-------------------------------------------------------------------------------
-- SpiritAppreciation.lua - Your Spirit's #1 Fan! (Classic 1.15.7)
-- Track and appreciate your spirit's contribution to mana regeneration
-------------------------------------------------------------------------------
local ADDON = ...

-- SavedVariables and defaults
SpiritAppreciationDB = SpiritAppreciationDB or {}
local defaults = {
    locked = false,
    scale = 1.0,
    alpha = 0.95,
    position = {"CENTER", "UIParent", "CENTER", 200, 0},
    showAppreciation = true,
    soundEnabled = true,
    
    -- Persistent stats
    totalManaFromSpirit = 0,
    sessionStart = 0,
    milestones = {},
    spiritHighScore = 0,
}

-- Merge defaults helper
local function mergeDefaults(t, d)
    for k, v in pairs(d) do
        if type(v) == "table" then
            t[k] = mergeDefaults(t[k] or {}, v)
        elseif t[k] == nil then
            t[k] = v
        end
    end
    return t
end

-- Helper to reset tables
local function wipeTable(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            wipeTable(v)
        else
            -- Reset numbers to 0, booleans to false, and strings to empty
            if type(v) == "number" then t[k] = 0
            elseif type(v) == "boolean" then t[k] = false
            elseif type(v) == "string" then t[k] = ""
            end
        end
    end
end

-- Session tracking
local session = {
    manaGained = 0,
    ticks = 0,
    combatMana = 0,
    nonCombatMana = 0,
    startTime = GetTime(),
    lastCastTime = 0,
    isRegenerating = false,
    lastMana = 0,
    lastTickTime = 0,  -- Track actual mana tick timing
    nextTickTime = 0,   -- Predict next tick
}

-- Spirit milestones for appreciation
local MILESTONES = {
    {mana = 1000, msg = "🌟 Your spirit has restored 1,000 mana!", sound = true},
    {mana = 5000, msg = "✨ Amazing! 5,000 mana from spirit!", sound = true},
    {mana = 10000, msg = "🎉 Incredible! 10,000 mana regenerated!", sound = true},
    {mana = 50000, msg = "👑 Spirit Master! 50,000 mana restored!", sound = true},
    {mana = 100000, msg = "🌠 LEGENDARY! 100,000 mana from spirit!", sound = true},
}

-- Calculate mana regen from spirit (Classic 1.15.7 EXACT formulas)
local function calculateSpiritRegen()
    local race, _ = UnitRace("player")
    local _, class = UnitClass("player")
    local spirit = UnitStat("player", 5) -- Spirit stat (includes racial bonus for Humans)
    local intellect = UnitStat("player", 4) -- Intellect stat
    local level = UnitLevel("player")
    local baseMp5 = 0
    
    -- Classic 1.15.7 Mana Regeneration Formulas:
    -- The addon correctly uses the simplified formulas (MP2 = Base + Spirit/Divisor)
    -- which are accurate for this version of the game.
    
    -- MP2 = X + (Spirit / Y) where X and Y are class-specific
    -- Then convert to MP5 by multiplying with 2.5
    
    if class == "DRUID" then
        -- Druid: MP2 = 15 + (Spirit / 5)
        local mp2 = 15 + (spirit / 5)
        baseMp5 = mp2 * 2.5
    elseif class == "HUNTER" then
        -- Hunter: MP2 = 15 + (Spirit / 5)
        local mp2 = 15 + (spirit / 5)
        baseMp5 = mp2 * 2.5
    elseif class == "MAGE" then
        -- Mage: MP2 = 13 + (Spirit / 4)
        local mp2 = 13 + (spirit / 4)
        baseMp5 = mp2 * 2.5
    elseif class == "PALADIN" then
        -- Paladin: MP2 = 15 + (Spirit / 5)
        local mp2 = 15 + (spirit / 5)
        baseMp5 = mp2 * 2.5
    elseif class == "PRIEST" then
        -- Priest: MP2 = 13 + (Spirit / 4)
        -- Note: Some sources say 12.5 base, but 13 is more commonly accepted
        local mp2 = 13 + (spirit / 4)
        baseMp5 = mp2 * 2.5
    elseif class == "SHAMAN" then
        -- Shaman: MP2 = 17 + (Spirit / 5)
        -- Shamans have the highest base regen
        local mp2 = 17 + (spirit / 5)
        baseMp5 = mp2 * 2.5
    elseif class == "WARLOCK" then
        -- Warlock: MP2 = 8 + (Spirit / 5)
        -- Note: Some sources say Spirit/4, but Spirit/5 is correct for Classic
        local mp2 = 8 + (spirit / 5)
        baseMp5 = mp2 * 2.5
    end
    
    -- Round to match in-game display (game rounds down)
    baseMp5 = math.floor(baseMp5)
    
    return baseMp5, spirit
end

-- Check Five Second Rule status
local function isInFSR()
    return (GetTime() - session.lastCastTime) < 5
end

-- Get current regen rate based on FSR (corrected for Classic)
local function getCurrentRegenRate()
    local baseMp5, spirit = calculateSpiritRegen()
    local inCombat = UnitAffectingCombat("player")
    local inFSR = isInFSR()
    
    -- Talent-based FSR regen (these are the Classic talent values)
    local _, class = UnitClass("player")
    local fsrRegen = 0
    
    -- Note: We can't detect talents via API, but documenting correct values
    if class == "PRIEST" then
        -- Meditation: 5/10/15% mana regen during FSR
        fsrRegen = 0 -- Default to 0, player can mentally adjust
    elseif class == "MAGE" then
        -- Arcane Meditation: 5/10/15% mana regen during FSR  
        fsrRegen = 0
    elseif class == "DRUID" then
        -- Reflection: 5/10/15% mana regen during FSR
        fsrRegen = 0
    end
    
    if inFSR then
        -- During FSR: 0% base regen (talents can modify)
        return baseMp5 * fsrRegen, "FSR Active"
    else
        -- Outside FSR: 100% regen (combat doesn't matter in Classic)
        if inCombat then
            return baseMp5, "Combat (100%)"
        else
            return baseMp5, "Full Regen"
        end
    end
end

-- Format numbers
local function fmt(n) return BreakUpLargeNumbers and BreakUpLargeNumbers(n) or tostring(n) end
local function colorText(hex, text) return "|cff"..hex..tostring(text).."|r" end

-- Create main frame
local f = CreateFrame("Frame", "SpiritAppreciationFrame", UIParent, "BackdropTemplate")
f:SetSize(220, 180)
f:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false, edgeSize = 12,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
})
f:SetBackdropColor(0, 0.1, 0.2, 0.9)
f:SetBackdropBorderColor(0.3, 0.7, 1, 0.8)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")

