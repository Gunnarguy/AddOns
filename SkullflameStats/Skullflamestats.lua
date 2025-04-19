local ADDON_NAME, ns =...

-- Initialize saved variables 
-- IMPORTANT: Add this line to your .toc file: ## SavedVariables: SFS_DB
SFS_DB = SFS_DB or {}

-- LOCAL tracking variables (not the saved variables!)
local trackingData = {
    combat = { procs = 0, healing = 0, spells = {} },
    session = { procs = 0, healing = 0, spells = {} },
    allTime = { procs = 0, healing = 0, spells = {} }
}

-- UI Elements
local frame = CreateFrame("Frame", "SkullflameStatsFrame", UIParent)
local statsFrame
local textWidgets = {}
local lastProcTime = 0
local lastSpellActivations = {}
local debugMode = false
local initialized = false

-- Function to print debug messages
local function Debug(...)
    if debugMode then
        print("|cFF33CCFF[SFS Debug]|r", ...)
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

-- Function to get or initialize spell data
local function GetSpellData(scope, spellID, spellName)
    if not trackingData[scope].spells[spellID] then
        trackingData[scope].spells[spellID] = { activations = 0, damage = 0, name = spellName }
    end
    return trackingData[scope].spells[spellID]
end

-- Function to save data to SFS_DB
local function SaveData()
    -- Make deep copies to avoid reference issues
    SFS_DB.allTime = DeepCopy(trackingData.allTime)
    SFS_DB.debug = debugMode
    SFS_DB.position = SFS_DB.position
    SFS_DB.scale = SFS_DB.scale
    SFS_DB.locked = SFS_DB.locked
    
    Debug("Data saved to SFS_DB!")
    Debug("All-time procs: " .. SFS_DB.allTime.procs)
end

-- UI Update Function
local function UpdateDisplay()
    if not statsFrame then return end

    for _, widget in ipairs(textWidgets) do
        local scopeData = trackingData[widget.key]
        widget.procs:SetText(scopeData.procs or 0)
        widget.healing:SetText(scopeData.healing or 0)

        local totalActivations = 0
        local totalDamage = 0
        for spellID, data in pairs(scopeData.spells) do
           totalActivations = totalActivations + (data.activations or 0)
           totalDamage = totalDamage + (data.damage or 0)
        end

        widget.flameActivations:SetText(totalActivations)
        widget.flameDamage:SetText(totalDamage)
    end
end

-- UI Creation
local function CreateUI()
    -- Load position from saved variables
    local position = SFS_DB.position or { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10 }
    local scale = SFS_DB.scale or 1.0
    local locked = SFS_DB.locked or false
    
    local f = CreateFrame("Frame", "SFS_StatsFrame", UIParent, "BackdropTemplate")
    f:SetSize(240, 90)
    f:SetScale(0.75)
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
        SFS_DB.position = { self:GetPoint(1) }
    end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -5)
    title:SetText("|cFFFFA500Skullflame Stats|r")

    local labelX  = 10
    local col1X   = 60
    local col2X   = 110
    local col3X   = 160
    local col4X   = 210
    local startY = -25
    local rowYSpacing = 16

    local procsHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    procsHeader:SetPoint("TOPLEFT", col1X, startY)
    procsHeader:SetText("Procs")
    local healingHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    healingHeader:SetPoint("TOPLEFT", col2X, startY)
    healingHeader:SetText("Healing")
    local flameHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    flameHeader:SetPoint("TOPLEFT", col3X, startY)
    flameHeader:SetText("Flame Act.")
    local flameDamageHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    flameDamageHeader:SetPoint("TOPLEFT", col4X, startY)
    flameDamageHeader:SetText("Flame Dmg")

    local entries = {
        { label = "Combat:",   key = "combat"   },
        { label = "Session:",  key = "session"  },
        { label = "All-Time:", key = "allTime"  },
    }

    local baseY = startY - rowYSpacing
    for i, entry in ipairs(entries) do
        local yPos = baseY - (i - 1) * rowYSpacing
        local rowLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowLabel:SetPoint("TOPLEFT", labelX, yPos)
        rowLabel:SetText(entry.label)
        local procs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        procs:SetPoint("TOPLEFT", col1X, yPos)
        procs:SetText("0")
        local healing = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        healing:SetPoint("TOPLEFT", col2X, yPos)
        healing:SetText("0")
        local flameAct = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        flameAct:SetPoint("TOPLEFT", col3X, yPos)
        flameAct:SetText("0")
        local flameDmg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        flameDmg:SetPoint("TOPLEFT", col4X, yPos)
        flameDmg:SetText("0")

        table.insert(textWidgets, {
            key = entry.key,
            procs = procs,
            healing = healing,
            flameActivations = flameAct,
            flameDamage = flameDmg,
        })
    end

    statsFrame = f
    statsFrame:Show()
    UpdateDisplay()
