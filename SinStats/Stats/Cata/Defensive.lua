local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Enhanced, Percentage, Chance, Complete = 1, 1, 1, 1
local Basic, Rating, Reduction = 2, 2, 2
local Both, Modifiers = 3, 3

----------------------------------
--		Text Return Formats		--
----------------------------------
--local Double_Rating_Format = { "%.1f", "%.0f", "%.1f (%.0f)", }

------------------------------
--		Global Updater		--
------------------------------

Ns.armorValue, Ns.armorDebuff, Ns.ohID = 0, 0, 0
Ns.dodgeChance, Ns.parryChance, Ns.blockChance, Ns.avoid, Ns.defAdjust, Ns.avoidBase = 0, 0, 0, 0, 0, 0

function Ns.DefenseUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then Ns.targetLevel = Ns.playerLevel + 3 end
	end

	-- Armor
	local _, effectiveArmor, _, _, negBuff = UnitArmor("player")
	Ns.armorValue = effectiveArmor
	Ns.armorDebuff = negBuff

	-- Block, Parry, Dodge
	Ns.blockChance = GetBlockChance()
	Ns.parryChance = GetParryChance()
	Ns.dodgeChance = GetDodgeChance()

	-- Avoidance / Crushing
	local ohID = GetInventoryItemID("player", 17)
	local classId, subId = 0, 0

	local miss = 5
	local parryBonus = GetCombatRatingBonus(CR_PARRY)

	if ohID == nil then  Ns.blockChance = 0 end

		Ns.avoid = (miss + Ns.dodgeChance + Ns.parryChance + Ns.blockChance) + Ns.quickness
		Ns.avoidBase = (miss + Ns.dodgeChance + Ns.parryChance + Ns.blockChance)
end
------------------------------------------------

-- Armor
function Ns.FunctionList.Armor(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText, decimals
	local debuffColor, endColor = "", ""

	if options.Dec_Def_Armor == 0 then decimals = "%.0f"
	elseif options.Dec_Def_Armor == 1 then decimals = "%.1f"
	elseif options.Dec_Def_Armor == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.armorDebuff < 0 then debuffColor = Ns.redText end
	if Ns.armorValue > options.Cap_Def_Armor then debuffColor = Ns.greenText end
	if debuffColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Enhanced) then returnText = debuffColor .. (decimals):format(Ns.armorValue) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(Ns.armorValue) end
	if Ns.Band(EB, Both) then returnText = debuffColor .. (decimals):format(Ns.armorValue) .. endColor .. "/" .. Ns.armorValue end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Effective HP
function Ns.FunctionList.EHP(HUD, data, options, ...)

	local maxHP = UnitHealthMax("player")
    local ehp = maxHP / (1 - (Ns.armorReduction))

	HUD:UpdateText(data, ("%.0f"):format(ehp))
end
------------------------------------------------

-- Resilience
function Ns.FunctionList.Resilience(HUD, data, options, ...)

	--local EB = options.Crit_Damage_Taken
	local returnText, decimals, dualdec

	local Resilience = GetCombatRatingBonus(15)
	local resiDamage = GetCombatRatingBonus(16)
	resiDamage = resiDamage + Resilience

	if options.Dec_Def_Res == 0 then decimals = "%.0f%%" ; dualdec = "%.0f"
	elseif options.Dec_Def_Res == 1 then decimals = "%.1f%%" ; dualdec = "%.1f"
	elseif options.Dec_Def_Res == 2 then decimals = "%.2f%%" ; dualdec = "%.2f"
	else decimals = "%.3f%%"; dualdec = "%.3f" end

	resiDamage = (decimals):format(resiDamage)

	HUD:UpdateText(data, resiDamage)
end
------------------------------------------------

