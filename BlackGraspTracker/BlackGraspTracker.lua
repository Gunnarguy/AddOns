-- BlackGraspTracker.lua
-- Tracks mana drain from Black Grasp of the Destroyer (spell 27522 -> 18350)
-- Classic Anniversary 1.15.7

local ADDON_NAME, _ = ...
BlackGraspTrackerDB = BlackGraspTrackerDB or {}

-- Spell IDs for Black Grasp
local BUFF_SPELL_ID = 27522      -- The buff/aura applied
local DRAIN_SPELL_ID = 18350     -- The triggered mana drain spell
local EXPECTED_DRAIN = 100       -- Expected mana drain amount

-- Initialize defaults
local defaults = {
    position = {"CENTER", "UIParent", "CENTER", 0, -200},
    locked = false,
    scale = 1.0,
    alpha = 0.9,
    -- Tracking data
    session = {
        procs = 0,
        totalDrained = 0,
        targets = {},  -- Track drain per target
        startTime = 0,
        combatDrains = {},  -- Drain amounts per combat
    },
    allTime = {
        procs = 0,
        totalDrained = 0,
        highestDrain = 0,
        averageDrain = 0,
    },
    current = {
        inCombat = false,
        combatProcs = 0,
        combatDrained = 0,
        combatStartTime = 0,
    },
    settings = {
        showInCombatOnly = false,
        announceProcs = true,
        trackTargets = true,
    }
}

-- Helper functions
local function mergeDefaults(db, defaults)
    db = db or {}
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            db[k] = mergeDefaults(db[k], v)
        elseif db[k] == nil then
            db[k] = v
        end
    end
    return db
end

local function formatNumber(num)
    if not num then return "0" end
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num + 0.5))
    end
end

-- Main frame
local BGT = CreateFrame("Frame", "BlackGraspTrackerFrame", UIParent)
local ui = nil