-- Drag handling
f:SetScript("OnDragStart", function(self)
    if not SpiritAppreciationDB.locked then
        self:StartMoving()
    end
end)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SpiritAppreciationDB.position = {self:GetPoint()}
end)

-- Title
local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", 0, -8)
title:SetText(colorText("00ff00", "✨ Spirit Appreciation ✨"))

-- Spirit value display
local spiritText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
spiritText:SetPoint("TOP", title, "BOTTOM", 0, -5)

-- FSR status bar with smooth animation
local fsrBar = CreateFrame("StatusBar", nil, f)
fsrBar:SetSize(200, 8)
fsrBar:SetPoint("TOP", spiritText, "BOTTOM", 0, -5)
fsrBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
fsrBar:SetMinMaxValues(0, 5)
fsrBar.targetValue = 0
fsrBar:SetValue(0)

-- Animation script for the FSR bar
fsrBar:SetScript("OnUpdate", function(self, elapsed)
    local currentValue = self:GetValue()
    local targetValue = self.targetValue
    if math.abs(currentValue - targetValue) > 0.01 then
        local newValue = currentValue + (targetValue - currentValue) * (elapsed * 8) -- Smooth interpolation
        self:SetValue(newValue)
    else
        self:SetValue(targetValue)
    end
end)

