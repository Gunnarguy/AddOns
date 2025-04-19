--
-- MI2_Config.lua
--
-- Configuration dialog related module of the MobInfo AddOn
--

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

MI2_OPTIONS["MI2_OptShowClass"] 	= { text=MI_TXT_CLASS; help=MI_HLP_CLASS }
MI2_OPTIONS["MI2_OptShowHealth"]	= { data="healthText"; text=MI_TXT_HEALTH; help=MI_HLP_HEALTH }
MI2_OPTIONS["MI2_OptShowMana"] 		= { data="manaText"; text=MI_TXT_MANA; help=MI_HLP_MANA }
MI2_OPTIONS["MI2_OptShowKills"]		= { data="kills"; text=MI_TXT_KILLS; help=MI_HLP_KILLS }
MI2_OPTIONS["MI2_OptShowLoots"] 	= { data="loots"; text=MI_TXT_LOOTS; help=MI_HLP_LOOTS }
MI2_OPTIONS["MI2_OptShowCoin"] 		= { data="avgCV"; t=1; text=MI_TXT_COINS; help=MI_HLP_COINS }
MI2_OPTIONS["MI2_OptShowIV"] 		= { data="avgIV"; t=1; text=MI_TXT_ITEMVAL; help=MI_HLP_ITEMVAL }
MI2_OPTIONS["MI2_OptShowTotal"] 	= { data="avgTV"; t=1; text=MI_TXT_MOBVAL; help=MI_HLP_MOBVAL }
MI2_OPTIONS["MI2_OptShowXp"] 		= { data="xp"; text=MI_TXT_XP; help=MI_HLP_XP }
MI2_OPTIONS["MI2_OptShowNo2lev"] 	= { data="mob2Level"; text=MI_TXT_TO_LEVEL; help=MI_HLP_TO_LEVEL }
MI2_OPTIONS["MI2_OptShowEmpty"] 	= { data="emptyLoots"; text=MI_TXT_EMPTY_LOOTS; help=MI_HLP_EMPTY_LOOTS }
MI2_OPTIONS["MI2_OptShowCloth"] 	= { data="clothCount"; text=MI_TXT_CLOTH_DROP; help=MI_HLP_CLOTH_DROP }
MI2_OPTIONS["MI2_OptShowDamage"] 	= { data="dmgText"; t=2; text=MI_TXT_DAMAGE; help=MI_HLP_DAMAGE }
MI2_OPTIONS["MI2_OptShowDps"] 		= { data="dps"; text="DPS"; help=MI_HLP_DPS }
MI2_OPTIONS["MI2_OptShowLocation"]	= { data="loc"; t=3; text=MI_TXT_LOCATION; help=MI_HELP_LOCATION }
MI2_OPTIONS["MI2_OptShowQuality"]	= { data="qualityStr"; opt=MI_OPT_QUALITY; text=MI_TXT_QUALITY; help=MI_HLP_QUALITY }
MI2_OPTIONS["MI2_OptShowLowHpAction"] = { text=MI_TXT_LOWHEALTH; help=MI_HELP_LOWHEALTH }
MI2_OPTIONS["MI2_OptShowResists"]	= { data="resStr"; opt=MI_OPT_RESISTS; text=MI_TXT_RESISTS; help=MI_HELP_RESISTS }
MI2_OPTIONS["MI2_OptShowImmuns"]	= { data="immStr"; text=MI_TXT_IMMUN; help="" }
MI2_OPTIONS["MI2_OptShowItems"]		= { text=MI_TXT_ITEMLIST; help=MI_HELP_ITEMLIST } 
MI2_OPTIONS["MI2_OptShowClothSkin"]	= { text=MI_TXT_CLOTHSKIN; help=MI_HELP_CLOTHSKIN }


function MI2_OptionsFrameOnKeyDown(self,key)
  if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
    self:Hide()
  end
end
-----------------------------------------------------------------------------
-- MI2_OptionsFrameOnLoad()
--
function MI2_OptionsFrameOnLoad()

	MI2_OptionsTabFrame.numTabs = 5
	MI2_TabButton_OnClick(MI2_OptionsTabFrameTab4 )

	MI2_TxtOptionsTitle:SetText( "MobInfo2 "..MI2_VersionNum )

--	MI2_OptShowCombined:Disable()
--	MI2_OptShowCombinedText:SetTextColor( 0.5,0.5,0.5 )

	MI2_MainOptionsFrame = MI2_OptionsTabFrame
end  -- MI2_OptionsFrameOnLoad()


