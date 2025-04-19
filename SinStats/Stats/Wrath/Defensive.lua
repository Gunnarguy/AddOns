local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Basic, Damage, DamageTaken, Percentage, Rating, MainHand, OffHand, World, Realm, Modifiers, Base = 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 3, 2
local SameLevel, BossLevel, Regen, Casting, Critical, CritDamage, Total, Max, Average, Auto, Chance, Reduction, Complete = 1, 2, 1, 2, 1, 2, 1, 1, 2, 3, 1, 2, 1

----------------------------------
--		Text Return Formats		--
----------------------------------
local Double_Rating_Format = { "%.1f", "%.0f", "%.1f (%.0f)", }

------------------------------
--		Global Updater		--
------------------------------

Ns.armorValue, Ns.armorDebuff, Ns.Resilvalue, Ns.ohID = 0, 0, 0, 0
Ns.dodgeChance, Ns.parryChance, Ns.blockChance, Ns.avoid, Ns.defAdjust, Ns.avoidBase = 0, 0, 0, 0, 0, 0
Ns.bossMiss = 0.956
if (Ns.classFilename == "DRUID") then Ns.bossMiss = 0.972 end

function Ns.DefenseUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then Ns.targetLevel = Ns.playerLevel + 3 end
	end

	-- Armor
	local _, effectiveArmor, _, _, negBuff = UnitArmor("player")
	Ns.armorValue = effectiveArmor
	Ns.armorDebuff = negBuff

	-- Resilience
	Ns.Resilvalue = GetCombatRatingBonus(15)

	-- Block, Parry, Dodge
	Ns.blockChance = GetBlockChance()
	Ns.parryChance = GetParryChance()
	Ns.dodgeChance = GetDodgeChance()

	-- Avoidance / Crushing
	local ohID = GetInventoryItemID("player", 17)
	local classId, subId = 0, 0
	--local bossSkillDiff = (Ns.targetLevel * 5) - Ns.baseDefense
	local skillDiff = (Ns.playerLevel * 5) - Ns.baseDefense
	local targetLvl = Ns.playerLevel + 3

	if UnitLevel("target") > Ns.playerLevel or UnitLevel("target") < 0 then
		skillDiff = targetLvl * 5 - Ns.baseDefense
	end
	Ns.avoidBlock = 0

	if ohID then
		classId = select(12, GetItemInfo(ohID))
		subId = select(13, GetItemInfo(ohID))
	end

	if classId == 4 and subId == 6 then
		Ns.avoidBlock = Ns.blockChance
	end

	Ns.defAdjust = (5 + (skillDiff) * 0.04)
	if Ns.gearDefense > 0 then
		Ns.avoid = (Ns.defAdjust + Ns.dodgeChance + Ns.parryChance + Ns.avoidBlock) + Ns.scorpidSting + Ns.insectSwarm + Ns.frigidDread	+ Ns.quickness + 1 / (0.0625 + Ns.bossMiss / (Ns.gearDefense * 0.04))
		Ns.avoidBase = (Ns.defAdjust + Ns.dodgeChance + Ns.parryChance + Ns.blockChance) + 1 / (0.0625 + Ns.bossMiss / (Ns.gearDefense * 0.04))
	else
		Ns.avoid = (Ns.defAdjust + Ns.dodgeChance + Ns.parryChance + Ns.avoidBlock) + Ns.scorpidSting + Ns.insectSwarm + Ns.frigidDread	+ Ns.quickness
		Ns.avoidBase = (Ns.defAdjust + Ns.dodgeChance + Ns.parryChance + Ns.blockChance)
	end
end

