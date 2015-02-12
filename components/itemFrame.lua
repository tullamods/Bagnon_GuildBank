--[[
	itemFrame.lua
		An guild bank item slot container
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local ItemFrame = Bagnon:NewClass('GuildItemFrame', 'Frame', Bagnon.ItemFrame)
ItemFrame.Button = Bagnon.GuildItemSlot

function ItemFrame:RegisterEvents()
	self:UnregisterEvents()
	self:RegisterMessage('UPDATE_ALL', 'RequestLayout')
	self:RequestLayout()

	if self:IsCached() then
		self:RegisterEvent('GET_ITEM_INFO_RECEIVED', 'ForAll', 'Update')
		self:RegisterMessage('GUILDBANK_TAB_CHANGED', 'ForAll', 'Update')
	else
		self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED', 'ForAll', 'Update')
		self:RegisterEvent('GUILDBANK_ITEM_LOCK_CHANGED', 'ForAll', 'UpdateLocked')
	end
end

function ItemFrame:IsShowing(bag)
	return bag == GetCurrentGuildBankTab()
end

function ItemFrame:IsCached()
	return Bagnon:IsBagCached(self:GetPlayer(), 'guild1')
end

function ItemFrame:NumSlots()
	return 98
end