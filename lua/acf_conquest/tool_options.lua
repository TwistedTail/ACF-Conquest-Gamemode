local gui = gui
local next = next
local os = os
local pairs = pairs


local CurrentOption
local OptionsLookup = {}
local OptionsTable = {}

local function AddOption(Name, SuperOnly)
	if not Name then return end

	local Index

	if not OptionsLookup[Name] then
		Index = #OptionsTable + 1
		OptionsLookup[Name] = { Index = Index }
	else
		Index = OptionsLookup[Name].Index
	end

	CurrentOption = Name

	OptionsTable[Index] = {
		name = Name,
		superonly = SuperOnly,
		data = {},
	}
end

local function AddOptionItem(Name, Icon, SuperOnly, Action)
	if not CurrentOption then return end
	if not OptionsLookup[CurrentOption] then return end
	if not Name then return end

	local Option = OptionsLookup[CurrentOption]
	local Index = Option.Index
	local Data = OptionsTable[Index].data
	local DataIndex = Option[Name] or #Data + 1

	Option[Name] = DataIndex
	Data[DataIndex] = {
		name = Name,
		icon = Icon,
		superonly = SuperOnly,
		action = Action,
	}
end

local function WIPText(Panel)
	local Text = Panel:AddTitle("Work in Progress.")
	Text:SetTemporal(Panel)

	local Count = 0
	local CoolButton = Panel:AddButton("Here, press this button.")
	CoolButton:SetTemporal(Panel)
	CoolButton.DoClickInternal = function()
		Count = Count + 1

		CoolButton:SetText("Pressed " .. Count .. " time" .. (Count ~= 1 and "s." or "."))
	end
end

local function CanUseItem(Item, IsSuper)
	if not Item then return false end
	if not Item.superonly then return true end

	return IsSuper and Item.superonly
end

local function GenerateMenu(ComboBox)
	if not next(OptionsTable) then return end

	local IsSuper = LocalPlayer():IsSuperAdmin()

	for _, v in pairs(OptionsTable) do
		if CanUseItem(v, IsSuper) then
			ComboBox:AddChoice(v.name, v.data)
		end
	end

	ComboBox:ChooseOptionID(1)
end

local function GenerateTree(Tree, Category)
	local Count = 0.5

	Tree:Clear()
	Tree:SelectNone()

	if next(Category) then
		local IsSuper = LocalPlayer():IsSuperAdmin()
		local First

		for _, v in pairs(Category) do
			if CanUseItem(v, IsSuper) then
				local Node = Tree:AddNode(v.name, v.icon)

				Node.Action = v.action

				Count = Count + 1

				if not First then
					First = true
					Tree:SetSelectedItem(Node)
				end
			end
		end
	end

	Tree:SetHeight(Tree:GetLineHeight() * Count)
end

local function CreateContextPanel(Panel)
	local Category
	local Option

	Panel:ClearItems("CreatedItems")

	local Reload = Panel:AddButton("Press to reload menu.")
	Reload.DoClickInternal = function()
		ACF_Conq.CreateContextPanel(Panel)
	end

	Panel:AddLabel("Available options:")

	local Options = Panel:AddComboBox()

	local Tree = Panel:AddTree()
	Tree.OnNodeSelected = function(_, Node)
		if Option == Node then return end

		Option = Node

		Panel:ClearItems("TempItems")

		if Option.Action then
			Option.Action(Panel)
		end
	end

	Options.OnSelect = function(_, _, _, Data)
		if Category == Data then return end

		Category = Data

		Panel:ClearItems("TempItems")

		GenerateTree(Tree, Category)
	end

	GenerateMenu(Options)
end

