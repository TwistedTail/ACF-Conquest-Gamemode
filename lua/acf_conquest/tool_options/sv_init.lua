local concommand = concommand
local hook = hook
local net = net
local util = util

util.AddNetworkString("ACF Conquest Set Operation")
util.AddNetworkString("ACF Conquest Set Stage")
util.AddNetworkString("ACF Conquest Server Data")

local function CanReceive(Player)
	if not IsValid(Player) then return false end
	if not Player:IsSuperAdmin() then return false end
	if Player:GetTool().Mode ~= "acf_conquest_menu" then return false end

	return true
end

local function OnPlayerInitialSpawn(Player)
	net.Start("ACF Conquest Server Data")
		net.WriteString(ACF_Conq.GetVersionStatus())
		net.WriteTable(ACF_Conq.GetLatestCommits())
		net.WriteTable(ACF_Conq.Flags)
	net.Send(Player)
end

net.Receive("ACF Conquest Operation", function(_, Player)
	if not CanReceive(Player) then return end

	Player:GetTool():SetOperation(net.ReadInt(4))
end)

net.Receive("ACF Conquest Stage", function(_, Player)
	if not CanReceive(Player) then return end

	Player:GetTool():SetStage(net.ReadInt(4))
end)

concommand.Add("acf_conquest_setconvar", function(Player, Command, Args)
	if not CanReceive(Player) then print(Player, "can't receive") return end

	RunConsoleCommand(unpack(Args))
end)

hook.Add("PlayerInitialSpawn", "ACF Conquest Server Data", OnPlayerInitialSpawn)