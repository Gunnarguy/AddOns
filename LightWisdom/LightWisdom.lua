local ADDON_NAME, ns = ...

--[[
Light & Wisdom Stats (Judgements Only) - Gamified Edition
Tracks Judgement of Light healing and Judgement of Wisdom mana for group members.
Now with achievements, visual feedback, and contribution scoring!
]]

--=============================
-- SavedVariables / Defaults
--=============================
local function applyDefaults(defaults, data)
    data = data or {}
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            data[k] = applyDefaults(v, data[k])
        elseif data[k] == nil then
            data[k] = v
        end
    end
    return data
end

local defaults = {
    allTime  = { healing = 0, mana = 0 },
    session  = { healing = 0, mana = 0, startTime = GetTime() },
    combat   = { healing = 0, mana = 0, startTime = 0, inCombat = false },
    statusDebuffs = { light = false, wisdom = false },
    position = { "CENTER", nil, "CENTER", 0, 0 },
    scale    = 1.0,
    locked   = false,
    alpha    = 0.8,  -- New: transparency setting
    fadeAlpha = 0.5, -- New: faded alpha when not hovering  
    fadeEnabled = false, -- New: enable fade on mouse leave
    minimapPos = 45,
    -- New gamification features
    achievements = {},
    personalBests = {
        bestHPS = 0,
        bestMPS = 0,
        bestCombatHealing = 0,
        bestCombatMana = 0,
        longestUptime = 0,
    },
    raidContribution = {}, -- Track per-player benefits
    streaks = {
        currentUptime = 0,
        uptimeStart = 0,
    },
    settings = {
        soundEnabled = true,
        showAchievements = true,
        debugMode = false, -- New: Debug mode for combat log inspection
    }
}

LWS_DB = applyDefaults(defaults, LWS_DB)
ns = ns or {}
ns.db = LWS_DB

--=============================
-- Gamification Constants
--=============================
-- Performance grades based on HPS/MPS
local PERFORMANCE_GRADES = {
    {threshold = 150, grade = "S", color = "FFD700", desc = "Divine Support!"},   -- Gold
    {threshold = 100, grade = "A", color = "00FF00", desc = "Excellent!"},        -- Green
    {threshold = 50,  grade = "B", color = "00BFFF", desc = "Good"},             -- Light Blue
    {threshold = 25,  grade = "C", color = "FFFF00", desc = "Average"},          -- Yellow
    {threshold = 0,   grade = "D", color = "FF6B6B", desc = "Keep trying"},      -- Red
}

-- Achievement milestones
local ACHIEVEMENTS = {
    {healing = 10000,  name = "Light Bearer",       icon = "✦", desc = "10k healing from JoL"},
    {healing = 50000,  name = "Radiant Guardian",   icon = "★", desc = "50k healing from JoL"},
    {healing = 100000, name = "Champion of Light",  icon = "☀", desc = "100k healing from JoL"},
    {mana = 5000,      name = "Wisdom Seeker",      icon = "♦", desc = "5k mana from JoW"},
    {mana = 25000,     name = "Sage",               icon = "✧", desc = "25k mana from JoW"},
    {mana = 50000,     name = "Oracle of Wisdom",   icon = "⚡", desc = "50k mana from JoW"},
}

--=============================
-- Utility helpers
--=============================
function ns.FormatNumber(number)
    if not number then return "0" end
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    end
    return tostring(math.floor(number))
end

local function ColorBool(state)
    return state and "|cff00ff00Yes|r" or "|cffff0000No|r"
end

local function colorText(hex, text) 
    return "|cff"..hex..tostring(text).."|r" 
end

-- Calculate resource equivalents
local function getHealthPotEquivalent(healing)
    local MAJOR_HEALING_POT = 1700 -- Average Major Healing Potion
    return math.floor((healing or 0) / MAJOR_HEALING_POT)
end

