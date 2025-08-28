------------------------------------------------------------------------
-- HealingCircle.lua  ·  v1.0.0  (Classic Era / SoD / HC)
-- Tracks Lawbringer 8-piece bonus (spellID 23544) procs & healing
------------------------------------------------------------------------
local ADDON_NAME, _ = ...
------------------------------------------------------------------------
-- 0.  SavedVariables
------------------------------------------------------------------------
HC_DB = HC_DB or {}                           -- !! ensure .toc SavedVariables
local defaults = {
  debug    = false,
  scale    = 0.75,
  locked   = false,
  position = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 260, 10}, -- Default position
  allTime  = { procs = 0, healing = 0 },
}

------------------------------------------------------------------------
-- 1.  Local caches
------------------------------------------------------------------------
local tracking = {
  combat  = { procs = 0, healing = 0 },
  session = { procs = 0, healing = 0 },
  allTime = {},                               -- populated from DB
}
local lastProcTime = 0
local textWidgets  = {}
local statsFrame
local debugMode    = false

------------------------------------------------------------------------
-- 2.  Utilities
------------------------------------------------------------------------
local function deepcopy(src, dst)
  if type(src) ~= "table" then return src end
  dst = dst or {}
  for k,v in pairs(src) do
    dst[k] = (type(v)=="table") and deepcopy(v, dst[k]) or v
  end
  return dst
end

local function Debug(...) if debugMode then print("|cff88ccff[HC]|r", ...) end end
local function fmt(n)      return BreakUpLargeNumbers and BreakUpLargeNumbers(n) or tostring(n) end

------------------------------------------------------------------------
-- 3.  UI factory  (runs at PLAYER_LOGIN)
------------------------------------------------------------------------
local function UpdateDisplay()
  if not statsFrame then return end
  for _,w in ipairs(textWidgets) do
    local s = tracking[w.key]
    w.procs  :SetText(fmt(s.procs))
    w.heal   :SetText(fmt(s.healing))
  end
end

local function CreateUI()
  if statsFrame then return end -- Assuming statsFrame is the global for the UI frame

  -- pull prefs from HC_DB, falling back to defaults
  local pos   = HC_DB.position or defaults.position -- Load saved position or use default
  local scale = HC_DB.scale    or defaults.scale
  local locked= HC_DB.locked   or defaults.locked

  local f = CreateFrame("Frame", "HC_StatsFrame", UIParent, "BackdropTemplate")
  f:SetSize(170, 70) -- Example size, adjust if needed
  f:SetScale(scale)
  f:SetPoint(unpack(pos)) -- Apply the loaded or default position
  f:SetBackdrop(nil)
  f:SetFrameStrata("MEDIUM")
  f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self)
    if not locked then self:StartMoving() end
  end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    HC_DB.position = { self:GetPoint(1) } -- Save the new position to HC_DB
  end)

  local title = f:CreateFontString(nil,"OVERLAY","GameFontNormal")
  title:SetPoint("TOP",0,-5)
  title:SetText("|cFFADD8E6Healing Circle Stats|r") -- Changed title

  -- column headers
  local col1X, col2X = 80, 130
  local startY, gap = -22, 16
  local h1 = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
  h1:SetPoint("TOPLEFT",col1X,startY); h1:SetText("Procs")
  local h2 = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
  h2:SetPoint("TOPLEFT",col2X,startY); h2:SetText("Healing")

  -- three rows
  local rows = {
    { label="Combat:",  key="combat"  },
    { label="Session:", key="session" },
    { label="All-Time:",key="allTime" },
  }
  local baseY = startY - gap
  for i,row in ipairs(rows) do
    local y = baseY - (i-1)*gap
    local lab = f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lab:SetPoint("TOPLEFT",10,y); lab:SetText(row.label)

    local p = f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    p:SetPoint("TOPLEFT",col1X,y); p:SetText("0")
    local h = f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    h:SetPoint("TOPLEFT",col2X,y); h:SetText("0")

    table.insert(textWidgets,{ key=row.key, procs=p, heal=h })
  end

  statsFrame = f
  statsFrame:Show()
  UpdateDisplay()
end

------------------------------------------------------------------------
-- 4.  Reset helpers
------------------------------------------------------------------------
local function wipeScope(s)
  s.procs   = 0
  s.healing = 0
end

