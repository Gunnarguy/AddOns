-------------------------------------------------------------------------------
-- ExtraAttacksTracker.lua  ·  v2.0 LOTTERY EDITION  (Classic 1.15.7)
-- The RNG Casino: Every proc is a jackpot! Track your luck and beat the odds!
-------------------------------------------------------------------------------
local ADDON, _ = ...

-------------------------------------------------------------------------------
-- 0.  SavedVariables & defaults
-------------------------------------------------------------------------------
EAT_DB = EAT_DB or {}
local defaults = {
  locked      = false,
  scale       = 0.85,
  alpha       = 0.9,
  fadeAlpha   = 0.5,
  fadeEnabled = false,
  position    = {"CENTER","UIParent","CENTER",0,0},
  autoReset   = true,

  -- persistent counters
  allTime = {
    flurry = 0, flurryProcs = 0, flurrySwings = 0,
    hoj    = 0, hojProcs    = 0,
    icw    = 0, icwProcs    = 0,
    reck   = 0,
    ironfoe = 0, ironfoeProcs = 0,  -- Added Ironfoe tracking
    parry  = 0, parrySwings = 0, parryExtra = 0,
  },
  
  -- Gamification data
  achievements = {},
  luckStats = {
    bestStreak = 0,
    worstDryStreak = 0,
    jackpots = 0,  -- Multi-proc events
    nearMisses = 0,
  },
  personalBests = {
    bestProcRate = 0,
    mostProcsMinute = 0,
    bestLuckRating = 0,
  },
  settings = {
    soundEnabled = true,
    showAlerts = true,
    particlesEnabled = true,
  },
  _seen = {},
}

-------------------------------------------------------------------------------
-- 1.  Local state + Gamification
-------------------------------------------------------------------------------
local s = {  -- session scope
  flurry=0, flurryProcs=0, flurrySwings=0,
  hoj=0,    hojProcs=0,
  icw=0,    icwProcs=0,
  reck=0,
  ironfoe=0, ironfoeProcs=0,  -- Added Ironfoe
  parry=0,  parrySwings=0, parryExtra=0,
  
  -- Luck tracking
  currentStreak = 0,
  dryStreak = 0,
  lastProcTime = 0,
  sessionStart = GetTime(),
  totalProcs = 0,
}

local c = {  -- combat scope
  flurry=0, flurryProcs=0, flurrySwings=0,
  hoj=0,    hojProcs=0,
  icw=0,    icwProcs=0,
  reck=0,
  ironfoe=0, ironfoeProcs=0,  -- Added Ironfoe
  parry=0,  parrySwings=0, parryExtra=0,
  
  -- Combat luck
  combatStreak = 0,
  combatStart = 0,
  expectedProcs = 0,
  actualProcs = 0,
}

-- Swing tracking
local lastSwingStart, lastSwingEnd, lastMainSpeed = 0,0,0
local swingsSinceProc = 0

-- Proc deduplication tracking
local lastProcEvent = {
  time = 0,
  spellID = 0,
  amount = 0,
  eventID = 0  -- Track unique combat log event
}
local eventCounter = 0  -- Increments for each combat log event

-------------------------------------------------------------------------------
-- 2.  Spell keys & Constants
-------------------------------------------------------------------------------
local ID = {
  FLURRY_AXE      = 18797,
  HOJ_IDS         = { [15600]=true },
  RECK_IDS        = { [20178]=true },
  COUNTERWEIGHT   = 12644,
  IRONFOE         = 15494,  -- Fury of the Forgewright spell ID
}

local NAME = {
  FLURRY_AXE      = "Flurry Axe",
  HAND_OF_JUSTICE = "Hand of Justice",
  RECKONING       = "Reckoning",
  COUNTERWEIGHT   = "Counterweight",
  FURY_FORGEWRIGHT = "Fury of the Forgewright",  -- Ironfoe proc name
}

-- Theoretical proc rates for luck calculation
local PROC_RATES = {
  flurry = 0.04,  -- ~4% per swing
  hoj = 0.02,     -- ~2% per swing
  icw = 0.04,     -- ~4% when it procs
  ironfoe = 0.04, -- ~4% per swing for Ironfoe
}

