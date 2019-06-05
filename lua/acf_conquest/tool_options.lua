-- Don't use this function here, use CreateTempItem instead!
local function CreateItem(Name, Parent, HasText)
	local Control = vgui.Create(Name, Parent)
	Control:Dock(TOP)
	Control:DockMargin(10, 5, 10, 5)

	if HasText then
		Control:SetFont("Trebuchet18")
		Control:SetDark(true)
		Control:SetAutoStretchVertical(true)
		Control:SetWrap(true)
	end

	Parent.Items[Control] = true

	return Control
end

-- I highly recommend to use this one for items created inside the Options table
local function CreateTempItem(Name, Parent, HasText)
	local Control = CreateItem(Name, Parent, HasText)

	Parent.TempItems[Control] = true

	return Control
end

local function ClearItems(Control, Name)
	local Items = Control[Name]

	if not Items then Control[Name] = {} return end
	if not next(Items) then return end

	for Item in pairs(Items) do
		Item:Remove()
	end
end

local function WIPText(Panel)
	local Text = CreateTempItem("DLabel", Panel, true)
	Text:SetText("Work in Progress.")
end

local Options = {
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
					local Text = CreateTempItem("DLabel", Panel, true)
					Text:SetText("Found a bug and don't really want to fix it yourself?\n" ..
								"Leave an issue report on the Github page!")

					local GitButton = CreateTempItem("DButton", Panel, true)
					GitButton:SetText("Report a Bug Now!")
					GitButton.DoClick = function()
						gui.OpenURL("https://github.com/TwistedTail/ACF-Conquest-Gamemode/issues")
					end

					local Note = CreateTempItem("DLabel", Panel, true)
					Note:SetText("Important: Problems are easier to solve if you know what caused them. " ..
								"It's highly suggested to provide information about the bug you're reporting.\n\n" ..
								"Examples would be:\n" ..
								"- What were you doing when it happened?\n" ..
								"- Was there an error on the console? If so, please provide it.\n" ..
								"- Can you explain how to replicate the bug? If so, please give a short explanation.\n\n" ..
								"By giving useful information you make both tracking and fixing the bug an easier and faster process.")
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
		data = {
			{
				name = "Global Settings",
				icon = "icon16/world.png",
				action = function(Panel)
					local Test = CreateTempItem("DLabel", Panel, true)
					Test:SetText("It's not a soldier's gun (Not a soldier's gun!). " ..
								"Tight tolerances? Full length guide rod? UNRELIABLE!? " ..
								"IT'S UNRELIABLE LADIES AND GENTS! UN-FUCKING-RELIABLE " ..
								"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
				end
			},
		},
	},
	{
		name = "Team Settings",
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

ACF_Conq.MenuOptions = Options
ACF_Conq.CreateItem = CreateItem
ACF_Conq.ClearItems = ClearItems