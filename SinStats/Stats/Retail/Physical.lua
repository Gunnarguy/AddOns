local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Enhanced, Percent, Melee, Max = 1, 1, 1, 1
local Base, Rating, Ranged, Average = 2, 2, 2, 2
local Both, Low = 3, 3

--------------------------
--		Physical		--
--------------------------
-- Strength
function Ns.FunctionList.Strength(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local base, stat, _, negBuff = UnitStat("Player", 1)
	local debuffColor = ""
	local returnText

	if not base then base = 0 end
	if not stat then stat = 0 end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if options.Decimals_Default == 0 then
		stat = BreakUpLargeNumbers(stat)
		base = BreakUpLargeNumbers(base)
	elseif options.Decimals_Default == 1 then
		stat = Ns.ShortNumbers(stat, 0)
		base = Ns.ShortNumbers(base, 0)
	elseif options.Decimals_Default == 2 then
		stat = Ns.ShortNumbers(stat, 1)
		base = Ns.ShortNumbers(base, 1)
	else
		stat = Ns.ShortNumbers(stat, 2)
		base = Ns.ShortNumbers(base, 2)
	end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. stat end
	if Ns.Band(EB, Base) then returnText = base end
	if Ns.Band(EB, Both) then returnText = debuffColor .. stat .. "|r/" .. base end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Agility
function Ns.FunctionList.Agility(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local _, stat, _, negBuff = UnitStat("Player", 2)
	local debuffColor = ""
	local returnText
	local base = stat

	if not base then base = 0 end
	if not stat then stat = 0 end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if options.Decimals_Default == 0 then
		stat = BreakUpLargeNumbers(stat)
		base = BreakUpLargeNumbers(base)
	elseif options.Decimals_Default == 1 then
		stat = Ns.ShortNumbers(stat, 0)
		base = Ns.ShortNumbers(base, 0)
	elseif options.Decimals_Default == 2 then
		stat = Ns.ShortNumbers(stat, 1)
		base = Ns.ShortNumbers(base, 1)
	else
		stat = Ns.ShortNumbers(stat, 2)
		base = Ns.ShortNumbers(base, 2)
	end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. stat end
	if Ns.Band(EB, Base) then returnText = base end
	if Ns.Band(EB, Both) then returnText = debuffColor .. stat .. "|r/" .. base end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Attack Power
function Ns.FunctionList.AP(HUD, data, options, ...)

	local EB = options.Melee_Ranged
	local base, posBuff, negBuff = UnitAttackPower("player");
	local effectiveAP = base + posBuff + negBuff;
	local base, posBuff, negBuff = UnitRangedAttackPower("player");
	local effectiveRanged = base + posBuff + negBuff;
	local debuffColor = ""
	local returnText

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if not effectiveAP then effectiveAP = 0 end
	if not effectiveRanged then effectiveRanged = 0 end

	if options.Decimals_Default == 0 then
		effectiveAP = BreakUpLargeNumbers(effectiveAP)
		effectiveRanged = BreakUpLargeNumbers(effectiveRanged)
	elseif options.Decimals_Default == 1 then
		effectiveAP = Ns.ShortNumbers(effectiveAP, 0)
		effectiveRanged = Ns.ShortNumbers(effectiveRanged, 0)
	elseif options.Decimals_Default == 2 then
		effectiveAP = Ns.ShortNumbers(effectiveAP, 1)
		effectiveRanged = Ns.ShortNumbers(effectiveRanged, 1)
	else
		effectiveAP = Ns.ShortNumbers(effectiveAP, 2)
		effectiveRanged = Ns.ShortNumbers(effectiveRanged, 2)
	end

	if Ns.Band(EB, Melee) then returnText = debuffColor .. effectiveAP end
	if Ns.Band(EB, Ranged) then returnText = debuffColor .. effectiveRanged end
	if Ns.Band(EB, Both) then returnText = debuffColor .. effectiveAP .. "|r/" .. debuffColor .. effectiveRanged end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Damage
function Ns.FunctionList.DMG(HUD, data, options, ...)

	local EB = options.Max_Average_Damage
	local lowDmg, hiDmg, offlowDmg, offhiDmg, _, negBuff = UnitDamage("player")
	local totalDamage = hiDmg
	local meleeDamageOH = offhiDmg
	local avgDamage = (hiDmg + lowDmg) / 2
	local lowDmg = lowDmg
	local speed = UnitRangedDamage("player")
	local debuffColor = ""
	local ohID = GetInventoryItemID("player", 17)
	local ohsubId = 0
	local returnText, decimals

	if options.Decimals_Damage == 0 then decimals = "%.0f"
	elseif options.Decimals_Damage == 1 then decimals = "%.1f"
	elseif options.Decimals_Damage == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	local avgOhDmg = "/" .. (decimals):format((offhiDmg + offlowDmg) / 2)
	local lowOH = "/" .. (decimals):format(offlowDmg)

	if speed > 0 then
		local _, rlowDmg, rhiDmg, _ = UnitRangedDamage("player")
		totalDamage = rhiDmg + (rhiDmg * Ns.mysticTouch) + (rhiDmg * Ns.razorIce) + (rhiDmg * Ns.luckOfDraw) + (rhiDmg * (Ns.bestialWrath/100)) + (rhiDmg * Ns.luckOfDraw)
							 + (rhiDmg * (Ns.delver/100))
		avgDamage = (rhiDmg + rlowDmg) / 2
		avgDamage = avgDamage + (avgDamage * Ns.mysticTouch) + (avgDamage * Ns.razorIce) + (avgDamage * Ns.luckOfDraw) + (avgDamage * (Ns.bestialWrath/100))
		avgOhDmg = ""
		lowDmg = rlowDmg
		lowOH = ""
	end

	if ohID then ohsubId = select(13, C_Item.GetItemInfo(ohID)) end
	if ohID or ohsubId == 2 then
		meleeDamageOH = meleeDamageOH + (meleeDamageOH * Ns.mysticTouch) + (meleeDamageOH * Ns.colossusSmash) + (meleeDamageOH * Ns.razorIce) + (meleeDamageOH * Ns.felSunder) +
					   (meleeDamageOH * Ns.jadeFire) + (meleeDamageOH * Ns.serenity) + (meleeDamageOH * Ns.luckOfDraw) + (meleeDamageOH * Ns.brittle) +
					   (meleeDamageOH * (Ns.finalReck/100)) + (meleeDamageOH * Ns.seethChaos) + (meleeDamageOH * Ns.ebonMight) +
					   (meleeDamageOH * (Ns.feralSpirit/100)) + (meleeDamageOH * Ns.ghostlyStrike) + (meleeDamageOH * Ns.huntersMark) +
					   (meleeDamageOH * (Ns.delver/100))
		meleeDamageOH = "/" .. (decimals):format(meleeDamageOH)
	else
		meleeDamageOH = ""
		avgOhDmg = ""
		lowOH = ""
	end

	if options.Display_MainHand then meleeDamageOH = ""; avgOhDmg = ""; lowOH = "" end

	totalDamage = totalDamage + (totalDamage * Ns.mysticTouch) + (totalDamage * Ns.colossusSmash) + (totalDamage * Ns.razorIce) + (totalDamage * Ns.felSunder) + (totalDamage * Ns.jadeFire) + (totalDamage * Ns.serenity) +
				(totalDamage * Ns.luckOfDraw) + (totalDamage * Ns.brittle) + (totalDamage * (Ns.finalReck/100)) + (totalDamage * Ns.seethChaos) + (totalDamage * Ns.ebonMight) +
				(totalDamage * (Ns.feralSpirit/100)) + (totalDamage * Ns.ghostlyStrike) + (totalDamage * Ns.huntersMark) + (totalDamage * (Ns.delver/100))

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if Ns.Band(EB, Max) then returnText = debuffColor .. (decimals):format(totalDamage) .. meleeDamageOH end
	if Ns.Band(EB, Average) then returnText = debuffColor .. (decimals):format(avgDamage) .. avgOhDmg end
	if Ns.Band(EB, Low) then returnText = debuffColor .. (decimals):format(lowDmg) .. lowOH end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Damage Bonus
function Ns.FunctionList.DMGMod(HUD, data, options, ...)

	local EB = options.Melee_Ranged
	local pmod = select(7,UnitDamage("player"))
	local rpmod = select(6, UnitRangedDamage("player"))
	local verDamage = GetVersatilityBonus(29) + GetCombatRatingBonus(29)
	local spec = GetSpecialization()
	local mastery, rmastery = 0, 0
	local masteryFx = GetMasteryEffect()
	local dmgMod, rdmgMod = 0, 0
	local color, rcolor = "", ""
	local decimals, returnText

	if options.Decimals_DmgMod == 0 then decimals = "%.0f%%"
	elseif options.Decimals_DmgMod == 1 then decimals = "%.1f%%"
	elseif options.Decimals_DmgMod == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	-- Mastery Effect
	if Ns.classId == 1 then -- warrior
		if (spec == 1) then mastery = masteryFx end
		if (spec == 2) and Ns.enrage then mastery = masteryFx end
	elseif Ns.classId == 2 then -- paladin
		if (spec == 3) then mastery = masteryFx end
	elseif Ns.classId == 3 then -- hunter
		if (spec == 1) or (spec == 3) then rmastery = masteryFx end
		if (spec == 2) then rmastery = masteryFx*2.233 end
	elseif Ns.classId == 6 then -- death knight
		if (spec == 2) then mastery = masteryFx end
	elseif Ns.classId == 7 then -- shaman
		if (spec == 1) then mastery = masteryFx/3.351 end
	elseif Ns.classId == 10 then -- monk
		if (spec == 3) and (Ns.hitCombo > 0) then mastery = masteryFx end
	elseif Ns.classId == 12 then -- demon hunter
		if (spec == 1) then mastery = masteryFx end
	end

	dmgMod = (Ns.mysticTouch * 100) + (Ns.colossusSmash * 100) + (Ns.razorIce * 100) + (Ns.felSunder * 100) + (Ns.jadeFire * 100) +
			 (Ns.serenity * 100) + (Ns.luckOfDraw * 100) + (Ns.brittle * 100) + Ns.loneWolf + Ns.hitCombo + verDamage + Ns.demonSoul +
			 Ns.ferocityXuen + Ns.tigersFury + Ns.finalReck + Ns.momentum + (Ns.seethChaos * 100) + Ns.symbolsDeath +
			 (Ns.ebonMight * 100) + Ns.avatar + Ns.battleShout - Ns.defStance + Ns.feralSpirit + (Ns.ghostlyStrike * 100) + Ns.retAura +
			 Ns.inertia + (Ns.huntersMark * 100) + Ns.avWrath + mastery + Ns.martial + Ns.delver

	dmgMod = dmgMod + (pmod * 10) + 100

	rdmgMod = (Ns.mysticTouch * 100) + (Ns.razorIce * 100) + (Ns.luckOfDraw * 100) + Ns.loneWolf  + Ns.bestialWrath
			  + (Ns.mysticTouch * 100) + Ns.retAura + (Ns.huntersMark * 100)  + rmastery + Ns.delver
	rdmgMod = rdmgMod + (rpmod * 10) + 100

	if dmgMod <= 0 then dmgMod = 100 end
	if rdmgMod <= 0 then rdmgMod = 100 end
	if dmgMod > 100 then color = Ns.greenText end
	if rdmgMod > 100 then rcolor = Ns.greenText end

	if Ns.Band(EB, Melee) then returnText = color .. (decimals):format(dmgMod) end
	if Ns.Band(EB, Ranged) then returnText = rcolor .. (decimals):format(rdmgMod) end
	if Ns.Band(EB, Both) then returnText = color .. (decimals):format(dmgMod) .. "|r/" .. rcolor .. (decimals):format(rdmgMod) end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- DPS
function Ns.FunctionList.DPS(HUD, data, options, ...)

	local EB = options.Melee_Ranged
	local lowDmg, hiDmg, offlowDmg, offhiDmg = UnitDamage("player")
	local rangedSpeed, rlowDmg, rhiDmg = UnitRangedDamage("player")
	local meleeSpeed, meleeoffSpeed = UnitAttackSpeed("player")
	local mainDPS, rangedDPS = 0, 0
	local offDPS = 0
	local separator = ""
	local returnText

	if meleeSpeed == nil then meleeSpeed = 0
	elseif meleeSpeed > 0 then
		hiDmg = hiDmg + (hiDmg * Ns.mysticTouch) + (hiDmg * Ns.colossusSmash) + (hiDmg * Ns.razorIce) + (hiDmg * Ns.felSunder) + (hiDmg * Ns.jadeFire) +
					(hiDmg * Ns.serenity) + (hiDmg * Ns.luckOfDraw) + (hiDmg * Ns.brittle) + (hiDmg * (Ns.finalReck/100)) + (hiDmg * Ns.seethChaos) +
					(hiDmg * Ns.ebonMight) + (hiDmg * (Ns.feralSpirit/100)) + (hiDmg * Ns.ghostlyStrike) + (hiDmg * Ns.huntersMark)
		lowDmg = lowDmg + (lowDmg * Ns.mysticTouch) + (lowDmg * Ns.colossusSmash) + (lowDmg * Ns.razorIce) + (lowDmg * Ns.felSunder) + (lowDmg * Ns.jadeFire) +
					(lowDmg * Ns.serenity) + (lowDmg * Ns.luckOfDraw) + (lowDmg * Ns.brittle) + (lowDmg * (Ns.finalReck/100)) + (lowDmg * Ns.seethChaos) +
					(lowDmg * Ns.ebonMight) + (lowDmg * (Ns.feralSpirit/100)) + (lowDmg * Ns.ghostlyStrike) + (lowDmg * Ns.huntersMark)
		mainDPS = ((lowDmg + hiDmg) / 2) / meleeSpeed
	end

	if meleeoffSpeed == nil then meleeoffSpeed = 0
	elseif meleeoffSpeed > 0 then
		offhiDmg = offhiDmg + (offhiDmg * Ns.mysticTouch) + (offhiDmg * Ns.colossusSmash) + (offhiDmg * Ns.razorIce) + (offhiDmg * Ns.felSunder) + (offhiDmg * Ns.jadeFire) +
					(offhiDmg * Ns.serenity) + (offhiDmg * Ns.luckOfDraw) + (offhiDmg * Ns.brittle) + (offhiDmg * (Ns.finalReck/100)) + (offhiDmg * Ns.seethChaos) +
					(offhiDmg * Ns.ebonMight) + (offhiDmg * (Ns.feralSpirit/100)) + (offhiDmg * Ns.ghostlyStrike) + (offlowDmg * Ns.huntersMark)
		offlowDmg = offlowDmg + (offlowDmg * Ns.mysticTouch) + (offlowDmg * Ns.colossusSmash) + (offlowDmg * Ns.razorIce) + (offlowDmg * Ns.felSunder) + (offlowDmg * Ns.jadeFire) +
					(offlowDmg * Ns.serenity) + (offlowDmg * Ns.luckOfDraw) + (offlowDmg * Ns.brittle) + (offlowDmg * (Ns.finalReck/100)) + (offlowDmg * Ns.seethChaos) +
					(offlowDmg * Ns.ebonMight) + (offlowDmg * (Ns.feralSpirit/100) + (offlowDmg * Ns.ghostlyStrike) + (offlowDmg * Ns.huntersMark))
		offDPS = (((offlowDmg + offhiDmg) / 2) / meleeoffSpeed)
		separator = "/"
	end

	if rangedSpeed == nil or rangedSpeed == 0 then rangedSpeed = 0
	else
		rhiDmg = rhiDmg + (rhiDmg * Ns.mysticTouch) + (rhiDmg * Ns.colossusSmash) + (rhiDmg * Ns.razorIce) + (rhiDmg * Ns.felSunder) + (rhiDmg * Ns.jadeFire) +
						(rhiDmg * Ns.serenity) + (rhiDmg * Ns.luckOfDraw) + (rhiDmg * Ns.ebonMight) + (rhiDmg * (Ns.bestialWrath/100)) + (rhiDmg * (Ns.huntersMark))
		rlowDmg = rlowDmg + (rlowDmg * Ns.mysticTouch) + (rlowDmg * Ns.colossusSmash) + (rlowDmg * Ns.razorIce) + (rlowDmg * Ns.felSunder) + (rlowDmg * Ns.jadeFire) +
					(rlowDmg * Ns.serenity) + (rlowDmg * Ns.luckOfDraw) + (rlowDmg * Ns.ebonMight) + (rlowDmg * (Ns.bestialWrath/100)) + (rhiDmg * (Ns.huntersMark))
		rangedDPS = ((rlowDmg + rhiDmg) / 2) / rangedSpeed
	end

	if options.Decimals_Default == 0 then
		mainDPS = BreakUpLargeNumbers(mainDPS)
		offDPS = BreakUpLargeNumbers(offDPS)
		rangedDPS = BreakUpLargeNumbers(rangedDPS)
	elseif options.Decimals_Default == 1 then
		mainDPS = Ns.ShortNumbers(mainDPS, 0)
		offDPS = Ns.ShortNumbers(offDPS, 0)
		rangedDPS = Ns.ShortNumbers(rangedDPS, 0)
	elseif options.Decimals_Default == 2 then
		mainDPS = Ns.ShortNumbers(mainDPS, 1)
		offDPS = Ns.ShortNumbers(offDPS, 1)
		rangedDPS = Ns.ShortNumbers(rangedDPS, 1)
	else
		mainDPS = Ns.ShortNumbers(mainDPS, 2)
		offDPS = Ns.ShortNumbers(offDPS, 2)
		rangedDPS = Ns.ShortNumbers(rangedDPS, 2)
	end

	if options.Display_MainHand then offDPS = ""; separator = "" end
	if meleeoffSpeed == 0 then offDPS = "" end

	if Ns.Band(EB, Melee) then returnText = mainDPS .. separator .. offDPS end
	if Ns.Band(EB, Ranged) then returnText = rangedDPS end
	if Ns.Band(EB, Both) then returnText = mainDPS .. separator .. offDPS .. " (" .. rangedDPS .. ")" end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Weapon Speed
function Ns.FunctionList.weaponSpeed(HUD, data, options, ...)

	local EB = options.Melee_Ranged
	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	local rangedSpeed = UnitRangedDamage("player")
	local returnText, decimals

	if options.Decimals_WepSpeed == 0 then decimals = "%.0f"
	elseif options.Decimals_WepSpeed == 1 then decimals = "%.1f"
	elseif options.Decimals_WepSpeed == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if offSpeed == nil then offSpeed = ""
	else offSpeed = "/" .. (decimals):format(offSpeed) end

	if Ns.Band(EB, Melee) then returnText = (decimals):format(mainSpeed) .. offSpeed end
	if Ns.Band(EB, Ranged) then returnText = (decimals):format(rangedSpeed) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(mainSpeed) .. offSpeed .. "|r (" .. (decimals):format(rangedSpeed) .. ")" end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Energy Regen
function Ns.FunctionList.EnergyRegen(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local haste = GetHaste()
	local energyRegen = 0
	local returnText, decimals
	energyRegen = 10 + (haste * 0.1)

	if options.Decimals_Energy == 0 then decimals = "%.0f"
	elseif options.Decimals_Energy == 1 then decimals = "%.1f"
	elseif options.Decimals_Energy == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(energyRegen) end
	if Ns.Band(EB, Base) then returnText = (decimals):format(energyRegen) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(energyRegen) .. " (" .. (decimals):format(energyRegen) .. ")" end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Stamina
function Ns.FunctionList.Stamina(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local _, stat, _, negBuff = UnitStat("Player", 3)
	local debuffColor = ""
	local returnText

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if not stat then stat = 0 end

	if options.Decimals_Default == 0 then
		stat = BreakUpLargeNumbers(stat)
	elseif options.Decimals_Default == 1 then
		stat = Ns.ShortNumbers(stat, 0)
	elseif options.Decimals_Default == 2 then
		stat = Ns.ShortNumbers(stat, 1)
	else
		stat = Ns.ShortNumbers(stat, 2)
	end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. stat end
	if Ns.Band(EB, Base) then returnText = stat end
	if Ns.Band(EB, Both) then returnText = debuffColor .. stat .. "|r (" .. stat .. ")" end
	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Mitigation
function Ns.FunctionList.Mitigation(HUD, data, options, ...)

	local armor = select(2, UnitArmor("player"))
	local playerLvl = UnitLevel("player")
	local dr = C_PaperDollInfo.GetArmorEffectiveness(armor, playerLvl) * 100
	local vers = GetVersatilityBonus(31) + GetCombatRatingBonus(31)
	local exist = UnitExists("target")
	local decimals

	if exist then
		dr = C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(armor)
		if dr then dr = dr * 100 end
	end

	if dr == nil then dr = 0 end

	dr = dr + vers

	if options.Decimals_DR == 0 then decimals = "%.0f%%"
	elseif options.Decimals_DR == 1 then decimals = "%.1f%%"
	elseif options.Decimals_DR == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	HUD:UpdateText(data, (decimals):format(dr))
end

-- Armor
function Ns.FunctionList.Armor(HUD, data, options, ...)

	local _, armor, _, _, negBuff = UnitArmor("player")
	local debuffColor = ""
	local returnText

	if negBuff == nil then negBuff = 0 end
	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if armor == nil then armor = 0 end

	if options.Decimals_Default == 0 then
		returnText = BreakUpLargeNumbers(armor)
	elseif options.Decimals_Default == 1 then
		returnText = Ns.ShortNumbers(armor, 0)
	elseif options.Decimals_Default == 2 then
		returnText = Ns.ShortNumbers(armor, 1)
	else
		returnText = Ns.ShortNumbers(armor, 2)
	end

	HUD:UpdateText(data, debuffColor .. returnText)
end

-- Dodge
function Ns.FunctionList.Dodge(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local percent = GetDodgeChance()
	local rating = GetCombatRating(CR_DODGE)
	local returnText, decimals
	local capColor, endColor, rateColor = "", "", ""

	if returnText == nil then returnText = 0 end

	if options.Decimals_Dodge == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Dodge == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Dodge == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if percent >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(percent) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(percent) .. endColor .. " / " .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Parry
function Ns.FunctionList.Parry(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local percent = GetParryChance()
	local rating = GetCombatRating(CR_PARRY)
	local decimals, returnText
	local capColor, endColor, rateColor = "", "", ""

	if returnText == nil then returnText = 0 end

	if options.Decimals_Parry == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Parry == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Parry == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if percent >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(percent) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(percent) .. endColor .. " / " .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Block
function Ns.FunctionList.Block(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local percent = GetBlockChance()
	local rating = GetCombatRating(CR_BLOCK)
	local decimals, returnText
	local capColor, endColor, rateColor = "", "", ""

	if returnText == nil then returnText = 0 end

	if options.Decimals_Block == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Block == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Block == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if percent >= options.Cap_Percent then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if rating >= options.Cap_Rating then rateColor = Ns.greenText end

	if options.Cap_Percent == 0 then capColor = "" end
	if options.Cap_Rating == 0 then rateColor = "" end

	rating = BreakUpLargeNumbers(rating)

	if Ns.Band(EB, Percent) then returnText = capColor .. (decimals):format(percent) end
	if Ns.Band(EB, Rating) then returnText = rateColor .. rating end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(percent) .. endColor .. " / " .. rateColor .. rating .. endColor end

	HUD:UpdateText(data, returnText)
end

-- Absorb
function Ns.FunctionList.Absorb(HUD, data, options, ...)

	local absorb = UnitGetTotalAbsorbs("player")
	local returnText

	if absorb == nil then absorb = 0 end

	if options.Decimals_Default == 0 then
		returnText = BreakUpLargeNumbers(absorb)
	elseif options.Decimals_Default == 1 then
		returnText = Ns.ShortNumbers(absorb, 0)
	elseif options.Decimals_Default == 2 then
		returnText = Ns.ShortNumbers(absorb, 1)
	else
		returnText = Ns.ShortNumbers(absorb, 2)
	end

	HUD:UpdateText(data, returnText)
end

-- Stagger
function Ns.FunctionList.Stagger(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local stagger = C_PaperDollInfo.GetStaggerPercentage("player")
	local decimals

	if stagger == nil then stagger = 0 end

	if options.Decimals_Stagger == 0 then decimals = "%.0f%%"
	elseif options.Decimals_Stagger == 1 then decimals = "%.1f%%"
	elseif options.Decimals_Stagger == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	HUD:UpdateText(data, (decimals):format(stagger))
end
