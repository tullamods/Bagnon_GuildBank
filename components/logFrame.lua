--[[
	itemFrame.lua
		A guild bank tab log messages scrollframe
--]]

local MODULE, Module =  ...
local LogFrame = Module.Addon:NewClass('LogFrame', 'ScrollFrame')

local MESSAGE_PREFIX, _ = '|cff009999   '
local TRANSACTION_HEIGHT = 13
local MAX_TRANSACTIONS = 24


--[[ Constructor ]]--

function LogFrame:New(parent)
	local f = self:Bind(CreateFrame('ScrollFrame', parent:GetName() .. 'LogFrame', parent, 'FauxScrollFrameTemplate'))
	local messages = CreateFrame('ScrollingMessageFrame', nil, f)
	messages:SetScript('OnHyperlinkClick', f.OnHyperlink)
	messages:SetFontObject(GameFontHighlight)
	messages:SetJustifyH('LEFT')
	messages:SetMaxLines(128)
	messages:SetFading(false)
	messages:SetAllPoints()

	local bg = f.ScrollBar:CreateTexture()
	bg:SetTexture(0, 0, 0, .5)
	bg:SetAllPoints()

	f:RegisterFrameMessage('SHOW_LOG', 'OnLog')
	f:SetScript('OnVerticalScroll', f.OnScroll)
	f:SetScript('OnHide', f.UnregisterAllEvents)
	f.messages = messages

	return f
end


--[[ Events ]]--

function LogFrame:OnLog(_, logID)
	if logID < 3 then
		self.isMoney = logID == 2
		self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED', 'Update')
		self:RegisterEvent('GUILDBANKLOG_UPDATE', 'Update')
		self:Update()

		if self.isMoney then
			QueryGuildBankLog(MAX_GUILDBANK_TABS + 1)
		else
			QueryGuildBankLog(GetCurrentGuildBankTab())
		end
	end
end

function LogFrame:OnScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, TRANSACTION_HEIGHT, self.UpdateScroll)
end

function LogFrame:OnHyperlink(...)
	SetItemRef(...)
end

function LogFrame:OnMouseDown()
	if CanEditGuildTabInfo(GetCurrentGuildBankTab()) then
		self:SetFocus()
	end
end


--[[ Update ]]--

function LogFrame:Update()
	self:UpdateScroll()
	self.messages:Clear()

	if self.isMoney then
		self:UpdateMoney()
	else
		self:UpdateTransactions()
	end
end

function LogFrame:UpdateTransactions()
	local type, name, itemLink, count, tab1, tab2, year, month, day, hour
	local msg

	for i=1, self.numTransactions do
		type, name, itemLink, count, tab1, tab2, year, month, day, hour = self:ProcessLine(GetGuildBankTransaction(self.tab, i))

		if type == "deposit" then
			msg = format(GUILDBANK_DEPOSIT_FORMAT, name, itemLink)
			if ( count > 1 ) then
				msg = msg..format(GUILDBANK_LOG_QUANTITY, count)
			end
		elseif type == "withdraw" then
			msg = format(GUILDBANK_WITHDRAW_FORMAT, name, itemLink)
			if ( count > 1 ) then
				msg = msg .. format(GUILDBANK_LOG_QUANTITY, count)
			end
		elseif type == "move" then
			msg = format(GUILDBANK_MOVE_FORMAT, name, itemLink, count, GetGuildBankTabInfo(tab1), GetGuildBankTabInfo(tab2))
		end

		self:AddLine(msg, year, month, day, hour)
	end
end

function LogFrame:UpdateMoney()
	local type, name, amount, year, month, day, hour
	local msg, money

	for i = 1, self.numTransactions do
		type, name, amount, year, month, day, hour = self:ProcessLine(GetGuildBankMoneyTransaction(i))
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
			msg = amount > 0 and GUILDBANK_BUYTAB_MONEY_FORMAT:format(name, money) or GUILDBANK_UNLOCKTAB_FORMAT:format(name)
		elseif ( type == "depositSummary" ) then
			msg = format(GUILDBANK_AWARD_MONEY_SUMMARY_FORMAT, money)
		end

		self:AddLine(msg, year, month, day, hour)
	end
end

function LogFrame:UpdateScroll()
	self.tab = GetCurrentGuildBankTab()
	self.numTransactions = self.isMoney and GetNumGuildBankMoneyTransactions() or GetNumGuildBankTransactions(self.tab)

	if self.numTransactions > 23 then
		self.messages:SetScrollOffset(FauxScrollFrame_GetOffset(self))
		self.ScrollBar:Show()
	else
		self.messages:SetScrollOffset(0)
		self.ScrollBar:Hide()
	end

	FauxScrollFrame_Update(self, self.numTransactions, MAX_TRANSACTIONS, TRANSACTION_HEIGHT, _,_,_,_,_,_, true)
end


--[[ API ]]--

function LogFrame:ProcessLine(type, name, ...)
	return type, NORMAL_FONT_COLOR_CODE .. (name or UNKNOWN) .. FONT_COLOR_CODE_CLOSE, ...
end

function LogFrame:AddLine(msg, ...)
	if msg then
		self.messages:AddMessage(msg .. MESSAGE_PREFIX .. format(GUILD_BANK_LOG_TIME, RecentTimeDate(...)))
	end
end