-- Defense
function Ns.FunctionList.DefenseStat(HUD, data, options, ...)

	local EB = options.Total_Rating
	--local statFormat = Double_Rating_Format[EB]
	local defenseDisplay = Ns.totalDefense
	local returnText, decimals
	local capColor, endColor = "", ""

	if options.Display_Basic then defenseDisplay = Ns.baseDefense end

	if defenseDisplay >= options.Cap_Def_Def then capColor = Ns.greenText end
	if capColor ~= "" then endColor = "|r" end

	if options.Dec_Def_Def == 0 then decimals = "%.0f"
	elseif options.Dec_Def_Def == 1 then decimals = "%.1f"
	elseif options.Dec_Def_Def == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if Ns.Band(EB, Total) then returnText = capColor .. (decimals):format(defenseDisplay) end
	if Ns.Band(EB, Rating) then returnText = ("%.0f"):format(Ns.defenseRating) end
	if Ns.Band(EB, Both) then returnText = capColor .. (decimals):format(defenseDisplay) .. endColor .. " (" .. ("%.0f"):format(Ns.defenseRating) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Stamina
function Ns.FunctionList.Stamina(HUD, data, options, ...)

	local _, stat, _, negBuff = UnitStat("Player", 3)
	local debuffColor = ""
	local decimals

	if options.Dec_Def_Stamina == 0 then decimals = "%.0f"
	elseif options.Dec_Def_Stamina == 1 then decimals = "%.1f"
	elseif options.Dec_Def_Stamina == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	if negBuff < 0 then debuffColor = "|cffC41E3A" end

	HUD:UpdateText(data, debuffColor .. (decimals):format(stat))
end

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
	local ehp, armorDR, otherDR = 0, 0, 0
	Ns.classDR = 1

	if Ns.classFilename == "WARRIOR" and GetShapeshiftForm() == 2 then
			Ns.classDR = (1 - 0.1)
	elseif Ns.classFilename == "DRUID" and GetShapeshiftForm() == 1 then
		Ns.classDR = (1 - (Ns.ProtectorPack) / 100)
	elseif Ns.classFilename == "PALADIN" then
		Ns.classDR = Ns.classDR * (1 - (Ns.ShieldTemplar) / 100)
	elseif Ns.classFilename == "DEATHKNIGHT" then
		if GetShapeshiftForm() == 2 then
			Ns.classDR = Ns.classDR * (1 - (8 + Ns.impFrostPresence * 2) / 100)
		end

		Ns.classDR = Ns.classDR * (1 - (Ns.bladeBarrier) / 100)
		Ns.classDR = Ns.classDR * (1 - Ns.armyDead / 100)
	end

	if Ns.targetLevel >= 60  then
		armorDR = Ns.armorValue / (Ns.armorValue + 400 + 85 * (Ns.targetLevel + 4.5 * (Ns.targetLevel - 59)))
	else
		armorDR = Ns.armorValue / (Ns.armorValue + 400 + 85 * Ns.targetLevel)
	end

	Ns.classDR = Ns.classDR * Ns.auraDR
	otherDR = Ns.classDR * Ns.buffDR
	ehp = math.floor((maxHP / (1 - armorDR)) / otherDR)

	HUD:UpdateText(data, ehp)
end
------------------------------------------------

-- Enemy Miss
function Ns.FunctionList.MobMiss(HUD, data, options, ...)

	local npcMiss = 0
	local decimals
	local baseMiss = 5 - (UnitLevel("player") * 5 - Ns.baseDefense) * 0.04

	if Ns.gearDefense > 0 then npcMiss = baseMiss + 1 / (0.0625 + Ns.bossMiss / (Ns.gearDefense * 0.04))
	else npcMiss = baseMiss end

	if options.Dec_Def_Miss == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Miss == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Miss == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	npcMiss = npcMiss * 100 / 100
	npcMiss = (decimals):format(npcMiss)

	HUD:UpdateText(data, npcMiss)
end
------------------------------------------------

-- Resilience
function Ns.FunctionList.Resilience(HUD, data, options, ...)

	local EB = options.Crit_Damage_Taken
	local returnText, decimals, dualdec

	local Resilience = GetCombatRatingBonus(15)
	local resiDamage = GetCombatRatingBonus(16)
	resiDamage = resiDamage + Resilience

	if options.Dec_Def_Res == 0 then decimals = "%.0f%%" ; dualdec = "%.0f"
	elseif options.Dec_Def_Res == 1 then decimals = "%.1f%%" ; dualdec = "%.1f"
	elseif options.Dec_Def_Res == 2 then decimals = "%.2f%%" ; dualdec = "%.2f"
	else decimals = "%.3f%%"; dualdec = "%.3f" end

	if Ns.Band(EB, Critical) then returnText = (decimals):format(Resilience) end
	if Ns.Band(EB, CritDamage) then returnText = (decimals):format(resiDamage) end
	if Ns.Band(EB, Both) then returnText = (dualdec):format(Resilience) .. "/" .. (decimals):format(resiDamage) end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Mitigation
