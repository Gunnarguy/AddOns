-- Reckoning Tracker for WoW Classic Era (1.15.6.58912)
-- Updated for Anniversary Fresh Realm Mechanics

-- Saved Variables
ReckoningTrackerDB = ReckoningTrackerDB or {
  enabled = true,
  position = {"CENTER", UIParent, "CENTER", 0, 0},
  showMax = true,
  lock = false,
  scale = 1.0
}

-- Constants
local RECKONING_SPELL_ID = 20178
local MAX_STACKS = 4
local CRIT_DETECTION_DELAY = 0.1 -- Increased for testing, adjust as needed

-- Frame Creation
local f = CreateFrame("Frame", "ReckoningTrackerFrame", UIParent, "BackdropTemplate")
f:SetSize(100, 40)
f:SetScale(ReckoningTrackerDB.scale)
f:SetPoint(unpack(ReckoningTrackerDB.position))
f:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = {left = 4, right = 4, top = 4, bottom = 4}
})
f:SetBackdropColor(0, 0, 0, 0.8)
f:SetMovable(true)
f:EnableMouse(not ReckoningTrackerDB.lock)
f:RegisterForDrag("LeftButton")

-- Text Display
local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("CENTER")
text:SetTextColor(1, 0.82, 0)

-- State Tracking
local currentStacks = 0

-- Core Functions
local function UpdateDisplay()
  if ReckoningTrackerDB.enabled then
      f:Show()
      local displayText = format("Reckoning: %d", currentStacks)
      if ReckoningTrackerDB.showMax then
          displayText = displayText..format("/%d", MAX_STACKS)
      end
      text:SetText(displayText)
  else
      f:Hide()
  end
end

local function ScanStacks()
  local _, _, count = UnitAura("player", "Reckoning")
  currentStacks = count or 0
  UpdateDisplay()
end


-- Event Handling
local function OnEvent(self, event, ...)
  if event == "PLAYER_LOGIN" then
      UpdateDisplay() -- This line is crucial!
  elseif event == "UNIT_AURA" and arg1 == "player" then
      ScanStacks()
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
      local time, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, spellSchool, amount, overkill, weaponType, attackType, damageType, absorbed, resisted, blocked, deflected, evaded, parried, crit, glancing, crushing, modifier1, modifier2, modifier3  = CombatLogGetCurrentEventInfo()

      -- Stack Generation
      if subEvent == "SWING_DAMAGE" and destGUID == UnitGUID("player") and crit then
          C_Timer.After(CRIT_DETECTION_DELAY, ScanStacks)
      end

      -- Stack Consumption
      if subEvent == "SWING_DAMAGE" and sourceGUID == UnitGUID("player") and currentStacks > 0 then
          currentStacks = currentStacks - 1
          UpdateDisplay()
      end

      -- Spell Activation for Seal of Reckoning Application
        if subEvent == "SPELL_CAST_START" and sourceGUID == UnitGUID("player") and spellID == RECKONING_SPELL_ID then
            ScanStacks() -- Immediately update on seal application.
        end

  end
end

-- Frame Behavior
f:SetScript("OnDragStart", function() if not ReckoningTrackerDB.lock then f:StartMoving() end end)
f:SetScript("OnDragStop", function() f:StopMovingOrSizing(); ReckoningTrackerDB.position = {f:GetPoint()} end)

-- Slash Commands
SLASH_RECKONINGTRACKER1 = "/reckoning"
SlashCmdList["RECKONINGTRACKER"] = function(msg)
msg = strlower(msg)

if msg == "toggle" then
    ReckoningTrackerDB.enabled = not ReckoningTrackerDB.enabled
    print("Reckoning Tracker "..(ReckoningTrackerDB.enabled and "|cff00ff00Enabled" or "|cffff0000Disabled"))
    UpdateDisplay()
elseif msg == "lock" then
    ReckoningTrackerDB.lock = not ReckoningTrackerDB.lock
    f:EnableMouse(not ReckoningTrackerDB.lock)
    print("Frame "..(ReckoningTrackerDB.lock and "|cffff0000Locked" or "|cff00ff00Unlocked"))
elseif msg == "reset" then
    currentStacks = 0
    UpdateDisplay()
    print("|cff00ff00Stacks reset")
elseif msg == "max" then
    ReckoningTrackerDB.showMax = not ReckoningTrackerDB.showMax
    print("Max stack display "..(ReckoningTrackerDB.showMax and "|cff00ff00Enabled" or "|cffff0000Disabled"))
    UpdateDisplay()
else
    print("|cff00ffffReckoning Tracker Commands:")
    print("|cff00ff00/reckoning toggle|r - Toggle display")
    print("|cff00ff00/reckoning lock|r - Lock/unlock position")
    print("|cff00ff00/reckoning reset|r - Reset stacks")
    print("|cff00ff00/reckoning max|r - Toggle max stack display")
end
end

-- Initialization
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", OnEvent)

-- Setup Complete
print("|cff00ffffReckoningTracker loaded|r - Type /reckoning for options")