local function getManaPotEquivalent(mana)
    local MAJOR_MANA_POT = 1800 -- Average Major Mana Potion
    return math.floor((mana or 0) / MAJOR_MANA_POT)
end

-- Get performance grade
local function getPerformanceGrade(value)
    for _, grade in ipairs(PERFORMANCE_GRADES) do
        if value >= grade.threshold then
            return grade
        end
    end
    return PERFORMANCE_GRADES[#PERFORMANCE_GRADES]
end

-- Calculate contribution score (0-100)
local function getContributionScore()
    local score = 0
    local combat = ns.db.combat
    
    -- Base score from HPS/MPS
    if combat.inCombat then
        local duration = math.max(1, GetTime() - combat.startTime)
        local hps = (combat.healing or 0) / duration
        local mps = (combat.mana or 0) / duration
        score = math.min(100, (hps + mps * 2) / 3) -- Weight mana higher as it's rarer
    end
    
    -- Bonus for having both judgements up
    if ns.db.statusDebuffs.light and ns.db.statusDebuffs.wisdom then
        score = math.min(100, score * 1.2)
    end
    
    return score
end

-- Check achievements
local function checkAchievements()
    local session = ns.db.session
    local achievements = ns.db.achievements
    
    for _, achievement in ipairs(ACHIEVEMENTS) do
        local key = achievement.name:gsub(" ", "_")
        local checkValue = achievement.healing or achievement.mana
        local currentValue = achievement.healing and session.healing or session.mana
        
        if currentValue >= checkValue and not achievements[key] then
            achievements[key] = GetTime()
            
            if ns.db.settings.showAchievements then
                UIErrorsFrame:AddMessage(achievement.icon .. " Achievement: " .. achievement.name .. "!", 1, 0.84, 0, 1.0)
                if ns.db.settings.soundEnabled then
                    PlaySound(888) -- Level up sound
                end
            end
        end
    end
    
    -- Update personal bests
    local pb = ns.db.personalBests
    if ns.db.combat.inCombat then
        local duration = GetTime() - ns.db.combat.startTime
        if duration > 0 then
            local hps = ns.db.combat.healing / duration
            local mps = ns.db.combat.mana / duration
            
            if hps > pb.bestHPS then
                pb.bestHPS = hps
                if hps > 50 then -- Only announce significant records
                    print("|cFF00FF96L&W:|r New HPS record: " .. string.format("%.1f", hps))
                end
            end
            
            if mps > pb.bestMPS then
                pb.bestMPS = mps
                if mps > 25 then
                    print("|cFF00FF96L&W:|r New MPS record: " .. string.format("%.1f", mps))
                end
            end
        end
    end
end

--=============================
-- Forward declarations for functions used in UI
--=============================
local UpdateDisplay, ResetCombat, UpdateRates

--=============================
-- Core frame & state
--=============================
local root = CreateFrame("Frame", "LWS_RootFrame", UIParent, "BackdropTemplate")
ns.root = root
root:SetScale(ns.db.scale)
root:SetAlpha(ns.db.alpha or 0.8)  -- Apply saved alpha
root:SetMovable(true)
root:EnableMouse(not ns.db.locked)  -- Disable mouse when locked
root:SetClampedToScreen(true)
root:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile=false, edgeSize=12,
    insets={left=4,right=4,top=4,bottom=4}
})
root:SetBackdropColor(0,0,0,0.80)

do
    local pos = ns.db.position
    if pos and #pos >= 5 then
        root:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
    else
        root:SetPoint("CENTER")
        ns.db.position = { "CENTER", nil, "CENTER", 0, 0 }
    end
end

root:RegisterForDrag("LeftButton")
root:SetScript("OnDragStart", function(self)
    if not ns.db.locked then 
        self:StartMoving()
        self:SetAlpha(1.0) -- Full opacity while dragging
    end
end)
root:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    ns.db.position = { self:GetPoint(1) }
    self:SetAlpha(ns.db.alpha) -- Restore alpha
