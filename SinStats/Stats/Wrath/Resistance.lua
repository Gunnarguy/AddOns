local AddName, Ns = ...
local L = Ns.L

------------------------------
--		Options Equates		--
------------------------------
local Player, Pet, Both = 1, 2, 3

-- Fire
function Ns.FunctionList.FireResist(HUD, data, options, ...)

	local EB = options.Player_Pet
	local bonus = select(3, UnitResistance("player",2))
	local petResist = select(2, UnitResistance("pet",2))
	local buffColor = ""
	local returnText

	if bonus > 0 then buffColor = Ns.greenText end

	if Ns.Band(EB, Player) then returnText = buffColor .. bonus end
	if Ns.Band(EB, Pet) then returnText = petResist end
	if Ns.Band(EB, Both) then returnText = buffColor .. bonus .. " |r(" .. petResist .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Nature
function Ns.FunctionList.NatureResist(HUD, data, options, ...)

	local EB = options.Player_Pet
	local bonus = select(3, UnitResistance("player",3))
	local petResist = select(2, UnitResistance("pet",3))
	local buffColor = ""
	local returnText

	if bonus > 0 then buffColor = Ns.greenText end

	if Ns.Band(EB, Player) then returnText = buffColor .. bonus end
	if Ns.Band(EB, Pet) then returnText = petResist end
	if Ns.Band(EB, Both) then returnText = buffColor .. bonus .. " |r(" .. petResist .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Frost
function Ns.FunctionList.FrostResist(HUD, data, options, ...)

	local EB = options.Player_Pet
	local bonus = select(3, UnitResistance("player",4))
	local petResist = select(2, UnitResistance("pet",4))
	local buffColor = ""
	local returnText

	if bonus > 0 then buffColor = Ns.greenText end

	if Ns.Band(EB, Player) then returnText = buffColor .. bonus end
	if Ns.Band(EB, Pet) then returnText = petResist end
	if Ns.Band(EB, Both) then returnText = buffColor .. bonus .. " |r(" .. petResist .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Shadow
function Ns.FunctionList.ShadowResist(HUD, data, options, ...)

	local EB = options.Player_Pet
	local bonus = select(3, UnitResistance("player",5))
	local petResist = select(2, UnitResistance("pet",5))
	local buffColor = ""
	local returnText

	if bonus > 0 then buffColor = Ns.greenText end

	if Ns.Band(EB, Player) then returnText = buffColor .. bonus end
	if Ns.Band(EB, Pet) then returnText = petResist end
	if Ns.Band(EB, Both) then returnText = buffColor .. bonus .. " |r(" .. petResist .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Arcane
function Ns.FunctionList.ArcaneResist(HUD, data, options, ...)

	local EB = options.Player_Pet
	local bonus = select(3, UnitResistance("player",6))
	local petResist = select(2, UnitResistance("pet",6))
	local buffColor = ""
	local returnText

	if bonus > 0 then buffColor = Ns.greenText end

	if Ns.Band(EB, Player) then returnText = buffColor .. bonus end
	if Ns.Band(EB, Pet) then returnText = petResist end
	if Ns.Band(EB, Both) then returnText = buffColor .. bonus .. " |r(" .. petResist .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------