-- Mitigation
function Ns.FunctionList.Mitigation(HUD, data, options, ...)

	local EB = options.Total_Modifiers
	local defStance, battleStance, bonus = 0, 0, 0
	local returnText, decimals
	local debuffColor = ""

	Ns.armorReduction = (Ns.armorValue/((88 * 2167.5) + Ns.armorValue - 158167.5))

	if Ns.targetLevel <= Ns.playerLevel then
		Ns.armorReduction = (PaperDollFrame_GetArmorReduction(Ns.armorValue, Ns.targetLevel) / 100) or 0
	end

	local mitBase = Ns.armorReduction

	if GetShapeshiftForm() == 2 and (Ns.classFilename == "WARRIOR") then defStance = 10
	elseif GetShapeshiftForm() == 1 and (Ns.classFilename == "WARRIOR") then battleStance = 5 end

	Ns.armorReduction = 1-(1-Ns.armorReduction) * (1-(Ns.divineProt/100)) * (1-(Ns.stoneForm/100)) * (1-(Ns.rockBiter/100)) 
	* (1-(Ns.inspiration/100)) * (1-(defStance/100)) * (1-(Ns.safeGuard/100)) * (1-(Ns.sancDmg/100)) * (1-(Ns.boneShield/100))
	* (1-(Ns.painSuppress/100)) * (1-(Ns.PrismaticCloak/100)) * (1-(Ns.bloodPresence/100)) * (1-(Ns.armyDead/100)) * (1-(Ns.iceFortitude/100))
	* (1-(Ns.scarletFever/100)) * (1-(Ns.naturalReaction/100)) * (1-(Ns.focusWill/100)) * (1-(Ns.powerBarrier/100)) * (1-(Ns.shadowForm/100))
	* (1-(Ns.dispDmg/100)) * (1-(Ns.DeadNerves/100)) * (1-(Ns.curseWeak/100)) * (1-(Ns.barkskin/100)) * (1-(Ns.vindication/100))
	* (1-(Ns.ardentDef/100)) * (1-(Ns.ancientKings/100)) * (1-(Ns.masteryDmg/100)) * (1-(Ns.shamRage/100)) * (1-(Ns.ancResolve/100))
	* (1-(Ns.ancFort/100)) * (1-(Ns.shieldWall/100)) * (1-(battleStance/100)) * (1-(Ns.moonDmg/100)) * (1-(Ns.survInstinct/100))
	* (1-(Ns.willNecro/100)) * (1-(Ns.BladeBarrier/100)) / (1-(Ns.deathWish/100)) / (1-(Ns.reckless/100))

	Ns.fullDR = Ns.armorReduction * 100

	bonus = Ns.divineProt + Ns.BladeBarrier + Ns.inspiration + battleStance +
	Ns.PrismaticCloak + Ns.bloodPresence + Ns.armyDead + Ns.painSuppress + Ns.shieldWall + Ns.iceFortitude +
	Ns.focusWill + Ns.powerBarrier + Ns.shadowForm + Ns.dispDmg + Ns.scarletFever +
	Ns.DeadNerves + Ns.curseWeak + Ns.sancDmg + Ns.vindication + Ns.ardentDef + Ns.ancientKings + Ns.stoneForm +
	Ns.rockBiter + Ns.masteryDmg + Ns.shamRage + Ns.ancResolve + Ns.ancFort + defStance + Ns.safeGuard -
	Ns.deathWish - Ns.reckless + Ns.moonDmg + Ns.naturalReaction + Ns.survInstinct + Ns.barkskin + Ns.boneShield +
	Ns.willNecro

	if Ns.fullDR >= options.Cap_Def_Mit then debuffColor = Ns.greenText end
	if Ns.fullDR < 0 then Ns.fullDR = 0; debuffColor = Ns.redText end

	if options.Dec_Def_Mit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Mit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Mit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Complete) then returnText = debuffColor .. (decimals):format(Ns.fullDR) end
	if Ns.Band(EB, Basic) then returnText = debuffColor .. (decimals):format(mitBase) end
	if Ns.Band(EB, Modifiers) then returnText = (decimals):format(bonus) end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Crit Immunity