end)

-- Enhanced right-click menu with dropdown
root:SetScript("OnMouseUp", function(self, btn)
    if btn == "RightButton" and not ns.db.locked then
        -- Create dropdown menu if it doesn't exist
        if not LWS_DropDown then
            CreateFrame("Frame", "LWS_DropDown", UIParent, "UIDropDownMenuTemplate")
        end
        
        UIDropDownMenu_Initialize(LWS_DropDown, function(menu, level)
            local info = UIDropDownMenu_CreateInfo()
            info.notCheckable = true
            
            if level == 1 then
                info.text = "Light & Wisdom"; info.isTitle = true
                UIDropDownMenu_AddButton(info, level)
                info.isTitle = false
                
                info.text = ns.db.locked and "Unlock Window" or "Lock Window"
                info.func = function()
                    ns.db.locked = not ns.db.locked
                    root:EnableMouse(not ns.db.locked)
                    print("|cFF00FF96L&W:|r Frame " .. (ns.db.locked and "locked (click-through)" or "unlocked"))
                    if UpdateDisplay then UpdateDisplay() end  -- Check if function exists
                end
                UIDropDownMenu_AddButton(info, level)
                
                info.text = "Transparency"
                info.hasArrow = true
                info.menuList = "transparency"
                UIDropDownMenu_AddButton(info, level)
                
                info.text = ns.db.fadeEnabled and "Disable Fade" or "Enable Fade"
                info.hasArrow = false
                info.menuList = nil
                info.func = function()
                    ns.db.fadeEnabled = not ns.db.fadeEnabled
                    if UpdateDisplay then UpdateDisplay() end  -- Check if function exists
                end
                UIDropDownMenu_AddButton(info, level)
                
                info.text = "Reset Combat"
                info.func = function()
                    if ResetCombat then ResetCombat() end  -- Check if function exists
                    if UpdateDisplay then UpdateDisplay() end
                    print("|cFF00FF96L&W:|r Combat stats reset.")
                end
                UIDropDownMenu_AddButton(info, level)
                
            elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "transparency" then
                info.text = "Transparency"; info.isTitle = true
                UIDropDownMenu_AddButton(info, level)
                info.isTitle = false
                
                local alphaValues = {1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3}
                for _, alpha in ipairs(alphaValues) do
                    info.text = string.format("%d%%", alpha * 100)
                    info.func = function()
                        ns.db.alpha = alpha
                        root:SetAlpha(alpha)
                        print(string.format("|cFF00FF96L&W:|r Transparency set to %d%%", alpha * 100))
                    end
                    if math.abs((ns.db.alpha or 0.8) - alpha) < 0.01 then  -- Float comparison fix
                        info.text = info.text .. " |cFF00FF00✓|r"
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end)
        
        ToggleDropDownMenu(1, nil, LWS_DropDown, self, 0, 0)
    end
end)

local title = root:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", 0, -6)
title:SetText("|cFF00FF96Light & Wisdom|r")
root.title = title

-- Add contribution score bar
local scoreBar = CreateFrame("StatusBar", nil, root)
scoreBar:SetSize(280, 10)
scoreBar:SetPoint("TOP", title, "BOTTOM", 0, -4)
scoreBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
scoreBar:SetMinMaxValues(0, 100)
scoreBar:SetValue(0)
scoreBar:SetStatusBarColor(0, 0.7, 1, 0.8)

local scoreBg = scoreBar:CreateTexture(nil, "BACKGROUND")
scoreBg:SetAllPoints()
scoreBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
scoreBg:SetVertexColor(0.2, 0.2, 0.2, 0.5)

root.scoreBar = scoreBar

