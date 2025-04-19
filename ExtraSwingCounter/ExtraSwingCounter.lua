-- Addon Namespace
local addonName, addonTable =...
local ExtraSwingCounter = CreateFrame("Frame", "ExtraSwingCounterFrame", UIParent)

-- Localization Table
local L = {
    ["Flurry Axe"] = "Flurry Axe",
    ["Reckoning"] = "Reckoning",
    ["Current Fight"] = "Current",
    ["Session"] = "Session",
    ["All-Time"] = "All-Time",
    ["Proc Rate"] = "Proc Rate",
    ["Swing Counter hidden."] = "Swing Counter hidden.",
    ["Swing Counter shown."] = "Swing Counter shown.",
    ["Help Menu"] = "Swing Counter Commands:",
    ["resetfight"] = "/swingcounter resetfight - Reset current fight procs.",
    ["resetsession"] = "/swingcounter resetsession - Reset session counters.",
    ["resetalltime"] = "/swingcounter resetalltime - Reset all-time counters.",
    ["toggle"] = "/swingcounter toggle - Show/hide the counter frame.",
    ["autoreset"] = "/swingcounter autoreset [on|off] - Toggle automatic reset after combat.",
    ["lock"] = "/swingcounter lock - Lock/unlock the counter frame."
}

-- Saved Variables
ExtraSwingCounterDB = ExtraSwingCounterDB or {}

-- Default Settings
local defaults = {
    autoReset = true,
    -- Make the position near center by default
    framePosition = { "CENTER", nil, "CENTER", 0, 0 },
    flurryAllTime = 0,
    flurryAllTimeProcCount = 0,
    flurryAllTimeSwings = 0,
    reckoningAllTime = 0,
    uiScale = 0.9,  -- Slightly smaller scale
    locked = false
}

-- Data Tables
local flurryData = {
    current = 0,
    session = 0,
    allTime = 0,
    currentProcCount = 0,
    sessionProcCount = 0,
    allTimeProcCount = 0,
    currentSwings = 0,
    sessionSwings = 0,
    allTimeSwings = 0
}

local reckoningData = {
    current = 0,
    session = 0,
    allTime = 0
}

-- Load Settings
local function LoadSettings()
    for k, v in pairs(defaults) do
        if ExtraSwingCounterDB[k] == nil then
            ExtraSwingCounterDB[k] = v
        end
    end
end
LoadSettings()

-- Create the Add-On Frame
local frame = CreateFrame("Frame", "ExtraSwingCounterMovableFrame", UIParent)  -- Removed "BackdropTemplate"
-- Reduced width, increased height for a vertical layout
frame:SetSize(110, 140)  -- Made even smaller
frame:SetPoint(unpack(ExtraSwingCounterDB.framePosition))
-- Removed backdrop for cleaner look
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not ExtraSwingCounterDB.locked then
        self:StartMoving()
    end
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    ExtraSwingCounterDB.framePosition = { point, relativePoint, xOfs, yOfs }
end)

-- Set scale from DB
frame:SetScale(ExtraSwingCounterDB.uiScale)

-- Title for Frame
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", frame, "TOP", 0, -6)
title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
title:SetText("|cff00ff96Extra Swing|r")

-- Text Display
local swingCounterText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
swingCounterText:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -22)
swingCounterText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
swingCounterText:SetWidth(100)  -- Adjusted for smaller width
swingCounterText:SetJustifyH("LEFT")

-- Lock Button
local lockButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lockButton:SetSize(40, 14) -- Smaller button
lockButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, -5)
lockButton:SetText(ExtraSwingCounterDB.locked and "Unlock" or "Lock")
lockButton:SetScript("OnClick", function(self)
    ExtraSwingCounterDB.locked = not ExtraSwingCounterDB.locked
    self:SetText(ExtraSwingCounterDB.locked and "Unlock" or "Lock")
end)

-- Update Display Function
local function UpdateDisplay()
    -- Compute separate proc rates for current, session, and all-time
    local flurryProcRateCurrent = (flurryData.currentSwings > 0)
        and (flurryData.currentProcCount / flurryData.currentSwings) or 0
    local flurryProcRateSession = (flurryData.sessionSwings > 0)
        and (flurryData.sessionProcCount / flurryData.sessionSwings) or 0
    local flurryProcRateAllTime = (flurryData.allTimeSwings > 0)
        and (flurryData.allTimeProcCount / flurryData.allTimeSwings) or 0
    
    -- Build a vertical text display
    local displayText = string.format(
        "|cff00ff00%s|r\n"..
        "%s: |cffffffff%d|r\n"..
        "%s: |cffffffff%d|r\n"..
        "%s: |cffffffff%d|r\n"..
        "C Rate: |cffffffff%.1f%%|r\n"..
        "S Rate: |cffffffff%.1f%%|r\n"..
        "A Rate: |cffffffff%.1f%%|r\n\n"..
        
        "|cff0077ff%s|r\n"..
        "%s: |cffffffff%d|r\n"..
        "%s: |cffffffff%d|r\n"..
        "%s: |cffffffff%d|r",
        
        -- Flurry
        L["Flurry Axe"],
        L["Current Fight"], flurryData.current,
        L["Session"], flurryData.session,
        L["All-Time"], flurryData.allTime,
        (flurryProcRateCurrent * 100),
        (flurryProcRateSession * 100),
        (flurryProcRateAllTime * 100),
        
        -- Reckoning
        L["Reckoning"],
        L["Current Fight"], reckoningData.current,
        L["Session"], reckoningData.session,
        L["All-Time"], reckoningData.allTime
    )
    
    swingCounterText:SetText(displayText)
