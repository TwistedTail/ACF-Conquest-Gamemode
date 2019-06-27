local file = file
local http = http
local IsValid = IsValid
local next = next
local os = os
local pairs = pairs
local print = print
local string = string
local unpack = unpack
local util = util

local RepoVersion
local RepoDate
local RepoOwner = "wiremod"
local RepoName = "wire" -- Using wiremod as a test since the repo is private
local RepoAPI = string.format("https://api.github.com/repos/%s/%s/commits?page=1&per_page=10", RepoOwner, RepoName)
local RepoLink = string.format("https://github.com/%s/%s", RepoOwner, RepoName)

local LocalVersion
local LocalDate

local Commits = Commits or {}

local function GetLocalVersion()
	if LocalVersion then return LocalVersion, LocalDate end

	local DataPath = "addons/ACF-Conquest-Gamemode"

	if not file.Exists(DataPath, "GAME") then
		local _, Folders = file.Find("addons/*", "GAME")

		for _, v in pairs(Folders) do
			if file.Exists("addons/" .. v .. "/lua/acf_conquest", "GAME") then
				DataPath = "addons/" .. v

				break
			end
		end
	end

	if file.Exists(DataPath .. "/.git/refs/heads/master", "GAME") then
		LocalVersion = "Git-" .. string.sub(file.Read(DataPath .. "/.git/refs/heads/master", "GAME"), 1, 8)
		LocalDate = file.Time(DataPath .. "/.git/refs/heads/master", "GAME")
	elseif file.Exists(DataPath .. "/.svn/wc.db", "GAME") then
		local Database = file.Read(DataPath .. "/.svn/wc.db", "GAME")
		local Start = Database:find(string.format("/%s/%s/!svn/ver/", RepoOwner, RepoName))
		local Offset = (Start or 0) + #RepoOwner + #RepoName + 12

		LocalVersion = "SVN-" .. Start and Database:sub(Offset, Offset + 3) or "Unknown"
		LocalDate = file.Time(DataPath .. "/.svn/wc.db", "GAME")
	else
		LocalVersion = "ZIP-Unknown"
		LocalDate = file.Time(DataPath .. "/.gitignore", "GAME")
	end

	return LocalVersion, LocalDate
end

GetLocalVersion() -- We're just gonna save our local version instantly

local function GitDateToEpoch(GitDate)
	local Date, Time = unpack(string.Explode("T", GitDate))
	local Year, Month, Day = unpack(string.Explode("-", Date))
	local Hour, Min, Sec = unpack(string.Explode(":", Time))

	return os.time({
		year = Year,
		month = Month,
		day = Day,
		hour = Hour,
		min = Min,
		sec = string.sub(Sec, 1, 2),
	})
end

local function GetTimezoneDiff()
	local Time = os.time()
	local Local = os.date("*t", Time)
	local LocalTime = os.time(Local)
	local GlobalTime = os.time(os.date("!*t", Time))
	local Difference = os.difftime(GlobalTime, LocalTime)

	if Local.isdst then
		if Difference > 0 then
			Difference = Difference - 3600
		else
			Difference = Difference + 3600
		end
	end

	return Difference
end

local function GetCommitMessage(Message)
	if not Message then return end

	local Start = Message:find("\n\n")

	Message = Message:Replace("\n\n", "\n"):gsub("[\r]*[\n]+[%s]+", "\n- ")

	local Title = Start and Message:sub(1, Start - 1) or Message
	local Body =  Start and Message:sub(Start + 1, #Message) or "No Commit Message"

	return Title, Body
end

local function CommitRequest(JSON, _, _, HTTPCode)
	if not JSON then
		print("Error: No data found on request.")

		return
	end

	local Data = util.JSONToTable(JSON)

	if HTTPCode == 200 then -- Success
		if not next(Data) then return end

		for k, v in pairs(Data) do
			local Date = GitDateToEpoch(v.commit.author.date) - GetTimezoneDiff()
			local Title, Body = GetCommitMessage(v.commit.message)

			Commits[k] = {
				id = v.sha,
				date = Date,
				author = v.commit.author.name,
				title = Title,
				message = Body,
				link = v.html_url,
			}
		end
	else
		print("Error " .. HTTPCode .. " - " .. Data.message ..
			"\n\tFor more info: \t" .. Data.documentation_url ..
			"\n\tRepository: \t" .. RepoLink)
	end
end

local function GetLatestCommits()
	if next(Commits) then return Commits end

	http.Fetch(RepoAPI, CommitRequest, print)

	return Commits
end

GetLatestCommits() -- We're also going to get the latest commits instantly

local function GetRepoVersion()
	if RepoVersion then return RepoVersion, RepoDate end

	local _, Commit = next(Commits)

	if Commit then
		RepoVersion = "Git-" .. string.sub(Commit.id, 1, 8)
		RepoDate = Commit.date
	end

	return RepoVersion, RepoDate
end

local function GetVersionStatus()
	GetRepoVersion()

	if not RepoVersion then return "Unable to Check" end
	if LocalVersion == RepoVersion then return "Up to Date" end
	if RepoDate > LocalDate then return "Update Available" end

	return "Up to Date"
end

concommand.Add("acf_conquest_version", function(Player)
	local Status = GetVersionStatus()
	local FullVersion = LocalVersion .. " | Updated " .. os.date("%B %d, %Y", LocalDate)
	local Message = "ACF Conquest:" ..
					"\n\tCurrent Version:\t" .. FullVersion ..
					"\n\tVersion Status:\t\t" .. Status

	if Status == "Update Available" then
		local FullRepoVersion = RepoVersion .. " | Updated " .. os.date("%B %d, %Y", RepoDate)

		Message = Message ..
				"\n\tLatest Version:\t\t" .. FullRepoVersion ..
				"\n\tRepository Link:\t" .. RepoLink
	end

	if IsValid(Player) then
		Player:ChatPrint(Message)
	else
		print(Message)
	end
end, nil, "Gets the current version of the ACF Conquest Gamemode.")

ACF_Conq.GetLocalVersion = GetLocalVersion
ACF_Conq.GetLatestCommits = GetLatestCommits
ACF_Conq.GetRepoVersion = GetRepoVersion
ACF_Conq.GetVersionStatus = GetVersionStatus