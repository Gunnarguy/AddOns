-- RaidHealerTracker.lua
-- Author: Copilot AI
-- Version: 1.0.0
-- Classic Anniversary 1.15.7 Compatible Raid Healer Tracker

-- Initialize main addon table
RaidHealerTracker = {}
local RHT = RaidHealerTracker

-- Addon name for event handling
local ADDON_NAME = "RaidHealerTracker"

-- Initialize default settings
RHT.defaults = {
    enabled = true,
    showFrame = true,
    maxHealers = 8,           -- Reduced for focus
    fontSize = 11,            -- Slightly larger for readability
    showSpellIcons = true,    
    showCastTimes = true,     
    showTargetHealth = true,  
    showProgressBars = true,  -- New: Visual cast progress bars
    compactMode = true,       -- New: Compact layout
    fadeOldHeals = true,      
    framePosition = {
        point = "TOPLEFT",
        relativePoint = "TOPLEFT", 
        xOffset = 20,         -- Moved closer to corner
        yOffset = -100
    },
    frameSize = {
        width = 260,          -- Much narrower (was 280)
        height = 170          -- Much more compact (was 200)
    }
}

-- Healing spell database for Classic (1.15.7)
RHT.healingSpells = {
    -- Priest Spells
    [2050] = { name = "Lesser Heal", class = "PRIEST", icon = 136052, castTime = 1.5 },
    [2054] = { name = "Heal", class = "PRIEST", icon = 135915, castTime = 3.0 },
    [2060] = { name = "Greater Heal", class = "PRIEST", icon = 135913, castTime = 3.0 },
    [596] = { name = "Prayer of Healing", class = "PRIEST", icon = 135943, castTime = 3.0 },
    [17] = { name = "Power Word: Shield", class = "PRIEST", icon = 135940, castTime = 0 },
    [139] = { name = "Renew", class = "PRIEST", icon = 135953, castTime = 0 },
    [6063] = { name = "Heal", class = "PRIEST", icon = 135915, castTime = 3.0 },
    [6064] = { name = "Heal", class = "PRIEST", icon = 135915, castTime = 3.0 },
    [6078] = { name = "Renew", class = "PRIEST", icon = 135953, castTime = 0 },
    [10963] = { name = "Greater Heal", class = "PRIEST", icon = 135913, castTime = 3.0 },
    [10964] = { name = "Greater Heal", class = "PRIEST", icon = 135913, castTime = 3.0 },
    [10965] = { name = "Greater Heal", class = "PRIEST", icon = 135913, castTime = 3.0 },
    [25314] = { name = "Greater Heal", class = "PRIEST", icon = 135913, castTime = 3.0 },
    [25210] = { name = "Greater Heal", class = "PRIEST", icon = 135913, castTime = 3.0 },
    
    -- Paladin Spells
    [635] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [639] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [647] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [1026] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [1042] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [3472] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [10328] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [10329] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [25292] = { name = "Holy Light", class = "PALADIN", icon = 135981, castTime = 2.5 },
    [19750] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    [19939] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    [19940] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    [19941] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    [19942] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    [19943] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    [27137] = { name = "Flash of Light", class = "PALADIN", icon = 135907, castTime = 1.5 },
    
    -- Druid Spells
    [774] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [1058] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [1430] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [2090] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [2091] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [3627] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [8910] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [9839] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [9840] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [9841] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [25299] = { name = "Rejuvenation", class = "DRUID", icon = 136081, castTime = 0 },
    [5185] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [5186] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [5187] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [5188] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [5189] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [6778] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [8903] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [9758] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [9888] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [9889] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [25297] = { name = "Healing Touch", class = "DRUID", icon = 136041, castTime = 3.5 },
    [740] = { name = "Tranquility", class = "DRUID", icon = 136107, castTime = 8.0 },
    [8918] = { name = "Tranquility", class = "DRUID", icon = 136107, castTime = 8.0 },
    [9862] = { name = "Tranquility", class = "DRUID", icon = 136107, castTime = 8.0 },
    [9863] = { name = "Tranquility", class = "DRUID", icon = 136107, castTime = 8.0 },
    
    -- Shaman Spells
    [331] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [332] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [547] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [913] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [939] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [959] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [8005] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [10395] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [10396] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [25357] = { name = "Healing Wave", class = "SHAMAN", icon = 136052, castTime = 3.0 },
    [8004] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [8008] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [8010] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [10466] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [10467] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [10468] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [25420] = { name = "Lesser Healing Wave", class = "SHAMAN", icon = 136043, castTime = 1.5 },
    [1064] = { name = "Chain Heal", class = "SHAMAN", icon = 136042, castTime = 2.5 },
    [10622] = { name = "Chain Heal", class = "SHAMAN", icon = 136042, castTime = 2.5 },
    [10623] = { name = "Chain Heal", class = "SHAMAN", icon = 136042, castTime = 2.5 },
    [25422] = { name = "Chain Heal", class = "SHAMAN", icon = 136042, castTime = 2.5 }
}

