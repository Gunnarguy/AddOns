dxpBars = CreateFrame("Frame","dxpBars",UIParent);
dxpPlayerOpts = {}
dxpBarsRef = {}

local dxpTestMode = false
function dxpChangeSpace(newSpace)
	GROUPXPDATA.spacing = newSpace
	dxpReloadBars()
end

function dxpReloadBars()
	local first = true
	local lastEntity
	for i,v in pairs(dxpBarsRef) do
		local sBar = v
		if (first == true) then
			sBar:SetPoint("TOPLEFT", dxpBars, "TOPLEFT", 5, -20)
			first = false
		else
			sBar:SetPoint("TOPLEFT", lastEntity, "BOTTOMLEFT", 0, -5 - ( GROUPXPDATA.spacing))
		end

		lastEntity = sBar
	end
end

function dxpChangeScale(newScale)
	GROUPXPDATA.scale = newScale
	dxpBars:SetScale(GROUPXPDATA.scale)
end
function dxpChangeMovable(nVal)

	GROUPXPDATA.movable = nVal

	dxpBars:EnableMouse(GROUPXPDATA.movable)
	dxpBars:RegisterForDrag("LeftButton")
	dxpBars:SetMovable(GROUPXPDATA.movable)

	if (GROUPXPDATA.movable) then
		dxpBars:SetUserPlaced(false)
	end


	return GROUPXPDATA.movable
end
function dxpToggleMe()
	if (GROUPXPDATA.me == false) then
		GROUPXPDATA.me = true
	else
		GROUPXPDATA.me = false
	end
	ReloadUI()
end
function dxpInitPosition()
	if (GROUPXPDATA.position == nil) then
		GROUPXPDATA.position = { "CENTER", "CENTER", 0, 0 }
	end
	if (GROUPXPDATA.scale == nil) then
		GROUPXPDATA.scale = 1
	end
	if (GROUPXPDATA.visible == nil) then
		GROUPXPDATA.visible  = true
	end
	if (GROUPXPDATA.visible == true) then
		dxpBars:Show()
	else
		dxpBars:Hide()
	end
	local PosP = GROUPXPDATA.position
	dxpBars:SetPoint(PosP[1],UIParent,PosP[3],PosP[4],PosP[5])
	dxpBars:SetScale(GROUPXPDATA.scale)
end

function dxpResizeBars(newWidth, newHeight)
	for i,v in pairs(dxpPlayerOpts) do
		local sBar = _G['dxpBars_' .. v]
		GROUPXPDATA.barwidth = newWidth
		GROUPXPDATA.barheight = newHeight
		sBar:SetWidth(newWidth)
		sBar:SetHeight(newHeight)
		dxpBars:SetWidth(newWidth)
		dxpBars:SetHeight(6 * 15 + (newHeight * 6))
		dxpPulls:SetWidth(newWidth)
		dxpPulls:SetHeight(newHeight)
		dxpPulls.report:SetWidth(newWidth)
		dxpPulls.report:SetHeight(newHeight + 2)
	end
end

