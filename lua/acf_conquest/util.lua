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
	local surface = surface
	local vgui = vgui

	surface.CreateFont("ACF_ConqTitle", {
		font = "Roboto",
		size = 23,
		weight = 1000,
	})

	surface.CreateFont("ACF_ConqBody", {
		font = "Roboto",
		size = 14,
		weight = 750,
	})

	surface.CreateFont("ACF_ConqControl", {
		font = "Roboto",
		size = 14,
		weight = 550,
	})

	local PANEL = FindMetaTable("Panel")

	function PANEL:SetTemporal(Parent)
		if not Parent.TempItems then
			Parent.TempItems = {}
		end

		Parent.TempItems[self] = true
	end

	function PANEL:SetNWConVar(Name)
		self = self.Button or self

		local OldSetValue = self.SetValue
		local OldThink = self.Think

		self.NWConVar = Name
		self.NWConVarValue = ""

		local function NWConVarThink(Panel)
			local Value = GetConVar(Panel.NWConVar):GetString()

			if #Value > 0 or Value ~= Panel.NWConVarValue then
				if isbool(Value) then
					Value = Value and 1 or 0
				end

				self.NWConVarValue = tostring(Value)

				OldSetValue(self, Value)
			end
		end

		function self:SetValue(Value)
			if isbool(Value) then
				Value = Value and 1 or 0
			end

			self.NWConVarValue = tostring(Value)

			if #self.NWConVarValue > 0 then
				RunConsoleCommand("acf_conquest_setconvar", self.NWConVar, self.NWConVarValue)
			end

			OldSetValue(self, Value)
		end

		timer.Simple(0.15, function()
			function self:Think()
				if OldThink then
					OldThink(self)
				end

				NWConVarThink(self)
			end
		end)
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

		function DForm:AddButton(Text)
			Text = Text or ""

			local Item = self:Button(Text, "", "")
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("ACF_ConqControl")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddCheckBox(Text)
			Text = Text or ""

			local Item = self:CheckBox(Text, "")
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("ACF_ConqControl")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddLabel(Text)
			Text = Text or ""

			local Item = self:Help(Text)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("ACF_ConqBody")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddTitle(Text)
			local Item = self:AddLabel(Text)
			Item:SetFont("ACF_ConqTitle")

			return Item
		end

		function DForm:AddHelp(Text)
			Text = Text or ""

			local Item = self:ControlHelp(Text)
			Item:DockMargin(25, 0, 5, 0)
			Item:SetFont("ACF_ConqBody")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddComboBox()
			local Item = vgui.Create("DComboBox", self)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetFont("ACF_ConqControl")
			Item:SetSortItems(false)
			Item:SetDark(true)
			Item:SetWrap(true)

			self:AddItem(Item)
			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddNumSlider(Text, Min, Max, Decimals)
			Text = Text or ""
			Min = Min or 0
			Max = Max or 0
			Decimals = Decimals or 0

			local Item = self:NumSlider(Text, "", Min, Max, Decimals)
			Item:DockMargin(5, 0, 5, 0)
			Item.Label:SetFont("ACF_ConqControl")

			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddTree()
			local Item = vgui.Create("DTree", self)
			Item:DockMargin(5, 0, 5, 0)

			self:AddItem(Item)
			self.CreatedItems[Item] = true

			return Item
		end

		function DForm:AddForm(Text)
			Text = Text or ""

			local Item = vgui.Create("DForm", self)
			Item:DockMargin(5, 0, 5, 0)
			Item:SetLabel(Text)
			Item.CreatedItems = {}

			self:AddItem(Item)
			self.CreatedItems[Item] = true

			return Item
		end
	end)

	local CurrentOption
	local OptionsLookup = {}
	local OptionsTable = {}

	local function AddOption(Name, SuperOnly)
		if not Name then return end

		local Index

		if not OptionsLookup[Name] then
			Index = #OptionsTable + 1
			OptionsLookup[Name] = { index = Index }
		else
			Index = OptionsLookup[Name].index
		end

		CurrentOption = Name

		OptionsTable[Index] = {
			name = Name,
			superonly = SuperOnly,
			data = {},
		}
	end

	local function AddOptionItem(Name, Icon, SuperOnly, Action)
		if not CurrentOption then return end
		if not OptionsLookup[CurrentOption] then return end
		if not Name then return end

		local Option = OptionsLookup[CurrentOption]
		local Index = Option.index
		local Data = OptionsTable[Index].data
		local DataIndex = Option[Name] or #Data + 1

		Option[Name] = DataIndex
		Data[DataIndex] = {
			name = Name,
			icon = Icon,
			superonly = SuperOnly,
			action = Action,
		}
	end

	local function CanUseItem(Item, IsSuper)
		if not Item then return false end
		if not Item.superonly then return true end

		return IsSuper and Item.superonly
	end

	local function GenerateMenu(ComboBox)
		if not next(OptionsTable) then return end

		local IsSuper = LocalPlayer():IsSuperAdmin()

		for _, v in pairs(OptionsTable) do
			if CanUseItem(v, IsSuper) then
				ComboBox:AddChoice(v.name, v.data)
			end
		end

		ComboBox:ChooseOptionID(1)
	end

	local function GenerateTree(Tree, Category)
		local Count = 0.5

		Tree:Clear()
		Tree:SelectNone()

		if next(Category) then
			local IsSuper = LocalPlayer():IsSuperAdmin()
			local First

			for _, v in pairs(Category) do
				if CanUseItem(v, IsSuper) then
					local Node = Tree:AddNode(v.name, v.icon)

					Node.Action = v.action

					Count = Count + 1

					if not First then
						First = true
						Tree:SetSelectedItem(Node)
					end
				end
			end
		end

		Tree:SetHeight(Tree:GetLineHeight() * Count)
	end

	ACF_Conq.AddOption = AddOption
	ACF_Conq.AddOptionItem = AddOptionItem
	ACF_Conq.CanUseItem = CanUseItem
	ACF_Conq.GenerateMenu = GenerateMenu
	ACF_Conq.GenerateTree = GenerateTree
end

ACF_Conq.CreateAccessor = CreateAccessor