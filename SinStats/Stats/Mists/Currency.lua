local _, Ns = ...

---------------------
-- Options Equates --
---------------------
local Both, Honor, Arena = 3, 1, 2

-- Money
function Ns.FunctionList.Money(HUD, data, options, ...)

	local money = GetMoney()
	local gold = floor(money / 1e4)
	local formattedMoney = (C_CurrencyInfo.GetCoinTextureString(money))

	if options.Display_Gold then
		if options.Decimals_Default == 0 then
			formattedMoney = BreakUpLargeNumbers(gold)
		elseif options.Decimals_Default == 1 then
			formattedMoney = Ns.ShortNumbers(gold, 0)
		elseif options.Decimals_Default == 2 then
			formattedMoney = Ns.ShortNumbers(gold, 1)
		else
			formattedMoney = Ns.ShortNumbers(gold, 2)
		end
	end

	HUD:UpdateText(data, formattedMoney)
end
------------------------------------------------

-- WoW Token
function Ns.FunctionList.WowToken(HUD, data, options, ...)

	C_WowTokenPublic.UpdateMarketPrice()
	local token = C_WowTokenPublic.GetCurrentMarketPrice() or 0
	token = floor(token / 10000)
	token = BreakUpLargeNumbers(token)

	if options.Display_Short then
		token = C_WowTokenPublic.GetCurrentMarketPrice() or 0
		token = floor(token / 10000)
		token = Ns.ShortNumbers(token, 1)
	end

	local formattedToken = token .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"

	HUD:UpdateText(data, formattedToken)
end
------------------------------------------------

-- PvP Points
-- function Ns.FunctionList.PvP(HUD, data, options, ...)

-- 	local EB = options.Honor_Arena
-- 	local honor = C_CurrencyInfo.GetCurrencyInfo(1901)
-- 	local arena = C_CurrencyInfo.GetCurrencyInfo(103)
-- 	local honorDisplay, arenaDisplay, returnText

-- 	if honor.name and tonumber(honor.quantity) then honorDisplay = honor.quantity
-- 	else honorDisplay = 0 end

-- 	if arena.name and tonumber(arena.quantity) then arenaDisplay = arena.quantity
-- 	else arenaDisplay = 0 end

-- 	if Ns.Band(EB, Honor) then returnText = honorDisplay end
-- 	if Ns.Band(EB, Arena) then returnText = arenaDisplay end
-- 	if Ns.Band(EB, Both) then returnText = honorDisplay .. "/" .. arenaDisplay end

-- 	HUD:UpdateText(data, returnText)
-- end
------------------------------------------------