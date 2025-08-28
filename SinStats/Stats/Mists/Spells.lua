local _, Ns = ...

------------------------------
--		Options Equates		--
------------------------------
local Enhanced, Percentage, SameLevel, Regen = 1, 1, 1, 1
local Basic, Rating, BossLevel, Casting = 2, 2, 2, 2
local Both = 3

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
	Ns.critSpellChance = Ns.critSpellChance + Ns.arcPotency + Ns.shadowandFlame

	-- Hit
	Ns.hitSpell = GetCombatRatingBonus(CR_HIT_SPELL)
	Ns.hitSpellRating = GetCombatRating(CR_HIT_SPELL)
	local hitMod = GetSpellHitModifier() or 0
	Ns.hitSpell = Ns.hitSpell + hitMod

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

	tempRegen = (Ns.dispRegen * 2)

	Ns.regenCasting = Ns.regenCasting + tempRegen + (Ns.innervate * 2)
	Ns.regenBase = Ns.regenBase + Ns.evoc + (Ns.innervate * 2) + (Ns.dispRegen * 2)

end
-------------------------------------------------

-- Healing
function Ns.FunctionList.Healing(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local heal = GetSpellBonusHealing()
	local healBase = heal
	local decimals
	local returnText

	heal = (heal + (heal * Ns.avenWrath) + (heal * Ns.divinity) + (heal * Ns.treeofLife) +
			(heal * Ns.archangel) + (heal * Ns.conviction) + (heal * Ns.SparkLife))

	if options.Dec_Spell_Healing == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Healing == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Healing == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(heal) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(healBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(heal) .. " (" .. (decimals):format(healBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Holy
function Ns.FunctionList.Holy(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local holy = GetSpellBonusDamage(2)
	local holyBase = holy
	local decimals, returnText

	holy = (holy + (holy * Ns.arcaneTactics) + (holy * Ns.feroInspiration) + (holy * Ns.masterPoisoner) + (holy * Ns.curseElements) +
			(holy * Ns.auraSpell) + (holy * Ns.conviction) + (holy * Ns.avenWrath) + (holy * Ns.earthMoon) +
			(holy * Ns.lightBreath))

	if options.Dec_Spell_Holy == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Holy == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Holy == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(holy) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(holyBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(holy) .. " (" .. (decimals):format(holyBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Nature
function Ns.FunctionList.Nature(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local nature = GetSpellBonusDamage(4)
	local natureBase = nature
	local decimals, returnText

	nature = (nature + (nature * Ns.arcaneTactics) + (nature * Ns.feroInspiration) + (nature * Ns.masterPoisoner) + (nature * Ns.curseElements) +
			(nature * Ns.auraSpell) + (nature * Ns.flameTongue) + (nature * Ns.elePrecision) + (nature * Ns.eleOath) +
			(nature * Ns.masterySpell) + (nature * Ns.flameTongueOH) + (nature * Ns.moonSpell) + (nature * Ns.earthMoon) + (nature * Ns.EarthMoonTalent) +
			(nature * Ns.owlFrenzy) + (nature * Ns.lightBreath))

	if options.Dec_Spell_Nature == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Nature == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Nature == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(nature) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(natureBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(nature) .. " (" .. (decimals):format(natureBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Shadow
function Ns.FunctionList.Shadow(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local shadow = GetSpellBonusDamage(6)
	local shadowBase = shadow
	local decimals, returnText

	shadow = (shadow + (shadow * Ns.arcaneTactics) + (shadow * Ns.feroInspiration) + (shadow * Ns.masterPoisoner) + (shadow * Ns.curseElements) +
			(shadow * Ns.deathEmbrace) + (shadow * Ns.metaDamage) + (shadow * Ns.soulFire) + (shadow * Ns.TwistedFaith) + (shadow * (Ns.shadowForm/100)) +
			(shadow * Ns.auraSpell) + (shadow * Ns.earthMoon) + (shadow * Ns.DemonicPact) + (shadow * Ns.lightBreath))

	if options.Dec_Spell_Shadow == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Shadow == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Shadow == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(shadow) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(shadowBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(shadow) .. " (" .. (decimals):format(shadowBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Fire
function Ns.FunctionList.Fire(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local fire = GetSpellBonusDamage(3)
	local fireBase = fire
	local decimals, returnText

	fire = (fire + (fire * Ns.invocation) + (fire * Ns.arcaneTactics) + (fire * Ns.arcanePower) + (fire * Ns.firePower) + (fire * Ns.moltenFury) +
			(fire * Ns.feroInspiration) + (fire * Ns.masterPoisoner) + (fire * Ns.curseElements) + (fire * Ns.metaDamage) + (fire * Ns.soulFire) +
			(fire * Ns.auraSpell) + (fire * Ns.flameTongue) + (fire * Ns.elePrecision) + (fire * Ns.eleOath) +
			(fire * Ns.masterySpell) + (fire * Ns.flameTongueOH) + (fire * Ns.earthMoon) + (fire * Ns.DemonicPact) + (fire * Ns.lightBreath))

	if options.Dec_Spell_Fire == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Fire == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Fire == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(fire) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(fireBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(fire) .. " (" .. (decimals):format(fireBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Frost
function Ns.FunctionList.Frost(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local frost = GetSpellBonusDamage(5)
	local frostBase = frost
	local decimals, returnText

	frost = (frost + (frost * Ns.invocation) + (frost * Ns.arcaneTactics) + (frost * Ns.arcanePower) + (frost * Ns.moltenFury) + (frost * Ns.feroInspiration)
			+ (frost * Ns.masterPoisoner) + (frost * Ns.curseElements) + (frost * Ns.auraSpell) + (frost * Ns.flameTongue)
			+ (frost * Ns.elePrecision) + (frost * Ns.eleOath) + (frost * Ns.masterySpell) + (frost * Ns.flameTongueOH) + (frost * Ns.earthMoon)
			+ (frost * Ns.lightBreath))

	if options.Dec_Spell_Frost == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Frost == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Frost == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(frost) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(frostBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(frost) .. " (" .. (decimals):format(frostBase) .. ")" end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Arcane
function Ns.FunctionList.Arcane(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local arcane = GetSpellBonusDamage(7)
	local arcaneBase = arcane
	local decimals, returnText

	arcane = (arcane + (arcane * Ns.invocation) + (arcane * Ns.arcaneTactics) + (arcane * Ns.arcanePower) + (arcane * Ns.moltenFury) + (arcane * Ns.feroInspiration)
			+ (arcane * Ns.masterPoisoner) + (arcane * Ns.curseElements) + (arcane * Ns.auraSpell) + (arcane * Ns.moonSpell)
			+ (arcane * Ns.eclipseLunar) + (arcane * Ns.earthMoon) + (arcane * Ns.EarthMoonTalent) + (arcane * Ns.owlFrenzy) + (arcane * Ns.lightBreath))

	if options.Dec_Spell_Arcane == 0 then decimals = "%.0f"
	elseif options.Dec_Spell_Arcane == 1 then decimals = "%.1f"
	elseif options.Dec_Spell_Arcane == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Enhanced) then returnText = (decimals):format(arcane) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(arcaneBase) end
	if Ns.Band(EB, Both) then returnText = (decimals):format(arcane) .. " (" .. (decimals):format(arcaneBase) .. ")" end
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

	if Ns.Band(EB, Percentage) then returnText = cc .. (decimals):format(Ns.critSpellChance) .. liveCrit end
	if Ns.Band(EB, Rating) then returnText = critSpellRating .. liveCrit end
	if Ns.Band(EB, Both) then  returnText = cc .. (decimals):format(Ns.critSpellChance) .. ec .. " (" .. critSpellRating .. ")" .. liveCrit end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critical vs Boss
function Ns.FunctionList.SpellCritBoss(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local levelDifference = 0
	local critAura = 2.1
	local decimals, returnText
	local cc = ""

	levelDifference = Ns.targetLevel - Ns.playerLevel
	if levelDifference <= 0 then
		levelDifference = 0
		critAura = 0
	elseif levelDifference >= 3 then
		critAura = 2.1
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

	if Ns.Band(EB, Enhanced) then returnText = cc .. (decimals):format(Ns.critSpellChance) end
	if Ns.Band(EB, Basic) then returnText = cc .. (decimals):format(Ns.critSpellBase) end
	if Ns.Band(EB, Both) then returnText = cc .. (decimals):format(Ns.critSpellChance) .. " (" .. (decimals):format(Ns.critSpellBase) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Haste
function Ns.FunctionList.HasteCaster(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local hasteRating = GetCombatRating(CR_HASTE_SPELL)
	local hasteBonus = UnitSpellHaste("player")
	local returnText, decimals

	if options.Display_Basic then hasteBonus = GetCombatRatingBonus(CR_HASTE_SPELL) or 0 end

	if options.Dec_Spell_Haste == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Haste == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Haste == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(hasteBonus) end
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
	--local returnText, decimals, liveMiss

	-- local missSameLevel = 3
	-- local missBossLevel = 17

	if Ns.hitSpell == nil then Ns.hitSpell = 0 end
	if Ns.hitSpellRating == nil then Ns.hitSpellRating = 0 end

	-- missSameLevel = (missSameLevel - Ns.hitSpell)
	-- missBossLevel = (missBossLevel - Ns.hitSpell)

	local miss, missBoss = 0, 0
	local baseMiss = PaperDollFrameUtil.Constants.BaseMissChanceSpell[0]
	local bossMiss = PaperDollFrameUtil.Constants.BaseMissChanceSpell[3]
	local returnText, decimals, liveMiss

	miss = baseMiss - Ns.hitSpell
	missBoss = bossMiss - Ns.hitSpell

	if Ns.targetLevel <= Ns.playerLevel then missBoss = baseMiss - Ns.hitSpell
	elseif Ns.targetLevel == (Ns.playerLevel + 1) then
		bossMiss = PaperDollFrameUtil.Constants.BaseMissChanceSpell[1]
		missBoss = bossMiss - Ns.hitSpell
	elseif Ns.targetLevel == (Ns.playerLevel + 2) then
		bossMiss = PaperDollFrameUtil.Constants.BaseMissChanceSpell[2]
		missBoss = bossMiss - Ns.hitSpell
	end

	if miss < 0 then miss = 0
	elseif miss > 100 then miss = 100 end

	if missBoss < 0 then missBoss = 0
	elseif missBoss > 100 then missBoss = 100 end

	if options.Dec_Spell_Miss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Spell_Miss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Spell_Miss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveMiss = " > " .. (decimals):format(Ns.spellMissTracker)
	else liveMiss = "" end

	if Ns.Band(EB, SameLevel) then returnText = (decimals):format(miss) .. liveMiss end
	if Ns.Band(EB, BossLevel) then returnText = (decimals):format(missBoss) .. liveMiss end
	if Ns.Band(EB, Both) then returnText = (decimals):format(miss) .. " (" .. (decimals):format(missBoss) .. ")" .. liveMiss end

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
