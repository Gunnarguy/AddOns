-- UI.lua

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

-- Nom de l'addon
defaultAddonName = "FocusClassic"

-- Créer le cadre du focus
local focusFrame = CreateFrame("Frame", "FocusClassicUI", UIParent, "BackdropTemplate")
focusFrame:SetSize(200, 80)
focusFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
focusFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
focusFrame:Show()

-- Activer le déplacement de la fenêtre
focusFrame:SetMovable(true)
focusFrame:EnableMouse(true)
focusFrame:RegisterForDrag("LeftButton")
focusFrame:SetScript("OnDragStart", focusFrame.StartMoving)
focusFrame:SetScript("OnDragStop", focusFrame.StopMovingOrSizing)

-- Créer les textes avant d'appeler Focus_UpdateUI()
local addonTitle = focusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
addonTitle:SetPoint("TOP", focusFrame, "TOP", 0, -10)
addonTitle:SetText("|cffffcc00" .. defaultAddonName .. "|r")

local focusText = focusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
focusText:SetPoint("TOP", focusFrame, "TOP", 0, -30)

-- Créer la barre de vie du focus
local focusHealthBar = CreateFrame("StatusBar", "FocusHealthBar", focusFrame)
focusHealthBar:SetSize(100, 4)
focusHealthBar:SetPoint("TOP", focusText, "BOTTOM", 0, -2) -- Positionner sous le texte du focus
focusHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
focusHealthBar:GetStatusBarTexture():SetHorizTile(true)
focusHealthBar:SetStatusBarColor(0, 1, 0) -- Couleur verte pour la vie
focusHealthBar:SetFrameLevel(focusFrame:GetFrameLevel() + 1) -- Mettre au-dessus du parent
focusHealthBar:SetFrameStrata("MEDIUM") -- Définir une strate moyenne
focusHealthBar:Hide() -- Cacher par défaut

-- Créer la barre de mana du focus
local focusManaBar = CreateFrame("StatusBar", "FocusManaBar", focusFrame)
focusManaBar:SetSize(100, 4)
focusManaBar:SetPoint("TOP", focusHealthBar, "BOTTOM", 0, -1) -- Positionner sous la barre de vie
focusManaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
focusManaBar:GetStatusBarTexture():SetHorizTile(true)
focusManaBar:SetStatusBarColor(0, 0, 1) -- Couleur bleue pour le mana
focusManaBar:SetFrameLevel(focusFrame:GetFrameLevel() + 1) -- Mettre au-dessus du parent
focusManaBar:SetFrameStrata("MEDIUM") -- Définir une strate moyenne
focusManaBar:Hide() -- Cacher par défaut

local focusTargetText = focusFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
focusTargetText:SetPoint("TOP", focusManaBar, "BOTTOM", 0, -2) -- Ajuster la position du texte de la cible

-- Définition de Focus_UpdateUI après la déclaration des éléments
function Focus_UpdateUI(focusName, targetName)
    if focusName and focusName ~= "" and focusName ~= "Invalide" and focusName ~= "Aucun" then
        -- Tronquer les noms si trop longs
        local maxLen = 18
        local displayFocusName = focusName
        local displayTargetName = targetName
        if strlen(focusName) > maxLen then
            displayFocusName = strsub(focusName, 1, maxLen - 3) .. "..."
        end
        if strlen(targetName) > maxLen then
            displayTargetName = strsub(targetName, 1, maxLen - 3) .. "..."
        end
        
        focusText:SetText("|cff00ff00Focus :|r |cff00ccff" .. displayFocusName .. "|r")

        -- Tentative de mise à jour des barres uniquement si focusUnit est valide
        if focusUnit and UnitExists(focusUnit) then
            -- Mise à jour de la barre de vie
            local health = UnitHealth(focusUnit)
            local maxHealth = UnitHealthMax(focusUnit)
            if health and maxHealth and maxHealth > 0 and FocusClassicDB.HealthBarEnabled then
                focusHealthBar:SetMinMaxValues(0, maxHealth)
                focusHealthBar:SetValue(health)
                focusHealthBar:Show()
            else
                focusHealthBar:Hide()
            end

            -- Mise à jour de la barre de mana/ressource
            local powerType, powerToken = UnitPowerType(focusUnit)
            local power = UnitPower(focusUnit, powerType)
            local maxPower = UnitPowerMax(focusUnit, powerType)

            if power and maxPower and maxPower > 0 and FocusClassicDB.ResourceBarEnabled then
                focusManaBar:SetMinMaxValues(0, maxPower)
                focusManaBar:SetValue(power)
                if powerToken == "MANA" then
                    focusManaBar:SetStatusBarColor(0, 0, 1) -- Bleu
                elseif powerToken == "RAGE" then
                    focusManaBar:SetStatusBarColor(1, 0, 0) -- Rouge
                elseif powerToken == "ENERGY" then
                    focusManaBar:SetStatusBarColor(1, 1, 0) -- Jaune
                else
                    focusManaBar:SetStatusBarColor(0.5, 0.5, 0.5) -- Gris par défaut
                end
                focusManaBar:Show()
            else
                focusManaBar:Hide() -- Cacher si pas de ressource, informations non disponibles ou option désactivée
            end
        else
             -- print("[Debug] focusUnit is NOT valid or does not exist:", focusUnit)
             -- Si focusUnit n'est pas valide (hors de portée?), on cache les barres
            focusHealthBar:Hide()
            focusManaBar:Hide()
        end

        focusTargetText:SetText("|cffffff00Cible :|r |cffffcc00" .. displayTargetName .. "|r")
        focusTargetText:Show()
        
        -- Mettre à jour l'infobulle
        Focus_UpdateTooltip()

    else
        -- print("[Debug] No valid focus name.")
        -- Cas où il n'y a pas de focus (ou invalide)
        focusText:SetText("|cff00ff00Focus :|r " .. (focusName == "Invalide" and L["Invalid"] or L["None"]))
        focusTargetText:Hide()
        focusHealthBar:Hide()
        focusManaBar:Hide()
        -- Désactiver l'infobulle quand il n'y a pas de focus
        focusTargetText:SetScript("OnEnter", nil)
        focusTargetText:SetScript("OnLeave", nil)
    end
