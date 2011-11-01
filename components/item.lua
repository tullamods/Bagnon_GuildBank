--[[
	item.lua
		A guild item slot button
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local ItemSlot = Bagnon:NewClass('GuildItemSlot', 'Button', Bagnon.ItemSlot)
ItemSlot.nextID = 0


--[[ Constructor ]]--

function ItemSlot:SetFrame(parent, tab, slot)
  self:SetSlot(tab, slot)
  self:SetParent(parent)
end

function ItemSlot:ConstructNewItemSlot(id)
	return CreateFrame('Button', 'BagnonGuildItemSlot' .. id, nil, 'ContainerFrameItemButtonTemplate')
end

function ItemSlot:CanReuseBlizzardBagSlots()
  return nil
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