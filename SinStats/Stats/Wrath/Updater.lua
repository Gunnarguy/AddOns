local AddName, Ns = ...
local L = Ns.L

-- Init
local hitTimes, selfhitTimes, critTimes, spellhitTimes, spellcritTimes, swingMissed, swingParryDodge, swingCount, critCount, selfSpellhitTimes, spMissCount, rMissCount, parrydodgeCount = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
local dodgeCount, parryCount, blockCount, rangedcritTimes, rangedhitTimes = 0, 0, 0, 0, 0

----------------------------
-- Local Helper Functions --
----------------------------
function Ns.druidFormChk()
	if (Ns.classFilename == "DRUID") then
		local index = GetShapeshiftForm()
		if (index == 1) or (index == 3) then return true
		else return false end
	end
end

-- Target Armor
local function TargetArmor()
	Ns.targetArmor = 0
	local NPCguid = UnitGUID("target")
	if NPCguid ~= nil then
		local NPCtype, _, _, _, _, npc_id, _ = strsplit("-",NPCguid)
		npc_id = tonumber(npc_id)
			if NPCtype == "Creature" then
				if Ns.BossArmor[npc_id] then Ns.targetArmor = Ns.BossArmor[npc_id][1] end
			end
	end
end

-- Item level & Tier set
local function itemLevelCheck()
	Ns.averageiLvl = 0
	Ns.valorousSet = 0
	Ns.wrynnSet = 0
	Ns.wrynnSetArp = 0
	Ns.wrynnSetCrit = 0
	Ns.lashWeaveSet = 0
	Ns.lashWeave = false
	local mainHandEquipLoc, offHandEquipLoc
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
			local id = GetInventoryItemID("player", slot)
			if id then
				if (Ns.classFilename == "DEATHKNIGHT") then
					if id == 45335 or id == 45336 or id == 45337 or id == 45338 or id == 45339
					or id == 37735 or id == 46119 or id == 46120 or id == 46121 or id == 46122 then
						Ns.valorousSet = Ns.valorousSet + 1
					end
				elseif (Ns.classFilename == "WARRIOR") then
					if Ns.WrynnSet[id] then Ns.wrynnSet = Ns.wrynnSet + 1 end
					if Ns.wrynnSet > 1 then Ns.wrynnSetArp = 6; Ns.wrynnSetCrit = 2 end
				elseif (Ns.classFilename == "DRUID") then
					if Ns.LashweaveSet[id] then Ns.lashWeaveSet = Ns.lashWeaveSet + 1 end
					if Ns.lashWeaveSet > 3 then Ns.lashWeave = true end
				end
				local _, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(id)
				if itemLevel == nil then itemLevel = 0 end
				Ns.averageiLvl = Ns.averageiLvl + itemLevel
				if slot == INVSLOT_MAINHAND then mainHandEquipLoc = itemEquipLoc
				elseif slot == INVSLOT_OFFHAND then offHandEquipLoc = itemEquipLoc end
			end
		end
	end
	local invSlots
	if mainHandEquipLoc and offHandEquipLoc then invSlots = 17 else
		local equippedItemLoc = mainHandEquipLoc or offHandEquipLoc
		invSlots = ( equippedItemLoc == "INVTYPE_WEAPON" or equippedItemLoc == "INVTYPE_WEAPONMAINHAND" ) and 17 or 16
	end
	Ns.averageiLvl = (Ns.averageiLvl/invSlots)
end

-- Glyph Info
local function checkGlyphs()
Ns.glyphHuntersMark = 0
Ns.glyphDivinePlea = 0
Ns.glyphIcebound = 0
Ns.glyphManaTide = false
	for i = 1, 6 do
		local enabled, _, _, glyphSpellID, _ = GetGlyphSocketInfo(i)
			if enabled then local link = GetGlyphLink(i)
				if link ~= "" then
					if glyphSpellID == 237652 then Ns.glyphHuntersMark = 0.2
					elseif glyphSpellID == 237632 then Ns.glyphDivinePlea = 3
					elseif glyphSpellID == 237651 then Ns.glyphIcebound = 40
					elseif glyphSpellID == 237644 then Ns.glyphManaTide = true
					else Ns.glyphHuntersMark = 0; Ns.glyphDivinePlea = 0; Ns.glyphIcebound = 0; Ns.glyphManaTide = false end
				end
			end
	end
end