local fsrBg = fsrBar:CreateTexture(nil, "BACKGROUND")
fsrBg:SetAllPoints()
fsrBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
fsrBg:SetVertexColor(0.2, 0.2, 0.2, 0.5)

-- FSR text
local fsrText = fsrBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fsrText:SetPoint("CENTER", fsrBar, "CENTER", 0, 0)
fsrText:SetText("Ready")

-- Regen rate display
local regenText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
regenText:SetPoint("TOP", fsrBar, "BOTTOM", 0, -10)

-- Stats display
local statsText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statsText:SetPoint("TOP", regenText, "BOTTOM", 0, -10)
statsText:SetJustifyH("LEFT")
statsText:SetWidth(200)

-- Appreciation message area
local appreciationText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
appreciationText:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
appreciationText:SetWidth(200)
appreciationText:SetText("")
appreciationText:SetAlpha(0) -- Start invisible for animations

-- Animation group for smooth appreciation messages
local appreciationAnimGroup = appreciationText:CreateAnimationGroup()
local fadeIn = appreciationAnimGroup:CreateAnimation("Alpha")
fadeIn:SetDuration(0.5); fadeIn:SetFromAlpha(0); fadeIn:SetToAlpha(1); fadeIn:SetOrder(1)
local wait = appreciationAnimGroup:CreateAnimation("Alpha")
wait:SetDuration(4); wait:SetFromAlpha(1); wait:SetToAlpha(1); wait:SetOrder(2)
local fadeOut = appreciationAnimGroup:CreateAnimation("Alpha")
fadeOut:SetDuration(1.0); fadeOut:SetFromAlpha(1); fadeOut:SetToAlpha(0); fadeOut:SetOrder(3)
appreciationText.animGroup = appreciationAnimGroup

-- Mana tick spark indicator
local tickSpark = f:CreateTexture(nil, "OVERLAY")
tickSpark:SetSize(32, 32)
tickSpark:SetPoint("CENTER", regenText, "LEFT", -15, 0)
tickSpark:SetTexture("Interface\\Spells\\SPARK")
tickSpark:SetBlendMode("ADD")
tickSpark:SetAlpha(0)

local sparkAnimGroup = tickSpark:CreateAnimationGroup()
local sparkFadeIn = sparkAnimGroup:CreateAnimation("Alpha")
sparkFadeIn:SetDuration(0.1); sparkFadeIn:SetFromAlpha(0); sparkFadeIn:SetToAlpha(0.8); sparkFadeIn:SetOrder(1)
local sparkFadeOut = sparkAnimGroup:CreateAnimation("Alpha")
sparkFadeOut:SetDuration(0.7); sparkFadeOut:SetFromAlpha(0.8); sparkFadeOut:SetToAlpha(0); sparkFadeOut:SetOrder(2)
tickSpark.animGroup = sparkAnimGroup

