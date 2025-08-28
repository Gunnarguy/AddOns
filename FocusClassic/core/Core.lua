local addonName, addon = ...

-- Initialisation de la table addon si elle n'existe pas
if not addon then
    addon = {}
end

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

-- Vérification que L est bien initialisé
if not L then
    error("Les fichiers de localisation n'ont pas été chargés correctement")
end

-- Initialisation de la base de données
if not FocusClassicDB then
    FocusClassicDB = {
        frameOpacity = 1,
        backgroundOpacity = 1,
        buttonsOpacity = 1,
        autoSkull = false
    }
end

-- Fonction pour obtenir le texte localisé
function addon:GetText(key)
    if not L then
        -- Si L n'est pas initialisé, essayer de le réinitialiser
        local clientLocale = GetLocale()
        if clientLocale == "frFR" then
            L = L_FR
        elseif clientLocale == "enUS" then
            L = L_EN
        else
            L = L_EN
        end
        if not L then
            return key -- Retourner la clé si L n'est toujours pas initialisé
        end
    end
    return L[key] or key
end

-- Exporter addon pour qu'il soit accessible globalement
_G[addonName] = addon 