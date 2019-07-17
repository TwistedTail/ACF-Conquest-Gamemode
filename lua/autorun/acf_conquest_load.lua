ACF_Conq = ACF_Conq or {}

if SERVER then
	AddCSLuaFile("acf_conquest/convars.lua")
	AddCSLuaFile("acf_conquest/util.lua")
	AddCSLuaFile("acf_conquest/users.lua")
	AddCSLuaFile("acf_conquest/flags.lua")
	AddCSLuaFile("acf_conquest/cl_init.lua")
	AddCSLuaFile("acf_conquest/tool_options/cl_init.lua")

	include("acf_conquest/convars.lua")
	include("acf_conquest/git_data.lua")
	include("acf_conquest/util.lua")
	include("acf_conquest/users.lua")
	include("acf_conquest/flags.lua")
	include("acf_conquest/sv_init.lua")
	include("acf_conquest/tool_options/sv_init.lua")
end

if CLIENT then
	include("acf_conquest/convars.lua")
	include("acf_conquest/util.lua")
	include("acf_conquest/users.lua")
	include("acf_conquest/flags.lua")
	include("acf_conquest/cl_init.lua")
	include("acf_conquest/tool_options/cl_init.lua")
end