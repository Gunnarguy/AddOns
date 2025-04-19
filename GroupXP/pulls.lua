dxpPulls = CreateFrame("Frame","dxpPulls",dxpBars);
dxpPulls:SetScript("OnEvent",function(self, event, ...) self[event](self, ...) end)
dxpPulls:RegisterEvent("PLAYER_REGEN_DISABLED")
dxpPulls:RegisterEvent("PLAYER_REGEN_ENABLED")
dxpPulls:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
local lastPullXP = 0
local isInCombat = false


--[[
	GroupDigits by phanxaddons
	Couldn't be bothered trying to do some regular expressions, so thank you :)
]]
local decimal = ("%.1f"):format(1/5):match("([^0-9])")
local thousands = decimal == "." and "," or "."

function dxpGroupDigits(num)
	if not num then return 0 end
	if abs(num) < 1000 then return num end

	local neg = num < 0 and "-" or ""
	local left, mid, right = tostring(abs(num)):match("^([^%d]*%d)(%d*)(.-)$")
	return ("%s%s%s%s"):format(neg, left, mid:reverse():gsub("(%d%d%d)", "%1" .. thousands):reverse(), right)
end


function dxpInitPullsPosition()
	dxpPulls:SetPoint("BOTTOMLEFT", dxpBars, "TOPLEFT")
end

function dxpTogglePulls()
	if (GROUPXPDATA.pulls == false) then
		GROUPXPDATA.pulls = true
	else
		GROUPXPDATA.pulls = false
	end
	ReloadUI()
end

function dxpInitPulls()

	if (GROUPXPDATA.pulls == true) then
		dxpPulls:SetSize(GROUPXPDATA.barwidth,GROUPXPDATA.barheight)
		dxpPulls:Show();
		lPullXPLabel = dxpPulls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmallOutline")
		lPullXPLabel:SetText("Pull XP ")
		lPullXPLabel:SetPoint("LEFT", dxpPulls, "LEFT", 5, 5)
		lPullXPValue = dxpPulls:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmallOutline")
		dxpPulls:SetScript("OnUpdate", function() lPullXPValue:SetText(dxpGroupDigits(lastPullXP)) end)
		lPullXPValue:SetFont("Fonts\\FRIZQT__.TTF", 10)
		lPullXPValue:SetPoint("RIGHT", dxpPulls, "RIGHT",5, 5)
		dxpPulls.report = CreateFrame("Button", "dxpPullsReport", dxpPulls)
		dxpPulls.report:SetSize(GROUPXPDATA.barwidth,GROUPXPDATA.barheight + 2)
		dxpPulls.report:SetPoint("TOPLEFT", dxpPulls, "TOPLEFT", 5, 5)
		dxpPulls.report:SetScript("OnClick", dxpLinkPullXP)
		dxpPulls.report:SetScript("OnEnter", function(self) lPullXPLabel:SetTextColor(1,0.2,0,1); lPullXPValue:SetTextColor(1,0.2,0,1) end)
		dxpPulls.report:SetScript("OnLeave", function(self) lPullXPLabel:SetTextColor(1,1,1,1); lPullXPValue:SetTextColor(1,1,1,1) end)
		dxpInitPullsPosition()
	end
end
function dxpLinkPullXP()
	if (UnitInParty("player")) then
		local outmsg = "Last Pull XP: " .. dxpGroupDigits(lastPullXP)
		SendChatMessage(outmsg, "PARTY")
	end
end

function dxpUpdatePulls(uVal)
	lastPullXP = tonumber(lastPullXP) + tonumber(uVal)
end

function dxpPulls:PLAYER_REGEN_DISABLED()
	lastPullXP = 0
	isInCombat = true

end

function dxpPulls:PLAYER_REGEN_ENABLED()
	isInCombat = false
end

function dxpPulls:CHAT_MSG_COMBAT_XP_GAIN(msg, ...)
	retVal = 0
	gsub(msg, "(%d+) experience", function(d) retVal = d end )
	if (isInCombat) then
		dxpUpdatePulls(retVal)
	end
end