function Ns.FunctionList.Mitigation(HUD, data, options, ...)

	local EB = options.Total_Modifiers
	local returnText, decimals
	local debuffColor = ""
	local armorReduction = (Ns.armorValue/(Ns.armorValue + 16635)) * 100

	local modifiers, bonus = 0, 0

	if Ns.targetLevel < 80 then armorReduction = (Ns.armorValue/(Ns.armorValue+400+85*((5.5 * Ns.targetLevel)-265.5))) * 100
	elseif Ns.targetLevel == 80 then armorReduction = Ns.armorValue/(Ns.armorValue + 15232.5) * 100 end

	local mitBase = armorReduction

	if GetShapeshiftForm() == 2 and (Ns.classFilename == "WARRIOR") then armorReduction = armorReduction + 10
	elseif GetShapeshiftForm() == 2 and (Ns.classFilename == "DEATHKNIGHT") then armorReduction = armorReduction + Ns.impFrostPresence end

	modifiers = (armorReduction - (armorReduction * (Ns.blessingSanc/100)) - (armorReduction * (Ns.rightFury/100)) - (armorReduction * (Ns.divineProt/100)) - (armorReduction * (Ns.ShieldTemplar/100)) -
				(armorReduction * (Ns.divinePlea/100)) - (armorReduction * (Ns.renewedHope/100)) - (armorReduction * (Ns.bladeBarrier/100)) - (armorReduction * (Ns.runeInvicibility/100)) -
				(armorReduction * (Ns.ancestralHealing/100)) - (armorReduction * (Ns.inspiration/100)) - (armorReduction * (Ns.shamanRage/100)) - (armorReduction * (Ns.MoltenSkin/100)) -
				(armorReduction * (Ns.PrismaticCloak/100)) - (armorReduction * (Ns.frostPresence/100)) - (armorReduction * (Ns.armyDead/100)) - (armorReduction * (Ns.iceFortitude/100)) -
				(armorReduction * (Ns.iceFortitude/100)) - (armorReduction * (Ns.valorousBonus/100)) - (armorReduction * (Ns.protectorPack/100)) - (armorReduction * (Ns.vigilance/100)) -
				(armorReduction * (Ns.lasherWeave/100)))

	armorReduction = modifiers + Ns.blessingSanc + Ns.divineProt + Ns.rightFury + Ns.ShieldTemplar + Ns.divinePlea +
					Ns.bladeBarrier + Ns.renewedHope + Ns.runeInvicibility + Ns.ancestralHealing + Ns.inspiration +
					Ns.shamanRage + Ns.MoltenSkin + Ns.PrismaticCloak + Ns.frostPresence + Ns.armyDead +
					Ns.iceFortitude + Ns.valorousBonus + Ns.protectorPack + Ns.vigilance + Ns.lasherWeave

	bonus = Ns.blessingSanc + Ns.divineProt + Ns.rightFury + Ns.ShieldTemplar + Ns.divinePlea +
			Ns.bladeBarrier + Ns.renewedHope + Ns.runeInvicibility + Ns.ancestralHealing + Ns.inspiration +
			Ns.shamanRage + Ns.MoltenSkin + Ns.PrismaticCloak + Ns.frostPresence + Ns.armyDead +
			Ns.iceFortitude + Ns.valorousBonus + Ns.protectorPack + Ns.vigilance + Ns.lasherWeave

	if Ns.armorDebuff < 0 then debuffColor = Ns.redText end

	if armorReduction >= options.Cap_Def_Mit then debuffColor = Ns.greenText
	elseif armorReduction < 0 then armorReduction = 0; debuffColor = Ns.redText end

	if armorReduction > 75 then armorReduction = 75 end

	if options.Dec_Def_Mit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Mit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Mit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Complete) then returnText = debuffColor ..  (decimals):format(armorReduction) end
	if Ns.Band(EB, Basic) then returnText = (decimals):format(mitBase) end
	if Ns.Band(EB, Modifiers) then returnText = (decimals):format(bonus) end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Hit reduction
