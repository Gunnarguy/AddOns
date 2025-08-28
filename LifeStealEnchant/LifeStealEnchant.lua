local ADDON_NAME, ns =...

-- Initialize saved variables
-- IMPORTANT: Add this line to your .toc file: ## SavedVariables: LSE_DB
LSE_DB = LSE_DB or {}

-- LOCAL tracking variables (not the saved variables!)
local trackingData = {
    combat = { procs = 0, healing = 0, spells = {} },
    session = { procs = 0, healing = 0, spells = {} },
    allTime = { procs = 0, healing = 0, spells = {} }
}

-- UI Elements
local frame = CreateFrame("Frame", "LifeStealEnchant", UIParent) -- Reverted frame name
local statsFrame
local textWidgets = {}
local lastProcTime = 0
local debugMode = false
local initialized = false

-- Function to print debug messages
local function Debug(...)
    if debugMode then
        print("|cFF33CCFF[LSE Debug]|r", ...) -- Reverted debug prefix (using LSE for consistency)
    end
end

-- Deep copy function to properly handle tables
local function DeepCopy(src)
    if type(src) ~= "table" then return src end
    local dest = {}
    for k, v in pairs(src) do
        dest[k] = (type(v) == "table") and DeepCopy(v) or v
    end
    return dest
end

-- Function to safely initialize or load scope data
local function InitOrLoadScope(scope, savedData)
    if not trackingData[scope] then
        trackingData[scope] = { procs = 0, healing = 0, spells = {} }
    end
    
    if savedData then
        trackingData[scope].procs = savedData.procs or 0
        trackingData[scope].healing = savedData.healing or 0
        
        -- Ensure spells table exists
        if not trackingData[scope].spells then
            trackingData[scope].spells = {}
        end
        
        -- Copy saved spells data
        if savedData.spells then
            for spellID, spellData in pairs(savedData.spells) do
                trackingData[scope].spells[spellID] = DeepCopy(spellData)
            end
        end
        
        Debug(scope .. " data loaded: " .. (trackingData[scope].procs or "nil") .. " procs, " .. 
              (trackingData[scope].healing or "nil") .. " healing")
    end
end

-- Function to save data to LSE_DB
local function SaveData()
    -- Make deep copies to avoid reference issues
    LSE_DB.allTime = DeepCopy(trackingData.allTime)
    LSE_DB.debug = debugMode
    LSE_DB.position = LSE_DB.position
    LSE_DB.scale = LSE_DB.scale
    LSE_DB.locked = LSE_DB.locked

    Debug("Data saved to LSE_DB!") -- Reverted variable name
    Debug("All-time procs: " .. LSE_DB.allTime.procs) -- Reverted variable name
end

-- UI Update Function: only procs & healing now
local function UpdateDisplay()
    if not statsFrame then return end

    for _, widget in ipairs(textWidgets) do
        local d = trackingData[widget.key]
        widget.procs:SetText(d.procs or 0)
        widget.healing:SetText(d.healing or 0)
    end
end

-- UI Creation: drop flame columns & shrink width
local function CreateUI()
    -- Load position from saved variables
    local position = LSE_DB.position or { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10 }
    local scale = LSE_DB.scale or 1.0
    local locked = LSE_DB.locked or false

    local f = CreateFrame("Frame", "LSE_StatsFrame", UIParent, "BackdropTemplate") -- Changed SFS_StatsFrame to LSE_StatsFrame
    f:SetSize(160, 90) -- width adjusted after removing flame columns
    f:SetScale(0.75) -- Using the existing scale, can be LSE_DB.scale if preferred
    f:SetPoint(unpack(position))
    f:SetBackdrop(nil)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if not locked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        LSE_DB.position = { self:GetPoint(1) }
    end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -5)
    title:SetText("|cFF33CCFFLife Steal Enchant|r") -- Changed title and color

    local labelX  = 10
    local col1X   = 60
    local col2X   = 110
    local startY = -25
    local rowYSpacing = 16

    -- headers for Procs & Healing only
    local procsH = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    procsH:SetPoint("TOPLEFT",col1X,startY); procsH:SetText("Procs")
    local healH  = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    healH:SetPoint("TOPLEFT",col2X,startY); healH:SetText("Healing")

    local entries = {
        { label = "Combat:",   key = "combat"   },
        { label = "Session:",  key = "session"  },
        { label = "All-Time:", key = "allTime"  },
    }

    local baseY = startY - rowYSpacing
    for i, entry in ipairs(entries) do
        local y = baseY - (i-1)*rowYSpacing
        local rowLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowLabel:SetPoint("TOPLEFT", labelX, y)
        rowLabel:SetText(entry.label)
        local p = f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        p:SetPoint("TOPLEFT",col1X,y); p:SetText("0")
        local h = f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        h:SetPoint("TOPLEFT",col2X,y); h:SetText("0")

        table.insert(textWidgets, {
            key     = entry.key,
            procs   = p,
            healing = h,
        })
    end

    statsFrame = f
    statsFrame:Show()
    UpdateDisplay()