-- UI Creation
local function createUI()
    if ui then return end
    
    local db = BlackGraspTrackerDB
    ui = CreateFrame("Frame", "BGT_MainFrame", UIParent, "BackdropTemplate")
    ui:SetSize(250, 180)
    ui:SetScale(db.scale or 1.0)
    ui:SetAlpha(db.alpha or 0.9)
    ui:SetPoint(unpack(db.position))
    ui:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, tileSize = 16, edgeSize = 12,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    ui:SetBackdropColor(0, 0, 0, 0.8)
    ui:SetBackdropBorderColor(0.5, 0, 0.8, 1)
    ui:SetMovable(true)
    ui:EnableMouse(not db.locked)
    ui:RegisterForDrag("LeftButton")
    
    -- Make draggable
    ui:SetScript("OnDragStart", function(self)
        if not db.locked then
            self:StartMoving()
        end
    end)
    
    ui:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        db.position = {self:GetPoint(1)}
    end)
    
    -- Title
    ui.title = ui:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ui.title:SetPoint("TOP", 0, -8)
    ui.title:SetText("|cFF9B30FFBlack Grasp Tracker|r")
    
    -- Create display rows
    local function createRow(parent, label, yOffset)
        local row = {}
        row.label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.label:SetPoint("TOPLEFT", 10, yOffset)
        row.label:SetText(label)
        row.label:SetTextColor(0.8, 0.8, 0.8)
        
        row.value = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.value:SetPoint("TOPRIGHT", -10, yOffset)
        row.value:SetText("0")
        
        return row
    end
    
    ui.rows = {}
    ui.rows.sessionProcs = createRow(ui, "Session Procs:", -30)
    ui.rows.sessionDrained = createRow(ui, "Session Drained:", -48)
    ui.rows.combatProcs = createRow(ui, "Combat Procs:", -66)
    ui.rows.combatDrained = createRow(ui, "Combat Drained:", -84)
    ui.rows.avgDrain = createRow(ui, "Avg per Proc:", -102)
    ui.rows.totalProcs = createRow(ui, "Total Procs:", -120)
    ui.rows.totalDrained = createRow(ui, "Total Drained:", -138)
    
    -- Status indicator
    ui.status = ui:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ui.status:SetPoint("BOTTOM", 0, 8)
    ui.status:SetText("|cFF808080Ready|r")
    
    -- Tooltip
    ui:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Black Grasp Tracker", 0.6, 0.2, 1)
        GameTooltip:AddLine(" ")
        
        if db.locked then
            GameTooltip:AddLine("Frame is |cFFFF0000LOCKED|r", 1, 1, 1)
        else
            GameTooltip:AddLine("Left-drag to move", 0.8, 0.8, 0.8)
        end
        
        -- Show top targets if tracked
        if db.settings.trackTargets and db.session.targets then
            local sorted = {}
            for name, amount in pairs(db.session.targets) do
                table.insert(sorted, {name = name, amount = amount})
            end
            table.sort(sorted, function(a, b) return a.amount > b.amount end)
            
            if #sorted > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Top Drain Targets:", 1, 0.8, 0)
                for i = 1, math.min(5, #sorted) do
                    GameTooltip:AddDoubleLine(
                        sorted[i].name,
                        formatNumber(sorted[i].amount),
                        0.8, 0.8, 0.8,
                        0.6, 0.2, 1
                    )
                end
            end
        end
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Commands:", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("/bgt - show help", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    ui:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return ui
end

-- Update UI display
local function updateUI()
    if not ui then return end
    
    local db = BlackGraspTrackerDB
    local session = db.session
    local current = db.current
    local allTime = db.allTime
    
    -- Update values
    ui.rows.sessionProcs.value:SetText("|cFF9B30FF" .. tostring(session.procs) .. "|r")
    ui.rows.sessionDrained.value:SetText("|cFF00FF00" .. formatNumber(session.totalDrained) .. "|r")
    ui.rows.combatProcs.value:SetText("|cFFFFFF00" .. tostring(current.combatProcs) .. "|r")
    ui.rows.combatDrained.value:SetText("|cFFFF8000" .. formatNumber(current.combatDrained) .. "|r")
    
    -- Calculate average
    local avgDrain = session.procs > 0 and (session.totalDrained / session.procs) or 0
    ui.rows.avgDrain.value:SetText("|cFF00FFFF" .. string.format("%.1f", avgDrain) .. "|r")
    
    ui.rows.totalProcs.value:SetText("|cFF808080" .. tostring(allTime.procs) .. "|r")
    ui.rows.totalDrained.value:SetText("|cFF808080" .. formatNumber(allTime.totalDrained) .. "|r")
    
    -- Update status
    if current.inCombat then
        ui.status:SetText("|cFFFF0000In Combat|r")
    else
        ui.status:SetText("|cFF00FF00Ready|r")
    end
    
    -- Handle visibility
    if db.settings.showInCombatOnly then
        if current.inCombat then
            ui:Show()
        else
            ui:Hide()
        end
    end
end

-- Track mana drain event
local function onManaDrain(timestamp, sourceGUID, sourceName, destGUID, destName, spellId, amount, powerType)
    -- Verify it's our spell and it's mana
    if spellId ~= DRAIN_SPELL_ID or powerType ~= 0 then return end
    
    -- Verify source is player
    if sourceGUID ~= UnitGUID("player") then return end
    
    local db = BlackGraspTrackerDB
    
    -- Update session stats
    db.session.procs = db.session.procs + 1
    db.session.totalDrained = db.session.totalDrained + amount
    
    -- Track per target
    if db.settings.trackTargets and destName then
        db.session.targets[destName] = (db.session.targets[destName] or 0) + amount
    end
    
    -- Update combat stats
    if db.current.inCombat then
        db.current.combatProcs = db.current.combatProcs + 1
        db.current.combatDrained = db.current.combatDrained + amount
        
        -- Track per-combat drains
        table.insert(db.session.combatDrains, amount)
    end
    
    -- Update all-time stats
    db.allTime.procs = db.allTime.procs + 1
    db.allTime.totalDrained = db.allTime.totalDrained + amount
    if amount > db.allTime.highestDrain then
        db.allTime.highestDrain = amount
    end
    db.allTime.averageDrain = db.allTime.totalDrained / db.allTime.procs
    
    -- Announce if enabled
    if db.settings.announceProcs then
        local msg = string.format("|cFF9B30FFBlack Grasp|r drained |cFF00FF00%d|r mana from |cFFFF8000%s|r", 
            amount, destName or "Unknown")
        print(msg)
    end
    
    updateUI()
end

-- Event handler
BGT:RegisterEvent("ADDON_LOADED")
BGT:RegisterEvent("PLAYER_LOGIN")
BGT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BGT:RegisterEvent("PLAYER_REGEN_DISABLED")
BGT:RegisterEvent("PLAYER_REGEN_ENABLED")

BGT:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        BlackGraspTrackerDB = mergeDefaults(BlackGraspTrackerDB, defaults)
        
    elseif event == "PLAYER_LOGIN" then
        -- Initialize session time
        BlackGraspTrackerDB.session.startTime = GetTime()
        createUI()
        updateUI()
        print("|cFF9B30FFBlack Grasp Tracker|r loaded. Type /bgt for help.")
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local info = {CombatLogGetCurrentEventInfo()}
        local timestamp = info[1]
        local subevent = info[2]
        local sourceGUID = info[4]
        local sourceName = info[5]
        local destGUID = info[8]
        local destName = info[9]
        local spellId = info[12]
        
        -- Check for SPELL_DRAIN events
        if subevent == "SPELL_DRAIN" then
            local amount = info[15]
            local powerType = info[16]
            onManaDrain(timestamp, sourceGUID, sourceName, destGUID, destName, spellId, amount, powerType)
            
        -- Also check SPELL_ENERGIZE in case the drain appears as energize to enemy
        elseif subevent == "SPELL_ENERGIZE" and spellId == DRAIN_SPELL_ID then
            local amount = info[15]
            local powerType = info[16]
            -- For energize, the source/dest might be reversed
            onManaDrain(timestamp, destGUID, destName, sourceGUID, sourceName, spellId, amount, powerType)
        end
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Combat started
        local db = BlackGraspTrackerDB
        db.current.inCombat = true
        db.current.combatProcs = 0
        db.current.combatDrained = 0
        db.current.combatStartTime = GetTime()
        updateUI()
        
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended
        local db = BlackGraspTrackerDB
        db.current.inCombat = false
        
        -- Show combat summary if there were procs
        if db.current.combatProcs > 0 then
            local duration = GetTime() - db.current.combatStartTime
            print(string.format("|cFF9B30FFCombat Summary:|r %d procs, %s mana drained in %.1fs",
                db.current.combatProcs,
                formatNumber(db.current.combatDrained),
                duration))
        end
        
        updateUI()
    end
end)

