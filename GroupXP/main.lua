local dxpFrame = CreateFrame("Frame",nil, UIParent)

dxpFrame:SetScript("OnEvent",function(self, event, ...) self[event](self, ...) end)

dxpRegPrefix = C_ChatInfo.RegisterAddonMessagePrefix("GroupXP")

local expData = ""
local loaded = false
SLASH_GXP1, SLASH_GXP2 = "/groupxp", "/gxp"
dxpFrame:RegisterEvent("PLAYER_LEVEL_UP")
dxpFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
dxpFrame:RegisterEvent("CHAT_MSG_ADDON")
dxpFrame:RegisterEvent("CHAT_MSG_PARTY")
dxpFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
dxpFrame:RegisterEvent("CHAT_MSG_WHISPER")
dxpFrame:RegisterEvent("ADDON_LOADED")
dxpFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

function GXPSlashHandler(msg, ...)
	if (msg == "reset") then
		GROUPXPDATA.firstLoadedM = nil
		ReloadUI()
		ret = "reset"
	else
		dxpOptions:Show()
	end
end
function dxpToggleVisible(newVal)
	GROUPXPDATA.visible = newVal
	if (GROUPXPDATA.visible == true) then
		dxpBars:Show()
	else
		dxpBars:Hide()
	end
end

function dxpToggleAnnounce(nVal)

		GROUPXPDATA.announce = nVal

end

function dxpGetUpdateXP(levelText)
	local xpMin = UnitXP("player")
	local xpMax = UnitXPMax("player")
	local barsLeft = (xpMax - xpMin) / (xpMax / 20)
	local fxpMin, fxpMax = dxpFormatXP(xpMin, xpMax)
	local outmsg = levelText .. "XP: " .. fxpMin .. " of " .. fxpMax  ..  " [" .. format("%.1f", ((20 - barsLeft) / 20) * 100) .. "%]"
	return outmsg
end
function dxpProcessChat( msg, typeM,...)
	if (msg == "!xp") then
		local lang, tarP = ...
		local level = UnitLevel("player")
		local outmsg = dxpGetUpdateXP("Level: " .. level .. " ")
		if (typeM ~= "BNET") then
			if (typeM == "WHISPER") then
				DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. tarP .. " requested your experience.")
			end
			SendChatMessage(outmsg, typeM, lang, tarP)
		else
			local pname,_,_,_,_,_,_,_,_,_,_,pid = ...
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. pname .. " requested your experience.")
			BNSendWhisper(pid, outmsg)
		end

	elseif (strsub(msg, 1, 6) == "!count") then
		local item = strsub(msg, 8)
		local outmsg = "I have " .. GetItemCount(item) .. "x " .. item
		SendChatMessage(outmsg, "PARTY")
	elseif (msg == "!roll") then
		RandomRoll(1,100)
	end
end

function dxpFrame:CHAT_MSG_COMBAT_XP_GAIN()
	if(loaded) then
		local n = UnitName("player")
		local fn = n .. "-" .. GetCustomRealmName();
		GROUPXPDATA.players[fn] = dxpGetUpdateXP("")
	end
end
function dxpFrame:CHAT_MSG_PARTY(msg, ...)
	dxpProcessChat(msg, "PARTY", ...)
end

function dxpFrame:CHAT_MSG_PARTY_LEADER(msg, ...)
	dxpProcessChat(msg, "PARTY", ...)
end

function dxpFrame:CHAT_MSG_WHISPER( msg,...)
	local author = ...
	dxpProcessChat(msg, "WHISPER", "Common", author)
end
function dxpFrame:CHAT_MSG_BN_WHISPER( msg,...)
	dxpProcessChat(msg, "BNET", ...)
end
function dxpRequestXP(unitName)
	if (loaded) then
		ChatThrottleLib:SendAddonMessage("NORMAL", "GroupXP", "REQUEST", "WHISPER", unitName)
		if (GROUPXPDATA.players[unitName] ~= nil) then
			
			return GROUPXPDATA.players[unitName]
		else
			GROUPXPDATA.players[unitName] = "No XP Data"
			return GROUPXPDATA.players[unitName]
		end
	end
end

