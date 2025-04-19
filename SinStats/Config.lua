local AddName, Ns = ...
local L = Ns.L
local HOptionsOffsetX, HOptionsOffsetY, mainMenuYOffset, separatorOffsetY = 7, 3, -82, 30
local sidePanelWidth
local redColor = { r=1, g=0, b=0.658 }
local orangeColor = { r=1, g=0.741, b=0.313 }
local white = { r=1, g=1, b=1 }
Ns.ConfigDefaultFont = "Fonts/ARIALN.ttf"
--Ns.ConfigDefaultFont = "Interface\\AddOns\\"..AddName.."\\fonts\\Accidental Presidency.ttf"
local addVer = C_AddOns.GetAddOnMetadata(AddName, "Version")



if GetLocale() == 'zhCN' or GetLocale() == 'zhTW' or GetLocale() == 'koKR' then
    Ns.ConfigDefaultFont = Ns.LSM:Fetch("font", Ns.LSM:GetDefault("font"))
end
Ns.ConfigDefaultFontSize = 17

-----------------------------------------------
--			SV Items and Groupings			---
-----------------------------------------------
Ns.SettingsGroupOrder = {
	[1] = { stat="HUD", svnotintable=true, icon="HUD", widget={ type="TopTab" }, activeonload=true, },
	[2] = { stat="Fonts", svnotintable=true, centeralign=true, icon="Fonts", widget={ type="TopTab" }, },
	[3] = { stat="Display", svnotintable=true, icon="Display", widget={ type="TopTab" }, },
	[4] = { stat="DisplayOrder", description=true, svnotintable=true, icon="Order", widget={ type="TopTab" }, enabledval=3, },
	[5] = { stat="Events", svnotintable=true, icon="Events", widget={ type="TopTab" }, },
	[6] = { stat="Profiles", svnotintable=true, icon="Profiles", widget={ type="TopTab" }, },
	[7] = { stat="FAQ", svnotintable=true, icon="Misc", widget={ type="TopTab" }, },
} 