-- Enhanced tooltip
root:SetScript("OnEnter", function(self)
    -- Update alpha when hovering
    if ns.db.fadeEnabled then
        self:SetAlpha(ns.db.alpha)
    end
    
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    
    if ns.db.locked then
        GameTooltip:AddLine("Light & Wisdom Stats [LOCKED]", 1, 0.5, 0.5)
        GameTooltip:AddLine("Type /lw unlock to enable interaction", 0.7, 0.7, 0.7)
    else
        GameTooltip:AddLine("Light & Wisdom Stats",1,1,1)
        GameTooltip:AddLine("Judgement Support Tracker", 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        
        -- Show contribution score
        local score = getContributionScore()
        GameTooltip:AddLine("Contribution Score: " .. string.format("%.0f/100", score), 0, 0.7, 1)
        
        -- Show achievement progress
        local achieved = 0
        for _, ach in ipairs(ACHIEVEMENTS) do
            if ns.db.achievements[ach.name:gsub(" ", "_")] then
                achieved = achieved + 1
            end
        end
        GameTooltip:AddLine(string.format("Achievements: %d/%d", achieved, #ACHIEVEMENTS), 1, 0.84, 0)
        
        -- Show personal bests
        local pb = ns.db.personalBests
        if pb.bestHPS > 0 or pb.bestMPS > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Personal Bests:", 1, 1, 0)
            if pb.bestHPS > 0 then
                GameTooltip:AddLine(string.format("  Best HPS: %.1f", pb.bestHPS), 0.7, 1, 0.7)
            end
            if pb.bestMPS > 0 then
                GameTooltip:AddLine(string.format("  Best MPS: %.1f", pb.bestMPS), 0.7, 0.7, 1)
            end
        end
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Left-drag to move. Right-click for options.", .9,.9,.9)
        GameTooltip:AddLine("/lw stats | lock | unlock | alpha <0.3-1.0> | fade", .7,.7,1)
    end
    
    GameTooltip:Show()
end)

root:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    -- Apply fade when leaving
    if ns.db.fadeEnabled and ns.db.locked then
        self:SetAlpha(ns.db.fadeAlpha)
    end
end)

-- Column headers
local colX = { 110, 190, 270 }
local headers = { "Now", "Session", "All-Time" }
for i, h in ipairs(headers) do
    local fs = root:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("TOPLEFT", colX[i], -30) -- Adjusted for score bar
    fs:SetText(h)
end

-- Enhanced row definitions
local rows = {
    { key="healing", label="JoL Healing" },
    { key="mana",    label="JoW Mana" },
    { key="hps",     label="HPS" },
    { key="mps",     label="MPS" },
    { key="grade",   label="Performance" },    -- New: performance grade
    { key="pots",    label="Resources Saved" }, -- New: pot equivalents
    { key="jol",     label="JoL Active" },
    { key="jow",     label="JoW Active" },
    { key="uptime",  label="Uptime" },         -- New: judgement uptime
}

local cells = {}
local y = -46 -- Adjusted for score bar
for _, r in ipairs(rows) do
    local label = root:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", 10, y)
    label:SetText(r.label)
    local nowFS = root:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nowFS:SetPoint("TOPLEFT", colX[1], y)
    nowFS:SetText("0")
    local sessFS = root:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sessFS:SetPoint("TOPLEFT", colX[2], y)
    sessFS:SetText("0")
    local allFS = root:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    allFS:SetPoint("TOPLEFT", colX[3], y)
    allFS:SetText("0")
    cells[r.key] = { now=nowFS, session=sessFS, all=allFS }
    y = y - 16
end
-- Resize frame for new rows
root:SetSize(330, -y + 20)
root.cells = cells

--=============================
-- Minimap button (optional)
--=============================
local minimapButton
local function UpdateMinimapButtonPosition()
    if not minimapButton or not Minimap then return end
    local angle = (ns.db.minimapPos or 45) * math.pi / 180
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
    if not Minimap then return end
    minimapButton = CreateFrame("Button", "LWS_MinimapButton", Minimap)
    minimapButton:SetSize(31, 31)
    minimapButton:SetFrameLevel(8)
    minimapButton:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(btn)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            local angle = math.deg(math.atan2(py - my, px - mx))
            ns.db.minimapPos = angle
            UpdateMinimapButtonPosition()
        end)
    end)
    minimapButton:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    minimapButton:SetScript("OnClick", function()
        if root:IsShown() then root:Hide() else root:Show() end
    end)
    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface/Icons/Spell_Holy_SealOfWisdom")
    icon:SetSize(19, 19)
    icon:SetPoint("CENTER")
    UpdateMinimapButtonPosition()
