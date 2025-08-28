-- Options.lua

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

-- Table locale pour les options
local FocusClassicOptions = {}
local optionsFrame = nil
local isOptionsVisible = false

-- Fonction pour initialiser les options par défaut
function FocusClassicOptions:InitializeDefaults()
    if not FocusClassicDB then
        FocusClassicDB = {
            -- Options par défaut
            FocusMarkEnabled = false,
            BorderOpacity = 1, -- Opacité par défaut (100%)
            BackgroundOpacity = 0.8, -- Opacité du fond par défaut (80%)
            HealthBarEnabled = true, -- Afficher la barre de vie par défaut
            ResourceBarEnabled = true -- Afficher la barre de ressource par défaut
        }
    end
    -- S'assurer que les options existent même si la DB existe déjà
    if FocusClassicDB.BorderOpacity == nil then
        FocusClassicDB.BorderOpacity = 1
    end
    if FocusClassicDB.BackgroundOpacity == nil then
        FocusClassicDB.BackgroundOpacity = 0.8
    end
    if FocusClassicDB.HealthBarEnabled == nil then
        FocusClassicDB.HealthBarEnabled = true
    end
    if FocusClassicDB.ResourceBarEnabled == nil then
        FocusClassicDB.ResourceBarEnabled = true
    end
end

