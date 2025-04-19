local AddName, Ns = ...
local L = Ns.L


function Ns.talentScan()
	local className, classFilename, classId = UnitClass("player")
	if (classFilename == "MAGE") then

		local points = select(5, GetTalentInfo(2, 13))
				Ns.spellCritMod = (points * 2)

		local points = select(5, GetTalentInfo(1, 15))
				Ns.arcaneMod = points * 1
				Ns.aiMod = ((points * 1)/100)

		local points = select(5, GetTalentInfo(3, 3))
				Ns.hitMod = points * 2

		local points = select(5, GetTalentInfo(1, 2))
				Ns.arcaneFocus = points * 2
				if Ns.arcaneFocus > 0 then
					Ns.labelHit = (" (|cff69CCF0+" .. ("%.0f"):format(Ns.arcaneFocus) .. "|r)")
				else
					Ns.labelHit = ""
				end

		local points = select(5, GetTalentInfo(2, 15))
				Ns.firepowerMod = ((points * 2)/100)

		local points = select(5, GetTalentInfo(3, 8))
				Ns.pierceMod = ((points * 2) / 100)

	elseif (classFilename == "PRIEST") then

		local points = select(5, GetTalentInfo(2, 3))
				Ns.spellCritMod = points * 1

		local points = select(5, GetTalentInfo(3, 5))
				Ns.hitMod = points * 2
				if Ns.hitMod > 0 then
				Ns.labelHit = (" (|cff8787ED+" .. ("%.0f"):format(Ns.hitMod) .. "|r)")
				else
					Ns.labelHit = ""
				end

		local points = select(5, GetTalentInfo(3, 15))
				Ns.DarkNessTalent = ((points * 2) / 100)

		local points = select(5, GetTalentInfo(2, 15))
				Ns.spiritualHealing = ((points * 2) / 100)


	elseif (classFilename == "PALADIN") then

		local points = select(5, GetTalentInfo(1, 10))
				Ns.wisTalent = ((points * 10)/100)

	elseif (classFilename == "WARLOCK") then

		local points = select(5, GetTalentInfo(1, 16))
				Ns.shadowMastery = ((points * 2)/100)

		local points = select(5, GetTalentInfo(3, 15))
				Ns.emberstorm = ((points * 2)/100)

	elseif (classFilename == "SHAMAN") then

		local points = select(5, GetTalentInfo(3, 14))
				Ns.purification = ((points * 2)/100)

	end
end
