local V2_TAG_NUMBER = 4

---@param v2Rankings ProviderProfileV2Rankings
---@return ProviderProfileSpec
local function convertRankingsToV1Format(v2Rankings, difficultyId, sizeId)
	---@type ProviderProfileSpec
	local v1Rankings = {}
	v1Rankings.progress = v2Rankings.progressKilled
	v1Rankings.total = v2Rankings.progressPossible
	v1Rankings.average = v2Rankings.bestAverage
	v1Rankings.spec = v2Rankings.spec
	v1Rankings.asp = v2Rankings.allStarPoints
	v1Rankings.rank = v2Rankings.allStarRank
	v1Rankings.difficulty = difficultyId
	v1Rankings.size = sizeId

	v1Rankings.encounters = {}
	for id, encounter in pairs(v2Rankings.encountersById) do
		v1Rankings.encounters[id] = {
			kills = encounter.kills,
			best = encounter.best,
		}
	end

	return v1Rankings
end

---Convert a v2 profile to a v1 profile
---@param v2 ProviderProfileV2
---@return ProviderProfile
local function convertToV1Format(v2)
	---@type ProviderProfile
	local v1 = {}
	v1.subscriber = v2.isSubscriber
	v1.perSpec = {}

	if v2.summary ~= nil then
		v1.progress = v2.summary.progressKilled
		v1.total = v2.summary.progressPossible
		v1.totalKillCount = v2.summary.totalKills
		v1.difficulty = v2.summary.difficultyId
		v1.size = v2.summary.sizeId
	else
		local bestSection = v2.sections[1]
		v1.progress = bestSection.anySpecRankings.progressKilled
		v1.total = bestSection.anySpecRankings.progressPossible
		v1.average = bestSection.anySpecRankings.bestAverage
		v1.totalKillCount = bestSection.totalKills
		v1.difficulty = bestSection.difficultyId
		v1.size = bestSection.sizeId
		v1.anySpec = convertRankingsToV1Format(bestSection.anySpecRankings, bestSection.difficultyId, bestSection.sizeId)
		for i, rankings in pairs(bestSection.perSpecRankings) do
			v1.perSpec[i] = convertRankingsToV1Format(rankings, bestSection.difficultyId, bestSection.sizeId)
		end
		v1.encounters = v1.anySpec.encounters
	end

	if v2.mainCharacter ~= nil then
		v1.mainCharacter = {}
		v1.mainCharacter.spec = v2.mainCharacter.spec
		v1.mainCharacter.average = v2.mainCharacter.bestAverage
		v1.mainCharacter.difficulty = v2.mainCharacter.difficultyId
		v1.mainCharacter.size = v2.mainCharacter.sizeId
		v1.mainCharacter.progress = v2.mainCharacter.progressKilled
		v1.mainCharacter.total = v2.mainCharacter.progressPossible
		v1.mainCharacter.totalKillCount = v2.mainCharacter.totalKills
	end

	return v1
end

---Parse a single set of rankings from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileV2Rankings
local function parseRankings(decoder, state, lookup)
	---@type ProviderProfileV2Rankings
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progressKilled = decoder.decodeInteger(state, 1)
	result.progressPossible = decoder.decodeInteger(state, 1)
	result.bestAverage = decoder.decodePercentileFixed(state)
	result.allStarRank = decoder.decodeInteger(state, 3)
	result.allStarPoints = decoder.decodeInteger(state, 2)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encountersById = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)
		local isHidden = decoder.decodeBoolean(state)

		result.encountersById[id] = { kills = kills, best = best, isHidden = isHidden }
	end

	return result
end

