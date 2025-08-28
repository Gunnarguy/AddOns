local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Percentage, Rating, Points = 3, 1, 2, 1

------------------------------
--		Global Updater		--
------------------------------

-- Agility
function Ns.FunctionList.Agility(HUD, data, options, ...)

	local _, stat, _, negBuff = UnitStat("Player", 2)
	local debuffColor = ""
	local decimals

	if options.Dec_Melee_Agi == 0 then decimals = "%.0f"
	elseif options.Dec_Melee_Agi == 1 then decimals = "%.1f"
	elseif options.Dec_Melee_Agi == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	HUD:UpdateText(data, debuffColor .. (decimals):format(stat))
end

-- Strength
function Ns.FunctionList.Strength(HUD, data, options, ...)

	local _, stat, _, negBuff = UnitStat("Player", 1)
	local debuffColor = ""
	local decimals

	if options.Dec_Melee_Str == 0 then decimals = "%.0f"
	elseif options.Dec_Melee_Str == 1 then decimals = "%.1f"
	elseif options.Dec_Melee_Str == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	HUD:UpdateText(data, debuffColor .. (decimals):format(stat))
end

-- Intellect
function Ns.FunctionList.Intellect(HUD, data, options, ...)

	local _, stat, _, negBuff = UnitStat("Player", 4)
	local debuffColor = ""
	local decimals

	if options.Dec_Spell_Int == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Int == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Int == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	HUD:UpdateText(data, debuffColor .. (decimals):format(stat))
end

-- Spirit
function Ns.FunctionList.Spirit(HUD, data, options, ...)

	local _, stat, _, negBuff = UnitStat("Player", 5)
	local debuffColor = ""
	local decimals

	if options.Dec_Spell_Spir == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Spir == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Spir == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	HUD:UpdateText(data, debuffColor .. (decimals):format(stat))
end

-- Stamina
function Ns.FunctionList.Stamina(HUD, data, options, ...)

	local _, stat, _, negBuff = UnitStat("Player", 3)
	local debuffColor = ""
	local decimals

	if options.Dec_Def_Stamina == 0 then decimals = "%.0f"
	elseif options.Dec_Def_Stamina == 1 then decimals = "%.1f"
	elseif options.Dec_Def_Stamina == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	HUD:UpdateText(data, debuffColor .. (decimals):format(stat))
end

-- Mastery
function Ns.FunctionList.Mastery(HUD, data, options, ...)

	local EB = options.Point_Rating
	local mastery = GetMastery()--GetCombatRatingBonus(CR_MASTERY)
	local masteryRating = GetCombatRating(CR_MASTERY)
	local returnText, decimals
	local capColor, endColor = "", ""

	if options.Decimals_Mastery == 0 then decimals = "%.0f"
	elseif options.Decimals_Mastery == 1 then decimals = "%.1f"
	elseif options.Decimals_Mastery == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if mastery >= options.Cap_Mastery then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Points) then returnText = capColor .. (decimals):format(mastery) end
	if Ns.Band(EB, Rating) then returnText = masteryRating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(mastery) .. endColor .. " (" .. masteryRating .. ")" end

	HUD:UpdateText(data, returnText)
end
