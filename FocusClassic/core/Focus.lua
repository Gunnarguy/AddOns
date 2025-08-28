-- Focus.lua

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

function FindUnitByGUID(guid)
    if not guid then return nil end
    if UnitGUID("target") == guid then return "target" end
    if UnitGUID("player") == guid then return "player" end
    for i = 1, 4 do
        if UnitGUID("party"..i) == guid then return "party"..i end
    end
    for i = 1, 40 do
        if UnitGUID("raid"..i) == guid then return "raid"..i end
    end
    return nil
end

function Focus_Update()
    if not focusGUID then return end
    focusUnit = FindUnitByGUID(focusGUID)
    
    if focusUnit and UnitExists(focusUnit) then
        local focusName = UnitName(focusUnit) or "Inconnu"
        local targetName = UnitName(focusUnit.."target") or L["No target"]

        if Focus_UpdateUI then
            Focus_UpdateUI(focusName, targetName)
        else
            print("|cffff0000[Focus Classic] Erreur : Focus_UpdateUI n'est pas défini.|r")
        end

        isFocusValid = true
    else
        if isFocusValid then
            print("|cffff0000[Focus Classic] La cible du focus n'est plus valide.|r")
            isFocusValid = false
        end

        if Focus_UpdateUI then
            Focus_UpdateUI("Invalide", "Invalide")
        end
    end
end

function Focus_Clear()
    Focus_UpdateUI("Aucun", "Aucune")
    print("|cffff0000[Focus Classic] " .. L["Focus cleared."] .. "|r")
end