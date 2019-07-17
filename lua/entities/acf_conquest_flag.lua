AddCSLuaFile()

ENT.Base   = "base_anim"
ENT.Name   = "ACF Conquest Flag"
ENT.Author = "TwistedTail"

if SERVER then
	local concommand = concommand
	local ents = ents

	function ENT:SetFlagTrigger(Pos, Ang, Size)
		local Trigger = ents.Create("acf_conquest_flag_trigger")

		if not IsValid(Trigger) then return end

		if IsValid(self.Trigger) then
			self.Trigger:Remove()
		end

		Trigger:SetPos(Pos)
		Trigger:SetAngles(Ang)
		Trigger:SetModel("models/props_junk/PopCan01a.mdl")
		Trigger:PhysicsInit(SOLID_OBB)
		Trigger:SetMoveType(MOVETYPE_NONE)
		Trigger:Spawn()

		Trigger:SetNoDraw(true)
		Trigger:SetTrigger(true)
		Trigger:UseTriggerBounds(true, Size)

		Trigger.Flag = self

		self.Trigger = Trigger
		self.Players = {}

		return Trigger
	end

	function ACF_Conq.CreateFlag(Pos, Ang, Name, Model, Size, OffsetPos, OffsetAng)
		local Flag = ents.Create("acf_conquest_flag")

		if not IsValid(Flag) then return end

		OffsetPos = OffsetPos or Vector()
		OffsetAng = OffsetAng or Angle()

		Flag:SetPos(Pos + OffsetPos)
		Flag:SetAngles(Ang + OffsetAng)
		Flag:SetModel(Model)
		Flag:PhysicsInit(SOLID_NONE)
		Flag:SetMoveType(MOVETYPE_NONE)
		Flag:Spawn()

		Flag:SetFlagTrigger(Pos, Ang, Size)

		Flag.Name = Name
		Flag.Model = Model

		local Index = ACF_Conq.FlagCount + 1
		ACF_Conq.FlagCount = Index
		ACF_Conq.Flags[Name] = ACF_ConqNewFlag(
			Name,
			Index,
			Pos,
			Ang,
			Model,
			Size,
			OffsetPos,
			OffsetAng
		)

		return Flag
	end

	function ENT:OnRemove()
		self.Trigger:Remove()

		if next(self.Players) then
			for Ply in pairs(self.Players) do
				if Ply:IsPlayer() then
					Ply.ACF_Conq.Flags[self] = nil
				end
			end
		end
	end

	concommand.Add("remove_flags", function()
		local Result = ents.FindByClass("acf_conquest_flag")

		if not next(Result) then return end

		for i = #Result, 1, -1 do
			Result[i]:Remove()
		end
	end)
end