--[[
	item.lua
		A guild item slot button
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local ItemSlot = Bagnon:NewClass('GuildItemSlot', 'Button', Bagnon.ItemSlot)
local ItemSearch = LibStub('LibItemSearch-1.0')


--[[ ItemSlot Constructor ]]--

function ItemSlot:New(tab, slot, frameID, parent)
	local item = self:Restore() or self:Create()
	item:SetFrameID(frameID)
  item:SetSlot(tab, slot)
  item:SetParent(parent)

	if item:IsVisible() then
		item:Update()
	else
		item:Show()
	end

	return item
end

--constructs a brand new item slot
function ItemSlot:Create()
	local id = self:GetNextItemSlotID()
	local item = self:Bind(self:ConstructNewItemSlot(id))

	item:RegisterForClicks('anyUp')
	item:RegisterForDrag('LeftButton')

	item:SetScript('OnEvent', item.HandleEvent)
	item:SetScript('OnClick', item.OnClick)
	item:SetScript('OnDragStart', item.OnDragStart)
	item:SetScript('OnReceiveDrag', item.OnReceiveDrag)
	item:SetScript('OnEnter', item.OnEnter)
	item:SetScript('OnLeave', item.OnLeave)
	item:SetScript('OnShow', item.OnShow)
	item:SetScript('OnHide', item.OnHide)

	return item
end

--creates a new item slot for <id>
function ItemSlot:ConstructNewItemSlot(id)
	local item = CreateFrame('Button', 'BagnonGuildItemSlot' .. id, nil, 'ItemButtonTemplate')
	item:Hide()

	--add a quality border texture
	local border = item:CreateTexture(nil, 'OVERLAY')
	border:SetWidth(67)
	border:SetHeight(67)
	border:SetPoint('CENTER', item)
	border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
	border:SetBlendMode('ADD')
	border:Hide()
	item.border = border

	return item
end

--returns the next available item slot
function ItemSlot:Restore()
	local item = ItemSlot.unused and next(ItemSlot.unused)
	if item then
		ItemSlot.unused[item] = nil
		return item
	end
end

--gets the next unique item slot id
do
	local id = 0
	function ItemSlot:GetNextItemSlotID()
		id = id + 1
		return id
	end
end


--[[ ItemSlot Destructor ]]--

function ItemSlot:Free()
	self:Hide()
	self:SetParent(nil)
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	ItemSlot.unused = ItemSlot.unused or {}
	ItemSlot.unused[self] = true
end


--[[ Events ]]--

function ItemSlot:GUILDBANK_ITEM_LOCK_CHANGED(event, tab, slot)
	self:UpdateLocked()
end

function ItemSlot:OnClick(button)
	if HandleModifiedItemClick(self:GetItem()) then
		return
	end

	if self:IsCached() then
		return
	end

	if IsModifiedClick('SPLITSTACK') then
		if not self:IsLocked() then
			OpenStackSplitFrame(self:GetCount(), self, 'BOTTOMLEFT', 'TOPLEFT')
		end
		return
	end

	local type, money = GetCursorInfo()
	if type == 'money' then
		DepositGuildBankMoney(money)
		ClearCursor()
	elseif type == 'guildbankmoney' then
		DropCursorMoney()
		ClearCursor()
	else
		if button == 'RightButton' then
			AutoStoreGuildBankItem(self:GetSlot())
		else
			PickupGuildBankItem(self:GetSlot())
		end
	end
end

function ItemSlot:OnDragStart(button)
	PickupGuildBankItem(self:GetSlot())
end

function ItemSlot:OnReceiveDrag(button)
	PickupGuildBankItem(self:GetSlot())
end

function ItemSlot:OnShow()
	self:RegisterEvent('GUILDBANK_ITEM_LOCK_CHANGED')
  self:Update()
end


--[[ Update Methods ]]--

function ItemSlot:Update()
	if not self:IsVisible() then
    return
  end

	local texture, itemCount, locked, itemLink = self:GetItemSlotInfo()
	self:SetItem(itemLink)
	self:SetTexture(texture)
	self:SetCount(itemCount)
	self:SetLocked(locked)
	self:UpdateBorder()
	self:UpdateSearch()

	if GameTooltip:IsOwned(self) then
		self:UpdateTooltip()
	end
end

function ItemSlot:SplitStack(split)
	local tab, slot = self:GetSlot()
	SplitGuildBankItem(tab, slot, split)
end

function ItemSlot:UpdateTooltip()
	if self:IsCached() then
		GameTooltip:SetHyperlink(self:GetItem())
	else
		GameTooltip:SetGuildBankItem(self:GetSlot())
	end

	GameTooltip:Show()
end


--[[ Accessor Methods ]]--

function ItemSlot:SetSlot(tab, slot)
	self.tab = tab
	self:SetID(slot)
	self:Update()
end

function ItemSlot:GetSlot()
	return self.tab, self:GetID()
end

function ItemSlot:IsSlot(tab, slot)
	return self.tab == tab and self:GetID() == slot
end

function ItemSlot:IsCached()
	return false
end

function ItemSlot:GetItemSlotInfo()
	local texture, itemCount, locked = GetGuildBankItemInfo(self:GetSlot())
	local itemLink = GetGuildBankItemLink(self:GetSlot())

	return texture, itemCount, locked, itemLink
end