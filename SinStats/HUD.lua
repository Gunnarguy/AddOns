
local _, Ns = ...
local L = Ns.L
local statPool = {}
local PDFHooked
local classId = select(2, UnitClass("player"))
local rClass, gClass, bClass = GetClassColor(classId)
local setClassColor = { r=rClass, g=gClass, b=bClass, a=0}
Ns.eventChecked = false
Ns.RunCheck = nil
Ns.dataColor = ""
Ns.TextSep = ":"

local OpPoints = {
    TOPLEFT="BOTTOMLEFT",
    TOPRIGHT="BOTTOMRIGHT",
    TOP="BOTTOM",
}

Ns.HUDAnchor = nil

----------------------------------
--		Local Accociations		--
----------------------------------
local function CreateStat()
	if #statPool > 0 then
		local stat = statPool[1]
		tremove(statPool, 1)
		return stat
	end
	local f = SinStatsFrame.HUD:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	Mixin(f, Ns.StatMixin)
	f:SetVertexColor(1, 1, 1)
	f.ProfileSettings = {}
	return f
end

local function InsertStat(self, profile, statdata, statoptions)
	local newWidget = CreateStat()
	local newStat = { widget=newWidget, data=statdata, options=statoptions, func=Ns.FunctionList[statdata.stat], newcolumn=Ns.Profile.NewColumns and Ns.Profile.NewColumns[statdata.stat]}
	tinsert(self.StatList, newStat)
	newWidget:SetJustifyV("TOP")
	if profile.StatAlignment == "TOPLEFT" then
		newWidget:SetJustifyH("LEFT")
	elseif profile.StatAlignment == "TOP" then
		newWidget:SetJustifyH("CENTER")
	else
		newWidget:SetJustifyH("RIGHT")
	end
	newWidget:SetSize(0, 0)

	if statdata.events then
		for event, evendata in pairs(statdata.events) do
			if not Ns.EventList[event] then
				Ns.EventList[event] = {}
			end
			newStat.units = evendata
			tinsert(Ns.EventList[event], newStat)
		end
	end
	if statdata.onupdate then
		if statdata.updatespeed then
			Ns:RegisterForOtherUpdate(statdata.updatespeed, newStat)
		else
			tinsert(Ns.OnUpdateList, newStat)
		end
	end

	if profile.StatTextColor then
		if profile.ClassColors then
			newWidget:SetVertexColor(setClassColor.r, setClassColor.g, setClassColor.b)
		else
			newWidget:SetVertexColor(profile.StatTextColor.r, profile.StatTextColor.g, profile.StatTextColor.b)
		end
	end

	if profile.DataColor and profile.SplitColors then
		Ns.dataColor = CreateColor(profile.DataColor.r, profile.DataColor.g, profile.DataColor.b)
		Ns.dataColor = Ns.dataColor:GenerateHexColorMarkup()
	end

	

	if not profile.SplitColors then
		Ns.dataColor = ""
	end

	if profile.TextSeparator then
		Ns.TextSep = profile.TextSeparator
	end

end

local function PDFOnShow(self)
	if Ns.Profile.PanelDisplay then
		if not Ns.Profile.LockHUD then
			SinStatsFrame:Show()
		end
		SinStatsFrame.HUD:Show()
	end
end

local function PDFOnHide(self)
	if Ns.Profile.PanelDisplay then
		SinStatsFrame:Hide()
		SinStatsFrame.HUD:Hide()
	end
end

local function KillStat(stat)
	tinsert(statPool, stat.widget)
	wipe(stat.widget.ProfileSettings)
	stat.widget:Hide()
	stat.widget:ClearAllPoints()
end

