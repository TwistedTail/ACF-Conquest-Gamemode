ACF_Conq = ACF_Conq or {}

if SERVER then
	AddCSLuaFile("acf_conquest/util.lua")
	AddCSLuaFile("acf_conquest/users.lua")
	AddCSLuaFile("acf_conquest/points.lua")
	AddCSLuaFile("acf_conquest/cl_init.lua")
	AddCSLuaFile("acf_conquest/tool_options.lua")

	include("acf_conquest/util.lua")
	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/sv_init.lua")

	CreateConVar("acf_conquest_enable", "1", FCVAR_ARCHIVE, "Enables the ACF Conquest Gamemode.")
	CreateConVar("acf_conquest_enable_bots", "1", FCVAR_ARCHIVE, "Enables bot spawning.")
	CreateConVar("acf_conquest_max_bots", "15", FCVAR_ARCHIVE, "Defines the maximum amount of bots per team.")
	CreateConVar("acf_conquest_max_tickets", "500", FCVAR_ARCHIVE, "Defines the amount of tickets each team starts with.")
	CreateConVar("acf_conquest_min_players", "4", FCVAR_ARCHIVE, "Defines the minimal amount of players needed to start a game.")
end

if CLIENT then
	include("acf_conquest/util.lua")
	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/cl_init.lua")
	include("acf_conquest/tool_options.lua")
end