function dxpInitBars()
	if (GROUPXPDATA.me == true) then
		dxpPlayerOpts = { "player","party1", "party2", "party3", "party4"}
	else
		dxpPlayerOpts = { "party1", "party2", "party3", "party4"}
	end
	local spacing = 28

	if (GROUPXPDATA.spacing == nil) then
		GROUPXPDATA.spacing = 35
	end

	local spacingC = GROUPXPDATA.spacing


	local first = true
	local lastEntity
	dxpBars:SetSize(GROUPXPDATA.barwidth, 6 * 15 + (GROUPXPDATA.barheight * 6))
	dxpBars:Show();

	dxpChangeMovable(false)
	dxpInitPosition()

	for i,v in pairs(dxpPlayerOpts) do

			
			local sBar = CreateFrame("StatusBar","dxpBars_" .. v, dxpBars)
			sBar.bg = sBar:CreateTexture(nil, "BACKGROUND")
			sBar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
			sBar.bg:SetAllPoints(true)
			sBar.bg:SetVertexColor(0, 0, 0, 0.7)
			sBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar", "ARTWORK")
			sBar:GetStatusBarTexture():SetHorizTile(false)
			sBar:GetStatusBarTexture():SetVertTile(false)

			sBar:SetWidth(GROUPXPDATA.barwidth)
			sBar:SetHeight(GROUPXPDATA.barheight)
			sBar:SetMinMaxValues(0, 100)
			if (UnitExists(v) and dxpIsUnitOnline(UnitName(v))) then
				sBar:SetValue(dxpGetUnitXPPercent(v))
				sBar:SetAlpha(1)
			else
				sBar:SetAlpha(0)
			end

			sBar:SetScript("OnUpdate",function() 
				if (UnitExists(v) and dxpIsUnitOnline(UnitName(v))) then
					sBar:SetStatusBarColor(0.62,0,0.596)
					sBar:SetAlpha(1)
					sBar.name:SetAlpha(1)
					sBar.level:SetAlpha(1)
					sBar.percent:SetAlpha(1)

					if (sBar.name ~= UnitName(v)) then
						local _,enClass = UnitClass(v)
						local raC, gaC, baC, aaC = GetClassColor(enClass)
						sBar.name:SetTextColor(raC,gaC,baC,1)

						sBar.name:SetText(UnitName(v))
						local lenName = strlen(sBar.name:GetText())
						if (lenName >= 10) then
							sBar.name:SetFont("Fonts\\FRIZQT__.TTF", 8)
						else
							sBar.name:SetFont("Fonts\\FRIZQT__.TTF", 10)
						end

						sBar.level:SetText(UnitLevel(v))
						if (not dxpHasGroupXP(UnitName(v) .. "-" .. GetCustomRealmName())) then
							sBar.percent:SetText( "N/A")
						else
							sBar.percent:SetText( string.format("%.1f", sBar:GetValue()) .. "%")
						end
						
					end
					if (sBar.update == nil) then
						sBar.update = 0
					end
					if(sBar.update == 300) then
					  	sBar:SetValue(dxpGetUnitXPPercent(v))
					  	sBar.update = 0
					else
						sBar.update = sBar.update + 1
					end
				else
					if (dxpTestMode == true) then
						sBar:SetAlpha(1)
						sBar.name:SetAlpha(1)
						sBar.level:SetAlpha(1)
						sBar.percent:SetAlpha(1)
					else


						if (dxpIsUnitOnline(UnitName(v)) == false) then
							sBar:SetAlpha(0.45)
							sBar:SetStatusBarColor(0.33,0.33,0.33)
							sBar.name:SetAlpha(0.45)
							sBar.name:SetText("Offline")
							sBar.level:SetAlpha(0.45)
							sBar.percent:SetAlpha(0.45)
						else
							sBar:SetAlpha(0)
							sBar.name:SetAlpha(0)
							sBar.level:SetAlpha(0)
							sBar.percent:SetAlpha(0)
						end
					end
				end
			end) 



			if (first == true) then
				sBar:SetPoint("TOPLEFT", dxpBars, "TOPLEFT", 5, -20 )
				first = false
			else
				sBar:SetPoint("TOPLEFT", _G[lastEntity], "BOTTOMLEFT", 0, -5 - ( spacingC))
			end
			dxpBarsRef[i] = sBar
			lastEntity = "dxpBars_" .. v

			sBar.name = dxpBars:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmallOutline")
			local _,engClass = UnitClass(v)
			local rC, gC, bC, aC = GetClassColor(engClass)
			sBar.name:SetTextColor(rC,gC,bC,1)
			sBar.name:SetText(UnitName(v))
			sBar.name:SetPoint("BOTTOMLEFT", sBar, "TOPLEFT",0, 5)
			sBar.level = dxpBars:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmallOutline")
			sBar.level:SetText(UnitLevel(v))
			sBar.level:SetFont("Fonts\\FRIZQT__.TTF", 10)
			sBar.level:SetPoint("BOTTOM", sBar, "TOP",0, 5)
			sBar.percent = dxpBars:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmallOutline")
			sBar.percent:SetText(string.format("%.1f", sBar:GetValue()) .. "%")
			sBar.percent:SetFont("Fonts\\FRIZQT__.TTF", 10)
			sBar.percent:SetPoint("BOTTOMRIGHT", sBar, "TOPRIGHT",0, 5)
			sBar.border = CreateFrame("Frame",nil, sBar, BackdropTemplateMixin and "BackdropTemplate")		
			sBar.border:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = false, tileSize = 8, edgeSize = 8, insets = { left = 8, right = 8, top = 8, bottom = 8}});		
			sBar.border:SetPoint("CENTER",sBar, "CENTER", -1, 0 )
			sBar.border:SetSize(sBar:GetWidth() + 3, sBar:GetHeight() + 4)
			local divider = sBar.border:CreateTexture('dxpBars_' .. v .. "div", "OVERLAY")
			divider:SetTexture("Interface\\AddOns\\GroupXP\\textures\\dividers")

			divider:SetSize(sBar.border:GetWidth(), sBar.border:GetHeight() - 4)
			divider:SetPoint("LEFT", sBar, "LEFT", -2,0)
			sBar:SetScript("OnSizeChanged", function(self) 
				sBar.border:SetSize(sBar:GetWidth() + 3, sBar:GetHeight() + 4)
				local divider = _G['dxpBars_' .. v .. "div"]
				divider:SetSize(sBar.border:GetWidth(), sBar.border:GetHeight() - 4)
			end)
			sBar:Show()
			
		

	end
end


function dxpToggleTest()
	dxpTestMode = not dxpTestMode
end
function dxpBars_OnDragStart()
	dxpBars:StartMoving()
end
function dxpBars_OnDragStop()
	dxpBars:StopMovingOrSizing()
	PosPTemp = {dxpBars:GetPoint()}
	PosP = {PosPTemp[1],PosPTemp[3],PosPTemp[4],PosPTemp[5]}
	GROUPXPDATA.position = PosP
end


dxpBars:SetScript("OnDragStart",dxpBars_OnDragStart)
dxpBars:SetScript("OnDragStop",dxpBars_OnDragStop)