--
-- MI2_Slash.lua
--
-- Handle all slash commands and the actions performed by slash commands.
-- All option dialog settings use slash commands for performing their
-- actions.
--
-- Note: version history now located in ReadMe.txt
--

local ADDON_NAME = ...

local MI2_DeleteMode = ""

-- defaults for all MobInfo config options
local MI2_TTDefaults = {
	ShowHealth=1, ShowMana=0, ShowXp=1, ShowNo2lev=1, ShowKills=0, ShowLoots=1, ShowTotal=1, 
	ShowCoin=0, ShowIV=0, ShowEmpty=0, ShowLowHpAction=1, ShowCloth=1, ShowDamage=1,
	ShowDps=1, ShowLocation=1, ShowQuality=1, ShowResists=1, ShowImmuns=1, ShowItems=1,
	ShowClothSkin=1, ShowIGrey=0, ShowIWhite=1, ShowIGreen=1, ShowIBlue=1, ShowIPurple=1, ShowClass= 1 } 


-----------------------------------------------------------------------------
-- MI2_SlashAction_Default()
--
-- Default tooltip content settings
--
function MI2_SlashAction_Default()
	local idx, def
	for idx,def in pairs(MI2_TTDefaults) do
		MobInfoConfig[idx] = def
	end
end -- MI2_SlashAction_Default


-----------------------------------------------------------------------------
-- MI2_SlashAction_AllOn()
--
-- Show all tooltip content
--
function MI2_SlashAction_AllOn()
	local idx,def
	for idx,def in pairs(MI2_TTDefaults) do
		MobInfoConfig[idx] = 1
	end
end -- MI2_SlashAction_AllOn


-----------------------------------------------------------------------------
-- MI2_SlashAction_AllOff()
--
-- Show no extra info in tooltip
--
function MI2_SlashAction_AllOff()
	local idx,def
	for idx,def in pairs(MI2_TTDefaults) do
		MobInfoConfig[idx] = 0
	end
end -- MI2_SlashAction_AllOff


-----------------------------------------------------------------------------
-- MI2_RegisterWithAddonManagers()
--
function MI2_RegisterWithAddonManagers(self)

	local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)
	local LDBIcon = LibStub("LibDBIcon-1.0", true)
	if LDB
	then
		local plugin = LDB:NewDataObject(ADDON_NAME, {
			type = "launcher",
			OnClick =	function(_, button)
							if button=="RightButton" then
								if MI2_SummaryFrame then
									if MI2_SummaryFrame:IsVisible()	then
										MI2_SummaryFrame:Hide()
									else
										MI2_SummaryFrame:Show()
									end
								end
							else
								if MI2_OptionsFrame then
									if MI2_OptionsFrame:IsVisible() then
										MI2_OptionsFrame:Hide()
									else
										MI2_OptionsFrame:Show()
									end
								end
							end
						end,
			icon = "Interface\\CharacterFrame\\TemporaryPortrait-Monster",
			OnTooltipShow = function(f)
								if f and f.AddLine
								then
									f:AddLine(ADDON_NAME)
									f:AddLine(MI2_TXT_ToggleOptions)
									f:AddLine(MI2_TXT_ToggleSummary)
								end
							end
		})
		
		if LDBIcon
		then
			if not MobInfoConfig.minimapIcon
			then
				MobInfoConfig.minimapIcon = { minimapPos = 210, hide = MobInfoConfig.ShowMMButton == 0}
			end

			LDBIcon:Register(ADDON_NAME, plugin, MobInfoConfig.minimapIcon)
			MI2_OptMMButtonPos:Hide()
		end
	end
	
	if MobInfoConfig.ShowMMButton == 0 or LDBIcon
	then
		MI2_MinimapButton:Hide()
	end
	
end  -- MI2_RegisterWithAddonManagers()


-----------------------------------------------------------------------------
-- MI2_SlashAction_ClearTarget()
--
-- Clear MobInfo and MobHealth data for current target.
--
function MI2_SlashAction_ClearTarget()
	if MI2_Target and MI2_Target.level and MI2_Target.id and MI2_Target.name then
		MI2_DeleteMobData( MI2_Target.id, MI2_Target.level )
		MI2_Target = {}
		MI2_OnTargetChanged()
		MI2_DbOptionsFrameOnShow()
		chattext( "data for target "..MI_Green..MI2_Target.name..":"..MI2_Target.level.." ["..MI2_Target.id.."]"..MI_White.." has been deleted" )
	end
