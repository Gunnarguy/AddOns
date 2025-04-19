local _, Ns = ...

------------------------------
--		Options Equates		--
------------------------------
local Value, Enhanced, MainHand, Percentage, SameLevel = 1, 1, 1, 1, 1
local Basic, OffHand, Rating, BossLevel = 2, 2, 2, 2
local Both, Auto = 3, 3

----------------------------------
--		Text Return Formats		--
----------------------------------
-- local Percent_Rating_Format = { "%.2f%%", "%.0f", "%.2f%% (%.0f)", }
-- local Haste_Format = { "%.2f%%", "%.0f", "%.1f%% (%.0f)", }
-- local Miss_Chance_Format = { "%.2f%%", "%.2f%%", "%.2f/%.2f%%", }

------------------------------
--		Global Updater		--
------------------------------

Ns.missMod, Ns.meleeSameLevel, Ns.meleeBossLevel, Ns.hitChance, Ns.hitBonus = 0,0,0,0,0

function Ns.MeleeUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then Ns.targetLevel = Ns.playerLevel + 3 end
	end

	-- Hit
	Ns.hitChance = GetHitModifier()
	Ns.hitBonus = GetCombatRatingBonus(CR_HIT_MELEE)

	if Ns.hitChance == nil then Ns.hitChance = 0 end
	if Ns.hitBonus == nil then Ns.hitBonus = 0 end

	Ns.hitChance = Ns.hitChance + Ns.hitBonus

	-- Miss Chance
	Ns.missChance, Ns.missBoss = 0, 0
	local baseMiss = BASE_MISS_CHANCE_PHYSICAL[0]
	local bossMiss = BASE_MISS_CHANCE_PHYSICAL[3]
	local dualWield = 0

	-- Dual wield
	if IsDualWielding() then dualWield = DUAL_WIELD_HIT_PENALTY end

	Ns.missChance = baseMiss - Ns.hitChance + dualWield
	Ns.missBoss = bossMiss - Ns.hitChance + dualWield

	if Ns.targetLevel <= Ns.playerLevel then
		Ns.missBoss = baseMiss - Ns.hitChance + dualWield
	elseif Ns.targetLevel == (Ns.playerLevel + 1) then
		bossMiss = BASE_MISS_CHANCE_PHYSICAL[1]
		Ns.missBoss = bossMiss - Ns.hitChance + dualWield
	elseif Ns.targetLevel == (Ns.playerLevel + 2) then
		bossMiss = BASE_MISS_CHANCE_PHYSICAL[2]
		Ns.missBoss = bossMiss - Ns.hitChance + dualWield
	end
--
end
------------------------------------------------

