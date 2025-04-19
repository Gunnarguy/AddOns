local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Both, Enhanced, Base = 3, 1, 2

------------------------------
--		Global Updater		--
------------------------------
function Ns.DefenseUpdate()

 	Ns.targetLevel = Ns.playerLevel + 3
	if UnitCanAttack("player", "target") then
		Ns.targetLevel = UnitLevel("target")
		if Ns.targetLevel <= 0 then
			Ns.targetLevel = Ns.playerLevel + 3
		end
	end
	
end

-- Defense
function Ns.FunctionList.Defense(HUD, data, options, ...)

	local baseDefense = 0
	local bonusDefense = 0
	local DefGearIndex = 0		
	local DefGear = GetNumSkillLines()
	local DefHeader = nil
		
	for i = 1, DefGear do
		local DefName = select(1, GetSkillLineInfo(i))
		local headerCheck = select(2, GetSkillLineInfo(i))
		if headerCheck ~= nil and headerCheck then
			DefHeader = DefName;
		else
			if (DefHeader == Ns.headerLoc) and (DefName == Ns.defenseLoc) then
				DefGearIndex = i
				break
			end
		end	
	end
	if (DefGearIndex > 0) then
		baseDefense = select(4, GetSkillLineInfo(DefGearIndex))
		bonusDefense = select(6, GetSkillLineInfo(DefGearIndex))
	end

	HUD:UpdateText(data, format("%.0f", (baseDefense + bonusDefense)))
end	
------------------------------------------------

-- Armor
function Ns.FunctionList.Armor(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText
	local debuffColor = ""
	local _, effectiveArmor, _, _, negBuff = UnitArmor("player")
	
	if negBuff < 0 then
		debuffColor = Ns.redText
	end	
	
	if Ns.Band(EB, Enhanced) then
		returnText = debuffColor .. ("%.0f"):format(effectiveArmor)
	end
	if  Ns.Band(EB, Base) then
		returnText = ("%.0f"):format(effectiveArmor)
	end
	if  Ns.Band(EB, Both) then
		returnText = debuffColor .. ("%.0f"):format(effectiveArmor) .. " |r/ " .. effectiveArmor
	end	
	
	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Mitigation
function Ns.FunctionList.Mitigation(HUD, data, options, ...)

	local EB = options.Enhanced_Base
	local returnText
	local debuffColor = ""
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
	local armorReduction = effectiveArmor/((85 * Ns.targetLevel) + 400);
	armorReduction = 100 * (armorReduction/(armorReduction + 1));
	
	local mitBase = armorReduction
	armorReduction = armorReduction
	
	if GetShapeshiftForm() == 2 and (Ns.classFilename == "WARRIOR") then
		armorReduction = armorReduction + 10
	end
	
	if negBuff < 0 then
		debuffColor = Ns.redText
	end
	
	if Ns.Band(EB, Enhanced) then
		returnText = debuffColor ..  ("%.2f%%"):format(armorReduction)
	end
	if Ns.Band(EB, Base) then
		returnText = ("%.2f%%"):format(mitBase)
	end
	if Ns.Band(EB, Both) then
		returnText = debuffColor ..  ("%.2f%%"):format(armorReduction) .. " |r(" .. ("%.2f%%"):format(mitBase) .. ")"
	end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Dodge
function Ns.FunctionList.Dodge(HUD, data, options, ...)

	local dodgeChance = GetDodgeChance()
	
	HUD:UpdateText(data, ("%.2f%%"):format(dodgeChance))
end
------------------------------------------------

-- Parry
function Ns.FunctionList.Parry(HUD, data, options, ...)

	local parryChance = GetParryChance()
	
	HUD:UpdateText(data, ("%.2f%%"):format(parryChance))
end
------------------------------------------------

-- Block
function Ns.FunctionList.Block(HUD, data, options, ...)

	local blockChance = GetBlockChance()
	
	HUD:UpdateText(data, ("%.2f%%"):format(blockChance))
end
------------------------------------------------