-----------------------------------------------------------------------------
-- MI2_UpdateOptions()
--
-- Update state of all options in options dialog with correct values from
-- data structure "MobInfoConfig".
--
function MI2_UpdateOptions()
	if MobInfoConfig.ShowMobInfo == 1 then
		MI2_OptUseGameTT:Enable()
		MI2_OptUseGameTTText:SetTextColor( 1.0,0.8,0.0 )
		MI2_OptShowWhileInCombat:Enable()
		MI2_OptShowWhileInCombatText:SetTextColor( 1.0,0.8,0.0 )
	else
		MI2_OptUseGameTT:Disable()
		MI2_OptUseGameTTText:SetTextColor( 0.5,0.5,0.5 )
		MI2_OptShowWhileInCombat:Disable()
		MI2_OptShowWhileInCombatText:SetTextColor( 1.0,0.8,0.0 )
	end

	local index, value
	for index, value in pairs(MI2_OPTIONS) do
		local option = string.sub(index,8)
		local control = _G[index]
		if  control and MobInfoConfig[option] then
			if value.dd then
				-- do nothing for dropdowns
			elseif value.val then
				control:SetValue( MobInfoConfig[option] )
			elseif value.txt then
				control:SetText( MobInfoConfig[option] )
			elseif control.SetChecked then
				if not MobInfoConfig[option] or MobInfoConfig[option] == 0 then
					control:SetChecked( false )
				else
					control:SetChecked( true )
				end
			end
		end
	end
end  -- MI2_UpdateOptions()


-----------------------------------------------------------------------------
-- MI2_ShowOptionHelpTooltip()
--
-- Show help text for current hovered option in options dialog
-- in the game tooltip window.
--
function MI2_ShowOptionHelpTooltip(self)
	GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
	GameTooltip:SetText( MI_White..MI2_OPTIONS[self:GetName()].text )
	  
	GameTooltip:AddLine(MI_Gold..MI2_OPTIONS[self:GetName()].help)
	if MI2_OPTIONS[self:GetName()].info then
		GameTooltip:AddLine(MI_Gold..MI2_OPTIONS[self:GetName()].info)
	end
	GameTooltip:Show()
end -- of MI2_ShowOptionHelpTooltip()


-----------------------------------------------------------------------------
-- MI2_OptionsFrameOnShow()
--
-- Show help text for current hovered option in options dialog
-- in the game tooltip window.
--
function MI2_OptionsFrameOnShow()
	MI2_UpdateOptions()
	MI2_TooltipAnchor:SetFrameStrata( "HIGH" )
	MI2_UpdateAnchor()
end  -- MI2_OptionsFrameOnShow()


function miConfig_OnMouseDown(self, button)
	if button == "LeftButton" then
		self:StartMoving()
	end
end


function miConfig_OnMouseUp(self, button)
	if button == "LeftButton" then
		self:StopMovingOrSizing()
	end
end


function MI2_DoneButton_OnClick(self)
	HideUIPanel(MI2_OptionsFrame)
end

-----------------------------------------------------------------------------
-- MI2_TabButton_OnClick()
--
-- Event handler: one of the options dialog TABs has been clicked.
-- Show the corresponding options frame and hide all other option frames.
--
function MI2_TabButton_OnClick( self )
	PanelTemplates_Tab_OnClick( self, MI2_OptionsTabFrame )
	local selected = MI2_OptionsTabFrame.selectedTab

	-- choose special information frame if mob health has been disabled
	local healthFrame = MI2_TargetOptionsFrame
	if  MobInfoConfig ~= nil and MobInfoConfig.DisableHealth == 2  then
		healthFrame = MI2_FrmHealthDisabledInfo
	end

	if  selected == 1  then
		MI2_TooltipOptionsFrame:Show()
	else
		MI2_TooltipOptionsFrame:Hide()
	end
	if  selected == 2  then
		healthFrame:Show()
	else
		healthFrame:Hide()
	end
	if  selected == 3  then
		MI2_DatabaseOptionsFrame:Show()
	else
		MI2_DatabaseOptionsFrame:Hide()
	end
	if  selected == 4  then
		MI2_SearchOptionsFrame:Show()
	else
		MI2_SearchOptionsFrame:Hide()
	end
	if  selected == 5  then
		MI2_GeneralOptionsFrame:Show()
	else
		MI2_GeneralOptionsFrame:Hide()
	end
end


-----------------------------------------------------------------------------
-- MI2_OptTargetFont_OnClick()
--
-- Event handler: one of the choices in the font selection box has been
-- clicked. Store it as a config option.
--
function MI2_OptTargetFont_OnClick(self)
	local oldID = LibDD:UIDropDownMenu_GetSelectedID( MI2_OptTargetFont )
	LibDD:UIDropDownMenu_SetSelectedID( MI2_OptTargetFont, self:GetID())
	if  oldID ~= self:GetID()  then
		MobInfoConfig.TargetFont = self:GetID()
		MI2_MobHealth_SetPos()
	end
end  -- MI2_OptTargetFont_OnClick()


