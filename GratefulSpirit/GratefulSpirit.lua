-- GratefulSpirit.lua revised for WoW Classic with integrated functionality:
-- - Draggable, compact, vertically arranged UI.
-- - Spirit-based regeneration formulas:
--       Health Regen (OOC): (Spirit * 0.5 + 15) per 2 sec → per sec = (spirit * 0.5 + 15) / 2
--       Mana Regen (OOC):   (Spirit * 0.25 + 15) per 2 sec → per sec = (spirit * 0.25 + 15) / 2
--       Combat Mana Regen (non-healer): ~30% of out-of-combat mana regen.
-- - "Base Spirit" is calculated by subtracting bonus spirit (from GetSpellBonusStat).
-- - Session tracking accumulates regeneration only when the specific stat (health or mana) is below its maximum.
--
-- These formulas and behaviors are consistent with community-accepted data for WoW Classic.

-- Create the main frame with BackdropTemplate support if available.
local GratefulSpiritFrame = CreateFrame("Frame", "GratefulSpiritFrame", UIParent,
    BackdropTemplateMixin and "BackdropTemplate" or nil)
GratefulSpiritFrame:SetSize(220, 140)  -- Compact size for a less obtrusive display.
GratefulSpiritFrame:SetPoint("CENTER")

-- Enable dragging to reposition the frame.
GratefulSpiritFrame:EnableMouse(true)
GratefulSpiritFrame:SetMovable(true)
GratefulSpiritFrame:RegisterForDrag("LeftButton")
GratefulSpiritFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
GratefulSpiritFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Set a subtle backdrop.
GratefulSpiritFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
GratefulSpiritFrame:SetBackdropColor(0, 0, 0, 0.5)

-- Create UI elements arranged vertically using a smaller font.
local title = GratefulSpiritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", GratefulSpiritFrame, "TOP", 0, -5)
title:SetText("GratefulSpirit (Classic)")
title:SetJustifyH("CENTER")

local healthText = GratefulSpiritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
healthText:SetPoint("TOP", title, "BOTTOM", 0, -2)
healthText:SetJustifyH("CENTER")

local manaText = GratefulSpiritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
manaText:SetPoint("TOP", healthText, "BOTTOM", 0, -2)
manaText:SetJustifyH("CENTER")

local combatManaText = GratefulSpiritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
combatManaText:SetPoint("TOP", manaText, "BOTTOM", 0, -2)
combatManaText:SetJustifyH("CENTER")

local sessionText = GratefulSpiritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sessionText:SetPoint("TOP", combatManaText, "BOTTOM", 0, -2)
sessionText:SetJustifyH("CENTER")

local buffText = GratefulSpiritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
buffText:SetPoint("TOP", sessionText, "BOTTOM", 0, -2)
buffText:SetJustifyH("CENTER")

-- Variables for session tracking.
local sessionManaGained, sessionHealthGained = 0, 0
local updateInterval, timeSinceLastUpdate = 0.5, 0

-- UpdateDisplay: Calculates and displays current regeneration values.
local function UpdateDisplay()
    -- Get current Spirit stat.
    local spirit = UnitStat("player", 5)  -- Stat index 5 is Spirit.
    local bonusSpirit = 0
    if GetSpellBonusStat then
        -- Use index 4 to get bonus Spirit from gear/buffs.
        bonusSpirit = GetSpellBonusStat(4) or 0  
    end
    local baseSpirit = spirit - bonusSpirit

    -- Calculate regeneration per tick (tick = 2 seconds, out-of-combat).
    local healthRegenPerTick = (spirit * 0.5 + 15)
    local manaRegenPerTick   = (spirit * 0.25 + 15)

    -- Convert to per-second rates.
    local healthRegenPerSec = healthRegenPerTick / 2
    local manaRegenPerSec   = manaRegenPerTick / 2

    -- Calculate in-combat mana regeneration (approx. 30% of full regen for non-healers).
    local combatManaRegenPerSec = manaRegenPerSec * 0.3

    -- Update display texts.
    healthText:SetText(string.format("HP Regen: %.2f/sec", healthRegenPerSec))
    manaText:SetText(string.format("MP Regen: %.2f/sec", manaRegenPerSec))
    combatManaText:SetText(string.format("Combat MP: %.2f/sec", combatManaRegenPerSec))
    buffText:SetText(string.format("Spirit: %d (Base: %d)", spirit, baseSpirit))
    sessionText:SetText(string.format("Session - HP: %.2f, MP: %.2f", sessionHealthGained, sessionManaGained))
end

-- OnUpdate script: Updates session tracking and display every updateInterval.
GratefulSpiritFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= updateInterval then
        if not UnitAffectingCombat("player") then
            local currentHealth, maxHealth = UnitHealth("player"), UnitHealthMax("player")
            local currentMana, maxMana = UnitMana("player"), UnitManaMax("player")
            local spirit = UnitStat("player", 5)
            local healthRegenPerTick = (spirit * 0.5 + 15)
            local manaRegenPerTick   = (spirit * 0.25 + 15)
            -- Accumulate health regeneration only if health is not full.
            if currentHealth < maxHealth then
                sessionHealthGained = sessionHealthGained + (healthRegenPerTick * updateInterval / 2)
            end
            -- Accumulate mana regeneration only if mana is not full.
            if currentMana < maxMana then
                sessionManaGained = sessionManaGained + (manaRegenPerTick * updateInterval / 2)
            end
        end
        UpdateDisplay()
        timeSinceLastUpdate = 0
    end
end)

-- Initial display update.
UpdateDisplay()