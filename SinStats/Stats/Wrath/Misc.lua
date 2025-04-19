local AddName, Ns = ...
local L = Ns.L

---------------------
-- Options Equates --
---------------------
local World, Realm, Both, Equipped, Total, Bags, Live, Static = 1, 2, 3, 1, 1, 3, 1, 2
local Percentage, Rating = 1, 2

-- GearScore
function Ns.FunctionList.GearScore(HUD, data, options, ...)

	local gearScore = Ns.equippedScore()
    local r, g, b = Ns.scoreRating(gearScore)
	local scoreColor = ""

	if options.Score_Color then
		scoreColor = CreateColor(r, g, b)
		if (r == 0.1) and (g == 0.1) and (b == 0.1) then scoreColor = ""
		else scoreColor = scoreColor:GenerateHexColorMarkup() end
	end

	HUD:UpdateText(data, scoreColor .. gearScore)
end
------------------------------------------------

-- Item level
function Ns.FunctionList.ItemLevel(HUD, data, options, ...)

	local decimals

	if options.Dec_Misc_Ilvl == 0 then decimals = "%.0f"
	elseif options.Dec_Misc_Ilvl == 1 then decimals = "%.1f"
	elseif options.Dec_Misc_Ilvl == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	HUD:UpdateText(data, (decimals):format(Ns.averageiLvl))
end
------------------------------------------------

-- Global Cooldown
local gcd, oldgcd, counter = 0, 0, 1
function Ns.FunctionList.GlobalCD(HUD, data, options, ...)

	_, gcd = GetSpellCooldown(61304)
	local decimals

	if gcd == 0 then gcd = oldgcd
	else oldgcd = gcd end

	if counter == 1 then gcd = 1.5; counter = 0 end

	if options.Dec_Misc_Gcd == 0 then decimals = "%.0f"
	elseif options.Dec_Misc_Gcd == 1 then decimals = "%.1f"
	elseif options.Dec_Misc_Gcd == 2 then decimals = "%.2f"
	else decimals = "%.3f" end

	HUD:UpdateText(data, (decimals):format(gcd))
end
------------------------------------------------

-- Speed
function Ns.FunctionList.Speed(HUD, data, options, ...)

	local EB = options.Speed_Static
	local speedColor, staticColor, endColor = "", "", ""
	local vehicleSpeed = GetUnitSpeed("vehicle")
	local fullSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
	local staticSpeed
	local returnText

	if IsFlying() then staticSpeed = flightSpeed
	elseif IsSwimming() then staticSpeed = swimSpeed
	elseif vehicleSpeed > 0 then staticSpeed = vehicleSpeed
	elseif UnitOnTaxi("player") then staticSpeed = fullSpeed
	else staticSpeed = runSpeed end

	if fullSpeed == 0 and vehicleSpeed > 0 then fullSpeed = vehicleSpeed end

	fullSpeed = fullSpeed / 0.07
	staticSpeed = staticSpeed / 0.07

	if fullSpeed == 0 or fullSpeed == 100 then speedColor = ""
	elseif fullSpeed <= 99 then speedColor = Ns.redText
	elseif fullSpeed > 100 then speedColor = Ns.greenText end

	if staticSpeed == 0 or staticSpeed == 100 then staticColor = ""
	elseif staticSpeed <= 99 then staticColor = Ns.redText
	elseif staticSpeed > 100 then staticColor = Ns.greenText end

	if speedColor ~= "" then endColor = "|r" end

	if Ns.Band(EB, Live) then returnText = speedColor .. string.format("%d%%", ("%.0f"):format(fullSpeed)) end
	if Ns.Band(EB, Static) then returnText = staticColor .. string.format("%d%%", ("%.0f"):format(staticSpeed)) end
	if Ns.Band(EB, Both) then returnText = speedColor .. string.format("%d%%", ("%.0f"):format(fullSpeed)) .. endColor .. "/" .. staticColor .. string.format("%d%%", ("%.0f"):format(staticSpeed)) end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Target Speed
function Ns.FunctionList.TargetSpeed(HUD, data, options, ...)

	local targetSpeed = GetUnitSpeed("target") / 7 * 100
	local speedColor = ""

	if targetSpeed == 0 or targetSpeed == 100 then speedColor = ""
	elseif targetSpeed < 100 then speedColor = "|cffC41E3A"
	elseif targetSpeed > 100 then speedColor = "|cff71FFC9" end

	HUD:UpdateText(data, speedColor .. string.format("%d%%", ("%.0f"):format(targetSpeed)))
end
------------------------------------------------

-- FPS
function Ns.FunctionList.FPS(HUD, data, options, ...)

	local framerate = GetFramerate()
	local fpsColor = ""

	if framerate <= 30 then fpsColor = "|cffC41E3A"
	elseif framerate > 30 and framerate < 50 then fpsColor = "|cffFF7C0A"
	elseif framerate >= 50 then fpsColor = "|cff71FFC9" end

	HUD:UpdateText(data, fpsColor .. floor(framerate))
