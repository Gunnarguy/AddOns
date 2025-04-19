-- Addon Namespace
local addonName, addonTable =...
local FieryBlazeTracker = CreateFrame("Frame", "FieryBlazeTrackerFrame", UIParent)

-- Localization Table
local L = {
    ["Fiery Blaze"]      = "Fiery Blaze", -- confirm actual name if different
    ["Current Fight"]    = "Current",
    ["Session"]          = "Session",
    ["All-Time"]         = "All-Time",
    ["Tracker hidden."]  = "Tracker hidden.",
    ["Tracker shown."]   = "Tracker shown.",
    ["Help Menu"]        = "Fiery Blaze Tracker Commands:",
    ["resetfight"]       = "/fieryblaze resetfight - Reset current fight counters.",
    ["resetsession"]     = "/fieryblaze resetsession - Reset session counters.",
    ["resetalltime"]     = "/fieryblaze resetalltime - Reset all-time counters.",
    ["toggle"]           = "/fieryblaze toggle - Show/hide the tracker.",
    ["autoreset"]        = "/fieryblaze autoreset [on|off] - Toggle automatic reset after combat."
}

-- Saved Variables
FieryBlazeTrackerDB = FieryBlazeTrackerDB or {}

-- Default Settings
local defaults = {
    autoReset      = true,
    framePosition  = { "CENTER", nil, "CENTER", 0, 0 },
    uiScale        = 0.7,
    locked         = false,

    -- All-time stored counters
    allTimeDamage  = 0,  -- total Fiery Blaze damage
    allTimeProcs   = 0,  -- total Fiery Blaze triggers
    allTimeSwings  = 0   -- total melee swings
}

-- Data Tables
local damageData = { current = 0, session = 0, allTime = 0 }
local procData   = { current = 0, session = 0, allTime = 0 }
local swingsData = { current = 0, session = 0, allTime = 0 }

-- We'll store the last time we counted a Fiery Blaze proc
local lastFieryBlazeProcTime = 0

-- Load & Initialize Settings
local function LoadSettings()
    for k, v in pairs(defaults) do
        if FieryBlazeTrackerDB[k] == nil then
            FieryBlazeTrackerDB[k] = v
        end
    end
end
LoadSettings()

-- Create the Add-On Frame
local frame = CreateFrame("Frame", "FieryBlazeTrackerMovableFrame", UIParent) -- Removed "BackdropTemplate"
frame:SetSize(100, 140)  -- Made smaller (adjust as needed)
frame:SetPoint(unpack(FieryBlazeTrackerDB.framePosition))
-- Removed backdrop
frame:SetScale(FieryBlazeTrackerDB.uiScale)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    if not FieryBlazeTrackerDB.locked then
        self:StartMoving()
    end
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    FieryBlazeTrackerDB.framePosition = { point, relativePoint, xOfs, yOfs }
end)

-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -8)
title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
title:SetText("|cff00ff96Fiery Blaze|r")

-- Main Text Display
local textDisplay = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
textDisplay:SetPoint("TOPLEFT", 10, -20) -- Adjusted position
textDisplay:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE") -- Smaller font
textDisplay:SetWidth(85)  -- Adjusted for smaller frame
textDisplay:SetWordWrap(true)
textDisplay:SetJustifyH("LEFT")

-- Lock Button
local lockButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lockButton:SetSize(40, 14) -- Smaller button
lockButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, -60)  -- Moved to bottom
lockButton:SetText(FieryBlazeTrackerDB.locked and "Unlock" or "Lock")
lockButton:SetScript("OnClick", function(self)
    FieryBlazeTrackerDB.locked = not FieryBlazeTrackerDB.locked
    self:SetText(FieryBlazeTrackerDB.locked and "Unlock" or "Lock")
    if FieryBlazeTrackerDB.locked then
        print("Fiery Blaze Tracker locked.")
    else
        print("Fiery Blaze Tracker unlocked.")
    end
end)

-- Update Display
local function UpdateDisplay()
    local function ProcRate(procs, swings)
        if swings == 0 then return 0 end
        return (procs / swings) * 100
    end

    local currentRate  = ProcRate(procData.current,  swingsData.current)
    local sessionRate  = ProcRate(procData.session,  swingsData.session)
    local allTimeRate  = ProcRate(procData.allTime,  swingsData.allTime)

    textDisplay:SetText(string.format([[
|cff00ff00Damage:|r
  • Current: %d
  • Session: %d
  • All-Time: %d

|cff00ff00Procs:|r
  • Current: %d
  • Session: %d
  • All-Time: %d

|cff00ff00Swings:|r
  • Current: %d
  • Session: %d
  • All-Time: %d

|cff00ff00Proc Rate (%%):|r
  • Current: %.2f
  • Session: %.2f
  • All-Time: %.2f
]],
        damageData.current, damageData.session, damageData.allTime,
        procData.current,   procData.session,   procData.allTime,
        swingsData.current, swingsData.session, swingsData.allTime,
        currentRate, sessionRate, allTimeRate
    ))
