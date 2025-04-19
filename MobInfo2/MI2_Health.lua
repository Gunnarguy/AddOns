--
-- MI2_Health.lua
--

local UnitHealth, UnitMana, UnitHealthMax, UnitManaMax = UnitHealth, UnitMana, UnitHealthMax, UnitManaMax

-- remember previous font type and font size
local lOldFontId = 0
local lOldFontSize = 0

function MI2_GetNumText(num, numNax)
	local factor = 1
	if numNax and numNax > 10000 then
		factor = 10
	end
	if num > 10000000*factor then
		return string.format("%.fM", num/1000000)
	end
	if num > 10000*factor then
		return string.format("%.fK", num/1000)
	end
	return num
end

-----------------------------------------------------------------------------
-- MobHealth_Display()
--
-- display the values and percentage for health	/ mana in target frame
--
function MobHealth_Display( check )
	-- nothing to do if showing is disabled
	if MobInfoConfig.ShowTargetInfo ~= 1 then return end

	local health = UnitHealth("target")
	if not check or MI2_MobHealthText:GetParent().currValue ~= health then

		local healthText
		-- create health and percent text if showing is enabled	
		if health > 0 then
			local maxhealth = UnitHealthMax("target")
			if MobInfoConfig.TargetHealth == 1 then
				healthText = MI2_GetNumText(health, maxhealth) .. " / " .. MI2_GetNumText(maxhealth)
			end
			if MobInfoConfig.HealthPercent == 1 then
				if healthText then
					healthText = healthText..string.format(" (%d%%)", ceil(100 * health / maxhealth))
				else
					healthText = string.format("%d%%", ceil(100 * health / maxhealth))
				end
			end
		end
		MI2_MobHealthText:SetText( healthText or "" )
	end

	local mana = UnitMana("target")
	if not check or  MI2_MobManaText:GetParent().currValue ~= mana then

		local manaText
		-- create mana text based on mana show flags
		if mana > 0 then
			local maxmana =	UnitManaMax("target")
			if maxmana > 0 then
				if MobInfoConfig.TargetMana == 1 then
					manaText = MI2_GetNumText(mana, maxmana) .. " / " .. MI2_GetNumText(maxmana)
				end
				if MobInfoConfig.ManaPercent == 1 then
					if manaText then
						manaText = manaText..string.format(" (%d%%)", ceil(100 * mana / maxmana))
					else
						manaText = string.format("%d%%", ceil(100 * mana / maxmana))
					end
				end
			end
		end
		MI2_MobManaText:SetText( manaText or "" )
	end
end	 --	MobHealth_Display()


-----------------------------------------------------------------------------
-- MI2_MobHealth_SetFont()
--
-- set new font	for	display	of health /	mana in	target frame
--
local function MI2_MobHealth_SetFont( fontId, fontSize )
	local fontName

	if fontId ~= lOldFontId or fontSize ~= lOldFontSize then
		lOldFontId = fontId
		lOldFontSize = fontSize

		-- select font name	to use
		if	fontId == 1	 then
			fontName = "Fonts\\ARIALN.TTF"  -- NumberFontNormal
		elseif	fontId == 2	 then
			fontName = "Fonts\\FRIZQT__.TTF"	 --	GameFontNormal
		else
			fontName = "Fonts\\MORPHEUS.TTF"	 --	ItemTextFontNormal
		end

		-- set font	for	health and mana	text
		MI2_MobHealthText:SetFont( fontName, fontSize )
		MI2_MobManaText:SetFont( fontName, fontSize )
	end

end	 --	of MI2_MobHealth_SetFont()


-----------------------------------------------------------------------------
-- MI2_MobHealth_SetPos()
--
-- set position	and	font for mob health/mana texts
--
function MI2_MobHealth_SetPos( )
	MI2_MobHealthText:SetParent(_G["TargetFrame"].healthbar)
	MI2_MobHealthText:SetPoint("TOP", _G["TargetFrame"].healthbar, "CENTER",0, 5)
	MI2_MobManaText:SetParent(_G["TargetFrame"].manabar)
	MI2_MobManaText:SetPoint("TOP", _G["TargetFrame"].manabar, "CENTER",0, 5)

	-- update font ID and font size
	MI2_MobHealth_SetFont( MobInfoConfig.TargetFont, MobInfoConfig.TargetFontSize )

	-- update visibility of target frame info
	if MobInfoConfig.ShowTargetInfo == 1 and MobInfoConfig.DisableHealth ~= 2 then
		MI2_MobHealthFrame:Show()
	else
		MI2_MobHealthFrame:Hide()
	end
end	 --	of MI2_MobHealth_SetPos()
