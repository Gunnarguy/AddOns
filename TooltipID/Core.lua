local addonName, addonTable = ...
local debugging = false

local AuraTooltip = CreateFrame("GameTooltip", "AuraTooltip", UIParent, "GameTooltipTemplate")
AuraTooltip:SetFrameStrata("TOOLTIP")

-- Set a smaller font size for the AuraTooltip
local font, fontSize, fontFlags = GameTooltipTextLeft1:GetFont()
AuraTooltipTextLeft1:SetFont(font, fontSize - 2, fontFlags)



local function debugger(message)
    if debugging then
        print(message)
    end
end

local function CheckForbidden(tooltip)
    if debugging then
        if tooltip:IsForbidden() then
            debugger("Forbidden tooltip: " .. tooltip:GetName())
        end
    end
    return tooltip:IsForbidden()
end

local function AddLine(tooltip, id, type, spacer)
    if not tooltip or not id then return end

    if spacer == nil then
        spacer = true
    end
    if spacer then
        tooltip:AddLine(" ")
    end
    tooltip:AddLine(type.."ID: ".."|cffFFFFCF"..id.."|r", 1, 1, 1)
    tooltip:Show()
end

local function HookItemTooltip(tooltip)
    local _, link = tooltip:GetItem()
    if not link or CheckForbidden(tooltip) then return end
    local itemID = tonumber(link:match("item:(%d+)"))
    AddLine(tooltip, itemID, "Item")
end

local function HookSpellTooltip(tooltip)
    local _, spellID = tooltip:GetSpell()
    if not spellID or CheckForbidden(tooltip) then return end
    AddLine(tooltip, spellID, "Spell")
end

local function HookAuraTooltip(tooltip, unit, index, filter, spacer)
    local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID = UnitAura(unit, index, filter)
    if not spellID or CheckForbidden(tooltip) then return end
    AddLine(tooltip, spellID, "Aura", spacer)
end


local function HookUnitID(tooltip, data)
    if CheckForbidden(tooltip) then return end

    -- TooltipUtil.SurfaceArgs(data)
    if debugging then
        print(data)
    end
    local unitUID = data.guid
    local unitID = select(6, strsplit("-", unitUID))
    if not unitID then return end
    AddLine(tooltip, unitID, "Unit")
end

local function HookUnitTooltip(tooltip) 
    local _, unit = tooltip:GetUnit() 
    if unit then 
        debugger("Unit detected: " .. unit) 
        local data = { guid = UnitGUID(unit) } 
        HookUnitID(tooltip, data)
        -- Process aura tooltips 

        for i = 1, 40 do 
            local name, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i) 
            if name then 
                debugger("Processing aura: " .. name .. " with Spell ID: " .. spellID)
                HookAuraTooltip(tooltip, unit, i, nil, false) 
            end 
        end 
        -- Process unit ID 
         
    else 
        debugger("No unit detected in tooltip.") 
    end 
end

local function HookAuraTooltipDirect(unit, index)
    if unit and index then
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID = UnitAura(unit, index)
        if name then
            debugger("Hovered over Aura: " .. name .. " with Spell ID: " .. spellID)
            AuraTooltip:ClearLines()
            AddLine(AuraTooltip, spellID, "Aura", false)
            AuraTooltip:Show()  -- Ensure the tooltip remains visible
        end
    end
end



local function HookAuraButtons()
    local function OnEnter(self)
        local unit = self.unit or "player"
        local index = self:GetID()
        debugger("Hovering over aura: " .. (index or "Unknown ID"))
        AuraTooltip:SetOwner(GameTooltip, "ANCHOR_BOTTOMLEFT", GameTooltip:GetWidth(), 0) -- Anchor below the primary tooltip
        HookAuraTooltipDirect(unit, index)
    end

    local function OnLeave(self)
        AuraTooltip:Hide()
    end

    local auraIndex = 1
    repeat 
        local buff = _G["BuffButton" .. auraIndex] 
        if buff and not buff.hooked then 
            buff:HookScript("OnEnter", OnEnter) 
            buff:HookScript("OnLeave", OnLeave)
            buff.hooked = true  
        end
        auraIndex = auraIndex + 1
    until not buff 
    
    auraIndex = 1
    repeat
        local debuff = _G["DebuffButton" .. auraIndex] 
        if debuff and not debuff.hooked then 
            debuff:HookScript("OnEnter", OnEnter) 
            debuff:HookScript("OnLeave", OnLeave)
            debuff.hooked = true 
        end 
        auraIndex = auraIndex + 1
    until not debuff
end

local function OnAuraUpdate(self, event, unit)
    if unit == "player" or UnitIsUnit(unit, "player") then
        HookAuraButtons()
    end
end



-- Register hooks
GameTooltip:HookScript("OnTooltipSetItem", HookItemTooltip)
GameTooltip:HookScript("OnTooltipSetSpell", HookSpellTooltip)
GameTooltip:HookScript("OnTooltipSetUnit", HookUnitTooltip)

-- Hook aura buttons and listen for aura updates
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        HookAuraButtons()
    elseif event == "UNIT_AURA" then
        OnAuraUpdate(self, event, ...)
    end
end)