end

--=============================
-- Enhanced display updates
--=============================
local lastRateTime, lastHealing, lastMana = 0,0,0
local currentHPS, currentMPS = 0, 0

-- Define UpdateDisplay function
UpdateDisplay = function()
    -- Ensure alpha is applied based on fade settings
    if ns.db.locked and ns.db.fadeEnabled and not root:IsMouseOver() then
        root:SetAlpha(ns.db.fadeAlpha)
    else
        root:SetAlpha(ns.db.alpha or 0.8)
    end
    
    local nowHealing, nowMana = ns.db.combat.healing, ns.db.combat.mana
    local sessHealing, sessMana = ns.db.session.healing, ns.db.session.mana
    local allHealing, allMana = ns.db.allTime.healing, ns.db.allTime.mana

    root.cells.healing.now:SetText(ns.FormatNumber(nowHealing))
    root.cells.healing.session:SetText(ns.FormatNumber(sessHealing))
    root.cells.healing.all:SetText(ns.FormatNumber(allHealing))

    root.cells.mana.now:SetText(ns.FormatNumber(nowMana))
    root.cells.mana.session:SetText(ns.FormatNumber(sessMana))
    root.cells.mana.all:SetText(ns.FormatNumber(allMana))

    root.cells.jol.now:SetText(ColorBool(ns.db.statusDebuffs.light))
    root.cells.jow.now:SetText(ColorBool(ns.db.statusDebuffs.wisdom))
    root.cells.jol.session:SetText("-")
    root.cells.jol.all:SetText("-")
    root.cells.jow.session:SetText("-")
    root.cells.jow.all:SetText("-")
    
    -- Update performance grades
    local combinedRate = currentHPS + currentMPS * 1.5 -- Weight mana higher
    local grade = getPerformanceGrade(combinedRate)
    root.cells.grade.now:SetText(colorText(grade.color, grade.grade .. " (" .. string.format("%.0f", combinedRate) .. ")"))
    root.cells.grade.session:SetText("-")
    root.cells.grade.all:SetText("-")
    
    -- Update resource saved (pot equivalents)
    local healPots = getHealthPotEquivalent(nowHealing)
    local manaPots = getManaPotEquivalent(nowMana)
    root.cells.pots.now:SetText(colorText("00BFFF", healPots .. "H/" .. manaPots .. "M"))
    
    local sessHealPots = getHealthPotEquivalent(sessHealing)
    local sessManaPots = getManaPotEquivalent(sessMana)
    root.cells.pots.session:SetText(colorText("00BFFF", sessHealPots .. "H/" .. sessManaPots .. "M"))
    
    local allHealPots = getHealthPotEquivalent(allHealing)
    local allManaPots = getManaPotEquivalent(allMana)
    root.cells.pots.all:SetText(colorText("00BFFF", allHealPots .. "H/" .. allManaPots .. "M"))
    
    -- Update uptime tracking
    if ns.db.statusDebuffs.light or ns.db.statusDebuffs.wisdom then
        if ns.db.streaks.uptimeStart == 0 then
            ns.db.streaks.uptimeStart = GetTime()
        end
        ns.db.streaks.currentUptime = GetTime() - ns.db.streaks.uptimeStart
        
        local uptimeStr = string.format("%.0fs", ns.db.streaks.currentUptime)
        root.cells.uptime.now:SetText(colorText("00FF00", uptimeStr))
        
        -- Update personal best uptime
        if ns.db.streaks.currentUptime > ns.db.personalBests.longestUptime then
            ns.db.personalBests.longestUptime = ns.db.streaks.currentUptime
        end
    else
        ns.db.streaks.uptimeStart = 0
        ns.db.streaks.currentUptime = 0
        root.cells.uptime.now:SetText(colorText("FF6B6B", "0s"))
    end
    root.cells.uptime.session:SetText("-")
    root.cells.uptime.all:SetText("-")
    
    -- Update contribution score bar
    local score = getContributionScore()
    root.scoreBar:SetValue(score)
    
    -- Color bar based on performance
    local r, g, b = 1, 0, 0
    if grade.grade == "S" then r, g, b = 1, 0.84, 0
    elseif grade.grade == "A" then r, g, b = 0, 1, 0
    elseif grade.grade == "B" then r, g, b = 0, 0.75, 1
    elseif grade.grade == "C" then r, g, b = 1, 1, 0
    end
    root.scoreBar:SetStatusBarColor(r, g, b, 0.8)
    
    -- Check for achievements
    checkAchievements()
