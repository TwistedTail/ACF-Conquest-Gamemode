-- Server init

ACF_Conq.Users = ACF_Conq.Users or {}
ACF_Conq.FlagCount = ACF_Conq.FlagCount or 0
ACF_Conq.Flags = ACF_Conq.Flags or {}
ACF_Conq.Spawns = ACF_Conq.Spawns or {}
ACF_Conq.ActiveUsers = ACF_Conq.ActiveUsers or {}

local file = file
local hook = hook
local os = os
local timer = timer
local util = util

local DataFolder = "acf_conquest"
local MapName = game.GetMap()
local MapFile = DataFolder .. "/mapdata_" .. MapName .. ".txt"
local UserFile = DataFolder .. "/userdata.txt"
local QueuedUser = false
local QueuedMap = false
local NextUser = CurTime()
local NextMap = CurTime()

local function CheckFile(Folder, File)
	if not file.Exists(Folder, "DATA") then
		file.CreateDir(Folder)

		return false
	end

	return file.Exists(File, "DATA")
end

local function SaveUserTable(Forced)
	if not Forced then
		if QueuedUser then return end

		if NextUser > CurTime() then
			QueuedUser = true

			timer.Simple(NextUser - CurTime(), function()
				QueuedUser = false

				SaveUserTable()
			end)

			return
		end
	end

	local UserData = {}

	CheckFile(DataFolder, UserFile)

	NextUser = CurTime() + 10

	for _, v in pairs(ACF_Conq.Users) do
		UserData[v:GetSteamID()] = v:ToTable()
	end

	print("[ACF Conquest] Saving user data.")

	file.Write(UserFile, util.TableToJSON(UserData, true))
end

local function SaveMapTable(Forced)
	if not Forced then
		if QueuedMap then return end

		if NextMap > CurTime() then
			QueuedMap = true

			timer.Simple(NextMap - CurTime(), function()
				QueuedMap = false

				SaveUserTable()
			end)

			return
		end
	end

	local Data = {
		Spawns = {},
		Flags = {}
	}

	CheckFile(DataFolder, MapFile)

	NextMap = CurTime() + 3

	if next(ACF_Conq.Flags) then
		for _, v in pairs(ACF_Conq.Flags) do
			Data.Flags[v:GetOrder()] = v:ToTable()
		end
	end

	print("[ACF Conquest] Saving map data.")

	file.Write(MapFile, util.TableToJSON(Data, true))
end

local function InitializeVersion()
	local Version = ACF_Conq.GetLocalVersion()

	print("[ACF Conquest] Currently running on version " .. Version)

	timer.Simple(15, ACF_Conq.GetLatestCommits)

	hook.Remove("Initialize", "ACF Conquest Version Init")
end

local function InitializeMap()
	if not CheckFile(DataFolder, MapFile) then
		print("[ACF Conquest] No data found for the map " .. MapName .. ".")
	else
		local MapData = util.JSONToTable(file.Read(MapFile, "DATA"))
		ACF_Conq.Spawns = MapData.Spawns
		ACF_Conq.Flags = {}

		if next(MapData.Flags) then
			for _, Flag in pairs(MapData.Flags) do
				ACF_Conq.CreateFlag(
					Flag._pos,
					Flag._ang,
					Flag._name,
					Flag._model,
					Flag._size,
					Flag._offsetPos,
					Flag._offsetAng
				)
			end

			print("[ACF Conquest] Loaded " .. ACF_Conq.FlagCount .. " flag(s).")
		end

		if next(ACF_Conq.Spawns) then
			print("[ACF Conquest] Loaded " .. #ACF_Conq.Spawns .. " spawn point(s).")
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
			local Count = 0

			for k, v in pairs(UserData) do
				ACF_Conq.Users[k] = ACF_UpdateUserData(v)
				Count = Count + 1
			end

			print("[ACF Conquest] Loaded " .. Count .. " user profile(s).")
		end
	end

	hook.Remove("Initialize", "ACF Conquest User Init")
end

local function OnPlayerInitialSpawn(Player)
	local UserID = Player:SteamID()
	local Date = os.date("%m-%d-%Y %H:%M:%S", os.time())

	if not ACF_Conq.Users[UserID] then
		local User = ACF_NewUserData(UserID, 420)

		ACF_Conq.Users[UserID] = User

		print("[ACF Conquest] Registering new user with ID " .. UserID .. ".")
	end

	ACF_Conq.Users[UserID]:SetLastSeen(Date)
	ACF_Conq.ActiveUsers[Player] = true
	Player.ACF_Conq = {
		UserData = ACF_Conq.Users[UserID],
		Flags = {},
	}

	SaveUserTable()
end

local function OnPlayerDeath(Victim, Inflictor, Attacker)
	local VictimPlayer = Victim:IsPlayer()
	local AttackerPlayer = Attacker:IsPlayer()

	if VictimPlayer then
		Victim.ACF_Conq.UserData:AddDeath(1)
	end

	if AttackerPlayer then
		Attacker.ACF_Conq.UserData:AddKill(1)
		Attacker.ACF_Conq.UserData:AddBalance(100)
	end

	if VictimPlayer or AttackerPlayer then
		SaveUserTable()
	end
end

local function OnNPCKilled(NPC, Attacker)
	if Attacker:IsPlayer() then
		Attacker.ACF_Conq.UserData:AddKill(1)
		Attacker.ACF_Conq.UserData:AddBalance(50)

		SaveUserTable()
	end
end

local function OnPlayerDisconnect(Player)
	if not Player.ACF_Conq then return end

	local Date = os.date("%m-%d-%Y %H:%M:%S", os.time())

	Player.ACF_Conq.UserData:SetLastSeen(Date)
	Player.ACF_Conq.UserData:SetTeam("None")

	ACF_Conq.ActiveUsers[Player] = nil

	SaveUserTable()
end

local function OnShutDown()
	if next(ACF_Conq.ActiveUsers) then
		local Date = os.date("%m-%d-%Y %H:%M:%S", os.time())

		for k in pairs(ACF_Conq.ActiveUsers) do
			k.ACF_Conq.UserData:SetLastSeen(Date)
			k.ACF_Conq.UserData:SetTeam("None")
		end

		SaveUserTable(true)
	end

	SaveMapTable(true)
end

hook.Add("Initialize", "ACF Conquest Version Init", InitializeVersion)
hook.Add("Initialize", "ACF Conquest User Init", InitializeUsers)
hook.Add("InitPostEntity", "ACF Conquest Map Init", InitializeMap)
hook.Add("PlayerInitialSpawn", "ACF Conquest Player Initial Spawn", OnPlayerInitialSpawn)
hook.Add("PlayerDeath", "ACF Conquest Player Death", OnPlayerDeath)
hook.Add("OnNPCKilled", "ACF Conquest NPC Death", OnNPCKilled)
hook.Add("PlayerDisconnected", "ACF Conquest Player Disconnect", OnPlayerDisconnect)
hook.Add("ShutDown", "ACF Conquest Server Shutdown", OnShutDown)

ACF_Conq.SaveUserTable = SaveUserTable
ACF_Conq.SaveMapTable = SaveMapTable