function dxpHasGroupXP(unitName)
	if (GROUPXPDATA.players[unitName] ~= nil) then
		if (GROUPXPDATA.players[unitName] == "No XP Data") then
			return false
		else
			return true
		end
	else
		return false
	end
end

function dxpFrame:CHAT_MSG_ADDON( pf, msg,_,auth)
	if (pf == "GroupXP") then
		if (msg == "REQUEST") then
			local author = auth
			local outmsg = dxpGetUpdateXP("")
			ChatThrottleLib:SendAddonMessage("NORMAL", "GroupXP", outmsg, "WHISPER", author)
		else

			GROUPXPDATA.players[auth] = msg
		end
	end
end
function dxpFrame:PLAYER_LEVEL_UP(arg1)
	if (IsInGroup() and GROUPXPDATA.announce == true) then
		local msg = gsub(GROUPXPDATA.announceMsg, "%[level%]", arg1)
		SendChatMessage(msg , "PARTY")
	end
end

function dxpFrame:ADDON_LOADED(arg1, ...)
	if (arg1 == "GroupXP") then
		loaded = true
		if (GROUPXPDATA == nil) then
			GROUPXPDATA = { players = {}, announce = true }
		end
		if (GROUPXPDATA.firstLoadedM == nil) then
			DEFAULT_CHAT_FRAME:AddMessage("GroupXP - Your settings were reset!")
			GROUPXPDATA = { players = {}, visible = true, me = true, position = nil, barwidth = 140, barheight = 10, scale = 1, movable = true, announce = true, pulls = false, announceMsg = "Ding! Leveled up to [level]!", spacing = 35  }
			GROUPXPDATA.firstLoadedM = true
		end
		local n = UnitName("player")
		local fn = n .. "-" .. GetCustomRealmName();
		GROUPXPDATA.players[fn] = dxpGetUpdateXP("")
		dxpInitBars()
		dxpInitPulls()
		dxpBuildOptions(GROUPXPDATA.barwidth, GROUPXPDATA.barheight, GROUPXPDATA.scale, GROUPXPDATA.visible, GROUPXPDATA.movable, GROUPXPDATA.me, GROUPXPDATA.pulls, GROUPXPDATA.announce , GROUPXPDATA.announceMsg, GROUPXPDATA.spacing)
		SlashCmdList["GXP"] = GXPSlashHandler
	end
end

function dxpFormatXP(xpMin, xpMax)
	local fxpMin = 0
	local fxpMax = 0

	if (xpMin > 1000) then
		fxpMin = format("%.1f", xpMin/1000) .. "k"
	else
		fxpMin = xpMin;
	end
	if (xpMax > 1000) then
		fxpMax = format("%.1f", xpMax/1000) .. "k"
	else
		fxpMax = xpMax;
	end

	return fxpMin, fxpMax
end

function dxpIsUnitOnline(unitName)
	if (unitName == UnitName("player")) then -- may aswell
		return true
	end
	for i = 1, MAX_RAID_MEMBERS do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i);
		if (name == unitName) then
			return online
		end
	end
end

function dxpGetUnitXPPercent(unit)

	local n = UnitName(unit)
	local fn = n .. "-" .. GetCustomRealmName();

	if (dxpIsUnitOnline(n)) then
		local tmp;
		if (UnitName("player") ~= n) then
			tmp = dxpRequestXP(fn)
		else
			tmp = dxpGetUpdateXP("")
		end

		if (tmp ~= "No XP Data" and tmp ~= nil) then
			if (string.find(tmp, "20 bars)")) then
				-- someone needs to update their addon
				return 0
			else
				tmp = strsub(tmp, 5)
				local b = string.find(tmp,"%[")
				local c = string.find(tmp, "%]")
				local ssa = strsub(tmp, b + 1, c - 2)
				return ssa
			end
		else

			return 0
		end
	else
		return 0
	end

end


function GetCustomRealmName()
	return GetRealmName():gsub("%s+", "")
end

GameTooltip:HookScript("OnTooltipSetUnit",function(self)
  local n, u = self:GetUnit()
  if (UnitIsPlayer(u) and UnitInParty(u) and UnitExists(u) and dxpIsUnitOnline(n)) then


  	expData = dxpRequestXP(n .. "-" .. GetCustomRealmName())
  	GameTooltip:AddLine(expData)
  	GameTooltip:Show()
  	
  end
end)












