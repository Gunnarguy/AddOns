-- HolyCreditTracker.lua
-- Classic-safe Paladin healing tracker for effective healing + Illumination refunds
-- Nightslayer-US (PvP) · Build 1.15.7 context

local ADDON_NAME, _ = ...
HolyCreditTrackerDB = HolyCreditTrackerDB or {}

------------------------------------------------------------------------
-- Defaults / helpers
------------------------------------------------------------------------
local defaults = {
  position = {"CENTER", "UIParent", "CENTER", 0, 0},
  scale    = 0.9,
  locked   = false,
  alpha    = 0.8,  -- New: transparency setting
  fadeAlpha = 0.5, -- New: faded alpha when not hovering
  fadeEnabled = false, -- New: enable fade on mouse leave
  allTime  = { healing = 0, refund = 0, spent = 0, crits = 0, heals = 0 },
  session  = { healing = 0, refund = 0, spent = 0, crits = 0, heals = 0, startTime = GetTime() },
  combat   = { healing = 0, refund = 0, spent = 0, crits = 0, heals = 0, inCombat = false, startTime = 0 },
  -- New gamification data
  achievements = {},
  raidStats = {},  -- Stats per raid instance
  personalBests = {
    bestEfficiency = 0,
    bestCritStreak = 0,
    bestManaRefund = 0,
    bestHealingCombat = 0,
  },
  settings = {
    soundEnabled = true,
    showAchievements = true,
  }
}

local function deepcopy(src, dst)
  if type(src) ~= "table" then return src end
  dst = dst or {}
  for k, v in pairs(src) do
    dst[k] = (type(v) == "table") and deepcopy(v, dst[k]) or v
  end
  return dst
end

local function mergeDefaults(db, d)
  if type(db) ~= "table" then db = {} end
  for k, v in pairs(d) do
    if type(v) == "table" then
      db[k] = mergeDefaults(db[k], v)
    elseif db[k] == nil then
      db[k] = v
    end
  end
  return db
end

local function fmt(number)
  if not number then return "0" end
  if number >= 1000000 then
    return string.format("%.1fM", number / 1000000)
  elseif number >= 1000 then
    return string.format("%.1fK", number / 1000)
  else
    return tostring(math.floor(number + 0.5))
  end
end

local function colorText(hex, text) return "|cff"..hex..tostring(text).."|r" end

-- Healing spell whitelist (rank-agnostic, enUS client)
local HEALING_SPELLS = {
  ["Flash of Light"] = true,
  ["Holy Light"]     = true,
  ["Lay on Hands"]   = true,
}

-- Observed cast-time (ms) from START→SUCCEEDED; seeded to a sensible default
local avgCastMS, ctSamples = 2000, 0
local castStartAt = {} -- [castGUID] = startTime

local function updateAvgCast(ms)
  if not ms or ms <= 0 then return end
  ctSamples = math.min(ctSamples + 1, 50)
  local w = 1 / ctSamples
  avgCastMS = avgCastMS * (1 - w) + ms * w
end

local function getHolyCritChancePercent(state)
  -- Prefer observed session rate once we have enough samples; else stat sheet
  local sess = state and state.session
  if sess and (sess.heals or 0) >= 10 then
    return (sess.crits / math.max(1, sess.heals)) * 100
  end
  if GetSpellCritChance then
    local crit = GetSpellCritChance(2) -- Holy
    if type(crit) == "number" and crit > 0 then return crit end
  end
  return 10
end

-- Base mana cost via Classic-safe API using ranked spellID (best accuracy)
local function baseManaCost(spellID, spellName)
  local cost = 0
  if GetSpellPowerCost then
    local t = GetSpellPowerCost(spellID) or (spellName and GetSpellPowerCost(spellName))
    if type(t) == "table" then
      for _, e in ipairs(t) do
        if e and e.type == 0 then cost = e.cost or 0; break end -- 0 = mana
      end
    end
  end
  -- Lay on Hands: costs all mana; treat as 0 base here so net doesn't nuke the display
  return cost or 0
end

------------------------------------------------------------------------
-- State + UI
------------------------------------------------------------------------
local HCT = CreateFrame("Frame", "HolyCreditTrackerFrame", UIParent)
local ui, text = nil, {}

local function net(scope) return (scope.refund or 0) - (scope.spent or 0) end

