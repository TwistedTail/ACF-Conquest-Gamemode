-- User class
local ACF_USER = {}
local ACF_USER_Meta = {
	__index = ACF_USER,
	__call = function( _, ... ) return ACF_NewUserData( ... ) end,
}

-- User local functions
local function SetKillDeathRatio(User)
	local Ratio = User._kills / User._deaths

	User._kdr = User._deaths ~= 0 and Ratio or 0
end

local function SetWinrate(User)
	local Games = User._victories + User._defeats
	local Winrate = User._victories / Games

	User._winrate = Games ~= 0 and Winrate or 0
	User._games = Games
end

-- User Get/Set methods
ACF_Conq.CreateAccessor(ACF_USER, "_steamid", "SteamID", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_balance", "Balance", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_lastseen", "LastSeen", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_USER, "_team", "Team", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_USER, "_kills", "Kills", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_deaths", "Deaths", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_kdr", "KillDeathRatio", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_victories", "Victories", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_victories", "Defeats", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_games", "TotalGames", ACSR_GET)
ACF_Conq.CreateAccessor(ACF_USER, "_winrate", "Winrate", ACSR_GET)

-- User Add functions
do
	function ACF_USER:AddBalance(Value)
		self._balance = self._balance + Value
	end

	function ACF_USER:AddKill(Value)
		self._kills = self._kills + Value
		SetKillDeathRatio(self)
	end

	function ACF_USER:AddDeath(Value)
		self._deaths = self._deaths + Value
		SetKillDeathRatio(self)
	end

	function ACF_USER:AddVictory(Value)
		self._victories = self._victories + Value
		SetWinrate(self)
	end

	function ACF_USER:AddDefeat(Value)
		self._defeats = self._defeats + Value
		SetWinrate(self)
	end
end

-- User ToTable method
function ACF_USER:ToTable()
	local Result = {}

	for k, v in pairs(self) do
		Result[k] = v
	end

	return Result
end

-- Create/Update User functions
function ACF_NewUserData(SteamID, Balance, Date, Team, Kills, Deaths, Victories, Defeats)
	local Data = {
		_steamid = SteamID or "Unknown",
		_balance = Balance or 0,
		_lastseen = Date or "Unknown",
		_team = Team or "None",
		_kills = Kills or 0,
		_deaths = Deaths or 0,
		_victories = Victories or 0,
		_defeats = Defeats or 0,
	}

	SetKillDeathRatio(Data)
	SetWinrate(Data)

	setmetatable(Data, ACF_USER_Meta)

	return Data
end

function ACF_UpdateUserData(User)
	return ACF_NewUserData(
		User._steamid,
		User._balance,
		User._lastseen,
		User._team,
		User._kills,
		User._deaths,
		User._victories,
		User._defeats
	)
end