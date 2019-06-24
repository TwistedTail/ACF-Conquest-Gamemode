-- Global enumerations
ACSR_GET = 1
ACSR_SET = 2
ACSR_GETSET = 3

local function CreateAccessor(Table, Key, Name, Type)
	if not Table then return end

	if bit.band(1, Type) == 1 then
		Table["Get" .. Name] = function(This)
			return This[Key]
		end
	end

	if bit.band(2, Type) == 2 then
		Table["Set" .. Name] = function(This, Value)
			This[Key] = Value
		end
	end
end

ACF_Conq.CreateAccessor = CreateAccessor