--
-- MI2_Events.lua
--
-- Handlers for all WoW events that MobInfo subscribes to. This includes
-- the main MobInfo OnEvent handler called "MI2_OnEvent()". Event handling
-- is based on a global table of event handlers called "MI2_EventHandlers[]".
-- For each event that MobInfo supports the corresponding handler function
-- is available in the table.
--
-- (this is code restructering work in progress, it has not yet been completed ... )
--

-- global variables initialisation
MI2_Target = {}
MI2_LastTargetIdx = {}
MI2_CurZone = 0

-- miscellaneous other event related global vairables 
MI2_IsNonMobLoot = nil
MI2_TradeskillUsed = nil

-- local variables declaration and initialisation
local MI2_EventHandlers = { }
local MI2_TT_SetItem

local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

function MI2_Encode(data)
    local serialized = LibSerialize:SerializeEx({ errorOnUnserializableType = false}, data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)
    return encoded
end

function MI2_Decode(encoded)
    local compressed = LibDeflate:DecodeForPrint(encoded)
    local serialized = LibDeflate:DecompressDeflate(compressed)
    local success, data = LibSerialize:Deserialize(serialized)
    return data
end

function MI2_ProcessVariables()
	if type(MI2_DB) == "string" then
		MI2_DB = MI2_Decode(MI2_DB)
	end

	if type(MI2_DB.source) == "string" then
		MI2_DB.source = MI2_Decode(MI2_DB.source)
	end

	if type(MI2_DB.location) == "string" then
		MI2_DB.location = MI2_Decode(MI2_DB.location)
	end

	if type(MI2_DB.character) == "string" then
		MI2_DB.character = MI2_Decode(MI2_DB.character)
	end

	if type(MI2_ItemNameTable) == "string" then
		MI2_ItemNameTable = MI2_Decode(MI2_ItemNameTable)
	end
	if type(MI2_UnitId2Name) == "string" then
		MI2_UnitId2Name = MI2_Decode(MI2_UnitId2Name)
	end
	if type(MI2_CurrencyNameTable) == "string" then
		MI2_CurrencyNameTable = MI2_Decode(MI2_CurrencyNameTable)
	end
	if type(MI2_CharTable) == "string" then
		MI2_CharTable = MI2_Decode(MI2_CharTable)
	end
	if type(MI2_ZoneTable) == "string" then
		MI2_ZoneTable = MI2_Decode(MI2_ZoneTable)
	end
	if type(MI2_RecentLoots) == "string" then
		MI2_RecentLoots = MI2_Decode(MI2_RecentLoots)
	end
end

-----------------------------------------------------------------------------
-- MI2_VariablesLoaded()
--
-- main global initialization function, this is called as the handler
-- for the "VARIABLES_LOADED" event
--
local function MI2_VariablesLoaded(self, event, ...)

	if type(MI2_DB) == "string" then
		MI2_DB = MI2_Decode(MI2_DB)
	end

	-- initialize "MobInfoConfig" data structure (main MobInfo config options)
	MI2_InitOptions(self)

	-- register with all AddOn managers that MobInfo attempts to support
	-- currently that is: myAddons, KHAOS (mainly for Cosmos), EARTH (originally for Cosmos)
	MI2_RegisterWithAddonManagers(self)

	MI2_OptionParse( self, "", {}, nil )

	-- ensure that MobHealthFrame get set correctly (if we have to set it for compatibility)
	if  MobHealthFrame == "MI2"  then
		MobHealthFrame = MI2_MobHealthFrame
	end

	-- setup a confirmation dialog for critical configuration options
	StaticPopupDialogs["MOBINFO_CONFIRMATION"] = {
		button1 = "Ok", --TEXT(OKAY),
		button2 = "Cancel", --TEXT(CANCEL),
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		interruptCinematic = 1
	}
	StaticPopupDialogs["MOBINFO_SHOWMESSAGE"] = {
		button1 = "Ok", --TEXT(OKAY),
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		interruptCinematic = 1
	}

	MI2_ProcessVariables()

	MI2_Database = CreateAndInitFromMixin(MI2_DatabaseMixin, MI2_DB)

	-- checking and cleanup for all databases
	MI2_CheckAndCleanDatabases()

	-- initialize slash commands processing
	MI2_SlashInit()
	-- build cross reference table for fast item tooltips
	MI2_BuildXRefItemTable()

	-- extend the spell school table to list both schools and schortcuts
	local newSchools = {}
	for school, schortcut in pairs(MI2_SpellSchools) do
		newSchools[school] = schortcut
		newSchools[schortcut] = school
	end
	MI2_SpellSchools = newSchools
	MI2_SpellSchools[64] = "ar"
	MI2_SpellSchools[32] = "sh"
	MI2_SpellSchools[16] = "fr"
	MI2_SpellSchools[8] = "na"
	MI2_SpellSchools[4] = "fi"
	MI2_SpellSchools[2] = "ho"

	-- from this point onward process events
	MI2_InitializeEventTable(self)

	MI2_UpdateOptions()
	MI2_InitializeTooltip()
	MI2_SetupTooltip()

	-- register for catching tooltip events
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, MI2_OnTooltipSetItem)
	else
		MI2_TT_SetItem = GameTooltip:GetScript("OnTooltipSetItem")
		GameTooltip:SetScript( "OnTooltipSetItem", MI2_OnTooltipSetItem )
	end
