local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Basic, Damage, DamageTaken, Percentage, Rating, MainHand, OffHand, SameLevel, BossLevel, Regen, Casting, Critical, CritDamage, Total, Max, Average = 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2

------------------------------
--		Global Updater		--
------------------------------

Ns.critSpellChance, Ns.hitSpell, Ns.hitSpellRating, Ns.regenBase, Ns.regenCasting, Ns.critSpellBase, Ns.regenBaseBasic, Ns.regenCastingBasic  = 0, 0, 0, 0, 0, 0, 0, 0

function Ns.SpellUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then
		Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then
			Ns.targetLevel = Ns.playerLevel + 3
		end
	end

	-- Critical
	Ns.critSpellChance = 0
	Ns.critSpellBase = 0
	local holySchool = GetSpellCritChance(2) or 0
	local fireSchool = GetSpellCritChance(3) or 0
	local natureSchool = GetSpellCritChance(4) or 0
	local frostSchool = GetSpellCritChance(5) or 0
	local shadowSchool = GetSpellCritChance(6) or 0
	local arcaneSchool = GetSpellCritChance(7) or 0

	Ns.critSpellChance = max(holySchool, fireSchool, natureSchool, frostSchool, shadowSchool, arcaneSchool)
	Ns.critSpellBase = Ns.critSpellChance
	Ns.critSpellChance = Ns.critSpellChance + Ns.combustionCount + Ns.tidalMastery + Ns.starlight + Ns.masterImp +
						 Ns.masterSucc + Ns.totemWrath + Ns.innerFocus + Ns.heartCrusader + Ns.wintersChill +
						 Ns.impSorch + Ns.impShadowbolt + Ns.faerieCrit

	Ns.impDemonicTactics = Ns.critSpellChance * Ns.ImpDemonicTactics

	if Ns.faerieFireImp > Ns.misery then Ns.misery = 0 end

	-- Hit
	Ns.hitSpell = GetCombatRatingBonus(CR_HIT_SPELL)
	Ns.hitSpellRating = GetCombatRating(CR_HIT_SPELL)
	Ns.hitSpell = Ns.hitSpell + Ns.hitMod + Ns.elePrecision + Ns.balancePower + Ns.heroicPresence + Ns.arcaneFocus +
				  Ns.Suppression + Ns.virulence + Ns.misery + Ns.faerieFireImp

	-- MP2
	local notcasting = 0
	local tempRegen = 0
	Ns.regenBase, Ns.regenCasting = GetManaRegen()

	Ns.regenBase = Ns.regenBase * 2
	Ns.regenCasting = (Ns.regenCasting * 2)

	if Ns.regenBase == Ns.regenCasting then
		if notcasting then
			Ns.regenBase = notcasting
		end
	else
		notcasting = Ns.regenBase
	end

	Ns.regenBaseBasic = Ns.regenBase
	Ns.regenCastingBasic = Ns.regenCasting

	tempRegen = Ns.felEnergy + (Ns.epiphany * 0.4) + Ns.manaTide + ((Ns.aspectViper/3) * 2)

	Ns.regenCasting = Ns.regenCasting + tempRegen + (Ns.innervate * 2)
	Ns.regenBase = Ns.regenBase + Ns.felEnergy + Ns.evoc + (Ns.epiphany * 0.4) + Ns.manaTide + ((Ns.aspectViper/3) * 2) + (Ns.innervate * 2)

end
-------------------------------------------------