end

-- Fonction dédiée pour mettre à jour l'infobulle de la cible du focus
function Focus_UpdateTooltip()
    if focusTargetText and focusUnit and UnitExists(focusUnit .. "target") then
        focusTargetText:EnableMouse(true) -- S'assurer que la souris est activée
        focusTargetText:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local targetUnit = focusUnit .. "target"
            local currentIcon = GetRaidTargetIndex(targetUnit)
            if currentIcon == 8 then -- 8 = Crâne
                GameTooltip:SetText(L["Tooltip remove mark"], 1, 0.82, 0, 1, true) -- Texte en jaune, retour à la ligne activé
            else
                GameTooltip:SetText(L["Tooltip add mark"], 1, 0.82, 0, 1, true) -- Texte en jaune, retour à la ligne activé
            end
            GameTooltip:Show()
        end)
        focusTargetText:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    elseif focusTargetText then
        -- Pas de focus valide ou pas de cible, on désactive/cache l'infobulle spécifique
        focusTargetText:SetScript("OnEnter", nil)
        focusTargetText:SetScript("OnLeave", nil)
    end
end

-- Remettre en place le script OnMouseDown pour gérer les clics sur le texte de la cible
focusTargetText:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        if focusUnit and UnitExists(focusUnit.."target") then
            local targetUnit = focusUnit.."target"
            if UnitExists(targetUnit) then
                SetRaidTargetIcon(targetUnit, 8)  -- 8 correspond à l'icône de raid 'skull'
            end
        end
    elseif button == "RightButton" then
        if focusUnit and UnitExists(focusUnit.."target") then
            local targetUnit = focusUnit.."target"
            if UnitExists(targetUnit) then
                SetRaidTargetIcon(targetUnit, 0)  -- 0 correspond à enlever l'icône de raid
            end
        end
    end
    -- On met à jour l'UI pour refléter immédiatement le changement d'icône dans l'infobulle
    C_Timer.After(0.1, function() Focus_UpdateTooltip() end) -- Appelle seulement la mise à jour du tooltip
end)

-- Bouton pour clear le focus
local clearFocusButton = CreateFrame("Button", nil, focusFrame)
clearFocusButton:SetSize(16, 16)
clearFocusButton:SetPoint("TOPRIGHT", focusFrame, "TOPRIGHT", -8, -8)
clearFocusButton:SetNormalTexture("Interface\\AddOns\\FocusClassic\\ressources\\clear-focus-icon.blp")
clearFocusButton:SetScript("OnClick", function()
    SlashCmdList["CLEARFOCUS"]()
end)
clearFocusButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(clearFocusButton, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Click to clear focus"], 1, 1, 1)
    GameTooltip:Show()
end)
clearFocusButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Icône de création de macro
local macroIcon = CreateFrame("Button", nil, focusFrame)
macroIcon:SetSize(16, 16)
macroIcon:SetPoint("TOPLEFT", focusFrame, "TOPLEFT", 8, -8)
macroIcon:SetNormalTexture("Interface\\AddOns\\FocusClassic\\ressources\\macro-icon.blp")