end -- MI2_VariablesLoaded()

local function MI2_EventLootReady(self, event, ...)
	MI2_ProcessLootReady()
end -- MI2_EventLootOpened()

-----------------------------------------------------------------------------
-- MI2_EventLootClosed()
--
-- Event handler for WoW event that the loot window has been closed.
-- This is used to catch empty loots when using auto-loot (Shift+RightClick)
-- In this case "LOOT_CLOSED" is the only loot event that fires
--
local function MI2_EventLootClosed(self, event, ...)
	MI2_ProcessLootClosed()
end

----------------------------------------------------------------------------
-- Event handler for the "PLAYER_TARGET_CHANGED" event. This handler will
-- fill the global variable "MI2_Target" with all the data that MobInfo
-- needs to know about the current target.
--
function MI2_OnTargetChanged(self, event, ...)
	local unit = "target"
	local _, unitId, unitName, unitLevel, unitGuid, unitIsClose, UnitClassification = MI2_Unit(unit)

	MI2_IsNonMobLoot = false -- to reset non Mob loot detection

	-- previous target post processing
	if  MI2_Target.mobIndex then
		MI2_LastTargetIdx = CopyTable(MI2_Target)
--		if MobInfoConfig.SaveResist == 1 then
--			local entry = MI2_FetchMobDataFromGUID(MI2_Target.guid, MI2_Target.level)
--			if entry then entry:SaveResistData() end
--		end
	end

	if unitId and unitLevel then
		MI2_Target = { name=unitName, level=unitLevel, guid=unitGuid, id = unitId }

		if  not UnitPlayerControlled(unit)  then
			MI2_Target.mobIndex = unitName..":"..unitLevel

			local mobData, fromCache = MI2_FetchMobDataFromGUID(unitGuid, unitLevel, unitId, unit)
			if not fromCache and mobData
			then
				MI2_CacheMobInfo(unitGuid, unitName, unitLevel, mobData, unitIsClose, UnitClassification)
			else
				if unitIsClose then
					MI2_RecordLocation( unitGuid )
				end
			end
			if unitLevel < (UnitLevel("player") + 5) then MI2_Target.ResOk = true end
		end
	else
		MI2_Target = {}
	end
	MobHealth_Display()
	-- update options dialog if shown
    if  MI2_OptionsFrame:IsVisible()  then
		MI2_DbOptionsFrameOnShow()
	end

    midebug( "new target: idx=[nil], last=["..(MI2_LastTargetIdx.name or "nil").."]", 1 )
end


-- abbreviated list from KarniCrap's lib_Tradskills.lua
-- used without permission o_O

KarniCrap_tradeskillList = {
	[49383] = "Engineering",		-- skin mob
	[32606] = "Mining",				-- skin mob
-- Herb Gathering
    [32605] = "Herb Gathering",     -- herb mob
	[2366]  = "Herb Gathering", 	-- Apprentice
	[2368]  = "Herb Gathering", 	-- Journeyman
	[3570]  = "Herb Gathering", 	-- Expert
	[11993] = "Herb Gathering", 	-- Artisan
	[28695] = "Herb Gathering", 	-- Master
	[50300] = "Herb Gathering", 	-- Grand Master
	[74519] = "Herb Gathering", 	-- Illustrious
-- Skinning
	[8613]  = "Skinning", 			-- Apprentice
	[8617]  = "Skinning", 			-- Journeyman
	[8618]  = "Skinning",			-- Expert
	[10768] = "Skinning", 			-- Artisan
	[32678] = "Skinning", 			-- Master
	[50305] = "Skinning", 			-- Grand Master
	[74522] = "Skinning", 			-- Illustrious
    [158756] = "Skinning",          -- Draenor Master
    [195125] = "Skinning",          -- Legion Master
	[195258] = "Skinning",          -- Mother's Skinning Knife
}

