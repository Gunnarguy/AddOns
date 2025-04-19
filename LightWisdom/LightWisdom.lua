------------------------------
-- 1. Addon Initialization  --
------------------------------
local ADDON_NAME, ns = ...
local frame = CreateFrame("Frame", "LightWisdomStatsFrame", UIParent)
local statsFrame, minimapButton = nil, nil
local textWidgets = {}
local strsplit = strsplit
LWS_DB = LWS_DB or {
    allTime   = { healing = 0, mana = 0 },
    session   = { healing = 0, mana = 0, startTime = GetTime() },
    combat    = { healing = 0, mana = 0, startTime = 0, inCombat = false },
    rates     = { healing = 0, mana = 0 },
    statusDebuffs = { light = false, wisdom = false },
    position  = { "CENTER", nil, "CENTER", 0, 0 },
    scale     = 1.0,
    locked    = false,
    showRates = true,
    minimapPos= 45
}

local lastUpdate = 0
local updateThreshold = 0.2 -- 5 times per second

------------------------------
-- 2. Utility Functions     --
------------------------------
local function FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return number
    end
end

local function CreateTooltip(frame, title, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine(title, 1, 1, 1)
        GameTooltip:AddLine(text, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

------------------------------
-- 3. Party Member Check   --
------------------------------
local function IsPartyMember(guid)
    if not guid then return false end
    if guid == UnitGUID("player") then return true end
    if IsInGroup() then
        local numGroupMembers = GetNumGroupMembers()
        for i = 1, numGroupMembers do
            local unitID = (IsInRaid() and "raid" .. i) or ("party" .. i)
            if UnitExists(unitID) and guid == UnitGUID(unitID) then
                return true
            end
        end
    end
    return false
end

------------------------------
-- 4. Display Update Logic  --
------------------------------
local function UpdateDisplay()
    for _, widget in ipairs(textWidgets) do
        local scope = LWS_DB[widget.key]
        widget.healing:SetText(FormatNumber(scope.healing or 0))
        widget.mana:SetText(FormatNumber(scope.mana or 0))
    end
    
    if statsFrame then
        statsFrame.jolIndicator:SetTextColor(LWS_DB.statusDebuffs.light and 0 or 1, LWS_DB.statusDebuffs.light and 1 or 0, 0)
        statsFrame.jowIndicator:SetTextColor(LWS_DB.statusDebuffs.wisdom and 0 or 1, LWS_DB.statusDebuffs.wisdom and 1 or 0, 0)
    end
end

local function ThrottledUpdate()
    local currentTime = GetTime()
    if currentTime - lastUpdate >= updateThreshold then
        UpdateDisplay()
        lastUpdate = currentTime
    end
end

local function UpdateStats(statType, amount)
    LWS_DB.combat[statType] = LWS_DB.combat[statType] + amount
    LWS_DB.session[statType] = LWS_DB.session[statType] + amount
    LWS_DB.allTime[statType] = LWS_DB.allTime[statType] + amount
    ThrottledUpdate()
end

------------------------------
-- 5. Combat Rate Tracking  --
------------------------------
local function UpdateCombatRates()
    if not LWS_DB.combat.inCombat then return end

    local currentTime = GetTime()
    local combatDuration = currentTime - LWS_DB.combat.startTime

    if combatDuration > 0 then
        if LWS_DB.combat.healing > 0 or LWS_DB.combat.mana > 0 then
            LWS_DB.rates.healing = math.floor((LWS_DB.combat.healing / combatDuration) * 60)
            LWS_DB.rates.mana    = math.floor((LWS_DB.combat.mana / combatDuration) * 60)
            ThrottledUpdate()
        end
    else
        LWS_DB.rates.healing = 0
        LWS_DB.rates.mana    = 0
    end
end

local rateUpdateTimer = CreateFrame("Frame")
rateUpdateTimer:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then
        self.elapsed = 0
        UpdateCombatRates()
    end
end)
rateUpdateTimer:Hide() -- Start hidden, only enabled in combat

local function OnCombatStart()
    LWS_DB.combat = { 
        healing = 0, 
        mana = 0, 
        startTime = GetTime(), 
        inCombat = true 
    }
    LWS_DB.rates = { healing = 0, mana = 0 }
    UpdateDisplay()
    rateUpdateTimer:Show()
end

local function OnCombatEnd()
    LWS_DB.combat.inCombat = false
    local finalRates = { healing = LWS_DB.rates.healing, mana = LWS_DB.rates.mana }
    LWS_DB.combat = { healing = 0, mana = 0, startTime = 0, inCombat = false }
    LWS_DB.rates = finalRates
    UpdateDisplay()
    rateUpdateTimer:Hide()
    C_Timer.After(5, function()
        if not LWS_DB.combat.inCombat then
            LWS_DB.rates = { healing = 0, mana = 0 }
            UpdateDisplay()
        end
    end)
end

------------------------------
-- 6. UI and Minimap Button --
------------------------------
local function UpdateMinimapButtonPosition()
    if not minimapButton then return end
    local angle = LWS_DB.minimapPos
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
    local button = CreateFrame("Button", "LWSMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameLevel(8)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Set proper button properties to make it visible and clickable
    button:EnableMouse(true)
    button:SetMovable(false)
    button:RegisterForDrag("LeftButton")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Create the button icon
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Spell_Holy_SealOfWisdom")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    
    -- Create the border texture
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", -11, 11)
    
    -- Set up drag functionality
    button:SetScript("OnDragStart", function(self)
        -- We're not moving the button itself, just tracking cursor for angle calculation
        self.isMoving = true
    end)
    
    button:SetScript("OnDragStop", function(self)
        self.isMoving = false
        -- Calculate position based on cursor and minimap center
        local xpos, ypos = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        xpos, ypos = xpos / scale, ypos / scale
        local minimapX, minimapY = Minimap:GetCenter()
        local angle = math.atan2(ypos - minimapY, xpos - minimapX)
        LWS_DB.minimapPos = angle
        UpdateMinimapButtonPosition()
    end)
    
    -- Set up click handlers
    button:SetScript("OnClick", function(self, btn)
        if btn == "LeftButton" then
            statsFrame:SetShown(not statsFrame:IsShown())
        elseif btn == "RightButton" then
            ToggleDropDownMenu(1, nil, LWSDropDownMenu, self, 0, 0)
        end
    end)
    
    -- Create tooltip
    CreateTooltip(button, "Light & Wisdom Stats", 
        "Left-Click: Toggle stats window\nRight-Click: Open options menu\nDrag: Move button")
    
    return button
end

local function CreateUI()
    -- Create the main stats frame with a backdrop
    local f = CreateFrame("Frame", "LWS_StatsFrame", UIParent, "BackdropTemplate")
    f:SetSize(200, 140)
    f:SetScale(LWS_DB.scale)
    
    -- Enable frame movement - critical for drag functionality
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    
    -- Fix position setting by ensuring proper anchor format
    local pos = LWS_DB.position
    if pos and #pos >= 5 then
        -- Standard format: point, relativeTo, relativePoint, x, y
        f:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
    else
        -- Fallback to default position if saved position is invalid
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        -- Update the stored position with correct format
        LWS_DB.position = {"CENTER", UIParent, "CENTER", 0, 0}
    end
    
    -- Set visual appearance of the frame
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    
    -- ===== DRAGGABLE HEADER SECTION =====
    -- Create a more visible header bar for dragging
    local header = CreateFrame("Frame", nil, f)
    header:SetHeight(25) -- Taller for easier dragging
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4) -- Inset slightly for visual appeal
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    header:EnableMouse(true) -- Crucial for capturing mouse events
    
    -- Add a more noticeable texture to the header
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints()
    headerBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    headerBg:SetBlendMode("ADD")
    headerBg:SetVertexColor(0.6, 0.6, 1.0, 0.7) -- Brighter blue color
    headerBg:SetShown(not LWS_DB.locked)
    f.headerTexture = headerBg -- Store reference for toggling
    
    -- Add a subtle grip texture to suggest draggable
    local grip = header:CreateTexture(nil, "OVERLAY")
    grip:SetTexture("Interface\\AddOns\\LightWisdom\\grip")
    grip:SetSize(16, 16)
    grip:SetPoint("LEFT", header, "LEFT", 5, 0)
    grip:SetVertexColor(1, 1, 1, 0.7)
    grip:SetShown(not LWS_DB.locked)
    f.gripTexture = grip
    
    -- ===== DRAGGING BEHAVIOR =====
    -- Set up the actual drag functionality on the header
    header:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not LWS_DB.locked then
            -- This is the critical function call that enables dragging
            f:StartMoving()
            f.isMoving = true
        end
    end)
    
    header:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and f.isMoving then
            -- Stop the movement and save the new position
            f:StopMovingOrSizing()
            f.isMoving = false
            
            -- Save position in a format that works with SetPoint
            local point, _, relativePoint, x, y = f:GetPoint()
            LWS_DB.position = {point, UIParent, relativePoint, x, y}
        end
    end)
    
    -- Ensure dragging stops if the cursor leaves the frame while dragging
    header:SetScript("OnHide", function(self)
        if f.isMoving then
            f:StopMovingOrSizing()
            f.isMoving = false
        end
    end)
    
    -- Change cursor when hovering over the header to indicate draggability
    header:SetScript("OnEnter", function(self)
        if not LWS_DB.locked then
            SetCursor("CAST_CURSOR")
        end
    end)
    
    header:SetScript("OnLeave", function(self)
        if not f.isMoving then
            ResetCursor()
        end
    end)
    
    -- Title and Debuff Indicators
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12) -- Adjusted position to work with header
    title:SetText("|cFF00FF96Light & Wisdom Stats|r")
    
    -- Control Buttons - moved to be more visually separate from header
    local lockBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    lockBtn:SetSize(20, 20) -- Slightly larger for better clickability
    lockBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -12)
    lockBtn:SetText("L")
    lockBtn:SetScript("OnClick", function()
        -- Toggle lock state and update visual indicators
        LWS_DB.locked = not LWS_DB.locked
        f.headerTexture:SetShown(not LWS_DB.locked)
        f.gripTexture:SetShown(not LWS_DB.locked)
        print("Light & Wisdom Stats Frame " .. (LWS_DB.locked and "|cFFFF0000Locked|r" or "|cFF00FF00Unlocked|r"))
    end)
    CreateTooltip(lockBtn, "Lock/Unlock", "Toggle frame dragging")
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(20, 20)
    resetBtn:SetPoint("RIGHT", lockBtn, "LEFT", -5, 0)
    resetBtn:SetText("R")

    -- Create reset menu directly instead of using StaticPopup
    resetBtn:SetScript("OnClick", function()
        -- Create dropdown menu for reset options
        local menu = {
            { text = "Reset Options", isTitle = true, notCheckable = true },
            { text = "Combat Stats", notCheckable = true, func = function() 
                LWS_DB.combat = { healing = 0, mana = 0, startTime = GetTime(), inCombat = LWS_DB.combat.inCombat }
                UpdateDisplay()
                print("|cFF00FF96Light & Wisdom Stats:|r Combat stats reset")
            end },
            { text = "Session Stats", notCheckable = true, func = function()
                LWS_DB.session = { healing = 0, mana = 0, startTime = GetTime() }
                UpdateDisplay()
                print("|cFF00FF96Light & Wisdom Stats:|r Session stats reset") 
            end },
            { text = "All-Time Stats", notCheckable = true, func = function() 
                LWS_DB.allTime = { healing = 0, mana = 0 }
                UpdateDisplay()
                print("|cFF00FF96Light & Wisdom Stats:|r All-time stats reset")
            end },
            { text = "Cancel", notCheckable = true, func = function() end },
        }
        
        -- Show dropdown menu at cursor position
        EasyMenu(menu, CreateFrame("Frame", "LWSResetMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
    end)

    CreateTooltip(resetBtn, "Reset", "Click to reset statistics")
    
    -- Add a status message that displays on first load
    C_Timer.After(1, function()
        if not LWS_DB.showedDragTip then
            print("|cFF00FF96Light & Wisdom Stats:|r Frame is |cFF00FF00unlocked|r. Drag the blue header to move it.")
            LWS_DB.showedDragTip = true
        end
    end)
    
    -- The rest of the UI elements (indicators, stats, etc.)
    local jolIndicator = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jolIndicator:SetPoint("TOPLEFT", 10, -35) -- Adjusted for header
    jolIndicator:SetText("JoL:")
    f.jolIndicator = jolIndicator
    
    local jowIndicator = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jowIndicator:SetPoint("LEFT", jolIndicator, "RIGHT", 10, 0)
    jowIndicator:SetText("JoW:")
    f.jowIndicator = jowIndicator
    
    local jolFrame = CreateFrame("Frame", nil, f)
    jolFrame:SetAllPoints(jolIndicator)
    CreateTooltip(jolFrame, "Judgement of Light", 
        "Green = Active, Red = Inactive\nHeals the attacker when active.")
    
    local jowFrame = CreateFrame("Frame", nil, f)
    jowFrame:SetAllPoints(jowIndicator)
    CreateTooltip(jowFrame, "Judgement of Wisdom", 
        "Green = Active, Red = Inactive\nRestores mana when active.")
    
    -- Headers
    local col1X, col2X = 80, 150
    for _, header in ipairs({ { text = "Healing", x = col1X }, { text = "Mana", x = col2X } }) do
        local h = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        h:SetPoint("TOP", f, "TOP", header.x - f:GetWidth() / 2, -45)
        h:SetText(header.text)
    end
    
    -- Stat Rows
    local entries = {
        { label = "Combat:",   key = "combat" },
        { label = "Session:",  key = "session" },
        { label = "All-Time:", key = "allTime" }
    }
    local rowY = -65
    for _, entry in ipairs(entries) do
        local rowLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowLabel:SetPoint("TOPLEFT", 10, rowY)
        rowLabel:SetText(entry.label)
        
        local healing = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        healing:SetPoint("TOPLEFT", f, "TOPLEFT", col1X - 20, rowY)
        healing:SetText("0")
        
        local mana = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        mana:SetPoint("TOPLEFT", f, "TOPLEFT", col2X - 20, rowY)
        mana:SetText("0")
        
        table.insert(textWidgets, { key = entry.key, healing = healing, mana = mana })
        rowY = rowY - 18
    end
    
    -- Rate Display
    local rateLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rateLabel:SetPoint("TOPLEFT", 10, rowY)
    rateLabel:SetText("Per Min:")
    
    local healingRate = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    healingRate:SetPoint("TOPLEFT", f, "TOPLEFT", col1X - 20, rowY)
    healingRate:SetText("0")
    
    local manaRate = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    manaRate:SetPoint("TOPLEFT", f, "TOPLEFT", col2X - 20, rowY)
    manaRate:SetText("0")
    
    table.insert(textWidgets, { key = "rates", healing = healingRate, mana = manaRate })
    
    local rateTooltipFrame = CreateFrame("Frame", nil, f)
    rateTooltipFrame:SetSize(50, 20)
    rateTooltipFrame:SetPoint("TOPLEFT", rateLabel, "TOPLEFT", -2, 2)
    CreateTooltip(rateTooltipFrame, "Per Minute Rate", "Average healing and mana restoration per minute.")
    
    statsFrame = f
    UpdateDisplay()
    return f
end

------------------------------
-- 7. Dropdown Menu         --
------------------------------
function LWSDropDownMenu_Initialize(frame, level)
    level = level or 1
    local info = UIDropDownMenu_CreateInfo()
    
    if level == 1 then
        -- Main menu items (level 1)
        info.text = "Light & Wisdom Stats Options"
        info.isTitle = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
        
        info.isTitle = false
        info.disabled = false
        info.notCheckable = true
        
        -- Toggle window option
        info.text = "Toggle Window"
        info.func = function() statsFrame:SetShown(not statsFrame:IsShown()) end
        UIDropDownMenu_AddButton(info, level)
        
        -- Lock/unlock window option
        info.text = "Lock/Unlock Window"
        info.func = function()
            LWS_DB.locked = not LWS_DB.locked
            statsFrame:EnableMouse(not LWS_DB.locked)
            print("Light & Wisdom Stats Frame " .. (LWS_DB.locked and "|cFFFF0000Locked|r" or "|cFF00FF00Unlocked|r"))
        end
        UIDropDownMenu_AddButton(info, level)
        
        -- Reset Stats submenu option
        info.text = "Reset Stats"
        info.hasArrow = true       -- Indicates this item has a submenu
        info.notCheckable = true
        info.value = "RESET_MENU"  -- Important! This value identifies the submenu
        info.func = nil            -- No function for menu items with submenus
        UIDropDownMenu_AddButton(info, level)
        
    elseif level == 2 then
        -- Submenu items (level 2)
        -- Check which submenu we're showing based on the parent menu value
        if UIDROPDOWNMENU_MENU_VALUE == "RESET_MENU" then
            info.notCheckable = true
            info.hasArrow = false
            
            -- Reset Combat Stats option
            info.text = "Reset Combat Stats"
            info.func = function()
                LWS_DB.combat = { healing = 0, mana = 0, startTime = GetTime(), inCombat = LWS_DB.combat.inCombat }
                UpdateDisplay()
                print("|cFF00FF96Light & Wisdom Stats:|r Combat stats reset")
            end
            UIDropDownMenu_AddButton(info, level)
            
            -- Reset Session Stats option
            info.text = "Reset Session Stats"
            info.func = function()
                LWS_DB.session = { healing = 0, mana = 0, startTime = GetTime() }
                UpdateDisplay()
                print("|cFF00FF96Light & Wisdom Stats:|r Session stats reset")
            end
            UIDropDownMenu_AddButton(info, level)
            
            -- Reset All-Time Stats option
            info.text = "Reset All-Time Stats"
            info.func = function()
                LWS_DB.allTime = { healing = 0, mana = 0 }
                UpdateDisplay()
                print("|cFF00FF96Light & Wisdom Stats:|r All-Time stats reset")
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

------------------------------
-- 8. Combat & Event Hooks  --
------------------------------
local eventHandlers = {
    PLAYER_LOGIN = function()
        CreateUI()
        CreateFrame("Frame", "LWSDropDownMenu", UIParent, "UIDropDownMenuTemplate")
        UIDropDownMenu_Initialize(LWSDropDownMenu, LWSDropDownMenu_Initialize)
        minimapButton = CreateMinimapButton()
        UpdateMinimapButtonPosition()
        
        -- Debug status message to confirm addon loaded correctly
        print("|cFF00FF96Light & Wisdom Stats:|r Addon initialized and ready to track")
    end,
    
    COMBAT_LOG_EVENT_UNFILTERED = function()
        local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
              destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        
        -- Skip processing if not a relevant event (optimization)
        if not (subEvent == "SPELL_AURA_APPLIED" or 
                subEvent == "SPELL_AURA_REFRESH" or 
                subEvent == "SPELL_AURA_REMOVED" or 
                subEvent == "SPELL_HEAL" or 
                subEvent == "SPELL_ENERGIZE") then
            return
        end
        
        -- Extract more info from combat log
        local spellID, spellName, spellSchool, amount, overHeal, absorbed, powerType
        
        if subEvent == "SPELL_HEAL" then
            -- Format for SPELL_HEAL: spellID, spellName, spellSchool, amount, overhealing, absorbed
            spellID, spellName, spellSchool, amount, overHeal, absorbed = select(12, CombatLogGetCurrentEventInfo())
        elseif subEvent == "SPELL_ENERGIZE" then
            -- Format for SPELL_ENERGIZE: spellID, spellName, spellSchool, amount, powerType
            spellID, spellName, spellSchool, amount, powerType = select(12, CombatLogGetCurrentEventInfo())
        else
            -- Format for aura events: spellID, spellName, spellSchool, auraType
            spellID, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
        end
        
        -- Debug logging for spellIDs during development
        -- if spellName and (spellName:match("Judgement") or spellName:match("Light") or spellName:match("Wisdom")) then
        --    print(subEvent, spellID, spellName)
        -- end
        
        -- ===== JUDGEMENT OF LIGHT HEALING DETECTION =====
        -- Classic Era JoL SpellID: 20343 = Judgement of Light heal proc
        if subEvent == "SPELL_HEAL" and (spellID == 20343 or spellName == "Judgement of Light") and 
           IsPartyMember(destGUID) then
           
            -- Calculate effective healing by subtracting overheal if it exists
            local effectiveHealing = amount
            if overHeal and type(overHeal) == "number" then
                effectiveHealing = amount - overHeal
            end
            
            if effectiveHealing > 0 then
                UpdateStats("healing", effectiveHealing)
                -- Debug for healing detection
                -- print("JoL heal:", effectiveHealing)
            end
            
        -- ===== JUDGEMENT OF WISDOM MANA RESTORATION DETECTION =====
        -- Classic Era JoW SpellID: 20268 = Judgement of Wisdom mana proc
        elseif subEvent == "SPELL_ENERGIZE" and (spellID == 20268 or spellName == "Judgement of Wisdom") and 
               IsPartyMember(destGUID) and powerType == 0 then -- 0 = mana
            
            if amount > 0 then
                UpdateStats("mana", amount)
                -- Debug for mana detection
                -- print("JoW mana:", amount)
            end
            
        -- ===== DEBUFF APPLICATION TRACKING =====
        elseif subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
            -- Judgement of Light main rank spell IDs
            if spellID == 20271 or spellID == 20185 or spellID == 20186 or 
               spellID == 20344 or spellID == 20345 or spellID == 20346 or
               (spellName and spellName:match("Judgement of Light")) then
                LWS_DB.statusDebuffs.light = true
                ThrottledUpdate()
                -- Debug for JoL application
                -- print("JoL applied:", spellID, spellName)
            -- Judgement of Wisdom main rank spell IDs
            elseif spellID == 20217 or spellID == 20268 or spellID == 20269 or 
                   spellID == 20270 or spellID == 20354 or spellID == 20352 or spellID == 20353 or
                   (spellName and spellName:match("Judgement of Wisdom")) then
                LWS_DB.statusDebuffs.wisdom = true
                ThrottledUpdate()
                -- Debug for JoW application
                -- print("JoW applied:", spellID, spellName)
            end
            
        -- ===== DEBUFF REMOVAL TRACKING =====
        elseif subEvent == "SPELL_AURA_REMOVED" then
            -- Handle Judgement of Light removal
            if spellID == 20271 or spellID == 20185 or spellID == 20186 or 
               spellID == 20344 or spellID == 20345 or spellID == 20346 or
               (spellName and spellName:match("Judgement of Light")) then
                LWS_DB.statusDebuffs.light = false
                ThrottledUpdate()
                -- Debug for JoL removal
                -- print("JoL removed:", spellID, spellName)
            -- Handle Judgement of Wisdom removal
            elseif spellID == 20217 or spellID == 20268 or spellID == 20269 or 
                   spellID == 20270 or spellID == 20354 or spellID == 20352 or spellID == 20353 or
                   spellID == 21183 or (spellName and spellName:match("Judgement of Wisdom")) then
                LWS_DB.statusDebuffs.wisdom = false
                ThrottledUpdate()
                -- Debug for JoW removal
                -- print("JoW removed:", spellID, spellName)
            -- Handle generic Judgement removal which clears both effects
            elseif spellID == 20271 or (spellName and spellName == "Judgement") then
                LWS_DB.statusDebuffs.light = false
                LWS_DB.statusDebuffs.wisdom = false
                ThrottledUpdate()
                -- Debug for general Judgement removal
                -- print("Judgement removed:", spellID, spellName)
            end
        end
    end,

    PLAYER_REGEN_ENABLED = function() OnCombatEnd() end,
    PLAYER_REGEN_DISABLED = function() OnCombatStart() end,
    GROUP_ROSTER_UPDATE = function() UpdateDisplay() end,
}

frame:SetScript("OnEvent", function(self, event, ...)
    if eventHandlers[event] then
        eventHandlers[event](...)
    end
end)

-- Register all events
for event in pairs(eventHandlers) do
    frame:RegisterEvent(event)
end

------------------------------
-- 9. Slash Command Support --
------------------------------
SLASH_LWS1 = "/lw"
SlashCmdList["LWS"] = function(msg)
    local cmd, arg = strsplit(" ", msg:lower(), 2)
    
    if cmd == "toggle" then
        statsFrame:SetShown(not statsFrame:IsShown())
    elseif cmd == "lock" then
        LWS_DB.locked = not LWS_DB.locked
        statsFrame:EnableMouse(not LWS_DB.locked)
        print("Light & Wisdom Stats Frame " .. (LWS_DB.locked and "|cFFFF0000Locked|r" or "|cFF00FF00Unlocked|r"))
    elseif cmd == "scale" and arg then
        local scale = tonumber(arg)
        if scale and scale >= 0.5 and scale <= 2.0 then
            LWS_DB.scale = scale
            statsFrame:SetScale(scale)
            print("Light & Wisdom Stats Frame Scale set to " .. scale)
        else
            print("Scale must be a number between 0.5 and 2.0")
        end
    elseif cmd == "reset" then
        if arg == "combat" then
            LWS_DB.combat = { healing = 0, mana = 0, startTime = GetTime(), inCombat = LWS_DB.combat.inCombat }
        elseif arg == "session" then
            LWS_DB.session = { healing = 0, mana = 0, startTime = GetTime() }
        elseif arg == "all" then
            LWS_DB.allTime = { healing = 0, mana = 0 }
        else
            print("Please specify what to reset: combat, session, or all")
        end
        UpdateDisplay()
    elseif cmd == "minimap" then
        minimapButton:SetShown(not minimapButton:IsShown())
        print("Minimap button " .. (minimapButton:IsShown() and "shown" or "hidden"))
    elseif cmd == "help" or cmd == "" then
        print("|cFF00FF96Light & Wisdom Stats Help:|r")
        print("/lw toggle - Show/hide window")
        print("/lw lock - Lock/unlock window position")
        print("/lw scale <number> - Set window scale (e.g., /lw scale 1.2)")
        print("/lw reset [combat|session|all] - Reset specific counters")
        print("/lw minimap - Toggle minimap button")
    end
end

------------------------------
-- 10. Reset Confirmation   --
------------------------------
StaticPopupDialogs["LWS_RESET_CONFIRM"] = {
    text = "Which statistics do you want to reset?",
    button1 = "Combat",
    button2 = "Session", 
    button3 = "All-Time",
    button4 = "Cancel",
    OnButton1 = function()
        LWS_DB.combat = { healing = 0, mana = 0, startTime = GetTime(), inCombat = LWS_DB.combat.inCombat }
        UpdateDisplay()
        print("|cFF00FF96Light & Wisdom Stats:|r Combat stats reset")
    end,
    OnButton2 = function()
        LWS_DB.session = { healing = 0, mana = 0, startTime = GetTime() }
        UpdateDisplay()
        print("|cFF00FF96Light & Wisdom Stats:|r Session stats reset")
    end,
    OnButton3 = function()
        LWS_DB.allTime = { healing = 0, mana = 0 }
        UpdateDisplay()
        print("|cFF00FF96Light & Wisdom Stats:|r All-Time stats reset")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  
    showAlert = true,    -- Makes the dialog more noticeable
}
