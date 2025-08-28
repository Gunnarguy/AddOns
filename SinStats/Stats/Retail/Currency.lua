local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Current, Level, Spark, Empty = 1, 1, 1, 1
local Earned, Honor, Splinter, Vintage = 2, 2, 2, 2
local Both = 3

--------------------------
--		Currency		--
--------------------------

-- Money
function Ns.FunctionList.Gold(HUD, data, options, ...)

	local money = GetMoney()
	local gold = floor(money / 1e4)
	local formattedMoney = (C_CurrencyInfo.GetCoinTextureString(money))

	if options.Display_Gold then
		if options.Decimals_Default == 0 then formattedMoney = BreakUpLargeNumbers(gold)
		elseif options.Decimals_Default == 1 then formattedMoney = Ns.ShortNumbers(gold, 0)
		elseif options.Decimals_Default == 2 then formattedMoney = Ns.ShortNumbers(gold, 1)
		else formattedMoney = Ns.ShortNumbers(gold, 2)
		end
	end

	HUD:UpdateText(data, formattedMoney)
end
------------------------------------------------

-- WoW Token
-- local oldToken = C_WowTokenPublic.GetCurrentMarketPrice() or 0
-- oldToken = floor(oldToken / 10000)
function Ns.FunctionList.WowToken(HUD, data, options, ...)

	C_WowTokenPublic.UpdateMarketPrice()
	local token = C_WowTokenPublic.GetCurrentMarketPrice() or 0
	local display, color = 0, ""

	token = floor(token / 10000)

	-- if oldToken < token then
	-- 	color = Ns.greenText
	-- elseif oldToken > token then
	-- 	color = Ns.redText
	-- else
	-- 	color = ""
	-- end

	-- print(oldToken, token)

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(token)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(token, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(token, 1)
	else display = Ns.ShortNumbers(token, 2)
	end

	HUD:UpdateText(data, color .. display)
end
------------------------------------------------

-- Honor
function Ns.FunctionList.Honor(HUD, data, options, ...)

	local EB = options.Level_HonorPoints
	local honorLevel = UnitHonorLevel("player")
	local honorPoints = C_CurrencyInfo.GetCurrencyInfo(1792)--UnitHonor("player")
	local ratedHonor = C_CurrencyInfo.GetCurrencyInfo(1891)
	local ratedTotal, hpDisplay = 0, 0
	local returnText

	if honorPoints.name and tonumber(honorPoints.quantity) then hpDisplay = honorPoints.quantity else hpDisplay = 0 end
	if ratedHonor.name and tonumber(ratedHonor.quantity) then ratedTotal = ratedHonor.quantity end

	if options.Display_Rated then hpDisplay = ratedTotal end

	if Ns.Band(EB, Level) then returnText = honorLevel end
	if Ns.Band(EB, Honor) then returnText = hpDisplay end
	if Ns.Band(EB, Both) then returnText = honorLevel .. "/" .. hpDisplay end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Valorstones
function Ns.FunctionList.Valorstones(HUD, data, options, ...)

	local valorstones = C_CurrencyInfo.GetCurrencyInfo(3008)
	local display = 0

	if valorstones.name and tonumber(valorstones.quantity) then display = valorstones.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
------------------------------------------------

-- Weathered Ethereal Crest
function Ns.FunctionList.Weathered(HUD, data, options, ...)

	local EB = options.Current_Earned
	local currency = C_CurrencyInfo.GetCurrencyInfo(3284)
	local max = currency.maxQuantity or 0
	local earn = currency.totalEarned or 0
	local display = 0
	local capColor = ""
	local cap = ""
	local returnText

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Display_Weekly then cap = "/" .. max end
	if options.Display_Max and earn == max then capColor = Ns.redText end

	if Ns.Band(EB, Current) then returnText = capColor .. display .. cap end
	if Ns.Band(EB, Earned) then returnText = capColor .. earn .. cap end
	if Ns.Band(EB, Both) then returnText = capColor .. display .. "/" .. earn .. cap end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
----------------------------------------------

-- Carved Ethereal Crest
function Ns.FunctionList.Carved(HUD, data, options, ...)

	local EB = options.Current_Earned
	local currency = C_CurrencyInfo.GetCurrencyInfo(3286)
	local max = currency.maxQuantity or 0
	local earn = currency.totalEarned or 0
	local display = 0
	local capColor = ""
	local cap = ""
	local returnText

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Display_Weekly then cap = "/" .. max end
	if options.Display_Max and earn == max then capColor = Ns.redText end

	if Ns.Band(EB, Current) then returnText = capColor .. display .. cap end
	if Ns.Band(EB, Earned) then returnText = capColor .. earn .. cap end
	if Ns.Band(EB, Both) then returnText = capColor .. display .. "/" .. earn .. cap end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
----------------------------------------------

-- Runed Ethereal Crest
function Ns.FunctionList.Runed(HUD, data, options, ...)

	local EB = options.Current_Earned
	local currency = C_CurrencyInfo.GetCurrencyInfo(3288)
	local max = currency.maxQuantity or 0
	local earn = currency.totalEarned or 0
	local display = 0
	local capColor = ""
	local cap = ""
	local returnText

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Display_Weekly then cap = "/" .. max end
	if options.Display_Max and earn == max then capColor = Ns.redText end

	if Ns.Band(EB, Current) then returnText = capColor .. display .. cap end
	if Ns.Band(EB, Earned) then returnText = capColor .. earn .. cap end
	if Ns.Band(EB, Both) then returnText = capColor .. display .. "/" .. earn .. cap end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
----------------------------------------------

-- Gilded Ethereal Crest
function Ns.FunctionList.Gilded(HUD, data, options, ...)

	local EB = options.Current_Earned
	local currency = C_CurrencyInfo.GetCurrencyInfo(3290)
	local max = currency.maxQuantity or 0
	local earn = currency.totalEarned or 0
	local display = 0
	local capColor = ""
	local cap = ""
	local returnText

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Display_Weekly then cap = "/" .. max end
	if options.Display_Max and earn == max then capColor = Ns.redText end

	if Ns.Band(EB, Current) then returnText = capColor .. display .. cap end
	if Ns.Band(EB, Earned) then returnText = capColor .. earn .. cap end
	if Ns.Band(EB, Both) then returnText = capColor .. display .. "/" .. earn .. cap end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
----------------------------------------------

-- Puzzling Cartel Chip
-- function Ns.FunctionList.Puzzling(HUD, data, options, ...)

-- 	local item = C_Item.GetItemCount(237502, true)

-- 	HUD:UpdateText(data, item)
-- end
----------------------------------------------

-- Untethered Coin
function Ns.FunctionList.Ethereal(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3278)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Untethered Coin
function Ns.FunctionList.Untethered(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3303)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Displaced Corrupted Mementos
function Ns.FunctionList.Mementos(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3149)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Ethereal Voidsplinter (Catalyst)
function Ns.FunctionList.Catalyst(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3269)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Market Research
function Ns.FunctionList.Market(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3226)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Sizzling Cinderpollen
function Ns.FunctionList.Cinder(HUD, data, options, ...)

	local item = C_Item.GetItemCount(225557, true)

	HUD:UpdateText(data, item)
end
----------------------------------------------

-- Undercoin
function Ns.FunctionList.Undercoin(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(2803)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Restored Coffer Key
function Ns.FunctionList.CofferKey(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3028)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Gilded Stash
function Ns.FunctionList.Stash(HUD, data, options, ...)

	local stash = C_UIWidgetManager.GetSpellDisplayVisualizationInfo(6659)
	local currency = "N/A"
    if stash ~= nil then
    	currency = strmatch(stash.spellInfo.tooltip, '(%d/3)')
	end

	HUD:UpdateText(data, currency)
end
----------------------------------------------

-- Flame-Blessed Iron
function Ns.FunctionList.Iron(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3090)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Kaja'Cola Can
function Ns.FunctionList.KajaCola(HUD, data, options, ...)

	local EB = options.Empty_Vintage
	local empty = C_CurrencyInfo.GetCurrencyInfo(3218)
	local vintage = C_CurrencyInfo.GetCurrencyInfo(3220)
	local emptyCur, vintageCur = 0, 0
	local returnText

	if empty.name and tonumber(empty.quantity) then emptyCur = empty.quantity
	else emptyCur = 0 end
	if vintage.name and tonumber(vintage.quantity) then vintageCur = vintage.quantity
	else vintageCur = 0 end

	if options.Decimals_Default == 0 then
		emptyCur = BreakUpLargeNumbers(emptyCur)
		vintageCur = BreakUpLargeNumbers(vintageCur)
	elseif options.Decimals_Default == 1 then 
		emptyCur = Ns.ShortNumbers(emptyCur, 0)
		vintageCur = Ns.ShortNumbers(vintageCur, 0)
	elseif options.Decimals_Default == 2 then
		emptyCur = Ns.ShortNumbers(emptyCur, 1)
		vintageCur = Ns.ShortNumbers(vintageCur, 1)
	else
		emptyCur = Ns.ShortNumbers(emptyCur, 2)
		vintageCur = Ns.ShortNumbers(vintageCur, 2)
	end

	if Ns.Band(EB, Empty) then returnText = emptyCur end
	if Ns.Band(EB, Vintage) then returnText = vintageCur end
	if Ns.Band(EB, Both) then returnText = emptyCur .. "/" .. vintageCur end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
----------------------------------------------

-- Plunder
-- function Ns.FunctionList.Plunder(HUD, data, options, ...)

-- 	local currency = C_CurrencyInfo.GetCurrencyInfo(3139)
-- 	local display = 0

-- 	if currency.name and tonumber(currency.quantity) then display = currency.quantity
-- 	else display = 0 end

-- 	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
-- 	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
-- 	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
-- 	else display = Ns.ShortNumbers(display, 2)
-- 	end

-- 	HUD:UpdateText(data, display)
-- end
----------------------------------------------

-- Resonance Crystals
function Ns.FunctionList.Crystals(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(2815)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
----------------------------------------------

-- Kej
function Ns.FunctionList.Kej(HUD, data, options, ...)

	local currency = C_CurrencyInfo.GetCurrencyInfo(3056)
	local display = 0

	if currency.name and tonumber(currency.quantity) then display = currency.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
----------------------------------------------


-- Bloody Tokens
function Ns.FunctionList.BloodyTokens(HUD, data, options, ...)

	local bloodyTokens = C_CurrencyInfo.GetCurrencyInfo(2123)
	local bloodyDisplay = 0

	if bloodyTokens.name and tonumber(bloodyTokens.quantity) then bloodyDisplay = bloodyTokens.quantity
	else bloodyDisplay = 0 end

	HUD:UpdateText(data, bloodyDisplay)
end
------------------------------------------------

-- Valor points
function Ns.FunctionList.ValorPoints(HUD, data, options, ...)

	local valor = C_CurrencyInfo.GetCurrencyInfo(1191)
	local valorDisplay = 0

	if valor.name and tonumber(valor.quantity) then valorDisplay = valor.quantity
	else valorDisplay = 0 end

	HUD:UpdateText(data, valorDisplay)
end
------------------------------------------------

-- Conquest
function Ns.FunctionList.Conquest(HUD, data, options, ...)

	local conquest = C_CurrencyInfo.GetCurrencyInfo(1602)
	local conquestDisplay = 0

	if conquest.name and tonumber(conquest.quantity) then conquestDisplay = conquest.quantity
	else conquestDisplay = 0 end

	HUD:UpdateText(data, conquestDisplay)
end
------------------------------------------------

-- Timewarped Badges
function Ns.FunctionList.Timewarped(HUD, data, options, ...)

	local timewarped = C_CurrencyInfo.GetCurrencyInfo(1166)
	local display = 0

	if timewarped.name and tonumber(timewarped.quantity) then display = timewarped.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
------------------------------------------------

-- Trader's Tender
function Ns.FunctionList.TraderTender(HUD, data, options, ...)

	local trader = C_CurrencyInfo.GetCurrencyInfo(2032)
	local display = 0

	if trader.name and tonumber(trader.quantity) then display = trader.quantity
	else display = 0 end

	if options.Decimals_Default == 0 then display = BreakUpLargeNumbers(display)
	elseif options.Decimals_Default == 1 then display = Ns.ShortNumbers(display, 0)
	elseif options.Decimals_Default == 2 then display = Ns.ShortNumbers(display, 1)
	else display = Ns.ShortNumbers(display, 2)
	end

	HUD:UpdateText(data, display)
end
------------------------------------------------

-- Spark of Starlight
function Ns.FunctionList.Spark(HUD, data, options, ...)

	local EB = options.Splint_Spark
	local returnText
	local spark = C_Item.GetItemCount(231756, true)
	local dust = C_CurrencyInfo.GetCurrencyInfo(3141)
	local splinter = 0

	if dust.name and tonumber(dust.quantity) then splinter = dust.quantity
	else splinter = 0 end

	if Ns.Band(EB, Spark) then returnText = spark end
	if Ns.Band(EB, Splinter) then returnText = splinter end
	if Ns.Band(EB, Both) then returnText = spark .. " (" .. splinter .. ")" end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------