Ns.SettingsDisplayOrder = {
	{ stat="HideHUD", icon="", spellclass="HUD", default=false, widget={ type="CheckBox", }, },
	{ stat="LockHUD", icon="", spellclass="HUD", default=false, widget={ type="CheckBox", }, },
	{ stat="PanelDisplay", icon="", spellclass="HUD", default=false, widget={ type="CheckBox", }, },-- linked={"FixedPanelDisplay", false, }, },
	{ stat="PanelShow", icon="", spellclass="HUD", default=false, widget={ type="CheckBox", }, },
	{ stat="HUDStrata", icon="", spellclass="HUD", default="MEDIUM", widget={ type="DropList", data="Strata", width=120, }, newline=true, },
	{ stat="HUDBgColor", icon="", spellclass="HUD", default={ r=0.1, g=0.1, b=0.1, }, widget={ type="ColorPicker", }, },
	{ stat="HUDBgAlpha", icon="", spellclass="HUD", default=0, widget={ type="Slider", min=0, max=1, valuestep=0.01, width=120, }, },
	{ stat="ResetPosition", icon="", spellclass="HUD", default=false, widget={ type="PlainButton", }, },
	{ stat="StatFont", icon="", spellclass="Fonts", default="Arial Narrow",  widget={ type="DropList", data="Fonts", width=170, }, },
	{ stat="StatFontSize", icon="", spellclass="Fonts", default=16, widget={ type="Slider", min=8, max=45, valuestep=1, width=140, }, },
	{ stat="StatFontFlags", icon="", spellclass="Fonts", default="", widget={ type="DropList", data="FontFlags", width=140, }, }, -- no table="Stat" entry uses the Ns.DropListTables[stat] table  -- ["OutlineTable"] is in a table of tables in Config.
	{ stat="StatIcons", icon="", spellclass="Display", default=true, widget={ type="CheckBox", }, },
	{ stat="StatTextAbreviate", spellclass="Display", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="StatTextCaps", spellclass="Display", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="TextSeparator", icon="", spellclass="Display", default=":", widget={ type="DropList", data="TextDataSeparator", width=90, },  },
	{ stat="StatTextColor", icon="", spellclass="Display", default={ r=1, g=1, b=1, }, widget={ type="ColorPicker", }, newline=true, },
	{ stat="ClassColors", spellclass="Display", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="DataColor", icon="", spellclass="Display", default={ r=1, g=1, b=1, }, widget={ type="ColorPicker", }, },
	{ stat="SplitColors", spellclass="Display", icon="", default=false, widget={ type="CheckBox", }, tooltip=true, },
	{ stat="StatWidth", icon="", spellclass="Display", default=150, widget={ type="Slider", min=70, max=300, valuestep=0.01, width=140, }, newline=true, tooltip=true, subgroup={ text="AlignmentText", icon="Spacing", }, },
	{ stat="StatSpacingH", icon="", spellclass="Display", default=1, widget={ type="Slider", min=1, max=80, width=140, }, },
	{ stat="StatSpacingV", icon="", spellclass="Display", default=0, widget={ type="Slider", min=0, max=80, valuestep=0.01, width=140, }, },
	{ stat="StatAlignment", icon="", spellclass="Display", default="TOPLEFT", widget={ type="DropList", data="Alignments", width=90, }, newline=true, },
	{ stat="IconAlignment", icon="", spellclass="Display", default="TOPLEFT", widget={ type="DropList", data="IconAlignments", width=90, },  },
	{ stat="Minimap", icon="", spellclass="HUD", default={ Show=true, }, widget={ type="MinimapButton", }, newline=true, subgroup={ text="MinimapGroupText", icon="MinimapIcon", }, },
	{ stat="CompButton", spellclass="HUD", icon="", default=true, widget={ type="CheckBox", }, },
	{ stat="EventEnable", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, tooltip=true, },
	{ stat="EventWorld", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, newline=true, },
	{ stat="EventDungeon", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="EventRaid", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="EventPvP", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, newline=true, },
	{ stat="EventArena", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="EventCombat", spellclass="Events", icon="", default=false, widget={ type="CheckBox", }, },
	{ stat="Profiles", icon="", svnotintable=true, spellclass="Profiles", widget={ type="ProfileConfig", data="Profiles", width=200, }, },
	{ stat="FAQ", icon="", svnotintable=true, spellclass="FAQ", widget={ type="FAQConfig", data="Profiles", width=200, }, },
	{ stat="StatOrderSettings", icon="", svnotintable=true, spellclass="DisplayOrder", widget={ type="DisplayOrderConfig", data="Profiles", width=200}, },
}

--------------------------------------
--			Droplist tables			--
--------------------------------------
function Ns.CopyTable(src, dest)
	for index, value in pairs(src) do
		if type(value) == "table" then
			dest[index] = {}
			Ns.CopyTable(value, dest[index])
		else
			dest[index] = value
		end
	end
end

function Ns:CheckForStats(currentprofile, class)
	local statSettings = Ns:GetClassDefaults(class)
	for k, v in pairs(Ns.DefaultOrder) do
		if not currentprofile.Stats[v.stat] then
			currentprofile.Stats[v.stat] = {}
			currentprofile.Stats[v.stat].Show = statSettings[v.stat] or false
			if v.options then
				for o,_ in pairs(v.options) do
					for _, so in pairs(Ns.Options) do
						if so.stat == o and so.default then
							currentprofile.Stats[v.stat][so.stat] = so.default
							break
						end
					end
				end
			end
		end
	end
end

function Ns:CreateProfile(newprofile, currentprofile, class) -- copies settings from the current to the new one
	if not currentprofile then
		if not class then
			print("Sinstats: No profile to copy from")
			return
		end
		currentprofile = {}
		for _, options in pairs(Ns.SettingsDisplayOrder) do
			currentprofile[options.stat] = options.default
		end
		currentprofile.Stats = {}
		Ns:CheckForStats(currentprofile, class)
	end
	SinStatsDB.profiles[newprofile] = {}
	Ns.CopyTable(currentprofile, SinStatsDB.profiles[newprofile])
end