-----------------------------------------------------------------------------
-- MI2_EventSpellStart()
--
-- handler for event "UNIT_SPELLCAST_START"
-- store the latest info used for determining node info for source
--
local function MI2_EventSpellStart(self, event, caster, spell, id)
	if caster=="player" then
		-- keep track of the tooltip title and first line of text to capture node info
		-- in some cases it might either pick the wrong text (if multiple game objects are close) or
		-- when you move and while for example gathering is 'active' (it will hide the gametooltip)
		MI2_GT_SpellId = id
		MI2_GT_Title= GameTooltipTextLeft1:GetText()
	end
end -- MI2_EventSpellStart()

-----------------------------------------------------------------------------
-- MI2_EventSpellSucceeded()
--
-- handler for event "UNIT_SPELLCAST_SUCCEEDED"
-- checks for successfully skinning, mining, or herbalizing a mob
--
local function MI2_EventSpellSucceeded(self, event, caster, spell, id)
	if caster=="player" and MI2_Target.mobIndex then
	-- the spell was cast on a mob... is it a tradeskill?
		-- link = GetSpellLink(id)
		-- printfd("%s successfully cast %s (id: %s)", caster or 'nil',link or 'nil',id or 'nil')
		if KarniCrap_tradeskillList[id] then
			--printfd("%s successfully used %s (id: %s) on mob", caster or 'nil',link or 'nil',id or 'nil')
			MI2_TradeskillUsed = id
		end
	end
end -- MI2_EventSpellSucceeded()

-----------------------------------------------------------------------------
-- MI2_EventCreatureDiesXP()
--
-- event handler for "CHAT_MSG_COMBAT_XP_GAIN" event
-- indicates that a mob died and gave XP points
--
function MI2_EventCreatureDiesXP(self, event, ...)
	local message = ...
	local _,_, creature, xp = string.find( message, MI2_ChatScanStrings[3] )
	if creature and xp then
		--printf("kill event with XP: mob="..creature..", xp="..xp..message )
		MI2_RecordKilledXP( creature, tonumber(xp) )
	end
end -- MI2_EventCreatureDiesXP()

-----------------------------------------------------------------------------
-- event handler for "CHAT_MSG_MONSTER_EMOTE" event
--
local function MI2_EventMonsterEmote(self, event, ...)
	local message, sender = ...
	local s = string.find( message, MI2_CHAT_MOBRUNS )
	if s then
		MI2_RecordLowHpAction( sender, 1 )
	end
end


-----------------------------------------------------------------------------
-- event handler for "ZONE_CHANGED_NEW_AREA" and "ZONE_CHANGED_INDOORS"
-- this is processed for mob location tracking so that we know the zone
--
local function MI2_EventZoneChanged(self, event, ...)
	MI2_SetNewZone( GetZoneText() )
end -- MI2_EventZoneChanged()


-----------------------------------------------------------------------------
-- MI2_Player_Login()
--
-- register the GameTooltip:OnShow event at player login time. This ensures
-- that MobInfo is the (hopefully) last AddOn to hook into this event.
--
local function MI2_Player_Login(self, event, ...)
	-- set current zone
	MI2_EventZoneChanged()

	-- scan spellbook to fill spell to school conversion table
	MI2_ScanSpellbook()

	chattext( "MobInfo2  "..MI2_VersionNum.."  Loaded,  ".."enter /mi2 or /mobinfo for interface")

	-- collect all the garbage caused by loading the AddOn
	collectgarbage( "collect" )
end -- MI2_Player_Login()