end

-- Reset Functions
local function ResetCombatData()
    trackingData.combat = { procs = 0, healing = 0, spells = {} }
    lastSpellActivations = {}
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
        SFS_DB = SFS_DB or {}
        SFS_DB.allTime = SFS_DB.allTime or { procs = 0, healing = 0, spells = {} }
        
        -- Load debug setting
        debugMode = SFS_DB.debug or false
        
        -- FIXED: First, properly load all-time data from saved variables
        InitOrLoadScope("allTime", SFS_DB.allTime)
        
        -- Then initialize new sessions without affecting the all-time data
        trackingData.session = { procs = 0, healing = 0, spells = {} }
        trackingData.combat = { procs = 0, healing = 0, spells = {} }
        
        Debug("Initialization complete - all-time data loaded, session reset")
        
        CreateUI()
        UpdateDisplay()
    
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subEvent, _, srcGUID, _, _, _, destGUID, _, _, _, spellID, spellName, _, amount = CombatLogGetCurrentEventInfo()

        if subEvent == "SPELL_HEAL" and spellID == 18817 and srcGUID == UnitGUID("player") then
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

        elseif subEvent == "SPELL_DAMAGE" and srcGUID == UnitGUID("player") and (spellID == 18818 or spellID == 47851) then
            local combatData = GetSpellData("combat", spellID, spellName)
            local sessionData = GetSpellData("session", spellID, spellName)
            local allTimeData = GetSpellData("allTime", spellID, spellName)

            -- Track flame activations with debounce (0.2 sec)
            if not lastSpellActivations[spellID] or (timestamp - lastSpellActivations[spellID]) > 0.2 then
                combatData.activations = (combatData.activations or 0) + 1
                sessionData.activations = (sessionData.activations or 0) + 1
                allTimeData.activations = (allTimeData.activations or 0) + 1
                lastSpellActivations[spellID] = timestamp
            end

            -- Track flame damage (always add)
            combatData.damage = (combatData.damage or 0) + amount
            sessionData.damage = (sessionData.damage or 0) + amount
            allTimeData.damage = (allTimeData.damage or 0) + amount

            UpdateDisplay()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Reset combat data when exiting combat
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
SLASH_SFS1 = "/sfs"
SLASH_SFS2 = "/skullflamestats"
SlashCmdList["SFS"] = function(msg)
    msg = msg:lower()
    if msg == "toggle" then
        statsFrame:SetShown(not statsFrame:IsShown())
        print("Skullflame Stats window is now", statsFrame:IsShown() and "|cFF00FF96shown|r" or "|cFFFF0000hidden|r")
    elseif msg == "reset combat" then
        ResetCombatData()
        print("|cFFFFA500Current combat stats reset.|r")
    elseif msg == "reset session" then
        ResetSessionData()
        print("|cFFFFA500Session stats reset.|r")
    elseif msg == "reset all" then
        ResetAllTimeData()
        print("|cFFFFA500All-time stats reset.|r")
        -- Save immediately when all-time data is reset
        SaveData()
    elseif msg == "debug" then
        debugMode = not debugMode
        SFS_DB.debug = debugMode
        print("Debug mode is now", debugMode and "|cFF00FF96enabled|r" or "|cFFFF0000disabled|r")
    elseif msg == "save" then
        SaveData()
        print("|cFFFFA500Data manually saved.|r")
    else
        print("|cFFFFA500SkullflameStats Commands:|r")
        print("|cFF00FF96/sfs toggle|r - Show/hide window")
        print("|cFF00FF96/sfs reset combat|r - Reset current fight stats")
        print("|cFF00FF96/sfs reset session|r - Reset session stats")
        print("|cFF00FF96/sfs reset all|r - Reset all-time stats")
        print("|cFF00FF96/sfs debug|r - Toggle debug messages")
        print("|cFF00FF96/sfs save|r - Force save data now")
    end
end