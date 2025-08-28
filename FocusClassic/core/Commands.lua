-- Commands.lua

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

SLASH_SETFOCUS1 = "/setfocus"
SlashCmdList["SETFOCUS"] = function()
    if UnitExists("target") then
        focusGUID = UnitGUID("target")
        focusUnit = FindUnitByGUID(focusGUID)
        print("|cff00ff00[Focus Classic]|r " .. L["Focus set on: "] .. (UnitName("target") or "Inconnu"))
        Focus_Update()
    else
        print("|cffff0000[Focus Classic] " .. L["Error: You must select a target."] .. "|r")
    end
end

SLASH_CLEARFOCUS1 = "/clearfocus"
SlashCmdList["CLEARFOCUS"] = function()
    focusGUID = nil
    focusUnit = nil
    Focus_Clear()
end

SLASH_FOCUSMACRO1 = "/focusmacro"
SlashCmdList["FOCUSMACRO"] = function()
    local macroName = "SetFocus"
    local macroText = "/setfocus"
    
    if GetMacroInfo(macroName) then
        print("|cffff0000[Focus Classic] " .. L["Macro already exists!"] .. "|r")
        return
    end
    
    if GetNumMacros() < 120 then
        local macroIndex = CreateMacro(macroName, "Ability_Hunter_MarkedForDeath", macroText, nil)
        if macroIndex then
            print("|cff00ff00[Focus Classic]|r " .. L["Macro '/setfocus' created successfully, place it on your action bar!"])
            PickupMacro(macroIndex)
        else
            print("|cffff0000[Focus Classic] " .. L["Error creating macro."] .. "|r")
        end
    else
        print("|cffff0000[Focus Classic] " .. L["Maximum number of macros reached."] .. "|r")
    end
end