-----------------------------------------------------------------------------
-- MI2_Player_Logout()
--
-- Encode MI2_DB on log out
--
local function MI2_Player_Logout(self, event, ...)
	if MobInfoConfig.SaveCompressed == 1 then
		for k,v in pairs(MI2_DB.character) do
			if type(v) == "table" then
				MI2_DB.character[k] = MI2_Encode(v)
			end
		end
		if type(MI2_DB.source) == "table" then
			MI2_DB.source = MI2_Encode(MI2_DB.source)
		end
		if type(MI2_DB.location) == "table" then
			MI2_DB.location = MI2_Encode(MI2_DB.location)
		end
		if type(MI2_ItemNameTable) == "table" then
			MI2_ItemNameTable = MI2_Encode(MI2_ItemNameTable)
		end
		if type(MI2_UnitId2Name) == "table" then
			MI2_UnitId2Name = MI2_Encode(MI2_UnitId2Name)
		end
		if type(MI2_CurrencyNameTable) == "table" then
			MI2_CurrencyNameTable = MI2_Encode(MI2_CurrencyNameTable)
		end
		if type(MI2_CharTable) == "table" then
			MI2_CharTable = MI2_Encode(MI2_CharTable)
		end
		if type(MI2_ZoneTable) == "table" then
			MI2_ZoneTable = MI2_Encode(MI2_ZoneTable)
		end
		if type(MI2_RecentLoots) == "table" then
			MI2_RecentLoots = MI2_Encode(MI2_RecentLoots)
		end
	end

end -- MI2_Player_Logout()

-----------------------------------------------------------------------------
-- MI2_OnTooltipSetItem
--
-- OnTooltipSetItem event handler for the GameTooltip frame
-- This handler will :
--   * if a known item is hovered add the corresponding item data
--   * call the original handler which it replaces
--
function MI2_OnTooltipSetItem( ... )
	-- call original WoW event for OnTooltipSetItem
	if MI2_TT_SetItem then
		MI2_TT_SetItem(...)
	end

	if MobInfoConfig.KeypressMode == 1 and not IsAltKeyDown() then  return  end

	local tooltip, tooltipData = ...
	local _, itemLink
	if MobInfoConfig.ShowItemInfo == 1 then
		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and tooltip ~= GameTooltip then
			itemLink = tooltipData.hyperlink
			if not itemLink and tooltipData.guid then
				itemLink = C_Item.GetItemLinkByGUID(tooltipData.guid)
			end
		else
			_, itemLink = tooltip:GetItem()
		end
		if itemLink then
			-- add item loot info to item tooltip
			MI2_BuildItemDataTooltip( tooltip, itemLink  )
		end
	end
end -- MI2_OnTooltipSetItem()


-----------------------------------------------------------------------------
-- MI2_InitializeEventTable()
--
-- This function enables (ie. registers) only those events that are
-- needed for the current MobInfo recording options. The general rule is
-- that we only register events if we want to record the data of the event.
--
function MI2_InitializeEventTable(self)
	-- reset all events to their always on flag state
	for eventName, eventInfo in pairs(MI2_EventHandlers) do
		local eventEnabled = eventInfo.always or MobInfoConfig.SaveBasicInfo == 1 
			and (eventInfo.basic
				or MobInfoConfig.SaveCharData == 1 and eventInfo.char
				or MobInfoConfig.SaveItems == 1 and eventInfo.items)
		if eventEnabled then
			self:RegisterEvent( eventName )
		else
			self:UnregisterEvent( eventName )
		end
	end
end -- MI2_InitializeEventTable()


-----------------------------------------------------------------------------
-- MI2_OnEvent()
--
-- MobInfo main event handler function, gets called for all registered events
-- uses table with event handler info
--
function MI2_OnEvent(self, event, ...)	
	--midebug("event="..event..", a1="..(arg1 or "<nil>")..", a2="..(arg2 or "<nil>")..", a3="..(arg3 or "<nil>")..", a4="..(arg4 or "<nil>"))
	MI2_EventHandlers[event].f(self, event, ...)
end -- MI2_OnEvent