-- Luck rating thresholds
local LUCK_GRADES = {
  {threshold = 150, grade = "🎰 JACKPOT!", color = "FFD700"},     -- >150% expected
  {threshold = 120, grade = "🍀 Blessed", color = "00FF00"},      -- >120%
  {threshold = 100, grade = "📊 Average", color = "00BFFF"},      -- 100%
  {threshold = 80,  grade = "💔 Unlucky", color = "FFFF00"},      -- >80%
  {threshold = 0,   grade = "☠️ Cursed", color = "FF6B6B"},       -- <80%
}

-- Achievement definitions
local ACHIEVEMENTS = {
  {type = "streak", value = 3,  name = "Hat Trick",      icon = "🎩", desc = "3 procs in a row"},
  {type = "streak", value = 5,  name = "On Fire!",       icon = "🔥", desc = "5 procs in a row"},
  {type = "streak", value = 10, name = "RNG God",        icon = "👑", desc = "10 procs in a row"},
  {type = "total",  value = 100, name = "Centurion",     icon = "💯", desc = "100 total procs"},
  {type = "total",  value = 500, name = "Proc Master",   icon = "⚔️", desc = "500 total procs"},
  {type = "total",  value = 1000, name = "Lucky Legend", icon = "🌟", desc = "1000 total procs"},
  {type = "luck",   value = 150, name = "Golden Horseshoe", icon = "🐴", desc = "150% luck rating"},
}

-------------------------------------------------------------------------------
-- 3.  Helpers
-------------------------------------------------------------------------------
local function mergeDefaults(t, d)
  for k, v in pairs(d) do
    if type(v) == "table" then
      t[k] = mergeDefaults(t[k] or {}, v)
    else
      if t[k] == nil then t[k] = v end
    end
  end
  return t
end