end  -- MI2_SlashAction_ClearTarget()


-----------------------------------------------------------------------------
-- MI2_Slash_ClearDbConfirmed()
--
-- Clear database handler : clear specific database if reqzested and 
-- confirmed by user.
--
local function MI2_Slash_ClearDbConfirmed()
	if MI2_DeleteMode == "MobDb" then
		local curZoneName = MI2_ZoneTable[MI2_CurZone]
		MI2_DeleteAllMobData()
		MI2_ZoneTable[MI2_CurZone] = curZoneName
		MobInfoConfig.ImportSignature = ""
	end
	chattext( "database deleted: "..MI2_DeleteMode )
	MI2_Target = {}
	MI2_OnTargetChanged()
	MI2_DbOptionsFrameOnShow()
	collectgarbage( "collect" )
end  -- MI2_Slash_ClearDbConfirmed()


-----------------------------------------------------------------------------
-- MI2_SlashAction_ClearHealthDb()
--
-- Clear entire contents of MobInfo and MobHealth databases.
-- Ask for confirmation before performing the clear operation.
--
function MI2_SlashAction_ClearHealthDb(self)
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].text = MI_TXT_CLR_ALL_CONFIRM.."'"..MI2_OPTIONS[self:GetName()].help.."' ?"
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].OnAccept = MI2_Slash_ClearDbConfirmed
	MI2_DeleteMode = "HealthDb"
	local dialog = StaticPopup_Show( "MOBINFO_CONFIRMATION", "")
end  -- MI2_SlashAction_ClearHealthDb()


-----------------------------------------------------------------------------
-- MI2_SlashAction_ClearPlayerDb()
--
-- Clear entire contents of MobInfo and MobHealth databases.
-- Ask for confirmation before performing the clear operation.
--
function MI2_SlashAction_ClearPlayerDb(self)
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].text = MI_TXT_CLR_ALL_CONFIRM.."'"..MI2_OPTIONS[self:GetName()].help.."' ?"
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].OnAccept = MI2_Slash_ClearDbConfirmed
	MI2_DeleteMode = "PlayerDb"
	local dialog = StaticPopup_Show( "MOBINFO_CONFIRMATION", "")
end  -- MI2_SlashAction_ClearPlayerDb()


-----------------------------------------------------------------------------
-- MI2_SlashAction_ClearMobDb()
--
-- Clear entire contents of MobInfo and MobHealth databases.
-- Ask for confirmation before performing the clear operation.
--
function MI2_SlashAction_ClearMobDb(self)
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].text = MI_TXT_CLR_ALL_CONFIRM.."'"..MI2_OPTIONS[self:GetName()].help.."' ?"
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].OnAccept = MI2_Slash_ClearDbConfirmed
	MI2_DeleteMode = "MobDb"
	local dialog = StaticPopup_Show( "MOBINFO_CONFIRMATION", "")
end  -- MI2_SlashAction_ClearMobDb()


-----------------------------------------------------------------------------
-- MI2_Slash_TrimDownConfirmed()
--
-- Trim down the contents of the mob info database by removing all data
-- that is not set as being recorded. This function is called when the
-- user confirms the delete confirmation.
--
local function MI2_Slash_TrimDownConfirmed()
	-- loop through database and check each record
	-- remove all fields within the record where recording of the field is disabled
	for key, mobData in next, MI2_DB do
		for _, mobInfo in next, mobData do
			if  MobInfoConfig.SaveBasicInfo == 0 then
				mobInfo.bi = nil
				mobInfo.ml = nil
			end
			if  MobInfoConfig.SaveQualityData == 0 then
				mobInfo.qi = nil
			end
			if  MobInfoConfig.SaveItems == 0 then
				mobInfo.il = nil
			end
			if  MobInfoConfig.SaveResist == 0 then
				mobInfo.re = nil
			end
			if  MobInfoConfig.SaveCharData == 0 and key ~= "DatabaseVersion:0" then
				MI2_RemoveCharData( mobInfo )
			end
		end
	end

	if  MobInfoConfig.SaveItems == 0 then
		MI2_ItemNameTable = {}
	end

	-- char table can be deleted when not saving char specific data
	if  MobInfoConfig.SaveCharData == 0 then
		MI2_CharTable = { charCount = 0 }
	end

	-- force a cleanup after trimming down
	MI2_ClearMobCache()
	MI2_CheckAndCleanDatabases()
	collectgarbage( "collect" )

	MI2_DbOptionsFrameOnShow()