-- Data structures
RHT.activeCasts = {}          -- [casterGUID] = { spellID, targetGUID, startTime, endTime }
RHT.raidHealers = {}         -- List of healer GUIDs in raid
RHT.unitFrames = {}          -- UI frames for each healer

-- Initialize variables
RHT.frame = nil
RHT.scrollFrame = nil
RHT.lastUpdate = 0
RHT.isInitialized = false

-- Create main frame for events
local eventFrame = CreateFrame("Frame", "RaidHealerTrackerEventFrame", UIParent)
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if RHT[event] then
        RHT[event](RHT, ...)
    end
end)

-- Register necessary events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

-- Debug function
local function Debug(msg)
    if RHT.db and RHT.db.debug then
        print("|cFF00FF00[RaidHealerTracker]|r " .. tostring(msg))
    end
end

-- Utility Functions
local function GetPlayerClass(unit)
    if not unit or not UnitExists(unit) then return nil end
    local _, class = UnitClass(unit)
    return class
end

local function IsHealerClass(class)
    return class == "PRIEST" or class == "PALADIN" or class == "DRUID" or class == "SHAMAN"
end

local function GetColorForClass(class)
    local classColors = {
        PRIEST = { 1.0, 1.0, 1.0 },
        PALADIN = { 0.96, 0.55, 0.73 }, 
        DRUID = { 1.0, 0.49, 0.04 },
        SHAMAN = { 0.0, 0.44, 0.87 }
    }
    return classColors[class] or { 0.5, 0.5, 0.5 }
end

local function GetUnitByGUID(targetGUID)
    -- Check player first
    if UnitGUID("player") == targetGUID then
        return "player"
    end
    
    -- Check party members
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and UnitGUID(unit) == targetGUID then
            return unit
        end
    end
    
    -- Check raid members
    if IsInRaid() then
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) and UnitGUID(unit) == targetGUID then
                return unit
            end
        end
    end
    
    return nil
end

local function GetUnitName(targetGUID)
    local unit = GetUnitByGUID(targetGUID)
    if unit then
        return UnitName(unit)
    end
    return "Unknown"
end

local function GetHealthPercent(targetGUID)
    local unit = GetUnitByGUID(targetGUID)
    if unit then
        local current = UnitHealth(unit)
        local max = UnitHealthMax(unit)
        if max > 0 then
            return math.floor((current / max) * 100)
        end
    end
    return 0
end

-- Main Functions
function RHT:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then return end
    
    -- Initialize saved variables
    RaidHealerTracker_DB = RaidHealerTracker_DB or {}
    RHT.db = RaidHealerTracker_DB
    
    -- Set up defaults
    for key, value in pairs(RHT.defaults) do
        if RHT.db[key] == nil then
            RHT.db[key] = value
        end
    end
    
    Debug("Addon loaded successfully")
end

function RHT:PLAYER_ENTERING_WORLD()
    if not RHT.isInitialized then
        RHT:Initialize()
        RHT.isInitialized = true
    end
    RHT:UpdateRaidHealers()
end

function RHT:GROUP_ROSTER_UPDATE()
    RHT:UpdateRaidHealers()
end

function RHT:Initialize()
    RHT:CreateMainFrame()
    RHT:UpdateDisplay()
    Debug("Addon initialized")
end

