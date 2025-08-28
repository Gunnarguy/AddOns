-- Config.lua

-- Variables globales
FocusClassic = {}
FocusClassic.Version = "1.0"
FocusClassic.Name = "FocusClassic"

-- Fonctions globales
FocusClassic.ShowOptions = function()
    if FocusClassicOptions then
        FocusClassicOptions:Show()
    end
end 