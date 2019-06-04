ACF_Conq = ACF_Conq or {}

if SERVER then
	AddCSLuaFile("acf_conquest/users.lua")
	AddCSLuaFile("acf_conquest/points.lua")
	AddCSLuaFile("acf_conquest/cl_init.lua")
	AddCSLuaFile("acf_conquest/tool_options.lua")

	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/sv_init.lua")
end

if CLIENT then
	include("acf_conquest/users.lua")
	include("acf_conquest/points.lua")
	include("acf_conquest/cl_init.lua")
	include("acf_conquest/tool_options.lua")
end