function RHT:UpdateRaidHealers()
    table.wipe(RHT.raidHealers)
    
    -- Add player if healer
    local playerClass = GetPlayerClass("player")
    if IsHealerClass(playerClass) then
        table.insert(RHT.raidHealers, {
            guid = UnitGUID("player"),
            name = UnitName("player"),
            class = playerClass,
            unit = "player"
        })
    end
    
    if IsInRaid() then
        -- Raid group
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) then
                local class = GetPlayerClass(unit)
                if IsHealerClass(class) then
                    table.insert(RHT.raidHealers, {
                        guid = UnitGUID(unit),
                        name = UnitName(unit),
                        class = class,
                        unit = unit
                    })
                end
            end
        end
    elseif IsInGroup() then
        -- Party group
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                local class = GetPlayerClass(unit)
                if IsHealerClass(class) then
                    table.insert(RHT.raidHealers, {
                        guid = UnitGUID(unit),
                        name = UnitName(unit),
                        class = class,
                        unit = unit
                    })
                end
            end
        end
    end
    
    Debug("Found " .. #RHT.raidHealers .. " healers in group")
    RHT:UpdateDisplay()
end

-- Spell casting event handlers
function RHT:UNIT_SPELLCAST_START(unit, castGUID, spellID)
    if not RHT.healingSpells[spellID] then return end
    
    local casterGUID = UnitGUID(unit)
    if not casterGUID then return end
    
    -- Check if this unit is one of our tracked healers
    local isTrackedHealer = false
    for _, healer in ipairs(RHT.raidHealers) do
        if healer.guid == casterGUID then
            isTrackedHealer = true
            break
        end
    end
    
    if not isTrackedHealer then return end
    
    local targetGUID = UnitGUID(unit .. "target")
    if not targetGUID then return end
    
    local startTime = GetTime()
    local castTime = RHT.healingSpells[spellID].castTime
    local endTime = startTime + castTime
    
    RHT.activeCasts[casterGUID] = {
        spellID = spellID,
        targetGUID = targetGUID,
        startTime = startTime,
        endTime = endTime,
        castGUID = castGUID
    }
    
    Debug("Cast started: " .. RHT.healingSpells[spellID].name .. " by " .. UnitName(unit) .. " on " .. GetUnitName(targetGUID))
    RHT:UpdateDisplay()
end

function RHT:UNIT_SPELLCAST_STOP(unit, castGUID, spellID)
    self:RemoveCast(unit, castGUID)
end

function RHT:UNIT_SPELLCAST_FAILED(unit, castGUID, spellID)
    self:RemoveCast(unit, castGUID)
end

function RHT:UNIT_SPELLCAST_INTERRUPTED(unit, castGUID, spellID)
    self:RemoveCast(unit, castGUID)
end

function RHT:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellID)
    -- Keep the cast for a short time to show it completed
    -- It will be removed by the timer update
end

function RHT:RemoveCast(unit, castGUID)
    local casterGUID = UnitGUID(unit)
    if casterGUID and RHT.activeCasts[casterGUID] and RHT.activeCasts[casterGUID].castGUID == castGUID then
        RHT.activeCasts[casterGUID] = nil
        RHT:UpdateDisplay()
    end
end

