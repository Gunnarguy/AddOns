-- EngagedThreat.lua  (Classic 1.15.7, Nightslayer-US)  v1.4.0
local ADDON = ...
EngagedThreatDB = EngagedThreatDB or {}

--============================ Config ============================--
local CFG = {
  scale   = EngagedThreatDB.scale or 0.95,
  width   = EngagedThreatDB.width or 320,
  rowH    = 24,
  maxRows = 12,
  fadeSec = 6,
  updateHz= 10,
  locked  = EngagedThreatDB.locked or false,
  showThreatWhenPct = 90,           -- show runner-up only when >= this % of top
  sortMode = EngagedThreatDB.sortMode or "engage", -- engage | activity | danger
  bubbleSeconds = 2.0,              -- keep bubbled-to-top this long after it stops targeting you
}
local FONT = "Fonts\\FRIZQT__.TTF"

--============================ Utils ============================--
local band = bit.band
local B_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local B_PLAYER  = COMBATLOG_OBJECT_TYPE_PLAYER
local B_PET     = COMBATLOG_OBJECT_TYPE_PET
local function now() return GetTime() end
local function IsHostile(f)  return band(f or 0, B_HOSTILE) ~= 0 end
local function IsGroupish(f) return band(f or 0, B_PLAYER) ~= 0 or band(f or 0, B_PET) ~= 0 end
local function clamp(x,a,b) if x<a then return a elseif x>b then return x>b and b or x end end
local function abbrev(n)
  if not n then return "0" end
  if n >= 1e6 then return ("%.1fm"):format(n/1e6):gsub("%.0m","m") end
  if n >= 1e3 then return ("%.1fk"):format(n/1e3):gsub("%.0k","k") end
  return tostring(math.floor(n+0.5))
end

local function colorizeUnitName(unit)
  local name = UnitName(unit) or "?"
  if UnitIsUnit(unit, "player") then return "|cffffd100"..name.."|r" end
  if UnitIsPlayer(unit) then
    local _, cls = UnitClass(unit)
    local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
    if c and c.colorStr then return "|c"..c.colorStr..name.."|r" end
  end
  return name
end

--============================ Data ============================--
-- [guid] = {name, lastSeen, unit, swings={}, estSpeed, lastVictimName, order, bubbleUntil}
local mobs, guidToUnit = {}, {}
local lastUI, orderCounter = 0, 1

--==================== GUID <-> Unit mapping ====================--
local function Bind(guid, unit)
  if not guid or not unit or not UnitExists(unit) then return end
  if UnitGUID(unit) ~= guid then return end
  guidToUnit[guid] = unit
  local m = mobs[guid]; if m then m.unit = unit end
end

