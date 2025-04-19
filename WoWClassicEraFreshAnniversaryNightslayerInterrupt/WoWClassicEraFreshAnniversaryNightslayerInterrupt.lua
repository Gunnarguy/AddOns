-- WoW Classic Era Fresh Anniversary Nightslayer Interrupt
-- Announces in /say when you've been interrupted and counts down the seconds

-- Create addon namespace
local addonName, NS = ...
local Interrupt = CreateFrame("Frame", "WoWClassicEraFreshAnniversaryNightslayerInterrupt")

-- Local variables
NS.playerName = UnitName("player")
NS.playerGUID = UnitGUID("player")
NS.interruptDuration = 0
NS.interruptTimeLeft = 0
NS.interruptActive = false
NS.countdownFrame = nil
NS.countdownText = nil

-- Default settings
NS.defaults = {
    enabled = true,
    announceInSay = true,
    countdownVisible = true,
    position = {
        x = 0,
        y = 100
    }
}

-- Initialize saved variables
WoWClassicEraFreshAnniversaryNightslayerInterruptDB = WoWClassicEraFreshAnniversaryNightslayerInterruptDB or CopyTable(NS.defaults)
NS.db = WoWClassicEraFreshAnniversaryNightslayerInterruptDB

-- Ensure the main frame is properly initialized and visible
if not NS.db then
    NS.db = WoWClassicEraFreshAnniversaryNightslayerInterruptDB or CopyTable(NS.defaults)
end

-- Set the frame visibility based on the saved settings
if NS.db.enabled then
    if not NS.countdownFrame then
        NS:CreateCountdownFrame()
    end
    NS.countdownFrame:Show()
else
    if NS.countdownFrame then
        NS.countdownFrame:Hide()
    end
end

-- UI Creation Functions
function NS:CreateCountdownFrame()
    -- Create countdown frame
    self.countdownFrame = CreateFrame("Frame", "WoWClassicEraFreshAnniversaryNightslayerInterruptFrame", UIParent)
    local frame = self.countdownFrame
    
    -- Configure frame properties
    frame:SetWidth(200)
    frame:SetHeight(60)
    frame:SetPoint("CENTER", UIParent, "CENTER", self.db.position.x, self.db.position.y)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetFrameStrata("HIGH")
    
    -- Drag handlers
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local _, _, _, x, y = self:GetPoint()
        NS.db.position.x = x
        NS.db.position.y = y
    end)
    
    -- Background for the frame
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetTexture(0, 0, 0, 0.7)
    
    -- Border for the frame
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Text for the countdown
    self.countdownText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.countdownText:SetPoint("CENTER", frame, "CENTER", 0, 0)
    self.countdownText:SetText("No interrupt active")
    
    -- Hide the frame initially
    frame:Hide()
end

-- Interrupt handling functions
function NS:HandleInterrupt(sourceName, spellName)
    -- Set up interrupt duration and state
    self.interruptDuration = 6 -- Default to 6 seconds
    self.interruptTimeLeft = self.interruptDuration
    self.interruptActive = true
    
    -- Announce the interrupt in /say if enabled
    if self.db.enabled and self.db.announceInSay then
        SendChatMessage("I've been interrupted by " .. sourceName .. " using " .. spellName .. " and can't do anything for " .. self.interruptDuration .. " seconds!", "SAY")
    end
    
    -- Show the countdown frame if enabled
    if self.db.enabled and self.db.countdownVisible then
        self.countdownFrame:Show()
    end
    
    -- Start the countdown using OnUpdate
    Interrupt:SetScript("OnUpdate", function(_, elapsed)
        NS:UpdateInterruptCountdown(elapsed)
    end)
end

function NS:UpdateInterruptCountdown(elapsed)
    if not self.interruptActive then return end
    
    self.interruptTimeLeft = self.interruptTimeLeft - elapsed
    
    if self.interruptTimeLeft <= 0 then
        self:EndInterrupt()
    else
        -- Update the countdown text
        self.countdownText:SetText("INTERRUPTED!\n" .. math.ceil(self.interruptTimeLeft) .. " seconds remaining")
    end
end

function NS:EndInterrupt()
    self.interruptActive = false
    self.countdownFrame:Hide()
    Interrupt:SetScript("OnUpdate", nil)
    
    -- Announce when the interrupt effect ends
    if self.db.enabled and self.db.announceInSay then
        SendChatMessage("I can cast spells again!", "SAY")
    end
end

-- Event handling
function NS:ProcessCombatLogEvent(timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool)
    -- Check if the addon is enabled
    if not self.db.enabled then return end
    
    -- Check if the event is an interrupt and the player is the target
    if eventType == "SPELL_INTERRUPT" and destGUID == self.playerGUID then
        self:HandleInterrupt(sourceName, spellName)
    end
end

-- Command handling
function NS:HandleCommands(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end
    
    if args[1] == "enable" or args[1] == "on" then
        self.db.enabled = true
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Enabled")
    elseif args[1] == "disable" or args[1] == "off" then
        self.db.enabled = false
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Disabled")
    elseif args[1] == "say" and args[2] == "on" then
        self.db.announceInSay = true
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Announcing in /say enabled")
    elseif args[1] == "say" and args[2] == "off" then
        self.db.announceInSay = false
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Announcing in /say disabled")
    elseif args[1] == "countdown" and args[2] == "on" then
        self.db.countdownVisible = true
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Countdown display enabled")
    elseif args[1] == "countdown" and args[2] == "off" then
        self.db.countdownVisible = false
        self.countdownFrame:Hide()
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Countdown display disabled")
    elseif args[1] == "reset" then
        self.db.position.x = 0
        self.db.position.y = 100
        self.countdownFrame:ClearAllPoints()
        self.countdownFrame:SetPoint("CENTER", UIParent, "CENTER", self.db.position.x, self.db.position.y)
        print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Position reset")
    else
        self:PrintHelp()
    end
end

function NS:PrintHelp()
    print("WoW Classic Era Fresh Anniversary Nightslayer Interrupt: Commands")
    print("  /wowinterrupt enable - Enable the addon")
    print("  /wowinterrupt disable - Disable the addon")
    print("  /wowinterrupt say on/off - Toggle announcing in /say")
    print("  /wowinterrupt countdown on/off - Toggle countdown display")
    print("  /wowinterrupt reset - Reset countdown frame position")
    print("Drag the countdown frame to move it")
end

-- Initialize the addon
function NS:Initialize()
    -- Create UI elements
    self:CreateCountdownFrame()
    
    -- Register events
    Interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    Interrupt:RegisterEvent("PLAYER_LOGIN")
    
    -- Set up event handler
    Interrupt:SetScript("OnEvent", function(_, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            -- Process the combat log event
            NS:ProcessCombatLogEvent(CombatLogGetCurrentEventInfo())
        elseif event == "PLAYER_LOGIN" then
            -- Initialize player GUID
            NS.playerGUID = UnitGUID("player")
            
            -- Print welcome message
            print("|cFF00FF00WoW Classic Era Fresh Anniversary Nightslayer Interrupt|r loaded. Type /wowinterrupt for options.")
        end
    end)
    
    -- Set up slash command
    SLASH_WOWINTERRUPT1 = "/wowinterrupt"
    SlashCmdList["WOWINTERRUPT"] = function(msg)
        NS:HandleCommands(msg)
    end
end

-- Start the addon
NS:Initialize()
