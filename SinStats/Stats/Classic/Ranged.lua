---@diagnostic disable: unbalanced-assignments
local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, SameLevel, BossLevel, Max, Average = 3, 1, 2, 1, 2

----------------------------------
--		Text Return Formats		--
----------------------------------
local Double_Percent_Format = { "%.2f%%", "%.2f%%", "%.2f/%.2f%%", }

------------------------------
--		Global Updater		--
------------------------------

Ns.speed, Ns.lowDmg, Ns.hiDmg, Ns.critRanged, Ns.gunEquipped, Ns.hitRanged, Ns.posBuff, Ns.negBuff = 0, 0, 0, 0, 0, 0, 0, 0

function Ns.RangedUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then
		Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then
			Ns.targetLevel = Ns.playerLevel + 3
		end
	end

	-- Attack Speed
	Ns.speed, Ns.lowDmg, Ns.hiDmg, Ns.posBuff, Ns.negBuff = UnitRangedDamage("player")

end

-- Attack Power
function Ns.FunctionList.RAP(HUD, data, options, ...)

	local base, posBuff, negBuff = UnitRangedAttackPower("player");
	local baseRangedAP = base + posBuff + negBuff
	local rangedAttack = 0
	local BuffColor = ""
	local returnText

	rangedAttack = base + posBuff + negBuff + Ns.huntersMark + Ns.exposeWeakness

	if (Ns.huntersMark > 0) then
		BuffColor = Ns.greenText
	end
	if negBuff < 0 then
		BuffColor = Ns.redText
	end

	HUD:UpdateText(data, BuffColor .. rangedAttack)
end
------------------------------------------------

-- Attack Power vs Undead
function Ns.FunctionList.RAPUD(HUD, data, options, ...)

	local udTrinket = 0
	local markTrinket = 0
	local mhEnchant = 0
	local ohEnchant = 0
	local slayerSet = 0
	local trinketCheck = GetInventoryItemID("player", 13)
	local trinketCheck2 = GetInventoryItemID("player", 14)
	local glovesCheck = GetInventoryItemID("player", 10)
	local bracersCheck = GetInventoryItemID("player", 9)
	local chestCheck = GetInventoryItemID("player", 5)
	local _, _, _, mainHandEnchantID, _, _, _, offHandEnchantId  = GetWeaponEnchantInfo()
	if trinketCheck == 13209 or trinketCheck2 == 13209 then
		udTrinket = 81
	end
	if trinketCheck == 23206 or trinketCheck2 == 23206 then
		markTrinket = 150
	end
	if (mainHandEnchantID == 2684) then
		mhEnchant = 100
	end
	if (offHandEnchantId == 2684) then
		ohEnchant = 100
	end
	if glovesCheck == 23078 or glovesCheck == 23081 then
		slayerSet = slayerSet + 60
	end
	if bracersCheck == 23093 or bracersCheck == 23090 then
		slayerSet = slayerSet + 45
	end
	if chestCheck == 23087 or chestCheck == 23089 then
		slayerSet = slayerSet + 81
	end

	local base, posBuff, negBuff = UnitRangedAttackPower("player")
	local undeadrAP = base + posBuff + negBuff + mhEnchant + ohEnchant + udTrinket + markTrinket + slayerSet + Ns.huntersMark + Ns.exposeWeakness

	HUD:UpdateText(data, undeadrAP)
end
------------------------------------------------

-- Attack Speed
function Ns.FunctionList.rangedSpeed(HUD, data, options, ...)

	HUD:UpdateText(data, ("%.2f"):format(Ns.speed))
end
------------------------------------------------

-- Damage
function Ns.FunctionList.RDMG(HUD, data, options, ...)

	local EB = options.Max_Average_Damage
	local avgDamage = (Ns.hiDmg) / 2
	local returnText

	if Ns.Band(EB, Max) then
		returnText = math.floor(Ns.hiDmg+1)
	end
	if  Ns.Band(EB, Average) then
        returnText = returnText and (returnText .. "/") or ""
		returnText = returnText .. math.floor(avgDamage+1)
	end

	if returnText == nil then
		returnText = ""
	end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- DPS
function Ns.FunctionList.rDPS(HUD, data, options, ...)

	local EB = options.Max_Average_Damage
	local maxDamage = Ns.hiDmg
	local lowDamage = Ns.lowDmg
	local maxDPS = 0
	local avgDPS = 0
	local BuffColor = ""
	local returnText

	if Ns.speed ~= 0 then
		avgDPS = (maxDamage + lowDamage / 2) / Ns.speed
		maxDPS = (maxDamage / Ns.speed)
	end

	if Ns.negBuff < 0 then
		BuffColor = Ns.redText
	end

	if Ns.Band(EB, Max) then returnText = BuffColor .. ("%.1f"):format(maxDPS) end
	if Ns.Band(EB, Average) then
        returnText = returnText and (returnText .. "/") or ""
		returnText = returnText .. ("%.1f"):format(avgDPS)
	end
	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Critcal