-- Slash commands
SLASH_BGT1 = "/bgt"
SLASH_BGT2 = "/blackgrasp"

SlashCmdList["BGT"] = function(msg)
    msg = msg:lower()
    
    if msg == "show" then
        if not ui then createUI() end
        ui:Show()
        
    elseif msg == "hide" then
        if ui then ui:Hide() end
        
    elseif msg == "toggle" then
        if not ui then createUI() end
        if ui:IsShown() then ui:Hide() else ui:Show() end
        
    elseif msg == "lock" then
        BlackGraspTrackerDB.locked = true
        if ui then ui:EnableMouse(false) end
        print("|cFF9B30FFBGT:|r Frame locked")
        
    elseif msg == "unlock" then
        BlackGraspTrackerDB.locked = false
        if ui then ui:EnableMouse(true) end
        print("|cFF9B30FFBGT:|r Frame unlocked")
        
    elseif msg == "reset session" then
        BlackGraspTrackerDB.session = {
            procs = 0,
            totalDrained = 0,
            targets = {},
            startTime = GetTime(),
            combatDrains = {},
        }
        updateUI()
        print("|cFF9B30FFBGT:|r Session data reset")
        
    elseif msg == "reset all" then
        BlackGraspTrackerDB = mergeDefaults({}, defaults)
        BlackGraspTrackerDB.session.startTime = GetTime()
        updateUI()
        print("|cFF9B30FFBGT:|r All data reset")
        
    elseif msg == "announce on" then
        BlackGraspTrackerDB.settings.announceProcs = true
        print("|cFF9B30FFBGT:|r Proc announcements enabled")
        
    elseif msg == "announce off" then
        BlackGraspTrackerDB.settings.announceProcs = false
        print("|cFF9B30FFBGT:|r Proc announcements disabled")
        
    elseif msg == "combat" then
        BlackGraspTrackerDB.settings.showInCombatOnly = not BlackGraspTrackerDB.settings.showInCombatOnly
        print("|cFF9B30FFBGT:|r Show in combat only: " .. 
            (BlackGraspTrackerDB.settings.showInCombatOnly and "ON" or "OFF"))
        updateUI()
        
    else
        print("|cFF9B30FFBlack Grasp Tracker Commands:|r")
        print("  /bgt show - Show the tracker")
        print("  /bgt hide - Hide the tracker")
        print("  /bgt toggle - Toggle visibility")
        print("  /bgt lock - Lock frame position")
        print("  /bgt unlock - Unlock frame position")
        print("  /bgt combat - Toggle show in combat only")
        print("  /bgt announce on/off - Toggle proc announcements")
        print("  /bgt reset session - Reset session data")
        print("  /bgt reset all - Reset all data")
    end
end