-----------------------------------------------------------------------------
-- MI2_OnCombatLogEvent()
--
-- MobInfo main event handler function, gets called for all registered events
-- uses table with event handler info
--
MI2_AttackedGUIDs = {}
function MI2_OnCombatLogEvent(self, event, ...)
	--time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetRaidFlags, spellId, spellName, spellType, amount, overkill, school, resisted, blocked, absorbed, critical, glacing, crushing, isoffhand, isreflected

	local timestamp, subEvent, hideCaster, sourceGUID, sourceName,
	 sourceFlags, sourceRaidFlags, destGUID, destName, destFlags,
	 destRaidFlags, amount_spellId, overkill_spellName, school_spellSchool, resisted_amount,
	 blocked_overkill, absorbed_school, critical_resisted, glancing_blocked, crushing_absorbed,
	 isOffHand_critical,  glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()
	--midebug("@event="..subEvent..", sourceGUID="..(sourceGUID or "<nil>")..", sourceName="..(sourceName or "<nil>")..", destGUID="..(destGUID or "<nil>")..", destName="..(destName or "<nil>")..", destFlags="..(destFlags or "<nil>")..", amount_spellid="..(amount_spellId or "<nil>")..", overkill_spellname="..(overkill_spellName or "<nil>")..", school_spellSchool="..(school_spellSchool or "<nil>")..", resisted_amount="..(resisted_amount or "<nil>")..", blocked_overkill="..(blocked_overkill or "<nil>"))

	if destGUID ~= nil
	then
		local guidType = select(1,strsplit("-", destGUID))
		if UnitGUID("player") == destGUID then
			--print(subEvent.." sid:"..(amount_spellId or "~").." ra:"..(tostring(resisted_amount or "~")).." cr:"..(tostring(critical_resisted or "~")))
			local damage
			if subEvent == "SWING_DAMAGE" and not critical_resisted then
				damage = amount_spellId
			elseif (subEvent=="SPELL_PERIODIC_DAMAGE" or subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE") and not isOffHand_critical then
				damage = resisted_amount
			end
			if damage and damage > 0 then
				MI2_RecordDamage( sourceGUID, tonumber(damage) )
			end
		elseif (guidType ~= "Player" and guidType ~= "Pet")
		then
--		    print(subEvent.." sid:"..(amount_spellId or "~").." ra:"..(resisted_amount or "~").." cr:"..(tostring(critical_resisted) or "~"))
			-- When any damage is done by player or player's pet, record the mob
			if ((subEvent=="SPELL_PERIODIC_DAMAGE" or subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE") and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")))
			then
				local damage, sp, sc
				if subEvent == "SWING_DAMAGE" then 
--					print(subEvent.." "..amount_spellId.." / "..(overkill_spellName or '~'))
					damage = amount_spellId
				else
					--print(subEvent.." "..resisted_amount.." / "..(blocked_overkill or '~').." > "..amount_spellId..","..school_spellSchool)
					damage = resisted_amount
					sp = amount_spellId
					sc = school_spellSchool
				end
				if damage and damage > 0 then
					MI2_RecordHit(destGUID, damage, sp, sc, subEvent == "SPELL_PERIODIC_DAMAGE" )
				else
					print("@!@Resists "..(sp or "<nil>").." "..(sc or "<nil>"))
					MI2_RecordImmunResist( destGUID, spell, isResist )
				end
				MI2_AttackedGUIDs[destGUID] = true
			elseif (subEvent=="SPELL_MISSED" and resisted_amount == "IMMUNE") then
			--	print(subEvent)
			--	print("@!@Resists "..(amount_spellId or "<nil>").." "..(school_spellSchool or "<nil>"))
			--	midebug("@event="..subEvent..", sourceGUID="..(sourceGUID or "<nil>")..", sourceName="..(sourceName or "<nil>")..", destGUID="..(destGUID or "<nil>")..", destName="..(destName or "<nil>")..", destFlags="..(destFlags or "<nil>")..", amount_spellid="..(amount_spellId or "<nil>")..", overkill_spellname="..(overkill_spellName or "<nil>")..", school_spellSchool="..(school_spellSchool or "<nil>")..", resisted_amount="..(resisted_amount or "<nil>")..", blocked_overkill="..(blocked_overkill or "<nil>"))
			elseif (subEvent=="PARTY_KILL" and (MobInfoConfig.SaveAllPartyKills or 0) == 1)
			then
				--printf("Saved kill for %s - %s by %s", guidType, destName, sourceName)
				MI2_AttackedGUIDs[destGUID] = true
			elseif (subEvent=="UNIT_DIED" and destGUID ~= nil and MI2_AttackedGUIDs[destGUID] == true)
			then
				MI2_RecordKill(destGUID,destName)
				MI2_AttackedGUIDs[destGUID] = nil
			end
		end
	end 
end -- MI2_OnCombatLogEvent

function MI2_OnPlayerRegenEnabled(self, event, ...)
	-- reset AttackedGUIDs cache
	MI2_AttackedGUIDs = {}
end

