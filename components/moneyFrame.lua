--[[
	moneyFrame.lua
		A money frame object
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local MoneyFrame = Bagnon:NewClass('GuildMoneyFrame', 'Frame', Bagnon.MoneyFrame)
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')


--[[ Frame Events ]]--

function MoneyFrame:OnClick(button)
	local cMoney = GetCursorMoney() or 0
	if cMoney > 0 then
		self:DepositMoney(cMoney)
		return
	end

	if button == 'LeftButton' and (not IsShiftKeyDown()) then
		self:ShowDepositDialog()
		return
	end

	if button == 'RightButton' or (button == 'LeftButton' and IsShiftKeyDown())  then
		self:ShowWithdrawDialog()
		return
	end
end

function MoneyFrame:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
	self:UpdateTooltip()
end

function MoneyFrame:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Actions ]]--

function MoneyFrame:UpdateEvents()
	self:UnregisterAllEvents()
	
	if self:IsVisible() then
		self:RegisterEvent('GUILDBANK_UPDATE_MONEY')
	end
end

function MoneyFrame:UpdateTooltip()
	GameTooltip:SetText(L.TipFunds)
	GameTooltip:AddLine(L.TipDeposit, 1, 1, 1)

	if CanWithdrawGuildBankMoney() then
		local withdrawMoney = GetGuildBankWithdrawMoney()
		if withdrawMoney > 0 then
			GameTooltip:AddLine(format(L.TipWithdrawRemaining, self:GetCoinsText(withdrawMoney)), 1, 1, 1)
		else
			GameTooltip:AddLine(L.TipWithdraw)
		end
	end

	GameTooltip:Show()
end

function MoneyFrame:DepositMoney(amount)
	DepositGuildBankMoney(cMoney)
	DropCursorMoney()
end

function MoneyFrame:ShowDepositDialog()
	PlaySound('igMainMenuOption')

	StaticPopup_Hide('GUILDBANK_WITHDRAW')
	if StaticPopup_Visible('GUILDBANK_DEPOSIT') then
		StaticPopup_Hide('GUILDBANK_DEPOSIT')
	else
		StaticPopup_Show('GUILDBANK_DEPOSIT')
	end
end

function MoneyFrame:ShowWithdrawDialog()
	if not CanWithdrawGuildBankMoney() then
		return
	end

	PlaySound('igMainMenuOption')
	StaticPopup_Hide('GUILDBANK_DEPOSIT')
	
	if StaticPopup_Visible('GUILDBANK_WITHDRAW') then
		StaticPopup_Hide('GUILDBANK_WITHDRAW')
	else
		StaticPopup_Show('GUILDBANK_WITHDRAW')
	end
end


--[[ Properties ]]--

function MoneyFrame:GetMoney()
	return GetGuildBankMoney()
end