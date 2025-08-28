-- Addon Namespace
local addonName, addonTable = ...
local DragonbreathChiliTracker = CreateFrame("Frame", "DragonbreathChiliTrackerFrame", UIParent)

-- Constants
local FONT_PATH = "Fonts\\\\FRIZQT__.TTF" -- Default game font
local FONT_STYLE_OUTLINE = "OUTLINE"
local COLOR_GREEN_HEX = "|cff00ff00"
local COLOR_HIGHLIGHT_HEX = "|cff00ff96"
local COLOR_RESET_HEX = "|r"
local DRAGONBREATH_CHILI_SPELL_ID = 15851
local DEFAULT_COOLDOWN_SECONDS = 10

-- Variables for tracking damage and combat timing
local damageData = {
    current = 0,    -- Current combat encounter damage
    session = 0,    -- Session damage (persists until manual reset)
    allTime = 0     -- All-time damage (persists between game sessions)
}
local combatInfo = {
    startTime = 0,        -- When current combat started
    inCombat = false,     -- Currently in combat flag
    duration = 0          -- Duration of current/last combat
}
local framePosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 } -- Default position
local cooldownEndTime = 0 -- Time when the cooldown ends

-- Saved Variables Table with proper initialization
DragonbreathChiliTrackerDB = DragonbreathChiliTrackerDB or {
    allTime = 0,
    locked = false,
    framePosition = nil -- Will use default if nil
}

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

-- Format number with K/M suffixes for better readability
local function FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(math.floor(number))
    end
end

--------------------------------------------------------------------------------
-- UI Creation
--------------------------------------------------------------------------------
local displayFrame -- Declare displayFrame to be accessible by UI functions

-- Helper to apply standard font settings to text elements
local function SetupStandardText(fontString)
    fontString:SetFont(FONT_PATH, 10, FONT_STYLE_OUTLINE)
    fontString:SetWidth(210)
    fontString:SetJustifyH("LEFT")
    fontString:SetWordWrap(true)
end

local function CreateMainFrame()
    local frame = CreateFrame("Frame", "DragonbreathChiliTrackerDisplay", UIParent, "BackdropTemplate")
    frame:SetSize(240, 120)
    frame:SetScale(0.8)
    frame:SetPoint(framePosition.point, UIParent, framePosition.relativePoint, framePosition.x, framePosition.y)

    frame:SetBackdrop({
        bgFile   = "Interface\\\\DialogFrame\\\\UI-DialogBox-Background",
        edgeFile = "Interface\\\\Tooltips\\\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 32,
        edgeSize = 14,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.7)
    frame:SetBackdropBorderColor(0.8, 0.8, 0.8)

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not DragonbreathChiliTrackerDB.locked then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        framePosition = { point = point, relativePoint = relativePoint, x = x, y = y }
        -- Potentially call SaveFramePosition() here if immediate save on drag is desired
    end)
    return frame
end

local function CreateTextElements(parentFrame)
    local title = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -8)
    title:SetFont(FONT_PATH, 12, FONT_STYLE_OUTLINE) -- Title uses a slightly larger font
    title:SetText(COLOR_HIGHLIGHT_HEX .. "Dragonbreath Chili" .. COLOR_RESET_HEX)

    local damageText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    damageText:SetPoint("TOPLEFT", 12, -30)
    SetupStandardText(damageText)

    local cooldownText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownText:SetPoint("TOPLEFT", damageText, "BOTTOMLEFT", 0, -4)
    SetupStandardText(cooldownText)

    local combatDPSText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    combatDPSText:SetPoint("TOPLEFT", cooldownText, "BOTTOMLEFT", 0, -4)
    SetupStandardText(combatDPSText)

    return title, damageText, cooldownText, combatDPSText
end

