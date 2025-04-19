local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Base, Damage, DamageTaken, Percentage, Rating, MainHand, OffHand, SameLevel, BossLevel, Regen, Casting, Critical, CritDamage, Total, Max, Average, Auto = 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 3
local Mood, Damage = 1, 2

----------------------------------
--		Text Return Formats		--
----------------------------------
local Percent_Rating_Format = { "%.2f%%", "%.0f", "%.2f%% (%.0f)", }
local Haste_Format = { "%.2f%%", "%.0f", "%.1f%% (%.0f)", }
local Miss_Chance_Format = { "%.2f%%", "%.2f%%", "%.2f/%.2f%%", }

------------------------------
--		Global Updater		--
------------------------------

-- Attack Power
function Ns.FunctionList.petAP(HUD, data, options, ...)

	local base, posBuff, negBuff = UnitAttackPower("pet")
	local attackPower = base + posBuff + negBuff
	local debuffColor = ""

	if negBuff < 0 then debuffColor = Ns.redText end

	HUD:UpdateText(data, debuffColor .. attackPower .. "|r")
end
------------------------------------------------

-- Damage
function Ns.FunctionList.petDMG(HUD, data, options, ...)

	local EB = options.Max_Average_Damage
	local lowDmg, hiDmg, _, _, _, negBuff, _ = UnitDamage("pet")
	local maxDamage = hiDmg
	local lowDamage = lowDmg
	local avgDamage = (maxDamage + lowDamage) / 2
	local debuffColor = ""
	local returnText

	if negBuff < 0 then debuffColor = Ns.redText end

	if Ns.Band(EB, Max) then returnText = math.floor(maxDamage+1) end
	if  Ns.Band(EB, Average) then
        returnText = returnText and (returnText .. "/") or ""
		returnText = returnText .. math.floor(avgDamage+1)
	end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, debuffColor .. returnText)
end
------------------------------------------------

-- Spell power
function Ns.FunctionList.petSpell(HUD, data, options, ...)

	local spellPower = GetPetSpellBonusDamage()

	HUD:UpdateText(data, "+" .. spellPower)
end
------------------------------------------------

-- Critical
function Ns.FunctionList.petCrit(HUD, data, options, ...)

	local critChance = GetCritChanceFromAgility("pet")
	local spellCrit = GetSpellCritChanceFromIntellect("pet")

	critChance = math.max(critChance, spellCrit)

	HUD:UpdateText(data, ("%.2f%%"):format(critChance))
end
----------------------------------------------

-- Armor
function Ns.FunctionList.petArmor(HUD, data, options, ...)

	local _, effectiveArmor, _, _, negBuff = UnitArmor("pet")
	local debuffColor = ""

	if negBuff < 0 then debuffColor = Ns.redText end

	HUD:UpdateText(data, debuffColor .. effectiveArmor)
end
------------------------------------------------

-- DPS
function Ns.FunctionList.petDPS(HUD, data, options, ...)

	local lowDmg, hiDmg = UnitDamage("pet")
	local mainSpeed = UnitAttackSpeed("pet")
	local maxDamage = hiDmg
	local lowDamage = lowDmg
	local DPS = 0

	if mainSpeed ~= 0 then DPS = ((lowDamage + maxDamage) / 2) / mainSpeed end

	HUD:UpdateText(data, ("%.1f"):format(DPS))
end
------------------------------------------------

-- Attack Speed
function Ns.FunctionList.petAtkSpeed(HUD, data, options, ...)

	local mainSpeed = UnitAttackSpeed("pet")

	HUD:UpdateText(data, ("%.2f"):format(mainSpeed))
end
------------------------------------------------