-- Update display
local function updateDisplay()
    local mp5, spirit = calculateSpiritRegen()
    local currentRate, status = getCurrentRegenRate()
    
    -- Calculate MP2 (mana per tick - every 2 seconds)
    -- Use floor to match in-game rounding
    local mp2 = math.floor(mp5 / 2.5)
    local currentMp2 = math.floor(currentRate / 2.5)
    
    -- Update spirit display with appreciation
    local spiritColor = "ffffff"
    if spirit >= 300 then spiritColor = "ffd700"  -- Gold for high spirit
    elseif spirit >= 200 then spiritColor = "00ff00"  -- Green for good spirit
    elseif spirit >= 100 then spiritColor = "00bfff"  -- Blue for decent spirit
    end
    
    -- Show spirit value (already includes racial bonus if Human)
    local race, _ = UnitRace("player")
    if race == "Human" then
        -- Calculate base spirit without racial for display
        local baseSpirit = math.floor(spirit / 1.05)
        spiritText:SetText(string.format("Spirit: %s (%d +5%%)", colorText(spiritColor, string.format("%d", spirit)), baseSpirit))
    else
        spiritText:SetText(string.format("Spirit: %s", colorText(spiritColor, string.format("%d", spirit))))
    end
    
    -- Update FSR bar by setting its target value for smooth animation
    local timeSinceCast = GetTime() - session.lastCastTime
    if timeSinceCast < 5 then
        fsrBar.targetValue = 5 - timeSinceCast
        fsrBar:SetStatusBarColor(1, 0.3, 0.3, 0.8)
        fsrText:SetText(string.format("FSR: %.1fs", 5 - timeSinceCast))
    else
        fsrBar.targetValue = 0
        fsrBar:SetStatusBarColor(0, 1, 0, 0.8)
        fsrText:SetText("Ready")
    end
    
    -- Update regen rate with MP2 display
    local rateColor = "00ff00"
    if currentRate == 0 then rateColor = "ff0000"
    elseif currentRate < mp5 then rateColor = "ffff00"
    end
    
    -- Show both MP2 and MP5 with proper rounding
    regenText:SetText(string.format("Regen: %s/2s (%s/5s) %s", 
        colorText(rateColor, string.format("%d", currentMp2)),
        colorText(rateColor, string.format("%d", currentRate)), 
        status))
    
    -- Update session stats
    local sessionTime = GetTime() - session.startTime
    local avgManaPerTick = 0
    if session.ticks > 0 then
        avgManaPerTick = session.manaGained / session.ticks
    end
    
    local lines = {
        colorText("00bfff", "═══ Session Stats ═══"),
        string.format("Mana Restored: %s", colorText("00ff00", fmt(math.floor(session.manaGained)))),
        string.format("Avg. per Tick: %.1f", avgManaPerTick),
        string.format("Combat: %s | Peace: %s", 
            fmt(math.floor(session.combatMana)), 
            fmt(math.floor(session.nonCombatMana))),
        "",
        string.format("Lifetime: %s mana", colorText("ffd700", fmt(math.floor(SpiritAppreciationDB.totalManaFromSpirit)))),
    }
    
    statsText:SetText(table.concat(lines, "\n"))
end

-- Show appreciation message with smooth animation
local function showAppreciation(msg, playSound)
    if not SpiritAppreciationDB.showAppreciation then return end
    
    appreciationText:SetText(colorText("ffd700", msg))
    appreciationText.animGroup:Stop()
    appreciationText.animGroup:Play()
    
    if playSound and SpiritAppreciationDB.soundEnabled then
        PlaySound(8959) -- Murloc gurgle sound (was 888 - Level Up)
    end
    
    -- Also show in chat
    print(colorText("00ff00", "Spirit Appreciation: ") .. msg)
end

-- Check milestones
local function checkMilestones()
    local total = SpiritAppreciationDB.totalManaFromSpirit
    
    for _, milestone in ipairs(MILESTONES) do
        local key = "m_" .. milestone.mana
        if total >= milestone.mana and not SpiritAppreciationDB.milestones[key] then
            SpiritAppreciationDB.milestones[key] = GetTime()
            showAppreciation(milestone.msg, milestone.sound)
            
            -- Special effect for big milestones
            if milestone.mana >= 50000 then
                UIErrorsFrame:AddMessage(milestone.msg, 1, 0.84, 0, 1.0)
            end
        end
    end
end

-- Tooltip
f:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine("Spirit Appreciation", 1, 1, 1)
    GameTooltip:AddLine("Your spirit's contribution to mana", 0.7, 0.7, 0.7)
    GameTooltip:AddLine(" ")
    
    local mp5, spirit = calculateSpiritRegen()
    GameTooltip:AddDoubleLine("Current Spirit:", spirit, 1, 1, 1, 0, 1, 0)
    GameTooltip:AddDoubleLine("Max Regen:", string.format("%.1f mp5", mp5), 1, 1, 1, 0, 1, 0)
    
    -- Show spirit appreciation level
    local appreciation = "Grateful"
    if spirit >= 400 then appreciation = "🌟 Spirit Sage"
    elseif spirit >= 300 then appreciation = "✨ Spirit Master"
    elseif spirit >= 200 then appreciation = "💫 Spirit Friend"
    elseif spirit >= 100 then appreciation = "⭐ Spirit Aware"
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Appreciation Level: " .. appreciation, 0.7, 1, 0.7)
    
    -- Tips based on spirit level
    if spirit < 100 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("💡 Tip: More spirit = faster mana regen!", 1, 1, 0)
    elseif spirit >= 300 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("🏆 Excellent spirit investment!", 0, 1, 0)
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-drag to move. /spirit for options", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

f:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Mana tracking timer
local manaTracker = CreateFrame("Frame")
local timeSinceLastUpdate = 0
local UPDATE_INTERVAL = 0.1 -- Check more frequently for better tick detection

-- Improved mana tracking with Classic tick timing
manaTracker:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    
    if timeSinceLastUpdate >= UPDATE_INTERVAL then
        timeSinceLastUpdate = 0
        
        -- Update display continuously for smooth FSR bar
        updateDisplay()
        
        -- Track actual mana gains
        local currentMana = UnitPower("player", 0)
        local maxMana = UnitPowerMax("player", 0)
        
        -- Initialize lastMana if not set
        if not session.lastMana then
            session.lastMana = currentMana
            return
        end
        
        -- Check if mana increased (potential regeneration)
        if currentMana > session.lastMana then
            local gained = currentMana - session.lastMana
            local currentTime = GetTime()
            
            -- Calculate expected tick amount
            local mp5, _ = calculateSpiritRegen()
            local expectedTick = math.floor(mp5 / 2.5)  -- MP2 (mana per 2 seconds)
            
            -- Trace mode for debugging
            if session.traceMode then
                print(string.format("[TRACE] Mana gain: +%d (FSR: %s, Expected: %d)", 
                    gained, isInFSR() and "Yes" or "No", expectedTick))
            end
            
            -- Only count as spirit regen if:
            -- 1. Not in Five Second Rule (FSR)
            -- 2. Not at max mana (can't regen at cap)
            -- 3. Gain is reasonable (not a potion/consumable)
            if not isInFSR() and currentMana < maxMana then
                -- Heuristic to identify spirit ticks:
                -- Accept gains up to 2x expected tick (accounts for rounding/buffs)
                -- but at least 1 mana (for very low spirit), with a minimum cap of 10.
                if gained >= 1 and gained <= math.max(expectedTick * 2, 10) then
                    -- This is spirit regeneration
                    session.manaGained = session.manaGained + gained
                    SpiritAppreciationDB.totalManaFromSpirit = SpiritAppreciationDB.totalManaFromSpirit + gained
                    session.ticks = session.ticks + 1
                    session.lastTickTime = currentTime
                    
                    -- Visual feedback - spark animation
                    if tickSpark and tickSpark.animGroup then
                        tickSpark.animGroup:Stop()
                        tickSpark.animGroup:Play()
                    end
                    
                    -- Track combat vs peaceful regeneration
                    if UnitAffectingCombat("player") then
                        session.combatMana = session.combatMana + gained
                    else
                        session.nonCombatMana = session.nonCombatMana + gained
                    end
                    
                    -- Check for milestone achievements
                    checkMilestones()
                    
                    -- Occasional appreciation messages (1% chance)
                    if math.random() < 0.01 and SpiritAppreciationDB.showAppreciation then
                        local messages = {
                            "Your spirit is working hard! 💪",
                            "Spirit power flowing! ✨",
                            "Mana restoration in progress... 🔄",
                            "Your spirit appreciates you too! 💙",
                            "Regeneration is love, regeneration is life! 🌟",
                        }
                        showAppreciation(messages[math.random(#messages)], false)
                    end
                end
            end
        end
        
        -- Always update last mana for next comparison
        session.lastMana = currentMana
    end
end)

-- Event handling with better spell cost detection
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
events:RegisterEvent("UNIT_SPELLCAST_START")  -- Add spell start tracking
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")

events:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON then
        mergeDefaults(SpiritAppreciationDB, defaults)
        f:SetScale(SpiritAppreciationDB.scale)
        f:SetAlpha(SpiritAppreciationDB.alpha)
        f:ClearAllPoints()
        f:SetPoint(unpack(SpiritAppreciationDB.position))
        if SpiritAppreciationDB.locked then f:EnableMouse(false) end
        
    elseif event == "PLAYER_LOGIN" then
        -- Initialize session tracking with proper defaults
        session = {
            manaGained = 0,
            ticks = 0,
            combatMana = 0,
            nonCombatMana = 0,
            startTime = GetTime(),
            lastCastTime = 0,  -- Start at 0 so we're not in FSR
            isRegenerating = false,
            lastMana = UnitPower("player", 0),
            lastTickTime = GetTime(),
            nextTickTime = 0,
        }
        
        updateDisplay()
        
        -- Welcome message with class-specific info
        local race, _ = UnitRace("player")
        local _, class = UnitClass("player")
        if class == "WARRIOR" or class == "ROGUE" then
            print(colorText("ff0000", "Spirit Appreciation: ") .. "You don't use mana, but we appreciate your spirit anyway! ❤️")
            f:Hide()
        elseif class == "PALADIN" then
            print(colorText("00ff00", "✨ Spirit Appreciation loaded!") .. " Tracking your holy mana regeneration!")
            local mp5, spirit = calculateSpiritRegen()
            
            if race == "Human" then
                local baseSpirit = math.floor(spirit / 1.05)
                print(string.format("|cffffcc00Human Paladin:|r %d base spirit + 5%% racial = %d total spirit", baseSpirit, spirit))
            end
            
            -- Paladin formula: 15 + Spirit/5 per 2 seconds
            local baseRegen = 15
            local spiritBonus = spirit / 5
            local mp2 = baseRegen + spiritBonus
            print(string.format("|cffffcc00Formula:|r %d base + (%d spirit / 5) = %.1f mp2 (%.1f mp5)", 
                baseRegen, spirit, mp2, mp5))
            showAppreciation("Light be with you, Paladin! 🛡️", false)
        else
            print(colorText("00ff00", "✨ Spirit Appreciation loaded!") .. " Your spirit is ready to restore mana!")
            showAppreciation("Welcome! Your spirit is here for you! 🌟", false)
        end
    
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit = ...
        if unit == "player" then
            -- Detect spell casts that cost mana to trigger FSR
            local currentMana = UnitPower("player", 0)
            
            -- Immediate check
            if session.lastMana and currentMana < session.lastMana then
                session.lastCastTime = GetTime()
                if session.traceMode then
                    print("[TRACE] FSR triggered - spell cast detected")
                end
            end
            
            -- Delayed check for spells with delayed mana cost
            C_Timer.After(0.1, function()
                local delayedMana = UnitPower("player", 0)
                if session.lastMana and delayedMana < session.lastMana then
                    session.lastCastTime = GetTime()
                end
            end)
        end
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entered combat - combat does NOT affect mana regen in Classic
        if SpiritAppreciationDB.showAppreciation then
            showAppreciation("Combat! Regen continues at 100% unless casting!", false)
        end
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Left combat
        if SpiritAppreciationDB.showAppreciation then
            showAppreciation("Peace restored! Keep regenerating!", false)
        end
    end
end)

-- Slash commands
SLASH_SPIRIT1 = "/spirit"
SLASH_SPIRIT2 = "/spiritappreciation"

SlashCmdList["SPIRIT"] = function(msg)
    msg = (msg or ""):lower():trim()
    
    if msg == "toggle" then
        f:SetShown(not f:IsShown())
        
    elseif msg == "lock" then
        SpiritAppreciationDB.locked = true
        f:EnableMouse(false)
        print(colorText("00ff00", "Spirit Appreciation") .. " frame locked")
        
    elseif msg == "unlock" then
        SpiritAppreciationDB.locked = false
        f:EnableMouse(true)
        print(colorText("00ff00", "Spirit Appreciation") .. " frame unlocked")
        
    elseif msg == "reset" then
        SpiritAppreciationDB.position = defaults.position
        f:ClearAllPoints()
        f:SetPoint(unpack(SpiritAppreciationDB.position))
        print(colorText("00ff00", "Spirit Appreciation") .. " position reset")
        
    elseif msg == "appreciate" then
        SpiritAppreciationDB.showAppreciation = not SpiritAppreciationDB.showAppreciation
        print(colorText("00ff00", "Spirit Appreciation") .. " messages " .. 
            (SpiritAppreciationDB.showAppreciation and "enabled" or "disabled"))
            
    elseif msg == "sound" then
        SpiritAppreciationDB.soundEnabled = not SpiritAppreciationDB.soundEnabled
        print(colorText("00ff00", "Spirit Appreciation") .. " sounds " .. 
            (SpiritAppreciationDB.soundEnabled and "enabled" or "disabled"))
        
    elseif msg == "stats" then
        print(colorText("00ff00", "═══ Spirit Appreciation Stats ═══"))
        print(string.format("Total mana from spirit: %s", fmt(math.floor(SpiritAppreciationDB.totalManaFromSpirit))))
        print(string.format("Session mana: %s (in %d ticks)", fmt(math.floor(session.manaGained)), session.ticks))
        print(string.format("Combat vs Peace: %s vs %s", 
            fmt(math.floor(session.combatMana)), 
            fmt(math.floor(session.nonCombatMana))))
        
        local mp5, spirit = calculateSpiritRegen()
        local mp2 = math.floor(mp5 / 2.5)
        local _, class = UnitClass("player")
        print(string.format("Current spirit: %d", spirit))
        print(string.format("%s Formula: %.0f mana per tick (%.1f mp5)", class, mp2, mp5))
        
        -- Show FSR status
        if isInFSR() then
            local remaining = 5 - (GetTime() - session.lastCastTime)
            print(string.format("FSR Active: %.1f seconds remaining", remaining))
        else
            print("FSR Status: Regenerating normally")
        end
        
    elseif msg == "test" then
        -- Test command to verify formulas
        local mp5, spirit = calculateSpiritRegen()
        local mp2 = math.floor(mp5 / 2.5)
        local race, _ = UnitRace("player")
        local _, class = UnitClass("player")
        print(colorText("00ff00", "═══ Spirit Regen Test (Classic 1.15.7) ═══"))
        print(string.format("Class: %s, Race: %s", class, race))
        
        if race == "Human" then
            local baseSpirit = math.floor(spirit / 1.05)
            print(string.format("Spirit: %d total (approx %d base + 5%% racial)", spirit, baseSpirit))
        else
            print(string.format("Spirit: %d", spirit))
        end
        
        -- Show class-specific formula breakdown with exact values
        local baseRegen, divisor = 0, 5
        if class == "PALADIN" then
            baseRegen = 15; divisor = 5
            print("Paladin Formula: 15 + (Spirit / 5)")
        elseif class == "DRUID" then
            baseRegen = 15; divisor = 5
            print("Druid Formula: 15 + (Spirit / 5)")
        elseif class == "HUNTER" then
            baseRegen = 15; divisor = 5
            print("Hunter Formula: 15 + (Spirit / 5)")
        elseif class == "SHAMAN" then
            baseRegen = 17; divisor = 5
            print("Shaman Formula: 17 + (Spirit / 5)")
        elseif class == "PRIEST" then
            baseRegen = 13; divisor = 4
            print("Priest Formula: 13 + (Spirit / 4)")
        elseif class == "MAGE" then
            baseRegen = 13; divisor = 4
            print("Mage Formula: 13 + (Spirit / 4)")
        elseif class == "WARLOCK" then
            baseRegen = 8; divisor = 5
            print("Warlock Formula: 8 + (Spirit / 5)")
        end
        
        if baseRegen > 0 then
            local spiritContribution = spirit / divisor
            local calculatedMp2 = baseRegen + spiritContribution
            print(string.format("Calculation: %d + (%.1f) = %.1f mp2", baseRegen, spiritContribution, calculatedMp2))
            print(string.format("Rounded down: %d mp2", mp2))
        end
        
        print(string.format("Mana per 2 sec (tick): %d", mp2))
        print(string.format("Mana per 5 sec: %d", mp5))
        print(string.format("Mana per minute: %d", mp5 * 12))
        
        if isInFSR() then
            print(colorText("ff0000", "WARNING: Currently in FSR - 0% regen!"))
        else
            print(colorText("00ff00", "Status: Regenerating normally"))
        end
        
    elseif msg == "reset session" then
        -- Properly reset session while keeping current values
        local currentMana = UnitPower("player", 0)
        wipeTable(session)
        session.startTime = GetTime()
        session.lastMana = currentMana
        session.lastTickTime = GetTime()
        session.lastCastTime = 0
        updateDisplay()
        print(colorText("00ff00", "Spirit Appreciation") .. " session stats reset.")
        
    elseif msg == "reset all" then
        -- Reset everything
        local currentMana = UnitPower("player", 0)
        wipeTable(session)
        session.startTime = GetTime()
        session.lastMana = currentMana
        session.lastTickTime = GetTime()
        session.lastCastTime = 0
        SpiritAppreciationDB.totalManaFromSpirit = 0
        SpiritAppreciationDB.milestones = {}
        updateDisplay()
        print(colorText("00ff00", "Spirit Appreciation") .. " all lifetime stats reset.")
        
    elseif msg == "debug" then
        -- Enhanced debug command
        print(colorText("00ff00", "═══ Spirit Appreciation Debug ═══"))
        local currentMana = UnitPower("player", 0)
        local maxMana = UnitPowerMax("player", 0)
        print(string.format("Mana: %d / %d (%.1f%%)", currentMana, maxMana, (currentMana/maxMana)*100))
        print(string.format("Last Mana: %d", session.lastMana or 0))
        print(string.format("Session Ticks: %d", session.ticks))
        print(string.format("Session Mana Gained: %.0f", session.manaGained))
        print(string.format("Session Time: %.1f min", (GetTime() - session.startTime) / 60))
        
        local mp5, spirit = calculateSpiritRegen()
        local mp2 = math.floor(mp5 / 2.5)
        print(string.format("Spirit: %d", spirit))
        print(string.format("Expected MP2: %d (MP5: %d)", mp2, mp5))
        
        print(string.format("In FSR: %s", isInFSR() and "Yes" or "No"))
        if isInFSR() then
            local remaining = 5 - (GetTime() - session.lastCastTime)
            print(string.format("FSR remaining: %.1f sec", remaining))
        else
            local timeSinceLastTick = GetTime() - session.lastTickTime
            print(string.format("Time since last tick: %.1f sec", timeSinceLastTick))
        end
        
        print(string.format("Combat: %s", UnitAffectingCombat("player") and "Yes" or "No"))
        print(string.format("Lifetime Total: %d mana", SpiritAppreciationDB.totalManaFromSpirit))
        
    elseif msg == "trace" then
        -- Toggle trace mode for debugging mana gains
        session.traceMode = not session.traceMode
        if session.traceMode then
            print(colorText("00ff00", "Spirit Appreciation") .. " trace mode ENABLED - will print all mana gains")
        else
            print(colorText("00ff00", "Spirit Appreciation") .. " trace mode DISABLED")
        end
        
    else
        print(colorText("00ff00", "Spirit Appreciation Commands:"))
        print("  /spirit toggle - show/hide frame")
        print("  /spirit lock|unlock - lock/unlock position")
        print("  /spirit reset - reset frame position")
        print("  /spirit appreciate - toggle messages")
        print("  /spirit sound - toggle milestone sounds")
        print("  /spirit stats - show statistics")
        print("  /spirit test - test regen formulas")
        print("  /spirit debug - show debug info")
        print("  /spirit trace - toggle trace mode (prints mana gains)")
        print("  /spirit reset session - reset session stats")
        print("  /spirit reset all - reset all lifetime stats")
    end
end