end

UpdateRates = function()
    local now = GetTime()
    if ns.db.combat.inCombat then
        local dt = now - (lastRateTime == 0 and now or lastRateTime)
        if dt >= 1 then
            local dh = ns.db.combat.healing - lastHealing
            local dm = ns.db.combat.mana - lastMana
            currentHPS = dh / dt
            currentMPS = dm / dt
            root.cells.hps.now:SetText(string.format("%.1f", currentHPS))
            root.cells.mps.now:SetText(string.format("%.1f", currentMPS))
            lastRateTime = now
            lastHealing = ns.db.combat.healing
            lastMana = ns.db.combat.mana
        end
    else
        currentHPS, currentMPS = 0, 0
        root.cells.hps.now:SetText("0")
        root.cells.mps.now:SetText("0")
    end
    root.cells.hps.session:SetText("-")
    root.cells.hps.all:SetText("-")
    root.cells.mps.session:SetText("-")
    root.cells.mps.all:SetText("-")
end

--=============================
-- Stat mutation helpers
--=============================
local function AddStat(stat, amount)
    if not amount or amount <= 0 then return end
    ns.db.combat[stat] = (ns.db.combat[stat] or 0) + amount
    ns.db.session[stat] = (ns.db.session[stat] or 0) + amount
    ns.db.allTime[stat] = (ns.db.allTime[stat] or 0) + amount
    UpdateDisplay()
end

-- Define ResetCombat function
ResetCombat = function()
    -- Show combat summary if significant
    if ns.db.combat.healing > 100 or ns.db.combat.mana > 50 then
        local healPots = getHealthPotEquivalent(ns.db.combat.healing)
        local manaPots = getManaPotEquivalent(ns.db.combat.mana)
        local grade = getPerformanceGrade(currentHPS + currentMPS * 1.5)
        
        print(string.format("|cFF00FF96L&W Combat:|r Grade %s - Saved %d heal pots, %d mana pots!", 
            grade.grade, healPots, manaPots))
    end
    
    ns.db.combat.healing = 0
    ns.db.combat.mana = 0
    ns.db.combat.startTime = GetTime()
    ns.db.combat.inCombat = true
    lastRateTime = 0
    lastHealing, lastMana = 0, 0
    currentHPS, currentMPS = 0, 0
    UpdateDisplay()
end

--=============================
-- Party membership helper
--=============================
function ns.IsPartyMember(guid)
    if not guid then return false end
    if guid == UnitGUID("player") then return true end
    if IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local unit = (IsInRaid() and "raid"..i) or ("party"..i)
            if UnitExists(unit) and guid == UnitGUID(unit) then return true end
        end
    end
    return false
end

--=============================
-- Combat log parsing (JoL/JoW)
--=============================
local events = CreateFrame("Frame")

events:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local ts, subevent,
            _, srcGUID, srcName, _, _,
            destGUID, destName, _, _,
            spellID, spellName, _, amount, overheal, _, _, _, _, _, critical, powerType =
                CombatLogGetCurrentEventInfo()

        if subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" then
            if spellName == "Judgement of Light" and ns.IsPartyMember(destGUID) then
                local eff = (amount or 0) - (overheal or 0)
                if eff and eff > 0 then
                    AddStat("healing", eff)
                    
                    -- Track per-player contribution
                    if not ns.db.raidContribution[destName] then
                        ns.db.raidContribution[destName] = {healing = 0, mana = 0}
                    end
                    ns.db.raidContribution[destName].healing = 
                        ns.db.raidContribution[destName].healing + eff
                end
            end

        elseif subevent == "SPELL_ENERGIZE" then
            -- Enhanced JoW detection with debug info
            if ns.db.settings.debugMode and powerType == 0 and amount and amount > 0 then
                debugPrint("ENERGIZE:", spellName, "Amount:", amount, "PowerType:", powerType, "Target:", destName)
            end
            
            -- Improved JoW detection with multiple spell name variants
            if isJudgementOfWisdom(spellName) and ns.IsPartyMember(destGUID) and powerType == 0 then
                debugPrint("JoW mana gain:", amount, "by", destName, "from", spellName)
                AddStat("mana", amount or 0)
                
                -- Track per-player contribution
                if not ns.db.raidContribution[destName] then
                    ns.db.raidContribution[destName] = {healing = 0, mana = 0}
                end
                ns.db.raidContribution[destName].mana = 
                    ns.db.raidContribution[destName].mana + (amount or 0)
            end
            
        elseif subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
            if spellName == "Judgement of Light" then
                ns.db.statusDebuffs.light = true
                UpdateDisplay()
            elseif isJudgementOfWisdom(spellName) then
                ns.db.statusDebuffs.wisdom = true
                UpdateDisplay()
                
                -- Show detected spell name for debug purposes
                if ns.db.settings.debugMode then
                    debugPrint("JoW applied with name:", spellName)
                end
            end

        elseif subevent == "SPELL_AURA_REMOVED" then
            if spellName == "Judgement of Light" then
                ns.db.statusDebuffs.light = false
                UpdateDisplay()
            elseif isJudgementOfWisdom(spellName) then
                ns.db.statusDebuffs.wisdom = false
                UpdateDisplay()
            end
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        ns.db.combat.inCombat = true
        if ns.db.combat.startTime == 0 or (GetTime() - ns.db.combat.startTime) > 5 then
            ResetCombat()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.db.combat.inCombat = false
        
        -- Reset raid contribution tracking for next combat
        ns.db.raidContribution = {}
    end
end)

events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")

