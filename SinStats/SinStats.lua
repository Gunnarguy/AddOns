----------------------------------
--			SinStats			--
----------------------------------
local AddName, Ns = ...
local L = Ns.L

local headerWidth, headerHeight, updateSpeed = 200, 15, 1

Ns.ConfigDefaultFontSize = 17 -- right side
Ns.TexturePath = "Interface\\AddOns\\"..AddName.."\\Textures\\"

Ns.IgnoreFormat = 0x1 -- just return the icon without any |T...:0|t. Can be used to display in Texture widgets
Ns.ForceIcon = 0x2 -- fors the use of the icon key is the source table has both a spell and and icon key
--Ns.IgnoreColor = ""
Ns.BottomLeft = 1 -- Option 1 use for anchor point of ident (indent???) stat. positioning
Ns.BottomRight = 2 -- Option 2 use for anchor point of ident (indent???) stat. positioning
Ns.LWin = LibStub("LibWindow-1.1")

function Ns.Band(var, flag)
	if var == nil then
		return false
	end
	if bit.band(var, flag) == flag then
		return true
	end
	return false
end

Ns.FunctionList = {}

------------------------------------------
--			Initialize Icons			--
------------------------------------------
local function LibInit()
	local MinimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject("SinStats",
		{
			type = "data source",
			text = "SinStats",
			icon = Ns.TexturePath.."MiniMap",

			OnTooltipShow = function(tooltip)
				tooltip:SetText("|cff71FFC9SinStats|r")
				tooltip:AddTexture(Ns.TexturePath.."MiniMap")
				tooltip:AddLine("|cff71FFC9"..L["QuickAccess"].."|r")
				tooltip:AddLine(L["OpenSettings"], 1, 1, 1)
				tooltip:AddTexture(Ns.TexturePath.."LeftClick")
				tooltip:AddLine(L["EnableDisable"], 1, 1, 1)
				tooltip:AddTexture(Ns.TexturePath.."RightClick")
				tooltip:AddLine("|cff71FFC9"..L["ShiftRightClick"].."|r - "..L["UnlockHUD"], 1, 1, 1)
				tooltip:AddTexture(Ns.TexturePath.."RightClick")
				tooltip:Show()
			end,

			OnClick = function(self, button, down)
                if button == "LeftButton" then
                    Ns:ToggleConfig()
                elseif button == "RightButton" then
                    if IsShiftKeyDown() then
                        Ns.Profile.LockHUD = not Ns.Profile.LockHUD
                        Ns:InitialiseProfile(Ns.Profile)
                    -- elseif IsControlKeyDown() then
                        -- SinStatsFrame.HUD:SetParent(PaperDollFrame)
						-- SinStatsFrame:SetParent(PaperDollFrame)

					-- elseif IsAltKeyDown() then
						-- SinStatsFrame.HUD:SetParent(UIParent)
						-- SinStatsFrame:SetParent(UIParent)
                    else
                        Ns.Profile.HideHUD = not Ns.Profile.HideHUD
                        Ns:InitialiseProfile(Ns.Profile)
                    end
                end

            end,
		}
	)
	Ns.sshMiniButton = LibStub("LibDBIcon-1.0")
	Ns.sshMiniButton:Register("SinStats", MinimapIcon, Ns.Profile.Minimap)

end

local function InitDefaults()
	if SinStatsDB and SinStatsDB.profileKeys and SinStatsDB.profiles then
		return
	end
	SinStatsDB = { profileKeys={}, profiles={} }
	for k, v in pairs(Ns.byPlayerClass) do
		Ns:CreateProfile(k, nil, k)
	end
end

local function CheckForNewOptions()
	for profile, settings in pairs(SinStatsDB.profiles) do
		for baseoption, value in pairs(Ns.SettingsDisplayOrder) do
			if settings[value.stat] == nil and value.default then
				settings[value.stat] = value.default
			end
		end
		for stat, data in pairs(settings.Stats) do
			for _, statkey in pairs(Ns.DefaultOrder) do
				if statkey.stat == stat then
					if not statkey.options then
						break
					end
					for option, istrue in pairs(statkey.options) do
						for _, optionentry in pairs(Ns.Options) do
							if optionentry.stat == option then
								if istrue and (optionentry.default ~= nil) and data[option] == nil then
									data[option] = optionentry.default
								end
							end
						end
					end
				end
			end
		end
	end
end

local otherUpdateSpeeds = {
	[1] = 0.2,
}
local otherUpdateSpeedsElapsed, otherUpdateSpeedsStats = {}, {}

function Ns:RegisterForOtherUpdate(id, stat)
	if not otherUpdateSpeeds[id] then
		error("|cffff0000SinStats ERROR:|r Ns:RegisterForOtherUpdate - No Elapsed time available for id |cffffff00".. id .."|r")
	end
	if not otherUpdateSpeedsElapsed[id] then
		otherUpdateSpeedsElapsed[id] = otherUpdateSpeeds[id]
	end
	if not otherUpdateSpeedsStats[id] then
		otherUpdateSpeedsStats[id] = {}
	end
	tinsert(otherUpdateSpeedsStats[id], stat)
end

function Ns:ClearOtherUpdates()
	table.wipe(otherUpdateSpeedsElapsed)
	table.wipe(otherUpdateSpeedsStats)
end

