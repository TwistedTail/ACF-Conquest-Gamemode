AddCSLuaFile()

ENT.Base   = "base_anim"
ENT.Name   = "ACF Conquest Flag Trigger"
ENT.Author = "TwistedTail"

if SERVER then
	local debugoverlay = debugoverlay

	function ENT:StartTouch(Ent)
		if Ent:IsPlayer() or Ent:IsNPC() then
			print("Start", Ent)

			if Ent:IsPlayer() then
				Ent.ACF_Conq.Flags[self.Flag] = true
			end

			self.Flag.Players[Ent] = true

			debugoverlay.Cross(Ent:GetPos(), 32, 3, Color(0, 0, 255))
		end
	end

	function ENT:EndTouch(Ent)
		if Ent:IsPlayer() or Ent:IsNPC() then
			print("End", Ent)

			if Ent:IsPlayer() then
				Ent.ACF_Conq.Flags[self.Flag] = nil
			end

			self.Flag.Players[Ent] = nil

			debugoverlay.Cross(Ent:GetPos(), 32, 3, Color(255, 0, 0))
		end
	end
end