local AddName, Ns = ...
local L = Ns.L

-- Fire
function Ns.FunctionList.FireResist(HUD, data, options, ...)

	local bonus = select(2, UnitResistance("player",2))
	local totalResist = bonus

	HUD:UpdateText(data, totalResist)
end
------------------------------------------------

-- Nature
function Ns.FunctionList.NatureResist(HUD, data, options, ...)

	local bonus = select(2, UnitResistance("player",3))
	local totalResist = bonus

	HUD:UpdateText(data, totalResist)
end
------------------------------------------------

-- Frost
function Ns.FunctionList.FrostResist(HUD, data, options, ...)

	local bonus = select(2, UnitResistance("player",4))
	local totalResist = bonus

	HUD:UpdateText(data, totalResist)
end
------------------------------------------------

-- Shadow
function Ns.FunctionList.ShadowResist(HUD, data, options, ...)

	local bonus = select(2, UnitResistance("player",5))
	local totalResist = bonus

	HUD:UpdateText(data, totalResist)
end
------------------------------------------------

-- Arcane
function Ns.FunctionList.ArcaneResist(HUD, data, options, ...)

	local bonus = select(2, UnitResistance("player",6))
	local totalResist = bonus

	HUD:UpdateText(data, totalResist)
end
------------------------------------------------