--[[
	logToggle.lua
		A guild money log toggle widget (by João Libório Cardoso)
--]]


local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local MoneyLogToggle = Bagnon.Classy:New('CheckButton')
Bagnon.MoneyLogToggle = MoneyLogToggle

local SIZE = 20
local NORMAL_TEXTURE_SIZE = 64 * (SIZE/36)


--[[ Constructor ]]--

function MoneyLogToggle:New(frameID, parent)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent))
	b:SetWidth(SIZE)
	b:SetHeight(SIZE)
	b:RegisterForClicks('anyUp')

	local nt = b:CreateTexture()
	nt:SetTexture([[Interface\Buttons\UI-Quickslot2]])
	nt:SetWidth(NORMAL_TEXTURE_SIZE)
	nt:SetHeight(NORMAL_TEXTURE_SIZE)
	nt:SetPoint('CENTER', 0, -1)
	b:SetNormalTexture(nt)

	local pt = b:CreateTexture()
	pt:SetTexture([[Interface\Buttons\UI-Quickslot-Depress]])
	pt:SetAllPoints(b)
	b:SetPushedTexture(pt)

	local ht = b:CreateTexture()
	ht:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	ht:SetAllPoints(b)
	b:SetHighlightTexture(ht)

	local ct = b:CreateTexture()
	ct:SetTexture([[Interface\Buttons\CheckButtonHilight]])
	ct:SetAllPoints(b)
	ct:SetBlendMode('ADD')
	b:SetCheckedTexture(ct)

	local icon = b:CreateTexture()
	icon:SetAllPoints(b)
	icon:SetTexture([[Interface\Icons\INV_Misc_Coin_01]])

	b:RegisterMessage('SHOW_LOG_TRANSACTIONS')
	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	return b
end


--[[ Messages ]]--

function MoneyLogToggle:SHOW_LOG_TRANSACTIONS()
	self:SetChecked(false)
end


--[[ Frame Events ]]--

function MoneyLogToggle:OnClick()
	if self:GetChecked() then
		self:SendMessage('SHOW_LOG_FRAME')
		self:SendMessage('SHOW_LOG_MONEY')
	else
		self:SendMessage('SHOW_ITEM_FRAME')
	end
end

function MoneyLogToggle:OnEnter()
	if self:GetRight() > (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end
	
	GameTooltip:SetText('Click to show the money log')
end

function MoneyLogToggle:OnLeave()
	GameTooltip:Hide()
end