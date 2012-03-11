--[[
	main.lua
		The bagnon driver thingy
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local GuildBank = Bagnon:NewModule('GuildBank', 'AceEvent-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-GuildBank')

function GuildBank:OnEnable()
	Bagnon.GuildFrame:New('guildbank', L.Title)

	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
end

function GuildBank:GUILDBANKFRAME_OPENED()
	Bagnon.FrameSettings:Get('guildbank'):Show()
	QueryGuildBankTab(GetCurrentGuildBankTab())
end

function GuildBank:GUILDBANKFRAME_CLOSED()
	Bagnon.FrameSettings:Get('guildbank'):Hide()
end