---Parse a binary-encoded data string into a provider profile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@param formatVersion number
---@return ProviderProfile|ProviderProfileV2|nil
local function parse(decoder, content, lookup, formatVersion) -- luacheck: ignore 211
	-- For backwards compatibility. The existing addon will leave this as nil
	-- so we know to use the old format. The new addon will specify this as 2.
	formatVersion = formatVersion or 1
	if formatVersion > 2 then
		return nil
	end

	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	---@type ProviderProfileV2
	local result = {}
	result.isSubscriber = decoder.decodeBoolean(state)
	result.summary = nil
	result.sections = {}
	result.progressOnly = false
	result.mainCharacter = nil

	local sectionsCount = decoder.decodeInteger(state, 1)
	if sectionsCount == 0 then
		---@type ProviderProfileV2Summary
		local summary = {}
		summary.zoneId = decoder.decodeInteger(state, 2)
		summary.difficultyId = decoder.decodeInteger(state, 1)
		summary.sizeId = decoder.decodeInteger(state, 1)
		summary.progressKilled = decoder.decodeInteger(state, 1)
		summary.progressPossible = decoder.decodeInteger(state, 1)
		summary.totalKills = decoder.decodeInteger(state, 2)

		result.summary = summary
	else
		for i = 1, sectionsCount do
			---@type ProviderProfileV2Section
			local section = {}
			section.zoneId = decoder.decodeInteger(state, 2)
			section.difficultyId = decoder.decodeInteger(state, 1)
			section.sizeId = decoder.decodeInteger(state, 1)
			section.partitionId = decoder.decodeInteger(state, 1) - 128
			section.totalKills = decoder.decodeInteger(state, 2)

			local specCount = decoder.decodeInteger(state, 1)
			section.anySpecRankings = parseRankings(decoder, state, lookup)

			section.perSpecRankings = {}
			for j = 1, specCount - 1 do
				local specRankings = parseRankings(decoder, state, lookup)
				table.insert(section.perSpecRankings, specRankings)
			end

			table.insert(result.sections, section)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)
	if hasMainCharacter then
		---@type ProviderProfileV2MainCharacter
		local mainCharacter = {}
		mainCharacter.zoneId = decoder.decodeInteger(state, 2)
		mainCharacter.difficultyId = decoder.decodeInteger(state, 1)
		mainCharacter.sizeId = decoder.decodeInteger(state, 1)
		mainCharacter.progressKilled = decoder.decodeInteger(state, 1)
		mainCharacter.progressPossible = decoder.decodeInteger(state, 1)
		mainCharacter.totalKills = decoder.decodeInteger(state, 2)
		mainCharacter.spec = decoder.decodeString(state, lookup)
		mainCharacter.bestAverage = decoder.decodePercentileFixed(state)

		result.mainCharacter = mainCharacter
	end

	local progressOnly = decoder.decodeBoolean(state)
	result.progressOnly = progressOnly

	if formatVersion == 1 then
		return convertToV1Format(result)
	end

	return result
