local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Enhanced = 1
local Base = 2
local Both = 3

----------------------------------
--		Text Return Formats		--
----------------------------------
local Double_Rating_Format = { "%.0f", "%.0f", "%.0f/%.0f", }

--------------------------
--		Physical		--
--------------------------

-- Intellect
function Ns.FunctionList.Intellect(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local _, stat, _, negBuff = UnitStat("Player", 4)
	local debuffColor = ""
	local returnText

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	if stat then
		if options.Decimals_Default == 0 then
			stat = BreakUpLargeNumbers(stat)
		elseif options.Decimals_Default == 1 then
			stat = Ns.ShortNumbers(stat, 0)
		elseif options.Decimals_Default == 2 then
			stat = Ns.ShortNumbers(stat, 1)
		else
			stat = Ns.ShortNumbers(stat, 2)
		end
	end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. stat end
	if Ns.Band(EB, Base) then returnText = stat end
	if Ns.Band(EB, Both) then returnText = debuffColor .. stat .. "|r/" .. stat end

	if returnText == nil then returnText = 0 end

	HUD:UpdateText(data, returnText)
end

-- Spell Power
function Ns.FunctionList.SpellPower(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local spellPower = 0
	local holySchool = GetSpellBonusDamage(2)
	local fireSchool = GetSpellBonusDamage(3)
	local natureSchool = GetSpellBonusDamage(4)
	local frostSchool = GetSpellBonusDamage(5)
	local shadowSchool = GetSpellBonusDamage(6)
	local arcaneSchool = GetSpellBonusDamage(7)
	local returnText

	spellPower = max(holySchool, fireSchool, natureSchool, frostSchool, shadowSchool, arcaneSchool)
	local basePower = spellPower
	spellPower = spellPower + (spellPower * Ns.shatteringStar) + (spellPower * Ns.chaosBrand) + (spellPower * Ns.felSunder) + (spellPower * Ns.serenity) +
				(spellPower * Ns.luckOfDraw) + (spellPower * Ns.shadowForm) + (spellPower * Ns.runePower) + (spellPower * (Ns.incanterFlow/100)) + (spellPower * (Ns.eradication/100)) +
				(spellPower * Ns.touchOfIce) + (spellPower * Ns.demonicSynergy) + (spellPower * (Ns.equilibrium/100)) + (spellPower * (Ns.InstinctArcana/100)) + (spellPower * (Ns.iridescence/100)) +
				(spellPower * Ns.ebonMight) + (spellPower * (Ns.friendFae/100)) + (spellPower * (Ns.wanTwilight/100)) + (spellPower * (Ns.huntersMark/100)) + (spellPower * (Ns.delver/100))

	if spellPower then
		if options.Decimals_Default == 0 then
			spellPower = BreakUpLargeNumbers(spellPower)
		elseif options.Decimals_Default == 1 then
			spellPower = Ns.ShortNumbers(spellPower, 0)
		elseif options.Decimals_Default == 2 then
			spellPower = Ns.ShortNumbers(spellPower, 1)
		else
			spellPower = Ns.ShortNumbers(spellPower, 2)
		end
	end

	if basePower then
		if options.Decimals_Default == 0 then
			basePower = BreakUpLargeNumbers(basePower)
		elseif options.Decimals_Default == 1 then
			basePower = Ns.ShortNumbers(basePower, 0)
		elseif options.Decimals_Default == 2 then
			basePower = Ns.ShortNumbers(basePower, 1)
		else
			basePower = Ns.ShortNumbers(basePower, 2)
		end
	end

	if Ns.Band(EB, Enhanced) then returnText = spellPower end
	if Ns.Band(EB, Base) then returnText = basePower end
	if Ns.Band(EB, Both) then returnText = spellPower .. "/" .. basePower end

	HUD:UpdateText(data, returnText)
end

-- Spell Damage
function Ns.FunctionList.DMGModSpell(HUD, data, options, ...)

	local spellMod = 0
	local verDamage = GetVersatilityBonus(29) + GetCombatRatingBonus(29)
	local spec = GetSpecialization()
	local mastery = 0
	local masteryFx = GetMasteryEffect()
	local color = ""
	local decimals

	if options.Decimals_DmgModSpell == 0 then decimals = "%.0f%%"
	elseif options.Decimals_DmgModSpell == 1 then decimals = "%.1f%%"
	elseif options.Decimals_DmgModSpell == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

		-- Mastery Effect
		if Ns.classId == 2 then -- paladin
			if (spec == 3) then mastery = masteryFx end
		elseif Ns.classId == 7 then -- shaman
			if (spec == 1) then mastery = masteryFx/3.351 end --3.3514517926155319148936170212766 coeff
			if (spec == 2) then mastery = masteryFx end
		elseif Ns.classId == 8 then -- mage
			if (spec == 1) then mastery = GetMastery() end
		elseif Ns.classId == 13 then -- evoker
			if (spec == 1) then mastery = GetMastery() end
		end

	spellMod = (Ns.shatteringStar * 100) + (Ns.chaosBrand * 100) + (Ns.felSunder * 100) + (Ns.serenity * 100) +
			   (Ns.luckOfDraw * 100) + verDamage + (Ns.shadowForm * 100) + (Ns.runePower * 100) + Ns.incanterFlow + Ns.tigersFury +
				Ns.eradication + (Ns.touchOfIce * 100) + (Ns.demonicSynergy * 100) + Ns.equilibrium + Ns.InstinctArcana + Ns.iridescence +
				Ns.arcaneSurge + Ns.enlightened + (Ns.ebonMight * 100) + Ns.friendFae + Ns.wanTwilight + Ns.retAura +
				Ns.huntersMark + mastery + Ns.delver + Ns.impetus
	spellMod = spellMod + 100

	if spellMod <= 0 then spellMod = 100 end
	if spellMod > 100 then color = Ns.greenText end

	HUD:UpdateText(data, color .. (decimals):format(spellMod))
end

-- Healing Power
function Ns.FunctionList.Healing(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local healPower = GetSpellBonusHealing()
	local baseHeal = healPower
	local returnText

	healPower = healPower + (healPower * Ns.serenity) + (healPower * Ns.luckOfDraw)

	if options.Decimals_Default == 0 then
		healPower = BreakUpLargeNumbers(healPower)
		baseHeal = BreakUpLargeNumbers(baseHeal)
	elseif options.Decimals_Default == 1 then
		healPower = Ns.ShortNumbers(healPower, 0)
		baseHeal = Ns.ShortNumbers(baseHeal, 0)
	elseif options.Decimals_Default == 2 then
		healPower = Ns.ShortNumbers(healPower, 1)
		baseHeal = Ns.ShortNumbers(baseHeal, 1)
	else
		healPower = Ns.ShortNumbers(healPower, 2)
		baseHeal = Ns.ShortNumbers(baseHeal, 2)
	end

	if Ns.Band(EB, Enhanced) then returnText = healPower end
	if Ns.Band(EB, Base) then returnText = baseHeal end
	if Ns.Band(EB, Both) then returnText = healPower .. "/" .. baseHeal end

	HUD:UpdateText(data, returnText)
end

-- Mana Regen
function Ns.FunctionList.ManaRegen(HUD, data, options, ...)

	local regen = GetManaRegen() or 0
	regen = regen * 5

	if options.Decimals_Default == 0 then
		regen = BreakUpLargeNumbers(regen)
	elseif options.Decimals_Default == 1 then
		regen = Ns.ShortNumbers(regen, 0)
	elseif options.Decimals_Default == 2 then
		regen = Ns.ShortNumbers(regen, 1)
	else
		regen = Ns.ShortNumbers(regen, 2)
	end

	HUD:UpdateText(data, regen)
end