-----------------------------------------------------------------------------
-- MI2_OptItemsQuality_OnClick()
--
-- Event handler: one of the choices in the items quality dropdown has been
-- clicked. Store it as a config option.
--
function MI2_OptItemsQuality_OnClick(self)
	local oldID = LibDD:UIDropDownMenu_GetSelectedID( MI2_OptItemsQuality )
	LibDD:UIDropDownMenu_SetSelectedID( MI2_OptItemsQuality, self:GetID())
	if  oldID ~= self:GetID()  then
		MobInfoConfig.ItemsQuality = self:GetID()
	end
end  -- MI2_OptItemsQuality_OnClick()


-----------------------------------------------------------------------------
-- MI2_OptTooltipMode_OnClick()
--
-- Event handler: one of the choices in the tooltip mode dropdown has been
-- clicked. Store it as a config option.
--
function MI2_OptTooltipMode_OnClick(self)
	local oldID = LibDD:UIDropDownMenu_GetSelectedID( MI2_OptTooltipMode )
	LibDD:UIDropDownMenu_SetSelectedID( MI2_OptTooltipMode, self:GetID())
	if  oldID ~= self:GetID()  then
		MobInfoConfig.TooltipMode = self:GetID()
	end
	MI2_SetupTooltip()
end  -- MI2_OptTooltipMode_OnClick()

-----------------------------------------------------------------------------
-- MI2_DbOptionsFrameOnShow()
--
--
function MI2_DbOptionsFrameOnShow()
	local mobDbSize, healthDbSize, playerDbSize, itemDbSize = 0, 0, 0, 0

	-- count and diplay size of MobInfo database
	for _ in next, MI2_DB.source do  mobDbSize = mobDbSize + 1  end
	MI2_TxtMobDbSize:SetText( MI_TXT_MOB_DB_SIZE..MI_White..(mobDbSize) )

	-- update mob index display and state of "clear mob" button
	if MI2_Database:Get(MI2_Target.id, MI2_Target.level, nil, true) then
		MI2_OptClearTarget:Enable()
		MI2_TxtTargetIndex:SetText( MI_TXT_CUR_TARGET..MI_White..MI2_Target.name..":"..MI2_Target.level )
	else
		MI2_OptClearTarget:Disable()
		MI2_TxtTargetIndex:SetText( MI_TXT_CUR_TARGET..MI_White.."---" )
	end

	-- update import status
	if MI2_Import_Status then
		if MobInfoConfig.ImportSignature == MI2_Import_Signature then
			MI2_OptImportMobData:Disable()
			MI2_TxtImportStatus:SetText( "Status: <data already imported ("..MI2_Import_Status..")>" )
		elseif MI2_Import_Status == "BADVER" then
			MI2_OptImportMobData:Disable()
			MI2_TxtImportStatus:SetText( "Status: <import database too old for import>" )
		elseif MI2_Import_Status == "BADLOC" then
			MI2_OptImportMobData:Disable()
			MI2_TxtImportStatus:SetText( "Status: <import database has wrong language (locale)>" )
		else
			MI2_OptImportMobData:Enable()
			MI2_TxtImportStatus:SetText( "Status: "..MI2_Import_Status.." available for import" )
		end
	else
		MI2_OptImportMobData:Disable()
		MI2_TxtImportStatus:SetText( "Status: <no import data>" )
	end
end  -- MI2_DbOptionsFrameOnShow()

local TAB_SIDES_PADDING = 20

function MI2_PanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
	if not MI2_WOWRetail then
		tab.LeftActive:Hide()
		tab.RightActive:Hide()
		tab.MiddleActive:Hide()
		PanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize);
		return
	end

	tab.LeftDisabled:Hide()
	tab.RightDisabled:Hide()
	tab.MiddleDisabled:Hide()

	if absoluteTextSize then
		tab.Text:SetWidth(absoluteTextSize)
	else
		tab.Text:SetWidth(0)
	end

	local textWidth = tab.Text:GetStringWidth()+1
	local width = textWidth + TAB_SIDES_PADDING + (padding or 0)
	local sideWidths = tab.Left:GetWidth() + tab.Right:GetWidth()
	minWidth = minWidth or sideWidths

	if absoluteSize then
		if absoluteSize < sideWidths then
			width = sideWidths
		else
			width = absoluteSize
		end

		textWidth = width - 10
	else
		if maxWidth and width > maxWidth then
			width = maxWidth
			textWidth = width - 10
		elseif minWidth and width < minWidth then
			width = minWidth
			textWidth = width - 10
		end
	end

	tab.Text:SetWidth(textWidth)
	tab:SetWidth(width)

	if ( tab.HighlightTexture ) then
		tab.HighlightTexture:SetWidth(width)
	end

	if (tab.Middle) then
		tab.Middle:SetWidth(textWidth)
	end

	if (tab.MiddleActive) then
		tab.MiddleActive:SetWidth(textWidth)
	end

end