-- Combat log for healing spells that completed
function RHT:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, amount, overhealing, absorbed, critical = CombatLogGetCurrentEventInfo()
    
    if (subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL") then
        -- Remove completed heals from active casts
        if RHT.activeCasts[sourceGUID] and RHT.activeCasts[sourceGUID].spellID == spellID then
            RHT.activeCasts[sourceGUID] = nil
            RHT:UpdateDisplay()
        end
    end
end

-- UI Creation Functions
function RHT:CreateMainFrame()
    if RHT.frame then return end
    
    -- Main frame with minimal styling
    RHT.frame = CreateFrame("Frame", "RaidHealerTrackerFrame", UIParent, "BackdropTemplate")
    RHT.frame:SetSize(RHT.db.frameSize.width, RHT.db.frameSize.height)
    RHT.frame:SetPoint(RHT.db.framePosition.point, UIParent, RHT.db.framePosition.relativePoint, RHT.db.framePosition.xOffset, RHT.db.framePosition.yOffset)
    
    -- Minimal backdrop for less distraction
    RHT.frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,        -- Thinner border (was 16)
        insets = { left = 2, right = 2, top = 2, bottom = 2 }  -- Smaller insets
    })
    RHT.frame:SetBackdropColor(0, 0, 0, 0.88)  -- Slightly more opaque
    RHT.frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)  -- Lighter, more subtle border
    
    -- Compact title
    local title = RHT.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", RHT.frame, "TOP", 0, -3)  -- Closer to top
    title:SetText("Healer Casts")
    title:SetTextColor(0.9, 0.9, 0.9)
    
    -- Content area with tighter spacing
    RHT.contentFrame = CreateFrame("Frame", nil, RHT.frame)
    RHT.contentFrame:SetPoint("TOPLEFT", RHT.frame, "TOPLEFT", 4, -16)  -- Tighter margins
    RHT.contentFrame:SetPoint("BOTTOMRIGHT", RHT.frame, "BOTTOMRIGHT", -4, 4)
    
    -- Make frame movable
    RHT.frame:SetMovable(true)
    RHT.frame:EnableMouse(true)
    RHT.frame:RegisterForDrag("LeftButton")
    RHT.frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    RHT.frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        RHT.db.framePosition.point = point
        RHT.db.framePosition.relativePoint = relativePoint
        RHT.db.framePosition.xOffset = xOffset
        RHT.db.framePosition.yOffset = yOffset
    end)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, RHT.frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", RHT.frame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        RHT:ToggleFrame()
    end)
    
    -- Update timer with higher frequency for smooth progress bars
    RHT.frame:SetScript("OnUpdate", function(self, elapsed)
        RHT.lastUpdate = RHT.lastUpdate + elapsed
        if RHT.lastUpdate >= 0.05 then -- 20 FPS for smooth progress
            RHT:UpdateCastTimes()
            RHT.lastUpdate = 0
        end
    end)
    
    if RHT.db.showFrame then
        RHT.frame:Show()
    else
        RHT.frame:Hide()
    end
end

