local _, Ns = ...

----------------------
--		SinLive		--
----------------------
function Ns.SinLive(self)

Ns.huntersMark, Ns.debuffCount, Ns.bloodFrenzy, Ns.exposeArmor, Ns.sunderArmor = 0, 0, 0, 0, 0
Ns.noEscape, Ns.deathEmbrace, Ns.shadowandFlame, Ns.curseWeak, Ns.vindication = 0, 0, 0, 0, 0
Ns.earthMoon, Ns.scarletFever, Ns.brittleBones, Ns.curseElements,Ns.savageCombat = 0, 0, 0, 0, 0
Ns.masterPoisoner, Ns.moltenFury, Ns.faerieFire, Ns.curseOfWeak, Ns.shatterArmor = 0, 0, 0, 0, 0
Ns.lightBreath = 0

	for i = 1, 40 do
	local _, _, dcount, _, _, _, caster, _, _, debuffId = UnitDebuff("target", i)
		if not debuffId then break end

		if debuffId then Ns.debuffCount = i end

		Ns.debuffCount = Ns.debuffCount

		if (debuffId == 1130) and caster and (caster == "player") then
			if (Ns.playerLevel == 80) then Ns.huntersMark = 500
			elseif (Ns.playerLevel == 81) then Ns.huntersMark = 1220
			elseif (Ns.playerLevel == 82) then Ns.huntersMark = 1352
			elseif (Ns.playerLevel == 83) then Ns.huntersMark = 1500
			elseif (Ns.playerLevel == 84) then Ns.huntersMark = 1628
			elseif (Ns.playerLevel == 85) then Ns.huntersMark = 1772
			end
		end

		-- local aura = C_UnitAuras.GetDebuffDataByIndex("target", i, "HARMFUL")
		-- print(AuraUtil.UnpackAuraData(aura))

		if Ns.ArmorDebuffs.ExposeArmor[debuffId] then Ns.exposeArmor = Ns.ArmorDebuffs.ExposeArmor[debuffId][1] end
		if Ns.ArmorDebuffs.SunderArmor[debuffId] then Ns.sunderArmor = (dcount * Ns.ArmorDebuffs.SunderArmor[debuffId][1]) end
		if Ns.ArmorDebuffs.FaerieFire[debuffId] then Ns.faerieFire = dcount * Ns.ArmorDebuffs.FaerieFire[debuffId][1] end
		if Ns.CurseElements[debuffId] then Ns.curseElements = Ns.CurseElements[debuffId][1] end
		if Ns.Blood[debuffId] then Ns.bloodFrenzy = Ns.Blood[debuffId][1] end
		if Ns.MasterPoisoner[debuffId] then Ns.masterPoisoner = Ns.MasterPoisoner[debuffId][1] end
		if Ns.CurseWeak[debuffId] then Ns.curseWeak = Ns.CurseWeak[debuffId][1] end
		if Ns.EarthMoon[debuffId] then Ns.earthMoon = Ns.EarthMoon[debuffId][1] end
		if Ns.Shatter[debuffId] then Ns.shatterArmor = dcount * Ns.Shatter[debuffId][1] end
		if Ns.HunterTraps[debuffId] then Ns.noEscape = Ns.NoEscape end
		if Ns.ShadowAndFlame[debuffId] then Ns.shadowandFlame = Ns.ShadowAndFlame[debuffId][1] end
		if Ns.SavageCombat[debuffId] then Ns.savageCombat = Ns.SavageCombat[debuffId][1] end
		if Ns.Vindication[debuffId] then Ns.vindication = Ns.Vindication[debuffId][1] end
		if Ns.ScarletFever[debuffId] then Ns.scarletFever = Ns.ScarletFever[debuffId][1] end
		if Ns.BrittleBones[debuffId] then Ns.brittleBones = Ns.BrittleBones[debuffId][1] end
		if Ns.LightningBreath[debuffId] then Ns.lightBreath = Ns.LightningBreath[debuffId][1] end

		-- health percentage-based debuffs
		local health = UnitHealth("target")
		local maxHealth = UnitHealthMax("target")
		local percentHealth = (health / maxHealth) * 100
		if Ns.MoltenFury > 0 then
			if percentHealth <= 35 then Ns.moltenFury = Ns.MoltenFury end
		end
		if Ns.DeathEmbrace > 0 then
			if percentHealth <= 25 then Ns.deathEmbrace = Ns.DeathEmbrace end
		end
	end
end