function Ns.FunctionList.CritReceived(HUD, data, options, ...)

	local EB = options.Chance_Reduction
	local chanceGetCrit = 19
	local getCritLevel = (Ns.targetLevel - Ns.playerLevel) * 0.2
	local uncritCap = 5
	local critTakenCap = 5.6
	local debuffColor = ""
	local returnText, decimals, liveImmunity
	local warStance = 0
	if GetShapeshiftForm() == 2 and (Ns.classFilename == "WARRIOR") then warStance = Ns.BastionDefense end

	chanceGetCrit = (uncritCap + getCritLevel) - Ns.moltenArmor - Ns.metaCrit - Ns.sancCrit -
					warStance - Ns.ThickHide - Ns.barkCrit - Ns.impBlood

	if chanceGetCrit < 0 then chanceGetCrit = 0; debuffColor = Ns.greenText
	elseif chanceGetCrit <= 1.5 then debuffColor = Ns.orangeText
	else debuffColor = Ns.redText end

	critTakenCap = Ns.moltenArmor + Ns.metaCrit + Ns.sancCrit + warStance + Ns.ThickHide + Ns.barkCrit + Ns.impBlood

	if options.Dec_Def_Crit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Crit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Crit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveImmunity = " > " .. (decimals):format(Ns.critReceived)
	else liveImmunity = "" end

	if Ns.Band(EB, Chance) then returnText = debuffColor .. (decimals):format(chanceGetCrit) .. "|r" .. liveImmunity end
	if Ns.Band(EB, Reduction) then returnText = (decimals):format(critTakenCap) .. liveImmunity end
	if Ns.Band(EB, Both) then returnText = debuffColor .. (decimals):format(chanceGetCrit) .. " |r(" .. (decimals):format(critTakenCap) .. ")" .. liveImmunity end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Dodge
function Ns.FunctionList.Dodge(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local dodgeRating =	GetCombatRating(CR_DODGE)
	local returnText, decimals, liveDodge

	if options.Dec_Def_Dodge == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Dodge == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Dodge == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveDodge = " > " .. (decimals):format(Ns.totalDodge)
	else liveDodge = "" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(Ns.dodgeChance) .. liveDodge end
	if Ns.Band(EB, Rating) then returnText = dodgeRating .. liveDodge end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.dodgeChance) .. " (" .. dodgeRating .. ")" .. liveDodge end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Parry
function Ns.FunctionList.Parry(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local parryBonus = GetCombatRatingBonus(CR_PARRY)
	local parry = GetParryChance() + parryBonus
	local parryRating =	GetCombatRating(CR_PARRY)
	local returnText, decimals, liveParry

	if options.Dec_Def_Parry == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Parry == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Parry == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveParry = " > " .. (decimals):format(Ns.totalParry)
	else liveParry = "" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(parry) .. liveParry end
	if Ns.Band(EB, Rating) then returnText = parryRating .. liveParry end
	if Ns.Band(EB, Both) then returnText = (decimals):format(parry) .. " (" .. parryRating .. ")" .. liveParry end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Block
function Ns.FunctionList.Block(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local block = GetBlockChance()
	local blockRating =	GetCombatRating(CR_BLOCK)
	local blockDamage = GetShieldBlock()
	local returnText, decimals, liveBlock

	if options.Dec_Def_Block == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Block == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Block == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Block_Damage then block = blockDamage end

	if options.Display_Simulate then liveBlock = " > " .. (decimals):format(Ns.totalBlock)
	else liveBlock = "" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(block) .. liveBlock end
	if Ns.Band(EB, Rating) then returnText = blockRating .. liveBlock end
	if Ns.Band(EB, Both) then returnText = (decimals):format(block) .. " (" .. blockRating .. ")" .. liveBlock end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Avoidance
function Ns.FunctionList.Avoidance(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText, decimals
	local avoidColor, endColor = "", ""

	if Ns.avoid >= options.Cap_Def_Avo then avoidColor = Ns.greenText end
	if avoidColor ~= "" then endColor = "|r" end

	if options.Add_Block then
		Ns.avoid = Ns.avoid - Ns.blockChance
		Ns.avoidBase = Ns.avoidBase - Ns.blockChance
	end

	if options.Dec_Def_Avoidance == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Avoidance == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Avoidance == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Enhanced) then returnText = avoidColor .. (decimals):format(Ns.avoid) end
	if Ns.Band(EB, Basic) then returnText = avoidColor .. (decimals):format(Ns.avoidBase) end
	if Ns.Band(EB, Both) then returnText = avoidColor .. (decimals):format(Ns.avoid) .. endColor .. " (" .. avoidColor .. (decimals):format(Ns.avoidBase) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

