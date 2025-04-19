---@diagnostic disable: unbalanced-assignments
local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Base, SameLevel, BossLevel, Regen, Casting = 3, 1, 2, 1, 2, 1, 2

----------------------------------
--		Text Return Formats		--
----------------------------------
-- local Percent_Rating_Format = { "%.2f%%", "%.0f", "%.2f%% (%.0f)", }
-- local Haste_Format = { "%.2f%%", "%.0f", "%.2f%% (%.0f)", }
local Double_Rating_Format = { "%.0f", "%.0f", "%.0f (%.0f)", }
local Mana_Regen_Format = { "%.1f", "%.1f", "%.1f (%.1f)", }
local Double_Percent_Format = { "%.2f%%", "%.2f%%", "%.2f/%.2f%%", }

------------------------------
--		Global Updater		--
------------------------------

Ns.hitSpellChance, Ns.hitSpellGear, Ns.regenBase, Ns.regenCasting, Ns.regenBaseBasic, Ns.regenCastingBasic  = 0, 0, 0, 0, 0, 0
Ns.healSpell, Ns.holySpell, Ns.natureSpell, Ns.shadowSpell, Ns.fireSpell, Ns.frostSpell, Ns.arcaneSpell = 0, 0, 0, 0, 0, 0, 0


function Ns.SpellUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then
		Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then
			Ns.targetLevel = Ns.playerLevel + 3
		end
	end

	Ns.spirit = UnitStat("player", 5)

	-- Spell Power
	Ns.healSpell = GetSpellBonusHealing()
	Ns.holySpell = GetSpellBonusDamage(2)
	Ns.natureSpell = GetSpellBonusDamage(4)
	Ns.shadowSpell = GetSpellBonusDamage(6)
	Ns.fireSpell = GetSpellBonusDamage(3)
	Ns.frostSpell = GetSpellBonusDamage(5)
	Ns.arcaneSpell = GetSpellBonusDamage(7)
	Ns.healSpell = Ns.healSpell + (Ns.healSpell * Ns.spiritualHealing) + (Ns.healSpell * Ns.purification)
	Ns.holySpell = (Ns.holySpell + (Ns.holySpell * Ns.dmfbuff) + (Ns.holySpell * Ns.silithyst) + (Ns.holySpell * Ns.sancAura) + (Ns.holySpell * Ns.vengeance))
	Ns.natureSpell = (Ns.natureSpell + (Ns.natureSpell * Ns.dmfbuff) + (Ns.natureSpell * Ns.silithyst))
	Ns.shadowSpell = (Ns.shadowSpell + (Ns.shadowSpell * Ns.shadowMastery) + (Ns.shadowSpell * Ns.DarkNessTalent) + (Ns.shadowSpell * Ns.dsSuc) + (Ns.shadowSpell * Ns.dmfbuff) + (Ns.shadowSpell * Ns.silithyst) + (Ns.shadowSpell * Ns.shadowFormDmg))
	Ns.fireSpell = (Ns.fireSpell + (Ns.fireSpell * Ns.firepowerMod) + (Ns.fireSpell * Ns.aiMod) + (Ns.fireSpell * Ns.emberstorm) + (Ns.fireSpell * Ns.dsImp) + (Ns.fireSpell * Ns.dmfbuff) + (Ns.fireSpell * Ns.silithyst) + (Ns.fireSpell * Ns.arcanePower))
	Ns.frostSpell = (Ns.frostSpell + (Ns.frostSpell * Ns.pierceMod) + (Ns.frostSpell * Ns.aiMod) + (Ns.frostSpell * Ns.dmfbuff) + (Ns.frostSpell * Ns.silithyst) + (Ns.frostSpell * Ns.arcanePower))
	Ns.arcaneSpell = (Ns.arcaneSpell + (Ns.arcaneSpell * Ns.aiMod) + (Ns.arcaneSpell * Ns.dmfbuff) + (Ns.arcaneSpell * Ns.silithyst) + (Ns.arcaneSpell * Ns.arcanePower))

	-- Hit
	Ns.hitSpellChance = GetCombatRatingBonus(8)
	Ns.hitSpellGear = GetSpellHitModifier()

	if Ns.hitSpellChance == nil or Ns.hitSpellGear == nil then
		Ns.hitSpellChance = 0
		Ns.hitSpellGear = 0
	end

end
-------------------------------------------------