local function wipeTable(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      wipeTable(v)
    else
      t[k] = (type(v) == "number") and 0 or nil
    end
  end
end

-- Format helpers
local function fmt(n) return BreakUpLargeNumbers and BreakUpLargeNumbers(n) or tostring(n) end
local function pct(a,b) return (b and b>0) and (a/b*100) or 0 end
local function colorText(hex, text) return "|cff"..hex..tostring(text).."|r" end

-- Spell detection
local function isHoJ(id, name)   return ID.HOJ_IDS[id] or name == NAME.HAND_OF_JUSTICE end
local function isReck(id, name)  return ID.RECK_IDS[id] or name == NAME.RECKONING end
local function isFlurry(id,name) return id == ID.FLURRY_AXE or name == NAME.FLURRY_AXE end
local function isCounterweight(id,name) return id == ID.COUNTERWEIGHT or name == NAME.COUNTERWEIGHT end
local function isIronfoe(id,name) return id == ID.IRONFOE or name == NAME.FURY_FORGEWRIGHT end  -- Added Ironfoe detection

-- Calculate luck rating (actual vs expected)
local function getLuckRating()
  local expectedFlurry = s.flurrySwings * PROC_RATES.flurry
  local expectedHoj = s.flurrySwings * PROC_RATES.hoj  -- HoJ procs on any swing
  local expectedIronfoe = s.flurrySwings * PROC_RATES.ironfoe  -- Ironfoe procs on swing
  local expected = expectedFlurry + expectedHoj + expectedIronfoe
  
  if expected <= 0 then return 100 end
  
  local actual = s.flurryProcs + s.hojProcs + s.ironfoeProcs
  return (actual / expected) * 100
end

-- Get luck grade
local function getLuckGrade(rating)
  for _, grade in ipairs(LUCK_GRADES) do
    if rating >= grade.threshold then
      return grade
    end
  end
  return LUCK_GRADES[#LUCK_GRADES]
end

-- Check achievements
local function checkAchievements(achievementType, value)
  for _, ach in ipairs(ACHIEVEMENTS) do
    local key = ach.type .. "_" .. ach.value
    if ach.type == achievementType and value >= ach.value and not EAT_DB.achievements[key] then
      EAT_DB.achievements[key] = GetTime()
      
      if EAT_DB.settings.showAlerts then
        UIErrorsFrame:AddMessage(ach.icon .. " Achievement: " .. ach.name .. "!", 1, 0.84, 0, 1.0)
        if EAT_DB.settings.soundEnabled then
          PlaySound(888) -- Level up sound
        end
      end
    end
  end
end

-- Proc celebration (jackpot alerts)
local function celebrateProc(procType, extraAttacks)
  -- Update streaks
  s.currentStreak = s.currentStreak + 1
  s.dryStreak = 0
  swingsSinceProc = 0
  s.lastProcTime = GetTime()
  s.totalProcs = s.totalProcs + 1
  
  c.combatStreak = c.combatStreak + 1
  c.actualProcs = c.actualProcs + 1
  
  -- Check streak achievements
  checkAchievements("streak", s.currentStreak)
  checkAchievements("total", s.totalProcs)
  
  -- Update personal bests
  if s.currentStreak > EAT_DB.luckStats.bestStreak then
    EAT_DB.luckStats.bestStreak = s.currentStreak
    if s.currentStreak >= 5 then
      print(colorText("FFD700", "🎰 NEW STREAK RECORD: " .. s.currentStreak .. " procs in a row!"))
    end
  end
  
  -- Jackpot alerts for multiple extra attacks
  if extraAttacks and extraAttacks > 1 then
    EAT_DB.luckStats.jackpots = (EAT_DB.luckStats.jackpots or 0) + 1
    if EAT_DB.settings.showAlerts then
      UIErrorsFrame:AddMessage("💰 JACKPOT! " .. extraAttacks .. " extra attacks!", 1, 0.84, 0, 1.0)
      if EAT_DB.settings.soundEnabled then
        PlaySound(8959) -- Auction house bell
      end
    end
  end
  
  -- Lucky streak bonus notification
  if s.currentStreak >= 3 then
    local streakBonus = string.format("🔥 %dx STREAK!", s.currentStreak)
    UIErrorsFrame:AddMessage(streakBonus, 1, 0.5, 0, 1.0)
  end
end

-------------------------------------------------------------------------------
-- 4.  Enhanced UI with gamification
-------------------------------------------------------------------------------
local f = CreateFrame("Frame","EAT_MainFrame",UIParent,"BackdropTemplate")
f:SetSize(185, 285)  -- Increased height to fit Ironfoe
f:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = false, edgeSize = 12,
  insets = {left = 4, right = 4, top = 4, bottom = 4}
})
f:SetBackdropColor(0,0,0,0.85)
f:SetMovable(true)
f:EnableMouse(not EAT_DB.locked)
f:RegisterForDrag("LeftButton")
f:SetAlpha(EAT_DB.alpha or 0.9)

-- Drag handlers
f:SetScript("OnDragStart",function(self) 
  if not EAT_DB.locked then 
    self:StartMoving()
    self:SetAlpha(1.0)
  end 
end)
f:SetScript("OnDragStop",function(self)
  self:StopMovingOrSizing()
  EAT_DB.position={self:GetPoint()}
  self:SetAlpha(EAT_DB.alpha)
end)

-- Title with better positioning
local title = f:CreateFontString(nil,"OVERLAY","GameFontHighlight")
title:SetPoint("TOP",0,-8)
title:SetText("|cff00ff96🎰 RNG Casino|r")

-- Luck meter bar - wider and better positioned
local luckBar = CreateFrame("StatusBar", nil, f)
luckBar:SetSize(165, 10)  -- Wider bar
luckBar:SetPoint("TOP", title, "BOTTOM", 0, -6)
luckBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
luckBar:SetMinMaxValues(0, 200)  -- 0-200% luck
luckBar:SetValue(100)

local luckBg = luckBar:CreateTexture(nil, "BACKGROUND")
luckBg:SetAllPoints()
luckBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
luckBg:SetVertexColor(0.2, 0.2, 0.2, 0.5)

-- Luck percentage text on the bar
local luckText = luckBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
luckText:SetPoint("CENTER", luckBar, "CENTER", 0, 0)
luckText:SetText("100%")
f.luckText = luckText