-- Item Score
local function itemScore(ItemLink)
    local QualityScale, PVPScale, PVPScore, GearScore = 1, 1, 0, 0
    if not ItemLink then return 0, 0 end

    local _, _, ItemRarity, ItemLevel, _, _, _, _, ItemEquipLoc = GetItemInfo(ItemLink)
    local Table = {}
    local Scale = 1.8618
    if ItemRarity == 5 then
        QualityScale = 1.3
        ItemRarity = 4
    elseif ItemRarity == 1 then
        QualityScale = 0.005
        ItemRarity = 2
    elseif ItemRarity == 0 then
        QualityScale = 0.005
        ItemRarity = 2
    end
    if ItemRarity == 7 then
        ItemRarity = 3
        ItemLevel = 187.05
    end

    if Ns.GearScoreItems[ItemEquipLoc] then
        if ItemLevel > 120 then
            Table = Ns.GearScoreModifiers["A"]
        else
            Table = Ns.GearScoreModifiers["B"]
        end 
        if (ItemRarity >= 2) and (ItemRarity <= 4)then
            local Red, Green, Blue = Ns.scoreRating((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * Scale)) * 11.25 )
            GearScore = floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * Ns.GearScoreItems[ItemEquipLoc].SlotMOD * Scale * QualityScale)
            if ItemLevel == 187.05 then
                ItemLevel = 0
            end
            if GearScore < 0 then
                GearScore = 0
              	Red, Green, Blue = Ns.scoreRating(1)
            end
            if PVPScale == 0.75 then
                PVPScore = 1
                GearScore = GearScore * 1
            else
                PVPScore = GearScore * 0
            end

            local percent = 1
            GearScore = floor(GearScore * percent)
            PVPScore = floor(PVPScore)
            return GearScore, ItemLevel, Ns.GearScoreItems[ItemEquipLoc].ItemSlot, Red, Green, Blue, PVPScore, ItemEquipLoc, percent
        end
    end
    return -1, ItemLevel, 50, 1, 1, 1, PVPScore, ItemEquipLoc, 1
end

-- Inventory score
function Ns.equippedScore()
    local gearScore, ItemScore, ItemLink = 0, 0
	local off2H = ""
	local ohID = GetInventoryItemID("player", 17)

	if ohID then off2H = select(9, GetItemInfo(ohID)) end

    for i = 1, 18 do
        if (i ~= 4) then
            ItemLink = GetInventoryItemLink("player", i)

            if ItemLink then
				local _, itemLink = GetItemInfo(ItemLink)
                ItemScore = itemScore(itemLink)
                if (i == 16 or i == 17) and (Ns.classFilename == "HUNTER") then
                    ItemScore = ItemScore * 0.3164
                end

                if (i == 18) and (Ns.classFilename == "HUNTER") then
                    ItemScore = ItemScore * 5.3224
                end
				if Ns.classFilename == "WARRIOR" and (off2H == "INVTYPE_2HWEAPON") then
					if i == 16 then
						ItemScore = ItemScore * 0.5
					end
					if i == 17 then
						ItemScore = ItemScore * 0.5
					end
				end

                gearScore = gearScore + ItemScore
            end
        end
    end

    if (gearScore <= 0) then gearScore = 0 end

    return math.floor(gearScore)
end

-- Score color
function Ns.scoreRating(ItemScore)
    if ItemScore > 5999 then ItemScore = 5999 end
    if not ItemScore then return 0, 0, 0 end

    for i = 0,6 do
        if (ItemScore > i * 1000) and (ItemScore <= (( i + 1) * 1000)) then
            local Red = Ns.GearScoreColor[(i + 1) * 1000].Red["A"] + (((ItemScore - Ns.GearScoreColor[(i + 1) * 1000].Red["B"])*Ns.GearScoreColor[(i + 1) * 1000].Red["C"])*Ns.GearScoreColor[(i + 1) * 1000].Red["D"])
            local Green = Ns.GearScoreColor[(i + 1) * 1000].Green["A"] + (((ItemScore - Ns.GearScoreColor[(i + 1) * 1000].Green["B"])*Ns.GearScoreColor[(i + 1) * 1000].Green["C"])*Ns.GearScoreColor[(i + 1) * 1000].Green["D"])
            local Blue = Ns.GearScoreColor[(i + 1) * 1000].Blue["A"] + (((ItemScore - Ns.GearScoreColor[(i + 1) * 1000].Blue["B"])*Ns.GearScoreColor[(i + 1) * 1000].Blue["C"])*Ns.GearScoreColor[(i + 1) * 1000].Blue["D"])
            return Red, Green, Blue
        end
    end
    return 0.1, 0.1, 0.1
