TOOL.Category = "ACF Conquest"
TOOL.Name = "ACF Conquest Menu"

if CLIENT then
	language.Add("Tool.acf_conquest_menu.name", "ACF Conquest Menu")
	language.Add("Tool.acf_conquest_menu.desc", "Does nothing.")
	language.Add("Tool.acf_conquest_menu.0", "Left click: Nothing. Right click: Also nothing.")

	local MenuOptions = ACF_Conq.MenuOptions
	local CreateItem = ACF_Conq.CreateItem
	local ClearItems = ACF_Conq.ClearItems
	local Category
	local Option

	local function CreateContextPanel(Panel)
		local ShowMenu = LocalPlayer():IsSuperAdmin()

		Panel:Dock(FILL)

		ClearItems(Panel, "Items")

		if not ShowMenu then
			local ErrorText = CreateItem("DLabel", Panel, true)
			ErrorText:SetText("Error! You don't have enough priviledges to use this tool. Make sure you're a superadmin.")

			local Reload = CreateItem("DButton", Panel, true)
			Reload:SetText("Press to reload menu.")
			Reload.DoClick = function()
				CreateContextPanel(Panel)
			end

			return
		end

		local Title = CreateItem("DLabel", Panel, true)
		Title:SetText("Available options:")

		local Options = CreateItem("DComboBox", Panel, true)
		Options:SetSortItems(false)

		for _, v in pairs(MenuOptions) do
			Options:AddChoice(v.name, v.data)
		end

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

			Tree:Clear()
			Tree:SelectNone()

			ClearItems(Panel, "TempItems")

			Tree:SetHeight(Tree:GetLineHeight() * (#Category + 0.5))

			if next(Category) then
				for k, v in pairs(Category) do
					local Node = Tree:AddNode(v.name, v.icon)

					Node.Action = v.action

					if k == 1 then
						Tree:SetSelectedItem(Node)
					end
				end
			end
		end

		Options:ChooseOptionID(1) -- Must be done after defining OnSelect
	end

	TOOL.BuildCPanel = CreateContextPanel
end