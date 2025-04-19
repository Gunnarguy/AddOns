dxpOptions = CreateFrame("Frame","dxpOptions",UIParent, BackdropTemplateMixin and "BackdropTemplate");

function dxpBuildOptions(dxpW, dxpH, dxpS, dxpV, dxpL, dxpM, dxpP, dxpA, dxpAMsg, dxpSP)
	dxpOptions:EnableMouse(true)
	dxpOptions:RegisterForDrag("LeftButton")
	dxpOptions:SetMovable(true)
	dxpOptions:SetSize(400,350);
	dxpOptions:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 8, insets = { left = 1, right = 1, top = 1, bottom = 1 }, edgeFile = "Interface/Tooltips/UI-Tooltip-Border" })
	dxpOptions:SetBackdropColor(0.5,0.5,0.5,1)
	dxpOptions:SetBackdropBorderColor(1,1,1,1)
	dxpOptions:SetPoint("CENTER",0,0)

	dxpOptions_Header = dxpOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	dxpOptions_Header:SetPoint("TOP", dxpOptions, "TOP",0, -20)

	dxpOptions_Header:SetText("Group XP v2.7.0.2")


	local dxpOptionsMenu = CreateFrame("Frame", nil, dxpOptions, BackdropTemplateMixin and "BackdropTemplate")
	dxpOptionsMenu:SetSize(380, 300)
	dxpOptionsMenu:SetPoint("TOP", dxpOptions_Header, "BOTTOM", 0 , -5)

	dxpOptionsMenu:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 8, insets = { left = 1, right = 1, top = 1, bottom = 1 }, edgeFile = "Interface/Tooltips/UI-Tooltip-Border" })
	dxpOptionsMenu:SetBackdropColor(0.8,0.8,0.8,1)
	dxpOptionsMenu:SetBackdropBorderColor(1,1,1,1)

	local dxpOptionsMenuBars = CreateFrame("CheckButton", "dxpOptionsMenu_BarsCheckBox", dxpOptionsMenu, "ChatConfigCheckButtonTemplate")
	dxpOptionsMenuBars:SetPoint("TOPLEFT", dxpOptionsMenu, "TOPLEFT",10, -10)
	dxpOptionsMenu_BarsCheckBoxText:SetText("Show XP Bars")
	dxpOptionsMenu_BarsCheckBox:SetChecked(dxpV)
	dxpOptionsMenu_BarsCheckBox:SetScript("OnClick", function(self) dxpToggleVisible(dxpOptionsMenu_BarsCheckBox:GetChecked()) end)



	local dxpOptionsMenuLock = CreateFrame("CheckButton", "dxpOptionsMenu_LockCheckBox", dxpOptionsMenu, "ChatConfigCheckButtonTemplate")
	dxpOptionsMenuLock:SetPoint("TOP", dxpOptionsMenuBars, "BOTTOM",0, -10)
	dxpOptionsMenu_LockCheckBoxText:SetText("Move XP Bars")
	dxpOptionsMenu_LockCheckBox:SetChecked(dxpL)
	dxpOptionsMenu_LockCheckBox:SetScript("OnClick", function(self) dxpChangeMovable(dxpOptionsMenu_LockCheckBox:GetChecked()) end)
	
	local dxpOptionsMenuInclude = CreateFrame("CheckButton", "dxpOptionsMenu_IncludeCheckBox", dxpOptionsMenu, "ChatConfigCheckButtonTemplate")
	dxpOptionsMenuInclude:SetPoint("TOP", dxpOptionsMenuLock, "BOTTOM",0, -10)
	dxpOptionsMenu_IncludeCheckBoxText:SetText("Include My XP - Reloads UI")
	dxpOptionsMenu_IncludeCheckBox:SetChecked(dxpM)
	dxpOptionsMenu_IncludeCheckBox:SetScript("OnClick", function(self) dxpToggleMe() end)

	local dxpOptionsMenuPulls = CreateFrame("CheckButton", "dxpOptionsMenu_PullsCheckBox", dxpOptionsMenu, "ChatConfigCheckButtonTemplate")
	dxpOptionsMenuPulls:SetPoint("TOP", dxpOptionsMenuInclude, "BOTTOM",0, -10)
	dxpOptionsMenu_PullsCheckBoxText:SetText("Pull XP - Reloads UI")
	dxpOptionsMenu_PullsCheckBox:SetChecked(dxpP)
	dxpOptionsMenu_PullsCheckBox:SetScript("OnClick", function(self) dxpTogglePulls() end)

	-- coming soon:
	--[[local dxpOptionsMenuTar = CreateFrame("CheckButton", "dxpOptionsMenu_TarCheckBox", dxpOptionsMenu, "ChatConfigCheckButtonTemplate")
	dxpOptionsMenuTar:SetPoint("TOP", dxpOptionsMenuPulls, "BOTTOM",0, -10)
	dxpOptionsMenu_TarCheckBoxText:SetText("")
	dxpOptionsMenu_TarCheckBox:SetChecked(dxpV)
	dxpOptionsMenu_TarCheckBox:SetScript("OnClick", function(self) dxpToggleVisible(dxpOptionsMenu_TarCheckBox:GetChecked()) end)]]

	local dxpOptionsMenuAnnounce = CreateFrame("CheckButton", "dxpOptionsMenu_AnnounceCheckBox", dxpOptionsMenu, "ChatConfigCheckButtonTemplate")
	dxpOptionsMenuAnnounce:SetPoint("TOP", dxpOptionsMenuPulls, "BOTTOM",0, -10)
	dxpOptionsMenu_AnnounceCheckBoxText:SetText("Announce Levels")
	dxpOptionsMenu_AnnounceCheckBox:SetChecked(dxpA)
	dxpOptionsMenu_AnnounceCheckBox:SetScript("OnClick", function(self) dxpToggleAnnounce(dxpOptionsMenu_AnnounceCheckBox:GetChecked()) end)

	local dxpOptionsMenu_WidthHeader = dxpOptionsMenu:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dxpOptionsMenu_WidthHeader:SetText("XP Bar Width")
	dxpOptionsMenu_WidthHeader:SetPoint("TOPRIGHT", dxpOptionsMenu, "TOPRIGHT", -10 , -10)

	local dxpOptionsMenuWidth = CreateFrame("Slider", "dxpOptionsMenu_WidthSlider", dxpOptionsMenu, "OptionsSliderTemplate")
	dxpOptionsMenuWidth:SetPoint("TOPRIGHT", dxpOptionsMenu_WidthHeader, "BOTTOMRIGHT",0, -10)
	dxpOptionsMenuWidth:SetMinMaxValues(1, 500)
	dxpOptionsMenuWidth:SetValue(dxpW)
	dxpOptionsMenu_WidthSliderLow:SetText(1)
	dxpOptionsMenu_WidthSliderText:SetPoint("TOP", dxpOptionsMenu_WidthSlider, "BOTTOM", 0, -20)
	dxpOptionsMenu_WidthSliderText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	dxpOptionsMenu_WidthSliderText:SetText(string.format("%.1f", dxpW))

	dxpOptionsMenu_WidthSlider:SetScript("OnValueChanged", function(self, nVal) 
		local newWidth = string.format("%.1f", nVal)
		dxpOptionsMenu_WidthSliderText:SetText(newWidth) 
		dxpResizeBars(newWidth, dxpOptionsMenu_HeightSlider:GetValue())
	end )

	dxpOptionsMenu_WidthSliderHigh:SetText(500)

	local dxpOptionsMenu_HeightHeader = dxpOptionsMenu:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dxpOptionsMenu_HeightHeader:SetText("XP Bar Height")
	dxpOptionsMenu_HeightHeader:SetPoint("TOPRIGHT", dxpOptionsMenuWidth, "TOPRIGHT", 0 , -30)

	local dxpOptionsMenuHeight = CreateFrame("Slider", "dxpOptionsMenu_HeightSlider", dxpOptionsMenu, "OptionsSliderTemplate")
	dxpOptionsMenuHeight:SetPoint("TOPRIGHT", dxpOptionsMenu_HeightHeader, "BOTTOMRIGHT",0, -10)
	dxpOptionsMenuHeight:SetMinMaxValues(1, 500)
	dxpOptionsMenuHeight:SetValue(dxpH)
	dxpOptionsMenu_HeightSliderLow:SetText(1)
	dxpOptionsMenu_HeightSliderHigh:SetText(500)
	dxpOptionsMenu_HeightSliderText:SetPoint("TOP", dxpOptionsMenu_HeightSlider, "BOTTOM", 0, -20)
	dxpOptionsMenu_HeightSliderText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	dxpOptionsMenu_HeightSliderText:SetText(string.format("%.1f", dxpH))

	dxpOptionsMenu_HeightSlider:SetScript("OnValueChanged", function(self, nVal) 
		local newHeight = string.format("%.1f", nVal)
		dxpOptionsMenu_HeightSliderText:SetText(newHeight) 
		dxpResizeBars(dxpOptionsMenu_WidthSlider:GetValue(), newHeight)
	end )

	local dxpOptionsMenu_ScaleHeader = dxpOptionsMenu:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dxpOptionsMenu_ScaleHeader:SetText("XP Bar Scale")
	dxpOptionsMenu_ScaleHeader:SetPoint("TOPRIGHT", dxpOptionsMenuHeight, "TOPRIGHT", 0 , -30)

	local dxpOptionsMenuScale = CreateFrame("Slider", "dxpOptionsMenu_ScaleSlider", dxpOptionsMenu, "OptionsSliderTemplate")
	dxpOptionsMenuScale:SetPoint("TOPRIGHT", dxpOptionsMenu_ScaleHeader, "BOTTOMRIGHT",0, -10)
	dxpOptionsMenuScale:SetMinMaxValues(0.1, 10)
	dxpOptionsMenuScale:SetValue(dxpS)
	dxpOptionsMenu_ScaleSliderLow:SetText(0.1)
	dxpOptionsMenu_ScaleSliderHigh:SetText(10)
	dxpOptionsMenu_ScaleSliderText:SetPoint("TOP", dxpOptionsMenu_ScaleSlider, "BOTTOM", 0, -20)
	dxpOptionsMenu_ScaleSliderText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	dxpOptionsMenu_ScaleSliderText:SetText(string.format("%.1f", dxpS))

	dxpOptionsMenu_ScaleSlider:SetScript("OnValueChanged", function(self, nVal)
		local newScale = string.format("%.1f", nVal)
		dxpOptionsMenu_ScaleSliderText:SetText(newScale) 
		dxpChangeScale(newScale)
	end )
	local dxpOptionsMenu_SpaceHeader = dxpOptionsMenu:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dxpOptionsMenu_SpaceHeader:SetText("XP Bar Spacing")
	dxpOptionsMenu_SpaceHeader:SetPoint("TOPRIGHT", dxpOptionsMenuScale, "TOPRIGHT", 0 , -30)

	local dxpOptionsMenuSpace = CreateFrame("Slider", "dxpOptionsMenu_SpaceSlider", dxpOptionsMenu, "OptionsSliderTemplate")
	dxpOptionsMenuSpace:SetPoint("TOPRIGHT", dxpOptionsMenu_SpaceHeader, "BOTTOMRIGHT",0, -10)
	dxpOptionsMenuSpace:SetMinMaxValues(-100, 100)
	dxpOptionsMenuSpace:SetValue(dxpSP)
	dxpOptionsMenu_SpaceSliderLow:SetText(-100)
	dxpOptionsMenu_SpaceSliderHigh:SetText(100)
	dxpOptionsMenu_SpaceSliderText:SetPoint("TOP", dxpOptionsMenu_SpaceSlider, "BOTTOM", 0, -20)
	dxpOptionsMenu_SpaceSliderText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	dxpOptionsMenu_SpaceSliderText:SetText(string.format("%.1f", dxpSP))

	dxpOptionsMenu_SpaceSlider:SetScript("OnValueChanged", function(self, nVal)
		local newSpace = string.format("%.1f", nVal)
		dxpOptionsMenu_SpaceSliderText:SetText(newSpace) 
		dxpChangeSpace(newSpace)
	end )
	dxpOptions:SetScript("OnDragStart",dxpOptions_OnDragStart)
	dxpOptions:SetScript("OnDragStop",dxpOptions_OnDragStop)

	local dxpOptions_CloseButton = CreateFrame("Button", nil, dxpOptionsMenu, "UIPanelButtonTemplate")
	dxpOptions_CloseButton:SetText("Done")
	dxpOptions_CloseButton:SetSize(60,30)
	dxpOptions_CloseButton:SetPoint("BOTTOMRIGHT", dxpOptionsMenu, "BOTTOMRIGHT", -5, 5)
	dxpOptions_CloseButton:SetScript("OnClick", function() dxpOptions:Hide() end)

	local dxpOptions_TestButton = CreateFrame("Button", nil, dxpOptionsMenu, "UIPanelButtonTemplate")
	dxpOptions_TestButton:SetText("Toggle Test Bars")
	dxpOptions_TestButton:SetSize(150,30)
	dxpOptions_TestButton:SetPoint("RIGHT", dxpOptions_CloseButton, "LEFT")
	dxpOptions_TestButton:SetScript("OnClick", function() dxpToggleTest() end)


	local dxpOptionsMenuMessage = CreateFrame("EditBox", "dxpOptionsMenu_AnnounceMsg", dxpOptionsMenu, "InputBoxTemplate")
	dxpOptionsMenuMessage:SetWidth(180)
	dxpOptionsMenuMessage:SetHeight(12)
	dxpOptionsMenuMessage:SetMultiLine(false)
	dxpOptionsMenuMessage:SetPoint("TOPLEFT", dxpOptionsMenuAnnounce, "BOTTOMLEFT", 8, -10)
	dxpOptionsMenuMessage:SetText(dxpAMsg)
	dxpOptionsMenuMessage:SetAutoFocus(false)
	dxpOptionsMenuMessage:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	dxpOptionsMenuMessage:SetScript("OnTextChanged", function(self) GROUPXPDATA.announceMsg = dxpOptionsMenuMessage:GetText() end)

	dxpOptions_footer = dxpOptionsMenu:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	dxpOptions_footer:SetPoint("TOP", dxpOptionsMenuMessage, "BOTTOM",15, -10)
	dxpOptions_footer:SetJustifyH("LEFT")

	dxpOptions_footer:SetText("Chat Commands\n!xp - get everyones xp\n!count item - get everyones count of item\n!roll - make everyone roll")

	dxpOptions:Hide()
end

function dxpOptions_OnDragStart()
	dxpOptions:StartMoving()
end
function dxpOptions_OnDragStop()
	dxpOptions:StopMovingOrSizing()
end