end -- MI2_Slash_TrimDownConfirmed()


-----------------------------------------------------------------------------
-- MI2_SlashAction_TrimDownMobData()
--
-- Trim down the contents of the mob info database by removing all data
-- that is not set as being recorded. Ask for a confirmation before
-- actually deleting anything.
--
function MI2_SlashAction_TrimDownMobData()
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].text = MI_TXT_TRIM_DOWN_CONFIRM
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].OnAccept = MI2_Slash_TrimDownConfirmed
	local dialog = StaticPopup_Show( "MOBINFO_CONFIRMATION", "")
end  -- MI2_SlashAction_TrimDownMobData()


-----------------------------------------------------------------------------
-- MI2_SlashAction_DeleteSearch()
--
-- Delete all Mobs in the search result list from the MobInfo database.
-- This function will ask for confirmation before deleting.
--
function MI2_SlashAction_DeleteSearch()
	local confirmationText = string.format( MI_TXT_DEL_SEARCH_CONFIRM, MI2_NumMobsFound )
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].text = confirmationText
	StaticPopupDialogs["MOBINFO_CONFIRMATION"].OnAccept = MI2_DeleteSearchResultMobs
	local dialog = StaticPopup_Show( "MOBINFO_CONFIRMATION", "")
end -- MI2_SlashAction_DeleteSearch()


-----------------------------------------------------------------------------
-- MI2_SlashInit()
--
-- Add all Slash Commands
--
function MI2_SlashInit()
	SlashCmdList["MOBINFO"] = MI2_SlashParse
	SLASH_MOBINFO1 = "/mobinfo" 
	SLASH_MOBINFO2 = "/mobinfo2" 
	SLASH_MOBINFO3 = "/mi2" 
end  -- MI2_SlashInit()


-----------------------------------------------------------------------------
-- MI2_SlashParse()
--
-- Parses the msg entered as a slash command. This function is also used
-- for the internal purpose of setting all options in the options dialog.
-- When used by the options dialog there is no need to actually update the
-- dialog, which is indicated by the "MI2_updateOptions" parameter.
--
-- FrameXML/Chatframe.lua gives us back only the parameter msg
-- ==> happens only when Mobinfo2 is called via command-line
-- ==> Therefor the optional variable self now the second in the function (only used, when config-parameters are changed)
--
function MI2_SlashParse(msg, self)
	-- extract option name and option argument from message string
	local _, _, cmd, param = string.find( string.lower(msg), "([%w_]*)[ ]*([-%w]*)") 

	-- handle all simple commands that dont require parsing right here
	-- handle show/hide of options dialog first of all
	if  not cmd  or  cmd == ""  or  cmd == "config"  then
		if MI2_OptionsFrame:IsVisible() then
			MI2_OptionsFrame:Hide()
		else
			MI2_OptionsFrame:Show()
		end
		return
	elseif cmd == 'version' then
		chattext( ' MobInfo-2 Version '..MI2_VersionNum )
		return
	elseif cmd == 'update' and MI2_UpdatePrices then
		MI2_UpdatePrices()
		return
	elseif cmd == 'summary' then
		if MI2_SummaryFrame:IsVisible() then
			MI2_SummaryFrame:Hide()
		else
			MI2_SummaryFrame:Show()
		end
		return
	elseif cmd == 'help' then
		chattext( ' Usage: enter /mobinfo2 or /mi2 to open interface' )
		return
	end

	-- search for the option data structure matching the command
	local optionName, optionData
	for idx, val in pairs(MI2_OPTIONS) do
		local lower_opt = string.lower( idx )
		local optionCommand = string.sub(lower_opt, 8)
		if cmd == lower_opt or cmd == optionCommand then
			optionName = string.sub(idx, 8)
			optionData = val
			break
		end
	end

	-- now call the option handler for the more complex commands
	if  optionData  then
		MI2_OptionParse( self, optionName, optionData, param )
	end
end -- of MI2_SlashParse()