end

-- SpellStones
local function spellStones()
	Ns.stones = 0
	if Ns.classFilename == "WARLOCK" then
		if Ns.playerLevel > 59 then
			local hasEnchant, _, _, enchantId = GetWeaponEnchantInfo()
			if hasEnchant and Ns.SpellStones[enchantId] then
				Ns.stones = Ns.SpellStones[enchantId][1] / Ns.levelRating[Ns.playerLevel][1]
			end
		else
			local hasEnchant, _, _, enchantId = GetWeaponEnchantInfo()
			if hasEnchant and Ns.SpellStones[enchantId] then
				Ns.stones = Ns.SpellStones[enchantId][1] / 10
			end
		end
	end
end

-- Number shorterner
function Ns.ShortNumbers(num, places)
    local ret
    local placeValue = ("%%.%df"):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000) .. "k"
    else
        ret = num
    end
    return ret
end

-- Stats computing
function Ns.StatsCompute()

	-- Init
	Ns.castHaste, Ns.meleeHaste = 0, 0
	Ns.buffCount, Ns.heroicPresence, Ns.zoneBuff, Ns.ancestralHealing, Ns.inspiration, Ns.rapidFire = 0, 0, 0, 0, 0, 0
	Ns.arcanePower, Ns.combustionCount, Ns.evoc, Ns.blessingSanc, Ns.rightFury, Ns.borrowedTime, Ns.wrathAir = 0, 0, 0, 0, 0, 0, 0
	Ns.masterImp, Ns.masterFel, Ns.masterSucc, Ns.dsSuc, Ns.dsImp, Ns.felEnergy, Ns.runeInvicibility, Ns.moltenArmor = 0, 0, 0, 0, 0, 0, 0, 0
	Ns.innervate, Ns.isShapeshift, Ns.treeofLife, Ns.bladeBarrier, Ns.renewedHope, Ns.windFury, Ns.berserkering = 0, false, 0, 0, 0, 0, 0
	Ns.aspectViper, Ns.icyTalons, Ns.vengStacks, Ns.vengBuff, Ns.avenWrath, Ns.epiphany, Ns.desolation, Ns.shamanRage = 0, 0, 0, 0, 0, 0, 0, 0
	Ns.shadowFormDmg, Ns.innerFocus, Ns.eleMasteryHaste, Ns.totemWrath, Ns.shadowWeaving, Ns.divineProt, Ns.armyDead, Ns.maelstromWeapon = 0, 0, 0, 0, 0, 0, 0, 0
	Ns.stanceArmorPen, Ns.berserker, Ns.arcaneEmpowerment, Ns.feroInspiration, Ns.naturesGrace, Ns.improvedMoonkin, Ns.talentCaster = 0, 0, 0, 0, 0, 0, nil
	Ns.swiftRetCheck, Ns.impMoonCheck, Ns.swiftRet, Ns.faerieCheck, Ns.hiddenHaste, Ns.metaDamage, Ns.metaCrit = false, false, 0, false, 0, 0, 0
	Ns.quickShots, Ns.frostPresence, Ns.iceFortitude, Ns.valorousBonus, Ns.protectorPack, Ns.vigilance, Ns.divinePlea, Ns.heroism = 0, 0, 0, 0, 0, 0, 0, 0
	Ns.bloodLust, Ns.buffDR, Ns.auraDR, Ns.lasherWeave = 0, 1, 1, 0
	local maxMana = 0

	for i = 1, 40 do
		local _, _, count, _, _, _, caster, _, _, spellId = UnitBuff("player",i, "HELPFUL")
		if not spellId then break end

		if spellId then Ns.buffCount = i end

		maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
		Ns.buffCount = Ns.buffCount
		if Ns.HeroicPresence[spellId] then Ns.heroicPresence = Ns.HeroicPresence[spellId][1] end
		if Ns.TotemOfWrath[spellId] then Ns.totemWrath = Ns.TotemOfWrath[spellId][1] end
		if Ns.InnervateEffect[spellId] then Ns.innervate = (maxMana * Ns.InnervateEffect[spellId][1]) / 10 end
		if Ns.OutlandsBuffs[spellId] then Ns.zoneBuff = Ns.OutlandsBuffs[spellId][1] end
		if Ns.BlessingOfSanc[spellId] then
			Ns.blessingSanc = Ns.BlessingOfSanc[spellId][1]
			Ns.buffDR = Ns.buffDR * (1 - Ns.blessingSanc)
		end
		if Ns.WindFuryTotem[spellId] then Ns.windFury = Ns.WindFuryTotem[spellId][1] + Ns.ImprovedWindfury end
		if Ns.RenewedHope[spellId] then Ns.renewedHope = Ns.RenewedHope[spellId][1] end
		if Ns.RuneInvicibility[spellId] then Ns.runeInvicibility = Ns.RuneInvicibility[spellId][1] end
		if Ns.AncestralHealing[spellId] then Ns.ancestralHealing = Ns.AncestralHealing[spellId][1] end
		if Ns.Inspiration[spellId] then Ns.inspiration = Ns.Inspiration[spellId][1] end
		if Ns.Flurry[spellId] then Ns.meleeHaste = Ns.meleeHaste + Ns.Flurry[spellId][1] end
		if Ns.PowerInfusion[spellId] then Ns.castHaste = Ns.castHaste + Ns.PowerInfusion[spellId][1] end
		if Ns.ArcaneEmpowerment[spellId] then Ns.arcaneEmpowerment = Ns.ArcaneEmpowerment[spellId][1] end
		if Ns.FerociousInspiration[spellId] then Ns.feroInspiration = Ns.FerociousInspiration[spellId][1] end
		if Ns.WrathOfAir[spellId] then Ns.wrathAir = Ns.WrathOfAir[spellId][1] end
		if Ns.Berserkering[spellId] then Ns.berserkering = Ns.Berserkering[spellId][1] end
		if Ns.Vigilance[spellId] then
			Ns.vigilance = Ns.Vigilance[spellId][1]
			Ns.buffDR = Ns.buffDR * (1 - Ns.vigilance)
		end
		if Ns.Heroism[spellId] then Ns.heroism = Ns.Heroism[spellId][1] end
		if Ns.BloodLust[spellId] then Ns.bloodLust = Ns.BloodLust[spellId][1] end
		if Ns.MoonkinAura[spellId] and caster ~= "player" and not Ns.swiftRetCheck then
			Ns.talentCaster = caster
			Ns.hiddenHaste = Ns.impMoon
			if GetTime() - Ns.throttleTime > Ns.inspectDelay then
				local inRange = CheckInteractDistance(caster, 1)
					if inRange then Ns.canInspect = CanInspect(caster)
						if Ns.canInspect then NotifyInspect(caster) end
						Ns.impMoonCheck = true
						Ns.throttleTime = GetTime()
					end
			end
		end
		if Ns.RetributionAura[spellId] and caster ~= "player" and not Ns.impMoonCheck then
			Ns.talentCaster = caster
			Ns.hiddenHaste = Ns.impRet
			if GetTime() - Ns.throttleTime > Ns.inspectDelay then
				local inRange = CheckInteractDistance(caster, 1)
					if inRange then Ns.canInspect = CanInspect(caster)
						if Ns.canInspect then NotifyInspect(caster) end
						Ns.swiftRetCheck = true
						Ns.throttleTime = GetTime()
					end
			end
		end

	-- Mage
	if (Ns.classFilename == "MAGE") then

		--maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
		if Ns.Combustion[spellId] then Ns.combustionCount = count * (Ns.Combustion[spellId][1]) end
		if Ns.IcyVeins[spellId] then Ns.castHaste = Ns.castHaste + (Ns.IcyVeins[spellId][1]) end
		if Ns.Combustion[spellId] then Ns.combustionCount = count * (Ns.Combustion[spellId][1]) end
		if Ns.Evocation[spellId] then Ns.evoc = maxMana * (Ns.Evocation[spellId][1] / 8) * 2 end
		if Ns.MoltenArmor[spellId] then Ns.moltenArmor = Ns.MoltenArmor[spellId][1] end
		if Ns.ArcanePower[spellId] then Ns.arcanePower = Ns.ArcanePower[spellId][1] end
	--

	-- Warlock
	elseif (Ns.classFilename == "WARLOCK") then

		--local maxpower = UnitPowerMax("player" , Enum.PowerType.Mana)
		if Ns.FelEnergy[spellId] then Ns.felEnergy = (maxMana * Ns.FelEnergy[spellId][1]) end
		if Ns.TouchOfShadow[spellId] then Ns.dsSuc = Ns.TouchOfShadow[spellId][1] end
		if Ns.BurningWish[spellId] then Ns.dsImp = Ns.BurningWish[spellId][1] end
		if Ns.MasterDemoImp[spellId] then Ns.masterImp = Ns.MasterDemoImp[spellId][1] end
		if Ns.MasterDemoSucc[spellId] then Ns.masterSucc = Ns.MasterDemoSucc[spellId][1] end
		if Ns.MasterDemoFel[spellId] then Ns.masterFel = Ns.MasterDemoFel[spellId][1] end
		if Ns.Eradication[spellId] then Ns.castHaste = Ns.castHaste + Ns.Eradication[spellId][1] end
		if Ns.Metamorphosis[spellId] then Ns.metaDamage = Ns.Metamorphosis[spellId][1]; Ns.metaCrit = Ns.Metamorphosis[spellId][2] end
	--	

	-- Druid
	elseif (Ns.classFilename == "DRUID") then

		if GetShapeshiftForm() == 1 or GetShapeshiftForm() == 3 then Ns.isShapeshift = true
		else Ns.isShapeshift = false end
		if Ns.TreeOfLife[spellId] then Ns.treeofLife = Ns.TreeOfLife[spellId][1] end
		if Ns.NaturesGrace[spellId] then Ns.naturesGrace = Ns.NaturesGrace[spellId][1] end
		if (Ns.ProtectorPack > 0 and GetShapeshiftForm() == 1) then Ns.protectorPack = Ns.ProtectorPack end
		if Ns.Moonkin[spellId] and Ns.ImprovedMoonkin > 0 then Ns.improvedMoonkin = Ns.ImprovedMoonkin end
		if Ns.swiftRetCheck then Ns.improvedMoonkin = 0 end
		if Ns.Enrage[spellId] and Ns.lashWeave then Ns.lasherWeave = 12 end

	--

	-- Hunter
	elseif (Ns.classFilename == "HUNTER") then

		--local playerMaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
		if Ns.AspectOfViper[spellId] then Ns.aspectViper = maxMana * Ns.AspectOfViper[spellId][1] end
		if Ns.RapidFire[spellId] then Ns.rapidFire = Ns.RapidFire[spellId][1] end
		if Ns.QuickShots[spellId] then Ns.quickShots = Ns.QuickShots[spellId][1] end
	--

	-- Paladin
	elseif (Ns.classFilename == "PALADIN") then

		if Ns.AvengingWrath[spellId] then Ns.avenWrath = Ns.AvengingWrath[spellId][1] end
		if Ns.DivineProtection[spellId] then Ns.divineProt = Ns.DivineProtection[spellId][1] end
		if (Ns.riFuryTalent > 0) and Ns.RighteousFury[spellId] then
			Ns.rightFury = Ns.riFuryTalent
			Ns.auraDR = Ns.auraDR * (1 - (Ns.riFuryTalent / 100))
		end
		if Ns.Vengeance[spellId] then Ns.vengStacks = count
			if Ns.vengeance == 3 and Ns.vengStacks > 0 then Ns.vengBuff = (Ns.vengStacks * Ns.vengeance) / 100
			elseif Ns.vengeance == 2 and Ns.vengStacks > 0 then Ns.vengBuff = (Ns.vengStacks * Ns.vengeance) / 100
			elseif Ns.vengeance == 1 and Ns.vengStacks > 0 then Ns.vengBuff = (Ns.vengStacks * Ns.vengeance) / 100
			else Ns.vengBuff = 0 end
		end
		if Ns.DivinePlea[spellId] then
			Ns.divinePlea = Ns.glyphDivinePlea
			if Ns.glyphDivinePlea > 0 then Ns.auraDR = Ns.auraDR * (1 - Ns.glyphDivinePlea / 100) end
		end
		if Ns.RetributionAura[spellId] and Ns.SwiftRetribution > 0 then Ns.swiftRet = Ns.SwiftRetribution end
		if Ns.impMoonCheck then Ns.swiftRet = 0 end
	--

	-- Priest
	elseif (Ns.classFilename == "PRIEST") then

		if Ns.InnerFocus[spellId] then Ns.innerFocus = Ns.InnerFocus[spellId][1] end
		if Ns.ShadowForm[spellId] then Ns.shadowFormDmg = Ns.ShadowForm[spellId][1] end
		if Ns.Epiphany[spellId] then Ns.epiphany = Ns.Epiphany[spellId][1] end
		if spellId == 15258 then Ns.shadowWeaving = count ; Ns.shadowWeaving = (Ns.shadowWeaving * 2) / 100 end
		if Ns.BorrowedTime[spellId] then Ns.borrowedTime = Ns.BorrowedTime[spellId][1] end
	--

	-- Shaman
	elseif (Ns.classFilename == "SHAMAN") then

		if Ns.ElementalMastery[spellId] then Ns.eleMasteryHaste = Ns.ElementalMastery[spellId][1] end
		if Ns.ShamanisticRage[spellId] then Ns.shamanRage = Ns.ShamanisticRage[spellId][1] end
		if Ns.MaelstromWeapon[spellId] then Ns.maelstromWeapon = Ns.MaelstromWeapon[spellId][1] end
	--

	-- Warrior
	elseif (Ns.classFilename == "WARRIOR") then

		if Ns.Berserker[spellId] then Ns.berserker = Ns.Berserker[spellId][1] end
	--

	-- Rogue
	-- elseif (Ns.classFilename == "ROGUE") then

	-- 	if Ns.SliceAndDice[spellId] then Ns.meleeHaste = Ns.meleeHaste + Ns.SliceAndDice[spellId][1] end
	-- 	if Ns.BladeFlurry[spellId] then Ns.bladeFlurry = Ns.BladeFlurry[spellId][1] end
	--

	-- Death Knight
	elseif (Ns.classFilename == "DEATHKNIGHT") then

		if Ns.IcyTalons[spellId] then Ns.icyTalons = Ns.icyTalons + Ns.IcyTalons[spellId][1] end
		if Ns.IcyTalonsImp[spellId] then Ns.icyTalons = Ns.IcyTalonsImp[spellId][1] end
		if Ns.Desolation[spellId] then Ns.desolation = Ns.Desolation[spellId][1] end
		if Ns.BladeBarrier[spellId] then Ns.bladeBarrier = Ns.BladeBarrier[spellId][1] end
		if Ns.ArmyofDead[spellId] then Ns.armyDead = Ns.ArmyofDead[spellId][1] + Ns.parryChance + Ns.dodgeChance end
		if Ns.FrostPresence[spellId] then Ns.frostPresence = Ns.FrostPresence[spellId][1] end
		if Ns.IceboundFort[spellId] then
			local DRFromIBF = 0.3 + 0.0015 * select(2, UnitDefense("player"))
			Ns.iceFortitude = Ns.IceboundFort[spellId][1] + (0.0015 * (Ns.totalDefense - 400))
			if (Ns.glyphIcebound == 40) then
				Ns.iceFortitude = Ns.glyphIcebound + (0.0015 * (Ns.totalDefense - 400))
				DRFromIBF = math.max(0.4, DRFromIBF)
			end
			Ns.auraDR = Ns.auraDR * (1 - DRFromIBF)
		end
		if (Ns.AntiMagic[spellId] and Ns.valorousSet >= 4) then Ns.valorousBonus = Ns.AntiMagic[spellId][1] end

	end -- end class checks
	end -- end loop player

	-- Defense
	Ns.baseDefense, Ns.gearDefense = UnitDefense("player")
	Ns.defenseBonus = GetCombatRatingBonus(CR_DEFENSE_SKILL)
	Ns.defenseRating = GetCombatRating(CR_DEFENSE_SKILL)
	Ns.totalDefense = 0
	local numberLines = GetNumSkillLines()
	local defGearBonus = 0


	if Ns.defenseBonus == nil then Ns.defenseBonus = 0 end
	if Ns.defenseRating == nil then Ns.defenseRating = 0 end

	for i = 1, numberLines do
		local skillName, header, _, _, _, skillModifier  = GetSkillLineInfo(i)

		if skillName == nil then break end
		if (not header) and (skillName == DEFENSE) then defGearBonus = skillModifier break end
	end
	Ns.totalDefense = Ns.defenseBonus + defGearBonus + Ns.baseDefense
	--