function Ns.FunctionList.RangedCrit(HUD, data, options, ...)

	local EB = options.Level_Same_Boss
	local critRanged = GetRangedCritChance()
	local levelDifference = 0
	local critAura = 1.8
	local critBoss = critRanged
	local returnText
	levelDifference = Ns.targetLevel - Ns.playerLevel

	if levelDifference <= 0 then
		levelDifference = 0
		critAura = 0
	elseif levelDifference >= 3 then
		critAura = 1.8
	end

	critBoss = critBoss - levelDifference - critAura

	if Ns.Band(EB, SameLevel) then returnText = ("%.2f%%"):format(critRanged) end
	if Ns.Band(EB, BossLevel) then returnText = ("%.2f%%"):format(critBoss) end
	if Ns.Band(EB, Both) then returnText = ("%.2f%%"):format(critRanged) .. " (" .. ("%.2f%%"):format(critBoss) .. ")" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Haste
function Ns.FunctionList.HasteRanged(HUD, data, options, ...)

	HUD:UpdateText(data, Ns.totalRangedHaste .. "%")
end
------------------------------------------------

-- Hit
function Ns.FunctionList.RangedHit(HUD, data, options, ...)

	local hitRangedChance = 0
	local returnText

	if (Ns.classFilename == "HUNTER") then
		local slotId = GetInventorySlotInfo("RangedSlot")
		local link = GetInventoryItemLink("player", slotId)
		if link then
			hitRangedChance = GetHitModifier()
			if hitRangedChance == nil then
				hitRangedChance = 0
			end
			local itemId, enchantId = link:match("item:(%d+):(%d+)")
			if enchantId then
				enchantId = tonumber(enchantId)
				if enchantId == 2523 then
					hitRangedChance = hitRangedChance + 3
				end
			end
		end
		hitRangedChance = (hitRangedChance and hitRangedChance)
	else
		hitRangedChance = GetHitModifier()
		if hitRangedChance == nil then hitRangedChance = 0 end
	end

	HUD:UpdateText(data, hitRangedChance .. "%")
end
------------------------------------------------

-- Miss
function Ns.FunctionList.RangedMiss(HUD, data, options, ...)

	local EB, enhancedStat, baseStat = options.Level_Same_Boss
	local statFormat = Double_Percent_Format[EB]

	local rangedMissLevel = 0
	local rangedMissBoss = 0
	local rangedAttackBase, rangedAttackMod = UnitRangedAttack("player")
	local levelDiffDef = Ns.targetLevel - Ns.playerLevel
	local levelDefense = Ns.playerLevel * 5
	local bossDefense = (Ns.playerLevel + levelDiffDef) * 5
	local rWeaponSkill = (rangedAttackBase + rangedAttackMod)
	local rangedSkillDiff = levelDefense - rWeaponSkill
	local rbossSkillDiff = bossDefense - rWeaponSkill

	if rangedSkillDiff > 10 then
		rangedMissLevel = (7 + ((rangedSkillDiff - 10) * 0.4))
		rangedMissLevel = rangedMissLevel - Ns.hitRanged
	elseif rangedSkillDiff <= 10 then
		rangedMissLevel = (5 + ((rangedSkillDiff) * 0.1))
		rangedMissLevel = rangedMissLevel - Ns.hitRanged
	end

	if rbossSkillDiff > 10 then
		rangedMissBoss = (7 + ((rbossSkillDiff - 10) * 0.4))
		rangedMissBoss = rangedMissBoss - Ns.hitRanged
	elseif rbossSkillDiff <= 10 then
		rangedMissBoss = (5 + ((rbossSkillDiff) * 0.1))
		rangedMissBoss = rangedMissBoss - Ns.hitRanged
	end

	if rangedMissLevel < 0 then
		rangedMissLevel = 0
	elseif rangedMissLevel > 100 then
		rangedMissLevel = 100
	end

	if rangedMissBoss < 0 then
		rangedMissBoss = 0
	elseif rangedMissBoss > 100 then
		rangedMissBoss = 100
	end

	if Ns.Band(EB, SameLevel) then
		enhancedStat = rangedMissLevel
	end
	if  Ns.Band(EB, BossLevel) then
		baseStat = rangedMissBoss
	end

	HUD:UpdateText(data, format(statFormat, enhancedStat and enhancedStat or baseStat, baseStat))
end
------------------------------------------------