end

-- Reset Functions
local function ResetCombatData()
    trackingData.combat = { procs = 0, healing = 0, spells = {} }
    UpdateDisplay()
    Debug("Combat data reset")
end

local function ResetSessionData()
    trackingData.session = { procs = 0, healing = 0, spells = {} }
    UpdateDisplay()
    Debug("Session data reset")
    -- Also reset combat data when session is reset
    ResetCombatData()
end

local function ResetAllTimeData()
    trackingData.allTime = { procs = 0, healing = 0, spells = {} }
    UpdateDisplay()
    Debug("All-time data reset")
    -- Also reset session and combat when all-time is reset
    ResetSessionData()
end

-- Event Handler
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event,...)
    if event == "ADDON_LOADED" and... == ADDON_NAME then
        Debug("Addon loaded:", ADDON_NAME)
        
        -- Initialize default saved variables if they don't exist
        LSE_DB = LSE_DB or {} -- Reverted variable name
        LSE_DB.allTime = LSE_DB.allTime or { procs = 0, healing = 0, spells = {} } -- Reverted variable name
        
        -- Load debug setting
        debugMode = LSE_DB.debug or false -- Reverted variable name
        
        -- FIXED: First, properly load all-time data from saved variables
        InitOrLoadScope("allTime", LSE_DB.allTime) -- Reverted variable name
        
        -- Then initialize new sessions without affecting the all-time data
        trackingData.session = { procs = 0, healing = 0, spells = {} }
        trackingData.combat = { procs = 0, healing = 0, spells = {} }
        
        Debug("Initialization complete - all-time data loaded, session reset")
        
        CreateUI()
        UpdateDisplay()
    
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subEvent, _, srcGUID, _, _, _, destGUID, _, _, _, spellID, spellName, _, amount = CombatLogGetCurrentEventInfo()

        if subEvent == "SPELL_HEAL" and spellID == 20004 and srcGUID == UnitGUID("player") then
            -- Track proc with debounce (0.2 sec)
            if (timestamp - lastProcTime) > 0.2 then
                trackingData.combat.procs = trackingData.combat.procs + 1
                trackingData.session.procs = trackingData.session.procs + 1
                trackingData.allTime.procs = trackingData.allTime.procs + 1
                lastProcTime = timestamp
            end
            
            -- Track healing amount (always add)
            trackingData.combat.healing = (trackingData.combat.healing or 0) + amount
            trackingData.session.healing = (trackingData.session.healing or 0) + amount
            trackingData.allTime.healing = (trackingData.allTime.healing or 0) + amount

            UpdateDisplay()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Reset combat data when exiting combat2
        ResetCombatData()

    elseif event == "PLAYER_LOGIN" then
        Debug("Player login")
        -- Combat data is already reset in ADDON_LOADED

    elseif event == "PLAYER_LOGOUT" then
        Debug("Player logout - saving data")
        -- Save the all-time data to saved variables
        SaveData()
    end
end)

-- Slash Commands
SLASH_LSE1 = "/lse" -- Changed from SLASH_SFS1
SLASH_LSE2 = "/lifestealenchant" -- Changed from SLASH_SFS2
SlashCmdList["LSE"] = function(msg) -- Changed from SlashCmdList["SFS"]
    msg = msg:lower()
    if msg == "toggle" then
        statsFrame:SetShown(not statsFrame:IsShown())
        print("Life Steal Enchant window is now", statsFrame:IsShown() and "|cFF00FF96shown|r" or "|cFFFF0000hidden|r") -- Changed text
    elseif msg == "reset combat" then
        ResetCombatData()
        print("|cFF33CCFFCurrent combat stats reset.|r") -- Changed color for consistency
    elseif msg == "reset session" then
        ResetSessionData()
        print("|cFF33CCFFSession stats reset.|r") -- Changed color for consistency
    elseif msg == "reset all" then
        ResetAllTimeData()
        print("|cFF33CCFFAll-time stats reset.|r") -- Changed color for consistency
        -- Save immediately when all-time data is reset
        SaveData()
    elseif msg == "debug" then
        debugMode = not debugMode
        LSE_DB.debug = debugMode
        print("Debug mode is now", debugMode and "|cFF00FF96enabled|r" or "|cFFFF0000disabled|r")
    elseif msg == "save" then
        SaveData()
        print("|cFF33CCFFData manually saved.|r") -- Changed color for consistency
    else
        print("|cFF33CCFFLife Steal Enchant Commands:|r") -- Changed title and color
        print("|cFF00FF96/lse toggle|r - Show/hide window") -- Changed command
        print("|cFF00FF96/lse reset combat|r - Reset current fight stats") -- Changed command
        print("|cFF00FF96/lse reset session|r - Reset session stats") -- Changed command
        print("|cFF00FF96/lse reset all|r - Reset all-time stats") -- Changed command
        print("|cFF00FF96/lse debug|r - Toggle debug messages") -- Changed command
        print("|cFF00FF96/lse save|r - Force save data now") -- Changed command
    end
end