-----------------------------------------------------------------------------
-- MI2_OptionParse()
--
-- Parses the more complex option toggle/set commands. There are 4
-- categories of options:
--   * options that can toggle between an on and off state
--   * options that represent a numeric value
--   * options that represent a text
--   * options that activate a special functionality represented by a
--     handler function that must correspond to a specific naming convention
--
function MI2_OptionParse( self, optionName, optionData, param )
	-- handle the option according to its option type: its either a
	-- switch being toggleg, a value being set, or a special action
	if optionData.val then
		-- it is a slider setting a value
		-- get new option value from parameter and set it
		local optValue = tonumber( param ) or 0
		MobInfoConfig[optionName] = optValue
		if  MI2_updateOptions  then
			chattext( optionData.text.." : "..MI_Green..optValue )
		end

	elseif optionData.txt then
		-- it is a text based option
		MobInfoConfig[optionName] = param
		if  MI2_updateOptions and optionData.text and optionData.text ~= "" then
			chattext( optionData.text.." : "..MI_Green..param )
		end

	elseif  MobInfoConfig[optionName]  then
		-- it is a switch toggle option:
		-- get current option value and toggle it to the opposite state (On<->Off)
		local valTxt = { val0 = "-OFF-",  val1 = "-ON-" }
		local optValue = MobInfoConfig[ optionName ]
		optValue = 1 - optValue  -- toggle option
		MobInfoConfig[optionName] = optValue
		if optionData.text and optionData.text ~= "" then
			chattext( optionData.text.." : "..MI_Green..valTxt["val"..optValue] )
		end

		-- some toggle switches control recording options which in turn controls events
		MI2_InitializeEventTable(self)
	else
		-- special action commands have a corresponding handler function
		local actionHandlerName = "MI2_SlashAction_"..optionName
		local actionHandler = _G[actionHandlerName]
		if  actionHandler  then
			actionHandler(self)
			MI2_updateOptions = true -- for AllOn, AllOff, etc.
		end
	end

	-- update position and visibility of minimap button
	-- (80/80 is circle radius, 50/52 is circle center)
	if optionName == "MMButtonPos" then
		local pos = MobInfoConfig.MMButtonPos
		MI2_MinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT",50 - (80 * cos(pos)), (80 * sin(pos)) - 52 )
	end

	if optionName == "ShowMMButton"
	then
		if MobInfoConfig.ShowMMButton == 1
		then
			local LDBIcon = LibStub("LibDBIcon-1.0", true)
			if LDBIcon
			then
				MobInfoConfig.minimapIcon.hide = false
				LDBIcon:Refresh(ADDON_NAME, MobInfoConfig.minimapIcon)
			else
				MI2_MinimapButton:Show()
			end
		else
			local LDBIcon = LibStub("LibDBIcon-1.0", true)
			if LDBIcon
			then
				MobInfoConfig.minimapIcon.hide = true
				LDBIcon:Refresh(ADDON_NAME, MobInfoConfig.minimapIcon)
			end
			MI2_MinimapButton:Hide()
		end
	end

	-- update everything that might depend on config actions
	MI2_MobHealth_SetPos()
	MI2_UpdateOptions()
	MI2_SetupTooltip()
end  -- MI2_OptionParse()

local function MI2_ImportTable(destinationTable,importTable)
	if importTable == nil or type(importTable) ~= "table" then return 0 end

	local addedItems = 0
	for id, idInfo in pairs(importTable) do
		if type(id) == "string" then
			for itemId, itemInfo in pairs(idInfo) do
				if not destinationTable[id][itemId] then
					destinationTable[id][itemId] = itemInfo
					addedItems = addedItems + 1
				end
			end
		elseif id ~= nil and not destinationTable[id] and not (destinationTable[MI2_Locale] and destinationTable[MI2_Locale][id]) then
			destinationTable[id] = idInfo
			addedItems = addedItems + 1
		end
	end
	return addedItems
end

