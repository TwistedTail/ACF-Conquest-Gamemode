ACF_Conq = ACF_Conq or {}

if SERVER then
	AddCSLuaFile("acf_conquest/users.lua")
	AddCSLuaFile("acf_conquest/points.lua")
	AddCSLuaFile("acf_conquest/cl_init.lua")
	AddCSLuaFile("acf_conquest/tool_options.lua")

	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/sv_init.lua")

	CreateConVar("acf_conquest_enable", "1", FCVAR_ARCHIVE, "Enables the ACF Conquest Gamemode.")
	CreateConVar("acf_conquest_enable_bots", "1", FCVAR_ARCHIVE, "Enables bot spawning.")
	CreateConVar("acf_conquest_max_bots", "15", FCVAR_ARCHIVE, "Defines the maximum amount of bots per team.")
end

if CLIENT then
	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/cl_init.lua")
	include("acf_conquest/tool_options.lua")
end