end
 local lookup = {'Unknown-Unknown','Warrior-Fury','Shaman-Restoration','Mage-Fire','Warrior-Protection','Priest-Holy',}; local provider = {region='US',realm='Nightslayer',name='US_5213',type='subscribers',zone=1035,date='2025-08-20',data={Ac='Actanonverba:BAEACwQDKAkJGwAAAQ==.',Ad='Adins:BAEACwQDKAkJCQAAAQ==.',Ae='Aengus:BAEACwQDKAkJGwABCwQDKAkJJAABAAAAAQ==.',Ah='Ahjeezer:BAEACwQDKAkJNgAAAQ==.',Al='Allelujah:BAEACwQDKAkJCQAAAQ==.',An='Anoj:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.Anthomm:BAEACwQDKAkJCQAAAQ==.',Ap='Apothw:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.',Ar='Art:BAEACwQDKAkJJAABCwQDKAkJJAABAAAAAQ==.',Ay='Ayakashi:BAEACwQDKAgJFQAAAQ==.Aylak:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.',Az='Azokk:BAEACwQDKAkJCQAAAQ==.Azotorp:BAEACwQDKAkJDgAAAQ==.',Ba='Bathunt:BAEACwQDKAkJKgAAAQ==.',Be='Beansbadknee:BAEACwQDKAkJNgAAAQ==.Beesdosomuch:BAEACwQDKAkJGwABCwQDKAkJNgABAAAAAQ==.Betchy:BAEACwQDKAkJLQAAAQ==.',Bi='Bigbrewski:BAEACwQDKAkJJAAAAQ==.Biggxthaplug:BAEACwQDKAkJKwAAAQ==.Bildozer:BAEACwQDKAkJKQAAAQ==.Billybork:BAEACwQDKAkJHwABCwQDKAkJNgABAAAAAQ==.Billybovine:BAEACwQDKAkJNgAAAQ==.Bingchaining:BAEACwQDKAkJEgABCwQDKAkJNgABAAAAAQ==.Bingchilling:BAEACwQDKAkJNgAAAQ==.',Bl='Blinkwing:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.Blockyblock:BAEACwQDKAkJNgAAAQ==.Bluke:BAEACwQDKAkJLQAAAQ==.',Bo='Bohemond:BAEACwQDKAkJLQAAAQ==.Bonfield:BAEACwQDKAkJMgAAAQ==.Boostiwoosti:BAEACwQDKAkJMAABCwQDKAkJNgABAAAAAQ==.',Br='Broxadina:BAEACwQDKAkJJAABCwQDKAkJJgABAAAAAQ==.Broxalynne:BAEACwQDKAkJJgAAAQ==.Broxie:BAEACwQDKAkJJAABCwQDKAkJJgABAAAAAQ==.Broxy:BAEACwQDKAkJJAABCwQDKAkJJgABAAAAAQ==.Brues:BAEACwQDKAkJGwAAAQ==.Bruggernaut:BAEACwQDKAkJIgAAAQ==.',Bu='Bubztwo:BAEACwQDKAkJLQAAAQ==.Buglord:BAEACwQDKAkJJAAAAQ==.Bunser:BAEACwQDKAkJLQAAAQ==.Bussybolt:BAEACwQDKAkJEgAAAQ==.',Bw='Bwoxy:BAEACwQDKAkJGAABCwQDKAkJJgABAAAAAQ==.',Ca='Cabo:BAEACwQDKAkJKwAAAQ==.Cammyboi:BAEACwQDKAkJJQAAAQ==.',Ce='Cexal:BAEACwQDKAkJPwAAAQ==.',Ch='Chakakhan:BAEACwQDKAkJJAAAAQ==.Chipotlae:BAEACwQDKAkJKwAAAQ==.Chubbz:BAEACwQDKAgJJgAAAQ==.',Cl='Cleavë:BAEACwQDKAkJLQAAAQ==.',Cr='Crazyrez:BAEACwQDKAkJIgABCwQDKAkJIwABAAAAAQ==.Creedthotz:BAEACwQDKAkJLQAAAQ==.Cressy:BAEACwQDKAkJLQAAAQ==.',Db='Dbldippin:BAEACwQDKAkJMAAAAQ==.',De='Dezrix:BAEACwQDKAkJCQAAAQ==.',Di='Dildus:BAEACwQDKAkJNgAAAQ==.Dinner:BAEACwQDKAkJKAABCwQDKAkJNgABAAAAAQ==.',Dr='Draxthos:BAEACwQDKAkJHwAAAQ==.Drez:BAEACwQDKAkJJAAAAQ==.Droppwf:BAEACwQDKAkJGwABCwQDKAkJNgABAAAAAQ==.',Dy='Dyra:BAEACwQDKAkJNgAAAQ==.',Eb='Ebonmight:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.',Ei='Eiloww:BAEBCwQDKIM2AAICAAkJiSU9CADzAgm1TAIABgBjALZMAgAGAGIAt0wCAAYAYgC4TAIABgBSALlMAgAGAFcBukwCAAYAWwC7TAIABgBjALxMAgAGAGMAvUwCAAYAYwACAAkJiSU9CADzAgm1TAIABgBjALZMAgAGAGIAt0wCAAYAYgC4TAIABgBSALlMAgAGAFcBukwCAAYAWwC7TAIABgBjALxMAgAGAGMAvUwCAAYAYwABCwQDKAkJNgACALUmAA==.',El='Elyahk:BAEACwQDKAkJLQAAAQ==.',Et='Etchy:BAEACwQDKAgJJwABCwQDKAkJLQABAAAAAQ==.',Ev='Evii:BAEACwQDKAkJEAAAAQ==.Evillary:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.',Ex='Exsil:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.',Fe='Fearwripper:BAEACwQDKAkJMgAAAQ==.',Fi='Firesign:BAEACwQDKAkJKgAAAQ==.',Fl='Flewf:BAEBCwQDKIMPAAIDAAkJYxsuFQAaAgm1TAIAAgBaALZMAgACAFoAt0wCAAIAUAC4TAIAAgBSALlMAgACAEkAukwCAAIAHAC7TAIAAQAkALxMAgABAEUAvUwCAAEAUAADAAkJYxsuFQAaAgm1TAIAAgBaALZMAgACAFoAt0wCAAIAUAC4TAIAAgBSALlMAgACAEkAukwCAAIAHAC7TAIAAQAkALxMAgABAEUAvUwCAAEAUAABCwQDKAkJLQADAJ4mAA==.Flightlord:BAEACwQDKAkJEgABCwQDKAkJKwABAAAAAQ==.Flow:BAEACwQDKAkJIAAAAQ==.',Fo='Foams:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Foamz:BAEACwQDKAkJLQAAAQ==.Formatical:BAEACwQDKAkJHwAAAQ==.',Fr='Frown:BAEACwQDKAkJNQAAAQ==.Frugo:BAEACwQDKAkJLAAAAQ==.',Gl='Glazzle:BAEACwQDKAkJIwABCwQDKAkJJAABAAAAAQ==.Glazzy:BAEACwQDKAkJJAAAAQ==.Glimpusmelpo:BAEACwQDKAkJGQAAAQ==.',Go='Goaway:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Goose:BAEACwQDKAkJLQAAAQ==.',Gr='Grantank:BAEACwQDKAkJNgAAAQ==.Greatunknown:BAEACwQDKAkJNgAAAQ==.Greenslug:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Grimshack:BAEACwQDKAkJJAAAAQ==.Grolmundr:BAEACwQDKAkJJAAAAQ==.',Gu='Gut:BAEACwQDKAkJEgAAAQ==.',Gz='Gzarlith:BAEACwQDKAkJEgAAAQ==.',Ha='Haars:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Haarslock:BAEACwQDKAkJKgABCwQDKAkJLQABAAAAAQ==.Haarsmage:BAEACwQDKAkJKgABCwQDKAkJLQABAAAAAQ==.Haarsshaman:BAEACwQDKAkJLQAAAQ==.Hahaha:BAEACwQDKAkJCQAAAQ==.Haiyah:BAEACwQDKAkJKAAAAQ==.Hallowedly:BAEACwQDKAkJLQABCwQDKAkJMgABAAAAAQ==.Hallowtide:BAEACwQDKAkJMgAAAQ==.Hallowtides:BAEACwQDKAkJLAABCwQDKAkJMgABAAAAAQ==.Harenil:BAEBCwQDKIMiAAIEAAkJbyJNFACQAgm1TAIABABKALZMAgAEAFsAt0wCAAQAVQC4TAIABABiALlMAgACABQBukwCAAQAYQC7TAIABABcALxMAgAEAFUAvUwCAAQATgAEAAkJbyJNFACQAgm1TAIABABKALZMAgAEAFsAt0wCAAQAVQC4TAIABABiALlMAgACABQBukwCAAQAYQC7TAIABABcALxMAgAEAFUAvUwCAAQATgAAAA==.',He='Healex:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Healthcure:BAEACwQDKAkJMgAAAQ==.Healytroll:BAEACwQDKAkJHQAAAQ==.',Ho='Hoofer:BAEACwQDKAkJNgAAAQ==.',Hu='Huka:BAEACwQDKAkJJAAAAQ==.Hunch:BAEACwQDKAkJLQAAAQ==.Hunchp:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Hunchsham:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Hunchz:BAEACwQDKAkJIwABCwQDKAkJLQABAAAAAQ==.',Hy='Hypnobones:BAEACwQDKAkJGwAAAQ==.',Ik='Ikissboys:BAEACwQDKAkJMAAAAQ==.',Is='Ishtotem:BAEACwQDKAkJKgAAAQ==.',It='Itzjay:BAEACwQDKAkJNgAAAQ==.',Ja='Jackedcat:BAEACwQDKAkJMQAAAQ==.',Jb='Jbhw:BAEBCwQDKIMtAAICAAkJnCaNAQAYAwm1TAIABQBjALZMAgAFAGMAt0wCAAUAYwC4TAIABQBgALlMAgAFAF8BukwCAAUAYAC7TAIABQBjALxMAgAFAGMAvUwCAAUAYwACAAkJnCaNAQAYAwm1TAIABQBjALZMAgAFAGMAt0wCAAUAYwC4TAIABQBgALlMAgAFAF8BukwCAAUAYAC7TAIABQBjALxMAgAFAGMAvUwCAAUAYwABCwQDKAkJNgACALUmAA==.Jbhwar:BAEBCwQDKIM2AAICAAkJtSZ+AAAvAwm1TAIABgBgALZMAgAGAGIAt0wCAAYAYwC4TAIABgBjALlMAgAGAF4BukwCAAYAYgC7TAIABgBjALxMAgAGAGMAvUwCAAYAYwACAAkJtSZ+AAAvAwm1TAIABgBgALZMAgAGAGIAt0wCAAYAYwC4TAIABgBjALlMAgAGAF4BukwCAAYAYgC7TAIABgBjALxMAgAGAGMAvUwCAAYAYwAAAA==.',Je='Jeepjeep:BAEACwQDKAkJKQABCwQDKAkJKwABAAAAAQ==.Jen:BAEACwQDKAkJIgABCwQDKAkJLQABAAAAAQ==.Jenediction:BAEACwQDKAkJIwABCwQDKAkJLQABAAAAAQ==.',Ji='Jickup:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.',Jo='Jodistewart:BAEACwQDKAkJNgAAAQ==.Jona:BAEACwQDKAkJNgAAAQ==.',Ju='Jugz:BAEACwQDKAkJNgAAAQ==.',Ka='Kathvely:BAEACwQDKAkJKwAAAQ==.Katzenbar:BAEACwQDKAkJLAABCwQDKAkJLQABAAAAAQ==.',Ke='Ketchikan:BAEACwQDKAkJGwAAAQ==.',Ki='Kipkat:BAEACwQDKAkJCQABCwQDKAkJNgABAAAAAQ==.Kissygirl:BAEACwQDKAkJLAABCwQDKAkJLQABAAAAAQ==.',Kl='Klov:BAEACwQDKAkJNgAAAQ==.Klovrockjaw:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.',Ko='Korvos:BAEACwQDKAkJIwABCwQDKAkJNQABAAAAAQ==.Kovul:BAEACwQDKAkJNQAAAQ==.',Kp='Kpns:BAEACwQDKAkJEgABCwQDKAkJNgABAAAAAQ==.',Kr='Krollblade:BAEACwQDKAkJNgAAAQ==.',Ky='Kylak:BAEACwQDKAkJNgABCwQDKAkJNgABAAAAAQ==.',['Kì']='Kìp:BAEACwQDKAkJNgAAAQ==.',['Kí']='Kíp:BAEACwQDKAkJLwABCwQDKAkJNgABAAAAAQ==.',La='Laríssa:BAEACwQDKAkJGgAAAQ==.',Le='Leechh:BAEACwQDKAkJMQAAAQ==.Leeroyqt:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Leknaat:BAEACwQDKAkJLQAAAQ==.Leknatt:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.',Li='Lilartimus:BAEACwQDKAgJCAABCwQDKAkJNgABAAAAAQ==.Lilcinder:BAEACwQDKAkJNgAAAQ==.Lilmaejok:BAEACwQDKAkJNgAAAQ==.Linksdead:BAEACwQDKAkJGwAAAQ==.Linksdeads:BAEACwQDKAkJEgABCwQDKAkJGwABAAAAAQ==.',Lo='Lockilock:BAEACwQDKAkJJgABCwQDKAkJNgABAAAAAQ==.',Lu='Ludociel:BAEACwQDKAkJEQABCwQDKAkJNgABAAAAAQ==.Lunilah:BAEACwQDKAkJLQABCwQDKAkJMgABAAAAAQ==.',Ma='Madea:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.Makenna:BAEACwQDKAIJAgAAAQ==.Marafice:BAEACwQDKAgJHwAAAQ==.',Me='Mechro:BAEACwQDKAkJLgAAAQ==.Meiun:BAEACwQDKAkJLAAAAQ==.',Mi='Miesty:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Miestylite:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Miestythicc:BAEACwQDKAkJLQAAAQ==.Mikasax:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.Mikasaxx:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Mikassa:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Mikassax:BAEACwQDKAkJLQAAAQ==.Milkslug:BAEACwQDKAkJEAABCwQDKAkJLQABAAAAAQ==.',Mo='Mokrogras:BAEACwQDKAkJLQAAAQ==.Molten:BAEACwQDKAkJKAABCwQDKAkJNgABAAAAAQ==.Moltenge:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.Mommie:BAEBCwQDKIMtAAIDAAkJniYuAAArAwm1TAIABQBiALZMAgAFAGMAt0wCAAUAYwC4TAIABQBhALlMAgAFAFsAukwCAAUAYgC7TAIABQBiALxMAgAFAGMAvUwCAAUAYQADAAkJniYuAAArAwm1TAIABQBiALZMAgAFAGMAt0wCAAUAYwC4TAIABQBhALlMAgAFAFsAukwCAAUAYgC7TAIABQBiALxMAgAFAGMAvUwCAAUAYQAAAA==.',Mu='Multishart:BAEACwQDKAkJNgAAAQ==.',My='Mynameben:BAEACwQDKAkJKwAAAQ==.',Na='Nade:BAEACwQDKAkJLQAAAQ==.Nadeshka:BAEACwQDKAkJIAABCwQDKAkJLQABAAAAAQ==.Nadewar:BAEACwQDKAkJKQABCwQDKAkJLQABAAAAAQ==.',Ne='Negy:BAEACwQDKAkJGwABCwQDKAkJLQABAAAAAQ==.',Ni='Nickxz:BAEACwQDKAkJEgAAAQ==.',No='Norivios:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.Noxiq:BAEACwQDKAgJJwAAAQ==.',Nu='Nullanwl:BAEACwQDKAkJJAAAAQ==.Nunya:BAEACwQDKAgJFAAAAQ==.',Nv='Nvrmind:BAEACwQDKAgJGgAAAQ==.',Oa='Oakshrond:BAEACwQDKAgJKAAAAQ==.',Ob='Obiwoncanoli:BAEACwQDKAkJJAAAAQ==.',Ol='Oldblackman:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.',Pa='Pacal:BAEACwQDKAkJNQAAAQ==.Paltara:BAEACwQDKAkJGwABCwQDKAkJJAABAAAAAQ==.Pantees:BAEACwQDKAkJLQAAAQ==.Pattön:BAEACwQDKAkJKgAAAQ==.',Ph='Phatw:BAEACwQDKAkJGgAAAQ==.Physis:BAEACwQDKAkJDwABCwQDKAkJHQABAAAAAQ==.',Pi='Picolina:BAEACwQDKAkJEwABCwQDKAkJNQABAAAAAQ==.Picomustard:BAEACwQDKAkJNQAAAQ==.Pipz:BAEACwQDKAkJMAAAAQ==.Pirateluffy:BAEACwQDKAYJEQAAAQ==.',Po='Pov:BAEACwQDKAkJPAAAAQ==.',Pr='Praky:BAEACwQDKAkJLQAAAQ==.Prakyp:BAEACwQDKAkJCQABCwQDKAkJLQABAAAAAQ==.Prilla:BAEACwQDKAkJGwAAAQ==.Primatron:BAEACwQDKAkJKwABCwQDKAkJNgABAAAAAQ==.Primbald:BAEACwQDKAkJKQABCwQDKAkJNgABAAAAAQ==.Primthree:BAEACwQDKAkJNgAAAQ==.Problemx:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.Proptologist:BAEACwQDKAgJCAAAAQ==.',Pu='Pubbles:BAEACwQDKAkJLQAAAQ==.Pump:BAEACwQDKAkJLQAAAQ==.Puos:BAEACwQDKAkJCQABCwQDKAkJLQABAAAAAQ==.',Py='Pyrrha:BAEACwQDKAkJJAAAAQ==.',Ra='Ramesses:BAEBCwQDKIMsAAMFAAkJ3CWKCQCYAgm1TAIABQBbALZMAgAFAGAAt0wCAAUAYAC4TAIABQBhALlMAgAEAFcBukwCAAUAYwC7TAIABQBhALxMAgAFAGEAvUwCAAUAYwAFAAgJtiWKCQCYAgi1TAIABQBbALZMAgAFAGAAt0wCAAUAYAC4TAIABABhALlMAgADAEIBukwCAAQAYwC7TAIABQBhALxMAgAFAGEAAgAECd8TnegAhQAEuEwCAAEABQC5TAIAAQBXAbpMAgABAC8AvUwCAAUAYwABCwQDKAkJNQABAAAAAA==.',Rd='Rdur:BAEACwQDKAkJGwAAAQ==.',Re='Rejen:BAEACwQDKAkJLQAAAQ==.Restobabyy:BAEACwQDKAkJIgAAAQ==.',Ri='Rimang:BAEBCwQDKIMzAAIEAAkJ3CNKDADHAgm1TAIABgBLALZMAgAGAGEAt0wCAAYAXwC4TAIABgBeALlMAgAGAFsBukwCAAYAYQC7TAIABQBOALxMAgAFAGEAvUwCAAUAYwAEAAkJ3CNKDADHAgm1TAIABgBLALZMAgAGAGEAt0wCAAYAXwC4TAIABgBeALlMAgAGAFsBukwCAAYAYQC7TAIABQBOALxMAgAFAGEAvUwCAAUAYwABCwQDKAkJKwAGAPYhAA==.Rimeng:BAEBCwQDKIMrAAIGAAkJ9iGUCwCXAgm1TAIABQBYALZMAgAFAE4At0wCAAUAWQC4TAIABQBHALlMAgADAFIAukwCAAUATwC7TAIABQBaALxMAgAFAGMAvUwCAAUAYgAGAAkJ9iGUCwCXAgm1TAIABQBYALZMAgAFAE4At0wCAAUAWQC4TAIABQBHALlMAgADAFIAukwCAAUATwC7TAIABQBaALxMAgAFAGMAvUwCAAUAYgAAAA==.',Ro='Roamìng:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Rodimus:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.Rogey:BAEACwQDKAkJNgAAAQ==.Rowling:BAEACwQDKAYJBgABCwQDKAkJNgABAAAAAQ==.',Sc='Scampii:BAEACwQDKAkJKgAAAQ==.Schnaks:BAEACwQDKAkJLAAAAQ==.',Se='Seanpaul:BAEACwQDKAkJIgABCwQDKAkJNgABAAAAAQ==.Serotonin:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.Setw:BAEACwQDKAkJNgAAAQ==.',Sf='Sfiv:BAEACwQDKAkJGAAAAQ==.',Sh='Shamanations:BAEACwQDKAkJLQAAAQ==.Shmeeva:BAEACwQDKAkJJAABCwQDKAkJLQABAAAAAQ==.Shmev:BAEACwQDKAkJLQAAAQ==.',Si='Sickup:BAEACwQDKAkJNgAAAQ==.',Sk='Skippi:BAEACwQDKAkJEgAAAQ==.Skuub:BAEACwQDKAkJLwAAAQ==.',Sl='Slappyboi:BAEACwQDKAkJLAAAAQ==.Slugzug:BAEACwQDKAkJLQAAAQ==.',Sm='Smaq:BAEACwQDKAkJJwAAAQ==.',Sn='Snacs:BAEACwQDKAkJKQAAAQ==.Snuset:BAEACwQDKAkJLQABCwQDKAkJNgABAAAAAQ==.',So='Solknar:BAEACwQDKAcJFwABCwQDKAgJHwABAAAAAQ==.',St='Starvin:BAEACwQDKAkJLQAAAQ==.',Sw='Swaxie:BAEACwQDKAkJHQAAAQ==.',Sy='Sylak:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.',Th='Thunderwx:BAEACwQDKAkJLQAAAQ==.',Ti='Ticks:BAEACwQDKAkJKwAAAQ==.Tiptwister:BAEACwQDKAkJKgABCwQDKAkJNgABAAAAAQ==.Titanseeds:BAEACwQDKAkJEgAAAQ==.',Tm='Tmp:BAEACwQDKAkJNgAAAQ==.',To='Toshio:BAEACwQDKAkJLQAAAQ==.',Tr='Tribslave:BAEACwQDKAkJCQABCwQDKAkJJgABAAAAAQ==.Trojanduck:BAEACwQDKAkJCQAAAQ==.',Tu='Tuah:BAEACwQDKAkJGgABCwQDKAkJNgABAAAAAQ==.Tub:BAEACwQDKAkJNgAAAQ==.',Tv='Tvaticus:BAEACwQDKAgJJgAAAQ==.',Tw='Twist:BAEACwQDKAkJLQAAAQ==.Twost:BAEACwQDKAkJLQABCwQDKAkJLQABAAAAAQ==.',Tz='Tzatzeeki:BAEACwQDKAcJCgAAAQ==.',Ut='Uthos:BAEACwQDKAkJKwAAAQ==.',Va='Vacx:BAEACwQDKAkJJAABCwQDKAkJJAABAAAAAQ==.',Ve='Verosia:BAEACwQDKAkJIwAAAQ==.',Vu='Vudumi:BAEACwQDKAkJJAABCwQDKAkJMgABAAAAAQ==.',Wa='Wamba:BAEACwQDKAgJHwAAAQ==.Wangwizard:BAEACwQDKAkJLQAAAQ==.Warella:BAEACwQDKAkJJAABCwQDKAkJNgABAAAAAQ==.Wargraymon:BAEACwQDKAgJIAABCwQDKAkJKgABAAAAAQ==.Wargreymon:BAEACwQDKAkJKgAAAQ==.Waveqx:BAEACwQDKAkJHwAAAQ==.',We='Weegee:BAEACwQDKAkJPwAAAQ==.Westside:BAEACwQDKAkJNgAAAQ==.',Wh='Whitecry:BAEACwQDKAkJIwABCwQDKAkJKAABAAAAAQ==.Whitesnake:BAEACwQDKAkJFQABCwQDKAkJKQABAAAAAQ==.',Ya='Yackulina:BAEACwQDKAkJLAABCwQDKAkJNQABAAAAAQ==.Yahk:BAEACwQDKAkJGwABCwQDKAkJLQABAAAAAQ==.',Yo='Yoey:BAEACwQDKAkJJQAAAQ==.Yoeythree:BAEACwQDKAkJIQABCwQDKAkJJQABAAAAAQ==.',Yu='Yuseifudo:BAEACwQDKAkJEAAAAQ==.',Za='Zanyuu:BAEACwQDKAkJNgAAAQ==.Zarillex:BAEACwQDKAgJDwAAAQ==.Zarko:BAEACwQDKAkJGwABCwQDKAkJNgABAAAAAQ==.',Ze='Zeldawn:BAEACwQDKAkJIwAAAQ==.Zelhoof:BAEACwQDKAkJPgAAAQ==.Zelx:BAEACwQDKAkJJAABCwQDKAkJPgABAAAAAQ==.Zevv:BAEACwQDKAkJJAAAAQ==.',Zi='Ziggey:BAEACwQDKAkJNAAAAQ==.',Zl='Zlappy:BAEACwQDKAkJCQABCwQDKAkJLAABAAAAAQ==.',Zo='Zombuzzles:BAEACwQDKAkJIwAAAQ==.',Zu='Zukalu:BAEACwQDKAkJHAABCwQDKAkJPgABAAAAAQ==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end