-- Gamification: Efficiency grades and thresholds
local EFFICIENCY_GRADES = {
  {threshold = 40, grade = "S", color = "FFD700", desc = "Legendary!"},  -- Gold
  {threshold = 30, grade = "A", color = "00FF00", desc = "Excellent!"},   -- Green
  {threshold = 20, grade = "B", color = "00BFFF", desc = "Good"},         -- Light Blue
  {threshold = 10, grade = "C", color = "FFFF00", desc = "Average"},      -- Yellow
  {threshold = 0,  grade = "D", color = "FF6B6B", desc = "Keep trying"}, -- Red
}

-- Milestone definitions for achievements
local MILESTONES = {
  {refund = 1000,  name = "Mana Saver",      icon = "♦"},
  {refund = 5000,  name = "Illuminated",     icon = "✦"},
  {refund = 10000, name = "Mana Master",     icon = "★"},
  {refund = 25000, name = "Efficiency God",  icon = "✪"},
  {refund = 50000, name = "Lightbringer",    icon = "☀"},
}

-- Raid instance detection
local RAID_ZONES = {
  ["Molten Core"] = true,
  ["Blackwing Lair"] = true,
  ["Ahn'Qiraj"] = true,
  ["Naxxramas"] = true,
  ["Zul'Gurub"] = true,
  ["Ruins of Ahn'Qiraj"] = true,
}

-- Calculate efficiency percentage
local function getEfficiencyPercent(scope)
  local spent = scope.spent or 0
  if spent <= 0 then return 0 end
  local refund = scope.refund or 0
  return (refund / spent) * 100
end