local function ResetCombat()  wipeScope(tracking.combat);  UpdateDisplay(); Debug("Combat reset") end
local function ResetSession() wipeScope(tracking.session); ResetCombat();   Debug("Session reset") end
local function ResetAllTime() wipeScope(tracking.allTime); ResetSession();  Debug("All-time reset") end

------------------------------------------------------------------------
-- 5.  Saver
------------------------------------------------------------------------
local function SaveDB()
  HC_DB.debug   = debugMode
  HC_DB.scale   = HC_DB.scale or defaults.scale     -- Persist current scale or default
  HC_DB.locked  = HC_DB.locked or defaults.locked   -- Persist current lock state or default
  HC_DB.allTime = deepcopy(tracking.allTime)       -- Persist all-time stats
  -- Note: HC_DB.position is updated directly in OnDragStop and saved with HC_DB automatically by WoW on logout/reload.
  Debug("Data saved; total procs:", HC_DB.allTime.procs)
end

------------------------------------------------------------------------
-- 6.  Event driver
------------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function(self,evt,arg1)
  if evt=="ADDON_LOADED" and arg1==ADDON_NAME then
    HC_DB = deepcopy(defaults, HC_DB)      -- Merge defaults with saved DB.
                                           -- This ensures HC_DB.position is initialized from defaults
                                           -- if it's not present in the saved variables file.
    tracking.allTime = deepcopy(HC_DB.allTime) -- Ensure tracking.allTime is populated
    debugMode = HC_DB.debug                -- Load debug status
    Debug("ADDON_LOADED complete for HealingCircle")

  elseif evt=="PLAYER_LOGIN" then            -- create UI late
    CreateUI()

  elseif evt=="COMBAT_LOG_EVENT_UNFILTERED" then
    local ts, sub, _, srcGUID, _, _, _, _, _, _, _, spellID, _, _, amount, overheal =
      CombatLogGetCurrentEventInfo()
    if srcGUID ~= UnitGUID("player") then return end

    if (sub=="SPELL_HEAL" or sub=="SPELL_PERIODIC_HEAL") and spellID==23544 then -- Changed spellID
      -- debounce 0.2 s to avoid double fire (rare but possible)
      if ts - lastProcTime > 0.2 then
        tracking.combat.procs   = tracking.combat.procs   + 1
        tracking.session.procs  = tracking.session.procs  + 1
        tracking.allTime.procs  = tracking.allTime.procs  + 1
        lastProcTime = ts
      end
      local eff = amount - (overheal or 0)
      tracking.combat.healing   = tracking.combat.healing   + eff
      tracking.session.healing  = tracking.session.healing  + eff
      tracking.allTime.healing  = tracking.allTime.healing  + eff
      UpdateDisplay()
    end

  elseif evt=="PLAYER_REGEN_ENABLED" then
    ResetCombat()

  elseif evt=="PLAYER_LOGOUT" then
    SaveDB() -- Ensure settings, including implicitly the position in HC_DB, are ready for WoW to save.
  end
end)

------------------------------------------------------------------------
-- 7.  Slash commands
------------------------------------------------------------------------
SLASH_HC1, SLASH_HC2 = "/hc", "/healingcircle" -- Changed slash commands
SlashCmdList["HC"] = function(msg) -- Changed slash command list key
  msg = (msg or ""):lower()
  if msg=="toggle" then
    if statsFrame:IsShown() then statsFrame:Hide() else statsFrame:Show() end

  elseif msg=="reset combat" then ResetCombat()
  elseif msg=="reset session" then ResetSession()
  elseif msg=="reset all" then    ResetAllTime()

  elseif msg=="debug" then
    debugMode = not debugMode; HC_DB.debug = debugMode
    print("Debug mode:", debugMode and "ON" or "OFF")

  elseif msg:match("^scale%s+") then
    local n = tonumber(msg:match("^scale%s+(%d*%.?%d+)"))
    if n and n>0 then
      HC_DB.scale = n; if statsFrame then statsFrame:SetScale(n) end
    end

  elseif msg=="lock" then HC_DB.locked=true
  elseif msg=="unlock" then HC_DB.locked=false

  else
    print("|cFFADD8E6Healing Circle Commands|r:") -- Changed print message
    print("  /hc toggle        – show/hide window")
    print("  /hc reset combat  – clear current fight")
    print("  /hc reset session – clear since login")
    print("  /hc reset all     – clear all-time")
    print("  /hc scale <n>     – set UI scale (e.g. 0.8)")
    print("  /hc lock|unlock   – lock/unlock frame")
    print("  /hc debug         – toggle debug chat")
  end
end
