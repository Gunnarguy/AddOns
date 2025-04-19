-- Addon Namespace
local addonName, addonTable = ...
local DragonbreathChiliTracker = CreateFrame("Frame", "DragonbreathChiliTrackerFrame", UIParent)

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
local cooldownTime = 10 -- Cooldown time in seconds
local cooldownEndTime = 0 -- Time when the cooldown ends

-- Saved Variables Table with proper initialization
-- This ensures we persist data between sessions
DragonbreathChiliTrackerDB = DragonbreathChiliTrackerDB or {
    allTime = 0,         -- All-time damage persists between game sessions
    locked = false,      -- Whether frame is locked or not
    framePosition = nil  -- Frame position saved between sessions
}

--------------------------------------------------------------------------------
-- Create UI Frame (Slightly bigger for improved readability)
--------------------------------------------------------------------------------
local frame = CreateFrame("Frame", "DragonbreathChiliTrackerDisplay", UIParent, "BackdropTemplate")
frame:SetSize(240, 120)  -- Larger size for better readability
frame:SetScale(0.8)      -- Global scale factor
frame:SetPoint(framePosition.point, UIParent, framePosition.relativePoint, framePosition.x, framePosition.y)

-- Set up frame appearance
frame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 32,
    edgeSize = 14,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0, 0, 0, 0.7)
frame:SetBackdropBorderColor(0.8, 0.8, 0.8)

-- Movable & Lockable frame setup
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
end)

--------------------------------------------------------------------------------
-- Title Text
--------------------------------------------------------------------------------
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -8)
title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
title:SetText("|cff00ff96Dragonbreath Chili|r")

--------------------------------------------------------------------------------
-- Damage Text (Bullet-Style)
--------------------------------------------------------------------------------
local damageText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
damageText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
damageText:SetPoint("TOPLEFT", 12, -30)
damageText:SetWidth(210)
damageText:SetJustifyH("LEFT")
damageText:SetWordWrap(true)

--------------------------------------------------------------------------------
-- Cooldown Text 
--------------------------------------------------------------------------------
local cooldownText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
cooldownText:SetPoint("TOPLEFT", damageText, "BOTTOMLEFT", 0, -4)  -- Just 4px gap
cooldownText:SetWidth(210)
cooldownText:SetJustifyH("LEFT")
cooldownText:SetWordWrap(true)

--------------------------------------------------------------------------------
-- Combat DPS Text
--------------------------------------------------------------------------------
local combatDPSText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
combatDPSText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
combatDPSText:SetPoint("TOPLEFT", cooldownText, "BOTTOMLEFT", 0, -4)
combatDPSText:SetWidth(210)
combatDPSText:SetJustifyH("LEFT")
combatDPSText:SetWordWrap(true)

--------------------------------------------------------------------------------
-- Lock Button (Bottom-Right)
--------------------------------------------------------------------------------
local lockButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lockButton:SetSize(60, 20)
lockButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
lockButton:SetText(DragonbreathChiliTrackerDB.locked and "Unlock" or "Lock")
lockButton:SetScript("OnClick", function(self)
    DragonbreathChiliTrackerDB.locked = not DragonbreathChiliTrackerDB.locked
    self:SetText(DragonbreathChiliTrackerDB.locked and "Unlock" or "Lock")
    if DragonbreathChiliTrackerDB.locked then
        print("Dragonbreath Chili frame locked.")
    else
        print("Dragonbreath Chili frame unlocked.")
    end
end)