end

--------------------------------------
--		Global OnEvent function		--
--------------------------------------
function Ns.OnEventFunc(event, ...)

	if event == "GLYPH_ADDED" or event == "GLYPH_REMOVED" or event == "GLYPH_UPDATED" then
	-----
		checkGlyphs()
	-----
	elseif event == "PLAYER_TALENT_UPDATE" then
	-----
		Ns.talentScan()
		Ns.StatsCompute()
	-----
	elseif event == "UNIT_INVENTORY_CHANGED" then
	-----
		itemLevelCheck()
		spellStones()
	-----
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
	-----
	local _, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
	local spellID, amount, critical, missType, healCrit, spellCritical
	local playerGUID = UnitGUID("player")

	if (Ns.manaTideCheck[spellId]) and (destGUID == playerGUID) and not Ns.tideTimer then
		local TideMana = UnitPowerMax("player", Enum.PowerType.Mana)
		if Ns.glyphManaTide then Ns.manaTide = ((TideMana * 0.07) / 3) * 2
		else Ns.manaTide = ((TideMana * 0.06) / 3) * 2 end
		Ns.manaTide = Ns.manaTide
		Ns.tideTimer = true
		C_Timer.After(12, function()
			Ns.manaTide = 0
			Ns.tideTimer = false
		end)
	end

	if (Ns.TrickTrade[spellId]) and (destGUID == playerGUID) then
		Ns.trickTrade = Ns.TrickTrade[spellId][1]
	else
		Ns.trickTrade = 0
	end

	if subevent == "SWING_DAMAGE" then
		if sourceGUID == playerGUID then
			amount, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
			hitTimes = hitTimes + 1
			if critical then critTimes = critTimes + 1 end
			Ns.meleeCrit = ((critTimes + spellcritTimes) / (hitTimes + spellhitTimes) * 100)
			Ns.totalParryDodge = (parrydodgeCount / hitTimes) * 100
			Ns.meleeMissTracker = ((swingMissed + spMissCount) / (hitTimes + spellhitTimes)) * 100
		end
		if destGUID == playerGUID then
			amount, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
			selfhitTimes = selfhitTimes + 1
			if critical then critCount = critCount + 1 end
			Ns.critReceived = (critCount/selfhitTimes) * 100
			Ns.totalDodge = (dodgeCount/selfhitTimes) * 100
			Ns.totalParry = (parryCount/selfhitTimes) * 100
			Ns.totalBlock = (blockCount/selfhitTimes) * 100
		end

	elseif subevent == "SWING_MISSED" then
		if sourceGUID == playerGUID then
			missType = select(12, CombatLogGetCurrentEventInfo())
			hitTimes = hitTimes + 1
			Ns.meleeCrit = ((critTimes + spellcritTimes) / (hitTimes + spellhitTimes) * 100)
			swingMissed = swingMissed + 1
			Ns.meleeMissTracker = ((swingMissed + spMissCount) / (hitTimes + spellhitTimes)) * 100
			if missType == "PARRY" or missType == "DODGE" then parrydodgeCount = parrydodgeCount + 1 end
		end
		if destGUID == playerGUID then
			missType = select(12, CombatLogGetCurrentEventInfo())
			selfhitTimes = selfhitTimes + 1
			if missType == "DODGE" then dodgeCount = dodgeCount + 1 end
			if missType == "PARRY" then parryCount = parryCount + 1 end
			if missType == "BLOCK" then blockCount = blockCount + 1 end
		end

	elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_HEAL" then
		if sourceGUID == playerGUID then
			_, _, _, _, _, _, healCrit, _, _, spellCritical = select(12, CombatLogGetCurrentEventInfo())
			spellhitTimes = spellhitTimes + 1
		if spellCritical or healCrit then
			spellCritical = false
			healCrit = false
			spellcritTimes = spellcritTimes + 1
		end
			Ns.spellCrit = ((spellcritTimes / spellhitTimes) * 100)
			Ns.spellMissTracker = ((spMissCount / spellhitTimes) * 100)
			Ns.rangedCrit = ((rangedcritTimes + spellcritTimes) / (rangedhitTimes + spellhitTimes)) * 100
			Ns.rangedMissTracker = ((rMissCount + spMissCount) / (rangedhitTimes + spellhitTimes)) * 100
			Ns.meleeMissTracker = ((swingMissed + spMissCount) / (hitTimes + spellhitTimes)) * 100
		end

	elseif subevent == "SPELL_MISSED" and sourceGUID == playerGUID then
		spellhitTimes = spellhitTimes + 1
		spMissCount = spMissCount + 1
		Ns.rangedCrit = ((rangedcritTimes + spellcritTimes) / (rangedhitTimes + spellhitTimes)) * 100
		Ns.meleeMissTracker = ((swingMissed + spMissCount) / (hitTimes + spellhitTimes)) * 100
		Ns.spellMissTracker = ((spMissCount / spellhitTimes) * 100)
		Ns.rangedMissTracker = ((rMissCount + spMissCount) / (rangedhitTimes + spellhitTimes)) * 100

	elseif subevent == "RANGE_DAMAGE" and sourceGUID == playerGUID then
		_, _, _, _, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
		rangedhitTimes = rangedhitTimes + 1
		if critical then rangedcritTimes = rangedcritTimes + 1 end
		Ns.rangedCrit = ((rangedcritTimes + spellcritTimes) / (rangedhitTimes + spellhitTimes)) * 100
		Ns.rangedMissTracker = ((rMissCount + spMissCount) / (rangedhitTimes + spellhitTimes)) * 100

	elseif subevent == "RANGE_MISSED" and sourceGUID == playerGUID then
		rangedhitTimes = rangedhitTimes + 1
		rMissCount = rMissCount + 1
		Ns.rangedCrit = ((rangedcritTimes + spellcritTimes) / (rangedhitTimes + spellhitTimes)) * 100
		Ns.rangedMissTracker = ((rMissCount + spMissCount) / (rangedhitTimes + spellhitTimes)) * 100
	end
	-----
	elseif event == "PLAYER_REGEN_DISABLED" then
		hitTimes, selfhitTimes, critTimes, spellhitTimes, spellcritTimes, critCount, rMissCount, swingMissed = 1, 1, 0, 0, 0, 0, 0, 0
		swingParryDodge, parrydodgeCount, dodgeCount, parryCount, blockCount, spMissCount, rangedhitTimes, rangedcritTimes = 0, 0, 0, 0, 0, 0, 0, 0
		Ns.meleeCrit, Ns.spellCrit, Ns.meleeMissTracker, Ns.totalParryDodge, Ns.totalDodge = 0, 0, 0, 0, 0
		Ns.spellMissTracker, Ns.rangedMissTracker, Ns.totalParry, Ns.totalBlock, Ns.critReceived = 0, 0, 0, 0, 0
	-----
	elseif event == "PLAYER_LEVEL_UP" then
	-----	
		Ns.playerLevel = UnitLevel("player")
	-----	
	elseif event == "INSPECT_READY" then
	-----
	if Ns.impMoonCheck then
		Ns.impMoon = 0
		Ns.impMoon = select(5, GetTalentInfo(1,19, Ns.canInspect, Ns.talentCaster))
	end
	if Ns.swiftRetCheck then
		Ns.impRet = 0
		Ns.impRet = select(5, GetTalentInfo(3,22, Ns.canInspect, Ns.talentCaster))
	end
	if Ns.faerieCheck then
		Ns.faerieFireImp = 0
		Ns.faerieFireImp = select(5, GetTalentInfo(1,15, Ns.canInspect, Ns.talentCaster))
		local casterGUID = UnitGUID(Ns.talentCaster) or 0
		Ns.ImprovedFae[1] = Ns.talentCaster
		Ns.ImprovedFae[2] = Ns.faerieFireImp
		Ns.ImprovedFae[3] = casterGUID
	end
	-----	
	elseif event == "PLAYER_TARGET_CHANGED" then
	-----	
		local exists = UnitExists("target")
		local hostile = UnitCanAttack("player", "target")
		Ns.BeastSlaying = 0

		if hostile or not exists then Ns.SinLive() end
		if exists and Ns.raceId == 8 and UnitCreatureType("target") == "Beast" then Ns.BeastSlaying = 0.05 end

		TargetArmor()
	-----
	else
	-----	

	local unit = ...
	if unit == "target" then Ns.SinLive() return end
	if unit == "pet" and UnitCreatureFamily("pet") == "Imp" then
		for i = 1, 20 do
			local _, _, _, _, _, _, _, _, _, spellId = UnitAura("pet",i, "PLAYER")
			if not spellId then break end
			Ns.demonicEmp = 0
			if spellId == 54444 then Ns.demonicEmp = 20 end
		end
	end

	Ns.StatsCompute()

end -- end events
end -- end function