-- Get efficiency grade based on percentage
local function getEfficiencyGrade(percent)
  for _, grade in ipairs(EFFICIENCY_GRADES) do
    if percent >= grade.threshold then
      return grade
    end
  end
  return EFFICIENCY_GRADES[#EFFICIENCY_GRADES]
end

-- Calculate equivalent mana potions saved
local function getManaPotsEquivalent(manaAmount)
  local MAJOR_MANA_POT = 1800  -- Major Mana Potion average restore
  return math.floor((manaAmount or 0) / MAJOR_MANA_POT)
end

-- Check and award achievements
local function checkAchievements()
  local session = HolyCreditTrackerDB.session
  local achievements = HolyCreditTrackerDB.achievements
  
  for _, milestone in ipairs(MILESTONES) do
    local key = "refund_" .. milestone.refund
    if session.refund >= milestone.refund and not achievements[key] then
      achievements[key] = GetTime()
      
      -- Show achievement popup
      if HolyCreditTrackerDB.settings.showAchievements then
        UIErrorsFrame:AddMessage(milestone.icon .. " Achievement: " .. milestone.name .. "!", 1, 0.84, 0, 1.0)
        if HolyCreditTrackerDB.settings.soundEnabled then
          PlaySound(888) -- Level up sound
        end
      end
    end
  end
  
  -- Check personal bests
  local pb = HolyCreditTrackerDB.personalBests
  local efficiency = getEfficiencyPercent(session)
  
  if efficiency > pb.bestEfficiency then
    pb.bestEfficiency = efficiency
    if efficiency > 10 then -- Only announce significant efficiency
      print("|cFF00FF96HCT:|r New efficiency record: " .. string.format("%.1f%%", efficiency))
    end
  end
  
  if HolyCreditTrackerDB.combat.healing > pb.bestHealingCombat then
    pb.bestHealingCombat = HolyCreditTrackerDB.combat.healing
  end
end

-- Track raid-specific stats
local function updateRaidStats()
  local zone = GetRealZoneText()
  if not RAID_ZONES[zone] then return end
  
  if not HolyCreditTrackerDB.raidStats[zone] then
    HolyCreditTrackerDB.raidStats[zone] = {
      healing = 0, refund = 0, spent = 0, crits = 0, heals = 0,
      visits = 0, lastVisit = 0
    }
  end
  
  local raid = HolyCreditTrackerDB.raidStats[zone]
  local combat = HolyCreditTrackerDB.combat
  
  -- Update raid stats with combat data
  raid.healing = raid.healing + (combat.healing or 0)
  raid.refund = raid.refund + (combat.refund or 0)
  raid.spent = raid.spent + (combat.spent or 0)
  raid.crits = raid.crits + (combat.crits or 0)
  raid.heals = raid.heals + (combat.heals or 0)
end

local function updateUI()
  if not ui then return end
  local now  = HolyCreditTrackerDB.combat
  local sess = HolyCreditTrackerDB.session

  local function cnum(n, posHex, negHex)
    if (n or 0) >= 0 then return colorText(posHex, fmt(n)) else return colorText(negHex, fmt(n)) end
  end

  text.nowHealing:SetText( fmt(now.healing) )
  text.sessHealing:SetText( fmt(sess.healing) )

  text.nowRefund:SetText( colorText("00ff96", fmt(now.refund)) )
  text.sessRefund:SetText( colorText("00ff96", fmt(sess.refund)) )

  text.nowSpent:SetText( colorText("ff6464", fmt(now.spent)) )
  text.sessSpent:SetText( colorText("ff6464", fmt(sess.spent)) )

  text.nowNet:SetText( cnum(net(now), "00ff00", "ff3333") )
  text.sessNet:SetText( cnum(net(sess), "00ff00", "ff3333") )

  text.nowCrits:SetText( tostring(now.crits or 0) )
  text.sessCrits:SetText( tostring(sess.crits or 0) )

  local critP = getHolyCritChancePercent(HolyCreditTrackerDB)
  local castsToCrit = (critP > 0) and (1 / (critP / 100)) or 0
  local timeToCrit  = castsToCrit * (avgCastMS / 1000)
  text.nowPred:SetText( string.format("%.1f / %.1fs", castsToCrit, timeToCrit) )
  text.sessPred:SetText( string.format("%.1f / %.1fs", castsToCrit, timeToCrit) )
  
  -- Update new gamification elements
  local nowEff = getEfficiencyPercent(now)
  local sessEff = getEfficiencyPercent(sess)
  local nowGrade = getEfficiencyGrade(nowEff)
  local sessGrade = getEfficiencyGrade(sessEff)
  
  text.nowEfficiency:SetText(colorText(nowGrade.color, string.format("%s (%.1f%%)", nowGrade.grade, nowEff)))
  text.sessEfficiency:SetText(colorText(sessGrade.color, string.format("%s (%.1f%%)", sessGrade.grade, sessEff)))
  
  -- Update mana pots equivalent
  local nowPots = getManaPotsEquivalent(now.refund)
  local sessPots = getManaPotsEquivalent(sess.refund)
  text.nowPots:SetText(colorText("00BFFF", tostring(nowPots)))
  text.sessPots:SetText(colorText("00BFFF", tostring(sessPots)))
  
  -- Update progress bar
  if ui.progressBar then
    local targetEff = 30 -- Target A grade
    local progress = math.min(sessEff / targetEff, 1.0)
    ui.progressBar:SetValue(progress)
    
    -- Color based on grade
    local r, g, b = 1, 0, 0
    if sessGrade.grade == "S" then r, g, b = 1, 0.84, 0
    elseif sessGrade.grade == "A" then r, g, b = 0, 1, 0
    elseif sessGrade.grade == "B" then r, g, b = 0, 0.75, 1
    elseif sessGrade.grade == "C" then r, g, b = 1, 1, 0
    end
    ui.progressBar:SetStatusBarColor(r, g, b, 0.8)
  end
  
  -- Check achievements
  checkAchievements()
  
  -- Update alpha based on lock state and settings
  if HolyCreditTrackerDB.locked and HolyCreditTrackerDB.fadeEnabled then
    ui:SetAlpha(HolyCreditTrackerDB.fadeAlpha)
  else
    ui:SetAlpha(HolyCreditTrackerDB.alpha)
  end
end

local function buildUI()
  if ui then return end
  local pos   = HolyCreditTrackerDB.position or defaults.position
  local scale = HolyCreditTrackerDB.scale or 0.9
  local alpha = HolyCreditTrackerDB.alpha or 0.8

  ui = CreateFrame("Frame", "HCT_Main", UIParent, "BackdropTemplate")
  ui:SetSize(320, 200)
  ui:SetScale(scale)
  ui:SetAlpha(alpha)  -- Apply saved alpha
  ui:SetPoint(unpack(pos))
  ui:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false, tileSize = 16, edgeSize = 12,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  ui:SetBackdropColor(0,0,0,0.8)
  ui:SetMovable(true)
  ui:EnableMouse(not HolyCreditTrackerDB.locked)  -- Disable mouse when locked
  ui:RegisterForDrag("LeftButton")
  
  -- Enhanced drag and lock behavior with proper position saving
  ui:SetScript("OnDragStart", function(self)
    if not HolyCreditTrackerDB.locked then 
      self:StartMoving()
      self:SetAlpha(1.0) -- Full opacity while dragging
    end
  end)
  ui:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save all position data properly
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
    HolyCreditTrackerDB.position = {
      point,
      relativeTo and relativeTo:GetName() or "UIParent",
      relativePoint,
      xOfs,
      yOfs
    }
    self:SetAlpha(HolyCreditTrackerDB.alpha) -- Restore alpha
  end)
  
  -- Add mouse enter/leave for fade effect
  ui:SetScript("OnEnter", function(self)
    if HolyCreditTrackerDB.fadeEnabled then
      self:SetAlpha(HolyCreditTrackerDB.alpha)
    end
    
    -- Show lock indicator
    if HolyCreditTrackerDB.locked then
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
      GameTooltip:AddLine("HolyCreditTracker [LOCKED]", 1, 0.5, 0.5)
      GameTooltip:AddLine("Type /hct unlock to enable interaction", 0.7, 0.7, 0.7)
      GameTooltip:Show()
    else
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
      GameTooltip:AddLine("HolyCreditTracker", 1,1,1)
      GameTooltip:AddLine("Left-drag to move. Right-click for options.", .9,.9,.9)
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Efficiency Grades:", 1, 0.84, 0)
      GameTooltip:AddLine("S: >40% (Legendary)", 1, 0.84, 0)
      GameTooltip:AddLine("A: >30% (Excellent)", 0, 1, 0)
      GameTooltip:AddLine("B: >20% (Good)", 0, 0.75, 1)
      GameTooltip:AddLine("C: >10% (Average)", 1, 1, 0)
      GameTooltip:AddLine("D: <10% (Keep trying)", 1, 0.42, 0.42)
      GameTooltip:AddLine(" ")
      
      -- Show achievements
      local achieved = 0
      for _, milestone in ipairs(MILESTONES) do
        local key = "refund_" .. milestone.refund
        if HolyCreditTrackerDB.achievements[key] then
          achieved = achieved + 1
        end
      end
      GameTooltip:AddLine(string.format("Achievements: %d/%d", achieved, #MILESTONES), 0.7, 0.7, 1)
      
      -- Show personal best
      local pb = HolyCreditTrackerDB.personalBests
      if pb.bestEfficiency > 0 then
        GameTooltip:AddLine(string.format("Best Efficiency: %.1f%%", pb.bestEfficiency), 0.7, 1, 0.7)
      end
      
      GameTooltip:AddLine("/hct toggle | lock | unlock | alpha <0.3-1.0> | fade", .7,.7,1)
      GameTooltip:Show()
    end
  end)
  
  ui:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
    if HolyCreditTrackerDB.fadeEnabled and HolyCreditTrackerDB.locked then
      self:SetAlpha(HolyCreditTrackerDB.fadeAlpha)
    end
  end)
  
  -- Create dropdown menu frame immediately after creating main UI
  local dropDown = CreateFrame("Frame", "HCT_DropDown", ui, "UIDropDownMenuTemplate")
  
  -- Initialize dropdown menu with proper menu structure
  local function InitializeDropdown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    if level == 1 then
      -- Title
      info.text = "HolyCreditTracker"
      info.isTitle = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, level)
      
      -- Lock/Unlock
      info = UIDropDownMenu_CreateInfo()
      info.text = HolyCreditTrackerDB.locked and "Unlock Window" or "Lock Window"
      info.notCheckable = true
      info.func = function() 
        HolyCreditTrackerDB.locked = not HolyCreditTrackerDB.locked
        ui:EnableMouse(not HolyCreditTrackerDB.locked)
        print("|cFF00FF96HCT:|r Frame " .. (HolyCreditTrackerDB.locked and "locked" or "unlocked"))
        updateUI()
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, level)
      
      -- Transparency submenu
      info = UIDropDownMenu_CreateInfo()
      info.text = "Transparency"
      info.notCheckable = true
      info.hasArrow = true
      info.menuList = "transparency"
      UIDropDownMenu_AddButton(info, level)
      
      -- Toggle fade
      info = UIDropDownMenu_CreateInfo()
      info.text = HolyCreditTrackerDB.fadeEnabled and "Disable Fade" or "Enable Fade"
      info.notCheckable = true
      info.func = function() 
        HolyCreditTrackerDB.fadeEnabled = not HolyCreditTrackerDB.fadeEnabled
        updateUI()
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, level)
      
      -- Toggle sounds
      info = UIDropDownMenu_CreateInfo()
      info.text = HolyCreditTrackerDB.settings.soundEnabled and "Disable Sounds" or "Enable Sounds"
      info.notCheckable = true
      info.func = function() 
        HolyCreditTrackerDB.settings.soundEnabled = not HolyCreditTrackerDB.settings.soundEnabled
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, level)
      
      -- Separator
      info = UIDropDownMenu_CreateInfo()
      info.disabled = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, level)
      
      -- Reset options
      info = UIDropDownMenu_CreateInfo()
      info.text = "Reset Combat"
      info.notCheckable = true
      info.func = function()
        HolyCreditTrackerDB.combat = deepcopy(defaults.combat)
        updateUI()
        print("|cFF00FF96HCT:|r Combat stats reset.")
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, level)
      
      info = UIDropDownMenu_CreateInfo()
      info.text = "Reset Session"
      info.notCheckable = true
      info.func = function()
        HolyCreditTrackerDB.session = deepcopy(defaults.session)
        updateUI()
        print("|cFF00FF96HCT:|r Session stats reset.")
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, level)
      
    elseif level == 2 then
      if menuList == "transparency" then
        -- Transparency submenu
        info.text = "Transparency"
        info.isTitle = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
        
        local alphaValues = {1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3}
        for _, alpha in ipairs(alphaValues) do
          info = UIDropDownMenu_CreateInfo()
          info.text = string.format("%d%%", alpha * 100)
          info.checked = math.abs((HolyCreditTrackerDB.alpha or 0.8) - alpha) < 0.01
          info.func = function()
            HolyCreditTrackerDB.alpha = alpha
            ui:SetAlpha(alpha)
            print(string.format("|cFF00FF96HCT:|r Transparency set to %d%%", alpha * 100))
            CloseDropDownMenus()
          end
          UIDropDownMenu_AddButton(info, level)
        end
      end
    end
  end
  
  UIDropDownMenu_Initialize(dropDown, InitializeDropdown, "MENU")
  
  -- Right-click handler for main frame
  ui:SetScript("OnMouseUp", function(self, btn)
    if btn == "RightButton" and not HolyCreditTrackerDB.locked then
      -- Toggle the dropdown menu at cursor position
      local x, y = GetCursorPosition()
      local scale = UIParent:GetEffectiveScale()
      ToggleDropDownMenu(1, nil, dropDown, "cursor", 0, 0)
    end
  end)
  
  local title = ui:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  title:SetPoint("TOP", 0, -6)
  title:SetText("|cFF00FF96Holy Credit Tracker|r")
  
  -- Add progress bar for efficiency
  local progressBar = CreateFrame("StatusBar", nil, ui)
  progressBar:SetSize(280, 12)
  progressBar:SetPoint("TOP", title, "BOTTOM", 0, -4)
  progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  progressBar:SetMinMaxValues(0, 1)
  progressBar:SetValue(0)
  progressBar:SetStatusBarColor(0, 1, 0, 0.8)
  
  local progressBg = progressBar:CreateTexture(nil, "BACKGROUND")
  progressBg:SetAllPoints()
  progressBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
  progressBg:SetVertexColor(0.2, 0.2, 0.2, 0.5)
  
  ui.progressBar = progressBar

  ui:SetScript("OnEnter", function(self)
    if HolyCreditTrackerDB.fadeEnabled then
      self:SetAlpha(HolyCreditTrackerDB.alpha)
    end
    
    -- Show lock indicator
    if HolyCreditTrackerDB.locked then
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
      GameTooltip:AddLine("HolyCreditTracker [LOCKED]", 1, 0.5, 0.5)
      GameTooltip:AddLine("Type /hct unlock to enable interaction", 0.7, 0.7, 0.7)
      GameTooltip:Show()
    else
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
      GameTooltip:AddLine("HolyCreditTracker", 1,1,1)
      GameTooltip:AddLine("Left-drag to move. Right-click for options.", .9,.9,.9)
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Efficiency Grades:", 1, 0.84, 0)
      GameTooltip:AddLine("S: >40% (Legendary)", 1, 0.84, 0)
      GameTooltip:AddLine("A: >30% (Excellent)", 0, 1, 0)
      GameTooltip:AddLine("B: >20% (Good)", 0, 0.75, 1)
      GameTooltip:AddLine("C: >10% (Average)", 1, 1, 0)
      GameTooltip:AddLine("D: <10% (Keep trying)", 1, 0.42, 0.42)
      GameTooltip:AddLine(" ")
      
      -- Show achievements
      local achieved = 0
      for _, milestone in ipairs(MILESTONES) do
        local key = "refund_" .. milestone.refund
        if HolyCreditTrackerDB.achievements[key] then
          achieved = achieved + 1
        end
      end
      GameTooltip:AddLine(string.format("Achievements: %d/%d", achieved, #MILESTONES), 0.7, 0.7, 1)
      
      -- Show personal best
      local pb = HolyCreditTrackerDB.personalBests
      if pb.bestEfficiency > 0 then
        GameTooltip:AddLine(string.format("Best Efficiency: %.1f%%", pb.bestEfficiency), 0.7, 1, 0.7)
      end
      
      GameTooltip:AddLine("/hct toggle | lock | unlock | alpha <0.3-1.0> | fade", .7,.7,1)
      GameTooltip:Show()
    end
  end)
  ui:SetScript("OnLeave", function() GameTooltip:Hide() end)

  local hNow  = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  local hSess = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  hNow:SetPoint("TOPLEFT", 110, -35); hNow:SetText("Now")
  hSess:SetPoint("LEFT", hNow, "RIGHT", 100, 0); hSess:SetText("Session")

  local rows = {
    {"Effective Healing", "nowHealing", "sessHealing"},
    {"Illumination Refund", "nowRefund", "sessRefund"},
    {"Mana Spent", "nowSpent", "sessSpent"},
    {"Net Mana (R−S)", "nowNet", "sessNet"},
    {"Efficiency Grade", "nowEfficiency", "sessEfficiency"},  -- New row
    {"≈ Major Mana Pots", "nowPots", "sessPots"},            -- New row
    {"Crits", "nowCrits", "sessCrits"},
    {"Casts / Time→Crit", "nowPred", "sessPred"},
  }

  local y = -50
  for _, r in ipairs(rows) do
    local label = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", 10, y)
    label:SetText(r[1])

    local nowFS = ui:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nowFS:SetPoint("TOPLEFT", 110, y)
    nowFS:SetText("0")

    local sesFS = ui:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sesFS:SetPoint("TOPLEFT", 210, y)
    sesFS:SetText("0")

    text[r[2]] = nowFS
    text[r[3]] = sesFS

    y = y - 16
  end

  updateUI()
end

------------------------------------------------------------------------
-- Stat helpers
------------------------------------------------------------------------
local function bump(scope, field, amt) scope[field] = (scope[field] or 0) + (amt or 0) end
local function addAll(field, amt)
  bump(HolyCreditTrackerDB.combat, field, amt)
  bump(HolyCreditTrackerDB.session, field, amt)
  bump(HolyCreditTrackerDB.allTime, field, amt)
end

-- Heals landed → effective healing + crit count + observed rate base
local function onHealEvent(spellID, spellName, amount, overheal, critical)
  if not HEALING_SPELLS[spellName] then return end
  local eff = (amount or 0) - (overheal or 0)
  if eff > 0 then addAll("healing", eff) end
  addAll("heals", 1)
  if critical then addAll("crits", 1) end
  updateUI()
end

-- Illumination refunds (read actual mana from CLEU)
local function onEnergize(spellID, spellName, amount, powerType, srcGUID, dstGUID)
  if powerType ~= 0 then return end -- only mana
  local me = UnitGUID("player")
  if dstGUID ~= me or srcGUID ~= me then return end
  if spellName ~= "Illumination" then return end -- avoid Wisdom, JoW, etc.
  if amount and amount > 0 then addAll("refund", amount); updateUI() end
end

-- UNIT_SPELLCAST_START → record start time (for cast-time measurement only)
local function onUnitCastStart(unit, castGUID, spellID)
  if unit ~= "player" then return end
  local name = GetSpellInfo(spellID)
  if not name or not HEALING_SPELLS[name] then return end
  castStartAt[castGUID] = GetTime()
end

-- UNIT_SPELLCAST_SUCCEEDED → charge mana cost, update cast-time average
local function onUnitCastSucceeded(unit, castGUID, spellID)
  if unit ~= "player" then return end
  local name = GetSpellInfo(spellID)
  if not name or not HEALING_SPELLS[name] then return end

  -- Charge mana on success only
  local cost = baseManaCost(spellID, name) or 0
  if cost > 0 then addAll("spent", cost) end

  -- Update observed cast time
  local startT = castStartAt[castGUID]
  if startT then
    updateAvgCast( (GetTime() - startT) * 1000 )
    castStartAt[castGUID] = nil
  else
    -- fallback to static cast time if we missed START
    local _, _, _, castMS = GetSpellInfo(spellID)
    updateAvgCast(castMS)
  end

  updateUI()
end

------------------------------------------------------------------------
-- Event driver
------------------------------------------------------------------------
HCT:RegisterEvent("ADDON_LOADED")
HCT:RegisterEvent("PLAYER_LOGIN")
HCT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
HCT:RegisterEvent("PLAYER_REGEN_DISABLED")
HCT:RegisterEvent("PLAYER_REGEN_ENABLED")
HCT:RegisterEvent("PLAYER_LOGOUT")
HCT:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
HCT:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
HCT:RegisterEvent("ZONE_CHANGED_NEW_AREA")

HCT:SetScript("OnEvent", function(self, evt, ...)
  if evt == "ADDON_LOADED" and ... == ADDON_NAME then
    HolyCreditTrackerDB = mergeDefaults(HolyCreditTrackerDB, defaults)

  elseif evt == "PLAYER_LOGIN" then
    buildUI()
    print("|cFF00FF96HolyCreditTracker:|r Loaded. /hct for help.")
    
    -- Show welcome message with current achievement status
    local achieved = 0
    for _, milestone in ipairs(MILESTONES) do
      if HolyCreditTrackerDB.achievements["refund_" .. milestone.refund] then
        achieved = achieved + 1
      end
    end
    if achieved > 0 then
      print(string.format("|cFF00FF96HCT:|r Achievements: %d/%d unlocked", achieved, #MILESTONES))
    end

  elseif evt == "COMBAT_LOG_EVENT_UNFILTERED" then
    -- ...existing code...
    local info = { CombatLogGetCurrentEventInfo() }
    local sub      = info[2]
    local srcGUID  = info[4]
    local dstGUID  = info[8]
    local spellID  = info[12]
    local spellName= info[13]

    if sub == "SPELL_HEAL" or sub == "SPELL_PERIODIC_HEAL" then
      if srcGUID == UnitGUID("player") then
        local amount   = info[15]
        local overheal = info[16]
        local critical = info[18]
        onHealEvent(spellID, spellName, amount, overheal, critical)
      end

    elseif sub == "SPELL_ENERGIZE" then
      local amount    = info[15]
      local powerType = info[16]
      onEnergize(spellID, spellName, amount, powerType, srcGUID, dstGUID)
    end

  elseif evt == "PLAYER_REGEN_DISABLED" then
    HolyCreditTrackerDB.combat = deepcopy(defaults.combat)
    HolyCreditTrackerDB.combat.inCombat = true
    HolyCreditTrackerDB.combat.startTime = GetTime()
    updateUI()

  elseif evt == "PLAYER_REGEN_ENABLED" then
    HolyCreditTrackerDB.combat.inCombat = false
    
    -- Update raid stats when combat ends
    updateRaidStats()
    
    -- Show combat summary if significant
    local combat = HolyCreditTrackerDB.combat
    if combat.refund > 100 then
      local eff = getEfficiencyPercent(combat)
      local grade = getEfficiencyGrade(eff)
      local pots = getManaPotsEquivalent(combat.refund)
      
      print(string.format("|cFF00FF96HCT Combat:|r Grade %s (%.1f%%) - Saved %d pots worth of mana!", 
        grade.grade, eff, pots))
    end
    
    updateUI()

  elseif evt == "UNIT_SPELLCAST_START" then
    onUnitCastStart(...)

  elseif evt == "UNIT_SPELLCAST_SUCCEEDED" then
    onUnitCastSucceeded(...)
    
  elseif evt == "ZONE_CHANGED_NEW_AREA" then
    -- Track raid visits
    local zone = GetRealZoneText()
    if RAID_ZONES[zone] and HolyCreditTrackerDB.raidStats[zone] then
      HolyCreditTrackerDB.raidStats[zone].visits = (HolyCreditTrackerDB.raidStats[zone].visits or 0) + 1
      HolyCreditTrackerDB.raidStats[zone].lastVisit = GetTime()
    end

  elseif evt == "PLAYER_LOGOUT" then
    -- SavedVariables auto-written
  end
end)

------------------------------------------------------------------------
-- Slash commands
------------------------------------------------------------------------
SLASH_HCT1 = "/hct"
SlashCmdList["HCT"] = function(msg)
  msg = (msg or ""):lower()

  if msg == "toggle" then
    if ui and ui:IsShown() then ui:Hide() else if not ui then buildUI() end ui:Show() end

  elseif msg == "lock" then
    HolyCreditTrackerDB.locked = true
    if ui then ui:EnableMouse(false) end
    print("|cFF00FF96HCT:|r Frame locked (click-through enabled)")
    updateUI()

  elseif msg == "unlock" then
    HolyCreditTrackerDB.locked = false
    if ui then ui:EnableMouse(true) end
    print("|cFF00FF96HCT:|r Frame unlocked (interaction enabled)")
    updateUI()
    
  elseif msg:match("^alpha%s+[%d%.]+$") then
    local alpha = tonumber(msg:match("alpha%s+([%d%.]+)"))
    if alpha and alpha >= 0.3 and alpha <= 1.0 then
      HolyCreditTrackerDB.alpha = alpha
      if ui then ui:SetAlpha(alpha) end
      print(string.format("|cFF00FF96HCT:|r Alpha set to %.1f", alpha))
    else
      print("|cFF00FF96HCT:|r Alpha must be between 0.3 and 1.0")
    end
    
  elseif msg == "fade" then
    HolyCreditTrackerDB.fadeEnabled = not HolyCreditTrackerDB.fadeEnabled
    print("|cFF00FF96HCT:|r Fade " .. (HolyCreditTrackerDB.fadeEnabled and "enabled" or "disabled"))
    updateUI()
    
  elseif msg == "stats" or msg == "achievements" then
    -- Show detailed statistics and achievements
    print("|cFF00FF96HolyCreditTracker Statistics|r")
    print("Session Efficiency: " .. string.format("%.1f%%", getEfficiencyPercent(HolyCreditTrackerDB.session)))
    print("Mana Pots Saved: " .. getManaPotsEquivalent(HolyCreditTrackerDB.session.refund))
    print("Personal Best Efficiency: " .. string.format("%.1f%%", HolyCreditTrackerDB.personalBests.bestEfficiency))
    
    print("|cFF00FF96Achievements:|r")
    for _, milestone in ipairs(MILESTONES) do
      local key = "refund_" .. milestone.refund
      local status = HolyCreditTrackerDB.achievements[key] and "✓" or "✗"
      print(string.format("  %s %s %s - %s mana refunded", status, milestone.icon, milestone.name, fmt(milestone.refund)))
    end

  elseif msg == "reset combat" then
    HolyCreditTrackerDB.combat = deepcopy(defaults.combat); updateUI(); print("HCT: combat stats reset.")

  elseif msg == "reset session" then
    HolyCreditTrackerDB.session = deepcopy(defaults.session); updateUI(); print("HCT: session stats reset.")

  elseif msg == "reset all-time" or msg == "reset all" then
    HolyCreditTrackerDB.allTime = deepcopy(defaults.allTime); updateUI(); print("HCT: all-time stats reset.")
    
  elseif msg == "reset achievements" then
    HolyCreditTrackerDB.achievements = {}
    HolyCreditTrackerDB.personalBests = deepcopy(defaults.personalBests)
    print("HCT: achievements and personal bests reset.")

  else
    print("|cFF00FF96HolyCreditTracker Commands|r")
    print("/hct toggle  - show/hide window")
    print("/hct stats   - show detailed statistics")
    print("/hct lock    - lock window (click-through)")
    print("/hct unlock  - unlock window")
    print("/hct alpha <0.3-1.0> - set transparency")
    print("/hct fade    - toggle fade when not hovering")
    print("/hct reset combat   - reset current fight")
    print("/hct reset session  - reset session")
    print("/hct reset all-time - reset all-time")
    print("/hct reset achievements - reset achievements")
  end
end