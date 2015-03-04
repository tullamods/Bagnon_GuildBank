--[[
	main.lua
		Show and hide frame
--]]

local GuildBank = Bagnon:NewModule('GuildBank', 'AceEvent-3.0')

function GuildBank:OnEnable()
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
end

function GuildBank:GUILDBANKFRAME_OPENED()
	Bagnon.Cache.AtGuild = true
	Bagnon:ShowFrame('guild')
	QueryGuildBankTab(GetCurrentGuildBankTab())
end

function GuildBank:GUILDBANKFRAME_CLOSED()
	Bagnon.Cache.AtGuild = nil
	Bagnon:HideFrame('guild')
end