------------------------------------------
--			Design Functions			--
------------------------------------------
local function DisplayHorizontal(self, anchorframe, align, astab, noicons)--, displayOrder, key, matchwith, noicons)
	widget = widget and strtrim(widget) or nil
 	local largestWidgetWidth, largestWidgetHeight = 0, 0
	for k, v in ipairs(self.DisplayOrder) do
		if not v.spellclass or v.spellclass == self.MyInformation.stat or (self.MyInformation.options and self.MyInformation.options[v.spellclass]) then
			local f = Ns:GetWidget(astab and "TopTab" or v.widget.type, Ns.ConfigFrame, k)
			anchorframe:AddWidget(f)
			f.ActiveOnInit = astab and v.activeonload -- must come before f:Init
			f:Init(anchorframe, self, noicons)
			local w = f:GetWidth()
			local h = f:GetHeight()
			if w > largestWidgetWidth then
				largestWidgetWidth = w
			end
			if h > largestWidgetHeight then
				largestWidgetHeight = h
			end
			if v.tooltip then
				f.Tooltip = Ns:GetWidget("Tooltip", f)
				f.Tooltip:Init(f, v)
			end
		end
	end
	largestWidgetHeight = ceil(largestWidgetHeight)
	largestWidgetWidth = ceil(largestWidgetWidth)
 	local maxItemsPerRow = floor(Ns.maxOptionsWidth / (largestWidgetWidth + HOptionsOffsetX))
 	local firstOnRow, lastAnchor = anchorframe, anchorframe
 	local rows, modOffset = 0, 1
 	local cols = min(maxItemsPerRow, #anchorframe.CurrentWidgets)
 	local pageAlignment = anchorframe.CenterAlign and "TOP" or "TOPLEFT"
 	local headerHeight = anchorframe.Description:GetHeight() + 24 -- y offset between header and top tabs
 	local SubGroupOs, SubGroupLabel
	for k, v in ipairs(anchorframe.CurrentWidgets) do
		if astab then
			v:SetWidth(largestWidgetWidth)
		end
		v:ClearAllPoints()
		local modVal = (k-modOffset) % maxItemsPerRow
		if k == 1 or v.MyInformation.newline or modVal == 0 then
			local yos = 0
			if k == 1 then
				yos = (HOptionsOffsetY * 2) + (headerHeight + 2) + anchorframe.Label:GetHeight()
			else
				if v.MyInformation.newline then
					modOffset = modOffset + modVal
				end
			end
			if v.Tip then
				yos = yos + 17  -- CHANGES THE Y OFFSET OF 1ST ROW AND 2ND ROW OPTIONS - TOGETHER
			end
			rows = rows + 1
			yos = k == 1 and -yos or -(yos + largestWidgetHeight + HOptionsOffsetY)
			if v.MyInformation.newline and v.MyInformation.subgroup then
				SubGroupOs = (rows + 2) * largestWidgetHeight + separatorOffsetY + 20 -- 2nd breakline offset
				local text = v.MyInformation.subgroup.text and v.MyInformation.subgroup.text or v.MyInformation.subgroup.stat
				SubGroupLabel = format(Ns.WidgetDisplayFormat, Ns:GetSpellIcon(v.MyInformation.subgroup), L[text])
				--local text = v.MyInformation.subgroup.text and v.MyInformation.subgroup.text or v.MyInformation.subgroup.stat
				--local iconSource = v.MyInformation.subgroup.icon and v.MyInformation.subgroup or v
				yos = yos - (HOptionsOffsetY * 25) -- 2nd row options offset
			end
			v:SetPoint("TOPLEFT", firstOnRow, "TOPLEFT", 0, yos)
			firstOnRow = v
			--savYos = yos
		else
			v:SetPoint(pageAlignment, lastAnchor, largestWidgetWidth + HOptionsOffsetX, 0)
		end
		lastAnchor = v
		if v.SetLink then
			v:SetLink(anchorframe, self)
		end
		v:Show() -- required because widgets are hidden when they are "killed"
	end
	local width
	if SubGroupLabel or not astab then
		anchorframe.TopSeparator = Ns:GetWidget("Separator", anchorframe)
		anchorframe.TopSeparator:SetPoint("CENTER", anchorframe, "TOP", 0, -28)
		anchorframe.TopSeparator:Show()
		SubGroupOs = SubGroupOs or (rows + 1) * (largestWidgetHeight + separatorOffsetY)

		if SubGroupLabel then -- Adds bottom separator Minimap/Alignment
			anchorframe.BottomSeparator = Ns:GetWidget("Separator", anchorframe)
			anchorframe.BottomSeparator:Init()
			anchorframe.BottomSeparator:SetTextColor(anchorframe.BottomSeparator.OrangeColor.r, anchorframe.BottomSeparator.OrangeColor.g, anchorframe.BottomSeparator.OrangeColor.b)
			anchorframe.BottomSeparator:SetLabel(SubGroupLabel)
			anchorframe.BottomSeparator:SetPoint("CENTER", anchorframe, "TOP", 0, -SubGroupOs)
			anchorframe.BottomSeparator:Show()
		else -- Adds bottom separator with description text
			anchorframe.BottomSeparator = Ns:GetWidget("Separator", anchorframe)
			anchorframe.BottomSeparator:Init(true)
			anchorframe.BottomSeparator:ClearAllPoints()
			anchorframe.BottomSeparator:SetPoint("CENTER", anchorframe.Description, "BOTTOM", 23, -SubGroupOs + 30)
			if self.MyInformation.options or self.MyInformation.description then
				anchorframe.BottomSeparator:AnchorLabel("TOPLEFT", 5, -15, true)
				anchorframe.BottomSeparator:SetLabel(L[self.MyInformation.stat.."Description"])
			end
			anchorframe.BottomSeparator:SetTextColor(1,1,1) -- description text for stats
			anchorframe.BottomSeparator:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 4) -- font size
			anchorframe.BottomSeparator:EnableToolip(true)
			anchorframe.BottomSeparator:Show()
		end
		width = Ns.SeparatorWidth
	else
		width = cols * (largestWidgetWidth + HOptionsOffsetX) - (rows == 1 and HOptionsOffsetX or 0)
	end
	local height = rows * (largestWidgetHeight + HOptionsOffsetY) + HOptionsOffsetY + headerHeight + anchorframe.Label:GetHeight() + 20
	anchorframe:SetAnchor(align, width, height)-- + headerHeight)
