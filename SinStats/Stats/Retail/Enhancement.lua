local AddName, Ns = ...

------------------------------
--		Options Equates		--
------------------------------
local Damage, Percent, Live = 1, 1, 1
local DamageTaken, Rating, Static = 2, 2, 2
local Both = 3

------------------------------
--		Enhancements		--
------------------------------
-- Critical
function Ns.FunctionList.CritChance(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local totalCrit, rating = 0, 0
	local returnText, decimals
	local critChance = GetCritChance()
	local critSpellChance = GetSpellCritChance()
	local critRangedChance = GetRangedCritChance()
	local meleeRating, rangedRating, spellRating = GetCombatRating(CR_CRIT_MELEE), GetCombatRating(CR_CRIT_RANGED), GetCombatRating(CR_CRIT_SPELL)
	totalCrit = max(critChance, critSpellChance, critRangedChance)
	local baseCrit = totalCrit
	rating = max(meleeRating, rangedRating, spellRating)
	local capColor, endColor, rateColor = "", "", ""

	totalCrit = totalCrit + Ns.combustion + Ns.betweenEyes + Ns.overflowEnergy

	if options.Display_Basic then totalCrit = baseCrit end

	if options.Decimals_Crit == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Crit == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Crit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if totalCrit >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	rating = BreakUpLargeNumbers(rating)

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(totalCrit) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(totalCrit) .. endColor .. "/" .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Haste
function Ns.FunctionList.Haste(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local haste = GetHaste()
	local rating = GetCombatRating(CR_HASTE_MELEE)
	local returnText, decimals
	local capColor, endColor, rateColor = "", "", ""

	if options.Decimals_Haste == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Haste == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Haste == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if haste >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(haste) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(haste) .. endColor .. "/" .. rateColor .. rating .. endColor end

	-- if options.Stat_Color then
	-- 	Ns.StatColors = CreateColor(options.Stat_Color.r, options.Stat_Color.g, options.Stat_Color.b)
	-- 	Ns.StatColors = Ns.StatColors:GenerateHexColorMarkup()
	-- end

	HUD:UpdateText(data, returnText)
end

-- Mastery
function Ns.FunctionList.Mastery(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local mastery = GetMasteryEffect()
	local rating = GetCombatRating(CR_MASTERY)
	local returnText, decimals
	local capColor, endColor, rateColor = "", "", ""

	if options.Display_Basic then mastery = mastery end

	if options.Decimals_Mastery == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Mastery == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Mastery == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if mastery >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(mastery) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(mastery) .. endColor .. "/" .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Versatility
function Ns.FunctionList.Versatility(HUD, data, options, ...)

	local EB = options.Damage_Taken
	local dmg = GetVersatilityBonus(29) + GetCombatRatingBonus(29)
	local mitigate = GetVersatilityBonus(31) + GetCombatRatingBonus(31)
	local rating = ""
	local returnText, decimals
	local capColor, endColor = "", ""

	if options.Display_Rating then 
		rating = GetCombatRating(29)
		rating = BreakUpLargeNumbers(rating)
		rating = " (" .. rating .. ")"
	end

	if options.Decimals_Versatility == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Versatility == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Versatility == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if dmg >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if options.Cap_Percent == 0 then capColor = "" end

	if Ns.Band(EB, Damage) then returnText = capColor .. (decimals):format(dmg) .. endColor .. rating end
	if Ns.Band(EB, DamageTaken) then returnText = capColor .. (decimals):format(mitigate) .. endColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(dmg) .. endColor .. "/" .. (decimals):format(mitigate) .. rating end

	HUD:UpdateText(data, returnText)
end

-- Avoidance
function Ns.FunctionList.Avoidance(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local avoidance = GetAvoidance()
	local rating = GetCombatRating(CR_AVOIDANCE)
	local returnText, decimals
	local capColor, endColor, rateColor = "", "", ""

	avoidance = avoidance + Ns.martial

	if options.Display_Basic then avoidance = avoidance end

	if options.Decimals_Avoidance == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Avoidance == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Avoidance == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if avoidance >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(avoidance) end
	if Ns.Band(EB, Rating) then returnText = capColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(avoidance) .. endColor .. "/" .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Leech
function Ns.FunctionList.Leech(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local leech = GetLifesteal()
	local rating = GetCombatRating(CR_LIFESTEAL)
	local returnText, decimals
	local capColor, endColor, rateColor = "", "", ""

	if options.Decimals_Leech == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Leech == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Leech == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if leech >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(leech) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(leech) .. endColor .. "/" .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Speed
function Ns.FunctionList.Speed(HUD, data, options, ...)

	local EB = options.Speed_Static
	local speedColor, staticColor, endColor = "", "", ""
	local vehicleSpeed = GetUnitSpeed("vehicle")
	local fullSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	local staticSpeed
	local returnText, decimals

	if IsFlying() then staticSpeed = flightSpeed
	elseif IsSwimming() then staticSpeed = swimSpeed
	elseif vehicleSpeed > 0 then staticSpeed = vehicleSpeed
	elseif UnitOnTaxi("player") then staticSpeed = fullSpeed
	else staticSpeed = runSpeed end

	if fullSpeed == 0 and vehicleSpeed > 0 then fullSpeed = vehicleSpeed end

	fullSpeed = fullSpeed / 0.07
	staticSpeed = staticSpeed / 0.07

	if canGlide then
		local base = isGliding and forwardSpeed or GetUnitSpeed("player")
		local movespeed = Round(base / BASE_MOVEMENT_SPEED * 100)
		fullSpeed = movespeed
		staticSpeed = movespeed
	end

	if fullSpeed == 0 or fullSpeed == 100 then speedColor = ""
	elseif fullSpeed <= 99 then speedColor = Ns.redText
	elseif fullSpeed > 100 then speedColor = Ns.greenText end

	if staticSpeed == 0 or staticSpeed == 100 then staticColor = ""
	elseif staticSpeed <= 99 then staticColor = Ns.redText
	elseif staticSpeed > 100 then staticColor = Ns.greenText end

	if speedColor ~= "" then endColor = "|r" end

	if options.Decimals_Speed == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Speed == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Speed == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Live) then returnText = speedColor .. (decimals):format(fullSpeed) end
	if Ns.Band(EB, Static) then returnText = staticColor .. (decimals):format(staticSpeed) end
	if Ns.Band(EB, Both) then returnText = speedColor .. (decimals):format(fullSpeed) .. endColor .. " (" .. staticColor .. (decimals):format(staticSpeed) .. ")" end

	HUD:UpdateText(data, returnText)
end