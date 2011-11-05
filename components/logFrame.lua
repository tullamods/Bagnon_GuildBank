--[[
	itemFrame.lua
		An guild bank item slot container (by João Libório Cardoso)
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local LogFrame = Bagnon:NewClass('LogFrame', 'ScrollFrame')

local MESSAGE_PREFIX = '|cff009999   '
local MAX_TRANSACTIONS = 24
local TRANSACTION_HEIGHT = 13


--[[ Constructor ]]--

function LogFrame:New(frameID, parent)
	local f = self:Bind(CreateFrame('ScrollFrame', parent:GetName() .. 'LogFrame', parent, 'FauxScrollFrameTemplate'))
	f:SetScript('OnVerticalScroll', f.OnScroll)
	f:SetScript('OnEvent', f.OnEvent)
	f:SetScript('OnShow', f.OnShow)
	f:SetScript('OnHide', f.OnHide)
	
	f:RegisterEvent('GUILDBANKLOG_UPDATE')
	f:RegisterMessage('SHOW_LOG_TRANSACTIONS')
	f:RegisterMessage('SHOW_LOG_MONEY')
	f:RegisterMessage('GUILD_BANK_CLOSED')
	
	local messages = CreateFrame('ScrollingMessageFrame', nil, f)
	messages:SetFontObject(GameFontHighlight)
	messages:SetScript('OnHyperlinkClick', f.OnHyperlink)
	messages:SetJustifyH('LEFT')
	messages:SetAllPoints(true)
	messages:SetMaxLines(128)
	messages:SetFading(false)
	f.messages = messages
	
	local bg = f.ScrollBar:CreateTexture()
	bg:SetTexture(0, 0, 0, .5)
	bg:SetAllPoints()
	
	return f
end


--[[ Events ]]--

function LogFrame:OnEvent()
	self:Update()
end

function LogFrame:OnScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, TRANSACTION_HEIGHT, self.UpdateScroll)
end

function LogFrame:OnHyperlink(...)
	SetItemRef(...)
end

function LogFrame:OnShow()
	self:RegisterMessage('GUILD_BANK_TAB_CHANGE')
end

function LogFrame:OnHide()
	self:UnregisterMessage('GUILD_BANK_TAB_CHANGE')
end


--[[ Messages ]]--

function LogFrame:SHOW_LOG_TRANSACTIONS()
	QueryGuildBankLog(GetCurrentGuildBankTab())
	self.money = nil
	self:Update()
end

function LogFrame:SHOW_LOG_MONEY()
	QueryGuildBankLog(MAX_GUILDBANK_TABS + 1)
	self.money = true
	self:Update()
end

function LogFrame:GUILD_BANK_TAB_CHANGE()
	self:Update()
end

function LogFrame:GUILD_BANK_CLOSED()
	self:Hide()
end


--[[ Update ]]--

function LogFrame:Update()
	self:UpdateScroll()
	self.messages:Clear()
  self:Show()
	
	if self.money then
		self:UpdateMoney()
	else
		self:UpdateTransactions()
	end
end

function LogFrame:UpdateTransactions()
	local type, name, itemLink, count, tab1, tab2, year, month, day, hour
	local msg
	
	for i=1, self.numTransactions do
		type, name, itemLink, count, tab1, tab2, year, month, day, hour = self:ProcessMessage(GetGuildBankTransaction(self.tab, i))

		if type == "deposit" then
			msg = format(GUILDBANK_DEPOSIT_FORMAT, name, itemLink)
			if ( count > 1 ) then
				msg = msg..format(GUILDBANK_LOG_QUANTITY, count)
			end
		elseif type == "withdraw" then
			msg = format(GUILDBANK_WITHDRAW_FORMAT, name, itemLink)
			if ( count > 1 ) then
				msg = msg..format(GUILDBANK_LOG_QUANTITY, count)
			end
		elseif type == "move" then
			msg = format(GUILDBANK_MOVE_FORMAT, name, itemLink, count, GetGuildBankTabInfo(tab1), GetGuildBankTabInfo(tab2))
		end
		
		self:AddMessage(msg, year, month, day, hour)
	end
end

function LogFrame:UpdateMoney()
	local type, name, amount, year, month, day, hour
	local msg, money
	
	for i = 1, self.numTransactions do
		type, name, amount, year, month, day, hour = self:ProcessMessage(GetGuildBankMoneyTransaction(i))
		money = GetDenominationsFromCopper(amount)
		
		if ( type == "deposit" ) then
			msg = format(GUILDBANK_DEPOSIT_MONEY_FORMAT, name, money)
		elseif ( type == "withdraw" ) then
			msg = format(GUILDBANK_WITHDRAW_MONEY_FORMAT, name, money)
		elseif ( type == "repair" ) then
			msg = format(GUILDBANK_REPAIR_MONEY_FORMAT, name, money)
		elseif ( type == "withdrawForTab" ) then
			msg = format(GUILDBANK_WITHDRAWFORTAB_MONEY_FORMAT, name, money)
		elseif ( type == "buyTab" ) then
			msg = format(GUILDBANK_BUYTAB_MONEY_FORMAT, name, money)
		end
		
		self:AddMessage(msg, year, month, day, hour)
	end
end

function LogFrame:UpdateScroll()
	self.tab = GetCurrentGuildBankTab()
	self.numTransactions = self.money and GetNumGuildBankMoneyTransactions() or GetNumGuildBankTransactions(self.tab)
	
	if self.numTransactions > 23 then
		self.messages:SetScrollOffset(FauxScrollFrame_GetOffset(self))
		self.ScrollBar:Show()
	else
		self.messages:SetScrollOffset(0)
		self.ScrollBar:Hide()
	end
	
	FauxScrollFrame_Update(self, self.numTransactions, MAX_TRANSACTIONS, TRANSACTION_HEIGHT)
end


--[[ Messages ]]--

function LogFrame:ProcessMessage(type, name, ...)
	return type, NORMAL_FONT_COLOR_CODE .. (name or UNKNOWN) .. FONT_COLOR_CODE_CLOSE, ...
end

function LogFrame:AddMessage(msg, ...)
	if msg then
		self.messages:AddMessage(msg .. MESSAGE_PREFIX .. format(GUILD_BANK_LOG_TIME, RecentTimeDate(...)))
	end
end