-- ParryHasteTracker.lua
-- Author: Gemini AI (for Gunnar)
-- Version: 1.1-Corrected

-- Initialize main addon table
ParryHasteTracker = {}
local PHT = ParryHasteTracker

-- Initialize default settings
PHT.defaults = {
    enabled = true,
    showFrame = true,
    timeSaved = 0,
    extraSwings = 0,
    totalParries = 0,
    framePosition = {
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = 0
    }
}

-- Initialize variables
PHT.isSwinging = false
PHT.swingStart = 0
PHT.swingEnd = 0
PHT.swingDuration = 0
PHT.lastParryTime = 0
PHT.mainHandSpeed = 0
PHT.offHandSpeed = 0
PHT.usingTwoHander = false
PHT.isInitialized = false

-- Create main frame for events
PHT.frame = CreateFrame("Frame", "ParryHasteTrackerFrame", UIParent)
PHT.frame:SetScript("OnEvent", function(self, event, ...)
    if PHT[event] then
        PHT[event](PHT, ...)
    end
end)

-- Register events
PHT.frame:RegisterEvent("ADDON_LOADED")
PHT.frame:RegisterEvent("PLAYER_LOGIN")
PHT.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PHT.frame:RegisterEvent("UNIT_ATTACK_SPEED")
PHT.frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Enter combat
PHT.frame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Leave combat

-- Handle addon loading
function PHT:ADDON_LOADED(addonName)
    if addonName == "ParryHasteTracker" then
        -- Initialize saved variables
        if not ParryHasteTracker_DB then
            ParryHasteTracker_DB = CopyTable(self.defaults)
        else
            -- Ensure all default values exist
            for k, v in pairs(self.defaults) do
                if ParryHasteTracker_DB[k] == nil then
                    ParryHasteTracker_DB[k] = v
                end
            end
        end
        
        -- Store reference to DB
        self.db = ParryHasteTracker_DB
    end
end

-- Handle player login
function PHT:PLAYER_LOGIN()
    -- Initialize weapon speed
    self:UpdateWeaponSpeeds()
    
    -- Create display frame
    self:CreateDisplayFrame()
    
    -- Set as initialized
    self.isInitialized = true
    
    -- Print welcome message
    self:Print("Parry Haste Tracker loaded. Type /pht for options.")
    
    -- Register slash commands
    SLASH_PARRYHASTETRACKER1 = "/pht"
    SLASH_PARRYHASTETRACKER2 = "/parryhastetracker"
    SlashCmdList["PARRYHASTETRACKER"] = function(msg)
        self:SlashCommand(msg)
    end
end

-- Update weapon speeds
function PHT:UpdateWeaponSpeeds()
    local mainHandSpeed, offHandSpeed = UnitAttackSpeed("player")
    self.mainHandSpeed = mainHandSpeed or 0
    
    -- Check if using two-handed weapon (offHandSpeed will be 0)
    if offHandSpeed and offHandSpeed > 0 then
        self.offHandSpeed = offHandSpeed
        self.usingTwoHander = false
    else
        self.offHandSpeed = 0
        self.usingTwoHander = true
    end
end

-- Handle attack speed changes
function PHT:UNIT_ATTACK_SPEED(unit)
    if unit == "player" then
        self:UpdateWeaponSpeeds()
    end
end

-- Handle combat log events
function PHT:COMBAT_LOG_EVENT_UNFILTERED()
    -- Only process if addon is initialized and enabled
    if not self.isInitialized or not self.db.enabled then return end
    
    local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, missType = CombatLogGetCurrentEventInfo()
    
    -- Check if player is the source of a swing
    if sourceGUID == UnitGUID("player") then
        if eventType == "SWING_DAMAGE" or (eventType == "SWING_MISSED" and missType ~= "PARRY") then
            -- Player performed an auto-attack, start/update the swing timer
            self:StartSwingTimer()
        end
        
        -- Handle abilities that reset swing timer (like Slam for warriors)
        if eventType == "SPELL_CAST_SUCCESS" then
            local spellID = select(12, CombatLogGetCurrentEventInfo())
            if self:IsSwingResetAbility(spellID) then
                self:StartSwingTimer()
            end
        end
    end
    
    -- Check if player parried an attack
    if destGUID == UnitGUID("player") and eventType == "SWING_MISSED" and missType == "PARRY" then
        self:HandleParry(timestamp)
    end
end

-- Check if a spell resets the swing timer
function PHT:IsSwingResetAbility(spellID)
    -- List of abilities that reset swing timer
    local swingResetAbilities = {
        [1464] = true, -- Slam (Warrior)
        [78] = true,   -- Heroic Strike (Warrior)
        -- Add other abilities as needed
    }
    
    return swingResetAbilities[spellID] or false
end

-- Start swing timer
function PHT:StartSwingTimer()
    self.isSwinging = true
    self.swingStart = GetTime()
    self.swingEnd = self.swingStart + self.mainHandSpeed
    self.swingDuration = self.mainHandSpeed
end

-- Handle parry event
function PHT:HandleParry(timestamp)
    -- Only process if we're currently swinging
    if not self.isSwinging then return end
    
    local currentTime = GetTime()
    local timeRemaining = self.swingEnd - currentTime
    local percentRemaining = timeRemaining / self.swingDuration
    
    -- Apply parry haste rule: 40% reduction unless it would go below 20% remaining
    if percentRemaining > 0.2 then
        -- Calculate time to remove (40% of total swing duration)
        local timeReduction = self.swingDuration * 0.4
        
        -- Ensure we don't go below 20% remaining
        if (timeRemaining - timeReduction) < (self.swingDuration * 0.2) then
            timeReduction = timeRemaining - (self.swingDuration * 0.2)
        end
        
        -- Apply the time reduction
        if timeReduction > 0 then
            self.swingEnd = self.swingEnd - timeReduction
            
            -- Update statistics
            self.db.timeSaved = self.db.timeSaved + timeReduction
            self.db.extraSwings = self.db.extraSwings + (timeReduction / self.swingDuration)
            self.db.totalParries = self.db.totalParries + 1
            
            -- Update display
            self:UpdateDisplay()
        end
    end
    
    -- Record last parry time for debugging
    self.lastParryTime = currentTime
