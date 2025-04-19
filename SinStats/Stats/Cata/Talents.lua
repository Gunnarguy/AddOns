local _, Ns = ...

function Ns.talentScan()
	local classFilename = select(2, UnitClass("player"))

	if (classFilename == "MAGE") then

		local points = select(5, GetTalentInfo(1, 7))
		Ns.PrismaticCloak = points * 2

		local points = select(5, GetTalentInfo(1, 19))
		Ns.invoCount = (points * 5) / 100

		local points = select(5, GetTalentInfo(2, 13))
		Ns.MoltenFury = ((points * 4) / 100)

		local points = select(5, GetTalentInfo(2, 20))
		Ns.firePower = points / 100


	elseif (classFilename == "PRIEST") then

		local points = select(5, GetTalentInfo(1, 12))
		Ns.FocusWillTalent = points * 5

		local points = select(5, GetTalentInfo(3, 20))
		Ns.TwistedFaith = points/100


	elseif (classFilename == "ROGUE") then

		local points = select(5, GetTalentInfo(1, 19))
			if points == 1 then
				Ns.DeadNerves = 3
			elseif points == 2 then
				Ns.DeadNerves = 7
			elseif points == 3 then
				Ns.DeadNerves = 10
			end


	elseif (classFilename == "WARRIOR") then

		local points = select(5, GetTalentInfo(3, 18))
		Ns.BastionDefense = points * 3


	elseif (classFilename == "PALADIN") then

		local points = select(5, GetTalentInfo(2, 7))
		Ns.sancCrit = (points * 2)
		if points == 1 then
			Ns.sancDmg = 3
		elseif points == 2 then
			Ns.sancDmg = 7
		elseif points == 3 then
			Ns.sancDmg = 10
		end

		local points = select(5, GetTalentInfo(2, 20))
		Ns.divinity = ((points * 2) / 100)

		local points = select(5, GetTalentInfo(3, 7))
		Ns.Communion = ((points * 5) / 100)


	elseif (classFilename == "WARLOCK") then

		local points = select(5, GetTalentInfo(1, 11))
		Ns.DeathEmbrace = ((points * 4) / 100)

		local points = select(5, GetTalentInfo(2, 8))
		Ns.DemonicPact = ((points * 2) / 100)

		local points = select(5, GetTalentInfo(3, 3))
		Ns.ImpSoulFire = ((points * 4) / 100)


	elseif (classFilename == "HUNTER") then

		local points = select(5, GetTalentInfo(3, 12))
		Ns.NoEscape = points * 3


	elseif (classFilename == "SHAMAN") then

		local points = select(5, GetTalentInfo(1, 9))
		Ns.elePrecision = points/100

		local points = select(5, GetTalentInfo(2, 4))
		Ns.eleWeapons = points/100

		local points = select(5, GetTalentInfo(3, 16))
		Ns.AncResolve = points * 5

		local points = select(5, GetTalentInfo(3, 18))
		Ns.SparkLife = ((points * 2) / 100)


	elseif (classFilename == "DRUID") then

		local points = select(5, GetTalentInfo(1, 14))
		Ns.EarthMoonTalent = ((points * 2) / 100)

		local points = select(5, GetTalentInfo(2, 1))
		Ns.ThickHide = points * 2

		local points = select(5, GetTalentInfo(2, 16))
		Ns.NaturalReaction = points * 9


	elseif (classFilename == "DEATHKNIGHT") then

		local points = select(5, GetTalentInfo(1, 1))
		Ns.ImpBlood = points * 3

		local points = select(5, GetTalentInfo(1, 6))
		Ns.WillNecropolis = points * 8

		local points = select(5, GetTalentInfo(1, 9))
		Ns.BladeBarrier = points * 2

		local points = select(5, GetTalentInfo(1, 16))
		Ns.SanguineFort = points * 15

		local points = select(5, GetTalentInfo(2, 19))
		if points == 1 then
			Ns.FrozenWastes = 0.03
		elseif points == 2 then
			Ns.FrozenWastes = 0.07
		elseif points == 3 then
			Ns.FrozenWastes = 0.1
		end

	end
end

