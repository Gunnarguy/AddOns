local _, Ns = ...

function Ns.talentScan()
	local classFilename = select(2, UnitClass("player"))

	if (classFilename == "MAGE") then

	local points = select(5, GetTalentInfo(1, 3))
	local pointsArcane = (select(3,GetTalentTabInfo(1)))
	local pointsFire = (select(3,GetTalentTabInfo(2)))
	local pointsFrost = (select(3,GetTalentTabInfo(3)))
	if (pointsArcane > pointsFire) and (pointsArcane > pointsFrost) then
		Ns.arcaneFocus = points
	else
		Ns.arcaneFocus = 0
	end

	local points = select(5, GetTalentInfo(1, 13))
			Ns.aiMod = ((points * 1)/100)

	local points = select(5, GetTalentInfo(1, 18))
			Ns.PrismaticCloak = points * 2

	local points = select(5, GetTalentInfo(1, 26))
		Ns.NetherwindPresence = points * 2

	local points = select(5, GetTalentInfo(2, 17))
			Ns.playFire = (points * 1) / 100

	local points = select(5, GetTalentInfo(2, 19))
		Ns.MoltenFury = ((points * 6) / 100)

	local points = select(5, GetTalentInfo(3, 3))
		Ns.pierceMod = ((points * 2) / 100)

	local points = select(5, GetTalentInfo(3,17))
		Ns.hitMod = points

	local points = select(5, GetTalentInfo(3, 20))
		Ns.arcticWind = (points * 1) / 100

	local points = select(5, GetTalentInfo(3, 21))
		Ns.impFrostbolt = (points * 5) / 100


	if (pointsArcane < pointsFire) or (pointsArcane < pointsFrost) then
		Ns.arcaneFocus = 0
	end

	elseif (classFilename == "PRIEST") then

	local points = select(5, GetTalentInfo(1, 16))
		Ns.FocusedPower = ((points * 2) / 100)

	local points = select(5, GetTalentInfo(1, 17))
		Ns.Enlightenment = points * 2

	local points = select(5, GetTalentInfo(2, 5))
		Ns.spiritualHealing = ((points * 2) / 100)

	local points = select(5, GetTalentInfo(2, 17))
		Ns.blessedResil = (points / 100)

	local points = select(5, GetTalentInfo(3, 2))
		Ns.DarkNessTalent = ((points * 2) / 100)

	local points = select(5, GetTalentInfo(3, 3))
		Ns.hitMod = points

	elseif (classFilename == "ROGUE") then

	local points = select(5, GetTalentInfo(1, 16))
		Ns.MasterPoisonerTalent = points

	local points = select(5, GetTalentInfo(2, 3))
		Ns.MaceSpec = points * 3

	local points = select(5, GetTalentInfo(2, 4))
		if points == 1 then Ns.LightningReflexes = 4
		elseif points == 2 then Ns.LightningReflexes = 7
		elseif points == 3 then Ns.LightningReflexes = 10 end

	local points = select(5, GetTalentInfo(3, 15))
		Ns.SleightTalent = points

	local points = select(5, GetTalentInfo(3, 14))
		Ns.SerratedBlades = points * 3

	elseif (classFilename == "WARRIOR") then

	local points = select(5, GetTalentInfo(1, 4))
		Ns.MaceSpec = points * 3

	elseif (classFilename == "PALADIN") then

	local points = select(5, GetTalentInfo(2, 9))
		Ns.divinity = points / 100

	local points = select(5, GetTalentInfo(2, 10))
		Ns.riFuryTalent = points * 2

	-- local points = select(5, GetTalentInfo(2, 19))
		-- Ns.GuardedByLight = points * 3

	local points = select(5, GetTalentInfo(2, 23))
		Ns.ShieldTemplar = points

	local points = select(5, GetTalentInfo(3, 2))
		Ns.vengeance = points

	local points = select(5, GetTalentInfo(3, 14))
		Ns.crusadeTalent = points / 100

	local points = select(5, GetTalentInfo(3, 22))
		Ns.SwiftRetribution = points

	elseif (classFilename == "WARLOCK") then

	local points = select(5, GetTalentInfo(1, 5))
		Ns.Suppression = points

	local points = select(5, GetTalentInfo(1, 11))
		Ns.shadowMastery = ((points * 3)/100)

	local points = select(5, GetTalentInfo(2, 19))
		Ns.DemonicTactics = points * 2

	local points = select(5, GetTalentInfo(2, 22))
		Ns.ImpDemonicTactics = (points * 10) / 100

	local points = select(5, GetTalentInfo(2, 25))
		Ns.DemonicPact = (points * 2) / 100

	local points = select(5, GetTalentInfo(3, 8))
		Ns.emberstorm = ((points * 3)/100)

	local points = select(5, GetTalentInfo(3, 11))
		Ns.devastation = points * 5
		if Ns.devastation > 0 then
			Ns.devastation = "|cffff3333 +" .. (points * 5) .. "|r"
		else
			Ns.devastation = ""
		end

	local points = select(5, GetTalentInfo(3, 21))
		Ns.MoltenSkin = points * 2

	elseif (classFilename == "HUNTER") then

	local points = select(5, GetTalentInfo(1, 10))
		Ns.Ferocity = (points * 2)

	local points = select(5, GetTalentInfo(1, 14))
		Ns.FocusedFire = points/100

	local points = select(5, GetTalentInfo(1, 16))
		Ns.AnimalHandler = (points * 5)

	local points = select(5, GetTalentInfo(1, 19))
		Ns.serpentSwift = (points * 4)

	local points = select(5, GetTalentInfo(1, 26))
		Ns.KindredSpirits = (points * 4)/100

	local points = select(5, GetTalentInfo(2, 3))
		Ns.ImprovedHuntersMark = ((points * 10) / 100)

	elseif (classFilename == "SHAMAN") then

	local points = select(5, GetTalentInfo(1, 2))
		Ns.callofThunder = points * 5
		if Ns.callofThunder > 0 then
			Ns.callofThunder = "|cff0070DD +" .. Ns.callofThunder .. "|r"
		else
			Ns.callofThunder = ""
		end

	local points = select(5, GetTalentInfo(1, 16))
		Ns.elePrecision = points

	local points = select(5, GetTalentInfo(2, 15))
		Ns.ImprovedWindfury = (points * 2)

	local points = select(5, GetTalentInfo(3, 10))
		Ns.purification = ((points * 2)/100)

	local points = select(5, GetTalentInfo(3, 12))
		Ns.tidalMastery = points

	elseif (classFilename == "DRUID") then

	local points = select(5, GetTalentInfo(1, 6))
		Ns.CelestialFocus = points

	local points = select(5, GetTalentInfo(1, 13))
		Ns.balancePower = (points * 2)

	local points = select(5, GetTalentInfo(1, 15))
		Ns.FaerieImproved = points

	local points = select(5, GetTalentInfo(1, 18))
		Ns.starlight = (points * 2)

	local points = select(5, GetTalentInfo(1, 19))
		Ns.ImprovedMoonkin = points

	local points = select(5, GetTalentInfo(2, 9))
		Ns.predStrikes = points * 0.5

	local points = select(5, GetTalentInfo(2, 18))
		Ns.survFittest = (points * 2)

	local points = select(5, GetTalentInfo(2, 28))
		Ns.ProtectorPack = (points * 4)

	local points = select(5, GetTalentInfo(3, 8))
		Ns.giftNature = ((points * 2) / 100)

	local points = select(5, GetTalentInfo(3, 22))
		Ns.earthMother = points * 2

	elseif (classFilename == "DEATHKNIGHT") then

	local points = select(5, GetTalentInfo(1, 24))
		Ns.bloodGorged = points * 2

	local points = select(5, GetTalentInfo(2, 13))
		Ns.tundraStalker = ((points * 3) / 100)

	local points = select(5, GetTalentInfo(2, 17))
		Ns.impFrostPresence = points

	local points = select(5, GetTalentInfo(3, 20))
		Ns.rageRivenTalent = ((points * 2) / 100)

	local points = select(5, GetTalentInfo(3, 1))
		Ns.virulence = points

	local points = select(5, GetTalentInfo(2, 9))
		Ns.frigidDread = points
	end
end

