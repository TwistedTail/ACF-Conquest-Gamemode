-- Capture Point class
local ACF_POINT = {}
local ACF_POINT_Meta = {
	__index = ACF_POINT,
	__call = function( _, ... ) return ACF_NewCapturePoint( ... ) end
}

-- Capture Point Get/Set methods
ACF_Conq.CreateAccessor(ACF_POINT, "_name", "Name", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_POINT, "_pos", "Pos", ACSR_GETSET)
ACF_Conq.CreateAccessor(ACF_POINT, "_model", "Model", ACSR_GETSET)

-- Capture Point ToTable method
function ACF_POINT:ToTable()
	local Result = {}

	for k, v in pairs(self) do
		Result[k] = v
	end

	return Result
end

-- Create/Update Capture Point functions
function ACF_NewCapturePoint(Name, Position, Model)
	local Data = {
		_name = Name or "",
		_pos = Position or Vector(),
		_model = Model or "",
	}

	setmetatable(Data, ACF_POINT_Meta)

	return Data
end

function ACF_UpdatePointData(Point)
	return ACF_NewCapturePoint(
		Point._name,
		Point._pos,
		Point._model
	)
end