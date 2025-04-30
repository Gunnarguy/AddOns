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
    f:SetSize(200, 140) -- Keep size or adjust as needed
    f:SetScale(LWS_DB.scale)
    
    -- Enable frame movement - critical for drag functionality
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    -- Keep mouse enabled so hover events work even when locked
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
    
    -- Set visual appearance of the frame - Use a simpler backdrop
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", -- Flat background texture
        edgeFile = nil, -- No border edge
        tile = false,
        tileSize = 16,
        edgeSize = 0, -- No edge size
        insets = { left = 2, right = 2, top = 2, bottom = 2 } -- Minimal insets
    })
    -- Adjust backdrop color and transparency (e.g., slightly darker)
    f:SetBackdropColor(0.1, 0.1, 0.1, 0.85) 
    
    -- ===== DRAGGABLE HEADER SECTION =====
    -- Create a header bar for dragging
    local header = CreateFrame("Frame", nil, f)
    header:SetHeight(20) -- Slightly shorter header
    header:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2) -- Align with new insets
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    -- Header needs mouse enabled to catch drag events when frame is unlocked
    header:EnableMouse(true) 
    
    -- Use a subtle texture or color for the header background
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints()
    -- Use a semi-transparent dark color instead of a bright texture
    headerBg:SetColorTexture(0.2, 0.2, 0.2, 0.5) 
    -- Header background is only shown when unlocked
    headerBg:SetShown(not LWS_DB.locked) 
    f.headerTexture = headerBg -- Store reference for toggling
    
    -- Grip texture is removed/hidden (existing code)
    local grip = header:CreateTexture(nil, "OVERLAY")
    grip:Hide() 
    grip:SetShown(false) 
    f.gripTexture = grip
    
    -- ===== DRAGGING BEHAVIOR =====
    -- Only allow dragging if the frame is NOT locked
    header:SetScript("OnMouseDown", function(self, button)
        -- Check lock status *before* starting movement
        if button == "LeftButton" and not LWS_DB.locked then 
            f:StartMoving()
            f.isMoving = true
        end
    end)
    
    -- OnMouseUp remains the same (stops moving and saves position)
    header:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and f.isMoving then
            f:StopMovingOrSizing()
            f.isMoving = false
            local point, _, relativePoint, x, y = f:GetPoint()
            LWS_DB.position = {point, UIParent, relativePoint, x, y}
        end
    end)
    
    -- OnHide remains the same
    header:SetScript("OnHide", function(self)
        if f.isMoving then
            f:StopMovingOrSizing()
            f.isMoving = false
        end
    end)
    
    -- Change cursor only when unlocked
    header:SetScript("OnEnter", function(self)
        if not LWS_DB.locked then
            SetCursor("CAST_CURSOR")
        end
    end)
    
    -- OnLeave remains the same
    header:SetScript("OnLeave", function(self)
        if not f.isMoving then
            ResetCursor()
        end
    end)
    
    -- Title - Adjust position slightly due to header/inset changes (existing code)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -6) 
    title:SetText("|cFF00FF96Light & Wisdom Stats|r")

    -- ===== BOTTOM-LEFT ANCHOR (Visual Only) =====
    local anchor = f:CreateTexture(nil, "OVERLAY")
    anchor:SetSize(12, 12) -- Small visual indicator
    anchor:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 4, 4) -- Position in the corner, respecting insets
    -- Use a simple texture, e.g., a square or corner piece
    anchor:SetTexture("Interface\\ChatFrame\\ChatFrameGrip") -- Re-use a grip-like texture
    anchor:SetVertexColor(0.8, 0.8, 0.8, 0.6) -- Make it semi-transparent grey
    -- Anchor is only shown when unlocked
    anchor:SetShown(not LWS_DB.locked) 
    f.anchorTexture = anchor -- Store reference

    -- ===== HOVER LOCK BUTTON =====
    local hoverLockBtn = CreateFrame("Button", nil, f)
    hoverLockBtn:SetSize(18, 18) -- Small button
    hoverLockBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -3) -- Position in the corner
    
    -- Set textures for locked and unlocked states
    local tex = hoverLockBtn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    hoverLockBtn.texture = tex
    
    local function UpdateLockButtonTexture()
        if LWS_DB.locked then
            -- Use a 'locked' icon texture
            hoverLockBtn.texture:SetTexture("Interface\\Buttons\\UI-Panel-Lock-Button-Down") 
        else
            -- Use an 'unlocked' icon texture
            hoverLockBtn.texture:SetTexture("Interface\\Buttons\\UI-Panel-Lock-Button-Up") 
        end
    end
    UpdateLockButtonTexture() -- Set initial texture

    hoverLockBtn:SetScript("OnClick", function()
        LWS_DB.locked = not LWS_DB.locked
        UpdateLockButtonTexture() -- Update icon
        f.headerTexture:SetShown(not LWS_DB.locked) -- Show/hide drag header bg
        f.anchorTexture:SetShown(not LWS_DB.locked) -- Show/hide bottom-left anchor
        print("Light & Wisdom Stats Frame " .. (LWS_DB.locked and "|cFFFF0000Locked|r" or "|cFF00FF00Unlocked|r"))
        -- No need to change f:EnableMouse here, dragging is handled by header's OnMouseDown
    end)

    -- Initially hide the button (set alpha to 0)
    hoverLockBtn:SetAlpha(0) 
    f.hoverLockBtn = hoverLockBtn -- Store reference if needed elsewhere

    -- Fade In/Out Logic for Hover Button
    f:SetScript("OnEnter", function(self)
        -- Fade in the lock button when mouse enters the main frame
        UIFrameFadeIn(self.hoverLockBtn, 0.2, self.hoverLockBtn:GetAlpha(), 1) 
    end)

    f:SetScript("OnLeave", function(self)
        -- Fade out the lock button when mouse leaves the main frame,
        -- but only if the mouse isn't moving onto the button itself.
        local currentMouseFocus = GetMouseFocus()
        if currentMouseFocus ~= self.hoverLockBtn then
            UIFrameFadeOut(self.hoverLockBtn, 0.3, self.hoverLockBtn:GetAlpha(), 0) 
        end
    end)

    hoverLockBtn:SetScript("OnEnter", function(self)
        -- Keep the button visible (cancel fade out) when mouse is over it
        UIFrameFadeIn(self, 0.1, self:GetAlpha(), 1) 
    end)

    hoverLockBtn:SetScript("OnLeave", function(self)
        -- Fade out the button when the mouse leaves it
        UIFrameFadeOut(self, 0.3, self:GetAlpha(), 0) 
    end)

    CreateTooltip(hoverLockBtn, "Lock/Unlock Frame", "Click to toggle frame movement.")

    -- REMOVED 'L' and 'R' buttons and their logic (including EasyMenu call)
    
    -- Status message (existing code, text updated slightly)
    C_Timer.After(1, function()
        if not LWS_DB.showedDragTip then
            print("|cFF00FF96Light & Wisdom Stats:|r Frame is |cFF00FF00unlocked|r. Drag the header area (when visible) or use the lock icon.") 
            LWS_DB.showedDragTip = true
        end
    end)
    
    -- Debuff Indicators - Adjust vertical position
    local indicatorYOffset = -28 -- Position below title/header area
    local jolIndicator = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jolIndicator:SetPoint("TOPLEFT", 10, indicatorYOffset) 
    jolIndicator:SetText("JoL:")
    f.jolIndicator = jolIndicator
    
    local jowIndicator = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jowIndicator:SetPoint("LEFT", jolIndicator, "RIGHT", 10, 0)
    jowIndicator:SetText("JoW:")
    f.jowIndicator = jowIndicator
    
    -- Tooltip frames for indicators (existing code)
    local jolFrame = CreateFrame("Frame", nil, f)
    jolFrame:SetAllPoints(jolIndicator)
    CreateTooltip(jolFrame, "Judgement of Light", "Green = Active, Red = Inactive\nHeals the attacker when active.")
    
    local jowFrame = CreateFrame("Frame", nil, f)
    jowFrame:SetAllPoints(jowIndicator)
    CreateTooltip(jowFrame, "Judgement of Wisdom", "Green = Active, Red = Inactive\nRestores mana when active.")
    
    -- Headers - Adjust vertical position
    local headerYOffset = indicatorYOffset - 18 -- Position below indicators
    local col1X, col2X = 80, 150
    for _, headerData in ipairs({ { text = "Healing", x = col1X }, { text = "Mana", x = col2X } }) do
        local h = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        -- Anchor relative to TOPLEFT for consistency with other elements
        h:SetPoint("TOPLEFT", f, "TOPLEFT", headerData.x - 20, headerYOffset) 
        h:SetText(headerData.text)
    end
    
    -- Stat Rows - Adjust starting vertical position
    local entries = {
        { label = "Combat:",   key = "combat" },
        { label = "Session:",  key = "session" },
        { label = "All-Time:", key = "allTime" }
    }
    local rowY = headerYOffset - 18 -- Start below headers
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
        rowY = rowY - 18 -- Increment Y offset for next row
    end
    
    -- Rate Display - Positioned below stat rows
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
    
    -- Tooltip for rate display (existing code)
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
        
        -- Lock/unlock window option (now redundant with hover button, but keep for accessibility?)
        -- Or repurpose/remove. Let's keep it for now.
        info.text = LWS_DB.locked and "Unlock Window" or "Lock Window" -- Dynamic text
        info.func = function()
            -- Call the hover button's OnClick logic to keep things consistent
            if statsFrame and statsFrame.hoverLockBtn then
                statsFrame.hoverLockBtn:Click() 
            end
            -- Fallback if button doesn't exist for some reason
            -- LWS_DB.locked = not LWS_DB.locked
            -- if statsFrame then statsFrame.headerTexture:SetShown(not LWS_DB.locked) end
            -- print("Light & Wisdom Stats Frame " .. (LWS_DB.locked and "|cFFFF0000Locked|r" or "|cFF00FF00Unlocked|r"))
        end
        UIDropDownMenu_AddButton(info, level)
        
        -- Reset Stats submenu option (Moved from 'R' button)
        info.text = "Reset Stats"
        info.hasArrow = true       -- Indicates this item has a submenu
        info.notCheckable = true
        info.value = "RESET_MENU"  -- Value to identify this submenu
        info.func = nil            -- No function for menu items with submenus
        UIDropDownMenu_AddButton(info, level)

        -- Add Scale option here? Or keep as slash command only. Keep as slash for now.
        
    elseif level == 2 then
        -- Submenu items (level 2)
        -- Check which submenu we're showing based on the parent menu value
        if UIDROPDOWNMENU_MENU_VALUE == "RESET_MENU" then
            info.text = "Reset Which Stats?" -- Submenu Title
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            info.isTitle = false
            info.notCheckable = true
            info.hasArrow = false -- These are action items
            
            -- Reset Combat Stats option
            info.text = "Reset Combat Stats"
            info.func = function()
                LWS_DB.combat = { healing = 0, mana = 0, startTime = GetTime(), inCombat = LWS_DB.combat.inCombat }
                LWS_DB.rates = { healing = 0, mana = 0 } -- Also reset rates tied to combat
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
        -- Add other submenus here if needed using elseif UIDROPDOWNMENU_MENU_VALUE == "OTHER_MENU"
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