--=============================
-- Enhanced slash commands
--=============================
SLASH_LWS1 = "/lw"
SlashCmdList["LWS"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "reset" then
        ResetCombat(); UpdateDisplay(); print("|cFF00FF96L&W:|r Combat stats reset.")
        
    elseif msg == "stats" then
        -- Show detailed statistics
        print("|cFF00FF96Light & Wisdom Statistics|r")
        print("Session Total: " .. ns.FormatNumber(ns.db.session.healing) .. " healing, " .. 
              ns.FormatNumber(ns.db.session.mana) .. " mana")
        
        local healPots = getHealthPotEquivalent(ns.db.session.healing)
        local manaPots = getManaPotEquivalent(ns.db.session.mana)
        print("Resources Saved: " .. healPots .. " heal pots, " .. manaPots .. " mana pots")
        
        -- Show top beneficiaries
        if next(ns.db.raidContribution) then
            print("Top Beneficiaries (This Combat):")
            local sorted = {}
            for name, data in pairs(ns.db.raidContribution) do
                table.insert(sorted, {name = name, total = data.healing + data.mana * 2})
            end
            table.sort(sorted, function(a,b) return a.total > b.total end)
            for i = 1, math.min(3, #sorted) do
                print("  " .. i .. ". " .. sorted[i].name .. ": " .. ns.FormatNumber(sorted[i].total))
            end
        end
        
        -- Show achievements
        print("|cFF00FF96Achievements:|r")
        for _, ach in ipairs(ACHIEVEMENTS) do
            local key = ach.name:gsub(" ", "_")
            local status = ns.db.achievements[key] and "✓" or "✗"
            print(string.format("  %s %s %s - %s", status, ach.icon, ach.name, ach.desc))
        end
        
    elseif msg == "lock" then
        ns.db.locked = true
        root:EnableMouse(false)
        print("|cFF00FF96L&W:|r Frame locked (click-through enabled)")
        UpdateDisplay()
        
    elseif msg == "unlock" then
        ns.db.locked = false
        root:EnableMouse(true)
        print("|cFF00FF96L&W:|r Frame unlocked (interaction enabled)")
        UpdateDisplay()
        
    elseif msg:match("^alpha%s+[%d%.]+$") then
        local alpha = tonumber(msg:match("alpha%s+([%d%.]+)"))
        if alpha and alpha >= 0.3 and alpha <= 1.0 then
            ns.db.alpha = alpha
            root:SetAlpha(alpha)
            print(string.format("|cFF00FF96L&W:|r Alpha set to %.1f", alpha))
        else
            print("|cFF00FF96L&W:|r Alpha must be between 0.3 and 1.0")
        end
        
    elseif msg == "fade" then
        ns.db.fadeEnabled = not ns.db.fadeEnabled
        print("|cFF00FF96L&W:|r Fade " .. (ns.db.fadeEnabled and "enabled" or "disabled"))
        UpdateDisplay()
        
    elseif msg == "debug" then
        -- Toggle debug mode
        ns.db.settings.debugMode = not ns.db.settings.debugMode
        print("|cFF00FF96L&W:|r Debug mode " .. (ns.db.settings.debugMode and "enabled" or "disabled"))
        if ns.db.settings.debugMode then
            print("Combat log events for mana restoration will be displayed in chat.")
        end
        
    elseif msg == "hide" then
        root:Hide()
    elseif msg == "show" then
        root:Show()
    elseif msg:match("^scale%s+[%d%.]+$") then
        local num = tonumber(msg:match("scale%s+([%d%.]+)"))
        if num and num >= 0.5 and num <= 2.0 then
            ns.db.scale = num
            root:SetScale(num)
            print("|cFF00FF96L&W:|r Scale set to " .. num)
        else
            print("|cFF00FF96L&W:|r Scale must be between 0.5 and 2.0")
        end
    else
        print("|cFF00FF96Light & Wisdom Stats Help:|r")
        print("/lw stats - show detailed statistics & achievements")
        print("/lw reset - reset current combat")
        print("/lw lock - lock frame (click-through)")
        print("/lw unlock - unlock frame")
        print("/lw alpha <0.3-1.0> - set transparency")
        print("/lw fade - toggle fade when not hovering")
        print("/lw debug - toggle debug mode for combat log events")
        print("/lw show | hide - show or hide window")
        print("/lw scale <0.5-2.0> - set window scale")
    end
end

--=============================
-- OnUpdate for rates
--=============================
root:SetScript("OnUpdate", function() UpdateRates() end)

--=============================
-- Init
--=============================
CreateMinimapButton()
UpdateDisplay()
print("|cFF00FF96Light & Wisdom Stats:|r Gamified Edition loaded! Type |cFFFFFF00/lw|r for options.")

-- Show achievement status on login
local achieved = 0
for _, ach in ipairs(ACHIEVEMENTS) do
    if ns.db.achievements[ach.name:gsub(" ", "_")] then
        achieved = achieved + 1
    end
end
if achieved > 0 then
    print(string.format("|cFF00FF96L&W:|r Achievements: %d/%d unlocked", achieved, #ACHIEVEMENTS))
end