--------------------------------------------------------------------------------
-- Reset Button (Bottom-Left)
--------------------------------------------------------------------------------
local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
resetButton:SetSize(60, 20)
resetButton:SetPoint("BOTTOM", frame, "BOTTOM", 10, 10)
resetButton:SetText("Reset")
resetButton:SetScript("OnClick", function(self)
    -- Create dropdown menu for reset options
    local menu = {
        { text = "Reset Options", isTitle = true, notCheckable = true },
        { text = "Current Fight", notCheckable = true, func = function() ResetCurrentFight() end },
        { text = "Session Stats", notCheckable = true, func = function() ResetSession() end },
        { text = "All-Time Stats", notCheckable = true, func = function() ResetAllTime() end },
        { text = "Cancel", notCheckable = true, func = function() end },
    }
    
    -- Show dropdown menu at cursor position
    EasyMenu(menu, CreateFrame("Frame", "ChiliResetMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
end)

--------------------------------------------------------------------------------
-- Format number with K/M suffixes for better readability
--------------------------------------------------------------------------------
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
-- UpdateDamageDisplay: Shows bullet-style damage stats
--------------------------------------------------------------------------------
local function UpdateDamageDisplay()
    damageText:SetText(string.format(
        "|cff00ff00Dragonbreath Chili Damage|r\n" ..
        "  • Current: %s\n" ..
        "  • Session: %s\n" ..
        "  • All-Time: %s",
        FormatNumber(damageData.current),
        FormatNumber(damageData.session),
        FormatNumber(damageData.allTime)
    ))
end

--------------------------------------------------------------------------------
-- UpdateCooldownDisplay: Shows cooldown status
--------------------------------------------------------------------------------
local function UpdateCooldownDisplay()
    local remainingTime = cooldownEndTime - GetTime()
    if remainingTime > 0 then
        cooldownText:SetText(string.format(
            "|cff00ff00Cooldown:|r\n" ..
            "  %d second(s)",
            math.ceil(remainingTime)
        ))
    else
        cooldownText:SetText(
            "|cff00ff00Cooldown:|r\n" ..
            "  Ready"
        )
    end
end

--------------------------------------------------------------------------------
-- UpdateCombatDPS: Shows DPS information for current/last fight
--------------------------------------------------------------------------------
local function UpdateCombatDPS()
    -- Calculate current combat duration
    local currentTime = GetTime()
    local duration = combatInfo.inCombat and (currentTime - combatInfo.startTime) or combatInfo.duration
    
    -- Only show DPS if we have both damage and duration
    if damageData.current > 0 and duration > 0 then
        local dps = damageData.current / duration
        combatDPSText:SetText(string.format(
            "|cff00ff00Combat Stats:|r\n" ..
            "  • DPS: %s (%.1f sec)",
            FormatNumber(dps),
            duration
        ))
    else
        combatDPSText:SetText(
            "|cff00ff00Combat Stats:|r\n" ..
            "  • No data yet"
        )
    end
end

--------------------------------------------------------------------------------
-- OnCombatStart: Tracks when player enters combat
--------------------------------------------------------------------------------
local function OnCombatStart()
    if not combatInfo.inCombat then
        combatInfo.inCombat = true
        combatInfo.startTime = GetTime()
        -- Don't reset damage on combat start - let it accumulate until manually reset
    end
end

--------------------------------------------------------------------------------
-- OnCombatEnd: Tracks when player leaves combat
--------------------------------------------------------------------------------
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
function ResetCurrentFight()
    damageData.current = 0
    combatInfo.startTime = combatInfo.inCombat and GetTime() or 0
    combatInfo.duration = 0
    UpdateDamageDisplay()
    UpdateCombatDPS()
    print("Dragonbreath Chili current fight damage reset!")
end

function ResetSession()
    damageData.session = 0
    UpdateDamageDisplay()
    print("Dragonbreath Chili session damage reset!")
end

function ResetAllTime()
    damageData.allTime = 0
    DragonbreathChiliTrackerDB.allTime = 0 -- Update saved value immediately
    UpdateDamageDisplay()
    print("Dragonbreath Chili all-time damage reset!")
end

--------------------------------------------------------------------------------
-- Save/Load Frame Position
--------------------------------------------------------------------------------
local function SaveFramePosition()
    DragonbreathChiliTrackerDB.framePosition = framePosition
end

local function LoadFramePosition()
    if DragonbreathChiliTrackerDB.framePosition then
        local pos = DragonbreathChiliTrackerDB.framePosition
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
DragonbreathChiliTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DragonbreathChiliTracker:RegisterEvent("PLAYER_REGEN_ENABLED")
DragonbreathChiliTracker:RegisterEvent("PLAYER_REGEN_DISABLED")
DragonbreathChiliTracker:RegisterEvent("ADDON_LOADED")
DragonbreathChiliTracker:RegisterEvent("PLAYER_LOGOUT")
DragonbreathChiliTracker:RegisterEvent("PLAYER_ENTERING_WORLD")

DragonbreathChiliTracker:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, sourceGUID, _, _, _, _, _, _, _, spellID, _, _, amount = CombatLogGetCurrentEventInfo()
        -- Only track Dragonbreath Chili damage from the player
        if sourceGUID == UnitGUID("player") and subevent == "SPELL_DAMAGE" and spellID == 15851 and amount then
            damageData.current  = damageData.current + amount
            damageData.session  = damageData.session + amount
            damageData.allTime  = damageData.allTime + amount
            cooldownEndTime     = GetTime() + cooldownTime
            
            -- Make sure we track combat status if damage happens outside normal combat
            if not combatInfo.inCombat then
                OnCombatStart()
            end
            
            -- Update all displays when damage occurs
            UpdateDamageDisplay()
            UpdateCombatDPS()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Player left combat
        OnCombatEnd()

    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Player entered combat
        OnCombatStart()

    elseif event == "ADDON_LOADED" and ... == addonName then
        -- Load saved data
        damageData.allTime = DragonbreathChiliTrackerDB.allTime or 0
        
        -- Load frame position
        framePosition = DragonbreathChiliTrackerDB.framePosition or framePosition
        LoadFramePosition()
        UpdateDamageDisplay()

    elseif event == "PLAYER_LOGOUT" then
        -- Save data before logout
        DragonbreathChiliTrackerDB.allTime = damageData.allTime
        SaveFramePosition()

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Setup OnUpdate handler for timers
        self:SetScript("OnUpdate", function(self, elapsed)
            self.updateTimer = (self.updateTimer or 0) + elapsed
            
            -- Update UI elements every 0.1 seconds (10 times per second)
            if self.updateTimer >= 0.1 then
                UpdateCooldownDisplay()
                
                -- Only update DPS in combat to avoid unnecessary calculations
                if combatInfo.inCombat then
                    UpdateCombatDPS()
                end
                
                self.updateTimer = 0
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_DRAGONCHILI1 = "/chilitracker"
SlashCmdList["DRAGONCHILI"] = function(msg)
    if msg == "resetfight" then
        ResetCurrentFight()
    elseif msg == "resetsession" then
        ResetSession()
    elseif msg == "resetalltime" then
        ResetAllTime()
    elseif msg == "toggle" then
        if frame:IsShown() then
            frame:Hide()
            print("Dragonbreath Chili Tracker hidden.")
        else
            frame:Show()
            print("Dragonbreath Chili Tracker shown.")
        end
    else
        print("Dragonbreath Chili Tracker Commands:")
        print("/chilitracker resetfight - Reset current fight damage.")
        print("/chilitracker resetsession - Reset session damage.")
        print("/chilitracker resetalltime - Reset all-time damage.")
        print("/chilitracker toggle - Show/hide the tracker.")
    end
end