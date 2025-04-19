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

-- Glyph Info
local function checkGlyphs()

Ns.glyphMastery = false
Ns.glyphWish = false

	for i = 1, 6 do
		local enabled, _, _, glyphSpellID, _ = GetGlyphSocketInfo(i)
			if enabled then local link = GetGlyphLink(i)
				if link ~= "" then
					if glyphSpellID == 54924 then Ns.glyphDivine = true
					elseif glyphSpellID == 94374 then Ns.glyphWish = true
					elseif glyphSpellID == 55452 then Ns.glyphMastery = true
					end
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

	Ns.buffCount, Ns.zoneBuff, Ns.buffDR, Ns.auraDR = 0, 0, 1, 1
	Ns.invocation, Ns.arcaneTactics, Ns.arcPotency, Ns.soulFire, Ns.archangel, Ns.painSuppress, Ns.focusWill = 0, 0, 0, 0, 0, 0, 0
	Ns.powerBarrier, Ns.shadowForm, Ns.dispDmg, Ns.dispRegen, Ns.arcanePower, Ns.evoc, Ns.ardentDef, Ns.ancientKings = 0, 0, 0, 0, 0, 0, 0, 0
	Ns.conviction, Ns.divineProt, Ns.avenWrath, Ns.stoneForm, Ns.flameTongue, Ns.rockBiter, Ns.eleOath = 0, 0, 0, 0, 0, 0, 0
	Ns.masterySpell, Ns.masteryDmg, Ns.flameTongueOH, Ns.shamRage, Ns.ancFort, Ns.safeGuard, Ns.shieldWall = 0, 0, 0, 0, 0, 0, 0
	Ns.deathWish, Ns.reckless, Ns.moonSpell, Ns.moonDmg, Ns.eclipseLunar, Ns.owlFrenzy, Ns.naturalReaction  = 0, 0, 0, 0, 0, 0, 0
	Ns.survInstinct, Ns.commuCheck, Ns.auraSpell, Ns.commEffect, Ns.feroInspiration = 0, false, 0, 0, 0
	Ns.barkCrit, Ns.barkskin, Ns.treeofLife, Ns.bloodPresence, Ns.boneShield, Ns.impBlood, Ns.willNecro = 0, 0, 0, 0, 0, 0, 0
	Ns.innervate, Ns.iceFortitude, Ns.metaDamage, Ns.metaCrit, Ns.armyDead, Ns.moltenArmor = 0, 0, 0, 0, 0, 0
	Ns.inspiration = 0
	local maxMana = 0

	for i = 1, 40 do
		local _, _, count, _, _, _, caster, _, _, spellId = UnitBuff("player",i, "HELPFUL")
		if not spellId then break end

		if spellId then Ns.buffCount = i end

		maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
		Ns.buffCount = Ns.buffCount

		if Ns.Innervate[spellId] then
			if caster == "player" then Ns.innervate = ((maxMana * Ns.Innervate[spellId][1]) / 10)
			else Ns.innervate = ((maxMana * Ns.Innervate[spellId][2]) / 10) end end

		if Ns.Stoneform[spellId] then Ns.stoneForm = Ns.Stoneform[spellId][1] end
		if Ns.FerociousInspiration[spellId] then Ns.feroInspiration = Ns.FerociousInspiration[spellId][1] end
		if Ns.PainSuppress[spellId] then Ns.painSuppress = Ns.PainSuppress[spellId][1] end
		if Ns.PowerBarrier[spellId] then Ns.powerBarrier = Ns.PowerBarrier[spellId][1] end
		if Ns.Inspiration[spellId] then Ns.inspiration = Ns.Inspiration[spellId][1] end
		if Ns.AncFortitude[spellId] then Ns.ancFort = Ns.AncFortitude[spellId][1] end
		if Ns.SafeGuard[spellId] then Ns.safeGuard = Ns.SafeGuard[spellId][1] end
		if Ns.OutlandsBuffs[spellId] then Ns.zoneBuff = Ns.OutlandsBuffs[spellId][1] end

	-- Mage
	if (Ns.classFilename == "MAGE") then

		if Ns.MoltenArmor[spellId] then Ns.moltenArmor = Ns.MoltenArmor[spellId][1] end
		if Ns.Invocation[spellId] then Ns.invocation = Ns.invoCount end
		if Ns.ArcaneTactics[spellId] then Ns.arcaneTactics = Ns.ArcaneTactics[spellId][1] end
		if Ns.ArcPotency[spellId] then Ns.arcPotency = count * 7.5 end
		if Ns.Evocation[spellId] then Ns.evoc = maxMana * (Ns.Evocation[spellId][1] / 5.07) * 2 end
		if Ns.ArcanePower[spellId] then Ns.arcanePower = Ns.ArcanePower[spellId][1] end
	--

	-- Warlock
	elseif (Ns.classFilename == "WARLOCK") then

		if Ns.Metamorphosis[spellId] then Ns.metaDamage = Ns.Metamorphosis[spellId][1]; Ns.metaCrit = Ns.Metamorphosis[spellId][2] end
		if Ns.SoulFire[spellId] then Ns.soulFire = Ns.ImpSoulFire end
	--	

	-- Druid
	elseif (Ns.classFilename == "DRUID") then

		if Ns.Moonkin[spellId] then Ns.moonSpell = Ns.Moonkin[spellId][1]; Ns.moonDmg = Ns.Moonkin[spellId][2] end
		if Ns.EclipseLunar[spellId] then Ns.eclipseLunar = Ns.EclipseLunar[spellId][1] end
		if Ns.OwlFrenzy[spellId] then Ns.owlFrenzy = Ns.OwlFrenzy[spellId][1] end
		if (Ns.NaturalReaction > 0) and GetShapeshiftForm() == 1 then Ns.naturalReaction = Ns.NaturalReaction end
		if Ns.SurvInstinct[spellId] then Ns.survInstinct = Ns.SurvInstinct[spellId][1] end
		if Ns.Barkskin[spellId] then Ns.barkskin = Ns.Barkskin[spellId][1] end
		if Ns.Amberskin[spellId] then Ns.barkCrit = Ns.Amberskin[spellId][1] end
		if Ns.TreeOfLife[spellId] then Ns.treeofLife = Ns.TreeOfLife[spellId][1] end
	--

	-- Hunter
	elseif (Ns.classFilename == "HUNTER") then
	--

	-- Paladin
	elseif (Ns.classFilename == "PALADIN") then

		if Ns.AvengingWrath[spellId] then Ns.avenWrath = Ns.AvengingWrath[spellId][1] end
		if Ns.RetributionAura[spellId] and Ns.Communion > 0 then Ns.auraSpell = Ns.Communion end
		if Ns.ArdentDef[spellId] then Ns.ardentDef = Ns.ArdentDef[spellId][1] end
		if Ns.AncientKings[spellId] then Ns.ancientKings = Ns.AncientKings[spellId][1] end
		if Ns.Conviction[spellId] then Ns.conviction = Ns.Conviction[spellId][1] end
		if Ns.DivineProtection[spellId] and not Ns.glyphDivine then Ns.divineProt = Ns.DivineProtection[spellId][1] end

	--

	-- Priest
	elseif (Ns.classFilename == "PRIEST") then

		local playerMaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
		if Ns.Archangel[spellId] then Ns.archangel = Ns.Archangel[spellId][1] end
		if Ns.FocusWill[spellId] then Ns.focusWill = Ns.FocusWillTalent end
		if Ns.ShadowForm[spellId] then Ns.shadowForm = Ns.ShadowForm[spellId][1] end
		if Ns.Dispersion[spellId] then Ns.dispDmg = Ns.Dispersion[spellId][1]; Ns.dispRegen = playerMaxMana * Ns.Dispersion[spellId][2] end
	--

	-- Shaman
	elseif (Ns.classFilename == "SHAMAN") then

		local hasEnchant, _, _, enchantId, hasEnchantOH, _, _, enchantIdOH = GetWeaponEnchantInfo()
		if hasEnchant and Ns.Flametongue[enchantId] then Ns.flameTongue = Ns.eleWeapons + Ns.Flametongue[enchantId][1] end
		if hasEnchantOH and Ns.Flametongue[enchantIdOH] then Ns.flameTongueOH = Ns.eleWeapons + Ns.Flametongue[enchantIdOH][1] end
		if hasEnchant and Ns.Rockbiter[enchantId] then Ns.rockBiter = Ns.Rockbiter[enchantId][1] end
		if Ns.ElementalOath[spellId] then Ns.eleOath = Ns.ElementalOath[spellId][1] end
		if Ns.ElementalMastery[spellId] then Ns.masterySpell = Ns.ElementalMastery[spellId][1]
			if Ns.glyphMastery then Ns.masteryDmg = Ns.ElementalMastery[spellId][2] end end
		if Ns.ShamRage[spellId] then Ns.shamRage = Ns.ShamRage[spellId][1] end
	--

	-- Warrior
	elseif (Ns.classFilename == "WARRIOR") then

		if Ns.ShieldWall[spellId] then Ns.shieldWall = Ns.ShieldWall[spellId][1] end
		if Ns.DeathWish[spellId] then
			if not Ns.glyphWish then Ns.deathWish = Ns.DeathWish[spellId][1] end
		end
		if Ns.Reckless[spellId] then Ns.reckless = Ns.Reckless[spellId][1] end
	--

	-- Death Knight
	elseif (Ns.classFilename == "DEATHKNIGHT") then

		if Ns.ArmyofDead[spellId] then Ns.armyDead = Ns.ArmyofDead[spellId][1] + Ns.parryChance + Ns.dodgeChance end
		if Ns.BloodPresence[spellId] then Ns.bloodPresence = Ns.BloodPresence[spellId][1]; Ns.impBlood = Ns.ImpBlood end
		if Ns.IceFortitude[spellId] then Ns.iceFortitude = Ns.IceFortitude[spellId][1] + Ns.SanguineFort end
		if Ns.BoneShield[spellId] then Ns.boneShield = Ns.BoneShield[spellId][1] end
		if Ns.WillNecro[spellId] then Ns.willNecro = Ns.WillNecropolis end
	--

	end -- end class checks
	end -- end loop player

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
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
	-----
	local _, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
	local spellID, amount, critical, missType, healCrit, spellCritical
	local playerGUID = UnitGUID("player")

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

	elseif subevent == "SPELL_CAST_START" and sourceGUID == playerGUID then
		Ns.ancResolve = Ns.AncResolve

	elseif (subevent == "SPELL_CAST_FAILED" or subevent == "SPELL_CAST_SUCCESS") and sourceGUID == playerGUID then
		Ns.ancResolve = 0
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

	Ns.StatsCompute()

end -- end events
end -- end function
