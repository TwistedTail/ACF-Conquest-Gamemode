TOOL.Category = "ACF Conquest"
TOOL.Name = "ACF Conquest Menu"

if CLIENT then
	language.Add("Tool.acf_conquest_menu.name", "ACF Conquest Menu")
	language.Add("Tool.acf_conquest_menu.desc", "Does nothing.")
	language.Add("Tool.acf_conquest_menu.0", "Left click: Nothing. Right click: Also nothing.")

	local CreateItem = ACF_Conq.CreateItem
	local ClearItems = ACF_Conq.ClearItems
	local GenerateMenu = ACF_Conq.GenerateMenu
	local GenerateTree = ACF_Conq.GenerateTree

	local function CreateContextPanel(Panel)
		local Category
		local Option

		Panel:Dock(FILL)

		ClearItems(Panel, "Items")

		local Reload = CreateItem("DButton", Panel, true)
		Reload:SetText("Press to reload menu.")
		Reload.DoClick = function()
			CreateContextPanel(Panel)
		end

		local Title = CreateItem("DLabel", Panel, true)
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

	TOOL.BuildCPanel = CreateContextPanel
end