--[[
	frame.lua
		A specialized version of the bagnon frame for guild banks
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local Frame = Bagnon.Classy:New('Frame', Bagnon.Frame)
Frame:Hide()
Bagnon.GuildFrame = Frame


--[[
	Events
--]]

function Frame:OnShow()
	PlaySound('GuildVaultOpen')

	self:UpdateEvents()
	self:RegisterMessage('SHOW_LOG_FRAME')
	self:RegisterMessage('SHOW_ITEM_FRAME')
	self:UpdateLook()
	
	if self:GetLogFrame():IsShown() then
		self:GetItemFrame():Hide()
	end
end

function Frame:OnHide()
--	GuildBankPopupFrame:Hide()
	StaticPopup_Hide('GUILDBANK_WITHDRAW')
	StaticPopup_Hide('GUILDBANK_DEPOSIT')
	StaticPopup_Hide('CONFIRM_BUY_GUILDBANK_TAB')
	CloseGuildBankFrame()
	PlaySound('GuildVaultClose')

	self:UpdateEvents()

	--fix issue where a frame is hidden, but not via bagnon controlled methods (ie, close on escape)
	if self:IsFrameShown() then
		self:HideFrame()
	end
end


--[[
	Messages
--]]

function Frame:SHOW_LOG_FRAME()
	self:ShowFrame(self:GetLogFrame())
	self:GetItemFrame():Hide()
end

function Frame:SHOW_ITEM_FRAME()
	self:ShowFrame(self:GetItemFrame())
	self:GetLogFrame():Hide()
end


--[[
	Create
--]]

function Frame:CreateItemFrame()
	local f = Bagnon.GuildItemFrame:New(self:GetFrameID(), self)
	self.itemFrame = f
	return f
end

function Frame:CreateBagFrame()
	local f = Bagnon.GuildTabFrame:New(self:GetFrameID(), self)
	self.bagFrame = f
	return f
end

function Frame:CreateMoneyFrame()
	local f = Bagnon.GuildMoneyFrame:New(self:GetFrameID(), self)
	self.moneyFrame = f
	return f
end

function Frame:CreateLogToggle()
	local f = Bagnon.LogToggle:New(self:GetFrameID(), self)
	self.logToggle = f
	return f
end

function Frame:CreateMoneyLogToggle()
	local f = Bagnon.MoneyLogToggle:New(self:GetFrameID(), self)
	self.moneyLogToggle = f
	return f
end

function Frame:CreateLogFrame()
	local item = self:GetItemFrame()
	local log = Bagnon.LogFrame:New(self:GetFrameID(), self)
	log:SetPoint('BOTTOMRIGHT', item, -25, 0)
	log:SetPoint('TOPLEFT', item)
	
	self.logFrame = log
	return log
end


--[[
	Properties
--]]

function Frame:HasLogs()
	return true
end

function Frame:GetLogFrame()
	return self.logFrame or self:CreateLogFrame()
end

function Frame:GetLogToggles()
	local log = self:GetLogToggle() or self:CreateLogToggle()
	local moneyLog = self:GetMoneyLogToggle() or self:CreateMoneyLogToggle()
	return log, moneyLog
end

function Frame:GetLogToggle()
	return self.logToggle
end

function Frame:GetMoneyLogToggle()
	return self.moneyLogToggle
end

function Frame:HasBagFrame()
	return true
end

function Frame:IsBagFrameShown()
	return true
end

function Frame:HasBagToggle()
	return false
end

function Frame:HasPlayerSelector()
	return false
end