end

-- Create display frame
function PHT:CreateDisplayFrame()
    -- Create main display frame
    self.displayFrame = CreateFrame("Frame", "ParryHasteTrackerDisplayFrame", UIParent, "BackdropTemplate")
    self.displayFrame:SetSize(200, 100)
    self.displayFrame:SetPoint(
        self.db.framePosition.point, 
        UIParent, 
        self.db.framePosition.relativePoint, 
        self.db.framePosition.xOffset, 
        self.db.framePosition.yOffset
    )
    self.displayFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.displayFrame:SetBackdropColor(0, 0, 0, 0.7)
    
    -- Make frame movable
    self.displayFrame:SetMovable(true)
    self.displayFrame:EnableMouse(true)
    self.displayFrame:RegisterForDrag("LeftButton")
    self.displayFrame:SetScript("OnDragStart", function() self.displayFrame:StartMoving() end)
    self.displayFrame:SetScript("OnDragStop", function() 
        self.displayFrame:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, xOffset, yOffset = self.displayFrame:GetPoint()
        self.db.framePosition.point = point
        self.db.framePosition.relativePoint = relativePoint
        self.db.framePosition.xOffset = xOffset
        self.db.framePosition.yOffset = yOffset
    end)
    
    -- Create title
    self.displayFrame.title = self.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.displayFrame.title:SetPoint("TOP", self.displayFrame, "TOP", 0, -10)
    self.displayFrame.title:SetText("|cffAAAAFFParry Haste Tracker|r")
    
    -- Create stats text
    self.displayFrame.stats = self.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.displayFrame.stats:SetPoint("TOPLEFT", self.displayFrame, "TOPLEFT", 15, -30)
    self.displayFrame.stats:SetJustifyH("LEFT")
    
    -- Show or hide based on settings
    if self.db.showFrame then
        self.displayFrame:Show()
    else
        self.displayFrame:Hide()
    end
    
    -- Initial update
    self:UpdateDisplay()
end

-- Update display with current stats
function PHT:UpdateDisplay()
    if not self.displayFrame then return end
    
    local text = string.format(
        "Parries: %d\nTime Saved: %.2f seconds\nExtra Swings: %.2f",
        self.db.totalParries,
        self.db.timeSaved,
        self.db.extraSwings
    )
    
    self.displayFrame.stats:SetText(text)
end

-- Print to chat
function PHT:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffAAAAFF[Parry Haste Tracker]|r " .. msg)
end

-- Handle slash commands
function PHT:SlashCommand(msg)
    local cmd, rest = self:GetArgs(msg, 2)
    cmd = cmd and cmd:lower() or "help"
    
    if cmd == "help" then
        self:Print("Commands:")
        self:Print("/pht show - Show the tracker frame")
        self:Print("/pht hide - Hide the tracker frame")
        self:Print("/pht reset - Reset all statistics")
        self:Print("/pht toggle - Toggle the addon on/off")
        self:Print("/pht status - Show current statistics")
    elseif cmd == "show" then
        self.db.showFrame = true
        self.displayFrame:Show()
        self:Print("Tracker frame shown.")
    elseif cmd == "hide" then
        self.db.showFrame = false
        self.displayFrame:Hide()
        self:Print("Tracker frame hidden.")
    elseif cmd == "reset" then
        self.db.timeSaved = 0
        self.db.extraSwings = 0
        self.db.totalParries = 0
        self:UpdateDisplay()
        self:Print("Statistics reset.")
    elseif cmd == "toggle" then
        self.db.enabled = not self.db.enabled
        self:Print("Addon " .. (self.db.enabled and "enabled" or "disabled") .. ".")
    elseif cmd == "status" then
        self:Print(string.format("Total Parries: %d", self.db.totalParries))
        self:Print(string.format("Time Saved: %.2f seconds", self.db.timeSaved))
        self:Print(string.format("Extra Swings: %.2f", self.db.extraSwings))
    else
        self:Print("Unknown command. Type /pht help for a list of commands.")
    end
end

-- Helper function to parse arguments
function PHT:GetArgs(str, numArgs)
    if not str then return end
    
    local args = {}
    for i = 1, numArgs do
        local arg = self:GetArg(str)
        if not arg then break end
        args[i] = arg
        str = string.sub(str, string.len(arg) + (string.find(str, arg) or 0))
        str = string.match(str, "^%s*(.*)$")
    end
    
    return unpack(args)
end

-- Get a single argument
function PHT:GetArg(str)
    if not str or str == "" then return end
    
    -- If the string starts with a quoted argument
    if string.sub(str, 1, 1) == "\"" then
        local endPos = string.find(str, "\"", 2)
        if endPos then
            return string.sub(str, 2, endPos - 1)
        else
            return string.sub(str, 2)
        end
    else
        -- Otherwise, get the first word
        local arg = string.match(str, "^([^%s]+)")
        return arg
    end
end

-- Handle entering combat
function PHT:PLAYER_REGEN_DISABLED()
    -- Reset swing timer for new combat
    self.isSwinging = false
end

-- Handle leaving combat
function PHT:PLAYER_REGEN_ENABLED()
    -- Reset swing timer after combat
    self.isSwinging = false
end