local function CreateButtons(parentFrame)
    local lockButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    lockButton:SetSize(10, 10)
    lockButton:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 15, 0)
    lockButton:SetText(DragonbreathChiliTrackerDB.locked and "U" or "L")
    lockButton:SetScript("OnClick", function(self)
        DragonbreathChiliTrackerDB.locked = not DragonbreathChiliTrackerDB.locked
        self:SetText(DragonbreathChiliTrackerDB.locked and "U" or "L")
        print(addonName .. " frame " .. (DragonbreathChiliTrackerDB.locked and "locked." or "unlocked."))
    end)

    local resetButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(10, 10)
    resetButton:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 35, 0) -- Adjusted for clarity if needed, original was fine
    resetButton:SetText("R")
    resetButton:SetScript("OnClick", function()
        local menu = {
            { text = "Reset Options", isTitle = true, notCheckable = true },
            { text = "Current Fight", notCheckable = true, func = function() ResetCurrentFight() end },
            { text = "Session Stats", notCheckable = true, func = function() ResetSession() end },
            { text = "All-Time Stats", notCheckable = true, func = function() ResetAllTime() end },
            { text = "Cancel", notCheckable = true, func = function() end },
        }
        EasyMenu(menu, CreateFrame("Frame", "ChiliResetMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
    end)
    return lockButton, resetButton
end

-- Initialize UI
displayFrame = CreateMainFrame()
local titleText, damageTextElement, cooldownTextElement, combatDPSTextElement = CreateTextElements(displayFrame)
local lockButton, resetButton = CreateButtons(displayFrame)


--------------------------------------------------------------------------------
-- UI Update Functions
--------------------------------------------------------------------------------
local function UpdateDamageDisplay()
    damageTextElement:SetText(string.format(
        "%sDragonbreath Chili Damage%s\n" ..
        "  • Current: %s\n" ..
        "  • Session: %s\n" ..
        "  • All-Time: %s",
        COLOR_GREEN_HEX, COLOR_RESET_HEX,
        FormatNumber(damageData.current),
        FormatNumber(damageData.session),
        FormatNumber(damageData.allTime)
    ))
end

local function UpdateCooldownDisplay()
    local remainingTime = cooldownEndTime - GetTime()
    if remainingTime > 0 then
        cooldownTextElement:SetText(string.format(
            "%sCooldown:%s\n" ..
            "  %d second(s)",
            COLOR_GREEN_HEX, COLOR_RESET_HEX,
            math.ceil(remainingTime)
        ))
    else
        cooldownTextElement:SetText(
            COLOR_GREEN_HEX .. "Cooldown:" .. COLOR_RESET_HEX .. "\\n" ..
            "  Ready"
        )
    end
end

local function UpdateCombatDPS()
    local currentTime = GetTime()
    local currentDuration = combatInfo.inCombat and (currentTime - combatInfo.startTime) or combatInfo.duration
    
    if damageData.current > 0 and currentDuration > 0 then
        local dps = damageData.current / currentDuration
        combatDPSTextElement:SetText(string.format(
            "%sCombat Stats:%s\\n" ..
            "  • DPS: %s (%.1f sec)",
            COLOR_GREEN_HEX, COLOR_RESET_HEX,
            FormatNumber(dps),
            currentDuration
        ))
    else
        combatDPSTextElement:SetText(
            COLOR_GREEN_HEX .. "Combat Stats:" .. COLOR_RESET_HEX .. "\\n" ..
            "  • No data yet"
        )
    end
end

--------------------------------------------------------------------------------
-- Combat Logic
--------------------------------------------------------------------------------
local function OnCombatStart()
    if not combatInfo.inCombat then
        combatInfo.inCombat = true
        combatInfo.startTime = GetTime()
        -- Current damage accumulates until manually reset or new combat if desired
        -- For now, it persists across combats within a session until ResetCurrentFight
    end
end

local function OnCombatEnd()
    if combatInfo.inCombat then
        combatInfo.inCombat = false
        combatInfo.duration = GetTime() - combatInfo.startTime
        UpdateCombatDPS() -- Update DPS display when combat ends
    end
end

--------------------------------------------------------------------------------
-- Reset Functions
--------------------------------------------------------------------------------

-- Helper function to announce resets and update relevant UI elements
local function AnnounceReset(category)
    UpdateDamageDisplay()
    UpdateCombatDPS()
    print(addonName .. " " .. category .. " reset!")
end

function ResetCurrentFight()
    damageData.current = 0
    combatInfo.startTime = combatInfo.inCombat and GetTime() or 0 -- Reset start time if in combat
    combatInfo.duration = 0
    AnnounceReset("current fight damage")
end

function ResetSession()
    damageData.current = 0 -- Also reset current fight damage as session includes it
    damageData.session = 0
    combatInfo.startTime = combatInfo.inCombat and GetTime() or 0
    combatInfo.duration = 0
    AnnounceReset("session damage")
end

function ResetAllTime()
    damageData.allTime = 0
    DragonbreathChiliTrackerDB.allTime = 0 -- Update saved value immediately
    -- Optionally reset current and session too if desired, e.g.:
    -- damageData.current = 0
    -- damageData.session = 0
    -- combatInfo.startTime = combatInfo.inCombat and GetTime() or 0
    -- combatInfo.duration = 0
    AnnounceReset("all-time damage") -- This will also call UpdateCombatDPS
end

--------------------------------------------------------------------------------
-- Persistence: Save/Load Frame Position
--------------------------------------------------------------------------------
local function SaveFramePosition()
    DragonbreathChiliTrackerDB.framePosition = framePosition
end

local function LoadFramePosition()
    if DragonbreathChiliTrackerDB.framePosition then
        local pos = DragonbreathChiliTrackerDB.framePosition
        displayFrame:ClearAllPoints()
        displayFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    elseif framePosition then -- Fallback to initial default if nothing saved
        displayFrame:ClearAllPoints()
        displayFrame:SetPoint(framePosition.point, UIParent, framePosition.relativePoint, framePosition.x, framePosition.y)
    end
end

--------------------------------------------------------------------------------
-- Event Handling Logic
--------------------------------------------------------------------------------
local function HandleCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, amount = CombatLogGetCurrentEventInfo()

    if sourceGUID == UnitGUID("player") and 
       subevent == "SPELL_DAMAGE" and 
       spellID == DRAGONBREATH_CHILI_SPELL_ID and 
       amount and amount > 0 then -- Ensure amount is positive
        
        damageData.current  = damageData.current + amount
        damageData.session  = damageData.session + amount
        damageData.allTime  = damageData.allTime + amount
        cooldownEndTime     = GetTime() + DEFAULT_COOLDOWN_SECONDS
        
        if not combatInfo.inCombat then
            OnCombatStart() -- Ensure combat is initiated
        end
        
        UpdateDamageDisplay()
        UpdateCombatDPS()
        -- Cooldown display is handled by the OnUpdate timer
    end
end

local function OnAddonLoaded(loadedAddonName)
    if loadedAddonName == addonName then
        -- Load saved data
        damageData.allTime = DragonbreathChiliTrackerDB.allTime or 0
        
        -- Load frame position (ensure displayFrame exists)
        if displayFrame then
             LoadFramePosition()
        end
        UpdateDamageDisplay() -- Update display with loaded data
        
        -- Set initial text for lock button based on saved state
        if lockButton then
            lockButton:SetText(DragonbreathChiliTrackerDB.locked and "Unlock" or "Lock")
        end
    end
end

local function OnPlayerLogout()
    DragonbreathChiliTrackerDB.allTime = damageData.allTime
    SaveFramePosition() -- Save frame position on logout
end

local function OnPlayerEnteringWorld()
    -- Setup OnUpdate handler for timers
    DragonbreathChiliTracker:SetScript("OnUpdate", function(self, elapsed)
        self.updateTimer = (self.updateTimer or 0) + elapsed
        
        if self.updateTimer >= 0.1 then -- Update 10 times per second
            UpdateCooldownDisplay()
            
            if combatInfo.inCombat then
                UpdateCombatDPS()
            end
            
            self.updateTimer = 0
        end
    end)
    -- Initial UI updates after entering world, in case ADDON_LOADED was too early for some UI elements
    if displayFrame then
        UpdateDamageDisplay()
        UpdateCooldownDisplay()
        UpdateCombatDPS()
    end
end

--------------------------------------------------------------------------------
-- Main Event Handler
--------------------------------------------------------------------------------
DragonbreathChiliTracker:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandleCombatLogEvent(...)
    elseif event == "PLAYER_REGEN_ENABLED" then -- Player left combat
        OnCombatEnd()
    elseif event == "PLAYER_REGEN_DISABLED" then -- Player entered combat
        OnCombatStart()
    elseif event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "PLAYER_LOGOUT" then
        OnPlayerLogout()
    elseif event == "PLAYER_ENTERING_WORLD" then
        OnPlayerEnteringWorld()
    end
end)

-- Register Events
DragonbreathChiliTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DragonbreathChiliTracker:RegisterEvent("PLAYER_REGEN_ENABLED")
DragonbreathChiliTracker:RegisterEvent("PLAYER_REGEN_DISABLED")
DragonbreathChiliTracker:RegisterEvent("ADDON_LOADED")
DragonbreathChiliTracker:RegisterEvent("PLAYER_LOGOUT")
DragonbreathChiliTracker:RegisterEvent("PLAYER_ENTERING_WORLD")

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_DRAGONCHILI1 = "/chilitracker"
SLASH_DRAGONCHILI2 = "/dbc" -- Alias

local slashCommands = {
    resetfight = ResetCurrentFight,
    resetsession = ResetSession,
    resetalltime = ResetAllTime,
    toggle = function()
        if displayFrame:IsShown() then
            displayFrame:Hide()
            print(addonName .. " Tracker hidden.")
        else
            displayFrame:Show()
            print(addonName .. " Tracker shown.")
        end
    end,
    lock = function() -- Added direct slash command for lock/unlock
        DragonbreathChiliTrackerDB.locked = not DragonbreathChiliTrackerDB.locked
        if lockButton then
            lockButton:SetText(DragonbreathChiliTrackerDB.locked and "Unlock" or "Lock")
        end
        print(addonName .. " frame " .. (DragonbreathChiliTrackerDB.locked and "locked." or "unlocked."))
    end
}

SlashCmdList["DRAGONCHILI"] = function(msg)
    local command = string.lower(string.match(msg, "^(%S*)")) -- Get first word as command
    if slashCommands[command] then
        slashCommands[command]()
    else
        print(COLOR_HIGHLIGHT_HEX .. addonName .. " Commands:" .. COLOR_RESET_HEX)
        print(SLASH_DRAGONCHILI1 .. " resetfight - Reset current fight damage.")
        print(SLASH_DRAGONCHILI1 .. " resetsession - Reset session damage.")
        print(SLASH_DRAGONCHILI1 .. " resetalltime - Reset all-time damage.")
        print(SLASH_DRAGONCHILI1 .. " toggle - Show/hide the tracker.")
        print(SLASH_DRAGONCHILI1 .. " lock - Toggle frame lock.")
    end
end

-- Initial update of displays once everything is set up
UpdateDamageDisplay()
UpdateCooldownDisplay()
UpdateCombatDPS()
print(COLOR_HIGHLIGHT_HEX .. addonName .. " loaded." .. COLOR_RESET_HEX)