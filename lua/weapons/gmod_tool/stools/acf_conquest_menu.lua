TOOL.Category = "ACF Conquest"
TOOL.Name = "ACF Conquest Menu"

if SERVER then
	util.AddNetworkString("ACF Conquest Set Operation")
	util.AddNetworkString("ACF Conquest Set Stage")

	net.Receive("ACF Conquest Operation", function(_, Player)
		if not IsValid(Player) then return end
		if not Player:IsSuperAdmin() then return end
		if Player:GetTool().Mode ~= "acf_conquest_menu" then return end

		local Value = net.ReadInt(4)

		Player:GetTool():SetOperation(Value)
	end)

	net.Receive("ACF Conquest Stage", function(_, Player)
		if not IsValid(Player) then return end
		if not Player:IsSuperAdmin() then return end
		if Player:GetTool().Mode ~= "acf_conquest_menu" then return end

		local Value = net.ReadInt(4)

		Player:GetTool():SetStage(Value)
	end)
elseif CLIENT then
	language.Add("Tool.acf_conquest_menu.name", "ACF Conquest Menu")
	language.Add("Tool.acf_conquest_menu.desc", "Does nothing.")
	language.Add("Tool.acf_conquest_menu.0", "Select an option on the context menu.")

	TOOL.BuildCPanel = ACF_Conq.CreateContextPanel
end