-- Streak indicator - better positioned
local streakText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
streakText:SetPoint("TOP", luckBar, "BOTTOM", 0, -4)
streakText:SetText("")

-- Main stats text - adjusted positioning and font size
local txt = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")  -- Smaller font
txt:SetPoint("TOPLEFT",10,-55)  -- Better starting position
txt:SetJustifyH("LEFT")
txt:SetWidth(165)  -- Wider text area
txt:SetSpacing(1.5)  -- Adjusted line spacing for more content

-- Enhanced tooltip
f:SetScript("OnEnter", function(self)
  if EAT_DB.fadeEnabled then
    self:SetAlpha(EAT_DB.alpha)
  end
  
  GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
  
  if EAT_DB.locked then
    GameTooltip:AddLine("RNG Casino [LOCKED]", 1, 0.5, 0.5)
    GameTooltip:AddLine("Type /eat unlock to enable interaction", 0.7, 0.7, 0.7)
  else
    GameTooltip:AddLine("🎰 RNG Casino", 1, 1, 1)
    GameTooltip:AddLine("Extra Attacks & Proc Tracker", 0.7, 0.7, 0.7)
    GameTooltip:AddLine(" ")
    
    -- Show luck rating
    local luck = getLuckRating()
    local grade = getLuckGrade(luck)
    GameTooltip:AddLine("Luck Rating: " .. colorText(grade.color, string.format("%s (%.0f%%)", grade.grade, luck)), 1, 1, 1)
    
    -- Show best streak
    if EAT_DB.luckStats.bestStreak > 0 then
      GameTooltip:AddLine("Best Streak: " .. EAT_DB.luckStats.bestStreak .. " procs", 0.7, 1, 0.7)
    end
    
    -- Show jackpots
    if EAT_DB.luckStats.jackpots > 0 then
      GameTooltip:AddLine("Jackpots Won: " .. EAT_DB.luckStats.jackpots, 1, 0.84, 0)
    end
    
    -- Show achievements
    local achieved = 0
    for _, ach in ipairs(ACHIEVEMENTS) do
      local key = ach.type .. "_" .. ach.value
      if EAT_DB.achievements[key] then
        achieved = achieved + 1
      end
    end
    GameTooltip:AddLine(string.format("Achievements: %d/%d", achieved, #ACHIEVEMENTS), 0.7, 0.7, 1)
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-drag to move. Right-click for options.", .9,.9,.9)
    GameTooltip:AddLine("/eat help for commands", .7,.7,1)
  end
  
  GameTooltip:Show()
end)

f:SetScript("OnLeave", function(self)
  GameTooltip:Hide()
  if EAT_DB.fadeEnabled and EAT_DB.locked then
    self:SetAlpha(EAT_DB.fadeAlpha)
  end
end)

-- Right-click menu
f:SetScript("OnMouseUp", function(self, btn)
  if btn == "RightButton" and not EAT_DB.locked then
    print("|cff00ff96RNG Casino Commands:|r")
    print("/eat stats - show detailed statistics")
    print("/eat lock | unlock - lock/unlock frame")
    print("/eat alpha <0.3-1.0> - set transparency")
    print("/eat fade - toggle fade when not hovering")
    print("/eat reset combat|session|all - reset stats")
  end
end)

-- Update display function with better formatting
local function repaint()
  local A = EAT_DB.allTime
  
  -- Calculate current luck
  local luckRating = getLuckRating()
  local luckGrade = getLuckGrade(luckRating)
  
  -- Update luck bar
  luckBar:SetValue(luckRating)
  f.luckText:SetText(string.format("%.0f%%", luckRating))  -- Show percentage on bar
  
  local r, g, b = 1, 0, 0
  if luckGrade.grade:find("JACKPOT") then r, g, b = 1, 0.84, 0
  elseif luckGrade.grade:find("Blessed") then r, g, b = 0, 1, 0
  elseif luckGrade.grade:find("Average") then r, g, b = 0, 0.75, 1
  elseif luckGrade.grade:find("Unlucky") then r, g, b = 1, 1, 0
  end
  luckBar:SetStatusBarColor(r, g, b, 0.8)
  
  -- Update streak text with better formatting
  if s.currentStreak > 0 then
    streakText:SetText(colorText("FFD700", string.format("🔥 %dx Streak!", s.currentStreak)))
  elseif s.dryStreak > 10 then
    streakText:SetText(colorText("FF6B6B", string.format("💀 %d dry...", s.dryStreak)))
  else
    streakText:SetText(colorText("FFFFFF", luckGrade.grade))
  end
  
  -- Main stats with cleaner, more compact layout
  local lines = {
    colorText("00FF96", "═══ Proc Lottery ═══"),
    "",
    -- Flurry Axe with cleaner format
    colorText("00ff00", "Flurry Axe") .. " " .. colorText("999999", string.format("(%.1f%%)", pct(s.flurryProcs, s.flurrySwings))),
    string.format("  Now:%d  Sess:%d  All:%s", c.flurry, s.flurry, fmt(A.flurry)),
    "",
    -- Ironfoe
    colorText("ff8800", "Ironfoe") .. " " .. colorText("999999", string.format("(%.1f%%)", pct(s.ironfoeProcs, s.flurrySwings))),
    string.format("  Now:%d  Sess:%d  All:%s", c.ironfoe, s.ironfoe, fmt(A.ironfoe)),
    "",
    -- Hand of Justice
    colorText("ffff00", "Hand of Justice"),
    string.format("  Now:%d  Sess:%d  All:%s", c.hoj, s.hoj, fmt(A.hoj)),
    "",
    -- Reckoning
    colorText("0077ff", "Reckoning"),
    string.format("  Now:%d  Sess:%d  All:%s", c.reck, s.reck, fmt(A.reck)),
    "",
    -- Parry with combined info
    colorText("aaaaff", "Parry-Haste"),
    string.format("  Count: %d/%d  Bonus: %.1f", c.parry, s.parry, s.parryExtra),
    "",
    -- Bottom summary line
    colorText("FFD700", "─────────────"),
    string.format("Jackpots:%d  Best:%d", 
      EAT_DB.luckStats.jackpots or 0, 
      EAT_DB.luckStats.bestStreak or 0),
  }
  
  txt:SetText(table.concat(lines,"\n"))
end

-------------------------------------------------------------------------------
-- 5.  Swing-timer helpers (Parry-Haste logic)
-------------------------------------------------------------------------------
local function startSwing()
  lastMainSpeed = select(1,UnitAttackSpeed("player")) or 0
  lastSwingStart = GetTime()
  lastSwingEnd   = (lastMainSpeed>0 and (lastSwingStart + lastMainSpeed)) or 0
end

local function applyParryHaste()
  if lastSwingEnd==0 or lastMainSpeed==0 then return end
  local now       = GetTime()
  local remaining = lastSwingEnd - now
  if remaining <= 0 then return end

  local dur       = lastMainSpeed
  local floor     = 0.2 * dur
  if remaining <= floor then return end

  local cut       = 0.4 * dur
  if (remaining - cut) < floor then
    cut = remaining - floor
  end
  if cut <= 0 then return end

  lastSwingEnd = lastSwingEnd - cut

  -- Track as fraction of swing
  local frac = cut / dur
  c.parryExtra   = c.parryExtra   + frac
  s.parryExtra   = s.parryExtra   + frac
  EAT_DB.allTime.parryExtra = (EAT_DB.allTime.parryExtra or 0) + frac
end

-------------------------------------------------------------------------------
-- 6.  Event handler with gamification
-------------------------------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
events:RegisterEvent("UNIT_ATTACK_SPEED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")

events:SetScript("OnEvent",function(_,e,...)
  if e=="ADDON_LOADED" and ...==ADDON then
    mergeDefaults(EAT_DB,defaults)
    f:SetScale(EAT_DB.scale or 0.85)
    f:SetAlpha(EAT_DB.alpha or 0.9)
    f:ClearAllPoints()
    f:SetPoint(unpack(EAT_DB.position))
    f:SetShown(true)
    if EAT_DB.locked then f:EnableMouse(false) end
    repaint()

  elseif e=="PLAYER_LOGIN" then
    startSwing()
    s.sessionStart = GetTime()
    repaint()
    
    -- Welcome message
    print("|cff00ff96🎰 RNG Casino loaded!|r Roll the dice with /eat help")
    local achieved = 0
    for _, ach in ipairs(ACHIEVEMENTS) do
      local key = ach.type .. "_" .. ach.value
      if EAT_DB.achievements[key] then achieved = achieved + 1 end
    end
    if achieved > 0 then
      print(string.format("|cff00ff96RNG Casino:|r %d/%d achievements unlocked", achieved, #ACHIEVEMENTS))
    end

  elseif e=="UNIT_ATTACK_SPEED" then
    local unit=...
    if unit=="player" then startSwing() end

  elseif e=="PLAYER_REGEN_DISABLED" then
    wipeTable(c)
    c.combatStart = GetTime()
    repaint()

  elseif e=="PLAYER_REGEN_ENABLED" then
    -- Combat summary
    if c.actualProcs > 0 then
      local duration = GetTime() - c.combatStart
      local procsPerMin = (c.actualProcs / duration) * 60
      
      -- Update personal best
      if procsPerMin > EAT_DB.personalBests.mostProcsMinute then
        EAT_DB.personalBests.mostProcsMinute = procsPerMin
        print(colorText("FFD700", string.format("🏆 NEW RECORD: %.1f procs/minute!", procsPerMin)))
      end
      
      -- Show combat lottery results
      local totalExtraAttacks = c.flurry + c.hoj + c.icw + c.reck + c.ironfoe  -- Added ironfoe
      if totalExtraAttacks > 0 then
        print(string.format("|cff00ff96🎰 Combat Lottery:|r %d extra attacks won! (%.1f/min)", 
          totalExtraAttacks, (totalExtraAttacks/duration)*60))
      end
    end
    
    if EAT_DB.autoReset then wipeTable(c) end
    repaint()

  elseif e=="COMBAT_LOG_EVENT_UNFILTERED" then
    eventCounter = eventCounter + 1  -- Track unique events
    local _, sub, _, srcGUID, _, _, _, destGUID, _, _, _,
          spellID, spellName, _, amount = CombatLogGetCurrentEventInfo()

    -- Track swings
    if srcGUID==UnitGUID("player") and (sub=="SWING_DAMAGE" or sub=="SWING_MISSED") then
      c.flurrySwings = c.flurrySwings + 1
      s.flurrySwings = s.flurrySwings + 1
      EAT_DB.allTime.flurrySwings = (EAT_DB.allTime.flurrySwings or 0) + 1
      
      -- Track dry streak
      swingsSinceProc = swingsSinceProc + 1
      if swingsSinceProc > 20 then  -- Expected at least 1 proc in 20 swings
        s.dryStreak = swingsSinceProc
        if s.dryStreak > EAT_DB.luckStats.worstDryStreak then
          EAT_DB.luckStats.worstDryStreak = s.dryStreak
        end
      end
      
      startSwing()

    -- SPELL_EXTRA_ATTACKS - The lottery wins!
    elseif srcGUID==UnitGUID("player") and sub=="SPELL_EXTRA_ATTACKS" then
      local n = tonumber(amount) or 0
      
      -- Check for duplicate proc event (same spell, same amount, consecutive event)
      local isDuplicate = false
      if spellID == lastProcEvent.spellID and 
         n == lastProcEvent.amount and 
         (eventCounter - lastProcEvent.eventID) <= 1 then
        -- This looks like a duplicate event for the same proc
        isDuplicate = true
      end
      
      -- Update last proc tracking
      lastProcEvent.time = GetTime()
      lastProcEvent.spellID = spellID
      lastProcEvent.amount = n
      lastProcEvent.eventID = eventCounter

      if isFlurry(spellID, spellName) then
        if not isDuplicate then
          c.flurry, c.flurryProcs = c.flurry+n, c.flurryProcs+1
          s.flurry, s.flurryProcs = s.flurry+n, s.flurryProcs+1
          local A=EAT_DB.allTime; A.flurry=(A.flurry or 0)+n; A.flurryProcs=(A.flurryProcs or 0)+1
          celebrateProc("flurry", n)
        end

      elseif isIronfoe(spellID, spellName) then
        if not isDuplicate then
          c.ironfoe, c.ironfoeProcs = c.ironfoe+n, c.ironfoeProcs+1
          s.ironfoe, s.ironfoeProcs = s.ironfoe+n, s.ironfoeProcs+1
          local A=EAT_DB.allTime; A.ironfoe=(A.ironfoe or 0)+n; A.ironfoeProcs=(A.ironfoeProcs or 0)+1
          celebrateProc("ironfoe", n)
          
          -- Ironfoe special celebration for 3+ attacks
          if n >= 3 then
            UIErrorsFrame:AddMessage("⚒️ FORGEWRIGHT'S FURY! " .. n .. " attacks!", 1, 0.5, 0, 1.0)
            if EAT_DB.settings.soundEnabled then
              PlaySound(8959) -- Celebration sound
            end
          end
        end

      elseif isHoJ(spellID, spellName) then
        if not isDuplicate then
          c.hoj, c.hojProcs = c.hoj+n, c.hojProcs+1
          s.hoj, s.hojProcs = s.hoj+n, s.hojProcs+1
          local A=EAT_DB.allTime; A.hoj=(A.hoj or 0)+n; A.hojProcs=(A.hojProcs or 0)+1
          celebrateProc("hoj", n)
        end

      elseif isCounterweight(spellID, spellName) then
        if not isDuplicate then
          c.icw, c.icwProcs = c.icw+n, c.icwProcs+1
          s.icw, s.icwProcs = s.icw+n, s.icwProcs+1
          local A=EAT_DB.allTime; A.icw=(A.icw or 0)+n; A.icwProcs=(A.icwProcs or 0)+1
          celebrateProc("icw", n)
        end

      elseif isReck(spellID, spellName) then
        if not isDuplicate then
          c.reck = c.reck + n
          s.reck = s.reck + n
          EAT_DB.allTime.reck = (EAT_DB.allTime.reck or 0) + n
          celebrateProc("reck", n)
          
          -- Reckoning is special - big celebration!
          if n >= 4 then
            UIErrorsFrame:AddMessage("🎊 RECKONING BOMB! " .. n .. " ATTACKS!", 1, 0, 0, 1.0)
            if EAT_DB.settings.soundEnabled then
              PlaySound(8959) -- Big celebration sound
            end
          end
        end

      else
        if not EAT_DB._seen[spellID] then
          EAT_DB._seen[spellID] = true
          print("|cff00ff96RNG Casino|r discovered:", spellID, spellName or "?", "amount:", n)
        end
      end
      
      -- Only update streak tracking if not a duplicate
      if not isDuplicate then
        -- Check if time between procs was very fast (lucky streak)
        local now = GetTime()
        if s.lastProcTime > 0 and (now - s.lastProcTime) < 2 then
          s.currentStreak = s.currentStreak + 1
        else
          s.currentStreak = 1
        end
      end
      
      repaint()

    -- Parry tracking
    elseif destGUID==UnitGUID("player") and sub=="SWING_MISSED" then
      local missType = select(12,CombatLogGetCurrentEventInfo())
      if missType=="PARRY" then
        c.parry = c.parry + 1
        s.parry = s.parry + 1
        EAT_DB.allTime.parry = (EAT_DB.allTime.parry or 0) + 1
        applyParryHaste()
        repaint()
      end
    end
  end
end)

-------------------------------------------------------------------------------
-- 7.  Enhanced slash commands
-------------------------------------------------------------------------------
SLASH_EAT1, SLASH_EAT2 = "/eat", "/extraattacks"
SlashCmdList["EAT"]=function(msg)
  msg = (msg or ""):lower():gsub("^%s+",""):gsub("%s+$","")

  if msg=="toggle" then
    f:SetShown(not f:IsShown())

  elseif msg=="lock" then
    EAT_DB.locked=true; f:EnableMouse(false)
    print("|cff00ff96RNG Casino|r frame locked (click-through enabled)")

  elseif msg=="unlock" then
    EAT_DB.locked=false; f:EnableMouse(true)
    print("|cff00ff96RNG Casino|r frame unlocked")
    
  elseif msg:match("^alpha%s+[%d%.]+$") then
    local alpha = tonumber(msg:match("alpha%s+([%d%.]+)"))
    if alpha and alpha >= 0.3 and alpha <= 1.0 then
      EAT_DB.alpha = alpha
      f:SetAlpha(alpha)
      print(string.format("|cff00ff96RNG Casino|r alpha set to %.1f", alpha))
    else
      print("|cff00ff96RNG Casino|r alpha must be 0.3-1.0")
    end
    
  elseif msg=="fade" then
    EAT_DB.fadeEnabled = not EAT_DB.fadeEnabled
    print("|cff00ff96RNG Casino|r fade " .. (EAT_DB.fadeEnabled and "enabled" or "disabled"))

  elseif msg:match("^scale%s+[%d%.]+$") then
    local val = tonumber(msg:match("scale%s+([%d%.]+)"))
    if val and val>0.4 and val<=3.0 then
      EAT_DB.scale = val; f:SetScale(val)
      print("|cff00ff96RNG Casino|r scale set to", val)
    else
      print("|cff00ff96RNG Casino|r scale must be 0.5–3.0")
    end
    
  elseif msg=="stats" then
    -- Detailed statistics
    print("|cff00ff96🎰 RNG Casino Statistics|r")
    
    local luck = getLuckRating()
    local grade = getLuckGrade(luck)
    print("Current Luck: " .. colorText(grade.color, string.format("%s (%.0f%%)", grade.grade, luck)))
    
    print(string.format("Session: %d procs in %d swings (%.1f%%)", 
      s.totalProcs, s.flurrySwings, pct(s.totalProcs, s.flurrySwings)))
    
    print("Best Streak: " .. EAT_DB.luckStats.bestStreak)
    print("Worst Dry Streak: " .. EAT_DB.luckStats.worstDryStreak)
    print("Jackpots Won: " .. (EAT_DB.luckStats.jackpots or 0))
    
    -- Show proc breakdown
    if s.ironfoeProcs > 0 then
      print(string.format("Ironfoe: %d procs, %d attacks", s.ironfoeProcs, s.ironfoe))
    end
    
    -- Show achievements
    print("|cff00ff96Achievements:|r")
    for _, ach in ipairs(ACHIEVEMENTS) do
      local key = ach.type .. "_" .. ach.value
      local status = EAT_DB.achievements[key] and "✓" or "✗"
      print(string.format("  %s %s %s - %s", status, ach.icon, ach.name, ach.desc))
    end

  elseif msg=="reset combat" then
    wipeTable(c); repaint()
    print("|cff00ff96RNG Casino|r combat counters reset")

  elseif msg=="reset session" then
    wipeTable(s); wipeTable(c)
    s.sessionStart = GetTime()
    repaint()
    print("|cff00ff96RNG Casino|r session reset")

  elseif msg=="reset all" then
    wipeTable(EAT_DB.allTime); wipeTable(s); wipeTable(c)
    EAT_DB.achievements = {}
    EAT_DB.luckStats = {bestStreak=0, worstDryStreak=0, jackpots=0}
    s.sessionStart = GetTime()
    repaint()
    print("|cff00ff96RNG Casino|r all stats and achievements reset")

  elseif msg=="help" or msg=="" then
    print("|cff00ff96🎰 RNG Casino Commands|r")
    print(" /eat toggle      – show/hide")
    print(" /eat stats       – detailed statistics")
    print(" /eat lock|unlock – lock/unlock frame")
    print(" /eat alpha <0.3-1.0> – transparency")
    print(" /eat fade        – toggle fade effect")
    print(" /eat scale <0.5–3.0> – UI scale")
    print(" /eat reset combat|session|all – reset stats")

  else
    print("|cff00ff96RNG Casino|r unknown command. Try /eat help")
  end
end