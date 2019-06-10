-- Adding compatibility with DForm panels
local FormPanels = {
	Button = { "", "", "" },
	CheckBox = { "", "" },
	ComboBox = { "", "" },
	ControlHelp = { "" },
	Help = { "" },
	ListBox = { "" },
	NumberWang = { "", "", 0, 0 },
	NumSlider = { "", "", 0, 0 },
	PanelSelect = { },
	TextEntry = { "", "" }
}

-- Don't use this function inside OptionsTable, use CreateTempItem instead!
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

-- I highly recommend to use this one for items created inside OptionsTable
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
end

local OptionsTable = {
	{
		name = "About the Addon",
		data = {
			{
				name = "Updates",
				icon = "icon16/newspaper.png",
				action = WIPText,
			},
			{
				name = "Description",
				icon = "icon16/information.png",
				action = WIPText,
			},
			{
				name = "Report a Bug",
				icon = "icon16/bug.png",
				action = function(Panel)
					local Text = CreateTempItem("Help", Panel, true)
					Text:SetText("Found a bug and don't really want to fix it yourself?\n" ..
								"Leave an issue report on the Github page!")

					local GitButton = CreateTempItem("Button", Panel, true)
					GitButton:SetText("Report a Bug Now!")
					GitButton.DoClick = function()
						gui.OpenURL("https://github.com/TwistedTail/ACF-Conquest-Gamemode/issues")
					end

					local Note = CreateTempItem("Help", Panel, true)
					Note:SetText("Important: Problems are easier to solve if you know what caused them. " ..
								"It's highly suggested to provide information about the bug you're reporting.")

					local Examples = CreateTempItem("Help", Panel, true)
					Examples:SetText("Examples of 'useful information' would be:\n" ..
								"- What were you doing when it happened?\n" ..
								"- Was there an error on the console? If so, please provide it.\n" ..
								"- Can you explain how to replicate the bug? If so, please give a short explanation.")
				end,
			},
		},
	},
	{
		name = "Tutorials",
		data = {
		},
	},
	{
		name = "Server Settings",
		superonly = true,
		data = {
			{
				name = "Global Settings",
				icon = "icon16/world.png",
				action = function(Panel)
					local Test = CreateTempItem("Help", Panel, true)
					Test:SetText("It's not a soldier's gun (Not a soldier's gun!). " ..
								"Tight tolerances? Full length guide rod? UNRELIABLE!? " ..
								"IT'S UNRELIABLE LADIES AND GENTS! UN-FUCKING-RELIABLE " ..
								"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")

					local Enable = CreateTempItem("CheckBox", Panel, true)
					Enable:SetText("Enable/disable the gamemode.")
					Enable:SetConVar("acf_conquest_enable")

					local Bots = CreateTempItem("CheckBox", Panel, true)
					Bots:SetText("Enable/disable bots.")
					Bots:SetConVar("acf_conquest_enable_bots")
				end
			},
			{
				name = "Map Settings",
				icon = "icon16/map.png",
				action = WIPText,
			},
		},
	},
	{
		name = "Team Settings",
		superonly = true,
		data = {
			{
				name = "View Teams",
				icon = "icon16/eye.png",
				action = WIPText,
			},
			{
				name = "Edit Teams",
				icon = "icon16/pencil.png",
				action = WIPText,
			}
		},
	},
	{
		name = "Capture Points",
		superonly = true,
		data = {
			{
				name = "View Capture Points",
				icon = "icon16/eye.png",
				action = WIPText,
			},
			{
				name = "Edit Capture Points",
				icon = "icon16/pencil.png",
				action = WIPText,
			},
			{
				name = "Order Capture Points",
				icon = "icon16/arrow_switch.png",
				action = WIPText,
			},
		},
	},
	{
		name = "Spawn Points",
		superonly = true,
		data = {
			{
				name = "View Spawn Points",
				icon = "icon16/eye.png",
				action = WIPText,
			},
			{
				name = "Edit Spawn Points",
				icon = "icon16/pencil.png",
				action = WIPText,
			},
		},
	},
}

local function CanUseItem(Item, IsSuper)
	if not Item then return false end
	if not Item.superonly then return true end

	return IsSuper and Item.superonly
end

local function GenerateMenu(ComboBox)
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
		CreateContextPanel(Panel)
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

ACF_Conq.CreateContextPanel = CreateContextPanel
ACF_Conq.CreateItem = CreateItem