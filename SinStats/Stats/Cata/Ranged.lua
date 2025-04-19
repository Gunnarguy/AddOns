local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Basic, Damage, DamageTaken, Percentage, Rating, MainHand, OffHand, SameLevel, BossLevel, Regen, Casting, Critical, CritDamage, Total, Max, Average = 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2

----------------------------------
--		Text Return Formats		--
----------------------------------
local Percent_Rating_Format = { "%.2f%%", "%.0f", "%.2f%% (%.0f)", }
local Double_Percent_Format = { "%.2f%%", "%.2f%%", "%.2f/%.2f%%", }

------------------------------
--		Global Updater		--
------------------------------

Ns.speed, Ns.lowDmg, Ns.hiDmg, Ns.critRanged, Ns.gunEquipped, Ns.hitRanged, Ns.posBuff, Ns.negBuff, Ns.bowEquipped = 0, 0, 0, 0, 0, 0, 0, 0, 0

function Ns.RangedUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then Ns.targetLevel = Ns.playerLevel + 3 end
	end

	-- Attack Speed
	Ns.speed, Ns.lowDmg, Ns.hiDmg, Ns.posBuff, Ns.negBuff, Ns.percentMod = UnitRangedDamage("player")

	-- Critical
	Ns.critRanged = GetRangedCritChance()
	Ns.gunEquipped = IsEquippedItemType("Guns")
	Ns.bowEquipped = IsEquippedItemType("Bows")
	Ns.critRanged = Ns.critRanged + Ns.noEscape

	-- Dwarf racial [Crit]
	if Ns.gunEquipped and Ns.dwarfRacial then Ns.critRanged = Ns.critRanged + 1 end
	-- Troll racial [Crit]
	if Ns.bowEquipped and Ns.bowSpec then Ns.critRanged = Ns.critRanged + 1 end

	-- Hit
	local hitModifier = GetHitModifier()
	Ns.hitRanged = GetCombatRatingBonus(CR_HIT_RANGED)

	if Ns.hitRanged == nil then Ns.hitRanged = 0 end
	if hitModifier == nil then hitModifier = 0 end

	Ns.hitRanged = Ns.hitRanged + hitModifier

end

-- Haste
function Ns.FunctionList.HasteRanged(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local hasteRanged = GetRangedHaste()
	local hasteRating = GetCombatRating(CR_HASTE_RANGED)
	local returnText, decimals
	local capColor, endColor = "", ""

	if options.Display_Basic then hasteRanged = GetCombatRatingBonus(CR_HASTE_RANGED) or 0 end

	if options.Dec_Ranged_Haste == 0 then decimals = "%.0f%%"
	elseif options.Dec_Ranged_Haste == 1 then decimals = "%.1f%%"
	elseif options.Dec_Ranged_Haste == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if hasteRanged >= options.Cap_Ranged_Haste then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Percentage) then returnText = capColor .. (decimals):format(hasteRanged) end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(hasteRating) end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(hasteRanged) .. endColor .. " (" .. ("%.0f"):format(hasteRating) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Attack Power
function Ns.FunctionList.RAP(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local base, posBuff, negBuff = UnitRangedAttackPower("player");
	local baseRangedAP = base + posBuff + negBuff
	local rangedAttack = 0
	local BuffColor, endColor = "", ""
	local returnText

	rangedAttack = base + posBuff + negBuff + Ns.huntersMark

	if (Ns.huntersMark > 0) then BuffColor = Ns.greenText end
	if negBuff < 0 then	BuffColor = Ns.redText end
	if BuffColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Enhanced) then returnText = BuffColor .. rangedAttack end
	if Ns.Band(EB, Basic) then
        returnText = returnText and (returnText .. endColor .. "/") or ""
		returnText = returnText .. baseRangedAP
	end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Attack Speed
function Ns.FunctionList.rangedSpeed(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText, decimals

	if options.Dec_Ranged_AttSp == 0 then decimals = "%.0f"
	elseif options.Dec_Ranged_AttSp == 1 then decimals = "%.1f"
	elseif options.Dec_Ranged_AttSp == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(Ns.speed) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(Ns.speed) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.speed) .. " (" .. (decimals):format(Ns.speed) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Damage
function Ns.FunctionList.RDMG(HUD, data, options, ...)

	local EB = options.Max_Average_Damage
	local maxDamage = (Ns.hiDmg + (Ns.hiDmg * Ns.bloodFrenzy) + (Ns.hiDmg * Ns.savageCombat) + (Ns.hiDmg * Ns.BeastSlaying) +
					  (Ns.hiDmg * Ns.trickTrade))
	local avgDamage = (Ns.hiDmg + Ns.lowDmg + (Ns.hiDmg * Ns.bloodFrenzy) + (Ns.hiDmg * Ns.savageCombat) + (Ns.hiDmg * Ns.BeastSlaying) +
					  (Ns.hiDmg * Ns.trickTrade)) / 2
	local returnText

	if Ns.Band(EB, Max) then returnText = math.floor(maxDamage+1) end
	if Ns.Band(EB, Average) then
        returnText = returnText and (returnText .. " / ") or ""
		returnText = returnText .. math.floor(avgDamage+1)
	end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- DPS
