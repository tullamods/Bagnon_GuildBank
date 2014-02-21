--[[
	tab.lua
		A tab button object
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local TabFrame = Bagnon:NewClass('GuildTabFrame', 'Frame', Bagnon.BagFrame)
local Tab = Bagnon:NewClass('GuildTab', 'CheckButton', Bagnon.Bag)

Tab.SetSearch = function() end
Tab.ClearSearch = Tab.SetSearch
TabFrame.Button = Bagnon.Tab


--[[ Scripts ]]--

function Tab:New(...)
	local tab = Bagnon.Bag.New(self, ...)
	tab:SetScript('OnReceiveDrag', nil)
	tab:SetScript('OnDragStart', nil)

	return tab
end

function Tab:OnClick()
	local tab = self:GetID()
	local _,_ viewable = GetGuildBankTabInfo(tab)
	
	if viewable then
		SetCurrentGuildBankTab(tab)
		QueryGuildBankTab(tab)
	
		self:SendMessage('GUILD_BANK_TAB_CHANGE', tab)
	else
		self:SetChecked(false)
	end
end


--[[ Events ]]--

function Tab:UpdateEvents()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('GUILD_BANK_TAB_CHANGE')
		self:RegisterEvent('GUILDBANK_UPDATE_TABS')
		self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
	end
end

function Tab:GUILDBANK_UPDATE_TABS()
	self:Update()
end

function Tab:GUILD_BANK_TAB_CHANGE(msg, tabID)
	self:UpdateChecked()
end

function Tab:GUILDBANKBAGSLOTS_CHANGED()
	self:UpdateCount()
end


--[[ Actions ]]--

function Tab:Update()
	local name, icon, viewable, _,_, remainingWithdrawals = self:GetInfo()
	SetItemButtonTexture(self, icon or [[Interface\PaperDoll\UI-PaperDoll-Slot-Bag]])
	
	if viewable then
		SetItemButtonTextureVertexColor(self, 1, 1, 1)
	else
		SetItemButtonTextureVertexColor(self, 1, 0.1, 0.1)
	end
	
	_G[self:GetName() .. 'IconTexture']:SetDesaturated(not viewable)
	self:UpdateCount(remainingWithdrawals)
	self:UpdateChecked()
end

function Tab:UpdateChecked()
	self:SetChecked(self:IsSelected())
end

function Tab:UpdateCount(count)
	-- the amount of withdrawls seems to only be correct for the current tab
	if not self:IsSelected() then 
		return 
	end
	
	self:SetCount(count or select(6, self:GetInfo()))
end

function Tab:GetSlot()
	return 'guild' .. tostring(self:GetID())
end

function Tab:IsSelected()
	return self:GetID() == GetCurrentGuildBankTab()
end


--[[ Tooltip Methods ]]--

function Tab:UpdateTooltip()
	local name, icon, _, canDeposit, numWithdrawals = self:GetInfo()
	if name then
		GameTooltip:SetText(name)

		local access
		if not canDeposit and numWithdrawals == 0 then
			access = RED_FONT_COLOR_CODE .. "(" .. GUILDBANK_TAB_LOCKED .. ")" .. FONT_COLOR_CODE_CLOSE;
		elseif not canDeposit then
			access = RED_FONT_COLOR_CODE .."(" .. GUILDBANK_TAB_WITHDRAW_ONLY .. ")" .. FONT_COLOR_CODE_CLOSE;
		elseif numWithdrawals == 0 then
			access = RED_FONT_COLOR_CODE .."(" .. GUILDBANK_TAB_DEPOSIT_ONLY .. ")" .. FONT_COLOR_CODE_CLOSE;
		else
			access = GREEN_FONT_COLOR_CODE .. "(" .. GUILDBANK_TAB_FULL_ACCESS .. ")" .. FONT_COLOR_CODE_CLOSE;
		end

		GameTooltip:AddLine(access)
	else
		GameTooltip:SetText('Unavailable')
	end

	GameTooltip:Show()
end