-- Critical
function Ns.FunctionList.SpellCrit(HUD, data, options, ...)

	local EB = options.Level_Same_Boss
	local critSpellChance = 0
	local holySchool = GetSpellCritChance(2)
	local fireSchool = GetSpellCritChance(3)
	local natureSchool = GetSpellCritChance(4)
	local frostSchool = GetSpellCritChance(5)
	local shadowSchool = GetSpellCritChance(6)
	local arcaneSchool = GetSpellCritChance(7)
	local levelDifference = 0
	local critAura = 1.8
	local returnText

	levelDifference = Ns.targetLevel - Ns.playerLevel
	if levelDifference <= 0 then
		levelDifference = 0
		critAura = 0
	elseif levelDifference >= 3 then
		critAura = 1.8
	end

	local spellCritTable = {holySchool, fireSchool, natureSchool, frostSchool, shadowSchool, arcaneSchool}
	table.sort(spellCritTable)
	critSpellChance = spellCritTable[#spellCritTable]
	critSpellChance = critSpellChance + Ns.combustionCount + Ns.arcaneMod + Ns.spellCritMod
	Ns.critSpellBoss = critSpellChance - levelDifference - critAura

	if Ns.Band(EB, SameLevel) then returnText = ("%.2f%%"):format(critSpellChance) end
	if Ns.Band(EB, BossLevel) then returnText = ("%.2f%%"):format(Ns.critSpellBoss) end
	if Ns.Band(EB, Both) then returnText = ("%.2f%%"):format(critSpellChance) .. " (" .. ("%.2f%%"):format(Ns.critSpellBoss) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Hit
function Ns.FunctionList.SpellHit(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText

	local baseHit = Ns.hitSpellChance + Ns.hitSpellGear
	Ns.hitSpellChance = Ns.hitSpellChance + Ns.hitMod + Ns.hitSpellGear

	if Ns.Band(EB, Enhanced) then returnText = ("%.2f%%"):format(Ns.hitSpellChance) .. Ns.labelHit end
	if Ns.Band(EB, Base) then returnText = ("%.2f%%"):format(baseHit) end
	if Ns.Band(EB, Both) then returnText = ("%.2f%%"):format(Ns.hitSpellChance) .. Ns.labelHit .. " (" .. ("%.2f%%"):format(baseHit) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Miss
function Ns.FunctionList.SpellMiss(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Level_Same_Boss
	local statFormat = Double_Percent_Format[EB]

	local missSameLevel = 3
	local missBossLevel = 16

	if Ns.hitSpellChance == nil then
		Ns.hitSpellChance = 0
	end
	if Ns.hitSpellRating == nil then
		Ns.hitSpellRating = 0
	end

	missSameLevel = (missSameLevel - Ns.hitSpellChance)
	missBossLevel = (missBossLevel - Ns.hitSpellChance)

	if missSameLevel < 0 then
		missSameLevel = 0
	elseif missSameLevel > 100 then
		missSameLevel = 100
	end
	if missBossLevel < 0 then
		missBossLevel = 0
	elseif missBossLevel > 100 then
		missBossLevel = 100
	end

	if Ns.Band(EB, SameLevel) then
		enhancedStat = missSameLevel
	end
	if  Ns.Band(EB, BossLevel) then
		baseStat = missBossLevel
	end

	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Healing
function Ns.FunctionList.Healing(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local healBase = GetSpellBonusHealing()

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.healSpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = healBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Holy
function Ns.FunctionList.Holy(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local holyBase = GetSpellBonusDamage(2)

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.holySpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = holyBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Nature
function Ns.FunctionList.Nature(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local natureBase = GetSpellBonusDamage(4)

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.natureSpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = natureBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Shadow
function Ns.FunctionList.Shadow(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local shadowBase = GetSpellBonusDamage(6)

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.shadowSpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = shadowBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Fire
function Ns.FunctionList.Fire(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local fireBase = GetSpellBonusDamage(3)

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.fireSpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = fireBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Frost
function Ns.FunctionList.Frost(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local frostBase = GetSpellBonusDamage(5)

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.frostSpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = frostBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Arcane
function Ns.FunctionList.Arcane(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Enhanced_Base
	local statFormat = Double_Rating_Format[EB]
	local arcaneBase = GetSpellBonusDamage(7)

	if Ns.Band(EB, Enhanced) then
		enhancedStat = Ns.arcaneSpell
	end
	if  Ns.Band(EB, Base) then
		baseStat = arcaneBase
	end
	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- Undead Spell Power
function Ns.FunctionList.SpellUD(HUD, data, options, ...)

	local undeadSpell = 0
	local cleansingSet = 0
	local udTrinket = 0
	local markTrinket = 0
	local mhEnchant = 0
	local ohEnchant = 0
	local glovesCheck = GetInventoryItemID("player", 10)
	local bracersCheck = GetInventoryItemID("player", 9)
	local chestCheck = GetInventoryItemID("player", 5)
	local trinketCheck = GetInventoryItemID("player", 13)
	local trinketCheck2 = GetInventoryItemID("player", 14)
	local _, _, _, mainHandEnchantID, _, _, _, offHandEnchantId  = GetWeaponEnchantInfo()

	if trinketCheck == 19812 or trinketCheck2 == 19812 then
		udTrinket = 48
	end
	if trinketCheck == 23207 or trinketCheck2 == 23207 then
		markTrinket = 85
	end

	if (mainHandEnchantID == 2685) then
		mhEnchant = 60
	end
	if (offHandEnchantId == 2685) then
		ohEnchant = 60
	end
	if glovesCheck == 23084 then
		cleansingSet = cleansingSet + 35
	end
	if bracersCheck == 23091 then
		cleansingSet = cleansingSet + 26
	end
	if chestCheck == 23085 then
		cleansingSet = cleansingSet + 48
	end

	local spellTable = {Ns.frostSpell, Ns.fireSpell, Ns.arcaneSpell, Ns.shadowSpell, Ns.natureSpell, Ns.holySpell}
	table.sort(spellTable)
	undeadSpell = spellTable[#spellTable]
	undeadSpell = undeadSpell + udTrinket + markTrinket + mhEnchant + ohEnchant + cleansingSet

	HUD:UpdateText(data, undeadSpell)
end
------------------------------------------------

-- Haste
function Ns.FunctionList.HasteCaster(HUD, data, options, ...)

	HUD:UpdateText(data, Ns.castHaste .. "%")
end
------------------------------------------------

-- MP2
function Ns.FunctionList.ManaRegen(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Regen_Normal_Casting
	local statFormat = Mana_Regen_Format[EB]

	if Ns.Band(EB, Regen) then
		enhancedStat = Ns.totalMP2
	end
	if  Ns.Band(EB, Casting) then
		baseStat = Ns.castingMP2
	end

	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

-- MP5
function Ns.FunctionList.MP5(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Regen_Normal_Casting
	local statFormat = Mana_Regen_Format[EB]

	if Ns.Band(EB, Regen) then
		enhancedStat = Ns.totalMP5
	end
	if  Ns.Band(EB, Casting) then
		baseStat = Ns.castingMP5
	end

	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------
