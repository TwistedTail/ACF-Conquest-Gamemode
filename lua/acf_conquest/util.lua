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

if CLIENT then
	local PanelBase = baseclass.Get("Panel")

	function PanelBase:SetTemporal(Parent)
		if not Parent.TempItems then
			Parent.TempItems = {}
		end

		Parent.TempItems[self] = true
	end

	timer.Simple(1, function()
		function DForm:ClearItems(Name)
			local Items = self[Name]

			if Items and next(Items) then
				for Item in pairs(Items) do
					Item:Remove()
				end
			end

			self[Name] = {}
		end

		function DForm:FormButton(Text, CVar, Vararg)
			Text = Text or ""
			CVar = CVar or ""
			Vararg = Vararg or ""

			local Item = self:Button(Text, CVar, Vararg)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("DermaDefaultBold")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:FormCheckBox(Text, CVar)
			Text = Text or ""
			CVar = CVar or ""

			local Item = self:CheckBox(Text, CVar)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("DermaDefaultBold")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:FormLabel(Text)
			Text = Text or ""

			local Item = self:Help(Text)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("DermaDefaultBold")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:FormTitle(Text)
			Text = Text or ""

			local Item = self:Help(Text)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("Trebuchet24")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:FormComboBox()
			local Item = vgui.Create("DComboBox", self)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("DermaDefaultBold")
			Item:SetSortItems(false)
			Item:SetDark(true)
			Item:SetWrap(true)

			self:AddItem(Item)
			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:FormNumSlider(Text, CVar)
			Text = Text or ""
			CVar = CVar or ""

			local Item = self:NumSlider(Text, CVar, 0, 0, 0)
			Item:DockMargin(5, 0, 5, 0)

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:FormTree()
			local Item = vgui.Create("DTree", self)
			Item:DockMargin(5, 0, 5, 0)

			self:AddItem(Item)
			self.CreatedItems[Item] = true

			return Item
		end
	end)
end

ACF_Conq.CreateAccessor = CreateAccessor