-----------------------------------------------------------------------------
-- MI2_SlashAction_ImportMobData()
--
-- Import externally supplied MobInfo database into own database.
--
function MI2_SlashAction_ImportMobData()
	local newMobs, updatedMobs = 0, 0
	local oldCurZone = MI2_CurZone

	chattext( " starting external database import [1/3] ...." )

	-- import name tables
	local newItemNames = MI2_ImportTable(MI2_ItemNameTable, MI2_ItemNameTable_Import)
	local newCurrencyNames = MI2_ImportTable(MI2_CurrencyNameTable,MI2_CurrencyNameTable_Import)
	local newUnitNames = MI2_ImportTable(MI2_UnitId2Name,MI2_UnitId2Name_Import)

	chattext( " starting external database import [2/3] ...." )

	-- swap name/id in zone name table
	if MI2_ZoneTable_Import.cnt == nil then
		local newTable = {}
		local count = 0
		for zoneName, zoneId in pairs(MI2_ZoneTable_Import) do
			newTable[zoneId] = zoneName
		end
		MI2_ZoneTable_Import = newTable
		MI2_ZoneTable_Import.cnt = count
	end

	chattext( " starting external database import [3/3] ...." )

	local version = 0
	local locale
	if MI2_DB_Import.info then
		version = MI2_DB_Import.info.version
		locale = MI2_DB.info.locale
	else
		if MobInfoDB_Import and MobInfoDB_Import["DatabaseVersion:0"] then
			version = MobInfoDB_Import["DatabaseVersion:0"].ver
			locale = MobInfoDB_Import["DatabaseVersion:0"].loc
		end
	end

	if version == 9 then
		local db = CreateAndInitFromMixin(MI2_DatabaseMixin, MI2_DB_Import)
		db:Upgrade9to10(MobInfoDB_Import, true)
		MI2_DB_Import = db.db
		version = 10
	end

	if version == 10 then
		local db = CreateAndInitFromMixin(MI2_DatabaseMixin, MI2_DB_Import)
		db:Upgrade10to11(true)
		MI2_DB_Import = db.db
		version = 11
	end

	local dbImport = CreateAndInitFromMixin(MI2_DatabaseMixin, MI2_DB_Import)
	local db = CreateAndInitFromMixin(MI2_DatabaseMixin, MI2_DB)
	-- import Mobs into main Mob database
	for mobIndex, mobData in pairs(dbImport.db.source) do
		for mobLevel, mobInfo in pairs(mobData) do
			if type(mobLevel) == "number" then
				local mobId = mobIndex
				if type(mobId) == "string" then
					local ids = MI2_GetIdForName(mobIndex)
					if ids and #ids == 1 then
						mobId = ids[1]
					end
				end

				if MI2_DB.source[mobId] and MI2_DB.source[mobId][mobLevel] then
					updatedMobs = updatedMobs + 1
					if MobInfoConfig.ImportOnlyNew == 0 then
						-- import Mob that already exists
						local destination = db:Get(mobId, mobLevel, true, true)
						local importEntry = dbImport:Get(mobIndex, mobLevel, true, true)
						if destination ~= nil and importEntry ~= nil then
							-- if mapping was found, overwrite entry here too
							importEntry.id = mobId
							destination:Union(importEntry)
							destination:SaveAll()
						end
					end
				else
					-- import unknown Mob
					MI2_DB.source[mobId] = {}
					MI2_DB.source[mobId][mobLevel] = mobInfo
					-- import location information
					local importLocation = MI2_DB_Import.location[mobId]
					if importLocation then
						local zoneName = MI2_ZoneTable_Import[importLocation.zone[1]]
						if zoneName then
							MI2_DB.location[mobId] = CopyTable(MI2_DB_Import.location[mobIndex])
							MI2_DB.location[mobId].zone[1] = MI2_GetZoneId(zoneName)
						end
					end
					newMobs = newMobs + 1
				end
			else
				if not MI2_DB.source[mobIndex] then
					MI2_DB.source[mobIndex] = {}
				end
				MI2_DB.source[mobIndex][mobLevel] = mobInfo
			end
		end
	end

	MI2_BuildXRefItemTable()

	-- restore current zone ID after import
	MI2_CurZone = oldCurZone

	chattext( " imported "..newMobs.." new Mobs" )
	chattext( " imported "..newItemNames.." new loot items" )
	if MobInfoConfig.ImportOnlyNew == 0 then
		chattext( " updated data for "..updatedMobs.." existing Mobs" )
	else
		chattext( " did NOT update data for "..updatedMobs.." existing Mobs" )
	end

	-- update database options frame
	MobInfoConfig.ImportSignature = MI2_Import_Signature
	MI2_DbOptionsFrameOnShow()
end  -- MI2_SlashAction_ImportMobData()