function Ns.FunctionList.rDPS(HUD, data, options, ...)

	local EB = options.Max_Average_Damage
	local maxDamage = (Ns.hiDmg + (Ns.hiDmg * Ns.bloodFrenzy) + (Ns.hiDmg * Ns.savageCombat) + (Ns.hiDmg * Ns.BeastSlaying) +
					  (Ns.hiDmg * Ns.trickTrade))
	local lowDamage = (Ns.lowDmg + (Ns.lowDmg * Ns.bloodFrenzy) + (Ns.lowDmg * Ns.savageCombat) + (Ns.lowDmg * Ns.BeastSlaying) +
	             	  (Ns.lowDmg * Ns.trickTrade))
	local maxDPS = 0
	local avgDPS = 0
	local BuffColor, endColor = "", ""
	local returnText

	if Ns.speed ~= 0 then
		avgDPS = ((maxDamage + lowDamage) / 2) / Ns.speed
		maxDPS = (maxDamage / Ns.speed)
	end

	if Ns.negBuff < 0 then BuffColor = Ns.redText end
	if BuffColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Max) then returnText = BuffColor .. ("%.0f"):format(maxDPS) end
	if Ns.Band(EB, Average) then returnText = BuffColor .. ("%.0f"):format(avgDPS) end
	if Ns.Band(EB, Both) then returnText = BuffColor .. ("%.0f"):format(maxDPS) .. endColor .. " (" .. ("%.0f"):format(avgDPS) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critcal
function Ns.FunctionList.RangedCrit(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local critRating = GetCombatRating(CR_CRIT_RANGED)
	local returnText, decimals, liveCrit
	local capColor, endColor = "", ""

	if options.Dec_Ranged_Crit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Ranged_Crit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Ranged_Crit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveCrit = " > " .. (decimals):format(Ns.rangedCrit)
	else liveCrit = "" end

	if Ns.critRanged >= options.Cap_Ranged_Crit then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Percentage) then returnText = capColor .. (decimals):format(Ns.critRanged) .. liveCrit end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(critRating) .. liveCrit end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(Ns.critRanged) .. endColor .. " (" .. ("%.0f"):format(critRating) .. ")" .. liveCrit end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critcal vs Boss
function Ns.FunctionList.RangedCritBoss(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local levelDifference = 0
	local critAura = 1.8
	local returnText, decimals
	local capColor, endColor = "", ""

	levelDifference = Ns.targetLevel - Ns.playerLevel
	if levelDifference <= 0 then
		levelDifference = 0
		critAura = 0
	elseif levelDifference >= 3 then
		critAura = 1.8
	end

	Ns.critRanged = Ns.critRanged - levelDifference - critAura

	if Ns.critRanged < 0 then Ns.critRanged = 0 end

	if options.Dec_Ranged_CritBoss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Ranged_CritBoss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Ranged_CritBoss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.critRanged >= options.Cap_Ranged_CritBoss then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(Ns.critRanged) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(Ns.critRanged) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.critRanged) .. endColor .. " (" .. (decimals):format(Ns.critRanged) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Hit
function Ns.FunctionList.RangedHit(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local hitRangedRating = GetCombatRating(CR_HIT_RANGED)
	local returnText, decimals
	local capColor, endColor = "", ""

	if hitRangedRating == nil then hitRangedRating = 0 end

	if options.Dec_Ranged_Hit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Ranged_Hit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Ranged_Hit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.hitRanged >= options.Cap_Ranged_Hit then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Percentage) then returnText = capColor .. (decimals):format(Ns.hitRanged) end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(hitRangedRating) end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(Ns.hitRanged) .. endColor .. " (" .. ("%.0f"):format(hitRangedRating) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Armor Penetration
function Ns.FunctionList.RangedPen(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local rangedPenetration = GetArmorPenetration()
	local rangedPenRating = GetCombatRating(CR_ARMOR_PENETRATION)
	local returnText, decimals
	local capColor, endColor = "", ""

	if options.Dec_Ranged_Pen == 0 then decimals = "%.0f%%"
	elseif options.Dec_Ranged_Pen == 1 then decimals = "%.1f%%"
	elseif options.Dec_Ranged_Pen == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if rangedPenRating >= options.Cap_Ranged_ArP then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Percentage) then returnText = capColor .. (decimals):format(rangedPenetration) end
	if Ns.Band(EB, Rating) then returnText = capColor .. ("%.0f"):format(rangedPenRating) end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(rangedPenetration) .. endColor .. " (" .. ("%.0f"):format(rangedPenRating) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Miss
function Ns.FunctionList.RangedMiss(HUD, data, options, ...)

	local EB = options.Level_Same_Boss
	local miss = 0
	local missBoss = 0
	local baseMiss = BASE_MISS_CHANCE_PHYSICAL[0]
	local bossMiss = BASE_MISS_CHANCE_PHYSICAL[3]
	local returnText, decimals, liveMiss

	miss = baseMiss - Ns.hitRanged
	missBoss = bossMiss - Ns.hitRanged

	if Ns.targetLevel <= Ns.playerLevel then missBoss = baseMiss - Ns.hitRanged
	elseif Ns.targetLevel == (Ns.playerLevel + 1) then
		bossMiss = BASE_MISS_CHANCE_PHYSICAL[1]
		missBoss = bossMiss - Ns.hitRanged
	elseif Ns.targetLevel == (Ns.playerLevel + 2) then
		bossMiss = BASE_MISS_CHANCE_PHYSICAL[2]
		missBoss = bossMiss - Ns.hitRanged
	end


	if miss < 0 then miss = 0
	elseif miss > 100 then miss = 100 end

	if missBoss < 0 then missBoss = 0
	elseif missBoss > 100 then missBoss = 100 end

	if options.Dec_Ranged_Miss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Ranged_Miss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Ranged_Miss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveMiss = " > " .. (decimals):format(Ns.rangedMissTracker)
	else liveMiss = "" end

	if Ns.Band(EB, SameLevel) then returnText = (decimals):format(miss) .. liveMiss end
	if Ns.Band(EB, BossLevel) then returnText = (decimals):format(missBoss) .. liveMiss end
	if Ns.Band(EB, Both) then returnText = (decimals):format(miss) .. " (" .. (decimals):format(missBoss) .. ")" .. liveMiss end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

