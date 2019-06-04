-- User class
local ACF_USER = {}
local ACF_USER_Meta = {
	__index = ACF_USER,
	__call = function( _, ... ) return ACF_NewUserData( ... ) end,
}

-- User local functions
local function SetKillDeathRatio(User)
	local Ratio = User._kills / User._deaths

	User._kdr = Ratio ~= Ratio and 0 or Ratio
end

local function SetWinrate(User)
	local Games = User._victories + User._defeats
	local Winrate = User._victories / Games

	User._winrate = Winrate ~= Winrate and 0 or Winrate
	User._games = Games
end

-- User getters
do
	function ACF_USER:GetSteamID()
		return self._steamid
	end

	function ACF_USER:GetBalance()
		return self._balance
	end

	function ACF_USER:GetLastSeen()
		return self._lastseen
	end

	function ACF_USER:GetTeam()
		return self._team
	end

	function ACF_USER:GetKills()
		return self._kills
	end

	function ACF_USER:GetDeaths()
		return self._deaths
	end

	function ACF_USER:GetKillDeathRatio()
		return self._kdr
	end

	function ACF_USER:GetVictories()
		return self._victories
	end

	function ACF_USER:GetDefeats()
		return self._defeats
	end

	function ACF_USER:GetTotalGames()
		return self._games
	end

	function ACF_USER:GetWinrate()
		return self._winrate
	end
end

-- User setters
do
	function ACF_USER:SetLastSeen(Value)
		self._lastseen = Value
	end

	function ACF_USER:SetTeam(Value)
		self._team = Value
	end
end

-- Add functions
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

-- ToTable method
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