-- Healing
function Ns.FunctionList.Healing(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local healSpell = GetSpellBonusHealing()
	local healBase = healSpell
	local decimals
	local returnText

	healSpell = (healSpell + (healSpell * Ns.spiritualHealing) + (healSpell * Ns.avenWrath) + (healSpell * Ns.giftNature) +
				(healSpell * Ns.purification) + (healSpell * Ns.blessedResil) + (healSpell * Ns.divinity) + (healSpell * Ns.treeofLife) +
				(healSpell * Ns.FocusedPower))

	if options.Dec_Spell_Healing == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Healing == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Healing == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(healSpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(healBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(healSpell) .. " (" .. (decimals):format(healBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Holy
function Ns.FunctionList.Holy(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local holySpell = GetSpellBonusDamage(2)
	local holyBase = holySpell
	local decimals, returnText

	holySpell = (holySpell + (holySpell * Ns.vengBuff) + (holySpell * Ns.avenWrath) + (holySpell * Ns.zoneBuff) + (holySpell * Ns.crusadeTalent) +
	(holySpell * (Ns.masterFel / 100)) + (holySpell * Ns.curseElements) + (holySpell * Ns.ebonPlague) + (holySpell * Ns.earthMoon) +
	(holySpell * Ns.FocusedPower) + (holySpell * Ns.arcaneEmpowerment) + (holySpell * Ns.feroInspiration) + (holySpell * Ns.BeastSlaying) +
	(holySpell * Ns.trickTrade))

	if options.Dec_Spell_Holy == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Holy == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Holy == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(holySpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(holyBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(holySpell) .. " (" .. (decimals):format(holyBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Nature
function Ns.FunctionList.Nature(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local natureSpell = GetSpellBonusDamage(4)
	local natureBase = natureSpell
	local decimals, returnText

	natureSpell = (natureSpell + (natureSpell * Ns.stormStrike) + (natureSpell * Ns.zoneBuff) + (natureSpell * Ns.curseElements) +
	(natureSpell * Ns.ebonPlague) + (natureSpell * Ns.earthMoon) + (natureSpell * Ns.arcaneEmpowerment) + (natureSpell * Ns.feroInspiration) + 
	(natureSpell * Ns.BeastSlaying) + (natureSpell * Ns.trickTrade))

	if options.Dec_Spell_Nature == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Nature == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Nature == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(natureSpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(natureBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(natureSpell) .. " (" .. (decimals):format(natureBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Shadow
function Ns.FunctionList.Shadow(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local shadowSpell = GetSpellBonusDamage(6)
	local shadowBase = shadowSpell
	local decimals, returnText

	shadowSpell = (shadowSpell + (shadowSpell * Ns.DarkNessTalent) + (shadowSpell * Ns.dsSuc) + (shadowSpell * Ns.zoneBuff) +
	(shadowSpell * Ns.shadowFormDmg) + (shadowSpell * Ns.shadowWeaving) + (shadowSpell * Ns.curseElements) + (shadowSpell * Ns.shadowMastery) +
	(shadowSpell * (Ns.masterSucc / 100)) + (shadowSpell * (Ns.masterFel / 100)) + (shadowSpell * Ns.ebonPlague) + (shadowSpell * Ns.earthMoon) + (shadowSpell * Ns.FocusedPower) +
	(shadowSpell * Ns.arcaneEmpowerment) + (shadowSpell * Ns.feroInspiration) + (shadowSpell * Ns.BeastSlaying) + (shadowSpell * Ns.DemonicPact) + (shadowSpell * Ns.metaDamage) +
	(shadowSpell * Ns.trickTrade))

	if options.Dec_Spell_Shadow == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Shadow == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Shadow == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(shadowSpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(shadowBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(shadowSpell) .. " (" .. (decimals):format(shadowBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Fire
function Ns.FunctionList.Fire(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local fireSpell = GetSpellBonusDamage(3)
	local fireBase = fireSpell
	local decimals, returnText

	fireSpell = (fireSpell + (fireSpell * Ns.aiMod) + (fireSpell * Ns.zoneBuff) + (fireSpell * Ns.emberstorm) + (fireSpell * Ns.dsImp) + (fireSpell * Ns.playFire) +
	(fireSpell * Ns.arcanePower) + (fireSpell * Ns.curseElements) + (fireSpell * (Ns.masterImp / 100)) + (fireSpell * (Ns.masterFel / 100)) + (fireSpell * Ns.ebonPlague) +
	(fireSpell * Ns.earthMoon) + (fireSpell * Ns.moltenFury) + (fireSpell * Ns.arcaneEmpowerment) + (fireSpell * Ns.arcanePower) + (fireSpell * Ns.feroInspiration) +
	(fireSpell * Ns.BeastSlaying) + (fireSpell * Ns.DemonicPact) + (fireSpell * Ns.metaDamage) + (fireSpell * Ns.trickTrade))

	if options.Dec_Spell_Fire == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Fire == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Fire == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(fireSpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(fireBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(fireSpell) .. " (" .. (decimals):format(fireBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Frost
function Ns.FunctionList.Frost(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local frostSpell = GetSpellBonusDamage(5)
	local frostBase = frostSpell
	local decimals, returnText

	frostSpell = (frostSpell + (frostSpell * Ns.pierceMod) + (frostSpell * Ns.aiMod) + (frostSpell * Ns.zoneBuff) + (frostSpell * Ns.playFire) +
	(frostSpell * Ns.impFrostbolt) + (frostSpell * Ns.arcticWind) + (frostSpell * (Ns.masterFel / 100)) + (frostSpell * Ns.arcanePower) +
	(frostSpell * Ns.curseElements) + (frostSpell * Ns.ebonPlague) + (frostSpell * Ns.earthMoon) + (frostSpell * Ns.moltenFury) +
	(frostSpell * Ns.arcaneEmpowerment) + (frostSpell * Ns.arcanePower) + (frostSpell * Ns.feroInspiration) + (frostSpell * Ns.BeastSlaying) +
	(frostSpell * Ns.trickTrade))

	if options.Dec_Spell_Frost == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Frost == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Frost == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(frostSpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(frostBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(frostSpell) .. " (" .. (decimals):format(frostBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Arcane
function Ns.FunctionList.Arcane(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local arcaneSpell = GetSpellBonusDamage(7)
	local arcaneBase = arcaneSpell
	local decimals, returnText

	arcaneSpell = (arcaneSpell + (arcaneSpell * Ns.aiMod) + (arcaneSpell * Ns.arcanePower) + (arcaneSpell * Ns.playFire) + (arcaneSpell * Ns.zoneBuff) +
	(arcaneSpell * (Ns.masterFel / 100)) + (arcaneSpell * Ns.curseElements) + (arcaneSpell * Ns.ebonPlague) + (arcaneSpell * Ns.earthMoon) + (arcaneSpell * Ns.moltenFury) +
	(arcaneSpell * Ns.arcaneEmpowerment) + (arcaneSpell * Ns.arcanePower) + (arcaneSpell * Ns.feroInspiration) + (arcaneSpell * Ns.BeastSlaying) + 
	(arcaneSpell * Ns.trickTrade))

	if options.Dec_Spell_Arcane == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Arcane == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Arcane == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(arcaneSpell) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(arcaneBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(arcaneSpell) .. " (" .. (decimals):format(arcaneBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critical
function Ns.FunctionList.SpellCrit(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local critSpellRating = GetCombatRating(CR_CRIT_SPELL)
	local returnText, decimals, liveCrit
	local cc, ec = "", ""

	if options.Display_Basic then Ns.critSpellChance = Ns.critSpellBase end
	if options.Dec_Spell_Crit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Crit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Crit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveCrit = " > " .. (decimals):format(Ns.spellCrit)
	else liveCrit = "" end

	if Ns.critSpellChance >= options.Cap_Spell_Crit then cc = Ns.greenText end
	if cc ~= "" then ec = "|r" end

	if Ns.Band(EB, Percentage) then returnText = cc .. (decimals):format(Ns.critSpellChance) .. Ns.callofThunder .. Ns.devastation .. liveCrit end
	if Ns.Band(EB, Rating) then returnText = critSpellRating .. liveCrit end
	if Ns.Band(EB, Both) then  returnText = cc .. (decimals):format(Ns.critSpellChance) .. Ns.callofThunder .. Ns.devastation .. ec .. " (" .. critSpellRating .. ")" .. liveCrit end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critical vs Boss
function Ns.FunctionList.SpellCritBoss(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local levelDifference = 0
	local critAura = 1.8
	local decimals, returnText
	local cc = ""

	levelDifference = Ns.targetLevel - Ns.playerLevel
	if levelDifference <= 0 then
		levelDifference = 0
		critAura = 0
	elseif levelDifference >= 3 then
		critAura = 1.8
	end

	Ns.critSpellBase = Ns.critSpellBase - levelDifference - critAura
	Ns.critSpellChance = Ns.critSpellChance - levelDifference - critAura

	if Ns.critSpellChance < 0 then Ns.critSpellChance = 0 end
	if Ns.critSpellBase < 0 then Ns.critSpellBase = 0 end

	if options.Dec_Spell_Crit_Boss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Crit_Boss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Crit_Boss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.critSpellChance >= options.Cap_Spell_CritBoss then cc = Ns.greenText end

	if Ns.Band(EB, Enhanced) then returnText = cc .. (decimals):format(Ns.critSpellChance) .. Ns.callofThunder .. Ns.devastation end
	if Ns.Band(EB, Basic) then returnText = cc .. (decimals):format(Ns.critSpellBase) end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(Ns.critSpellChance) .. Ns.callofThunder .. Ns.devastation .. " (" .. (decimals):format(Ns.critSpellBase) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Haste
function Ns.FunctionList.HasteCaster(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local hasteRating = GetCombatRating(CR_HASTE_SPELL)
	local hasteBonus = GetRangedHaste()
	local returnText, decimals
	local hasteSpells, hasteTalents, speedMods, maelstrom = 0, 0, 0, ""

	hasteTalents = ((hasteBonus * Ns.earthMother/100) + Ns.earthMother) + ((hasteBonus * Ns.naturesGrace/100) + Ns.naturesGrace) + ((hasteBonus * Ns.CelestialFocus/100) + Ns.CelestialFocus) +
				   ((hasteBonus * Ns.NetherwindPresence/100) + Ns.NetherwindPresence) + ((hasteBonus * Ns.Enlightenment/100) + Ns.Enlightenment)
	hasteBonus = hasteBonus + hasteTalents

	hasteSpells =  ((hasteBonus * Ns.wrathAir/100) + Ns.wrathAir) + ((hasteBonus * Ns.eleMasteryHaste/100) + Ns.eleMasteryHaste) + ((hasteBonus * Ns.borrowedTime/100) + Ns.borrowedTime)

	if options.Add_Speed then speedMods = ((hasteBonus * Ns.castHaste/100) + Ns.castHaste) end

	hasteBonus = hasteBonus + hasteSpells + speedMods + Ns.stones

	if Ns.maelstromWeapon == 0 then maelstrom = ""  else maelstrom = " +" .. Ns.maelstromWeapon end

	if options.Display_Basic then hasteBonus = GetCombatRatingBonus(CR_HASTE_SPELL) or 0 end

	if options.Dec_Spell_Haste == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Haste == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Haste == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(hasteBonus) .. maelstrom end
	if Ns.Band(EB, Rating) then returnText = hasteRating end
	if Ns.Band(EB, Both) then returnText = (decimals):format(hasteBonus) .. " (" .. hasteRating .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Hit
function Ns.FunctionList.SpellHit(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local returnText
	local decimals
	local cc, ec = "", ""

	if Ns.hitSpell == nil then Ns.hitSpell = 0 end
	if Ns.hitSpellRating == nil then Ns.hitSpellRating = 0 end
	if Ns.hitSpell >= 17 then cc = Ns.greenText end

	if options.Dec_Spell_Hit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Hit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Hit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.hitSpell >= options.Cap_Spell_Hit then cc = Ns.greenText end
	if cc ~= "" then ec = "|r" end

	if Ns.Band(EB, Percentage) then returnText = cc .. (decimals):format(Ns.hitSpell) end
	if Ns.Band(EB, Rating) then returnText = Ns.hitSpellRating end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(Ns.hitSpell) .. ec .. " (" .. Ns.hitSpellRating .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Miss
function Ns.FunctionList.SpellMiss(HUD, data, options, ...)

	local EB = options.Level_Same_Boss
	local returnText, decimals, liveMiss

	local missSameLevel = 3
	local missBossLevel = 17

	if Ns.hitSpell == nil then Ns.hitSpell = 0 end
	if Ns.hitSpellRating == nil then Ns.hitSpellRating = 0 end

	missSameLevel = (missSameLevel - Ns.hitSpell)
	missBossLevel = (missBossLevel - Ns.hitSpell)

	if missSameLevel < 0 then missSameLevel = 0
	elseif missSameLevel > 100 then missSameLevel = 100 end
	if missBossLevel < 0 then missBossLevel = 0
	elseif missBossLevel > 100 then missBossLevel = 100 end

	if options.Dec_Spell_Miss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Miss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Miss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveMiss = " > " .. (decimals):format(Ns.spellMissTracker)
	else liveMiss = "" end

	if Ns.Band(EB, SameLevel) then returnText = (decimals):format(missSameLevel) .. liveMiss end
	if Ns.Band(EB, BossLevel) then returnText = (decimals):format(missBossLevel) .. liveMiss end
	if Ns.Band(EB, Both) then returnText = (decimals):format(missSameLevel) .. " (" .. (decimals):format(missBossLevel) .. ")" .. liveMiss end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- MP2
function Ns.FunctionList.ManaRegen(HUD, data, options, ...)

	local EB = options.Regen_Normal_Casting
	local returnText
	local decimals

	if options.Display_Basic then
		Ns.regenBase = Ns.regenBaseBasic
		Ns.regenCasting = Ns.regenCastingBasic
	end

	if options.Dec_Spell_MP2 == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_MP2 == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_MP2 == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Regen) then returnText = (decimals):format(Ns.regenBase) end
	if Ns.Band(EB, Casting) then returnText = (decimals):format(Ns.regenCasting) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.regenBase) .. " (" .. (decimals):format(Ns.regenCasting) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- MP5
function Ns.FunctionList.MP5(HUD, data, options, ...)

	local EB = options.Regen_Normal_Casting
	local returnText
	local decimals

	if options.Display_Basic then
		Ns.regenBase = Ns.regenBaseBasic
		Ns.regenCasting = Ns.regenCastingBasic
	end

	Ns.regenBase = (Ns.regenBase / 2) * 5
	Ns.regenCasting = (Ns.regenCasting / 2) * 5

	if options.Dec_Spell_MP5 == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_MP5 == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_MP5 == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Regen) then returnText = (decimals):format(Ns.regenBase) end
	if Ns.Band(EB, Casting) then returnText = (decimals):format(Ns.regenCasting) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.regenBase) .. " (" .. (decimals):format(Ns.regenCasting) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Spell Penetration
function Ns.FunctionList.SpellPenetration(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local spellPenetration = GetSpellPenetration()
	local returnText
	local decimals

	if options.Dec_Spell_Pen == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Pen == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Pen == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(spellPenetration) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(spellPenetration) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(spellPenetration) .. " (" .. (decimals):format(spellPenetration) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

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
