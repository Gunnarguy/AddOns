-- Main.lua

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

local FocusClassic = CreateFrame("Frame", "FocusClassicFrame", UIParent, "BackdropTemplate")

FocusClassicDB = FocusClassicDB or {}
if FocusClassicDB.FocusMarkEnabled == nil then
    FocusClassicDB.FocusMarkEnabled = false
end

-- Variables globales
focusGUID = nil
focusUnit = nil
isFocusValid = true

-- Fonction appelée au chargement de l'addon
local function OnAddonLoaded()
    C_Timer.After(1, function()
        print("|cff00ff00[Focus Classic]|r " .. L["Addon loaded! Use /setfocus to set a target."])
        print("|cff00ff00[Focus Classic]|r " .. L["Use /focusmacro to create the macro."])
    end)
end

-- Gestion des événements
FocusClassic:RegisterEvent("ADDON_LOADED")
FocusClassic:RegisterEvent("UNIT_TARGET")
FocusClassic:RegisterEvent("GROUP_ROSTER_UPDATE")
FocusClassic:RegisterEvent("PLAYER_ENTERING_WORLD")
FocusClassic:RegisterEvent("UNIT_HEALTH")
FocusClassic:RegisterEvent("UNIT_POWER_UPDATE") -- Utiliser UNIT_POWER_UPDATE pour Classic Era
FocusClassic:RegisterEvent("RAID_TARGET_UPDATE") -- Ajouter l'événement pour les changements de repère

FocusClassic:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "FocusClassic" then
        OnAddonLoaded()
    elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_UPDATE" then
        -- Vérifier si l'événement concerne notre unité focus
        if focusUnit and arg1 == focusUnit then
            Focus_Update()
        end
    elseif event == "UNIT_TARGET" or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        -- Pour les autres événements majeurs, mise à jour complète
        Focus_Update()
    elseif event == "RAID_TARGET_UPDATE" then
        -- Pour cet événement, seule l'infobulle doit être mise à jour
        -- pour éviter les boucles avec l'auto-marquage.
        if Focus_UpdateTooltip then -- Vérifie que la fonction existe
            Focus_UpdateTooltip()
        end
    end
end)