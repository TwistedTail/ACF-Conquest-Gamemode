-- Capture Point class
local ACF_POINT = {}
local ACF_POINT_Meta = {
	__index = ACF_POINT,
	__call = function( _, ... ) return ACF_NewCapturePoint( ... ) end
}

-- Capture Point getters
do
	function ACF_POINT:GetName()
		return self._name
	end

	function ACF_POINT:GetPos()
		return self._pos
	end

	function ACF_POINT:GetModel()
		return self._model
	end
end

-- Capture Point setters
do
	function ACF_POINT:SetName(Value)
		self._name = Value
	end

	function ACF_POINT:SetPos(Value)
		self._pos = Value
	end

	function ACF_POINT:SetModel(Value)
		self._model = Value
	end
end

-- ToTable method
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