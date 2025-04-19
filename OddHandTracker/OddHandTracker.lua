local addonName, addonTable =...

--------------------------------------
-- 1) Saved Variables & Defaults
--------------------------------------
-- IMPORTANT: Make sure to add to your TOC file:
-- ## SavedVariables: OddHandTrackerDB

-- Initialize saved variables table
OddHandTrackerDB = OddHandTrackerDB or {}

-- LOCAL tracking data (separate from saved variables)
local procData = {
    combat = 0,   -- Procs in current combat
    session = 0,  -- Procs in this session
    allTime = 0   -- All-time procs
}

-- Constants
local TRACKED_SPELL_ID = 18803  -- Spell ID for Focus
local debug = false            -- Debug mode flag

--------------------------------------
-- 2) Debug Function
--------------------------------------
local function Debug(...)
    if debug then
        print("|cFF33CCFF[Focus Tracker Debug]|r", ...)
    end
end

--------------------------------------
-- 3) Create Main Frame
--------------------------------------
local OddHandFrame = CreateFrame("Frame", "OddHandTrackerFrame", UIParent, "BackdropTemplate")
OddHandFrame:SetSize(180, 100)

-- Set position from saved variables or use default
local position = { point = "CENTER", x = 0, y = 0 }
if OddHandTrackerDB.position then
    position = OddHandTrackerDB.position
end

OddHandFrame:SetPoint(position.point, position.x, position.y)
OddHandFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = false,
    tileSize = 32,
    edgeSize = 14,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})
OddHandFrame:SetBackdropColor(0, 0, 0, 0.7)
OddHandFrame:EnableMouse(true)
OddHandFrame:SetMovable(true)
OddHandFrame:RegisterForDrag("LeftButton")

-- Load locked state
local locked = false
if OddHandTrackerDB.locked ~= nil then
    locked = OddHandTrackerDB.locked
end

-- Drag & Drop
OddHandFrame:SetScript("OnDragStart", function(self)
    if not locked then self:StartMoving() end
end)
OddHandFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    position.point = point
    position.x = x
    position.y = y
    OddHandTrackerDB.position = position
end)

--------------------------------------
-- 4) Title Text
--------------------------------------
local title = OddHandFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", 0, -6)
title:SetText("|cFF00FF96Focus Tracker|r")

--------------------------------------
-- 5) Display Text
--------------------------------------
local display = OddHandFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
display:SetPoint("TOPLEFT", 10, -28)
display:SetJustifyH("LEFT")
display:SetTextColor(1, 1, 1, 1)

-- Function to update the display text
local function UpdateDisplay()
    display:SetText(string.format(
        "Combat: |cFFFFFF00%d|r\nSession: |cFFFFFF00%d|r\nAll-Time: |cFFFFFF00%d|r",
        procData.combat, procData.session, procData.allTime
    ))
end

--------------------------------------
-- 6) Lock/Unlock Toggle Button
--------------------------------------
local lockButton = CreateFrame("Button", nil, OddHandFrame, "UIPanelButtonTemplate")
lockButton:SetSize(60, 18)
lockButton:SetPoint("BOTTOMRIGHT", OddHandFrame, "BOTTOMRIGHT", -5, 5)
lockButton:SetText(locked and "Unlock" or "Lock")
lockButton:SetScript("OnClick", function(self)
    locked = not locked
    OddHandTrackerDB.locked = locked
    self:SetText(locked and "Unlock" or "Lock")
    if locked then
        print("Focus Tracker locked.")
    else
        print("Focus Tracker unlocked.")
    end
end)

--------------------------------------
-- 7) Reset Functions
--------------------------------------
-- Reset combat data
local function ResetCombatData()
    procData.combat = 0
    UpdateDisplay()
    Debug("Combat data reset")
end

-- Reset session data
local function ResetSessionData()
    procData.session = 0
    ResetCombatData() -- Also reset combat data
    UpdateDisplay()
    Debug("Session data reset")
end

-- Reset all-time data
local function ResetAllTimeData()
    procData.allTime = 0
    ResetSessionData() -- Also reset session and combat data
    UpdateDisplay()
    Debug("All-time data reset")
end

--------------------------------------
-- 8) Event Frame + Logic
--------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")

-- OnEvent function
eventFrame:SetScript("OnEvent", function(self, event,...)
    if event == "ADDON_LOADED" and... == addonName then
        Debug("Addon loaded:", addonName)
        -- Load all-time value from DB, use default 0 if nil
        procData.allTime = OddHandTrackerDB.allTime or 0
        Debug("Loaded all-time data:", procData.allTime)
        
        debug = OddHandTrackerDB.debug or false
        
        -- Session data should always start at 0 for a new game session
        procData.session = 0
        Debug("Reset session data for new game session")
        
        -- Initialize the UI
        UpdateDisplay()
        
    elseif event == "PLAYER_LOGIN" then
        Debug("Player login")
        
        -- Only reset combat data on login/reload
        ResetCombatData()
        
        -- Update display
        UpdateDisplay()
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        
        -- Check if the player cast it and it's the correct spell
        -- Track both new applications AND refreshes
        if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH") 
           and sourceGUID == UnitGUID("player") 
           and spellID == TRACKED_SPELL_ID then
            
            procData.combat  = procData.combat + 1
            procData.session = procData.session + 1
            procData.allTime = procData.allTime + 1
            
            Debug("Focus proc detected:", subEvent, "Total:", procData.combat, "Session:", procData.session, "All-time:", procData.allTime)
            UpdateDisplay()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- We left combat, so reset 'combat' counter
        Debug("Combat ended - resetting combat counter")
        ResetCombatData()

    elseif event == "PLAYER_LOGOUT" then
        Debug("Player logout - saving data")
        
        -- Only save all-time data to the saved variables
        OddHandTrackerDB.allTime = procData.allTime
        OddHandTrackerDB.debug = debug
        Debug("Saved all-time data:", procData.allTime)
    end
end)

--------------------------------------
-- 9) Slash Commands
--------------------------------------
SLASH_ODDHAND1 = "/focus"
SlashCmdList["ODDHAND"] = function(msg)
    msg = msg and msg:lower() or ""

    -- /focus toggle
    if msg == "toggle" then
        if OddHandFrame:IsShown() then
            OddHandFrame:Hide()
            print("Focus Tracker hidden.")
        else
            OddHandFrame:Show()
            print("Focus Tracker shown.")
        end

    -- /focus reset combat
    elseif msg == "reset combat" then
        ResetCombatData()
        print("|cFF00FF96Focus Tracker|r: Combat count reset.")

    -- /focus reset session
    elseif msg == "reset session" then
        ResetSessionData()
        print("|cFF00FF96Focus Tracker|r: Session count reset.")

    -- /focus reset all
    elseif msg == "reset all" then
        ResetAllTimeData()
        print("|cFF00FF96Focus Tracker|r: All counters reset.")
    
    -- /focus debug
    elseif msg == "debug" then
        debug = not debug
        OddHandTrackerDB.debug = debug
        print("Focus Tracker debug mode:", debug and "|cFF00FF96enabled|r" or "|cFFFF0000disabled|r")

    else
        -- Help
        print("|cFF00FF96Focus Tracker Commands:|r")
        print("/focus toggle       - Show/Hide the tracker window")
        print("/focus reset combat - Reset combat count")
        print("/focus reset session - Reset session count")
        print("/focus reset all     - Reset all-time count")
        print("/focus debug         - Toggle debug mode")
    end
end

-- Initialize on load
UpdateDisplay()
