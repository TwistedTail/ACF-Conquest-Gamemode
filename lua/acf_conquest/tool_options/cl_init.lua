local gui = gui
local language = language
local net = net
local next = next
local os = os
local pairs = pairs

local AddOption = ACF_Conq.AddOption
local AddOptionItem = ACF_Conq.AddOptionItem
local GenerateMenu = ACF_Conq.GenerateMenu
local GenerateTree = ACF_Conq.GenerateTree

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

language.Add("Tool.acf_conquest_menu.name", "ACF Conquest Menu")
language.Add("Tool.acf_conquest_menu.desc", "Does nothing.")
language.Add("Tool.acf_conquest_menu.0", "Select an option on the context menu.")

net.Receive("ACF Conquest Server Data", function(_, Player)
	if IsValid(Player) then return end

	ACF_Conq.Commits = net.ReadTable()
	ACF_Conq.VersionStatus = net.ReadString()
	ACF_Conq.Flags = net.ReadTable()
end)

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
	local GMTitle = Panel:AddTitle("Gamemode")
	GMTitle:SetTemporal(Panel)

	local GMEnable = Panel:AddCheckBox("Enable the gamemode.")
	GMEnable:SetNWConVar("acf_conquest_enable")
	GMEnable:SetTemporal(Panel)

	local ScoreAmount = Panel:AddNumSlider("Initial tickets", 100, 2000)
	ScoreAmount:SetNWConVar("acf_conquest_max_tickets")
	ScoreAmount:SetTemporal(Panel)

	local ScoreHelp = Panel:AddHelp("Amount of tickets each team starts with.")
	ScoreHelp:SetTemporal(Panel)

	local MinPlayers = Panel:AddNumSlider("Min. players", 1, 30)
	MinPlayers:SetNWConVar("acf_conquest_min_players")
	MinPlayers:SetTemporal(Panel)

	local MinPlayersHelp = Panel:AddHelp("Minimum amount of players per team needed to start a match.")
	MinPlayersHelp:SetTemporal(Panel)

	local BotTitle = Panel:AddTitle("Bots")
	BotTitle:SetTemporal(Panel)

	local BotEnable = Panel:AddCheckBox("Enable bot spawning.")
	BotEnable:SetNWConVar("acf_conquest_enable_bots")
	BotEnable:SetTemporal(Panel)

	local BotAmount = Panel:AddNumSlider("Bots per team", 0, 100)
	BotAmount:SetNWConVar("acf_conquest_max_bots")
	BotAmount:SetTemporal(Panel)

	local BotAmountHelp = Panel:AddHelp("Maximum amount of bots per team.")
	BotAmountHelp:SetTemporal(Panel)
end)
AddOptionItem("Map Settings", "icon16/map.png", nil, WIPText)

AddOption("Teams", true)
AddOptionItem("View Teams", "icon16/eye.png", nil, WIPText)
AddOptionItem("Edit Teams", "icon16/pencil.png", nil, WIPText)

AddOption("Capture Points", true)
AddOptionItem("View Capture Points", "icon16/eye.png", nil, WIPText)
AddOptionItem("Edit Capture Points", "icon16/pencil.png", nil, WIPText)
AddOptionItem("Order Capture Points", "icon16/arrow_switch.png", nil, WIPText)

AddOption("Spawn Points", true)
AddOptionItem("View Spawn Points", "icon16/eye.png", nil, WIPText)
AddOptionItem("Edit Spawn Points", "icon16/pencil.png", nil, WIPText)

ACF_Conq.CreateContextPanel = CreateContextPanel