-- Global enumerations
ACSR_GET = 1
ACSR_SET = 2
ACSR_GETSET = 3

local function CreateAccessor(Table, Key, Name, Type)
	if not Table then return end

	local Binary = math.IntToBin(Type)

	if bit.band("001", Binary) == 1 then
		Table["Get" .. Name] = function(This)
			return This[Key]
		end
	end

	if bit.band("010", Binary) == 10 then
		Table["Set" .. Name] = function(This, Value)
			This[Key] = Value
		end
	end
end

ACF_Conq.CreateAccessor = CreateAccessor