function RHT:UpdateDisplay()
    if not RHT.contentFrame then return end
    
    -- Clear existing frames
    for _, frame in pairs(RHT.unitFrames) do
        frame:Hide()
    end
    table.wipe(RHT.unitFrames)
    
    local yOffset = 0
    local frameHeight = 16  -- Even more compact (was 18)
    local padding = 1       -- Minimal padding
    
    -- Calculate optimal frame height based on content
    local maxDisplayed = math.min(#RHT.raidHealers, RHT.db.maxHealers)
    local contentHeight = (frameHeight * maxDisplayed) + (padding * (maxDisplayed - 1)) + 20  -- +20 for title
    
    -- Dynamically resize frame to fit content
    if contentHeight < RHT.db.frameSize.height then
        RHT.frame:SetHeight(contentHeight)
    else
        RHT.frame:SetHeight(RHT.db.frameSize.height)
    end

    -- Sort healers by activity (active casts first)
    local sortedHealers = {}
    for _, healer in ipairs(RHT.raidHealers) do
        table.insert(sortedHealers, healer)
    end
    
    table.sort(sortedHealers, function(a, b)
        local aCasting = RHT.activeCasts[a.guid] ~= nil
        local bCasting = RHT.activeCasts[b.guid] ~= nil
        if aCasting ~= bCasting then
            return aCasting -- Active casts first
        end
        return a.name < b.name -- Alphabetical for non-casting
    end)
    
    for i, healer in ipairs(sortedHealers) do
        if i > RHT.db.maxHealers then break end
        
        -- Create compact healer frame
        local healerFrame = CreateFrame("Frame", nil, RHT.contentFrame)
        healerFrame:SetSize(RHT.db.frameSize.width - 10, frameHeight)
        healerFrame:SetPoint("TOPLEFT", RHT.contentFrame, "TOPLEFT", 0, -yOffset)
        
        -- Class color indicator (small left border)
        local classIndicator = healerFrame:CreateTexture(nil, "BACKGROUND")
        classIndicator:SetSize(3, frameHeight)
        classIndicator:SetPoint("LEFT", healerFrame, "LEFT", 0, 0)
        local r, g, b = unpack(GetColorForClass(healer.class))
        classIndicator:SetColorTexture(r, g, b, 0.8)
        healerFrame.classIndicator = classIndicator
        
        -- Healer name (compact)
        local nameText = healerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameText:SetPoint("LEFT", healerFrame, "LEFT", 6, 0)
        nameText:SetFont("Fonts\\FRIZQT__.TTF", RHT.db.fontSize - 1, "OUTLINE")
        nameText:SetTextColor(r, g, b)
        nameText:SetText(healer.name:sub(1, 8)) -- Truncate long names
        healerFrame.nameText = nameText
        
        -- Progress bar background (smaller)
        local progressBG = healerFrame:CreateTexture(nil, "BACKGROUND")
        progressBG:SetSize(110, 10)  -- Smaller progress bar (was 120x12)
        progressBG:SetPoint("LEFT", nameText, "RIGHT", 4, 0)
        progressBG:SetColorTexture(0.15, 0.15, 0.15, 0.9)  -- Darker background
        healerFrame.progressBG = progressBG
        
        -- Progress bar
        local progressBar = healerFrame:CreateTexture(nil, "ARTWORK")
        progressBar:SetHeight(10)  -- Match new height
        progressBar:SetPoint("LEFT", progressBG, "LEFT", 0, 0)
        progressBar:SetColorTexture(0, 0.8, 0, 0.9)
        healerFrame.progressBar = progressBar
        
        -- Cast text (spell → target)
        local castText = healerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        castText:SetPoint("LEFT", progressBG, "LEFT", 2, 0)
        castText:SetFont("Fonts\\FRIZQT__.TTF", RHT.db.fontSize - 3, "OUTLINE")  -- Smaller text
        castText:SetTextColor(1, 1, 1)
        healerFrame.castText = castText
        
        -- Spell icon (smaller)
        if RHT.db.showSpellIcons then
            local iconFrame = CreateFrame("Frame", nil, healerFrame)
            iconFrame:SetSize(12, 12)  -- Smaller icon (was 14x14)
            iconFrame:SetPoint("RIGHT", healerFrame, "RIGHT", -2, 0)
            
            local icon = iconFrame:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(iconFrame)
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            healerFrame.icon = icon
            healerFrame.iconFrame = iconFrame
        end
        
        table.insert(RHT.unitFrames, healerFrame)
        yOffset = yOffset + frameHeight + padding
    end
    
    -- Update cast information
    RHT:UpdateCastInfo()
end

function RHT:UpdateCastInfo()
    local currentTime = GetTime()
    
    for i, healerFrame in ipairs(RHT.unitFrames) do
        -- Find corresponding healer (account for sorting)
        local healer = nil
        local healerName = healerFrame.nameText:GetText()
        for _, h in ipairs(RHT.raidHealers) do
            if h.name:sub(1, 8) == healerName then
                healer = h
                break
            end
        end
        
        if not healer then 
            healerFrame:Hide()
            break 
        end
        
        local cast = RHT.activeCasts[healer.guid]
        
        if cast then
            local spellInfo = RHT.healingSpells[cast.spellID]
            local targetName = GetUnitName(cast.targetGUID)
            local remainingTime = cast.endTime - currentTime
            local totalTime = cast.endTime - cast.startTime
            local progress = math.max(0, math.min(1, (totalTime - remainingTime) / totalTime))
            
            -- Update progress bar with smaller width
            if healerFrame.progressBar and healerFrame.progressBG then
                local barWidth = 110 * progress  -- Match new progress bar width
                healerFrame.progressBar:SetWidth(barWidth)
                
                -- Color based on urgency and target health
                local healthPercent = GetHealthPercent(cast.targetGUID)
                if healthPercent < 30 then
                    healerFrame.progressBar:SetColorTexture(1, 0.2, 0.2, 0.9) -- Red for critical
                elseif healthPercent < 60 then
                    healerFrame.progressBar:SetColorTexture(1, 0.8, 0, 0.9)   -- Orange for low
                else
                    healerFrame.progressBar:SetColorTexture(0, 0.8, 0, 0.9)   -- Green for normal
                end
            end
            
            -- Compact cast text
            local castText = ""
            if remainingTime > 0 then
                local shortSpell = spellInfo.name:gsub("Greater ", "G"):gsub("Lesser ", "L"):gsub(" of Light", "")
                local shortTarget = targetName:sub(1, 6)
                castText = string.format("%s→%s", shortSpell, shortTarget)
                
                if RHT.db.showTargetHealth then
                    local healthPercent = GetHealthPercent(cast.targetGUID)
                    if healthPercent < 50 then -- Only show health when it matters
                        castText = castText .. string.format(" %d%%", healthPercent)
                    end
                end
            else
                -- Brief "complete" indicator
                castText = "✓ Complete"
                healerFrame.progressBar:SetColorTexture(0.3, 0.8, 1, 0.9) -- Blue for complete
                
                -- Remove completed casts quickly
                if remainingTime < -0.3 then
                    RHT.activeCasts[healer.guid] = nil
                end
            end
            
            healerFrame.castText:SetText(castText)
            
            -- Update spell icon
            if healerFrame.icon and spellInfo.icon then
                healerFrame.icon:SetTexture(spellInfo.icon)
                healerFrame.iconFrame:Show()
            end
            
            -- Make active casters more visible
            healerFrame:SetAlpha(1.0)
            
        else
            -- No active cast
            healerFrame.castText:SetText("")
            if healerFrame.progressBar then
                healerFrame.progressBar:SetWidth(0)
            end
            if healerFrame.iconFrame then
                healerFrame.iconFrame:Hide()
            end
            
            -- Fade inactive healers slightly
            healerFrame:SetAlpha(0.6)
        end
    end
end

function RHT:UpdateCastTimes()
    RHT:UpdateCastInfo()
end

-- Slash command functions
function RHT:ToggleFrame()
    if RHT.frame then
        if RHT.frame:IsShown() then
            RHT.frame:Hide()
            RHT.db.showFrame = false
        else
            RHT.frame:Show()
            RHT.db.showFrame = true
        end
    end
end

function RHT:ShowHelp()
    print("|cFF00FF00[Raid Healer Tracker] Commands:|r")
    print("  /rht - Toggle the main frame")
    print("  /rht show - Show the main frame")
    print("  /rht hide - Hide the main frame")
    print("  /rht debug - Toggle debug mode")
    print("  /rht reset - Reset frame position")
end

-- Slash commands
SLASH_RAIDHEALERTRACKER1 = "/rht"
SLASH_RAIDHEALERTRACKER2 = "/raidhealertracker"

-- Enhanced slash commands for quick adjustments
SlashCmdList["RAIDHEALERTRACKER"] = function(msg)
    local command, args = msg:match("^(%S*)%s*(.*)$")
    command = command:lower()
    
    if command == "" then
        RHT:ToggleFrame()
    elseif command == "show" then
        if RHT.frame then
            RHT.frame:Show()
            RHT.db.showFrame = true
        end
    elseif command == "hide" then
        if RHT.frame then
            RHT.frame:Hide()
            RHT.db.showFrame = false
        end
    elseif command == "compact" then
        RHT.db.compactMode = not RHT.db.compactMode
        print("|cFF00FF00[RHT]|r Compact mode: " .. (RHT.db.compactMode and "ON" or "OFF"))
        RHT:UpdateDisplay()
    elseif command == "size" and args ~= "" then
        local newSize = tonumber(args)
        if newSize and newSize >= 6 and newSize <= 15 then
            RHT.db.maxHealers = newSize
            print("|cFF00FF00[RHT]|r Max healers set to: " .. newSize)
            RHT:UpdateDisplay()
        end
    elseif command == "debug" then
        RHT.db.debug = not RHT.db.debug
        print("|cFF00FF00[RHT]|r Debug: " .. (RHT.db.debug and "ON" or "OFF"))
    elseif command == "reset" then
        RHT.db.framePosition = {
            point = "TOPLEFT",
            relativePoint = "TOPLEFT",
            xOffset = 20,
            yOffset = -100
        }
        if RHT.frame then
            RHT.frame:ClearAllPoints()
            RHT.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -100)
        end
        print("|cFF00FF00[RHT]|r Position reset")
    else
        print("|cFF00FF00[Raid Healer Tracker] Commands:|r")
        print("  /rht - Toggle frame")
        print("  /rht compact - Toggle compact mode")
        print("  /rht size <1-15> - Set max healers shown")
        print("  /rht debug - Toggle debug mode")
        print("  /rht reset - Reset position")
    end
end