function Ns.FunctionList.HitReduction(HUD, data, options, ...)

	local hitReduction = Ns.scorpidSting + Ns.insectSwarm + Ns.frigidDread	+ Ns.quickness + Ns.Resilvalue
	local decimals

	if options.Dec_Def_Hit == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Hit == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Hit == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	HUD:UpdateText(data, (decimals):format(hitReduction))
end
------------------------------------------------

-- Crit Immunity
function Ns.FunctionList.CritReceived(HUD, data, options, ...)

	local EB = options.Chance_Reduction
	local chanceGetCrit = 19
	local getCritLevel = (Ns.targetLevel - Ns.playerLevel) * 0.2 -- 0.2 / 0.4 / 0.6 
	--local getCritDefense = (Ns.totalDefense) * 0.04
	local uncritCap = 5
	local critTakenCap = 5.6
	local debuffColor = ""
	local returnText, decimals, liveImmunity
	local resilCrit = GetDodgeBlockParryChanceFromDefense()

	chanceGetCrit = (uncritCap + getCritLevel) - resilCrit - Ns.survFittest - Ns.Resilvalue - Ns.SleightTalent - Ns.moltenArmor - Ns.metaCrit

	if chanceGetCrit < 0 then chanceGetCrit = 0; debuffColor = Ns.greenText
	elseif chanceGetCrit <= 1.5 then debuffColor = Ns.orangeText
	else debuffColor = Ns.redText end

	critTakenCap = critTakenCap - chanceGetCrit

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
	local parryRating =	GetCombatRating(CR_PARRY)
	local returnText, decimals, liveParry

	if options.Dec_Def_Parry == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Parry == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Parry == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveParry = " > " .. (decimals):format(Ns.totalParry)
	else liveParry = "" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(Ns.parryChance) .. liveParry end
	if Ns.Band(EB, Rating) then returnText = parryRating .. liveParry end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.parryChance) .. " (" .. parryRating .. ")" .. liveParry end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Block
function Ns.FunctionList.Block(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local blockRating =	GetCombatRating(CR_BLOCK)
	local returnText, decimals, liveBlock

	if options.Dec_Def_Block == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Block == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Block == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if options.Display_Simulate then liveBlock = " > " .. (decimals):format(Ns.totalBlock)
	else liveBlock = "" end

	if Ns.Band(EB, Percentage) then returnText = (decimals):format(Ns.blockChance) .. liveBlock end
	if Ns.Band(EB, Rating) then returnText = blockRating .. liveBlock end
	if Ns.Band(EB, Both) then returnText = (decimals):format(Ns.blockChance) .. " (" .. blockRating .. ")" .. liveBlock end

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

-- Crushing
function Ns.FunctionList.Crushing(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText, decimals
	local crushColor, endColor = "", ""
	local targetCrushLevel = UnitLevel("target")

	if targetCrushLevel == 0 then targetCrushLevel = Ns.playerLevel + 4 end

	local crush = ((targetCrushLevel * 5) - Ns.totalDefense) * 2 - 15

	if crush <= 0 then crushColor = Ns.greenText; crush = 0
	else crushColor = "" end
	if crushColor ~= "" then endColor = "|r" end

	if options.Dec_Def_Crush == 0 then decimals = "%.0f%%"
	elseif options.Dec_Def_Crush == 1 then decimals = "%.1f%%"
	elseif options.Dec_Def_Crush == 2 then decimals = "%.2f%%"
	else decimals = "%.3f%%" end

	if Ns.Band(EB, Enhanced) then returnText = crushColor .. (decimals):format(crush) end
	if Ns.Band(EB, Basic) then returnText = crushColor .. (decimals):format(crush) end
	if Ns.Band(EB, Both) then returnText = crushColor .. (decimals):format(crush) .. endColor .. " (" .. crushColor .. (decimals):format(crush) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------