function Ns.NewSettings(profile, class)
--[[ DO NOT REMOVE! ]]--
	Ns:CheckForStats(profile, class) -- Check if any new stats have been added to the Ns.DefaultOrder table
	CheckForNewOptions() -- Check if any new options have been added and add them to require SV stats in ALL profiles
	-- Remove old GroupOrder SV entry to be replaced by Stat. Display Order (including Custom order)
	if profile.GroupOrder ~= nil then
		for _, settings in pairs(SinStatsDB.profiles) do
			settings.GroupOrder = nil
		end
	end

	-- Fix for Font droplist with incorrect or blank setting
	if profile.StatFont == "Fonts/ARIALN.ttf" then
		for _, settings in pairs(SinStatsDB.profiles) do
			if settings.StatFont == "Fonts/ARIALN.ttf" then
				settings.StatFont = "Arial Narrow"
			end
		end
	end
end

--------------------------
--			HUD			--
--------------------------
local f = CreateFrame("Frame", "SinStatsFrame", UIParent)
f:SetSize(headerWidth, headerHeight)
f:EnableMouse(true)
f:SetFrameStrata("MEDIUM")
f.Background = f:CreateTexture()
f.Background:SetAllPoints()
f.Background:SetColorTexture(0.09020, 0.09020, 0.09020, 1)
f.Title = f:CreateFontString(nil, "OVERLAY");
f.Title:SetFontObject("GameFontHighlight");
f.Title:SetTextColor(1, 1, 1)
f.Title:SetText("SinStats")
f.Title:SetPoint("CENTER")
f.HUD = CreateFrame("Frame", nil, UIParent)
f.HUD:SetSize(headerWidth, 2)
f.HUD:SetPoint("TOPLEFT", f, "BOTTOMLEFT")
f.HUD:SetFrameStrata("MEDIUM")
f.HUD.Background = f.HUD:CreateTexture()
f.HUD.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
f.HUD.Background:SetVertexColor(0.1, 0.1, 0.1, 0)
f.HUD.Background:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 1)
--f.HUD.Background:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT")
f.HUD.StatList = {}
f.HUD:SetScript("OnEvent", function (self, event, ...)
	if event == "PLAYER_LOGIN" then
		Ns:InitialiseVersionData()
--		print("|cff00f26dSinStats v" .. addVer .. "|r. Type |cff00f26d/sinstats|r or |cff00f26d/ss|r to open the settings.")
		Ns.Name = UnitName("player")
		Ns.ProfileKey = Ns.Name .. "-" .. GetRealmName()
		Ns.Class = select(2, UnitClass("player"))
		InitDefaults()
		if not SinStatsDB.profileKeys[Ns.ProfileKey] then
			if not SinStatsDB.profiles[Ns.Class] then
				Ns:CreateProfile(Ns.Class, nil, Ns.Class)
			end
			SinStatsDB.profileKeys[Ns.ProfileKey] = Ns.Class
		end
		Ns.Profile = SinStatsDB.profiles[SinStatsDB.profileKeys[Ns.ProfileKey]]
		Ns.NewSettings(Ns.Profile, Ns.Class)
		LibInit()
		if not Ns.Profile.HUDPos then
			Ns.Profile.HUDPos = {}
			Ns:ResetHUD()
		end
		Ns.LWin.RegisterConfig(SinStatsFrame, Ns.Profile.HUDPos)
		Ns.LWin.MakeDraggable(SinStatsFrame)
		--Ns.LWin.RestorePosition(SinStatsFrame) 
		Ns.talentScan()
		self:SetScript("OnEvent", function(self, event, ...)
			if Ns.EventList[event] then
				for _, v in pairs(Ns.EventList[event]) do
					v.func(v.widget, v.data, v.options, ...)
				end
			end
			Ns.OnEventFunc(event, ...)
		end)

		C_Timer.After(1, function()
			self:GetScript("OnEvent")(SinStatsFrame, "UPDATE_INVENTORY_DURABILITY")
			self:GetScript("OnEvent")(SinStatsFrame, "PLAYER_EQUIPMENT_CHANGED")
		end)
		
		self.Elapsed = updateSpeed
		self:SetScript("OnUpdate", function(self, elapsed)
			for elapseId, elapseTime in pairs(otherUpdateSpeedsElapsed) do
				elapseTime = elapseTime - elapsed
				if elapseTime > 0 then
					otherUpdateSpeedsElapsed[elapseId] = elapseTime
				else
					otherUpdateSpeedsElapsed[elapseId] = otherUpdateSpeeds[elapseId]
					for k, v in pairs(otherUpdateSpeedsStats[elapseId]) do
						v.func(v.widget, v.data, v.options, elapsed)
					end
				end
			end
			self.Elapsed = self.Elapsed - elapsed
			if self.Elapsed >= 0 then
				return
			end
			self.Elapsed = updateSpeed
			Ns.MeleeUpdate()
			Ns.DefenseUpdate()
			Ns.RangedUpdate()
			Ns.SpellUpdate()
			for k, v in ipairs(Ns.OnUpdateList) do
				v.func(v.widget, v.data, v.options, elapsed)
			end
		end)
		Ns:InitialiseProfile(Ns.Profile)
	end
end)
f.HUD:RegisterEvent("PLAYER_LOGIN")
f.HUD:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

--------------------------------------
--			Slash commands			--
--------------------------------------
SLASH_SINSTATS1 = "/sinstats"
SLASH_SINSTATS2 = "/ss"
function SlashCmdList.SINSTATS()
	Ns:ToggleConfig()
end
