TOOL.Category	= "ACF Conquest"
TOOL.Name		= "ACF Conquest Menu"
TOOL.Author		= "TwistedTail"

if SERVER then
	function TOOL:LeftClick(Trace)
		if not self:GetOwner():IsSuperAdmin() then return false end
		if Trace.HitSky then return false end

		local Pos = Trace.HitPos
		local Ang = Angle()
		local Name = "Test"
		local Model = "models/props_c17/FurnitureToilet001a.mdl"

		ACF_Conq.CreateFlag(Pos, Ang, Name, Model, 255, Vector(0, 0, 50))

		return true
	end
elseif CLIENT then
	TOOL.BuildCPanel = ACF_Conq.CreateContextPanel
end