end

-- Reset Functions
local function ResetCurrentFight()
    damageData.current = 0
    procData.current   = 0
    swingsData.current = 0
    UpdateDisplay()
    print("FieryBlazeTracker: Current fight counters reset.")
end

local function ResetSession()
    damageData.session = 0
    procData.session   = 0
    swingsData.session = 0
    UpdateDisplay()
    print("FieryBlazeTracker: Session counters reset.")
end

local function ResetAllTime()
    damageData.allTime  = 0
    procData.allTime    = 0
    swingsData.allTime  = 0

    FieryBlazeTrackerDB.allTimeDamage = 0
    FieryBlazeTrackerDB.allTimeProcs  = 0
    FieryBlazeTrackerDB.allTimeSwings = 0

    UpdateDisplay()
    print("FieryBlazeTracker: All-time counters reset.")
end

-- Event Handling
FieryBlazeTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
FieryBlazeTracker:RegisterEvent("PLAYER_REGEN_ENABLED")
FieryBlazeTracker:RegisterEvent("ADDON_LOADED")
FieryBlazeTracker:RegisterEvent("PLAYER_LOGOUT")

FieryBlazeTracker:SetScript("OnEvent", function(self, event,...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- The full data includes the timestamp
        local timestamp, subevent, _, sourceGUID, _, _, _, destGUID, _, _, _,
              spellID, spellName, _, amount = CombatLogGetCurrentEventInfo()

        if sourceGUID == UnitGUID("player") then
            -- Count total melee attempts
            if subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED" then
                swingsData.current = swingsData.current + 1
                swingsData.session = swingsData.session + 1
                swingsData.allTime = swingsData.allTime + 1
            end

            -- Fiery Blaze damage lines
            if subevent == "SPELL_DAMAGE"
               and spellName == "Fiery Blaze"  -- or check spellID if you prefer
               and amount and amount > 0
            then
                -- Only increment the proc once per event, ignoring AoE multi-hits
                -- We'll compare timestamps
                if math.abs(timestamp - lastFieryBlazeProcTime) > 0.0001 then
                    -- This is a new proc event, increment proc count
                    procData.current = procData.current + 1
                    procData.session = procData.session + 1
                    procData.allTime = procData.allTime + 1

                    lastFieryBlazeProcTime = timestamp
                end

                -- Always add the damage (since each AoE line deals distinct damage)
                damageData.current = damageData.current + amount
                damageData.session = damageData.session + amount
                damageData.allTime = damageData.allTime + amount

                -- Persist your all-time counts
                FieryBlazeTrackerDB.allTimeDamage = damageData.allTime
                FieryBlazeTrackerDB.allTimeProcs  = procData.allTime
                FieryBlazeTrackerDB.allTimeSwings = swingsData.allTime

                UpdateDisplay()
            end
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if FieryBlazeTrackerDB.autoReset then
            ResetCurrentFight()
        end

    elseif event == "ADDON_LOADED" and... == addonName then
        -- Restore from saved variables
        damageData.allTime = FieryBlazeTrackerDB.allTimeDamage or 0
        procData.allTime   = FieryBlazeTrackerDB.allTimeProcs  or 0
        swingsData.allTime = FieryBlazeTrackerDB.allTimeSwings or 0
        UpdateDisplay()

    elseif event == "PLAYER_LOGOUT" then
        -- Save all-time counters
        FieryBlazeTrackerDB.allTimeDamage = damageData.allTime
        FieryBlazeTrackerDB.allTimeProcs  = procData.allTime
        FieryBlazeTrackerDB.allTimeSwings = swingsData.allTime
    end
end)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_FIERYBLAZE1 = "/fieryblaze"
SlashCmdList["FIERYBLAZE"] = function(msg)
    if msg == "resetfight" then
        ResetCurrentFight()
    elseif msg == "resetsession" then
        ResetSession()
    elseif msg == "resetalltime" then
        ResetAllTime()
    elseif msg == "toggle" then
        if frame:IsShown() then
            frame:Hide()
            print(L["Tracker hidden."])
        else
            frame:Show()
            print(L["Tracker shown."])
        end
    elseif msg:match("^autoreset%s+(%w+)$") then
        local state = msg:match("^autoreset%s+(%w+)$")
        if state == "on" then
            FieryBlazeTrackerDB.autoReset = true
            print("Auto reset enabled.")
        elseif state == "off" then
            FieryBlazeTrackerDB.autoReset = false
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
    end
end