end

function Ns:UpdateProfile()
	for i=0, #Ns.ConfigFrame.MainMenuItems do
		if i == 0 then
			Ns.ConfigFrame.MainMenuItems[i].SvTable = Ns.Profile
		else
			Ns.ConfigFrame.MainMenuItems[i].SvTable = Ns.Profile.Stats
		end
	end
end

----------------------------------
--			Main Menu			--
----------------------------------
local function CreateMainMenu()
	local last, click
	for i=0, #Ns.SpellClass do
		local v = Ns.SpellClass[i]
		local f = Ns:GetWidget("MainMenuButton", Ns.ConfigFrame, sidePanelWidth) -- -10)
		Ns.ConfigFrame.MainMenuItems[i] = f
		f:SetID(i)
		f:SetFontSize(15)
		f:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
		f:SetLabel(format(Ns.WidgetDisplayFormat, Ns:GetSpellIcon(v), L[Ns.SpellClass[i].stat]))--, "THICKOUTLINE")
		f.SpellClass = v.stat
		if i == 0 then -- Settings Tabs
			click = f
			f.DisplayOrder = Ns.SettingsGroupOrder
			f.GroupOrder = Ns.SettingsGroupOrder
			f.NextDisplayOrder = Ns.SettingsDisplayOrder
--			f.SvTable = Ns.Profile
		else  -- SpellClass Tabs
			f.DisplayOrder = Ns.DefaultOrder
			f.GroupOrder = Ns.SpellClass
			f.NextDisplayOrder = Ns.Options --Ns.OptionsList --Ns.GetStatOptionDefaults