-- Fonction pour vérifier si la macro existe déjà
local function DoesMacroExist()
    local numGlobal, numPerChar = GetNumMacros()
    -- Vérifier les macros globales
    for i = 1, numGlobal do
        local name = GetMacroInfo(i)
        if name == "SetFocus" then
            return true
        end
    end
    -- Vérifier les macros spécifiques au personnage
    local perCharStart = MAX_ACCOUNT_MACROS + 1
    local perCharEnd = MAX_ACCOUNT_MACROS + numPerChar
    for i = perCharStart, perCharEnd do
        local name = GetMacroInfo(i)
        if name == "SetFocus" then
            return true
        end
    end
    return false
end

-- Fonction pour mettre à jour l'apparence de l'icône de macro
local function UpdateMacroIcon()
    if DoesMacroExist() then
        macroIcon:SetAlpha(0.5)
    else
        macroIcon:SetAlpha(1)
    end
end

macroIcon:SetScript("OnClick", function()
    if DoesMacroExist() then
        -- Si la macro existe, ouvrir le menu des macros
        ShowMacroFrame()
    else
        -- Sinon, créer la macro
        SlashCmdList["FOCUSMACRO"]()
        C_Timer.After(0.1, UpdateMacroIcon) -- Petit délai pour s'assurer que la macro est créée
    end
end)

macroIcon:SetScript("OnEnter", function()
    GameTooltip:SetOwner(macroIcon, "ANCHOR_RIGHT")
    if DoesMacroExist() then
        GameTooltip:AddLine(L["Macro exists"], 1, 1, 0) -- Texte en jaune
        GameTooltip:AddLine(L["Open macro menu"], 0, 1, 0) -- Texte en vert
    else
        GameTooltip:SetText(L["Click to create the macro"], 1, 1, 0) -- Texte en jaune
    end
    GameTooltip:Show()
end)

macroIcon:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Mettre à jour l'état initial de l'icône
UpdateMacroIcon()

-- Enregistrer un événement pour mettre à jour l'icône quand les macros changent
local macroEventFrame = CreateFrame("Frame")
macroEventFrame:RegisterEvent("PLAYER_LOGIN")
macroEventFrame:RegisterEvent("UPDATE_MACROS")
macroEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
macroEventFrame:SetScript("OnEvent", function(self, event)
    C_Timer.After(0.5, UpdateMacroIcon) -- Petit délai pour s'assurer que les macros sont chargées
end)

-- Vérifier que FocusClassicDB est initialisé
if not FocusClassicDB then
    FocusClassicDB = {}
end
if FocusClassicDB.FocusMarkEnabled == nil then
    FocusClassicDB.FocusMarkEnabled = false
end

-- Bouton sous forme d'icône pour activer/désactiver l'auto-crâne
local skullToggleButton = CreateFrame("Button", "FocusClassicSkullToggle", focusFrame)
skullToggleButton:SetSize(16, 16)
skullToggleButton:SetPoint("TOPRIGHT", clearFocusButton, "TOPLEFT", -4, 0)
skullToggleButton:SetNormalTexture("Interface\\AddOns\\FocusClassic\\ressources\\crane-icon.blp")

local function UpdateSkullButton()
    if FocusClassicDB.FocusMarkEnabled then
        skullToggleButton:SetAlpha(1)
    else
        skullToggleButton:SetAlpha(0.5)
    end
end

skullToggleButton:SetScript("OnClick", function()
    FocusClassicDB.FocusMarkEnabled = not FocusClassicDB.FocusMarkEnabled
    UpdateSkullButton()
end)

skullToggleButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(skullToggleButton, "ANCHOR_RIGHT")
    if FocusClassicDB.FocusMarkEnabled then
        GameTooltip:SetText(L["Auto-Skull enabled"], 0, 1, 0) -- Texte en vert si actif
    else
        GameTooltip:SetText(L["Auto-Skull disabled"], 1, 0, 0) -- Texte en rouge si inactif
    end
    GameTooltip:Show()
end)
skullToggleButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

UpdateSkullButton()

-- Bouton pour les options
local optionsButton = CreateFrame("Button", nil, focusFrame)
optionsButton:SetSize(14, 14)
optionsButton:SetPoint("BOTTOMRIGHT", focusFrame, "BOTTOMRIGHT", -8, 8)
optionsButton:SetNormalTexture("Interface\\AddOns\\FocusClassic\\ressources\\options-icon.blp")
optionsButton:SetScript("OnClick", function()
    FocusClassicOptions:CreateOptionsPanel()
end)
optionsButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(optionsButton, "ANCHOR_RIGHT")
    GameTooltip:SetText("Options", 1, 1, 1)
    GameTooltip:Show()
end)
optionsButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Enregistrer un événement pour mettre à jour l'état initial du crâne
local skullEventFrame = CreateFrame("Frame")
skullEventFrame:RegisterEvent("PLAYER_LOGIN")
skullEventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        UpdateSkullButton()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)