-- Attack Power
function Ns.FunctionList.AP(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local base, posBuff, negBuff = UnitAttackPower("player")
	local attackPower = base + posBuff + negBuff
	local shapeshiftAP = 0
	local baseAP = attackPower
	local debuffColor, ec = "", ""
	local returnText

	attackPower = attackPower + shapeshiftAP

	if negBuff < 0 then debuffColor = Ns.redText end
	if debuffColor ~= "" then ec = "|r" end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. attackPower end
	if Ns.Band(EB, Basic) then
        returnText = returnText and (returnText .. ec .. "/") or ""
		returnText = returnText .. baseAP
	end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Damage
function Ns.FunctionList.DMG(HUD, data, options, ...)

	local EB = options.Main_Off_Auto
	local lowDmg, hiDmg, offlowDmg, offhiDmg, _, negBuff = UnitDamage("player")
	local ohID = GetInventoryItemID("player", 17)
	local maxDamage = hiDmg
	local lowDamage = lowDmg
	local maxDamageOH = offhiDmg
	local lowDamageOH = offlowDmg
	local debuffColor = ""
	local returnText
	local classId = 0

	if ohID then classId = select(12, GetItemInfo(ohID)) end

	maxDamage = hiDmg + (hiDmg * Ns.bloodFrenzy) +
				(hiDmg * Ns.savageCombat) + (hiDmg * Ns.BeastSlaying) + (hiDmg * Ns.metaDamage) + (hiDmg * Ns.trickTrade) + (hiDmg * Ns.brittleBones) +
				(hiDmg * Ns.FrozenWastes)

	lowDamage = lowDmg + (lowDmg * Ns.bloodFrenzy) +
				(lowDmg * Ns.savageCombat) + (lowDmg * Ns.BeastSlaying) + (lowDmg * Ns.metaDamage) + (lowDmg * Ns.trickTrade) + (lowDmg * Ns.brittleBones) +
				(lowDmg * Ns.FrozenWastes)

	maxDamageOH = offhiDmg + (offhiDmg * Ns.bloodFrenzy) +
				 (offhiDmg * Ns.savageCombat) + (offhiDmg * Ns.BeastSlaying) + (offhiDmg * Ns.metaDamage) + (offhiDmg * Ns.trickTrade) + (offhiDmg * Ns.brittleBones) +
				 (offhiDmg * Ns.FrozenWastes)

	lowDamageOH = offlowDmg + (offlowDmg * Ns.bloodFrenzy) +
				 (offlowDmg * Ns.savageCombat) + (offlowDmg * Ns.BeastSlaying) + (offlowDmg * Ns.metaDamage) + (offlowDmg * Ns.trickTrade) + (offlowDmg * Ns.brittleBones) +
				 (offlowDmg * Ns.FrozenWastes)

	if options.Display_Average then
		maxDamage = (maxDamage + lowDamage) / 2
		maxDamageOH = (maxDamageOH + lowDamageOH) / 2
	end

	local maxDamageAlt = maxDamageOH

	if (ohID and classId == Ns.weaponTag) then maxDamageOH = "/" .. math.floor(maxDamageOH)
	else maxDamageOH = "" end

	if negBuff < 0 then debuffColor = Ns.redText end

	if Ns.Band(EB, MainHand) then returnText = debuffColor .. math.floor(maxDamage) end
	if Ns.Band(EB, OffHand) then returnText = math.floor(maxDamageAlt) end
	if Ns.Band(EB, Auto) then returnText = debuffColor .. math.floor(maxDamage) .. maxDamageOH end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- DPS
function Ns.FunctionList.mDPS(HUD, data, options, ...)

	local EB = options.Main_Off_Auto
	local lowDmg, hiDmg, offlowDmg, offhiDmg, _, negBuff = UnitDamage("player")
	local ohID = GetInventoryItemID("player", 17)
	local mainSpeed = UnitAttackSpeed("player")
	local maxDamage = hiDmg
	local lowDamage = lowDmg
	local maxDamageOH = offhiDmg
	local lowDamageOH = offlowDmg
	local DPS = 0
	local DPSOH = 0
	local debuffColor = ""
	local classId = 0
	local returnText

	if ohID then classId = select(12, GetItemInfo(ohID)) end

	maxDamage = hiDmg + (hiDmg * Ns.bloodFrenzy) +
				(hiDmg * Ns.savageCombat) + (hiDmg * Ns.metaDamage) + (hiDmg * Ns.trickTrade) + (hiDmg * Ns.brittleBones) +
				(hiDmg * Ns.FrozenWastes)

	lowDamage = lowDmg + (lowDmg * Ns.bloodFrenzy) +
				(lowDmg * Ns.savageCombat) + (lowDmg * Ns.metaDamage) + (lowDmg * Ns.trickTrade) + (lowDmg * Ns.brittleBones) +
				(lowDmg * Ns.FrozenWastes)

	maxDamageOH = offhiDmg + (offhiDmg * Ns.bloodFrenzy) +
				(offhiDmg * Ns.savageCombat) + (offhiDmg * Ns.metaDamage) + (offhiDmg * Ns.trickTrade) + (offhiDmg * Ns.brittleBones) +
				(offhiDmg * Ns.FrozenWastes)

	lowDamageOH = offlowDmg + (offlowDmg * Ns.brittleBones) +
				(offlowDmg * Ns.bloodFrenzy) + (offlowDmg * Ns.savageCombat) + (offlowDmg * Ns.metaDamage) + (offlowDmg * Ns.trickTrade) +
				(offlowDmg * Ns.FrozenWastes)

	if options.Display_Average then
		maxDamage = (maxDamage + lowDamage) / 2
		maxDamageOH = (maxDamageOH + lowDamageOH) / 2
	end
	if mainSpeed ~= 0 then
		DPS = ((lowDamage + maxDamage) / 2) / mainSpeed
		DPSOH = ((lowDamageOH + maxDamageOH) / 2) / mainSpeed
	end

	local DPSOH2 = DPSOH

	if (ohID and classId == Ns.weaponTag) then DPSOH = "/" .. math.floor(DPSOH+1)
	else DPSOH = "" end

	if negBuff < 0 then debuffColor = Ns.redText end

	if Ns.Band(EB, MainHand) then returnText = debuffColor .. math.floor(DPS+1) end
	if Ns.Band(EB, OffHand) then returnText = math.floor(DPSOH2+1) end
	if Ns.Band(EB, Auto) then returnText = debuffColor .. math.floor(DPS+1) .. DPSOH end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critical
function Ns.FunctionList.Crit(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local critChance = GetCritChance()
	local critRating = GetCombatRating(CR_CRIT_MELEE)
	local returnText, decimals, liveCrit
	local cc, ec = "", ""

	critChance = critChance + Ns.masterPoisoner

	if options.Display_Basic then critChance = GetCritChance(); critRating = GetCombatRating(CR_CRIT_MELEE) end

	if options.Dec_Melee_Crit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Crit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Crit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveCrit = " > " .. (decimals):format(Ns.meleeCrit)
	else liveCrit = "" end

	if critChance > options.Cap_Melee_Crit then cc = Ns.greenText end
	if cc ~= "" then ec = "|r" end

	if Ns.Band(EB, Percentage) then returnText = cc .. (decimals):format(critChance) .. liveCrit end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(critRating) .. liveCrit end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(critChance) .. ec .. " (" .. ("%.0f"):format(critRating) .. ")"  .. liveCrit end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critical vs Boss
function Ns.FunctionList.CritBoss(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local critChance = GetCritChance()
	local critBase = critChance
	local levelDifference = 0
	local critAura = 0
	local returnText, decimals
	local cc, ec = "", ""

	critChance = critChance + Ns.masterPoisoner
	levelDifference = Ns.targetLevel - Ns.playerLevel

	if levelDifference <= 0 then levelDifference = 0; critAura = 0
	elseif levelDifference >= 3 then critAura = 1.8 end

	critChance = critChance - levelDifference - critAura
	critBase = critBase  - levelDifference - critAura

	if critChance < 0 then critChance = 0 end
	if critBase < 0 then critBase = 0 end

	if options.Dec_Melee_Boss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Boss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Boss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if critChance > options.Cap_Melee_CritBoss then cc = Ns.greenText end
	if cc ~= "" then ec = "|r" end

	if Ns.Band(EB, Enhanced) then returnText = cc .. (decimals):format(critChance) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(critBase) end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(critChance) .. ec .. "/" .. (decimals):format(critBase) end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critical Cap
function Ns.FunctionList.CritCap(HUD, data, options, ...)

	local EB = options.Enhanced_Base

	local critChance = GetCritChance()
	local aura = 4.84
	local glancing = 24
	local cap = 100
	local dodged = GetExpertisePercent()
	local critCap = 0
	local debuffColor = ""
	local decimals, returnText

	critCap = cap - aura - dodged - Ns.missBoss

	if critChance < 0 then critChance = 0 end

	if critChance > critCap then debuffColor = Ns.redText
	elseif critChance == critCap then debuffColor = Ns.orangeText
	else debuffColor = Ns.greenText end

	if options.Dec_Melee_Cap == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Cap == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Cap == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. (decimals):format(critCap) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(critCap) end
	if Ns.Band(EB, Both) then returnText = debuffColor .. (decimals):format(critCap) .. "/" .. (decimals):format(critCap) end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Hit
function Ns.FunctionList.Hit(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local hitRating = GetCombatRating(CR_HIT_MELEE)
	local returnText, decimals
	local cc, ec = "", ""

	if options.Dec_Melee_Hit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Hit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Hit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.hitChance >= options.Cap_Melee_Hit then cc = Ns.greenText end
	if cc ~= "" then ec = "|r" end

	if Ns.Band(EB, Percentage) then returnText = cc .. (decimals):format(Ns.hitChance) end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(hitRating) end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(Ns.hitChance) .. ec .. " (" .. ("%.0f"):format(hitRating) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Haste
function Ns.FunctionList.HasteMelee(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local haste = GetMeleeHaste()
	local hasteBonus = GetCombatRatingBonus(CR_HASTE_MELEE)
	local hasteRating = GetCombatRating(CR_HASTE_MELEE)
	local returnText, decimals
	local hasteTalents = 0
	local cc, ec = "", ""

	if options.Display_Basic then haste = hasteBonus end

	if options.Dec_Melee_Haste == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Haste == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Haste == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if haste >= options.Cap_Melee_Haste then cc = Ns.greenText end
	if cc ~= "" then ec = "|r" end

	if Ns.Band(EB, Percentage) then returnText = cc .. (decimals):format(haste) end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(hasteRating) end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(haste) .. ec .. " (" .. ("%.0f"):format(hasteRating) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Attack Speed
function Ns.FunctionList.weaponSpeed(HUD, data, options, ...)

	local EB = options.Main_Off_Auto
	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	local ohID = GetInventoryItemID("player", 17)
	local returnText, decimals

	if offSpeed == nil then offSpeed = 0 end

	local offHandSpeed = offSpeed
	local offHandAuto = offSpeed
	local classId = 0

	if ohID then classId = select(12, GetItemInfo(ohID)) end

	if (ohID and classId == Ns.weaponTag) then offHandSpeed = "/" .. ("%.1f"):format(offHandSpeed)
	else offHandSpeed = "" end

	if options.Dec_Melee_AttSp == 0 then decimals = "%.0f"
	elseif options.Dec_Melee_AttSp == 1 then decimals = "%.1f"
	elseif options.Dec_Melee_AttSp == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, MainHand) then returnText = (decimals):format(mainSpeed) end
	if Ns.Band(EB, OffHand) then returnText = (decimals):format(offHandAuto) end
	if Ns.Band(EB, Auto) then returnText = (decimals):format(mainSpeed) .. offHandSpeed end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Armor Penenetration
function Ns.FunctionList.ArmorPen(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local armorPen = GetArmorPenetration()
	local armorPenBase = armorPen
	local armorPenRating = GetCombatRating(CR_ARMOR_PENETRATION)
	local returnText, decimals

	if options.Display_Basic then armorPen = armorPenBase end

	if options.Dec_Melee_Pen == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Pen == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Pen == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(armorPen) end
	if Ns.Band(EB, Rating) then returnText = armorPenRating end
	if Ns.Band(EB, Both) then returnText = (decimals):format(armorPen) .. " (" .. armorPenRating .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Target Armor
function Ns.FunctionList.NPCArmor(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local debuffColor = ""
	local npcArmorBase = Ns.targetArmor
	local npcArmor = 0
	local returnText
	npcArmor = Ns.targetArmor - Ns.targetArmor * (Ns.faerieFire/100) - Ns.targetArmor * (Ns.exposeArmor/100) - Ns.targetArmor * (Ns.sunderArmor/100) - Ns.shatterArmor

	if (Ns.sunderArmor > 0) or (Ns.exposeArmor > 0) or (Ns.faerieFire > 0) or (Ns.shatterArmor > 0) then debuffColor = Ns.greenText end

	if npcArmor == 0 then debuffColor = "" end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. ("%.0f"):format(npcArmor) end
	if Ns.Band(EB, Basic) then returnText = debuffColor .. ("%.0f"):format(npcArmorBase) end
	if Ns.Band(EB, Both) then returnText = debuffColor .. ("%.0f"):format(npcArmor) .. "/" .. ("%.0f"):format(npcArmorBase) end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Expertise
function Ns.FunctionList.Expertise(HUD, data, options, ...)

	local EB = options.Value_Rating
	local expertisePercent, offhandExpertisePercent = GetExpertisePercent()
	local expertiseRating = GetCombatRating(CR_EXPERTISE)
	local ohID = GetInventoryItemID("player", 17)
	local returnText, decimals, liveExp
	local cc, ratingColor, ec = "", "", ""
	local classId, mainHandFormat, offHandFormat = 0, "", ""

	if ohID then classId = select(12, GetItemInfo(ohID)) end

	mainHandFormat = GetExpertise()

	if options.Dec_Melee_Exp == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Exp == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Exp == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if mainHandFormat >= options.Cap_Melee_Exp then cc = Ns.greenText end
	if expertiseRating >= 781 then ratingColor = Ns.greenText end

	if cc ~= "" then ec = "|r" end

	if options.Display_Expertise then
		mainHandFormat = (decimals):format(expertisePercent)
		offHandFormat = (decimals):format(offhandExpertisePercent)
		if (ohID and classId == Ns.weaponTag) and offhandExpertisePercent > 0 then offHandFormat = "/" .. offHandFormat
		else offHandFormat = "" end
	end

	if options.Display_Simulate then liveExp = " > " .. (decimals):format(Ns.totalParryDodge)
	else liveExp = "" end

	if Ns.Band(EB, Value) then returnText = cc.. mainHandFormat .. offHandFormat .. liveExp end
	if Ns.Band(EB, Rating) then returnText = ratingColor .. expertiseRating .. liveExp end
	if Ns.Band(EB, Both) then returnText = cc.. mainHandFormat .. offHandFormat .. ec .. " (" .. ratingColor .. expertiseRating .. ")" .. liveExp end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Damage Reduction
function Ns.FunctionList.BossReduc(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local debuffColor = ""
	local valueSign = ""
	local returnText, decimals

	local damageReduction = (Ns.targetArmor / ((467.5 * Ns.targetLevel) + Ns.targetArmor - 22167.5)) * 100
	local baseReduction = (Ns.targetArmor / ((467.5 * Ns.targetLevel) + Ns.targetArmor - 22167.5)) * 100

	if (Ns.sunderArmor > 0) or (Ns.exposeArmor > 0) or (Ns.faerieFire > 0) or (Ns.curseWeak > 0) or (Ns.shatterArmor > 0) then debuffColor = Ns.greenText end

	damageReduction = damageReduction + Ns.curseWeak + Ns.faerieFire + Ns.exposeArmor + Ns.sunderArmor + Ns.shatterArmor

	if damageReduction < 0 then damageReduction = math.abs(damageReduction); valueSign = "+" end

	if options.Dec_Melee_Dmg == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Dmg == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Dmg == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. valueSign .. (decimals):format(damageReduction) end
	if Ns.Band(EB, Basic) then returnText = valueSign .. (decimals):format(baseReduction) end
	if Ns.Band(EB, Both) then returnText = debuffColor .. valueSign .. (decimals):format(damageReduction) .. " (" .. ("%.1f%%"):format(baseReduction) .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Miss
function Ns.FunctionList.MeleeMiss(HUD, data, options, ...)

	local EB = options.Level_Same_Boss
	local returnText, decimals, liveMiss
	local miss, missBoss = Ns.missChance, Ns.missBoss

	if options.Dec_Melee_Miss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Miss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Miss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Special then
		if IsDualWielding() then
			miss = Ns.missChance - DUAL_WIELD_HIT_PENALTY
			missBoss = Ns.missBoss - DUAL_WIELD_HIT_PENALTY
		end
	end

	if miss <= 0 then miss = 0
	elseif miss >= 100 then miss = 100 end

	if missBoss <= 0 then missBoss = 0
	elseif missBoss >= 100 then missBoss = 100 end

	if options.Display_Simulate then liveMiss = " > " .. (decimals):format(Ns.meleeMissTracker)
	else liveMiss = "" end

	if Ns.Band(EB, SameLevel) then returnText = (decimals):format(miss) .. liveMiss end
	if Ns.Band(EB, BossLevel) then returnText = (decimals):format(missBoss) .. liveMiss end
	if Ns.Band(EB, Both) then returnText = (decimals):format(miss) .. " (" .. (decimals):format(missBoss) .. ")" .. liveMiss end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------