--			f.SvTable = Ns.Profile.Stats
		end
		f.MyInformation = v
		f.DisplayFunc = DisplayHorizontal
		if i == 0 then
			f:SetPoint("TOPLEFT", Ns.ConfigFrame.TopBorder, "LEFT", 0, mainMenuYOffset) -- the first main menu item position relative to the top border line
			last = f
		else
			f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
			last = f
		end
 		Ns:UpdateProfile()
	end
	click:Click()
end

--------------------------------------
--			Config frame			--
--------------------------------------
local function ColorBorders(self, r, g, b, a)
    for i=1, 4 do
        self.Borders[i]:SetColorTexture(r, g, b, a and a or 1)
    end
end

local function CreateBorder(frame, size)
    local f = frame
    local t = size or 1
    f.SetBorderColor = f.SetBorderColor or ColorBorders
    f.Borders = f.Borders or {}
    local offset = (t/2)
    for i=1, 4 do
        if not f.Borders[i] then
            f.Borders[i] = f:CreateLine(nil, "BORDER", nil, 0)
        end
        local b = f.Borders[i]
        b:SetThickness(t)
        b:SetColorTexture(1, 1, 1, 1)
        if i==1 then
            b:SetStartPoint("TOPLEFT", -offset, 0)
            b:SetEndPoint("TOPRIGHT", offset, 0)
        elseif i==2 then
            b:SetStartPoint("TOPRIGHT", 0, offset)
            b:SetEndPoint("BOTTOMRIGHT", 0, -offset)
        elseif i==3 then
            b:SetStartPoint("BOTTOMRIGHT", offset, 0)
            b:SetEndPoint("BOTTOMLEFT", -offset, 0)
        else
            b:SetStartPoint("BOTTOMLEFT", 0, -offset)
            b:SetEndPoint("TOPLEFT", 0, offset)
        end
    end
end

local f = CreateFrame("frame", "SinStatsConfigFrame", UIParent)
f:SetPoint("CENTER")
f:SetMovable(true)
f:SetUserPlaced(true)
f:EnableMouse(true)
f:Hide()

local function InitConfig()
	local f = SinStatsConfigFrame
	Ns.ConfigFrame = f
	f.MainMenuItems = {} -- Toplevel items always visible

	f.Background = f:CreateTexture()
	f.Background:SetAllPoints()
	f.Background:SetColorTexture(0.09020, 0.09020, 0.09020, 1)
	f:SetSize(Ns.ConfigWidth or 800, Ns.ConfigHeight or 500)

	f.SideBackground = f:CreateTexture()
	f.SideBackground:SetDrawLayer("ARTWORK", 1)
	f.SideBackground:SetSize(151, Ns.ConfigHeight)
	f.SideBackground:SetPoint("TOPLEFT", 0, 0)
	f.SideBackground:SetColorTexture(0.08020, 0.08020, 0.08020, 0.5)

	f:SetClampedToScreen(false)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(self) self:StartMoving() end)
	f:SetScript("OnDragStart", function(self) self:StartMoving() end)
	f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	f:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, Ns.ConfigFrame:GetName())
	f.Close = CreateFrame('Button', '$parentClose', f, "UIPanelCloseButton")
	f.Close:SetPoint('TOPRIGHT', -11, -5)
	f.Close:SetSize(15, 15)
	f.Close:SetFrameLevel(4)
	f.Close:SetHighlightTexture(Ns.TexturePath.."Close")
	f.Close:GetHighlightTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 1)
	f.Close:SetNormalTexture(Ns.TexturePath.."Close")
	f.Close:GetNormalTexture():SetVertexColor(white.r, white.g, white.b, 0.3)
	f.Close:SetPushedTexture(Ns.TexturePath.."Close")
	f.Close:GetPushedTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.9)
	f.Close:SetScript('OnClick', function(self)
		self:GetParent():Hide()
	end)

	f.Title = f:CreateFontString("$parentTitle", "OVERLAY")
	f.Title:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize)
	f.Title:SetPoint("TOP", 0, -15)
	f.Logo = f:CreateTexture("$parentLogo", "OVERLAY")
	f.Logo:SetTexture(Ns.TexturePath.."SinStatsLogo")