------------------------------------------
--		Shared Functions and Data		--
------------------------------------------
-- Functions for controlling stat. display information (each stat. widget is assigned (Mixin() these functions)

Ns.StatMixin = {}
-- Adds Icon to displayed Text

function Ns.StatMixin.UpdateText(self, data, funcdata)

    local statName = Ns.Profile.StatTextAbreviate and L[data.stat.."Abrev"] or L[data.stat]
    if Ns.Profile.StatTextCaps then
        statName = strupper(statName)
    end
    if Ns.Profile.IconAlignment == "TOPLEFT" then
        self:SetText(format("%s %s"..Ns.TextSep..Ns.dataColor.." %s", self.ProfileSettings.Icon, statName, funcdata))
    else
        self:SetText(format("%s"..Ns.TextSep..Ns.dataColor.." %s %s", statName, funcdata, self.ProfileSettings.Icon))
    end


end

-- functions called in OnUpdate
Ns.OnUpdateList = {}
-- functions called in OnEvent
Ns.EventList = {}
-- Stat to default order entry num.
Ns.StatToDefaultOrder = {}

-- List of known player classes for this version order by ID
local byPlayerClassId

function Ns:GetSpellIcon(lookup, flags)
	local icon
	if type(lookup) == "table" then
		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
			if lookup.spell and not Ns.Band(flags, Ns.ForceIcon)  then
				icon = C_Spell.GetSpellInfo(lookup.spell)
				icon = icon.iconID
			elseif lookup.item and not Ns.Band(flags, Ns.ForceIcon)  then
				_,_,_,_,icon = C_Item.GetItemInfoInstant(lookup.item)
			elseif lookup.currency and not Ns.Band(flags, Ns.ForceIcon)  then
				icon = C_CurrencyInfo.GetCurrencyInfo(lookup.currency)
				icon = icon.iconFileID
			elseif lookup.icon then
				icon = lookup.icon
				if not icon or strtrim(icon) == "" then
					icon = "NoIcon"
				end
				if not strfind(icon, "\\") and not strfind(icon, "/") then
					icon = Ns.TexturePath .. icon
				end
			end
		else
			if lookup.spell and not Ns.Band(flags, Ns.ForceIcon)  then
				icon = select(3, GetSpellInfo(lookup.spell))
			elseif lookup.item and not Ns.Band(flags, Ns.ForceIcon)  then
				icon = select(5, GetItemInfoInstant(lookup.item))
			elseif lookup.currency and not Ns.Band(flags, Ns.ForceIcon)  then
				icon = C_CurrencyInfo.GetCurrencyInfo(lookup.currency)
				icon = icon.iconFileID
			elseif lookup.icon then
				icon = lookup.icon
				if not icon or strtrim(icon) == "" then
					icon = "NoIcon"
				end
				if not strfind(icon, "\\") and not strfind(icon, "/") then
					icon = Ns.TexturePath .. icon
				end
			end
		end
	else
		icon = lookup
	end
	if Ns.Band(flags, Ns.IgnoreFormat) then
		return icon
	end
	if icon then
		icon = "|T"..icon..":0|t"
	end
	return icon or ""
end

-- function Ns:GetStatColor(lookup, flags)
-- 	local statColors
-- 	if type(lookup) == "table" then
-- 		if lookup.options.Stat_Color then

-- 			--statColors = CreateColor(options.Stat_Color.r, options.Stat_Color.g, options.Stat_Color.b)
-- 			--print(lookup.options.Stat_Color.r)

-- 		else
-- 			return
-- 		end
-- 	else
-- 		statColors = lookup
-- 	end
-- 	if Ns.Band(flags, Ns.IgnoreColor) then
-- 		return statColors
-- 	end
-- 	if statColors then
-- 		statColors = statColors:GenerateHexColorMarkup()
-- 	end
-- 	return statColors or ""
-- end


function Ns:InitStat(self, profile, statdata)
	self.ProfileSettings.Icon = ""
	if profile.StatIcons and statdata.spell then
		self.ProfileSettings.Icon = Ns:GetSpellIcon(statdata)
	elseif profile.StatIcons and statdata.item then
		self.ProfileSettings.Icon = Ns:GetSpellIcon(statdata)
	elseif profile.StatIcons and statdata.currency then
		self.ProfileSettings.Icon = Ns:GetSpellIcon(statdata)
	end
	self:SetFont(Ns.LSM:Fetch("font", profile.StatFont), profile.StatFontSize, profile.StatFontFlags)
	--local h = self:GetHeight()
	self:SetText(" ")
	self:SetHeight(self:GetHeight())
	-- Other options

	--self.ProfileSettings.fontColor = Ns:GetStatColor(statdata)
	--print(self.ProfileSettings.fontColor)

	
end

function Ns:GetClass(class)
	if type(class) == "string" then
		return Ns.byPlayerClass[strupper(strtrim(class))]
	elseif type(class) == "number" then
		return byPlayerClassId[class]
	else
		print("Sinstats: No class listed for ", class)
	end
end

function Ns:FillDisplayOrder(orderedlist, profile, configfill)
	local added, removed
	if profile.CustomOrderList then
		for k, stat in ipairs(profile.CustomOrderList) do
			if profile.Stats[stat].Show then
				tinsert(orderedlist, Ns.DefaultOrder[Ns.StatToDefaultOrder[stat]])
			else
				removed = true
			end
		end
	end
	for k, v in ipairs(Ns.DefaultOrder) do
		if profile.Stats[v.stat].Show then
			local found
			if profile.CustomOrderList then
				for i, stat in ipairs(profile.CustomOrderList) do
					if stat == v.stat then
						found = true
						break
					end
				end
			end
			if not found then
				added = true
				if configfill then
					tinsert(orderedlist, { stat=v.stat, id=Ns.StatToDefaultOrder[v.stat], })
				else
					tinsert(orderedlist, v)
				end
			end
		end
	end
	return added, removed
end

function Ns:InitialiseVersionData()
	for k, v in ipairs(Ns.DefaultOrder) do
		Ns.StatToDefaultOrder[v.stat] = k
	end
end

function Ns:ResetHUD()
	Ns.Profile.HUDPos = Ns.Profile.HUDPos or {}
	wipe(Ns.Profile.HUDPos)
	Ns.Profile.HUDPos.point = "CENTER"
	Ns.Profile.HUDPos.y = 0
	Ns.Profile.HUDPos.x = 0
	Ns.Profile.HUDPos.scale = 1
end

function Ns.ResizeBackground(profile, NumCols, NumRows, onerow)
	if not profile then
		profile = Ns.Profile
	end
	--local statWidth = onerow and 0 or profile.StatWidth
	local width = 0
	local height = 0
	if onerow then
		width = SinStatsFrame.HUD.StatList[#SinStatsFrame.HUD.StatList].widget:GetRight() - SinStatsFrame.HUD.StatList[1].widget:GetLeft() + 25
		height = NumRows * (SinStatsFrame.HUD.StatList[1].widget:GetHeight() + profile.StatSpacingV)
	elseif NumCols > 1 then
		width = SinStatsFrame.HUD.StatList[#SinStatsFrame.HUD.StatList].widget:GetRight() - SinStatsFrame.HUD.StatList[1].widget:GetLeft()
	else
		for k, v in pairs(SinStatsFrame.HUD.StatList) do
			local w = v.widget:GetWidth()
			if w > width then
				width = w
			end
		end
		width = width + profile.StatSpacingH + 15
	end
	if not onerow then
		height = (NumRows * SinStatsFrame.HUD.StatList[1].widget:GetHeight()) + (NumRows - 1) * profile.StatSpacingV
	end
	height = height + 2
	SinStatsFrame.HUD.Background:SetSize(width, height)
	SinStatsFrame:SetWidth(width)
end

------------------------------------------
--		Initialise Stat. Widgets		--
------------------------------------------
function Ns:InitialiseProfile(profile)
	if not byPlayerClassId then
		byPlayerClassId = {}
		-- remove classes that don't exists in client version currently being played
		for k, v in pairs(Ns.byPlayerClass) do
			if not C_CreatureInfo.GetClassInfo(v) then
				Ns.byPlayerClass[k] = nil
			end
		end
		-- Build the list of classes by ID
		for k, v in pairs(Ns.byPlayerClass) do
			byPlayerClassId[v] = k
		end
	end
	SinStatsFrame.HUD.Background:SetAlpha((profile.HideHUD and 0) or profile.HUDBgAlpha or 0)
	if profile.HUDBgColor then
		SinStatsFrame.HUD.Background:SetVertexColor(profile.HUDBgColor.r, profile.HUDBgColor.g, profile.HUDBgColor.b)
	end
	if profile.LockHUD or profile.HideHUD then
		SinStatsFrame:Hide()
	else
		SinStatsFrame:Show()
	end
	if profile.ResetPosition then
		-- profile.ResetPosition = false
		-- Ns:ResetHUD()
		StaticPopupDialogs["SINSTATS_RESET"] = {
			text = L["ResetPosition"],
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				profile.ResetPosition = false
				Ns:ResetHUD()
				Ns:InitialiseProfile(Ns.Profile)
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = false,
			OnCancel = function() end,
		}

	end
	if not profile.HUDPos then
		Ns:ResetHUD()
	end
	Ns.LWin.RegisterConfig(SinStatsFrame, profile.HUDPos)
	Ns.LWin.RestorePosition(SinStatsFrame)

	
	if profile.PanelShow then

		if WOW_PROJECT_ID == 14 then

			local function statsShow()
				if CharacterFrameExpandButton and PaperDollFrame:IsVisible() then
					if not CharacterStatsPane:IsShown() then
							CharacterFrameExpandButton:Click()
					end
				end
			end

			PaperDollFrame:HookScript("OnShow", statsShow)

		end

	else
		if WOW_PROJECT_ID == 14 then

			local function statsHide()
				if CharacterFrameExpandButton and PaperDollFrame:IsVisible() then
					if CharacterStatsPane:IsShown() then
							CharacterFrameExpandButton:Click()
					end
				end
			end

			PaperDollFrame:HookScript("OnShow", statsHide)

		end
	end

	if profile.EventEnable and profile.EventWorld or profile.EventDungeon or profile.EventRaid or profile.EventPvP or profile.EventArena or profile.EventCombat then
		Ns.eventChecked = true
	end

	if Ns.sshMiniButton:IsButtonCompartmentAvailable() then
		if profile.CompButton then
			Ns.sshMiniButton:AddButtonToCompartment("SinStats")
		else
			Ns.sshMiniButton:RemoveButtonFromCompartment("SinStats")
		end
	end

	if profile.EventEnable then
		if not profile.EventWorld and not profile.EventDungeon and not profile.EventRaid and not profile.EventPvP and not profile.EventArena and not profile.EventCombat then
		profile.HideHUD = true
		SinStatsFrame.HUD:Hide()
		SinStatsFrame:Hide()
		--profile.LockHUD = true
		end

		local inInstance, instanceType = IsInInstance()
		if (profile.EventDungeon and instanceType == "party" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = false
			SinStatsFrame.HUD:Show()
			if not profile.LockHUD then SinStatsFrame:Show() end
		elseif (profile.EventDungeon and not inInstance and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		elseif (not profile.EventDungeon and Ns.eventChecked and instanceType == "party" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		end

		if (profile.EventRaid and instanceType == "raids" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = false
			SinStatsFrame.HUD:Show()
			if not profile.LockHUD then SinStatsFrame:Show() end
		elseif (profile.EventRaid and not inInstance and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		elseif (not profile.EventRaid and Ns.eventChecked and instanceType == "raids" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		end

		if (profile.EventPvP and instanceType == "pvp" and not profile.CharPanel and not profile.EventCombat ) then
			profile.HideHUD = false
			SinStatsFrame.HUD:Show()
			if not profile.LockHUD then SinStatsFrame:Show() end
		elseif (profile.EventPvP and not inInstance and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		elseif (not profile.EventPvP and Ns.eventChecked and instanceType == "pvp" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		end

		if (profile.EventArena and instanceType == "arena" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = false
			SinStatsFrame.HUD:Show()
			if not profile.LockHUD then SinStatsFrame:Show() end
		elseif (profile.EventArena and not inInstance and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		elseif (not profile.EventArena and Ns.eventChecked and instanceType == "arena" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		end

		if (profile.EventWorld and instanceType == "none" and not profile.CharPanel and not profile.EventCombat) then
			profile.HideHUD = false
			SinStatsFrame.HUD:Show()
			if not profile.LockHUD then SinStatsFrame:Show() end
		end

		if (Ns.Profile.EventCombat and not Ns.CharPanel and (not UnitAffectingCombat('player') or not InCombatLockdown())) then
			profile.HideHUD = true
			SinStatsFrame.HUD:Hide()
			if not profile.LockHUD then SinStatsFrame:Hide() end
		end

		if (Ns.Profile.EventCombat and not Ns.CharPanel and (UnitAffectingCombat('player') or InCombatLockdown())) then
			profile.HideHUD = false
			SinStatsFrame.HUD:Show()
			if not profile.LockHUD then SinStatsFrame:Show() end
		end
	end

	if profile.HUDStrata == nil then profile.HUDStrata = "MEDIUM" else SinStatsFrame.HUD:SetFrameStrata(profile.HUDStrata); SinStatsFrame:SetFrameStrata(profile.HUDStrata) end

	LibDBIcon10_SinStats:SetShown(profile.Minimap.Show)
	SinStatsFrame.HUD:UnregisterAllEvents() -- Stop event processing
	wipe(Ns.OnUpdateList)
	Ns:ClearOtherUpdates()
	wipe(Ns.EventList)
	for i=#SinStatsFrame.HUD.StatList, 1, -1 do
		KillStat(SinStatsFrame.HUD.StatList[i])
	end
	wipe(SinStatsFrame.HUD.StatList)
	-- Configure general Settings
	if profile.HideHUD then
		return
	end
	-- Configure Stats
	local orderedList = {}
	local oneRow = profile.NewColumns and true or false
	Ns:FillDisplayOrder(orderedList, profile, nil)
	local NumRows, NumCols, RowCount = 0, 1, 1
	for k, v in ipairs(orderedList) do
		if profile.Stats[v.stat] and profile.Stats[v.stat].Show then
			if profile.NewColumns and #SinStatsFrame.HUD.StatList > 1 then
				if not profile.NewColumns[v.stat] then
					oneRow = false
				else
					NumCols = NumCols + 1
				end
			end
			InsertStat(SinStatsFrame.HUD, profile, v, profile.Stats[v.stat])
		end
	end
	if #SinStatsFrame.HUD.StatList == 0 then
		return
	end
	local totalRows = #SinStatsFrame.HUD.StatList
	local firstOnRow, lastAnchor
	if totalRows > 0 then
		local rows = profile.StatRows or 1
		--local maxItemsPerRow = math.ceil(totalRows / rows)
		for k, v in ipairs(SinStatsFrame.HUD.StatList) do
			v.widget:ClearAllPoints()
			if not oneRow and NumCols > 1 then
				v.widget:SetWidth(profile.StatWidth or 100)
			end
			if k == 1 then
				v.widget:SetPoint("TOPLEFT", SinStatsFrame, "BOTTOMLEFT")
				firstOnRow = v.widget
				lastAnchor = v.widget
			else
				if v.newcolumn then
					v.widget:SetPoint("LEFT", firstOnRow, "RIGHT", profile.StatSpacingH, 0)
					firstOnRow = v.widget
--					NumCols = NumCols + 1
					RowCount = 1
				else
					oneRow = false
					v.widget:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -profile.StatSpacingV)
					RowCount = RowCount + 1
				end
			end
			lastAnchor = v.widget
			if RowCount > NumRows then
				NumRows = RowCount
			end
			v.widget:Show()
			Ns:InitStat(v.widget, profile, v.data)
		end
	end
	-- if NumCols == 1 and profile.StatAlignment ~= "TOPLEFT" then
        -- for i, v in ipairs(SinStatsFrame.HUD.StatList) do
            -- v.widget:ClearAllPoints()
            -- v.widget:SetPoint(profile.StatAlignment, i == 1 and SinStatsFrame or SinStatsFrame.HUD.StatList[i-1].widget, OpPoints[profile.StatAlignment], 0, i == 1 and 0 or -profile.StatSpacingV)

        -- end
    -- end
	if NumCols == 1 and profile.StatAlignment ~= "TOPLEFT" then
		for i, v in ipairs(SinStatsFrame.HUD.StatList) do
			v.widget:ClearAllPoints()
			v.widget:SetPoint(profile.StatAlignment, i == 1 and SinStatsFrame or SinStatsFrame.HUD.StatList[i-1].widget, OpPoints[profile.StatAlignment], 0, i == 1 and 0 or -profile.StatSpacingV)

		end
	elseif oneRow and profile.StatAlignment == "TOPRIGHT" then
		for i=#SinStatsFrame.HUD.StatList, 1, -1 do -- Anchor from last stat to first so we don't mess up the layout ordering!
			local v = SinStatsFrame.HUD.StatList[i]
			v.widget:ClearAllPoints()
			if i == #SinStatsFrame.HUD.StatList then
				v.widget:SetPoint("TOPRIGHT", SinStatsFrame, "BOTTOMRIGHT", 0, 0)
			else
				v.widget:SetPoint("RIGHT", SinStatsFrame.HUD.StatList[i + 1].widget, "LEFT", -profile.StatSpacingH, 0)
			end
		end
	end
	for event, widgets in pairs(Ns.EventList) do -- Start event processing
		for widget, widgetinfo in pairs(widgets) do
			if type(widgetinfo.units) == "table" then
				local units = { player=true, target=true }  -- only RegisterUnitEvent once with up to 2 units
				for _,unit in pairs(widgetinfo.units) do    -- Assumes event is not being used globaly
					units[unit] = true
					SinStatsFrame.HUD:GetScript("OnEvent")(SinStatsFrame.HUD, event, unit)
				end
				local unit1, unit2
				if units.player then
					unit1 = "player"
				end
				if units.target then
					if not unit1 then
						unit1 = "target"
					else
						unit2 = "target"
					end
				end
				SinStatsFrame.HUD:RegisterUnitEvent(event, unit1, unit2)
			else
				SinStatsFrame.HUD:RegisterEvent(event)
				SinStatsFrame.HUD:GetScript("OnEvent")(SinStatsFrame.HUD, event)
			end
		end
	end
	for event, eveninfo in pairs(Ns.GlobalEvents) do
		if type(eveninfo) == "table" then
			SinStatsFrame.HUD:RegisterUnitEvent(event, unpack(eveninfo)) -- Assumes event is not being used more that once globaly or in a stat's events={} list
			for _, unit in pairs(eveninfo) do
				SinStatsFrame.HUD:GetScript("OnEvent")(SinStatsFrame.HUD, event, unit)
			end
		else
			SinStatsFrame.HUD:RegisterEvent(event)
			SinStatsFrame.HUD:GetScript("OnEvent")(SinStatsFrame.HUD, event)
		end
	end
	SinStatsFrame.HUD.Elapsed = 0 -- Restarts OnUpdate
	SinStatsFrame.HUD:GetScript("OnUpdate")(SinStatsFrame.HUD, 10)
--	C_Timer.After(0, function()
		Ns.ResizeBackground(profile, NumCols, NumRows, oneRow)
--	end)
	SinStatsFrame.HUD:Show() -- Restarts OnUpdate
	
	if profile.PanelDisplay then
		if not PDFHooked then
			PDFHooked = true
			PaperDollFrame:HookScript("OnShow", PDFOnShow)
			PaperDollFrame:HookScript("OnHide", PDFOnHide)
		end
		if not PaperDollFrame:IsVisible() then
			SinStatsFrame:Hide()
			SinStatsFrame.HUD:Hide()
		end
		Ns.CharPanel = true
		SinStatsFrame:Hide()
		SinStatsFrame.HUD:Hide()
	else
		Ns.CharPanel = false
	end

end



