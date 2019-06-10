ACF_Conq = ACF_Conq or {}

if SERVER then
	AddCSLuaFile("acf_conquest/users.lua")
	AddCSLuaFile("acf_conquest/points.lua")
	AddCSLuaFile("acf_conquest/cl_init.lua")
	AddCSLuaFile("acf_conquest/tool_options.lua")

	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/sv_init.lua")

	CreateConVar("acf_conquest_enable", "1", FCVAR_ARCHIVE, "Enable/disable the ACF Conquest Gamemode.")
	CreateConVar("acf_conquest_enable_bots", "1", FCVAR_ARCHIVE, "Enable/disable bot spawning.")
end

if CLIENT then
	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/cl_init.lua")
	include("acf_conquest/tool_options.lua")
end