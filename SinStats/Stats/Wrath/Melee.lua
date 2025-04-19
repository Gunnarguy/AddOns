local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Basic, Damage, DamageTaken, Percentage, Rating, MainHand, OffHand, SameLevel, BossLevel, Regen, Casting, Critical, CritDamage, Total, Max, Average, Auto = 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 3

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
	Ns.meleeSameLevel = 0
	Ns.meleeBossLevel = 0
	local mainBase, mainMod, _, _ = UnitAttackBothHands("player")
	--local levelDefense = Ns.playerLevel * 5
	local levelDiffDef = (Ns.targetLevel - Ns.playerLevel)
	local liveDefense = Ns.playerLevel * 5
	local bossDefense = (Ns.playerLevel + levelDiffDef) * 5
	local mWeaponSkill = (mainBase + mainMod)
	local meleeSkillDiff = liveDefense - mWeaponSkill
	local bossSkillDiff = bossDefense - mWeaponSkill
	local bossSkillMod = bossDefense - mWeaponSkill
	Ns.missMod = 0
	local _, isOffHand = UnitAttackSpeed("player")
	local itemType, itemSubtype, classId, subId = 0, 0, 0, 0

	if isOffHand ~= nil then
		if meleeSkillDiff > 10 then
			Ns.meleeSameLevel = (25 + ((meleeSkillDiff - 10) * 0.4))
			Ns.meleeSameLevel = Ns.meleeSameLevel - Ns.hitChance
		elseif meleeSkillDiff <= 10 then
			Ns.meleeSameLevel = (24 + ((meleeSkillDiff) * 0.1))
			Ns.meleeSameLevel = Ns.meleeSameLevel - Ns.hitChance
		end
		if bossSkillDiff > 10 then
			Ns.meleeBossLevel = (25 + ((bossSkillDiff - 10) * 0.4))
			Ns.meleeBossLevel = Ns.meleeBossLevel - Ns.hitChance
			Ns.missMod = (25 + ((bossSkillMod - 10) * 0.4))
			Ns.missMod = Ns.missMod - Ns.hitChance
		elseif bossSkillDiff <= 10 then
			Ns.meleeBossLevel = (24 + ((bossSkillDiff) * 0.1))
			Ns.meleeBossLevel = Ns.meleeBossLevel - Ns.hitChance
			Ns.missMod = (25 + ((bossSkillMod - 10) * 0.4))
			Ns.missMod = Ns.missMod - Ns.hitChance
		end
	else
		if Ns.druidFormChk() then
			Ns.meleeSameLevel = 5 - Ns.hitChance
			Ns.meleeBossLevel = 8 - Ns.hitChance
		else
			if meleeSkillDiff > 10 then
				Ns.meleeSameLevel = (6 + ((meleeSkillDiff - 10) * 0.4))
				Ns.meleeSameLevel = Ns.meleeSameLevel - Ns.hitChance
			elseif meleeSkillDiff <= 10 then
				Ns.meleeSameLevel = (5 + ((meleeSkillDiff) * 0.1))
				Ns.meleeSameLevel = Ns.meleeSameLevel - Ns.hitChance
			end
			if bossSkillDiff > 10 then
				Ns.meleeBossLevel = (6 + ((bossSkillDiff - 10) * 0.4))
				Ns.meleeBossLevel = Ns.meleeBossLevel - Ns.hitChance
				Ns.missMod = (6 + ((bossSkillMod - 10) * 0.4))
				Ns.missMod = Ns.missMod - Ns.hitChance
			elseif bossSkillDiff <= 10 then
				Ns.meleeBossLevel = (5 + ((bossSkillDiff) * 0.1))
				Ns.meleeBossLevel = Ns.meleeBossLevel - Ns.hitChance
				Ns.missMod = (5 + ((bossSkillMod - 10) * 0.1))
				Ns.missMod = Ns.missMod - Ns.hitChance
			end
		end
	end

	if Ns.meleeSameLevel < 0 then Ns.meleeSameLevel = 0
	elseif Ns.meleeSameLevel > 100 then Ns.meleeSameLevel = 100 end
	if Ns.meleeBossLevel < 0 then Ns.meleeBossLevel = 0
	elseif Ns.meleeBossLevel > 100 then Ns.meleeBossLevel = 100 end

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

	if not Ns.isShapeshift then shapeshiftAP = (Ns.playerLevel * Ns.predStrikes) end

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

	maxDamage = hiDmg + (hiDmg * Ns.crusadeTalent) + (hiDmg * Ns.desolation) + (hiDmg * Ns.frostFever) + (hiDmg * Ns.rageRivendare) + Ns.hemoDmg + (hiDmg * Ns.bloodFrenzy) +
				(hiDmg * Ns.savageCombat) + (hiDmg * Ns.BeastSlaying) + (hiDmg * Ns.FocusedFire) + (hiDmg * Ns.metaDamage) + (hiDmg * Ns.trickTrade)
	lowDamage = lowDmg + (lowDmg * Ns.crusadeTalent) + (lowDmg * Ns.desolation) + (lowDmg * Ns.frostFever) + (lowDmg * Ns.rageRivendare) + Ns.hemoDmg + (lowDmg * Ns.bloodFrenzy) +
				(lowDmg * Ns.savageCombat) + (lowDmg * Ns.BeastSlaying) + (lowDmg * Ns.FocusedFire) + (lowDmg * Ns.metaDamage) + (lowDmg * Ns.trickTrade)
	maxDamageOH = offhiDmg + (offhiDmg * Ns.crusadeTalent) + (offhiDmg * Ns.desolation) + (offhiDmg * Ns.frostFever) + (offhiDmg * Ns.rageRivendare) + Ns.hemoDmg + (offhiDmg * Ns.bloodFrenzy) +
				 (offhiDmg * Ns.savageCombat) + (offhiDmg * Ns.BeastSlaying) + (offhiDmg * Ns.FocusedFire) + (offhiDmg * Ns.metaDamage) + (offhiDmg * Ns.trickTrade)
	lowDamageOH = offlowDmg + (offlowDmg * Ns.crusadeTalent) + (offlowDmg * Ns.desolation) + (offlowDmg * Ns.frostFever) + (offlowDmg * Ns.rageRivendare) + Ns.hemoDmg + (offlowDmg * Ns.bloodFrenzy) +
				 (offlowDmg * Ns.savageCombat) + (offlowDmg * Ns.BeastSlaying) + (offlowDmg * Ns.FocusedFire) + (offlowDmg * Ns.metaDamage) + (offlowDmg * Ns.trickTrade)

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

	maxDamage = hiDmg + (hiDmg * Ns.crusadeTalent) + (hiDmg * Ns.desolation) + (hiDmg * Ns.frostFever) + (hiDmg * Ns.rageRivendare) + Ns.hemoDmg + (hiDmg * Ns.bloodFrenzy) +
				(hiDmg * Ns.savageCombat) + (hiDmg * Ns.FocusedFire) + (hiDmg * Ns.metaDamage) + (hiDmg * Ns.trickTrade)
	lowDamage = lowDmg + (lowDmg * Ns.crusadeTalent) + (lowDmg * Ns.desolation) + (lowDmg * Ns.frostFever) + (lowDmg * Ns.rageRivendare) + Ns.hemoDmg + (lowDmg * Ns.bloodFrenzy) +
				(lowDmg * Ns.savageCombat) + (lowDmg * Ns.FocusedFire) + (lowDmg * Ns.metaDamage) + (lowDmg * Ns.trickTrade)
	maxDamageOH = offhiDmg + (offhiDmg * Ns.crusadeTalent) + (offhiDmg * Ns.desolation) + (offhiDmg * Ns.frostFever) + (offhiDmg * Ns.rageRivendare) + Ns.hemoDmg + (offhiDmg * Ns.bloodFrenzy) +
				(offhiDmg * Ns.savageCombat) + (offhiDmg * Ns.FocusedFire) + (offhiDmg * Ns.metaDamage) + (offhiDmg * Ns.trickTrade)
	lowDamageOH = offlowDmg + (offlowDmg * Ns.crusadeTalent) + (offlowDmg * Ns.desolation) + (offlowDmg * Ns.frostFever) + (offlowDmg * Ns.rageRivendare) + Ns.hemoDmg +
				(offlowDmg * Ns.bloodFrenzy) + (offlowDmg * Ns.savageCombat) + (offlowDmg * Ns.FocusedFire) + (offlowDmg * Ns.metaDamage) + (offlowDmg * Ns.trickTrade)

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
	local tierNine = 0

	if (Ns.classFilename == "WARRIOR") then
		local stance = GetShapeshiftForm()
		if stance == 3 then tierNine = Ns.wrynnSetCrit end
	end

	critChance = critChance + Ns.totemWrath + Ns.heartCrusader + Ns.masterPoisoner + Ns.berserker + tierNine

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

	critChance = critChance + Ns.totemWrath + Ns.heartCrusader + Ns.masterPoisoner
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
	local mainBase, mainMod, offBase, offMod = UnitAttackBothHands("player")
	local mWeaponSkill = (mainBase + mainMod)

	local critChance = GetCritChance()
	local levelDifference = 0
	local critAura = 1.84
	local ohID = GetInventoryItemID("player", 17)
	local classId = 0
	local returnText, decimals

	if ohID then classId = select(12, GetItemInfo(ohID)) end

	if ohID and classId == Ns.weaponTag then
		mWeaponSkill = math.min((mainBase + mainMod), (offBase + offMod))
	end

	local skillDiff = 365 - mWeaponSkill
	local critSupp = 4.8
	local dodgeBoss = 5 + (skillDiff * 0.1)
	local glancingBoss = 40
	local extraWeaponSkill = mWeaponSkill - (Ns.playerLevel * 5)
	local mcritCap = 100 - Ns.missMod - dodgeBoss - glancingBoss + critSupp + (extraWeaponSkill * 0.04)
	local debuffColor = ""

	critChance = critChance + Ns.totemWrath
	levelDifference = Ns.targetLevel - Ns.playerLevel

	if Ns.crusader then critChance = critChance + Ns.crusaderTalent end

	if levelDifference <= 0 then
		levelDifference = 0
		critAura = 0
	end
	critChance = critChance - levelDifference - critAura

	if critChance < 0 then critChance = 0 end

	if critChance > mcritCap then debuffColor = Ns.redText
	elseif critChance == mcritCap then debuffColor = Ns.orangeText
	else debuffColor = Ns.greenText end

	if mcritCap > 100 then mcritCap = 100
	elseif mcritCap < 0 then mcritCap = 0 end

	if options.Dec_Melee_Cap == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Cap == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Cap == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. (decimals):format(mcritCap) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(mcritCap) end
	if Ns.Band(EB, Both) then returnText = debuffColor .. (decimals):format(mcritCap) .. "/" .. (decimals):format(mcritCap) end
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
	local hasteTalents, hasteSpells = 0, 0
	local cc, ec = "", ""

	if not options.Add_AtkSpeed then
		hasteTalents = ((hasteBonus * Ns.earthMother/100) + Ns.earthMother) + ((hasteBonus * Ns.LightningReflexes/100) + Ns.LightningReflexes) +
						((hasteBonus * Ns.icyTalons/100) + Ns.icyTalons)
		haste = hasteBonus + hasteTalents
		hasteSpells = ((haste * Ns.windFury/100) + Ns.windFury) + ((haste * Ns.improvedMoonkin/100) + Ns.improvedMoonkin) +
						((haste * Ns.impMoon/100) + Ns.impMoon)
		haste = haste + hasteSpells
	end

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
	local mhID = GetInventoryItemID("player", 16)
	local ohID = GetInventoryItemID("player", 17)
	local armorPen = GetArmorPenetration()
	local armorPenBase = armorPen
	local armorPenRating = GetCombatRating(CR_ARMOR_PENETRATION)
	local maceSpecOH = ""
	local returnText, decimals
	local stanceArmorPen, mhsubId, ohsubId = 0, 0, 0

	if (Ns.classFilename == "WARRIOR") then
		local battleStance = GetShapeshiftForm()
		if (battleStance == 1) then stanceArmorPen = 10 + Ns.wrynnSetArp end
	end

	armorPen = armorPen + Ns.bloodGorged + Ns.SerratedBlades + stanceArmorPen

	if mhID then mhsubId = select(13, GetItemInfo(mhID)) end

	if (Ns.MaceEquipped[mhID] or Ns.MaceEquipped[mhsubId]) then armorPen =  armorPen + Ns.MaceSpec end

	if ohID then ohsubId = select(13, GetItemInfo(ohID)) end

	if Ns.MaceSpec ~= 0 then
		if (Ns.MaceEquipped[ohID] or Ns.MaceEquipped[ohsubId]) then maceSpecOH = "/" .. ("%.0f%%"):format(Ns.MaceSpec) end
		if (Ns.MaceEquipped[mhID] or Ns.MaceEquipped[mhsubId]) and (Ns.MaceEquipped[ohID] or Ns.MaceEquipped[ohsubId]) then maceSpecOH = "" end
	end

	if options.Display_Basic then armorPen = armorPenBase; maceSpecOH = "" end

	if options.Dec_Melee_Pen == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Pen == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Pen == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(armorPen) .. maceSpecOH end
	if Ns.Band(EB, Rating) then returnText = armorPenRating end
	if Ns.Band(EB, Both) then returnText = (decimals):format(armorPen) .. maceSpecOH .. " (" .. armorPenRating .. ")" end
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
	npcArmor = Ns.targetArmor - Ns.targetArmor * (Ns.curseOfWeak/100) - Ns.targetArmor * (Ns.faerieFire/100) - Ns.targetArmor * (Ns.exposeArmor/100) - Ns.targetArmor * (Ns.sunderArmor/100) - Ns.shatterArmor

	if (Ns.sunderArmor > 0) or (Ns.exposeArmor > 0) or (Ns.faerieFire > 0) or (Ns.curseOfWeak > 0) or (Ns.shatterArmor > 0) then debuffColor = Ns.greenText end

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

	local EB = options.Percent_Rating
	local expertisePercent, offhandExpertisePercent = GetExpertisePercent()
	local expertiseRating = GetCombatRating(CR_EXPERTISE)
	local ohID = GetInventoryItemID("player", 17)
	local returnText, decimals, liveExp
	local cc, ratingColor, ec = "", "", ""
	local classId = 0

	if ohID then classId = select(12, GetItemInfo(ohID)) end

	local mainHandFormat = expertisePercent
	local offHandFormat = offhandExpertisePercent

	if options.Dec_Melee_Exp == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Exp == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Exp == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if (ohID and classId == Ns.weaponTag) and offhandExpertisePercent > 0 then offHandFormat = "/" .. (decimals):format(offHandFormat)
	else offHandFormat = "" end

	if options.Display_Expertise then mainHandFormat = GetExpertise(); decimals = "%.0f" end

	if mainHandFormat >= options.Cap_Melee_Exp then cc = Ns.greenText end
	if expertiseRating >= 213 then ratingColor = Ns.greenText end

	if cc ~= "" then ec = "|r" end

	if options.Display_Simulate then liveExp = " > " .. (decimals):format(Ns.totalParryDodge)
	else liveExp = "" end

	if Ns.Band(EB, Percentage) then returnText = cc.. (decimals):format(mainHandFormat) .. offHandFormat .. liveExp end
	if Ns.Band(EB, Rating) then returnText = ratingColor .. expertiseRating .. liveExp end
	if Ns.Band(EB, Both) then returnText = cc.. (decimals):format(mainHandFormat) .. offHandFormat .. ec .. " (" .. ratingColor .. expertiseRating .. ")" .. liveExp end

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

	if (Ns.sunderArmor > 0) or (Ns.exposeArmor > 0) or (Ns.faerieFire > 0) or (Ns.curseOfWeak > 0) or (Ns.shatterArmor > 0) then debuffColor = Ns.greenText end

	damageReduction = damageReduction + Ns.curseOfWeak + Ns.faerieFire + Ns.exposeArmor + Ns.sunderArmor + Ns.shatterArmor

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

	if options.Dec_Melee_Miss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Melee_Miss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Melee_Miss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveMiss = " > " .. (decimals):format(Ns.meleeMissTracker)
	else liveMiss = "" end

	if Ns.Band(EB, SameLevel) then returnText = (decimals):format(Ns.meleeSameLevel) .. liveMiss end
	if Ns.Band(EB, BossLevel) then returnText = (decimals):format(Ns.meleeBossLevel) .. liveMiss end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.meleeSameLevel) .. " (" .. (decimals):format(Ns.meleeBossLevel) .. ")" .. liveMiss end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

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