end

-- Reset Functions
local function ResetCurrentFight()
    flurryData.current = 0
    flurryData.currentProcCount = 0
    flurryData.currentSwings = 0
    reckoningData.current = 0
    UpdateDisplay()
    print("Current fight counters reset!")
end

local function ResetSession()
    flurryData.session = 0
    flurryData.sessionProcCount = 0
    flurryData.sessionSwings = 0
    reckoningData.session = 0
    UpdateDisplay()
    print("Session counters reset!")
end

local function ResetAllTime()
    flurryData.allTime = 0
    flurryData.allTimeProcCount = 0
    flurryData.allTimeSwings = 0
    reckoningData.allTime = 0
    UpdateDisplay()
    print("All-time counters reset!")
end

-- Event Handling
ExtraSwingCounter:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ExtraSwingCounter:RegisterEvent("PLAYER_REGEN_ENABLED")
ExtraSwingCounter:RegisterEvent("ADDON_LOADED")
ExtraSwingCounter:RegisterEvent("PLAYER_LOGOUT")

ExtraSwingCounter:SetScript("OnEvent", function(self, event,...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, amount = CombatLogGetCurrentEventInfo()
        
        -- Detect normal melee swings by the player
        if sourceGUID == UnitGUID("player") and (subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED") then
            -- Increment total swings for all 3 scopes
            flurryData.currentSwings  = flurryData.currentSwings  + 1
            flurryData.sessionSwings  = flurryData.sessionSwings  + 1
            flurryData.allTimeSwings  = flurryData.allTimeSwings  + 1
            UpdateDisplay()
        end
        
        -- Detect extra attacks (Flurry/Reckoning)
        if sourceGUID == UnitGUID("player") and subevent == "SPELL_EXTRA_ATTACKS" then
            -- Flurry Axe
            if spellID == 18797 then
                flurryData.current = flurryData.current + amount
                flurryData.session = flurryData.session + amount
                flurryData.allTime = flurryData.allTime + amount
                
                flurryData.currentProcCount = flurryData.currentProcCount + 1
                flurryData.sessionProcCount = flurryData.sessionProcCount + 1
                flurryData.allTimeProcCount = flurryData.allTimeProcCount + 1
            
            -- Reckoning
            elseif spellID == 20178 then
                reckoningData.current = reckoningData.current + amount
                reckoningData.session = reckoningData.session + amount
                reckoningData.allTime = reckoningData.allTime + amount
            end
            
            UpdateDisplay()
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        if ExtraSwingCounterDB.autoReset then
            ResetCurrentFight()
        end
    
    elseif event == "ADDON_LOADED" and... == addonName then
        -- Load persistent data
        flurryData.allTime          = ExtraSwingCounterDB.flurryAllTime or 0
        flurryData.allTimeProcCount = ExtraSwingCounterDB.flurryAllTimeProcCount or 0
        flurryData.allTimeSwings    = ExtraSwingCounterDB.flurryAllTimeSwings or 0
        reckoningData.allTime       = ExtraSwingCounterDB.reckoningAllTime or 0
        UpdateDisplay()
    
    elseif event == "PLAYER_LOGOUT" then
        -- Save persistent data
        ExtraSwingCounterDB.flurryAllTime          = flurryData.allTime
        ExtraSwingCounterDB.flurryAllTimeProcCount = flurryData.allTimeProcCount
        ExtraSwingCounterDB.flurryAllTimeSwings    = flurryData.allTimeSwings
        ExtraSwingCounterDB.reckoningAllTime       = reckoningData.allTime
    end
end)

-- Slash Commands
SLASH_SWINGCOUNTER1 = "/swingcounter"
SlashCmdList["SWINGCOUNTER"] = function(msg)
    if msg == "resetfight" then
        ResetCurrentFight()
    elseif msg == "resetsession" then
        ResetSession()
    elseif msg == "resetalltime" then
        ResetAllTime()
    elseif msg == "toggle" then
        if frame:IsShown() then
            frame:Hide()
            print(L["Swing Counter hidden."])
        else
            frame:Show()
            print(L["Swing Counter shown."])
        end
    elseif msg == "lock" then
        ExtraSwingCounterDB.locked = not ExtraSwingCounterDB.locked
        lockButton:SetText(ExtraSwingCounterDB.locked and "Unlock" or "Lock")
        print(ExtraSwingCounterDB.locked and "Frame locked." or "Frame unlocked.")
    elseif msg:match("^autoreset%s+(%w+)$") then
        local state = msg:match("^autoreset%s+(%w+)$")
        if state == "on" then
            ExtraSwingCounterDB.autoReset = true
            print("Auto reset enabled.")
        elseif state == "off" then
            ExtraSwingCounterDB.autoReset = false
            print("Auto reset disabled.")
        else
            print("Invalid argument for autoreset. Use 'on' or 'off'.")
        end
    else
        print(L["Help Menu"])
        print(L["resetfight"])
        print(L["resetsession"])
        print(L["resetalltime"])
        print(L["toggle"])
        print(L["autoreset"])
        print(L["lock"])
    end
end