end
------------------------------------------------

-- Lag
function Ns.FunctionList.Lag(HUD, data, options, ...)

	local EB = options.World_Realm
	local _, _, lagRealm, lagWorld = GetNetStats()
	local lagColor = ""
	local returnText

	if lagWorld <= 90 or lagRealm <= 90 then lagColor = "|cff71FFC9"
	elseif (lagWorld >= 90 and lagWorld < 200) or  (lagRealm >= 90 and lagRealm < 200) then lagColor = "|cffFF7C0A"
	elseif lagWorld >= 200 or lagRealm >= 200 then lagColor = "|cffC41E3A" end

	if Ns.Band(EB, World) then returnText = lagColor .. floor(lagWorld) end
	if Ns.Band(EB, Realm) then returnText = lagColor .. floor(lagRealm) end
	if Ns.Band(EB, Both) then returnText = lagColor .. floor(lagWorld) .. "/" .. floor(lagRealm) end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Debuffs
function Ns.FunctionList.DebuffCounter(HUD, data, options, ...)

	HUD:UpdateText(data, Ns.debuffCount)
end
------------------------------------------------

-- Buffs
function Ns.FunctionList.BuffCounter(HUD, data, options, ...)

	HUD:UpdateText(data, Ns.buffCount)
end
------------------------------------------------

-- Repair cost
function Ns.FunctionList.RepairCost(HUD, data, options, ...)

	local EB = options.Total_Equipped_Bags
	local totalCost = 0
	local equippedCost = 0
	local bagsCost = 0
	local returnText

	for bagNum = 0,4 do
	local cost = 0
		for bagSlot = 1,C_Container.GetContainerNumSlots(bagNum) do
			local item =C_Container.GetContainerItemLink (bagNum, bagSlot)
			if (item) then
				local dur, max = C_Container.GetContainerItemDurability(bagNum, bagSlot)
				if (dur~=nil) then
					--local dif = max - dur
					Ns.repairTooltip:ClearLines()
					cost = select(2, Ns.repairTooltip:SetBagItem(bagNum, bagSlot))
					bagsCost = bagsCost + cost
				end
			end
		end
	end

	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
	if not slot then break end
		Ns.repairTooltip:ClearLines()
		local repairCost = select(3, Ns.repairTooltip:SetInventoryItem("player", slot)) or 0
		equippedCost = equippedCost + repairCost
	end

	totalCost = equippedCost + bagsCost

	if Ns.Band(EB, Total) then returnText = GetCoinTextureString(totalCost) end
	if Ns.Band(EB, Equipped) then returnText = GetCoinTextureString(equippedCost) end
	if Ns.Band(EB, Bags) then returnText = GetCoinTextureString(bagsCost) end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------

-- Durability
function Ns.FunctionList.Durability(HUD, data, options, ...)
	local Durability, Current, Full, Percent
	local LowestCurrent, LowestFull, t1, t2, t3 = 500, 0, 0, 0, 100
	for i=1,19 do
		Current, Full = GetInventoryItemDurability(i)
		if Current and Full then
			Percent = floor(100*Current/Full + 0.5)
			if (Percent < t3) then
				t3 = Percent
			end
			if (Current < LowestCurrent) then
				LowestCurrent = Current
				LowestFull = Full
			end
			t1 = t1 + Current
			t2 = t2 + Full
		end
	end
	if t2 == 0 then
		Durability = "N/A"
	else
		Durability = floor(t1 * 100 / t2)
	end
	local Text = ""
	if type(Durability) == "number" then
		if Durability > 50 then
			Text = string.format("|cff%2xff00", ((Durability > 50) and (255 - 2.55*Durability) or (2.55*Durability)), Durability) .. Text
		else
			Text = string.format("|cffff%2x00", (2.55*Durability), Durability) .. Text
		end
		Text = Text..Durability.."%"
	end

	HUD:UpdateText(data, Text)
end
------------------------------------------------

-- Threat
function Ns.FunctionList.Threat(HUD, data, options, ...)

	local EB = options.Percent_Rating
	local _, _, threatpct, _, threatvalue = UnitDetailedThreatSituation("player", "target")
	local returnText
	local threatColor = ""

	if threatpct == nil then threatpct = 0 end
	if threatvalue == nil then threatvalue = 0 end

	if threatpct <= 59 then threatColor = Ns.greenText
	elseif threatpct >= 60 and threatpct < 100 then threatColor = Ns.orangeText
	elseif threatpct == 100 then threatColor = Ns.redText end

	if Ns.Band(EB, Percentage) then returnText = threatColor .. ("%.0f%%"):format(threatpct) end
	if Ns.Band(EB, Rating) then returnText = threatColor .. ("%.0f"):format(threatvalue) end
	if Ns.Band(EB, Both) then returnText = threatColor .. ("%.0f%%"):format(threatpct) .. " |r(" .. ("%.0f"):format(threatvalue) .. ")" end

	if returnText == nil then returnText = "" end

	HUD:UpdateText(data, returnText)
end
------------------------------------------------