--[[
	f.Logo:SetSize(300, 300) -- So the frame isn't mostly blank when first opened (MainMenuScripts.OnClick for where it's moved)
	f.Logo:SetPoint("CENTER", 70, -10)
]]--
	f.Logo:SetSize(75, 75)
	f.Logo:SetPoint("TOPLEFT", 25, 3)

	f.Caption = CreateFrame("Frame", nil, f) -- Does the actual dragging
	f.Caption:SetPoint("TOPLEFT")
	f.Caption:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -50)

	f.TopBorder = f:CreateLine()
	f.TopBorder:SetDrawLayer("OVERLAY", 1)
	f.TopBorder:SetThickness(3)
	f.TopBorder:SetAlpha(0.5)
	f.TopBorder:SetStartPoint("BOTTOMLEFT", f.Caption, 10, 100)
	f.TopBorder:SetEndPoint("BOTTOMRIGHT", f.Caption, -10, -2)
	f.TopBorder:SetColorTexture(0.05, 0.05, 0.05, 0)

	f.SideBorder = f:CreateLine()
	f.SideBorder:SetDrawLayer("OVERLAY", 1)
	f.SideBorder:SetThickness(1)
	f.SideBorder:SetAlpha(1)
	f.SideBorder:SetStartPoint("LEFT", f.TopBorder, 141, 0)
	f.SideBorder:SetEndPoint("BOTTOMLEFT", f, 151, 0)
	--f.SideBorder:SetColorTexture(unpack(borderColor))
	f.SideBorder:SetColorTexture(0, 0, 0)


	-- Corner textures
	f.topRight = f:CreateTexture("$parentTopRight", "OVERLAY")
	f.topRight:SetTexture(Ns.TexturePath.."top_right-corner")
	f.topRight:SetSize(20, 20)
	f.topRight:SetPoint("TOPRIGHT", 3, 3)

	f.bottomLeft = f:CreateTexture("$parentBotLeft", "OVERLAY")
	f.bottomLeft:SetTexture(Ns.TexturePath.."bottom_left-corner")
	f.bottomLeft:SetSize(20, 20)
	f.bottomLeft:SetPoint("BOTTOMLEFT", -3, -3)

	f.bottomRight = f:CreateTexture("$parentBotRight", "OVERLAY")
	f.bottomRight:SetTexture(Ns.TexturePath.."bottom_right-corner")
	f.bottomRight:SetSize(20, 20)
	f.bottomRight:SetPoint("BOTTOMRIGHT", 3, -3)

	f.topLeft = f:CreateTexture("$parentTopLeft", "OVERLAY")
	f.topLeft:SetTexture(Ns.TexturePath.."top_left-corner")
	f.topLeft:SetSize(20, 20)
	f.topLeft:SetPoint("TOPLEFT", -3, 3)

	-- Version
	f.Version = f:CreateFontString("$parentTitle", "OVERLAY")
	f.Version:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 6)
	f.Version:SetPoint("BOTTOMLEFT", 65, 1)
	f.Version:SetText("|cff71ffc9" .. addVer .. "|r")

	local _, _, _, y = f.SideBorder:GetStartPoint()
	sidePanelWidth = select(3, f.SideBorder:GetStartPoint())
	Ns.maxOptionsWidth = f:GetWidth() - sidePanelWidth - 30 -- -30 right indent size
	Ns.SeparatorWidth  = Ns.maxOptionsWidth / 1.15
	f.TopAnchor = CreateFrame("Frame", nil, f)
	f.TopAnchor:SetSize(5, 2)
	f.TopAnchor:SetPoint("TOP", (sidePanelWidth/2), y-10) -- x,y entire right side panel content
	Ns.TopAnchor = f.TopAnchor

	CreateMainMenu()
	CreateBorder(f, 2)
	ColorBorders(f, 0, 0, 0)
end

function Ns:ToggleConfig()
	if not Ns.ConfigFrame then
		InitConfig()
	end
	Ns.ConfigFrame:SetShown(not Ns.ConfigFrame :IsShown())
end