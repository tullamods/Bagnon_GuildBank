--[[
	itemFrame.lua
		A guild bank item slot container
--]]

local MODULE, Module =  ...
local Addon = Module.Addon
local ItemFrame = Addon:NewClass('GuildItemFrame', 'Frame', Addon.ItemFrame)
ItemFrame.Button = Addon.GuildItemSlot
ItemFrame.Transposed = true

function ItemFrame:RegisterEvents()
	self:UnregisterEvents()
	self:RegisterFrameMessage('PLAYER_CHANGED', 'Update')
	self:RegisterMessage('UPDATE_ALL', 'RequestLayout')

	if self:IsCached() then
		self:RegisterMessage('GUILDBANK_TAB_CHANGED', 'ForAll', 'Update')
  else
    self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED', 'ForAll', 'Update')
    self:RegisterEvent('GUILDBANK_ITEM_LOCK_CHANGED', 'ForAll', 'UpdateLocked')
	end
end

function ItemFrame:IsShowingBag(bag)
	return bag == GetCurrentGuildBankTab()
end

function ItemFrame:NumSlots()
	return 98
end