-----------------------------------------------------------------------------
-- MI2_OnLoad()
--
-- Set up main event handler table and do stuff that must be done before
-- "VARIABLES_LOADED" is called.
--
function MI2_OnLoad(self)
	-- main MobInfo event handler table
	-- "f"=function to call, "always"=event always on flag, "basic"=mob basic info event, 
	-- "items"=item tracking event, "loc"=mob location event, "char"=char specific event
	MI2_EventHandlers = {
		VARIABLES_LOADED = {f=MI2_VariablesLoaded},
		COMBAT_LOG_EVENT_UNFILTERED = {f=MI2_OnCombatLogEvent, always=1},

		PLAYER_TARGET_CHANGED = {f=MI2_OnTargetChanged, always=1},
		PLAYER_LOGIN = {f=MI2_Player_Login, always=1},
		PLAYER_LOGOUT = {f=MI2_Player_Logout, always=1},
		CHAT_MSG_COMBAT_XP_GAIN = {f=MI2_EventCreatureDiesXP, basic=1},
		ZONE_CHANGED_NEW_AREA = {f=MI2_EventZoneChanged, basic=1},
		ZONE_CHANGED_INDOORS = {f=MI2_EventZoneChanged, basic=1},
		CHAT_MSG_MONSTER_EMOTE = {f=MI2_EventMonsterEmote, basic=1},
		LOOT_READY = {f=MI2_EventLootReady, basic=1, items=1},
		LOOT_CLOSED = {f=MI2_EventLootClosed, basic=1, items=1},

		ITEM_LOCKED = {f=MI2_ItemLocked, basic=1, items=1},
		ITEM_UNLOCKED = {f=MI2_ItemUnlocked, basic=1, items=1},

		UNIT_SPELLCAST_START ={f=MI2_EventSpellStart, char=1},
		UNIT_SPELLCAST_CHANNEL_START ={f=MI2_EventSpellStart, char=1},
		UNIT_SPELLCAST_SUCCEEDED ={f=MI2_EventSpellSucceeded, char=1},
		PLAYER_REGEN_ENABLED = {f=MI2_OnPlayerRegenEnabled, always=1}
	}

	MI2_ChatScanStrings = {
		[1] = OPEN_LOCK_SELF,
		[2] = SELFKILLOTHER,
		[3] = COMBATLOG_XPGAIN_FIRSTPERSON,
		[4] = COMBATHITSELFOTHER,
		[5] = COMBATHITCRITSELFOTHER,
		[6] = SPELLLOGSELFOTHER,
		[7] = SPELLLOGSCHOOLSELFOTHER,
		[8] = SPELLLOGCRITSELFOTHER,
		[9] = PERIODICAURADAMAGESELFOTHER,
		[10] = COMBATHITOTHEROTHER,
		[11] = COMBATHITCRITOTHEROTHER,
		[12] = SPELLLOGOTHEROTHER,
		[13] = SPELLLOGCRITOTHEROTHER,
		[14] = IMMUNESPELLSELFOTHER,
		[15] = SPELLIMMUNESELFOTHER,
		[16] = SPELLRESISTSELFOTHER,
		[17] = SPELLLOGCRITSCHOOLSELFOTHER,
		[18] = AURAADDEDOTHERHARMFUL, }

	for idx, scanString in pairs(MI2_ChatScanStrings) do
		scanString = string.gsub(scanString, "%(", "%%%(")
		scanString = string.gsub(scanString, "%)", "%%%)")
		scanString = string.gsub(scanString, "(%%s)", "%(%.%+%)")
		scanString = string.gsub(scanString, "(%%%d$s)", "%(%.%+%)")
		scanString = string.gsub(scanString, "(%%d)", "%(%%%d%+%)")
		scanString = string.gsub(scanString, "(%%%d$d)", "%(%%%d%+%)")
		MI2_ChatScanStrings[idx] = scanString
	end

	-- process no other events until "VARIABLES_LOADED"
	self:RegisterEvent("VARIABLES_LOADED")

	-- prepare for importing external database data
	-- this must be done before "VARIABLES_LOADED" overwrites import data
	MI2_PrepareForImport()
	MI2_DeleteAllMobData()

	-- set some stuff that is needed (only) for improved compatibility
	-- to other AddOns wanting to use MobHealth info
	if  not MobHealth_OnEvent  then
		MobHealthFrame = "MI2"
		MobHealth_OnEvent = MI2_OnEvent
	end
end -- MI2_OnLoad()
