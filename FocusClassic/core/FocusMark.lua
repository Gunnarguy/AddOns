-- FocusMark.lua (Module de marquage automatique du crâne)

-- Détection de la langue du client
local clientLocale = GetLocale()

-- Chargement des traductions en fonction de la langue détectée
if clientLocale == "frFR" then
    L = L_FR
elseif clientLocale == "enUS" then
    L = L_EN
else
    -- Par défaut, utiliser l'anglais si la langue du client n'est pas prise en charge
    L = L_EN
end

local skullIcon = 8 -- Icône du crâne
local focusTargetGUID = nil
local wasSkullSet = false -- Vérifie si le crâne a été mis manuellement

-- Chargement de la config globale
if not FocusClassicDB then FocusClassicDB = {} end
if FocusClassicDB.FocusMarkEnabled == nil then FocusClassicDB.FocusMarkEnabled = true end

-- Vérifie si une unité a un crâne
local function HasSkull(unit)
    return unit and GetRaidTargetIndex(unit) == skullIcon
end

-- Applique le crâne sur une unité
local function ApplySkull(unit)
    if unit and UnitExists(unit) and FocusClassicDB.FocusMarkEnabled then
        SetRaidTarget(unit, skullIcon)
    end
end

-- Détecte quand un crâne est mis manuellement
hooksecurefunc("SetRaidTarget", function(unit, index)
    if index == skullIcon and UnitExists(unit) then
        wasSkullSet = true
    end
end)

-- Met à jour la cible du focus et applique le crâne si nécessaire
local function UpdateFocusTarget()
    if not focusGUID or not FocusClassicDB.FocusMarkEnabled then return end
    local focusUnit = FindUnitByGUID(focusGUID)
    
    if focusUnit and UnitExists(focusUnit .. "target") then
        focusTargetGUID = UnitGUID(focusUnit .. "target")
        
        -- Vérifie si un crâne était déjà mis avant le changement de focus
        if HasSkull("target") then
            wasSkullSet = true
        end
        
        -- Appliquer le crâne seulement si il a été mis manuellement
        if wasSkullSet then
            ApplySkull(focusUnit .. "target")
        end
    end
end

-- Événement pour suivre la mort de la cible du focus
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(_, _, event, _, _, _, _, _, destGUID)
    if event == "UNIT_DIED" and destGUID == focusTargetGUID then
        C_Timer.After(0.5, UpdateFocusTarget) -- Petit délai pour éviter un conflit
    end
end)

-- Intégration avec Focus Classic
hooksecurefunc("Focus_Update", UpdateFocusTarget)