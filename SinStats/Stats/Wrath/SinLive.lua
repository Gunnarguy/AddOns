local AddName, Ns = ...
local L = Ns.L

----------------------
--		SinLive		--
----------------------
function Ns.SinLive(self)

Ns.huntersMark, Ns.debuffCount, Ns.bloodFrenzy, Ns.stormStrike, Ns.hemoDmg, Ns.exposeArmor, Ns.sunderArmor = 0, 0, 0, 0, 0, 0, 0
Ns.faerieFire, Ns.curseOfWeak, Ns.shatterArmor, Ns.frostFever, Ns.scorpidSting, Ns.insectSwarm, Ns.improvedFaerie = 0, 0, 0, 0, 0, 0, 0
Ns.misery, Ns.curseElements, Ns.impSorch, Ns.wintersChill, Ns.ebonPlague, Ns.rageRivendare, Ns.earthMoon = 0, 0, 0, 0, 0, 0, 0
Ns.heartCrusader, Ns.savageCombat, Ns.impShadowbolt, Ns.faerieFireImp, Ns.masterPoisoner, Ns.moltenFury, Ns.faerieCrit = 0, 0, 0, 0, 0, 0, 0

	for i = 1, 40 do
	local _, _, dcount, _, _, _, caster, _, _, debuffId = UnitDebuff("target", i)
		if not debuffId then break end

		if debuffId then Ns.debuffCount = i end

		Ns.debuffCount = Ns.debuffCount
		if Ns.Misery[debuffId] then Ns.misery = Ns.Misery[debuffId][1] end
		if Ns.HuntsMark[debuffId] then Ns.huntersMark = Ns.HuntsMark[debuffId][1] + (Ns.HuntsMark[debuffId][1] * Ns.ImprovedHuntersMark) + (Ns.HuntsMark[debuffId][1] * Ns.glyphHuntersMark) end
		if Ns.Hemo[debuffId] then Ns.hemoDmg = Ns.Hemo[debuffId][1] end
		if Ns.CurseOfEl[debuffId] then Ns.curseElements = Ns.CurseOfEl[debuffId][1] end
		if Ns.Scorpid[debuffId] then Ns.scorpidSting = Ns.Scorpid[debuffId][1] end
		if Ns.Stormstrike[debuffId] then Ns.stormStrike = Ns.Stormstrike[debuffId][1] end
		if Ns.Blood[debuffId] then Ns.bloodFrenzy = Ns.Blood[debuffId][1] end
		if Ns.Insect[debuffId] then Ns.insectSwarm = Ns.Insect[debuffId][1] end
		if Ns.MasterPoisoner[debuffId] then Ns.masterPoisoner = Ns.MasterPoisoner[debuffId][1] + Ns.MasterPoisonerTalent end
		if Ns.ArmorDebuffs.ExposeArmor[debuffId] then Ns.exposeArmor = Ns.ArmorDebuffs.ExposeArmor[debuffId][1] end
		if Ns.ArmorDebuffs.SunderArmor[debuffId] then Ns.sunderArmor = (dcount * Ns.ArmorDebuffs.SunderArmor[debuffId][1]) end
		if Ns.ArmorDebuffs.FaerieFire[debuffId] then Ns.faerieFire = Ns.ArmorDebuffs.FaerieFire[debuffId][1] 
			if caster == "player" then Ns.faerieFireImp = Ns.FaerieImproved; Ns.faerieCrit = Ns.FaerieImproved end end
		if Ns.ArmorDebuffs.CurseOfWeak[debuffId] then Ns.curseOfWeak = Ns.ArmorDebuffs.CurseOfWeak[debuffId][1] end
		if Ns.EbonPlaguebringer[debuffId] then Ns.ebonPlague = Ns.EbonPlaguebringer[debuffId][1] end
		if Ns.EarthAndMoon[debuffId] then Ns.earthMoon = Ns.EarthAndMoon[debuffId][1] end
		if Ns.Shatter[debuffId] then Ns.shatterArmor = dcount * Ns.Shatter[debuffId][1] end
		if Ns.FrostFever[debuffId] and Ns.tundraStalker > 0 then Ns.frostFever = Ns.tundraStalker end
		if Ns.BloodPlague[debuffId] and Ns.rageRivenTalent > 0 then Ns.rageRivendare = Ns.rageRivenTalent end
		if Ns.HeartOfCrusader[debuffId] then Ns.heartCrusader = Ns.HeartOfCrusader[debuffId][1] end
		if Ns.WintersChill[debuffId] then Ns.wintersChill = dcount end
		if Ns.ImprovedScorch[debuffId] then Ns.impSorch = Ns.ImprovedScorch[debuffId][1] end
		if Ns.SavageCombat[debuffId] then Ns.savageCombat = Ns.SavageCombat[debuffId][1] end
		if Ns.ShadowMastery[debuffId] then Ns.impShadowbolt = Ns.ShadowMastery[debuffId][1] end
		if Ns.MoltenFury > 0 then
			local health = UnitHealth("target")
			local maxHealth = UnitHealthMax("target")
			local percentHealth = (health / maxHealth) * 100
			if percentHealth <= 35 then Ns.moltenFury = Ns.MoltenFury end
		end
		if Ns.ArmorDebuffs.FaerieFire[debuffId] and caster and caster ~= "player" then --and not Ns.faerieCheck then
			Ns.talentCaster = caster
			local casterGUID = UnitGUID(caster) or 0
			if Ns.talentCaster ~= Ns.ImprovedFae[1] and casterGUID ~= Ns.ImprovedFae[3] then
			local inRange = CheckInteractDistance(caster, 1)
				if inRange then Ns.canInspect = CanInspect(caster)
					if Ns.canInspect then NotifyInspect(caster) end
						Ns.faerieCheck = true
						Ns.throttleTime = GetTime()
				end
			end
		end
		if Ns.ArmorDebuffs.FaerieFire[debuffId] and caster and caster ~= "player" and Ns.ImprovedFae[1] == Ns.talentCaster then Ns.faerieFireImp = Ns.ImprovedFae[2] end
		--if Ns.faerieCheck and caster == "player" then Ns.faerieFireImp = 0; Ns.faerieCrit = Ns.faerieFireImp print("test") end
		if Ns.faerieCheck and caster ~= "player" then Ns.faerieCrit = 0 end
	end
end