-- Server init

ACF_Conq.Users = ACF_Conq.Users or {}
ACF_Conq.Points = ACF_Conq.Points or {}
ACF_Conq.Spawns = ACF_Conq.Spawns or {}
ACF_Conq.ActiveUsers = ACF_Conq.ActiveUsers or {}

local file = file
local os = os
local table = table
local timer = timer
local util = util

local DataFolder = "acf_conquest"
local MapName = game.GetMap()
local MapFile = DataFolder .. "/mapdata_" .. MapName .. ".txt"
local UserFile = DataFolder .. "/userdata.txt"
local QueuedSave = false
local NextSave = CurTime()

local function CheckFile(Folder, File)
	if not file.Exists(Folder, "DATA") then
		file.CreateDir(Folder)

		return false
	end

	return file.Exists(File, "DATA")
end

local function SaveUserTable(Forced)
	if not Forced then
		if QueuedSave then return end

		if NextSave > CurTime() then
			QueuedSave = true

			timer.Simple(NextSave - CurTime(), function()
				QueuedSave = false

				SaveUserTable()
			end)

			return
		end
	end

	local UserData = {}

	CheckFile(DataFolder, UserFile)

	NextSave = CurTime() + 10

	for _, v in pairs(ACF_Conq.Users) do
		table.insert(UserData, v:ToTable())
	end

	print("[ACF Conquest] Saving user data.")

	file.Write(UserFile, util.TableToJSON(UserData))
end

local function InitializeMaps()
	if not CheckFile(DataFolder, MapFile) then
		print("[ACF Conquest] No data found for the map " .. MapName .. ".")
	else
		local MapData = util.JSONToTable(file.Read(MapFile, "DATA"))
		ACF_Conq.Spawns = MapData.Spawns
		ACF_Conq.Points = {}

		if next(MapData.Points) then
			for _, v in pairs(MapData.Points) do
				table.insert(ACF_Conq.Points, ACF_UpdatePointData(v))
			end

			print("[ACF Conquest] Loaded " .. #ACF_Conq.Points .. " capture point(s).")
		end

		if next(ACF_Conq.Spawns) then
			print("[ACF Conquest] Loaded " .. #ACF_Conq.Spawns .. " custom spawn point(s).")
		end
	end

	hook.Remove("Initialize", "ACF Conquest Map Init")
end

local function InitializeUsers()
	if not CheckFile(DataFolder, UserFile) then
		print("[ACF Conquest] No user data was found.")
	else
		local UserData = util.JSONToTable(file.Read(UserFile, "DATA"))

		if next(UserData) then
			for _, v in pairs(UserData) do
				local User = ACF_UpdateUserData(v)

				ACF_Conq.Users[User:GetSteamID()] = User
			end

			print("[ACF Conquest] Loaded " .. #UserData .. " user profile(s).")
		end
	end

	hook.Remove("Initialize", "ACF Conquest User Init")
end

local function OnPlayerInitialSpawn(Player)
	local UserID = game.SinglePlayer() and util.CRC(Player:Name()) or Player:SteamID()

	if not ACF_Conq.Users[UserID] then
		local Date = os.date("%m-%d-%Y %H:%M:%S", os.time())
		local User = ACF_NewUserData(UserID, 420, Date)

		ACF_Conq.Users[UserID] = User

		print("[ACF Conquest] Registering new user with ID " .. UserID .. ".")
	end

	Player.ACF_ConqData = ACF_Conq.Users[UserID]
	ACF_Conq.ActiveUsers[Player] = true

	SaveUserTable()
end

local function OnPlayerDisconnect(Player)
	if not Player.ACF_ConqData then return end

	local Date = os.date("%m-%d-%Y %H:%M:%S", os.time())

	Player.ACF_ConqData:SetLastSeen(Date)
	Player.ACF_ConqData:SetTeam("None")

	ACF_Conq.ActiveUsers[Player] = nil

	SaveUserTable()
end

local function OnPlayerDeath(Victim, Inflictor, Attacker)
	local VictimPlayer = Victim:IsPlayer()
	local AttackerPlayer = Attacker:IsPlayer()

	if VictimPlayer then
		Victim.ACF_ConqData:AddDeath(1)
	end

	if AttackerPlayer then
		Attacker.ACF_ConqData:AddKill(1)
		Attacker.ACF_ConqData:AddBalance(100)
	end

	if VictimPlayer or AttackerPlayer then
		SaveUserTable()
	end
end

local function OnNPCKilled(NPC, Attacker)
	if Attacker:IsPlayer() then
		Attacker.ACF_ConqData:AddKill(1)
		Attacker.ACF_ConqData:AddBalance(50)

		SaveUserTable()
	end
end

local function OnShutDown()
	if not next(ACF_Conq.ActiveUsers) then return end

	local Date = os.date("%m-%d-%Y %H:%M:%S", os.time())

	for k in pairs(ACF_Conq.ActiveUsers) do
		k.ACF_ConqData:SetLastSeen(Date)
		k.ACF_ConqData:SetTeam("None")
	end

	SaveUserTable(true)
end

hook.Add("Initialize", "ACF Conquest Map Init", InitializeMaps)
hook.Add("Initialize", "ACF Conquest User Init", InitializeUsers)
hook.Add("PlayerInitialSpawn", "ACF Conquest Player Initial Spawn", OnPlayerInitialSpawn)
hook.Add("PlayerDisconnected", "ACF Conquest Player Disconnect", OnPlayerDisconnect)
hook.Add("PlayerDeath", "ACF Conquest Player Death", OnPlayerDeath)
hook.Add("OnNPCKilled", "ACF Conquest NPC Death", OnNPCKilled)
hook.Add("ShutDown", "ACF Conquest Server Shutdown", OnShutDown)