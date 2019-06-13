local CurrentOption
local OptionsLookup = {}
local OptionsTable = {}

-- Adding compatibility with DForm panels
-- https://wiki.garrysmod.com/page/Category:DForm
local FormPanels = {
	Button = { "", "", "" },
	CheckBox = { "", "" },
	ComboBox = { "", "" },
	ControlHelp = { "" },
	Help = { "" },
	ListBox = { "" },
	NumberWang = { "", "", 0, 0, 0 },
	NumSlider = { "", "", 0, 0, 0 },
	PanelSelect = { },
	TextEntry = { "", "" }
}

-- Don't use this function inside an Option Item, use CreateTempItem instead!
local function CreateItem(Name, Parent, HasText)
	local Panel
	local FormData = FormPanels[Name]

	if FormData then
		Panel = Parent[Name](Parent, unpack(FormData)) -- Creating a DForm panel. Ex: DForm.Button(DForm, ...)

		if HasText then
			Panel:SetFont("Trebuchet18")
		end
	else
		Panel = vgui.Create(Name, Parent)
		Panel:Dock(TOP)

		if HasText then
			Panel:SetFont("Trebuchet18")
			Panel:SetDark(true)

			if Panel.SetAutoStretchVertical then
				Panel:SetAutoStretchVertical(true)
			end

			Panel:SetWrap(true)
		end

		Parent:AddItem(Panel)
	end

	Panel:DockMargin(5, 0, 5, 0)

	Parent.CreatedItems[Panel] = true

	return Panel
end

-- I highly recommend to use this one for items created inside AddOptionItem
local function CreateTempItem(Name, Parent, HasText)
	local Panel = CreateItem(Name, Parent, HasText)

	Parent.TempItems[Panel] = true

	return Panel
end

local function ClearItems(Panel, Name)
	local Items = Panel[Name]

	if not Items then Panel[Name] = {} return end
	if not next(Items) then return end

	for Item in pairs(Items) do
		Item:Remove()
	end
end

local function WIPText(Panel)
	local Text = CreateTempItem("DLabel", Panel, true)
	Text:SetText("Work in Progress.")

	local Count = 0
	local CoolButton = CreateTempItem("Button", Panel, true)
	CoolButton:SetText("Here, press this button.")
	CoolButton.DoClickInternal = function()
		Count = Count + 1

		CoolButton:SetText("Pressed " .. Count .. " time" .. (Count ~= 1 and "s." or "."))
	end
end

local function AddOption(Name, SuperOnly)
	if not Name then return end

	local Index = #OptionsTable + 1

	CurrentOption = Name

	OptionsLookup[Name] = Index
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

	local Index = OptionsLookup[CurrentOption]
	local Data = OptionsTable[Index].data

	Data[#Data + 1] = {
		name = Name,
		icon = Icon,
		superonly = SuperOnly,
		action = Action,
	}
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

	ClearItems(Panel, "CreatedItems")

	local Reload = CreateItem("Button", Panel, true)
	Reload:SetText("Press to reload menu.")
	Reload.DoClick = function()
		ACF_Conq.CreateContextPanel(Panel)
	end

	local Title = CreateItem("Help", Panel, true)
	Title:SetText("Available options:")

	local Options = CreateItem("DComboBox", Panel, true)
	Options:SetSortItems(false)

	local Tree = CreateItem("DTree", Panel)
	Tree.OnNodeSelected = function(_, Node)
		if Option == Node then return end

		Option = Node

		ClearItems(Panel, "TempItems")

		if Option.Action then
			Option.Action(Panel)
		end
	end

	Options.OnSelect = function(_, _, _, Data)
		if Category == Data then return end

		Category = Data

		ClearItems(Panel, "TempItems")

		GenerateTree(Tree, Category)
	end

	GenerateMenu(Options)
end

-- Filling the tool's menu
AddOption("About the Addon")
AddOptionItem("Updates", "icon16/newspaper.png", nil, WIPText)
AddOptionItem("Description", "icon16/information.png", nil, WIPText)
AddOptionItem("Report a Bug", "icon16/bug.png", nil, function(Panel)
	local Text = CreateTempItem("Help", Panel, true)
	Text:SetText("Found a bug and don't really want to fix it yourself?\n" ..
				"Leave an issue report on the Github page!")

	local GitButton = CreateTempItem("Button", Panel, true)
	GitButton:SetText("Report a Bug Now!")
	GitButton.DoClickInternal = function()
		gui.OpenURL("https://github.com/TwistedTail/ACF-Conquest-Gamemode/issues/new/choose")
	end

	local Note = CreateTempItem("Help", Panel, true)
	Note:SetText("Important: Problems are easier to solve if you know what caused them. " ..
				"It's highly suggested to provide information about the bug you're reporting.")

	local Examples = CreateTempItem("Help", Panel, true)
	Examples:SetText("Examples of 'useful information' would be:\n" ..
					"- What were you doing when it happened?\n" ..
					"- Was there an error on the console? If so, please provide it.\n" ..
					"- Can you explain how to replicate the bug? If so, please give a short explanation.")
end)

AddOption("Tutorials")

AddOption("Server Settings", true)
AddOptionItem("Global Settings", "icon16/world.png", nil, function(Panel)
	local Test = CreateTempItem("Help", Panel, true)
	Test:SetText("It's not a soldier's gun (Not a soldier's gun!). " ..
				"Tight tolerances? Full length guide rod? UNRELIABLE!? " ..
				"IT'S UNRELIABLE LADIES AND GENTS! UN-FUCKING-RELIABLE " ..
				"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")

	local GMEnable = CreateTempItem("CheckBox", Panel, true)
	GMEnable:SetText("Enable the gamemode.")
	GMEnable:SetConVar("acf_conquest_enable")

	local BotEnable = CreateTempItem("CheckBox", Panel, true)
	BotEnable:SetText("Enable bot spawning.")
	BotEnable:SetConVar("acf_conquest_enable_bots")

	local BotAmount = CreateTempItem("NumSlider", Panel)
	BotAmount:SetTooltip("Defines the maximum amount of bots per team.")
	BotAmount:SetText("Bots per team")
	BotAmount:SetMax(100)
	BotAmount:SetConVar("acf_conquest_max_bots")

	local ScoreAmount = CreateTempItem("NumSlider", Panel)
	ScoreAmount:SetTooltip("Defines the amount of tickets each team starts with.")
	ScoreAmount:SetText("Tickets per team")
	ScoreAmount:SetMinMax(100, 2000)
	ScoreAmount:SetConVar("acf_conquest_max_tickets")
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
ACF_Conq.CreateItem = CreateItem
ACF_Conq.CreateTempItem = CreateTempItem
ACF_Conq.AddOption = AddOption
ACF_Conq.AddOptionItem = AddOptionItem