local function TryBindUnitForGUID(guid)
  local u = guidToUnit[guid]
  if u and UnitExists(u) and UnitGUID(u) == guid then return u end
  local probes = { "target", "focus", "mouseover" }
  for i=1,4 do probes[#probes+1]=("party%dtarget"):format(i); probes[#probes+1]=("partypet%d"):format(i) end
  for i=1,40 do probes[#probes+1]=("raid%dtarget"):format(i);  probes[#probes+1]=("raidpet%d"):format(i)  end
  for i=1,40 do probes[#probes+1]=("nameplate%d"):format(i) end
  for _,unit in ipairs(probes) do
    if UnitExists(unit) and UnitGUID(unit) == guid then Bind(guid, unit); return unit end
  end
end
local function UnitForGUID(guid) return TryBindUnitForGUID(guid) end

--========================= Swing speed =========================--
local function PushSwing(guid, tstamp)
  local m = mobs[guid]; if not m then return end
  m.swings = m.swings or {}
  local t = m.swings; t[#t+1] = tstamp; if #t>6 then table.remove(t,1) end
  if #t>=3 then local s,c=0,0 for i=2,#t do s=s+(t[i]-t[i-1]); c=c+1 end m.estSpeed = clamp(s/c, 0.5, 4.0) end
end

--=========================== Threat ===========================--
local function RunnerUpFor(mobUnit)
  if not mobUnit or not UnitExists(mobUnit) then return end
  local list = {}
  local function add(u)
    if UnitExists(u) then
      local _,_,_,_,raw = UnitDetailedThreatSituation(u, mobUnit)
      if raw and raw>0 then list[#list+1] = {u=u, raw=raw} end
    end
  end
  add("player"); add("pet")
  for i=1,4 do add(("party%d"):format(i)); add(("partypet%d"):format(i)) end
  for i=1,40 do add(("raid%d"):format(i));  add(("raidpet%d"):format(i))  end
  table.sort(list, function(a,b) return a.raw > b.raw end)
  return list[1], list[2]
end

--============================= UI =============================--
local holder = CreateFrame("Frame", "EngagedThreatFrame", UIParent)
holder:SetSize(CFG.width, CFG.rowH*CFG.maxRows + 18)
holder:SetPoint("CENTER", 0, 120)
holder:SetScale(CFG.scale)
holder:SetMovable(true)
holder:RegisterForDrag("LeftButton")
holder:SetClampedToScreen(true)

-- robust drag: stop on mouse up / hide too
local function SavePos()
  local p, _, rp, x, y = holder:GetPoint()
  EngagedThreatDB.pos = {p, rp, x, y}
end
holder:SetScript("OnDragStart", function(self) if not CFG.locked then self.isMoving=true; self:StartMoving() end end)
holder:SetScript("OnDragStop",  function(self) if self.isMoving then self.isMoving=false; self:StopMovingOrSizing(); SavePos() end end)
holder:SetScript("OnMouseUp",   function(self) if self.isMoving then self.isMoving=false; self:StopMovingOrSizing(); SavePos() end end)
holder:SetScript("OnHide",      function(self) if self.isMoving then self.isMoving=false; self:StopMovingOrSizing(); SavePos() end end)

local bg = holder:CreateTexture(nil,"BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0,0,0,0.20)
local title = holder:CreateFontString(nil,"OVERLAY"); title:SetFont(FONT,11,"OUTLINE")
title:SetPoint("TOPLEFT",4,-3); title:SetText("|cff00ff96Engaged Threat|r")

-- forward declare; then lock plumbing
local lockBtn
local function ApplyLock()
  holder:EnableMouse(not CFG.locked)
  if holder.isMoving then holder.isMoving=false; holder:StopMovingOrSizing(); SavePos() end
  if lockBtn then lockBtn:SetShown(not CFG.locked) end
end

lockBtn = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
lockBtn:SetSize(44, 16)
lockBtn:SetPoint("TOPRIGHT", -2, -2)
lockBtn:SetText("Lock")
lockBtn:SetScript("OnClick", function()
  CFG.locked = true; EngagedThreatDB.locked = true; ApplyLock()
  print("EngagedThreat: locked. Use /engthreat unlock to unlock.")
end)

local rows = {}
local function CreateRow(i)
  local f = CreateFrame("Frame", nil, holder)
  f:SetSize(CFG.width-4, CFG.rowH)
  f:SetPoint("TOPLEFT", 2, -18-(i-1)*CFG.rowH)

  local rowBG = f:CreateTexture(nil,"BACKGROUND"); rowBG:SetAllPoints(); rowBG:SetColorTexture(0,0,0,0.35)
  local hl = f:CreateTexture(nil,"ARTWORK"); hl:SetAllPoints()
  hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight"); hl:SetBlendMode("ADD"); hl:Hide()

  local nameFS = f:CreateFontString(nil,"OVERLAY"); nameFS:SetFont(FONT,11,"OUTLINE")
  nameFS:SetPoint("LEFT", f, "LEFT", 4, 0); nameFS:SetWidth((CFG.width-4)*0.50); nameFS:SetJustifyH("LEFT"); nameFS:SetMaxLines(1)

  local portrait = f:CreateTexture(nil,"OVERLAY"); portrait:SetSize(CFG.rowH-6, CFG.rowH-6)
  portrait:SetPoint("RIGHT", f, "RIGHT", -3, 0); portrait:SetTexCoord(0.07,0.93,0.07,0.93)

  local tgtFS = f:CreateFontString(nil,"OVERLAY"); tgtFS:SetFont(FONT,11,"OUTLINE")
  tgtFS:SetPoint("RIGHT", portrait, "LEFT", -6, 0); tgtFS:SetWidth((CFG.width-4)*0.32); tgtFS:SetJustifyH("RIGHT"); tgtFS:SetMaxLines(1)

  local thrFS = f:CreateFontString(nil,"OVERLAY"); thrFS:SetFont(FONT,9,"OUTLINE")
  thrFS:SetPoint("TOPRIGHT", tgtFS, "BOTTOMRIGHT", 0, 0)

  local hpBG = f:CreateTexture(nil,"BORDER"); hpBG:SetColorTexture(0,0,0,0.8)
  hpBG:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
  hpBG:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
  hpBG:SetHeight(3)

  local hp = CreateFrame("StatusBar", nil, f)
  hp:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
  hp:SetPoint("TOPLEFT", hpBG, "TOPLEFT", 0, 0)
  hp:SetPoint("BOTTOMRIGHT", hpBG, "BOTTOMRIGHT", 0, 0)
  hp:SetMinMaxValues(0,1); hp:SetValue(1)

  rows[i] = {frame=f, bg=rowBG, hl=hl, name=nameFS, tgt=tgtFS, port=portrait, thr=thrFS, hp=hp, guid=nil}
end
for i=1, CFG.maxRows do CreateRow(i) end

--========================== Model ops ==========================--
local function TouchMob(guid, name)
  if not guid then return end
  local m = mobs[guid]
  if not m then
    m = {name=name or "Unknown", swings={}, lastSeen=now(), order=orderCounter}
    orderCounter = orderCounter + 1
    mobs[guid] = m
  else
    m.name = name or m.name
    m.lastSeen = now()
  end
  return m
end

local function CleanupMobs()
  local t = now()
  for g,m in pairs(mobs) do
    if (t - (m.lastSeen or 0)) > CFG.fadeSec then
      mobs[g] = nil; guidToUnit[g] = nil
    end
  end
end

--========================== Data get ===========================--
local function RaidIconText(unit)
  local i = unit and UnitExists(unit) and GetRaidTargetIndex(unit)
  if i then return ("|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%d:12|t "):format(i) end
  return ""
end

local function HealthFrac(guid)
  local u = UnitForGUID(guid)
  if u and UnitExists(u) then
    local cur,max = UnitHealth(u), UnitHealthMax(u)
    if max and max > 0 then return cur/max end
  end
end

local function TargetUnitForMob(guid)
  local u = UnitForGUID(guid)
  if u and UnitExists(u.."target") then return u.."target" end
end

local function LeftText(guid)
  local m = mobs[guid]; local u = UnitForGUID(guid)
  local spd = m.estSpeed and string.format("%.2fs", m.estSpeed)
  if not spd and u then local base = UnitAttackSpeed(u); if base then spd = string.format("%.2fs", base) end end
  spd = spd or "…"
  return string.format("%s%s  |cffa0a0a0spd:|r %s", RaidIconText(u), m.name or "Unknown", spd)
end

local function ThreatText(guid)
  local u = UnitForGUID(guid); if not u then return "" end
  local top, runner = RunnerUpFor(u); if not top then return "" end
  local topRaw = top.raw; local rRaw = runner and runner.raw or 0
  local pct = (topRaw>0 and rRaw>0) and (rRaw/topRaw*100) or 0
  if pct < CFG.showThreatWhenPct then return "" end
  local pullM, pullR = topRaw*1.10, topRaw*1.30
  local rName = runner and colorizeUnitName(runner.u) or "-"
  return string.format("|cffa0a0a0runner:|r %s  %d%%  M:+%s R:+%s",
    rName, pct, abbrev(math.max(0,pullM-rRaw)), abbrev(math.max(0,pullR-rRaw)))
end

-- danger score used by "danger" sort
local function DangerScore(guid)
  local score = 0
  local tu = TargetUnitForMob(guid)
  if tu and UnitIsUnit(tu,"player") then score = score + 1000 end
  local u = UnitForGUID(guid)
  if u then
    local top, runner = RunnerUpFor(u)
    if top and runner and top.raw and runner.raw and top.raw > 0 then
      score = score + (runner.raw / top.raw) * 100
    end
  end
  -- fresher activity gives small bias
  local m = mobs[guid]; if m and m.lastSeen then score = score + (now() - (m.lastSeen or 0) < 1.0 and 1 or 0) end
  return score
end

--======================== Collect & Sort =======================--
local function Collect()
  local list = {}
  for g,m in pairs(mobs) do list[#list+1] = {g=g, m=m} end

  -- bubble mob(s) targeting you to top for a short window (hysteresis)
  local tnow = now()
  for _,item in ipairs(list) do
    local tu = TargetUnitForMob(item.g)
    if tu and UnitIsUnit(tu,"player") then
      item.m.bubbleUntil = tnow + CFG.bubbleSeconds
    end
  end

  table.sort(list, function(a,b)
    local aBub = a.m.bubbleUntil and a.m.bubbleUntil > now()
    local bBub = b.m.bubbleUntil and b.m.bubbleUntil > now()
    if aBub ~= bBub then return aBub end

    if CFG.sortMode == "engage" then
      return (a.m.order or 1e9) < (b.m.order or 1e9)
    elseif CFG.sortMode == "danger" then
      local da, db = DangerScore(a.g), DangerScore(b.g)
      if da ~= db then return da > db end
      return (a.m.order or 1e9) < (b.m.order or 1e9)
    else -- "activity"
      local la, lb = (a.m.lastSeen or 0), (b.m.lastSeen or 0)
      if la ~= lb then return la > lb end
      return (a.m.order or 1e9) < (b.m.order or 1e9)
    end
  end)

  while #list > CFG.maxRows do table.remove(list) end
  return list
end

--============================ Paint ============================--
local function Paint()
  local list = Collect()
  for i,row in ipairs(rows) do
    local item = list[i]
    if not item then
      row.frame:Hide(); row.guid = nil
    else
      row.frame:Show(); row.guid = item.g

      row.name:SetText(LeftText(item.g))

      local tu = TargetUnitForMob(item.g)
      if tu and UnitExists(tu) then
        row.tgt:SetText(colorizeUnitName(tu))
        SetPortraitTexture(row.port, tu); row.port:Show()
        if UnitIsUnit(tu, "player") then row.hl:Show() else row.hl:Hide() end
      else
        row.tgt:SetText("|cffa0a0a0t:|r ?")
        row.port:Hide(); row.hl:Hide()
      end

      local f = HealthFrac(item.g)
      if f then
        row.hp:SetValue(f)
        local r = clamp((1-f)*2, 0, 1); local g = clamp(f*2, 0, 1)
        row.hp:SetStatusBarColor(r, g, 0.1)
      else
        row.hp:SetValue(1); row.hp:SetStatusBarColor(0.35,0.35,0.35)
      end

      row.thr:SetText(ThreatText(item.g))
    end
  end
end

--============================ Events ===========================--
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

f:SetScript("OnEvent", function(self, evt, ...)
  if evt == "ADDON_LOADED" then
    local a = ...
    if a == ADDON then
      if EngagedThreatDB.pos then
        holder:ClearAllPoints()
        holder:SetPoint(EngagedThreatDB.pos[1], UIParent, EngagedThreatDB.pos[2], EngagedThreatDB.pos[3], EngagedThreatDB.pos[4])
      end
      CFG.locked = not not EngagedThreatDB.locked
      CFG.sortMode = EngagedThreatDB.sortMode or CFG.sortMode
      ApplyLock()
    end

  elseif evt == "PLAYER_LOGIN" then
    holder:SetScript("OnUpdate", function(_, e)
      lastUI = lastUI + e
      if lastUI >= (1/CFG.updateHz) then CleanupMobs(); Paint(); lastUI = 0 end
    end)

  elseif evt == "PLAYER_LOGOUT" then
    EngagedThreatDB.scale = CFG.scale
    EngagedThreatDB.width = CFG.width
    EngagedThreatDB.locked = CFG.locked
    EngagedThreatDB.sortMode = CFG.sortMode

  elseif evt == "GROUP_ROSTER_UPDATE" then wipe(guidToUnit)

  elseif evt == "PLAYER_TARGET_CHANGED" then if UnitExists("target") then Bind(UnitGUID("target"), "target") end
  elseif evt == "UPDATE_MOUSEOVER_UNIT" then if UnitExists("mouseover") then Bind(UnitGUID("mouseover"), "mouseover") end
  elseif evt == "NAME_PLATE_UNIT_ADDED" then local u = ...; Bind(UnitGUID(u), u)
  elseif evt == "NAME_PLATE_UNIT_REMOVED" then local u = ...; local g = UnitGUID(u); if g then guidToUnit[g] = nil end
  elseif evt == "PLAYER_REGEN_ENABLED" then
    -- fade clears
  elseif evt == "COMBAT_LOG_EVENT_UNFILTERED" then
    local ts, sub, _, sGUID, sName, sF, _, dGUID, dName, dF = CombatLogGetCurrentEventInfo()
    if IsHostile(sF) and IsGroupish(dF) then local m = TouchMob(sGUID, sName); if m then m.lastVictimName = dName end
    elseif IsHostile(dF) and IsGroupish(sF) then TouchMob(dGUID, dName) end
    if (sub=="SWING_DAMAGE" or sub=="SWING_MISSED") and IsHostile(sF) and IsGroupish(dF) then if mobs[sGUID] then PushSwing(sGUID, ts) end end
    if (sub=="UNIT_DIED" or sub=="PARTY_KILL") and dGUID and mobs[dGUID] then mobs[dGUID]=nil; guidToUnit[dGUID]=nil end
  end
end)

--============================ Slash ============================--
SLASH_ENGTHREAT1 = "/engthreat"
SlashCmdList["ENGTHREAT"] = function(msg)
  msg = (msg or ""):lower()
  if msg == "toggle" then
    holder:SetShown(not holder:IsShown())
  elseif msg:match("^scale%s+") then
    local n = tonumber(msg:match("^scale%s+(%d*%.?%d+)"))
    if n and n>0 then CFG.scale=n; EngagedThreatDB.scale=n; holder:SetScale(n) end
  elseif msg:match("^width%s+") then
    local n = tonumber(msg:match("^width%s+(%d+)"))
    if n and n>=200 then CFG.width=n; EngagedThreatDB.width=n; holder:SetWidth(n) end
  elseif msg:match("^sort%s+") then
    local m = msg:match("^sort%s+(%a+)")
    if m=="engage" or m=="activity" or m=="danger" then
      CFG.sortMode = m; EngagedThreatDB.sortMode = m
      print("EngagedThreat: sort mode = "..m)
    else
      print("EngagedThreat: invalid sort. Use: engage | activity | danger")
    end
  elseif msg == "lock" then
    CFG.locked = true; EngagedThreatDB.locked = true; ApplyLock(); print("EngagedThreat: locked.")
  elseif msg == "unlock" then
    CFG.locked = false; EngagedThreatDB.locked = false; ApplyLock(); print("EngagedThreat: unlocked.")
  else
    print("|cff00ff96EngagedThreat|r cmds:")
    print("  /engthreat toggle | scale N | width N")
    print("  /engthreat sort engage|activity|danger")
    print("  /engthreat lock | unlock")
  end
end