-- Fonction pour créer le panneau d'options
function FocusClassicOptions:CreateOptionsPanel()
    if optionsFrame then
        if isOptionsVisible then
            optionsFrame:Hide()
            isOptionsVisible = false
        else
            optionsFrame:Show()
            isOptionsVisible = true
        end
        return
    end

    -- Création du cadre principal
    optionsFrame = CreateFrame("Frame", "FocusClassicOptionsFrame", UIParent, "BackdropTemplate")
    optionsFrame:SetSize(300, 270)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    optionsFrame:EnableMouse(true)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)

    -- Titre de l'addon
    local title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", optionsFrame, "TOP", 0, -20)
    title:SetText("FocusClassic")

    -- Version de l'addon
    local version = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("TOP", title, "BOTTOM", 0, -5)
    version:SetText("Version " .. GetAddOnMetadata("FocusClassic", "Version"))

    -- Slider pour l'opacité de la bordure
    local borderSlider = CreateFrame("Slider", "FocusClassicBorderSlider", optionsFrame, "OptionsSliderTemplate")
    borderSlider:SetPoint("TOP", version, "BOTTOM", 0, -25) -- Ajustement espacement
    borderSlider:SetWidth(220)
    borderSlider:SetHeight(18)
    borderSlider:SetMinMaxValues(0, 1)
    borderSlider:SetValueStep(0.1)
    borderSlider:SetValue(FocusClassicDB.BorderOpacity)
    
    -- Labels du slider de bordure
    _G[borderSlider:GetName().."Text"]:SetText(L["Border Opacity"])
    _G[borderSlider:GetName().."Low"]:SetText("0%")
    _G[borderSlider:GetName().."High"]:SetText("100%")

    -- Mise à jour en temps réel de la bordure
    borderSlider:SetScript("OnValueChanged", function(self, value)
        FocusClassicDB.BorderOpacity = value
        -- Mettre à jour l'opacité de la bordure du cadre principal
        local focusFrame = _G["FocusClassicUI"]
        if focusFrame then
            focusFrame:SetBackdropBorderColor(1, 1, 1, value)
        end
    end)

    -- Slider pour l'opacité du fond
    local backgroundSlider = CreateFrame("Slider", "FocusClassicBackgroundSlider", optionsFrame, "OptionsSliderTemplate")
    backgroundSlider:SetPoint("TOP", borderSlider, "BOTTOM", 0, -25) -- Ajustement espacement
    backgroundSlider:SetWidth(220)
    backgroundSlider:SetHeight(18)
    backgroundSlider:SetMinMaxValues(0, 1)
    backgroundSlider:SetValueStep(0.1)
    backgroundSlider:SetValue(FocusClassicDB.BackgroundOpacity)
    
    -- Labels du slider de fond
    _G[backgroundSlider:GetName().."Text"]:SetText(L["Background Opacity"])
    _G[backgroundSlider:GetName().."Low"]:SetText("0%")
    _G[backgroundSlider:GetName().."High"]:SetText("100%")

    -- Mise à jour en temps réel du fond
    backgroundSlider:SetScript("OnValueChanged", function(self, value)
        FocusClassicDB.BackgroundOpacity = value
        -- Mettre à jour l'opacité du fond du cadre principal
        local focusFrame = _G["FocusClassicUI"]
        if focusFrame then
            local r, g, b, a = focusFrame:GetBackdropColor()
            focusFrame:SetBackdropColor(r, g, b, value)
        end
    end)

    -- Case à cocher pour la barre de Vie
    local healthCheckbox = CreateFrame("CheckButton", "FocusClassicHealthCheckbox", optionsFrame, "UICheckButtonTemplate")
    healthCheckbox:SetPoint("TOPLEFT", backgroundSlider, "BOTTOMLEFT", 0, -15) -- Ancrer en haut à gauche du slider
    _G[healthCheckbox:GetName() .. "Text"]:SetText(L["Show Health Bar"])
    healthCheckbox:SetChecked(FocusClassicDB.HealthBarEnabled)
    healthCheckbox:SetScript("OnClick", function(self)
        FocusClassicDB.HealthBarEnabled = self:GetChecked()
        if _G.Focus_UpdateUI then _G.Focus_Update() end
    end)

    -- Case à cocher pour la barre de Ressource
    local resourceCheckbox = CreateFrame("CheckButton", "FocusClassicResourceCheckbox", optionsFrame, "UICheckButtonTemplate")
    resourceCheckbox:SetPoint("TOPLEFT", healthCheckbox, "BOTTOMLEFT", 0, -5) -- Ancrer sous la checkbox de vie
    _G[resourceCheckbox:GetName() .. "Text"]:SetText(L["Show Resource Bar"])
    resourceCheckbox:SetChecked(FocusClassicDB.ResourceBarEnabled)
    resourceCheckbox:SetScript("OnClick", function(self)
        FocusClassicDB.ResourceBarEnabled = self:GetChecked()
        if _G.Focus_UpdateUI then _G.Focus_Update() end
    end)

    -- Bouton Fermer
    local closeButton = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOM", optionsFrame, "BOTTOM", 45, 15)
    closeButton:SetText("Fermer")
    closeButton:SetScript("OnClick", function()
        optionsFrame:Hide()
        isOptionsVisible = false
    end)

    -- Bouton Réinitialiser
    local resetButton = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 22)
    resetButton:SetPoint("RIGHT", closeButton, "LEFT", -15, 0)
    resetButton:SetText("Réinitialiser")
    resetButton:SetScript("OnClick", function()
        -- Réinitialiser les valeurs par défaut
        FocusClassicDB.BorderOpacity = 1
        FocusClassicDB.BackgroundOpacity = 0.8
        FocusClassicDB.HealthBarEnabled = true -- Réinitialiser
        FocusClassicDB.ResourceBarEnabled = true -- Réinitialiser
        
        -- Mettre à jour les sliders et les checkboxes
        borderSlider:SetValue(1)
        backgroundSlider:SetValue(0.8)
        healthCheckbox:SetChecked(true)
        resourceCheckbox:SetChecked(true)
        
        -- Mettre à jour l'interface
        local focusFrame = _G["FocusClassicUI"]
        if focusFrame then
            focusFrame:SetBackdropBorderColor(1, 1, 1, 1)
            local r, g, b, a = focusFrame:GetBackdropColor()
            focusFrame:SetBackdropColor(r, g, b, 0.8)
        end
    end)

    optionsFrame:Show()
    isOptionsVisible = true
end

-- Fonction pour sauvegarder les options (la sauvegarde est automatique)
function FocusClassicOptions:SaveOptions()
    -- Les options sont sauvegardées automatiquement dans FocusClassicDB
end

-- Fonction pour charger les options
function FocusClassicOptions:LoadOptions()
    -- Appliquer l'opacité de la bordure et du fond sauvegardées
    local focusFrame = _G["FocusClassicUI"]
    if focusFrame then
        focusFrame:SetBackdropBorderColor(1, 1, 1, FocusClassicDB.BorderOpacity or 1)
        local r, g, b, a = focusFrame:GetBackdropColor()
        focusFrame:SetBackdropColor(r, g, b, FocusClassicDB.BackgroundOpacity or 1)
    end
end

-- Initialisation des options au chargement
FocusClassicOptions:InitializeDefaults()
FocusClassicOptions:LoadOptions()

-- Enregistrer un événement pour appliquer les options après le chargement de l'UI
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        FocusClassicOptions:LoadOptions()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

-- Rendre les fonctions accessibles globalement
_G["FocusClassicOptions"] = FocusClassicOptions 