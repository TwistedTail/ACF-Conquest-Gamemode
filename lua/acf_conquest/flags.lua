-- Flag class
local ACF_FLAG = {}
local ACF_FLAG_Meta = {
	__index = ACF_FLAG,
	__call = function( _, ... ) return ACF_ConqNewFlag( ... ) end
}

-- Flag Get/Set methods
ACF_Conq.CreateAccessor(ACF_FLAG, "_name", "Name", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_order", "Order", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_pos", "Pos", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_ang", "Angle", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_model", "Model", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_size", "Size", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_offsetPos", "OffsetPos", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_FLAG, "_offsetAng", "OffsetAng", ACSR_GETSET)

-- Flag ToTable method
function ACF_FLAG:ToTable()
	local Result = {}

	for k, v in pairs(self) do
		Result[k] = v
	end

	return Result
end

-- Create/Update Flag functions
function ACF_ConqNewFlag(Name, Order, Pos, Ang, Model, Size, OffsetPos, OffsetAng)
	local Data = {
		_name = Name or "",
		_order = Order or 0,
		_pos = Pos or Vector(),
		_ang = Ang or Angle(),
		_model = Model or "",
		_size = Size or 255,
		_offsetPos = OffsetPos or Vector(),
		_offsetAng = OffsetAng or Angle(),
	}

	setmetatable(Data, ACF_FLAG_Meta)

	return Data
end

function ACF_ConqUpdateFlag(Point)
	return ACF_ConqNewFlag(
		Point._name,
		Point._order,
		Point._pos,
		Point._ang,
		Point._model,
		Point._size,
		Point._offsetPos,
		Point._offsetAng
	)
end