-- Filling the tool's menu
AddOption("About the Addon")
AddOptionItem("Updates", "icon16/newspaper.png", nil, function(Panel)
	local Text = Panel:AddTitle("Latest Updates")
	Text:SetTemporal(Panel)

	local Status = Panel:AddLabel("Version Status: " .. ACF_Conq.VersionStatus)
	Status:SetTemporal(Panel)

	if not next(ACF_Conq.Commits) then
		local NoCommits = Panel:AddLabel("No commits were found.")
		NoCommits:SetTemporal(Panel)

		return
	end

	for _, v in pairs(ACF_Conq.Commits) do
		local Date = os.date("%Y/%m/%d - %H:%M:%S", v.date)

		local Form = Panel:AddForm("Update " .. Date)
		Form:SetTemporal(Panel)
		Form:Toggle()

		local Title = Form:AddTitle(v.title)
		Title:SetTemporal(Panel)

		local Author = Form:AddLabel("Author:\n" .. v.author)
		Author:SetTemporal(Panel)

		local Message = Form:AddLabel("Message:\n" .. v.message)
		Message:SetTemporal(Panel)

		local Link = Form:AddButton("View this commit")
		Link:SetTemporal(Panel)
		Link.DoClickInternal = function()
			gui.OpenURL(v.link)
		end
	end
end)
AddOptionItem("Description", "icon16/information.png", nil, WIPText)
AddOptionItem("Report a Bug", "icon16/bug.png", nil, function(Panel)
	local Text = Panel:AddLabel(
				"Found a bug and don't really want to fix it yourself?\n" ..
				"Leave an issue report on the Github page!")
	Text:SetTemporal(Panel)

	local GitButton = Panel:AddButton("Report a Bug Now!")
	GitButton:SetTemporal(Panel)
	GitButton.DoClickInternal = function()
		gui.OpenURL("https://github.com/TwistedTail/ACF-Conquest-Gamemode/issues/new/choose")
	end

	local Note = Panel:AddLabel(
				"Important: Problems are easier to solve if you know what caused them. " ..
				"It's highly suggested to provide information about the bug you're reporting.")
	Note:SetTemporal(Panel)

	local Examples = Panel:AddLabel(
					"Examples of 'useful information' would be:\n" ..
					"- What were you doing when it happened?\n" ..
					"- Was there an error on the console? If so, please provide it.\n" ..
					"- Can you explain how to replicate the bug? If so, please give a short explanation.")
	Examples:SetTemporal(Panel)
end)

AddOption("Tutorials")

AddOption("Server Settings", true)
AddOptionItem("Global Settings", "icon16/world.png", nil, function(Panel)
	local GMEnable = Panel:AddCheckBox("Enable the gamemode.", "acf_conquest_enable")
	GMEnable:SetTemporal(Panel)

	local BotEnable = Panel:AddCheckBox("Enable bot spawning.", "acf_conquest_enable_bots")
	BotEnable:SetTemporal(Panel)

	local BotAmount = Panel:AddNumSlider("Bots per team", "acf_conquest_max_bots")
	BotAmount:SetTemporal(Panel)
	BotAmount:SetTooltip("Defines the maximum amount of bots per team.")
	BotAmount:SetMax(100)

	local ScoreAmount = Panel:AddNumSlider("Tickets per team", "acf_conquest_max_tickets")
	ScoreAmount:SetTemporal(Panel)
	ScoreAmount:SetTooltip("Defines the amount of tickets each team starts with.")
	ScoreAmount:SetMinMax(100, 2000)

	local MinPlayers = Panel:AddNumSlider("Minimum players", "acf_conquest_min_players")
	MinPlayers:SetTemporal(Panel)
	MinPlayers:SetTooltip("Defines the minimal amount of players needed to start a game.")
	MinPlayers:SetMinMax(1, 30)
end)
AddOptionItem("Map Settings", "icon16/map.png", nil, WIPText)

AddOption("Team Settings", true)
AddOptionItem("View Teams", "icon16/eye.png", nil, WIPText)
AddOptionItem("Edit Teams", "icon16/pencil.png", nil, WIPText)

AddOption("Capture Point Settings", true)
AddOptionItem("View Capture Points", "icon16/eye.png", nil, WIPText)
AddOptionItem("Edit Capture Points", "icon16/pencil.png", nil, WIPText)
AddOptionItem("Order Capture Points", "icon16/arrow_switch.png", nil, WIPText)

AddOption("Spawn Point Settings", true)
AddOptionItem("View Spawn Points", "icon16/eye.png", nil, WIPText)
AddOptionItem("Edit Spawn Points", "icon16/pencil.png", nil, WIPText)

-- Globalizing useful functions
ACF_Conq.CreateContextPanel = CreateContextPanel
ACF_Conq.AddOption = AddOption
ACF_Conq.AddOptionItem = AddOptionItem