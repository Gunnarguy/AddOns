local AddName, Ns = ...
local L = Ns.L

local newTicker, rowWidget
local gttFont, gttFontSize, gttFontFlags
local settingsOffsetY, dropListRowHeight = -15, 18
local checkBoxHeight, radioSize, defaultLabelOsW, MainMenuButtonHeight, topTabHeight = 30, 14, 40, 21, 22
local topTabColor = { r=0.298, g=0.298, b=0.298, a=0}
--local topTabVar = { r=0.11373, g=0.11373, b=0.11373, a=0}
--local backdropBorderColor = { r=0, g=0, b=0, a=1 }
local greenColor = { r=0.443, g=1, b=0.788 }
local redColor = { r=1, g=0, b=0.658 }
local orangeColor = { r=1, g=0.741, b=0.313 }
--local blueColor = { r=0.258, g=0.631, b=0.960 }

local anchorLableHeight = 10

Ns.WidgetDisplayFormat = "%s %s"

local opPoints = {
	LEFT = { point="RIGHT", x=-5, y=0, use="x", },
	RIGHT = { point="LEFT", x=5, y=0, use="x" },
	CENTER = { point="CENTER", use="xy" },
}

local TooltipOffsets = {
	Default = { point="RIGHT", topoint="LEFT", x=100, y=24 },
	CheckBox = { point="LEFT", topoint="RIGHT", x=-2, y=4 },
    EditBox = { point="LEFT", topoint="RIGHT", x=6, y=1 },
	Slider = { point="LEFT", topoint="RIGHT", x=-55, y=16 },
}

local Mixins, WidgetPool = { scripts={}, functions={} }, {}

local W = {}
Ns.W = W
Ns.Mixins = Mixins

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
        b:SetColorTexture(0, 0, 0, 1)
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

local WidgetBG = {
	bgFile="Interface/BUTTONS/WHITE8X8",
	--edgeFile="Interface/Tooltips/UI-Tooltip-Border",
	tile=false,
	edgeSize=3,
	tileSize=0,
	insets={ left=1, right=1, top=1, bottom=1, },
}

local EditBoxBG = {
	bgFile="Interface/BUTTONS/WHITE8X8",
	--edgeFile="Interface/Tooltips/UI-Tooltip-Border",
	tile=false,
	edgeSize=4,
	tileSize=0,
	insets={ left=1, right=1, top=1, bottom=1, },
	--insets={ left=1, right=1, top=3, bottom=4, },
}

local RadioBG = {
	bgFile="Interface/BUTTONS/WHITE8X8",
	--edgeFile="Interface/Tooltips/UI-Tooltip-Border", 
	tile=false,
	edgeSize=1,
	tileSize=0,
	insets={ left=1, right=4, top=1, bottom=9, },
}

local SliderBG = {
	bgFile="Interface/BUTTONS/WHITE8X8",
	--edgeFile="Interface/Tooltips/UI-Tooltip-Border",
	tile=false,
	edgeSize=4,
	tileSize=0,
	insets={ left=1, right=1, top=1, bottom=1, },
}

local DragBG = {
	bgFile="Interface/BUTTONS/WHITE8X8",
	edgeFile="Interface/Tooltips/UI-Tooltip-Border",
	tile=false,
	edgeSize=7,
	tileSize=0,
	insets={ left=0, right=0, top=0, bottom=0, },
}

----------------------------------
--			Fonts Init			--
----------------------------------
local LSM = LibStub("LibSharedMedia-3.0")
Ns.LSM = LSM
LSM:Register("font", "Accidental Presidency", [[Interface\Addons\SinStats\fonts\Accidental Presidency.ttf]])
LSM:Register("font", "Oswald", [[Interface\Addons\SinStats\fonts\Oswald-Regular.otf]])
LSM:Register("font", "FORCED SQUARE", [[Interface\Addons\SinStats\fonts\FORCED SQUARE.ttf]])
LSM:Register("font", "Bazooka", [[Interface\Addons\SinStats\fonts\Bazooka.ttf]])
LSM:Register("font", "DorisPP", [[Interface\Addons\SinStats\fonts\DORISPP.ttf]])
LSM:Register("font", "Enigmatic", [[Interface\Addons\SinStats\fonts\Enigma__2.ttf]])
LSM:Register("font", "Liberation Sans (U)", [[Interface\Addons\SinStats\fonts\LiberationSans-Regular.ttf]])
LSM:Register("font", "White Rabbit", [[Interface\Addons\SinStats\fonts\WHITRABT.ttf]])
LSM:Register("font", "Monofonto", [[Interface\Addons\SinStats\fonts\MONOFONT.ttf]])
LSM:Register("font", "FSEX300 (U)", [[Interface\Addons\SinStats\fonts\FSEX300.ttf]])
LSM:Register("font", "PT Sans", [[Interface\Addons\SinStats\fonts\PTSansNarrow.ttf]])

----------------------------------------------
--			Droplist Source Tables			--
----------------------------------------------
local ListData = {}
ListData.FontFlags = {
	{ text=L["None"], value="" },
	{ text=L["Thin"], value="OUTLINE", },
	{ text=L["Thick"], value="THICKOUTLINE" },
	{ text=L["Monochrome"], value="MONOCHROME" },
	{ text=L["Thin Monochrome"], value="OUTLINE, MONOCHROME" },
	{ text=L["Thick Monochrome"], value="THICKOUTLINE, MONOCHROME" },
}
ListData.TextDataSeparator = {
	{ text=L[":"], value=":", },
	{ text=L["-"], value=" -", },
	{ text=L["|"], value=" | ", },
	{ text=L["/"], value=" /", },
	{ text=L[">"], value=" >", },
	{ text=L["<"], value=" <", },
	{ text=L["None"], value="", },
}
ListData.Alignments = {
	{ text=L["Left"], value="TOPLEFT", },
	{ text=L["Right"], value="TOPRIGHT", },
	{ text=L["Center"], value="TOP", },
}
ListData.IconAlignments = {
	{ text=L["Left"], value="TOPLEFT", },
	{ text=L["Right"], value="TOPRIGHT", },
}
ListData.Rows = {
	{ text=1, value=1, },
	{ text=2, value=2, },
	{ text=3, value=3, },
	{ text=4, value=4, },
	{ text=5, value=5, },
}
ListData.Strata = {
	{ text=L["Lowest"], value="BACKGROUND", },
	{ text=L["Low"], value="LOW", },
	{ text=L["Medium"], value="MEDIUM", },
	{ text=L["High"], value="HIGH", },
	{ text=L["Highest"], value="TOOLTIP", },
}

ListData.Decimals = {
	{ text=0, value=0, },
	{ text=1, value=1, },
	{ text=2, value=2, },
	{ text=3, value=3, },
}

ListData.Fonts = {}
for k, v in ipairs(Ns.LSM:List("font")) do
	tinsert(ListData.Fonts, { text=v, value=v, })
end

ListData.Profiles = {}
local function UpdateProfiles()
	wipe(ListData.Profiles)
	for k, v in pairs(SinStatsDB.profiles) do
		tinsert(ListData.Profiles, { text=k, value=k })
	end
	sort(ListData.Profiles, function(a, b)
		return a.text < b.text
	end)
end

--------------------------------------
--			Local Functions			--
--------------------------------------
local TipFormat = "%s"
local function AdjustCheckTip(self, text)
--	self:SetWidth(self:GetWidth() + self.Label:GetWidth())
	self.Tip:SetText(format(TipFormat, L[text.."Tip"]))
	self.Tip:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
end

local function AdjustTopTabText(self, text)
	self:SetWidth(self.Label:GetWidth() + defaultLabelOsW)
end

local function AddTipText(self)
	self.Tip = self:CreateFontString(nil, "OVERLAY")
	self.Tip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3) -- CHECKBOX TIP TEXT
	self.Tip:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -5) -- TIP TEXT SIZE
	self.Tip:SetJustifyH("LEFT")
	self.Tip:SetJustifyV("TOP")
end

local function AddLabel(self)
	self.Label = self:CreateFontString(nil, "OVERLAY")
	Mixin(self.Label, Mixins.functions.Labels)
	Mixin(self, Mixins.functions.HasFontString)
	self:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
end

local function AnchorWidget(self, location, x, y, notrelative) -- location = where the lab el will be located in relation to the parent
	location = strupper(location)
	local anchor = (notrelative and location) or opPoints[location] or location  -- because the anchor point will actually be the opposite of the location (topoint)
	self:ClearAllPoints()
	self:SetPoint(anchor.point or location, self:GetParent(), location, x or anchor.x, y or anchor.y)
end

local function CancelTicker(self, leaveshown)
	self:Cancel()
	if not leaveshown then
		rowWidget:Hide()
	end
	rowWidget = nil
	newTicker = nil
end

local function GetLabelText(text, myinformation, noicons)
	if noicons then
		return strtrim(L[text])
	else
		return format(Ns.WidgetDisplayFormat, Ns:GetSpellIcon(myinformation), strtrim(L[text]))
	end
end

local function KillPage(page)
	if Ns.ConfigFrame[page] then
		Ns:KillWidget(Ns.ConfigFrame[page])
		Ns.ConfigFrame[page] = nil
	end
end

local function OnEnterFunc(self)
	if newTicker then
		if rowWidget and rowWidget == self.List then
			CancelTicker(newTicker, true)
		else
			CancelTicker(newTicker)
		end
	end
end

local function OnLeaveFunc(self)
	if not self:IsMouseOver() and not self.List:IsMouseOver() and self.List:IsShown() then
		rowWidget = self.List
		if newTicker then
			CancelTicker()
		end
		newTicker = C_Timer.NewTicker(1, CancelTicker)
	end
end

local function PlayOnTab()
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN, "Ambience")
end

local function PlayOnCheck()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, "Ambience")
end

local function SetAnchorText(self, text, anchorcenter)
	if #self.CurrentWidgets == 0 then
		return
	end
	self:SetAnchor()
end

--------------------------------------
--			Label Functions			--
--------------------------------------
Mixins.functions.Labels = {}

function Mixins.functions.Labels.Anchor(self, location, x, y, notrelative)
	AnchorWidget(self, location, x, y, notrelative)
end

------------------------------------------
--	Parents with Label Functions		--
------------------------------------------
Mixins.functions.HasFontString = {}
function Mixins.functions.HasFontString.AnchorLabel(self, location, x, y, notrelative)
	AnchorWidget(self.Label, location, x, y, notrelative)
end

function Mixins.functions.HasFontString.GetLabel(self)
	return self.Label:GetText()
end

function Mixins.functions.HasFontString.GetLabelHeight(self)
	return math.ceil(self.Label:GetHeight())
end

function Mixins.functions.HasFontString.SetFont(self, font, size, flags)
	local text = self.Label
	local setFont = font or Ns.ConfigDefaultFont
	local setSize = size or Ns.ConfigDefaultFontSize
	text:SetFont(setFont, setSize)
end

function Mixins.functions.HasFontString.SetFontSize(self, size)
	local f, s = self.Label:GetFont()
	self.Label:SetFont(f, size)
end

function Mixins.functions.HasFontString.SetJustifyH(self, justify)
	self.Label:SetJustifyH(justify)
end

function Mixins.functions.HasFontString.SetJustifyV(self, justify)
	self.Label:SetJustifyV(justify)
end

function Mixins.functions.HasFontString.SetTextColor(self, r, g, b, a)
	self.Label:SetTextColor(r, g, b, a)
end

function Mixins.functions.HasFontString.SetLabel(self, text)
	self.Label:SetText(text)
end


------------------------------------------
--			Widgets and Mixins			--
------------------------------------------

--------------------------------------
--			Anchor Frame			--
--------------------------------------
function W.AnchorFrame(parent)
	local f = CreateFrame("Frame", nil, parent)
	f:SetSize(5, 5)
	f.SpecialType = "AnchorFrame"
	f:SetFrameStrata("HIGH")
	local borderOffset = Ns.maxOptionsWidth / 2.5
	AddLabel(f)
	f:AnchorLabel("TOP", 0, 0, true)
	f.Label:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize + anchorLableHeight)
	f.Label:SetJustifyH("CENTER")

	f.Description = f:CreateFontString()
	f.Description:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -3)
	f.Description:SetPoint("TOP", f.Label, "BOTTOM", -25, -5)
	--f.Description:SetJustifyH('TOP')
	f.Description:SetJustifyH('LEFT')
	f.Description:SetWidth(Ns.maxOptionsWidth - (borderOffset / 2))

	f.CurrentWidgets = {}
	Mixin(f, Mixins.functions.AnchorFrames)
	hooksecurefunc(f, "SetLabel", SetAnchorText)
	return f
end

Mixins.functions.AnchorFrames = {}
function Mixins.functions.AnchorFrames.AddWidget(self, widget)
	widget:SetParent(self)
	tinsert(self.CurrentWidgets, widget)
end

function Mixins.functions.AnchorFrames.Reset(self)
	self.ActiveWidget = nil
	self.CenterAlign = nil
	self:SetLabel("")
	self.Description:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -3) -- STATS TEXT FIRST BREAKLINE
	for k, v in pairs(self.CurrentWidgets) do
		Ns:KillWidget(v)
	end
	wipe(self.CurrentWidgets)
	if self.TopSeparator then
		Ns:KillWidget(self.TopSeparator)
		self.TopSeparator = nil
	end
	if self.BottomSeparator then
		Ns:KillWidget(self.BottomSeparator)
		self.BottomSeparator = nil
	end
end

function Mixins.functions.AnchorFrames.SetActive(self, widget)
	local w = self.ActiveWidget
	self.ActiveWidget = widget
	if w and w ~= self.ActiveWidget then
		w:Click()
	end
end

function Mixins.functions.AnchorFrames.SetAnchor(self, anchor, width, height)
	if #self.CurrentWidgets == 0 then
		return
	end
	self.PageAnchor = anchor
	self.BaseWidth = width and width or self.BaseWidth
	self.BaseHeight = height and height or self.BaseHeight
	self:ClearAllPoints()
	self:SetPoint("TOP", anchor, "BOTTOM", 0, settingsOffsetY)
	local reAnchor = self.CurrentWidgets[1]
	--local p, r, t, x, y = reAnchor:GetPoint(1)
 	local offsetY = 0
	self:SetSize(self.BaseWidth, self.BaseHeight + offsetY)
end

----------------------------------
--			Separator			--
----------------------------------
function W.Separator(parent)
	local f = CreateFrame("Frame", nil, parent)
	f:SetSize(Ns.SeparatorWidth, 5)
	f.SpecialType = "Separator"
	f.Texture = f:CreateTexture()
	f.Texture:SetAllPoints()
	f.Texture:SetTexture(Ns.TexturePath.."Breakline")
	f.Texture:SetVertexColor(1, 1, 1, 0.7)
	AddLabel(f)
	f:AnchorLabel("TOPLEFT", 0, 20, true)
	f:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -3)
	f.Label:SetJustifyH("LEFT")
	--f.Label:SetJustifyV("BOTTOM")
	Mixin(f, Mixins.functions.Separator)
	for k, v in pairs(Mixins.scripts.Separator) do
		f:SetScript(k, v)
	end
	f.OrangeColor = orangeColor
	f:Hide()
	return f
end

Mixins.functions.Separator = {}
function Mixins.functions.Separator.Init(self, bottomlabel)
	if bottomlabel then
		self:AnchorLabel("TOPLEFT", 30, -20, true)
		self:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 5)
		--self.Label:SetJustifyV("TOP")
	end
end

function Mixins.functions.Separator.EnableToolip(self, enable)
	self:SetHyperlinksEnabled(enable)
end

function Mixins.functions.Separator.Reset(self)
	self:SetLabel("")
	self:AnchorLabel("TOPLEFT", 0, 20, true)
	self:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -3)
	self:SetTextColor(1,1,1)
	self:EnableToolip(false)
	--self.Label:SetJustifyV("BOTTOM")
end

Mixins.scripts.Separator = {}
function Mixins.scripts.Separator.OnHyperlinkEnter(self, link, text, region, left, bottom, width, height)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

function Mixins.scripts.Separator.OnHyperlinkLeave(self)
	GameTooltip:Hide()
end

----------------------------------
--			CheckButton			--
----------------------------------
function W.CheckButton(parent)
	local f = CreateFrame("CheckButton", nil, parent)
	f:SetSize(14, 14)
	f.SpecialType = "CheckButton"
	f:SetNormalTexture(Ns.TexturePath.."CheckOff")
	f:SetCheckedTexture(Ns.TexturePath.."CheckOn")
	f:GetCheckedTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b)
	f:GetCheckedTexture():SetBlendMode("ALPHAKEY")
	Mixin(f, Mixins.functions.CheckButton)
	for k, v in pairs(Mixins.scripts.CheckButton) do
		f:SetScript(k, v)
	end
	return f
end

Mixins.functions.CheckButton = {}
function Mixins.functions.CheckButton.Reset(self)
	self.ParentLink = nil
	self.ChildLink = nil
	self.Settings = nil
	self.Key = nil
	self:SetChecked(false)
	self:SetEnabled(true)
	self:Show()
end

Mixins.scripts.CheckButton = {}
function Mixins.scripts.CheckButton.OnClick(self)
	PlayOnCheck()
	self.Settings[self.Key] = self:GetChecked()
	local parent = self:GetParent()
	if parent.Linked and #parent.Linked > 0 then
		for k, v in ipairs(parent.Linked) do
			v[1]:SetEnabled(self:GetChecked() ~= v[2])
		end
	end
	if not self.DelayInit then
		Ns:InitialiseProfile(Ns.Profile)
	end
	if self.ParentLink then
		self.ParentLink:SetChecked(self:GetChecked())
	end
	if self.ChildLink then
		self.ChildLink:SetChecked(self:GetChecked())
	end
end

function Mixins.scripts.CheckButton.OnEnable(self)
	self:GetCheckedTexture():SetBlendMode("ALPHAKEY")
	local t = self:GetChecked() and self:GetNormalTexture() or self:GetCheckedTexture()
	t:Show()
end

function Mixins.scripts.CheckButton.OnDisable(self)
	self:GetCheckedTexture():SetBlendMode("ADD")
	local t = self:GetChecked() and self:GetNormalTexture() or self:GetCheckedTexture()
	t:Hide()

end
----------------------------------
--			ColorPicker			--
----------------------------------
function W.ColorPicker(parent)
	local f = CreateFrame("Button", nil, parent)
	f:SetSize(20, 20)
	f.SpecialType = "ColorPicker"
	f.ColorPad = f:CreateTexture(nil, "BACKGROUND", nil, 1)
	f.ColorPad:SetAllPoints()
	f.ColorPad:SetTexture(Ns.TexturePath.."ColorPad")
	f.ColorBorder = f:CreateTexture(nil, "BACKGROUND", nil, 4)
	f.ColorBorder:SetAllPoints()
	f.ColorBorder:SetTexture(Ns.TexturePath.."ColorBorder")
	f.ColorBorder:SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 1)
	f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	AddLabel(f)
	f:AnchorLabel("RIGHT", 35, 0, true)
	AddTipText(f)
	Mixin(f, Mixins.functions.ColorPicker)
	for k, v in pairs(Mixins.scripts.ColorPicker) do
		f:SetScript(k, v)
	end
	return f
end

local function SetPickerPadColor(self, r, g, b)
	self.ColorPad:SetVertexColor(r, g, b)
end

local function ColourPickerCancel(self)
	local colour = ColorPickerFrame.previousValues
	ColorPickerFrame.colourBox.Settings[ColorPickerFrame.colourBox.Key] = colour
	SetPickerPadColor(ColorPickerFrame.colourBox, colour.r, colour.g, colour.b)
	Ns:InitialiseProfile(Ns.Profile)
end

local function ColourPickerChange(self)
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local colour = { r=r, g=g, b=b }
	ColorPickerFrame.colourBox.Settings[ColorPickerFrame.colourBox.Key] = colour
	SetPickerPadColor(ColorPickerFrame.colourBox, colour.r, colour.g, colour.b)
	Ns:InitialiseProfile(Ns.Profile)
end

Mixins.functions.ColorPicker = {}
function Mixins.functions.ColorPicker.Init(self, anchorframe, parent)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.Settings = parent.MyInformation.svnotintable and parent.SvTable or parent.SvTable[parent.MyInformation.stat]
	self.Key = self.MyInformation.stat
	self:ColorInit()
end

function Mixins.functions.ColorPicker.ColorInit(self)
	local colour = self.Settings[self.Key]
	if not colour then
		colour = { r=1, g=1, b=1 }
	end
	self.ColorPad:SetVertexColor(colour.r, colour.g, colour.b)
	self:SetLabel(GetLabelText(self.MyInformation.stat, self.MyInformation, true))
	self.Tip:SetText(format(TipFormat, L[self.MyInformation.stat.."Tip"]))
	self.Tip:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	self.Tip:Show()
end

Mixins.scripts.ColorPicker = {}
function Mixins.scripts.ColorPicker.OnClick(self, button, down)
	if button == "RightButton" then
		if self.DefaultColor then
			SetPickerPadColor(self, self.DefaultColor.r, self.DefaultColor.g, self.DefaultColor.b)
			self.Settings[self.Key].r = self.DefaultColor.r
			self.Settings[self.Key].g = self.DefaultColor.g
			self.Settings[self.Key].b = self.DefaultColor.b
			self:ColorInit()
		end
		return
	end

	local basecolour = self.Settings[self.Key]
	local colour = { r=basecolour.r, g=basecolour.g, b=basecolour.b, }
	ColorPickerFrame.previousValues = colour
	ColorPickerFrame.colourBox = self
    if ColorPickerFrame.SetupColorPickerAndShow then -- 10.2.5 suport for ColorPicker changes
        local info = UIDropDownMenu_CreateInfo()
        info.r, info.g, info.b = colour.r, colour.g, colour.b
        info.swatchFunc = ColourPickerChange
        info.cancelFunc = ColourPickerCancel
        ColorPickerFrame:SetupColorPickerAndShow(info)
        if ColorPickerFrame.Content then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(colour.r, colour.g, colour.b)
		else
			ColorPickerFrame:SetColorRGB(colour.r, colour.g, colour.b)
		end
    else
        ColorPickerFrame.func = ColourPickerChange
        ColorPickerFrame.cancelFunc = ColourPickerCancel
        ColorPickerFrame:SetColorRGB(colour.r, colour.g, colour.b)
    end
    ColorPickerFrame:ClearAllPoints()
	--ColorPickerFrame.cancelFunc = ColourPickerCancel
	--ColorPickerFrame.func = ColourPickerChange
	-- ColorPickerFrame:SetColorRGB(colour.r, colour.g, colour.b)

	if self:GetRight() < UIParent:GetWidth() / 2 then
		ColorPickerFrame:SetPoint("LEFT", self, "RIGHT", 10, 0)
	else
		ColorPickerFrame:SetPoint("RIGHT", self, "LEFT", -10, 0)
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	ColorPickerFrame:Show()
end

function Mixins.scripts.ColorPicker.OnDisable(self)
	self:SetAlpha(0.5)
end

function Mixins.scripts.ColorPicker.OnEnable(self)
	self:SetAlpha(1)
end

------------------------------
--			Radio			--
------------------------------
function W.Radio(parent)
	local f = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	f:SetSize(checkBoxHeight, checkBoxHeight)
	f.SpecialType = "Radio"
	f:SetBackdrop(RadioBG)
	f:SetBackdropColor(0.184, 0.184, 0.184, 0.4)
	f:SetBackdropBorderColor(0.184, 0.184, 0.184, 0)
	Mixin(f, Mixins.functions.Radio)
	AddTipText(f)
	f.Tip:SetText(format(TipFormat, L["OptionsTip"]))
	f.Radios = {}
	for i=1, 3 do
		local r = CreateFrame("CheckButton", nil, f)
		tinsert(f.Radios, r)
		r:SetSize(radioSize, radioSize)
		r:SetNormalTexture(Ns.TexturePath.."RadioOff")
		r:SetCheckedTexture(Ns.TexturePath.."RadioOn")
		r:GetCheckedTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b)--(0.784, 0.850, 0.941)--(1, 0.737, 0)
		r:SetHighlightTexture(Ns.TexturePath.."Highlight")
		r:GetCheckedTexture():SetBlendMode("ALPHAKEY")
		AddLabel(r)
		r:AnchorLabel("RIGHT", 4, 0)
		for k, v in pairs(Mixins.scripts.Radio) do
			r:SetScript(k, v)
		end
		if i == 1 then
			r:SetPoint("BOTTOMLEFT", 6, 12)
		else
			r:SetPoint("LEFT", f.Radios[i-1].Label, "RIGHT", 8, 0)
		end
	end
	return f
end

Mixins.functions.Radio = {}
function Mixins.functions.Radio.Init(self, anchorframe, parent)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	if parent.MyInformation.svnotintable then
		self.Settings = parent.SvTable
		self.Tip:SetText(format(TipFormat, L[self.MyInformation.stat]))
		self.UpdateFunc = self.MyInformation.updatefunc
		self.AnchorFrame = anchorframe
	else
		self.Settings = parent.SvTable[parent.MyInformation.stat]
	end
	self.Key = self.MyInformation.stat
	self.Option = Ns.Options[self.MyInformation.option]
	local width = 0
	for k, v in ipairs(self.Radios) do
		v.OptionVal = k
		v:SetLabel(L[self.MyInformation.labels[k]])
		v:SetChecked(false)
		width = width + v:GetWidth() + v.Label:GetWidth() + 4
	end
	self:SetWidth(width + 32) --(2*8) + 12)
	self.Radios[self.Settings[self.Key]]:SetChecked(true)
end

function Mixins.functions.Radio.Reset(self)
	self.MyInformation = nil
	self.Settings = nil
	self.Key = nil
	self.Option = nil
	self.OptionVal = nil
	self.AnchorFrame = nil
	self.UpdateFunc = nil
	for k, v in ipairs(self.Radios) do
		v:SetChecked(false)
	end
end

Mixins.scripts.Radio = {}
function Mixins.scripts.Radio.OnClick(self)
	PlayOnCheck()
	for k, v in ipairs(self:GetParent().Radios) do
		if v == self then
			v:SetChecked(true)
		else
			v:SetChecked(false)
		end
	end
	self:GetParent().Settings[self:GetParent().Key] = self.OptionVal
	if self:GetParent().UpdateFunc then
		Ns[self:GetParent().UpdateFunc](self, self.OptionVal)
	end
	Ns:InitialiseProfile(Ns.Profile)
end

----------------------------------
--			Checkbox			--
----------------------------------
function W.CheckBox(parent)
	local f = CreateFrame("Button", nil, parent)
	f:SetSize(10, checkBoxHeight)
	f.SpecialType = "CheckBox"
	Mixin(f, Mixins.functions.CheckBoxFrame)
	f:SetHighlightTexture(Ns.TexturePath.."Highlight")
	f:GetHighlightTexture():SetAlpha(0.2)
	AddLabel(f)
	f:AnchorLabel("LEFT",  30, 5, true)
	f:SetLabel("")
	AddTipText(f)

	for k, v in pairs(Mixins.scripts.CheckBoxFrame) do
		f:SetScript(k, v)
	end
	f.Check = Ns:GetWidget("CheckButton", f)
	f.Check:SetPoint("LEFT", 9, 5)
	f.Check:SetSize(14,14)
	f.Check:SetHighlightTexture(Ns.TexturePath.."Highlight")
	f.Check:GetHighlightTexture():ClearAllPoints()
	f.Check:GetHighlightTexture():SetAllPoints(f:GetHighlightTexture())
	f.Check:GetHighlightTexture():SetAlpha(0.2)
	f:SetPoint("CENTER")
	return f
end

Mixins.functions.CheckBoxFrame = {}
function Mixins.functions.CheckBoxFrame.Init(self, anchorframe, parent)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.Check.Settings = parent.MyInformation.svnotintable and parent.SvTable or parent.SvTable[parent.MyInformation.stat]
	self.Check.Key = self.MyInformation.stat
	if self.Linked then
		wipe(self.Linked)
	end
	self.DisableOn = nil
	self.Check:SetChecked(self.Check.Settings[self.MyInformation.stat])
	self:SetLabel(GetLabelText(self.MyInformation.stat, self.MyInformation, true))
	self:SetWidth(self.Check:GetWidth() + self.Label:GetWidth() + 35)
	AdjustCheckTip(self, self.MyInformation.stat)
end

function Mixins.functions.CheckBoxFrame.Reset(self)
	self.Check:Reset()
	self:SetLabel("")
	self:SetWidth(5)
end

function Mixins.functions.CheckBoxFrame.SetLink(self, anchorframe, parent)
	if not self.MyInformation.linked or #self.MyInformation.linked == 0 then
		return
	end
	self.Linked = self.Linked or {}
	wipe(self.Linked)
	local i, total = 1, #self.MyInformation.linked
	while i < total do-- #self.MyInformation.linked do 
		--local link = self.MyInformation.linked[i]
		for k, v in ipairs(anchorframe.CurrentWidgets) do
			if parent.DisplayOrder[v:GetID()].stat == self.MyInformation.linked[i] then
				tinsert(self.Linked, { v, self.MyInformation.linked[i+1] })
				v:SetEnabled(self.Check:GetChecked() ~= self.MyInformation.linked[i+1])
				break
			end
		end
		i=i+2
	end
end

Mixins.scripts.CheckBoxFrame = {}
function Mixins.scripts.CheckBoxFrame.OnClick(self)
	PlayOnCheck()
	self.Check:Click()
end

function Mixins.scripts.CheckBoxFrame.OnEnable(self)
	self.Check:SetEnabled(true)
	self:SetAlpha(1)
end

function Mixins.scripts.CheckBoxFrame.OnDisable(self)
	self.Check:SetEnabled(false)
	self:SetAlpha(0.5)
end

----------------------------------
--			Droplists			--
----------------------------------
function W.DropList(parent)
	local f = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	f:SetSize(140, 20)
	f.SpecialType = "DropList"
	AddTipText(f)
	Mixin(f, Mixins.functions.DropListFrame)
	for k, v in pairs(Mixins.scripts.DropListFrame) do
		f:SetScript(k, v)
	end
	f:SetBackdrop(WidgetBG)
	--f:SetBackdropColor(0.184, 0.184, 0.184, 0.3)
	f:SetBackdropColor(0.27451, 0.27451, 0.27451, 0.3)
	f:SetBackdropBorderColor(0, 0, 0, 1)
	f.DropButton = CreateFrame("Button", nil, f)
	f.DropButton:SetSize(13, 13)
	f.DropButton:SetPoint("TOPRIGHT", -4, -4)
	f.DropButton:SetNormalTexture(Ns.TexturePath.."DropNormal")
	f.DropButton:GetNormalTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 1)--(0.784, 0.850, 0.941)--(1, 0.737, 0, 1)
	f.DropButton:SetPushedTexture(Ns.TexturePath.."DropPushed")
	f.DropButton:GetPushedTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 1)--(0.784, 0.850, 0.941)--(1, 0.737, 0, 1)
	f.DropButton:SetHighlightTexture(Ns.TexturePath.."Highlight")
	for k, v in pairs(Mixins.scripts.DropListButton) do
		f.DropButton:SetScript(k, v)
	end
	f.Text = f:CreateFontString()
	f.Text:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 4)
	f.Text:SetJustifyH("LEFT")
	f.Text:SetPoint("TOPLEFT", 4, -4)
	f.Text:SetPoint("BOTTOMRIGHT", f.DropButton, "BOTTOMLEFT", -4, 0)

	f.List = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
	f.List:Hide()
	f.List:SetSize(150, 70)
	f.List:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 0.6)
	f.List:SetBackdrop(WidgetBG)
	f.List:SetBackdropColor(0.150, 0.150, 0.150)
	f.List:SetBackdropBorderColor(0, 0, 0, 0.3)
	f.List.Buttons = {}
	Mixin(f.List, Mixins.functions.DropList)
	for k, v in pairs(Mixins.scripts.DropList) do
		f.List:SetScript(k, v)
	end
	return f
end

function W.DropListRow(parent)
	local f = CreateFrame("CheckButton", nil, parent)
	f:SetSize(10, dropListRowHeight)
	f.SpecialType = "DropListRow"
	f:SetNormalTexture("Interface/BUTTONS/WHITE8X8")
	f:GetNormalTexture():SetVertexColor(0.150, 0.150, 0.150, 0.4)
	f:SetCheckedTexture(Ns.TexturePath.."HighlightMenu")
	f:GetCheckedTexture():SetAlpha(0.3)
	--f:GetCheckedTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.3)--(0.784, 0.850, 0.941)--(1, 0.737, 0, 0.3)
	f:SetHighlightTexture(Ns.TexturePath.."HighlightMenu")
	f.Text = f:CreateFontString()
	f.Text:SetPoint("LEFT")
	f.Text:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 4)
	f.Text:SetJustifyH("LEFT")

	Mixin(f, Mixins.functions.DropListRow)
	for k, v in pairs(Mixins.scripts.DropListRow) do
		f:SetScript(k, v)
	end
	return f

end

Mixins.functions.DropListFrame = {}
function Mixins.functions.DropListFrame.Init(self, anchorframe, parent, displaylist)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self:SetEnabled(true)
	self:SetWidth(self.MyInformation.widget.width)
	self:SetFrameStrata("DIALOG")
	self.DropButton.MyInformation = parent.DisplayOrder[self:GetID()]
	self.DropButton.Settings = parent.MyInformation.svnotintable and parent.SvTable or parent.SvTable[parent.MyInformation.stat]
	self.DropButton.Key = self.MyInformation.stat ~= "Profiles" and self.MyInformation.stat or parent.Key
	self.DropButton.Data = ListData[self.MyInformation.widget.data]
	for k, v in ipairs(self.DropButton.Data) do
		if v.value == self.DropButton.Settings[self.DropButton.Key] then
			self:SetText(v.text)
			break
		end
	end
	self.Tip:SetText(format(TipFormat, L[self.DropButton.Key.."Tip"]))
	self.Tip:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	self.Tip:Show()
end

function Mixins.functions.DropListFrame.Reset(self)
	self.List:Hide()
end

function Mixins.functions.DropListFrame.SetEnabled(self, enabled)
	--local r, g, b, a = self:GetBackdropBorderColor()
	--a = enabled and 1 or 0.5
	self:SetBackdropBorderColor(0.184, 0.184, 0.184, 0.8)
	self.Text:SetAlpha(enabled and 1 or 0.5)
	self.DropButton:SetEnabled(enabled)
	self.DropButton:SetAlpha(enabled and 1 or 0.5)
end

function Mixins.functions.DropListFrame.SetText(self, text)
	self.Text:SetText(text)
end

Mixins.scripts.DropListFrame = {}
function Mixins.scripts.DropListFrame.OnEnter(self)
	OnEnterFunc(self)
end

function Mixins.scripts.DropListFrame.OnLeave(self)
	OnLeaveFunc(self)
end

Mixins.scripts.DropListButton = {}
function Mixins.scripts.DropListButton.OnClick(self)
	PlayOnCheck()
	local parent = self:GetParent()
	if not self:GetParent().List:IsShown() then
		parent.List.MyInformation = self.MyInformation
		parent.List.Settings = self.Settings
		parent.List.Key = self.Key
		parent.List.Data = self.Data
	end
	self:GetParent().List:SetShown(not self:GetParent().List:IsShown())
end

function Mixins.scripts.DropListButton.OnEnter(self)
	OnEnterFunc(self:GetParent())
end

function Mixins.scripts.DropListButton.OnLeave(self)
	self:GetParent():GetScript("OnLeave")(self:GetParent())
end

Mixins.functions.DropList = {}
function Mixins.functions.DropList.Reset(self)
	self:SetSize(5, 5)
	self.MyInformation = nil
	self.Settings = nil
	self.Key = nil
	self.Data = nil
	for k, v in ipairs(self.Buttons) do
		Ns:KillWidget(v)
	end
	wipe(self.Buttons)
end

Mixins.scripts.DropList = {}
function Mixins.scripts.DropList.OnHide(self)
	self:Reset()
end

function Mixins.scripts.DropList.OnEnter(self)
	OnEnterFunc(self:GetParent())
end

function Mixins.scripts.DropList.OnLeave(self)
	self:GetParent():GetScript("OnLeave")(self:GetParent())
end

function Mixins.scripts.DropList.OnShow(self)
	self:SetSize(5, 5)
	local widest = 0
	for k, v in ipairs(self.Data) do
		local row = Ns:GetWidget("DropListRow", self, k)
		row:SetChecked(false)
		tinsert(self.Buttons, row)
		local w = row:Init(self, v)
		if w > widest then
			widest = w
		end
		if v.value == self.Settings[self.Key] then
			self:GetParent():SetText(v.text)
			row:SetChecked(true)
		else
			row:SetChecked(false)
		end
	end
	widest = math.max(ceil(widest), ceil(self:GetParent():GetWidth() / 2)) + 4
	local first, last
	local total = #self.Data
	local maxRows = floor((self:GetParent():GetBottom() - SinStatsConfigFrame:GetBottom())/dropListRowHeight)
	local modVal = total > maxRows and maxRows or 1
	local modAnchor = modVal > 1 and "TOPRIGHT" or "BOTTOMLEFT"
	local rows = 1
	for k, v in ipairs(self.Buttons) do
		v:ClearAllPoints()
		v:SetWidth(widest)
		if k == 1 then
			v:SetPoint("TOPLEFT", 2, -2)
			first = v
		elseif modVal > 1 and (k-1) % modVal == 0 then
			v:SetPoint("TOPLEFT", first, modAnchor, 0, 0)
			first = v
			rows = rows + 1
		else
			v:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 0)
		end
		last = v
	end
	local height = modVal > 1 and modVal * dropListRowHeight or total * dropListRowHeight
	self:SetSize((rows * widest) + 2, height + 2)
end

Mixins.functions.DropListRow = {}
function Mixins.functions.DropListRow.Init(self, parent, rowdata)--, id)
	self:SetParent(parent)
	self.Parent = parent
	self.RowData = rowdata
	local t, v = parent.Data[self:GetID()].text, parent.Data[self:GetID()].value
	if parent.Data == ListData.Fonts then
		self.Text:SetFont(Ns.LSM:Fetch("font", v), 15)
	else
		self.Text:SetFont(Ns.ConfigDefaultFont, 15)
	end
	self.Text:SetText(t)
	self:Show()
	return self.Text:GetWidth()
end

Mixins.scripts.DropListRow = {}
function Mixins.scripts.DropListRow.OnClick(self)
	PlayOnCheck()
	self:GetParent().Settings[self:GetParent().Key] = self.RowData.value
	self:GetParent():GetParent():SetText(self.RowData.text)
	self:GetParent():Hide() -- hide the list
	if self.Parent:GetParent():GetParent().RunAction then -- Used by Profiles List
		self.Parent:GetParent():GetParent():RunAction("select")
		return
	end
	Ns:InitialiseProfile(Ns.Profile)
end

function Mixins.scripts.DropListRow.OnEnter(self)
	OnEnterFunc(self:GetParent():GetParent())
end

function Mixins.scripts.DropListRow.OnLeave(self)
	local leaveParent = self:GetParent():GetParent()
	leaveParent:GetScript("OnLeave")(leaveParent)
end

------------------------------------------
--			Main Menu Button			--
------------------------------------------
function W.MainMenuButton(parent, width)
	local f = CreateFrame("Button", nil, parent)
	f.SpecialType = "MainMenuButton"
	f.NoResize = true
	Mixin(f, Mixins.functions.MainMenuButton)
	AddLabel(f)
	f:AnchorLabel("LEFT", 5, 0, true)
	f:SetJustifyH("LEFT")
	f:SetNormalTexture(Ns.TexturePath.."HighlightMenu")
	f:GetNormalTexture():SetAlpha(0) -- alpha changed only ; texture already green
	f:SetHighlightTexture(Ns.TexturePath.."HighlightMenu")
	f.Collapsed = true
	f:SetSize(width, MainMenuButtonHeight)
	for k, v in pairs(Mixins.scripts.MainMenuButton) do
		f:SetScript(k, v)
	end
	return f
end

Mixins.functions.MainMenuButton = {}
function Mixins.functions.MainMenuButton.Collapse(self)
	if self.Collapsed then
		return
	end
	self.Collapsed = true
	self:GetNormalTexture():SetAlpha(0)
	local configFrame = self:GetParent()
	if configFrame.MainMenuSelected.Anchor then
		Ns:KillWidget(configFrame.MainMenuSelected.Anchor)
		configFrame.MainMenuSelected.Anchor = nil
	end
	configFrame.MainMenuSelected = nil
end

function Mixins.functions.MainMenuButton.Expand(self)
	if not self.Collapsed then
		return
	end
	self.Collapsed = false
	self:GetNormalTexture():SetAlpha(0.5)
	local configFrame = self:GetParent()
	configFrame.MainMenuSelected = self
	if not self.DisplayFunc then
		print("|cffff0000SinStats: No display function supplied for Main Menu item:", self.MyInformation.stat.."!")
		return
	end
	Ns.ConfigFrame.MainAnchor = Ns:GetWidget("AnchorFrame", configFrame)
	Ns.ConfigFrame.MainAnchor:SetLabel(format(Ns.WidgetDisplayFormat, Ns:GetSpellIcon(self.MyInformation), (L[self.MyInformation.stat])))
	Ns.ConfigFrame.MainAnchor:SetFontSize(20)
	Ns.ConfigFrame.MainAnchor:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	Ns.ConfigFrame.MainAnchor.Description:SetText(L[self.MyInformation.stat.."Description"])
	Ns.ConfigFrame.MainAnchor.CenterAlign = self.MyInformation.centeralign
	self.DisplayFunc(self, Ns.ConfigFrame.MainAnchor, Ns.TopAnchor, true)
	Ns.ConfigFrame.MainAnchor:Show()
end

Mixins.scripts.MainMenuButton = {}
function Mixins.scripts.MainMenuButton.OnClick(self)
	PlayOnTab()
	configFrame = self:GetParent()
	if  configFrame.MainMenuSelected and configFrame.MainMenuSelected == self then
		return
	end
	if  configFrame.MainMenuSelected and configFrame.MainMenuSelected ~= self then
		KillPage("MainAnchor")
		KillPage("ChildAnchor")
		configFrame.MainMenuSelected:Collapse()
	end
	if self.Collapsed then
		self:Expand()
	else
		self:Collapse()
	end
end

--------------------------------------
--			Minimap Button			--
--------------------------------------
function W.MinimapButton(parent) -- All the funcions to do Profiles
	local f = Ns:GetWidget("CheckBox")
	f.SpecialType = "MinimapButton"
	Mixin(f, Mixins.functions.MinimapButton)
	return f
end

Mixins.functions.MinimapButton = {}
function Mixins.functions.MinimapButton.Init(self, anchorframe, parent)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.Check.Settings = parent.SvTable[self.MyInformation.stat]
	self.Check.Key = "Show"
	self.Check:SetChecked(self.Check.Settings[self.Check.Key])
	self:SetLabel(GetLabelText(self.MyInformation.stat, self.MyInformation, true))
	self:SetWidth(self.Check:GetWidth() + self.Label:GetWidth() + 35)
	AdjustCheckTip(self, self.MyInformation.stat)
end

----------------------------------
--			Plain Button		--
----------------------------------
function W.PlainButton(parent, width)
	local f = CreateFrame("Button", nil, parent)
	f:SetSize(50, 25)
	f.SpecialType = "PlainButton"
	Mixin(f, Mixins.functions.PlainButton)
	AddLabel(f)
	f:AnchorLabel("CENTER")
	f:SetNormalTexture(Ns.TexturePath.."ButtonNormal")
	f:SetPushedTexture(Ns.TexturePath.."ButtonPushed")
	f:SetHighlightTexture(Ns.TexturePath.."Highlight")
	f:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.8)
	f:GetPushedTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.8)
	f:GetHighlightTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.2)
	for k, v in pairs(Mixins.scripts.PlainButton) do
		f:SetScript(k, v)
	end
	return f
end

Mixins.functions.PlainButton = {}
function Mixins.functions.PlainButton.Init(self, anchorframe, parent)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.Settings = parent.MyInformation.svnotintable and parent.SvTable or parent.SvTable[parent.MyInformation.stat]
	self.Key = self.MyInformation.stat
	self:SetLabel(GetLabelText(self.MyInformation.stat, self.MyInformation, true))
	self:SetWidth(self.Label:GetWidth() + 30)
end

function Mixins.functions.PlainButton.Reset(self)
	self.MyInformation = nil
	self:SetLabel("")
	self:SetWidth(10)
end

Mixins.scripts.PlainButton = {}
function Mixins.scripts.PlainButton.OnClick(self)
	self.Settings[self.Key] = true
	Ns:InitialiseProfile(Ns.Profile)
	StaticPopup_Show("SINSTATS_RESET")
end

----------------------------------
--			Profiles			--
----------------------------------
local CurrentProfileFormat = "%s: %s"

local function FindInProfilekys(find)
	for k, v in pairs(SinStatsDB.profileKeys) do
		if v == find then
			return true
		end
	end
end

local function ProfileDisableAll(self) -- To Mixin or not to Mixin, that is.....
	self.Selected:SetEnabled(false)
	self.Delete:SetEnabled(false)
	self.Copy:SetEnabled(false)
	self.Create:SetEnabled(false)
	self.Cancel:Hide()
	self.ConfirmDelete:Hide()
	self.Delete:Show()
	self.Selected:Show()
	self.CopyIcon:Hide()
end

local function ResetProfileConfig(self)
	wipe(self.CurrentProfile)
	self.CurrentProfile[Ns.ProfileKey] = SinStatsDB.profileKeys[Ns.ProfileKey]
	self.SvTable = self.CurrentProfile
	self.Key = Ns.ProfileKey
	self.ProfileList:Init(self, self)
	self.ProfileList.Tip:Hide()
	self:RunAction("select")
end

Mixins.scripts.ProfileConfigButton = {}
function Mixins.scripts.ProfileConfigButton.OnClick(self)
	PlayOnTab()
	self:GetParent():RunAction(self.Action)
end

function Mixins.scripts.ProfileConfigButton.OnEnable(self)
	self:SetAlpha(1)
	self:GetNormalTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.8)
	self:GetPushedTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.8)
end

function Mixins.scripts.ProfileConfigButton.OnDisable(self)
	self:SetAlpha(0.5)
	self:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b)
	self:GetPushedTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b)

end

local function CreateProfileButton(self, label, action)
	local f = CreateFrame("Button", nil, self, "TruncatedButtonTemplate")
	f:SetSize(80, 26)
	f.Text = f:CreateFontString()
	f.Text:SetPoint("CENTER")
	f.Text:SetFont(Ns.ConfigDefaultFont, 12)
	f.Text:SetJustifyH("CENTER")
	f:SetNormalTexture(Ns.TexturePath.."ButtonNormal")
	f:SetPushedTexture(Ns.TexturePath.."ButtonPushed")
	f:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.8)--(0.784, 0.850, 0.941)--(1, 0.737, 0, 0.8)
	f:GetPushedTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.8)--(1, 0.737, 0, 0.8)
	f:SetHighlightTexture(Ns.TexturePath.."Highlight")
	local h = f:GetHighlightTexture()
	h:SetVertexColor(1, 1, 1, 1)
	f.Text:SetText(label)
	f.Action = action
	for k, v in pairs(Mixins.scripts.ProfileConfigButton) do
		f:SetScript(k, v)
	end
	return f
end

function W.ProfileConfig(parent) -- All the funcions to do Profiles
	local f = CreateFrame("Frame", "$parentProfiles", parent )
	f.SpecialType = "ProfileConfig"
	f:SetSize(400, 100)
	Mixin(f, Mixins.functions.ProfileConfig)
	ListData.Deafults = {} -- grab the default class profiles and format them for a doplist in case of a "Reset From Default"
	for k, v in pairs(Ns:GetClassDefaults()) do
		tinsert(ListData.Deafults, { text=k, value=v, })
	end
	sort(ListData.Deafults, function(a, b)
		return a.text < b.text
	end)

	f.Instruction = f:CreateFontString()
	f.Instruction:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Instruction:SetPoint("TOPLEFT", 0, 0)
	f.Instruction:SetJustifyH("LEFT")
	f.Instruction:SetText(L["SelectProfile"])

	f.CurrentProfileText = f:CreateFontString()
	f.CurrentProfileText:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -2)
	f.CurrentProfileText:SetTextColor(greenColor.r, greenColor.g, greenColor.b)
	f.CurrentProfileText:SetPoint("CENTER", 0, -15)
	f.CurrentProfileText:SetJustifyH("CENTER")

	f.Selected = CreateProfileButton(f, L["Selected"], "selected") -- apply delete buttons
	f.Selected:SetPoint("CENTER", 50, -67)

	f.Cancel = CreateProfileButton(f, L["Cancel"], "cancel")
	f.Cancel:SetPoint("CENTER", f.Selected)
	f.Cancel:GetNormalTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.8)
	f.Cancel:GetPushedTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.8)

	f.Delete = CreateProfileButton(f, L["Delete"], "delete")
	f.Delete:SetPoint("LEFT", f.Selected, "RIGHT", 15, 0)
	f.Delete:GetNormalTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.9)
	f.Delete:GetPushedTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.9)

	f.ConfirmDelete = CreateProfileButton(f, L["ConfirmDelete"], "confirmdelete")
	f.ConfirmDelete:SetPoint("CENTER", f.Delete)
	f.ConfirmDelete:GetNormalTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.9)
	f.ConfirmDelete:GetPushedTexture():SetVertexColor(redColor.r, redColor.g, redColor.b, 0.9)

	f.ProfileText = f:CreateFontString()
	f.ProfileText:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -5) -- "Profiles" TEXT
	f.ProfileText:SetPoint("LEFT", 0, -49)
	f.ProfileText:SetJustifyH("CENTER")
	f.ProfileText:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	f.ProfileText:SetText(L["ProfileSelected"])

	function f.RunAction(self, action) -- The magic happens here.
		ProfileDisableAll(self)
		local newProfile = strtrim(self.Edit:GetText())
		if self.SvTable[self.Key] ~= SinStatsDB.profileKeys[Ns.ProfileKey] then
			self.Selected:SetEnabled(true)
		end
		if action == "selected" then
			SinStatsDB.profileKeys[Ns.ProfileKey] = self.CurrentProfile[self.Key]
			Ns.Profile = SinStatsDB.profiles[SinStatsDB.profileKeys[Ns.ProfileKey]]
			Ns.NewSettings(Ns.Profile, Ns.Class)
			self.CurrentProfileText:SetText(format(CurrentProfileFormat, L["CurrentProfile"], SinStatsDB.profileKeys[Ns.ProfileKey]))
			ResetProfileConfig(self)
			Ns:UpdateProfile()
			for k, v in pairs(self:GetParent().PageAnchor.CurrentWidgets) do
				v.SvTable = v.Parent.SvTable
			end 
			Ns:InitialiseProfile(Ns.Profile)
		end
		if action == "select" then
			if FindInProfilekys(self.SvTable[self.Key]) then
				if newProfile ~= "" and not FindInProfilekys(newProfile) then
					self.Copy:SetEnabled(true)
					self.CopyIcon:Show()
				end
			else
				self.Delete:SetEnabled(true)
			end
		end
		if action == "edit" then
			if newProfile ~= "" and not FindInProfilekys(newProfile) then
				self.Copy:SetEnabled(true)
				self.CopyIcon:Show()
			end
		end
		if action == "copy" then
			self.Create:SetEnabled(true)
		end
		if action == "create" then
			SinStatsDB.profiles[newProfile] = {}
			Ns.CopyTable(SinStatsDB.profiles[self.SvTable[self.Key]], SinStatsDB.profiles[newProfile])
			UpdateProfiles()
			self.Edit:SetText("")
		end
		if action == "delete" then
			self.Delete:SetEnabled(true)
			self.Selected:SetEnabled(true)
			self.Delete:Hide()
			self.Selected:Hide()

			self.ConfirmDelete:Show()
			self.Cancel:Show()
		end
		if action == "confirmdelete" then
			SinStatsDB.profiles[self.CurrentProfile[self.Key]] = nil
			UpdateProfiles()
			ResetProfileConfig(self)
		end
		if action == "cancel" then
			ProfileDisableAll(self)
			ResetProfileConfig(self)
		end
	end

	f.createOs = -55
	f.manageOs = -20
	--f.Edit = W.BaseEditBox(f, 200, 27)
	f.Edit = W.BaseEditBox(f, 200, 22)
	f.Edit:SetPoint("LEFT", 0, -120)
	f.Edit.Action = "edit"
	f.Edit:SetScript("OnTextChanged", function(self)
		self:GetParent():RunAction(self.Action)
	end)

	f.CopyIcon = f:CreateTexture()
	f.CopyIcon:SetSize(18, 15)
	f.CopyIcon:SetTexture(Ns.TexturePath.."ProfileCopy")
	f.CopyIcon:SetPoint("LEFT", 95, -92)
	f.CopyIcon:SetVertexColor(greenColor.r, greenColor.g, greenColor.b)

	f.Copy = CreateProfileButton(f, L["Copy"], "copy")
	f.Copy:SetPoint("CENTER", f.Selected, "CENTER", 0, -53) -- APPLY BUTTON SECOND ROW

	f.Create = CreateProfileButton(f, L["Create"], "create")
	f.Create:SetPoint("LEFT", f.Copy, "RIGHT", 15, 0)
	f.NewProfileText = f:CreateFontString()
	f.NewProfileText:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -5)
	f.NewProfileText:SetPoint("TOPLEFT", f.Edit, "TOPLEFT", 0, 14) -- NEW PROFILE TEXT
	--f.NewProfileText:SetPoint("TOPLEFT", f.Edit, "TOPLEFT", 0, 11) -- NEW PROFILE TEXT
	f.NewProfileText:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	f.NewProfileText:SetJustifyH("CENTER")
	f.NewProfileText:SetText(L["NewProfile"])

	f.CurrentProfile = {}

	return f
end

Mixins.functions.ProfileConfig = {}
function Mixins.functions.ProfileConfig.Init(self, anchorframe, parent, displaylist)
	UpdateProfiles()
	self.Anchoreframe = anchorframe
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.DisplayOrder = parent.DisplayOrder
	self.Edit:SetText("")
	self.CurrentProfile[Ns.ProfileKey] = SinStatsDB.profileKeys[Ns.ProfileKey]
	self.SvTable = self.CurrentProfile
	self.Key = Ns.ProfileKey
	self.CurrentProfileText:SetText(format(CurrentProfileFormat, L["CurrentProfile"], SinStatsDB.profileKeys[Ns.ProfileKey]))
	self.ProfileList = Ns:GetWidget("DropList", self, self:GetID()) -- 4 = entry in Ns.SettingsGroupOrder table
	self.ProfileList:SetParent(self)
	self.ProfileList:ClearAllPoints()
	self.ProfileList:SetPoint("LEFT", 0, -67) -- PROFILE DROPLIST
	self.ProfileList:Init(self, self)
	self.ProfileList.Tip:Hide()
	self.ProfileList:Show()

	self:RunAction("select")
end

function Mixins.functions.ProfileConfig.Reset(self)
	Ns:KillWidget(self.ProfileList)
	self.ProfileList = nil
end

------------------------------
--			Sliders			--
------------------------------
function W.Slider(parent)
	local f = CreateFrame("Slider", nil, f, BackdropTemplateMixin and "BackdropTemplate")
	f.SpecialType = "Slider"
	f:SetSize(100, 12)
	f:SetBackdrop(SliderBG)
	--f:SetBackdropColor(0.20392, 0.20392, 0.20392, 0.3)
	f:SetBackdropColor(0.27451, 0.27451, 0.27451, 0.3)
	f:SetBackdropBorderColor(0.184, 0.184, 0.184, 0.3)
	AddTipText(f)
	f:SetValueStep(1)
	f:SetObeyStepOnDrag(true)
	f:SetOrientation("HORIZONTAL")
	f:SetFrameLevel(4)
	f:SetThumbTexture(Ns.TexturePath.."SliderThumb")
	f:GetThumbTexture():SetSize(22, 14)
	f:GetThumbTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.9)--(0.784, 0.850, 0.941)--(1, 0.737, 0, 0.9)
	f:GetThumbTexture():SetBlendMode("ADD")
	f.Min = f:CreateFontString()
	f.Min:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 5)
	f.Min:SetPoint("LEFT", 3, 0)
	f.Min:SetJustifyH("LEFT")
	f.Min:SetJustifyV("BOTTOM")
	f.Max = f:CreateFontString()
	f.Max:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 5)
	f.Max:SetPoint("RIGHT", -3, 0)
	f.Max:SetJustifyH("RIGHT")
	f.Max:SetJustifyV("BOTTOM")
--[[
	f.Value = f:CreateFontString()
	f.Value:SetFont(Ns.ConfigDefaultFont, 14)
	f.Value:SetPoint("CENTER", 0, 0)
	f.Value:SetTextColor(greenColor.r, greenColor.g, greenColor.b)
	f.Value:SetJustifyH("CENTER")
	f.Value:SetJustifyV("CENTER")
]]--
	f.Edit = W.BaseEditBox(f, 50, 12)
	f.Edit:SetPoint("TOP", f, "BOTTOM", 0, 1)
	CreateBorder(f.Edit, 0)
	-- f.Edit = W.BaseEditBox(f, 46, 17)
	-- f.Edit:SetPoint("TOP", f, "BOTTOM", 0, 2)
	f.Edit:SetFont(Ns.ConfigDefaultFont, 12, "")
	f.Edit:SetTextColor(greenColor.r, greenColor.g, greenColor.b)
	f.Edit:SetJustifyH("CENTER")
	Mixin(f.Edit, Mixins.functions.SliderEdit)
	for k, v in pairs(Mixins.scripts.SliderEdit) do
		f.Edit:SetScript(k, v)
	end
--	f.Edit.Action = "edit"
--	f.Edit:SetScript("OnTextChanged", function(self)
--		self:GetParent():RunAction(self.Action)
--	end)


	Mixin(f, Mixins.functions.Slider)
	for k, v in pairs(Mixins.scripts.Slider) do
		f:SetScript(k, v)
	end
	return f
end

Mixins.functions.SliderEdit = {}
function Mixins.functions.SliderEdit.GetValue(self)
	return self:GetNumber()
end

function Mixins.functions.SliderEdit.SetValue(self, value)
	local n = format("%.1f", value)
	self:SetText(n)
end


Mixins.scripts.SliderEdit = {}
function Mixins.scripts.SliderEdit.OnEnterPressed(self)
	local value = self:GetValue()
	local min, max = self:GetParent():GetMinMaxValues()
	if value < min then
		value = min
	end
	if value > max then
		value = max
	end
	self:SetValue(value)
	self:GetParent():SetValue(value)
	self:ClearFocus()
end

Mixins.functions.Slider = {}
--local minMaxFormat = "- %s -"
function Mixins.functions.Slider.Init(self, anchorframe, parent, displaylist, orderlist)
	self:SetEnabled(true)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.Settings = parent.MyInformation.svnotintable and parent.SvTable or parent.SvTable[parent.MyInformation.stat]
	self.Key = self.MyInformation.stat
	self.Key = self.Key
	self:SetWidth(self.MyInformation.widget.width)
	local min, max, value = self.MyInformation.widget.min, self.MyInformation.widget.max, self.Settings[self.Key]
	self.Min:SetText(type(min) == "string" and L[min] or min)
	self.Max:SetText(type(max) == "string" and L[max] or max)
	self:SetMinMaxValues(min, max)
	local step = self.MyInformation.widget.valuestep
	if step then self:SetValueStep(step) end
	self:SetValue(value)
	self.Tip:SetText(format(TipFormat, L[self.Key.."Tip"]))
	self.Tip:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	self.Edit:SetValue(value)
end

Mixins.scripts.Slider = {}
function Mixins.scripts.Slider.OnValueChanged(self, value)
    if self.Settings[self.Key] == value then return end
    	self.Edit:SetValue(value)
	self.Settings[self.Key] = value
	Ns:InitialiseProfile(Ns.Profile)
end
function Mixins.scripts.Slider.OnDisable(self)
	self:SetAlpha(0.5)
end

function Mixins.scripts.Slider.OnEnable(self)
	self:SetAlpha(1)
end

------------------------------
--			ToolTip			--
------------------------------
function W.Tooltip(parent)
	if not gttFont then
		gttFont, gttFontSize, gttFontFlags = GameTooltipHeaderText:GetFont()
	end
	local f = CreateFrame("Frame")
	f.SpecialType = "Tooltip"
	f:SetSize(12, 12)
	f.Texture = f:CreateTexture()
	f.Texture:SetAllPoints()
	f.Texture:SetTexture(Ns.TexturePath.."Misc")
	Mixin(f, Mixins.functions.Tooltip)
	for k, v in pairs(Mixins.scripts.Tooltip) do
		f:SetScript(k, v)
	end
	return f
end
Mixins.functions.Tooltip = {}
function Mixins.functions.Tooltip.Init(self, parent, settings)
	self:SetParent(parent)
	self:Show()
	self:SetFrameStrata(parent:GetFrameStrata())
	self:SetFrameLevel(parent:GetFrameLevel() + 1)
	self:ClearAllPoints()
	local points = TooltipOffsets[parent.SpecialType] or TooltipOffsets.Default
	self:SetPoint(points.point, parent, points.topoint, points.x, points.y)
	self.Tip = settings.stat.."Tooltip"
end

function Mixins.functions.Tooltip.Reset(self)
	self.Tip = nil
	self:Hide()
end

Mixins.scripts.Tooltip = {}
function Mixins.scripts.Tooltip.OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltipHeaderText:SetFont(Ns.ConfigDefaultFont, 13, "")
	GameTooltip:SetText(L[self.Tip])
end
function Mixins.scripts.Tooltip.OnLeave(self)
	GameTooltipHeaderText:SetFont(gttFont, gttFontSize, gttFontFlags)
	GameTooltip:Hide()
end

----------------------------------
--			Top Tabs			--
----------------------------------
function W.TopTab(parent, width)
	local f = CreateFrame("Button", nil, parent)
	f:SetSize(50, topTabHeight)
	f.SpecialType = "TopTab"
	Mixin(f, Mixins.functions.TopTab)
	AddLabel(f)
	f:AnchorLabel("CENTER")
	hooksecurefunc(f, "SetLabel", AdjustTopTabText)
	f.Properties = {}
	f:SetNormalTexture(Ns.TexturePath.."LabelBG")
	f:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.2)
	f:SetHighlightTexture(Ns.TexturePath.."LabelBGLine")
	f:GetHighlightTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 1)
	for k, v in pairs(Mixins.scripts.TopTab) do
		f:SetScript(k, v)
	end

	f.Status = Ns:GetWidget("CheckButton", f) -- TOP TAB CHECKBOX
	f.Status:SetSize(11, 11)
	f.Status:SetPoint("RIGHT", -3, 1)
	f.Status:SetFrameLevel(f:GetFrameLevel() + 4)
	f.Status:SetHighlightTexture(Ns.TexturePath.."LabelBGLine")
	f.Status:GetHighlightTexture():ClearAllPoints()
	f.Status:GetHighlightTexture():SetAllPoints(f:GetHighlightTexture())
	f.Status:GetHighlightTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 1)
	return f
end

Mixins.functions.TopTab = {}
function Mixins.functions.TopTab.Init(self, anchorframe, parent, noicons)
	self.AnchorFrame = anchorframe
	self.Parent = parent
	self.MyInformation = parent.DisplayOrder[self:GetID()]
--	self.GroupOrder = nil
	self.DisplayOrder = parent.NextDisplayOrder
	self.SvTable = parent.SvTable
	self.Key = self.MyInformation.stat.."Menu"
	if self.ActiveOnInit then
		self:Click()
		self.ActiveOnInit = nil
	else
		--self:GetNormalTexture():SetAlpha(0.3)
		self:SetNormalTexture(Ns.TexturePath.."LabelBG")
		self:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.2)
		self.Properties.Checked = false
	end
	self:SetLabel(GetLabelText(self.Key, self.MyInformation, noicons))
	if type(self.SvTable[self.MyInformation.stat]) == "table" then --[self.MyInformation.stat].Show then
		self.Status.MyInformation = parent.DisplayOrder[self:GetID()]
		self.Status.Settings = self.SvTable[self.MyInformation.stat]
		self.Status.Key = "Show"
		self.Status:SetChecked(self.Status.Settings[self.Status.Key])
		self.Status:Show()
		self:AnchorLabel("LEFT", 6, 0, true)
	else
		if self.MyInformation.enabled and self.MyInformation.enabledval then
			if Ns.Profile[self.MyInformation.enabled] ~= self.MyInformation.enabledval then
				self:SetEnabled(false)
			end
		end
		self:AnchorLabel("CENTER")
		self.Status:Hide()
	end
end

function Mixins.functions.TopTab.Reset(self)
	wipe(self.Properties)
	self.Status:Reset()
end

Mixins.scripts.TopTab = {}
function Mixins.scripts.TopTab.OnClick(self)
	--PlayOnTab()
	local parent = self:GetParent()
	if parent.ActiveWidget and parent.ActiveWidget == self then
		return
	end
	self.Properties.Checked = not self.Properties.Checked
	if self.Properties.Checked then
		--self:GetNormalTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 0.3)
		self:SetNormalTexture(Ns.TexturePath.."LabelBGLine")
		self:GetNormalTexture():SetVertexColor(greenColor.r, greenColor.g, greenColor.b, 1)
		--self:GetNormalTexture():SetAlpha(1)
	else
		--self:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.3)
		self:SetNormalTexture(Ns.TexturePath.."LabelBG")
		self:GetNormalTexture():SetVertexColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.2)
	end
	KillPage("ChildAnchor")
	if self.Properties.Checked then
		self.AnchorFrame:SetActive(self)
		Ns.ConfigFrame.ChildAnchor = Ns:GetWidget("AnchorFrame", configFrame)
		Ns.ConfigFrame.ChildAnchor:SetLabel("")
		Ns.ConfigFrame.ChildAnchor.Description:SetText(format(Ns.WidgetDisplayFormat, Ns:GetSpellIcon(self.MyInformation), L[self.MyInformation.stat.."Menu"])) -- .."Description" STATS TOP LINE TEXT
		Ns.ConfigFrame.ChildAnchor.Description:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
		Ns.ConfigFrame.ChildAnchor.CenterAlign = self.MyInformation.centeralign
		self.Parent.DisplayFunc(self, Ns.ConfigFrame.ChildAnchor, self.AnchorFrame, false, true)
		for k, v in pairs(Ns.ConfigFrame.ChildAnchor.CurrentWidgets) do
			if v.Check and v.Check.Key == "Show" then
				v.Check.ParentLink = self.Status
				self.Status.ChildLink = v.Check
			end
		end
		Ns.ConfigFrame.ChildAnchor:Show()
	end
end

function Mixins.scripts.TopTab.OnDisable(self)
	self:SetAlpha(0.5)
end

function Mixins.scripts.TopTab.OnEnable(self)
	self:SetAlpha(1)
end

------------------------------------------
--			Get/Kill Widgets			--
------------------------------------------
function Ns:GetWidget(widgettype, parent, id)
	local widget
	if WidgetPool[widgettype] and #WidgetPool[widgettype] > 0 then
		widget = WidgetPool[widgettype][1]
		tremove(WidgetPool[widgettype], 1)
	end
	if not widget then
		widget = W[widgettype](parent, id)
	end
	if type(id) == "number" then
		widget:SetID(id)
	end
	return widget
end

function Ns:KillWidget(widget)
	widget:Hide()
	local widgettype = widget.SpecialType or widget:GetObjectType()
	if not WidgetPool[widgettype] then
		WidgetPool[widgettype] = {}
	end
	tinsert(WidgetPool[widgettype], widget)
	widget:ClearAllPoints()
	widget:SetID(-1)
	if widget.Reset then
		widget:Reset()
	end
	if widget.Tooltip then
		Ns:KillWidget(widget.Tooltip)
		widget.Tooltip = nil
	end
end

----------------------------------
--			Edit Box			--
----------------------------------
--[[
local function EditBox_Init(self)--, data, index)
	local text = self.Data[self.Index]
	if not text then
		text = ""
	end
	self.prevvalue = text
	self:SetText(text)
end
]]--

function W.BaseEditBox(parent, width, height)
	local templates = "InputBoxTemplate"
	if BackdropTemplateMixin then
		templates = templates .. ", BackdropTemplate"
	end
	local f = CreateFrame("EditBox", nil, parent, templates)
	f:SetBackdrop(EditBoxBG)
	f:SetBackdropColor(0.27451, 0.27451, 0.27451, 0.3)
	f:SetBackdropBorderColor(0.184, 0.184, 0.184, 0.3)
	f.Left:Hide()
	f.Right:Hide()
	f.Middle:Hide()
	f:SetFont(Ns.ConfigDefaultFont, 12, "")
	f:SetJustifyH("CENTER")
	if width and height then
		f:SetSize(width, height)
	end
	f:SetMaxLetters(80)
	f:SetAutoFocus(false)
	f:SetScript("OnEscapePressed", function(self)
		if self.prevvalue then
			self:SetText(self.prevvalue)
		else
			self:SetText("")
		end
		self:ClearFocus()
	end)
	return f
end

function W.EditBox(parent)
	local f = W.BaseEditBox(parent)
	f.SpecialType = "EditBox"
	Mixin(f, Mixins.functions.EditBox)
	AddLabel(f)
	for k, v in pairs(Mixins.scripts.EditBox) do
		f:SetScript(k, v)
	end
	return f
end

Mixins.functions.EditBox = {}
function Mixins.functions.EditBox.Init(self, anchorframe, parent, displaylist, orderlist)
	self:SetParent(parent)
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.Settings = parent.MyInformation.svnotintable and parent.SvTable or parent.SvTable[parent.MyInformation.stat]
	self.Key = self.MyInformation.stat
	self:SetSize(self.MyInformation.widget.width, self.MyInformation.widget.height)
	self:AnchorLabel("TOPLEFT", 0, 14, true)
	self:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 5)
	self:SetLabel(GetLabelText(self.MyInformation.stat, self.MyInformation, true))
	self.Label:SetTextColor(orangeColor.r, orangeColor.g, orangeColor.b)
	self:SetValue(self.Settings[self.Key])
end

function Mixins.functions.EditBox.GetValue(self)
	if self.MyInformation.widget.numeric then
		return self:GetNumber()
	else
		return self:GetText()
	end
end

function Mixins.functions.EditBox.SetValue(self, value)
	if self.MyInformation.widget.numeric then
		value = tonumber(value)
		if self.MyInformation.widget.format then
			value = format(self.MyInformation.widget.format, value)
		end
	end
	self:SetText(value)
	self.prevvalue = value
end

Mixins.scripts.EditBox = {}
function Mixins.scripts.EditBox.OnEnterPressed(self)
	local value = self:GetValue()
	self:SetValue(value)
	self.Settings[self.Key] = value
	self:ClearFocus()
	Ns:InitialiseProfile(Ns.Profile)
end

----------------------------------
--			DragStat			--
----------------------------------
local DSWidth, DSHeight, Spacer = 120, 20, 12
local function SetSpacer(self, open)
	local p, r, t, x, y = self:GetPoint(1)
	local ny = open and -Spacer or Spacer
	self:SetPoint(p, r, t, x, y + ny)
	self:GetParent().DragFrame.Moved = open and self or nil
end

function W.DragStat(parent)
	local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	f.SpecialType = "DragStat"
	f:SetSize(DSWidth, DSHeight)
	f:EnableMouse(false)
	f.IdText = f:CreateFontString()
	f.IdText:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 6)
	f.IdText:SetTextColor(greenColor.r, greenColor.g, greenColor.b, 0.8)
	f.IdText:SetPoint("LEFT", 5, 0)
	f.Text = f:CreateFontString()
	f.Text:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize - 4)
	f.Text:SetJustifyH("LEFT")
	f.Text:SetPoint("LEFT", f.IdText, "RIGHT", 5, 0)
	f:SetBackdrop(DragBG)
	f:SetBackdropColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.3)
	f:SetBackdropBorderColor(greenColor.r, greenColor.g, greenColor.b, 0)
	Mixin(f, Mixins.functions.DragStat)
	for k, v in pairs(Mixins.scripts.DragStat) do
		f:SetScript(k, v)
	end

	f.NewColumn = Ns:GetWidget("CheckButton", f)
	f.NewColumn:SetPoint("RIGHT", -3, 0)
	f.NewColumn:SetSize(12,12)
--	f.NewColumn:SetNormalTexture(Ns.TexturePath.."DropNormal")
	f.NewColumn:SetCheckedTexture(Ns.TexturePath.."CheckColumn")
	f.NewColumn:GetCheckedTexture():SetVertexColor(1, 1, 1)
--	f.NewColumn:GetCheckedTexture():SetBlendMode("ALPHAKEY")

	return f
end
Mixins.functions.DragStat = {}

function Mixins.functions.DragStat.Init(self, parent, id, shufflefunc)
	self:SetParent(parent)
	self.ID = id
	if not self.LastOrder then
		if self.ID == 1 then
			if self.NewColumn:GetChecked() then
				self.NewColumn:Click()
			end
			self.NewColumn:Hide()
		elseif self.ID > 1 then
			self.NewColumn:Show()
		end
	end
	self.ShuffleFunc = shufflefunc
end

function Mixins.functions.DragStat.GetText(self)
	return self.Text:GetText()
end

function Mixins.functions.DragStat.Reset(self)
	self.ID = nil
	self.IdText:SetText("")
	self.ShuffleFunc = nil
end

function Mixins.functions.DragStat.SetIDText(self, text)
	self.IdText:SetText(text)
end

function Mixins.functions.DragStat.SetText(self, text)
	self.Text:SetText(text)
end

Mixins.scripts.DragStat = {}
function Mixins.scripts.DragStat.OnEnter(self)
	local parent = self:GetParent()
	local moved = parent.DragFrame.Moved
	if moved and not moved:IsMouseOver() then
		SetSpacer(moved)
	end
	self:SetBackdropColor(greenColor.r, greenColor.g, greenColor.b, 0.6)
	if parent.DragFrame and parent.DragFrame:IsShown() then
		for k, v in ipairs(parent.WidgetList) do
			if v:IsMouseOver() and parent.DragFrame.WasOver ~= v then
				if v == parent.DragFrame.Origin then
					parent.DragFrame:SetPoint("LEFT", v)
				elseif v.ID == (parent.DragFrame.Origin.ID + 1) then
					parent.DragFrame:SetPoint("LEFT", parent.DragFrame.Origin)
				else
					parent.DragFrame:SetPoint("LEFT", v, "TOP", 0, 5)
					if not parent.WidgetList[v.ID].FirstOnRow then
						SetSpacer(self, true)
					end
				end
				parent.DragFrame.WasOver = v
				break
			end
		end
	end
end

function Mixins.scripts.DragStat.OnHide(self)
	local parent = self:GetParent()
	if parent.DragFrame and parent.DragFrame.Moved then
		SetSpacer(parent.DragFrame.Moved)
	end
	if self.ID ~= -1 then
		parent.DragFrame.Moved = nil
		parent.DragFrame.Origin = nil
		parent.DragFrame.WasOver = nil
		parent.DragFrame:Hide()
	end
end

function Mixins.scripts.DragStat.OnLeave(self)
	self:SetBackdropColor(topTabColor.r, topTabColor.g, topTabColor.b, 0.3)
end

function Mixins.scripts.DragStat.OnMouseDown(self)
	if self.LastOrder then
		return
	end
	local parent = self:GetParent()
	if parent.DragFrame then
		parent.DragFrame.Origin = self
		parent.DragFrame.WasOver = self
		parent.DragFrame:SetText(self:GetText())
		parent.DragFrame:SetSize(self:GetSize())
		parent.DragFrame:SetPoint("LEFT", self)
		parent.DragFrame:Show()
	end
end

function Mixins.scripts.DragStat.OnMouseUp(self)
	local parent = self:GetParent()
	if parent.DragFrame then
		parent.DragFrame:Hide()
	end
	if self.ShuffleFunc then
		self.ShuffleFunc(self)
	end
	if parent.DragFrame.Moved then
		SetSpacer(self:GetParent().DragFrame.Moved)
	end
	parent.DragFrame.Origin = nil
	parent.DragFrame.WasOver = nil
end

--------------------------------------
--			Display Order			--
--------------------------------------
local function NewColumnOnClick(self)
	self:GetParent():GetParent().Save:SetEnabled(true)
end

local function NewColumnOnEnter(self)
	self:GetParent():GetScript("OnEnter")(self:GetParent())
end

local function NewColumnOnLeave(self)
	if not self:GetParent():IsMouseOver() then
		self:GetParent():GetScript("OnLeave")(self:GetParent())
	end
end

local function ShuffleList(self)
	local parent = self:GetParent()
	if not parent:IsShown() then
		return
	end
	if parent.DragFrame.Origin == parent.DragFrame.WasOver then
		return
	end
	parent.Save:SetEnabled(true)
	local MoveStatId = parent.DragFrame.Origin.ID
	local InsertStat = parent.DragFrame.WasOver.ID
	if MoveStatId < InsertStat then
		InsertStat = InsertStat - 1
	end
	local MoveStat = parent.StatList[MoveStatId]
	tremove(parent.StatList, MoveStatId)
	tinsert(parent.StatList, InsertStat, MoveStat)
	for k, v in ipairs(parent.StatList) do
		parent.WidgetList[k]:SetText(L[v.stat])--(Ns.Profile.StatTextAbreviate and L[v.stat.."Abrev"] or L[v.stat])
		parent.WidgetList[k].NewColumn:SetChecked(Ns.Profile.NewColumns and Ns.Profile.NewColumns[v.stat] or false)
	end
end

local MaxPerColumn = 14
function W.DisplayOrderConfig(parent)
	local f = CreateFrame("Frame", "$parentOrder", parent)
	f.SpecialType = "DisplayOrderConfig"
	f:SetSize(400, 150)
	f.WidgetList = {}
	Mixin(f, Mixins.functions.DisplayOrderConfig)
	f.Save = CreateProfileButton(f, L["Selected"])
	f.Save:SetSize(65,20)
	f.Save:SetPoint("TOPLEFT", 120, 45)
	f.Save:SetEnabled(false)
	f.Save.Action = "Save"

	f.ClearAllColumns = CreateProfileButton(f, L["ClearAllColumns"])
	f.ClearAllColumns:SetPoint("LEFT", f.Save, "RIGHT", 20, 0)
	f.ClearAllColumns:SetSize(65,20)
	f.ClearAllColumns.Action = "ClearAllColumns"
	f.ClearAllColumns.Tooltip = Ns:GetWidget("Tooltip", f.ClearAllColumns)

	-- Rows Presets
	f.Rows = f:CreateFontString()
	f.Rows:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Rows:SetText(L["Rows"])
	f.Rows:SetPoint("LEFT", f.ClearAllColumns, "RIGHT", 30, 0)

	f.OneRow = CreateProfileButton(f, L["OneRow"])
	f.OneRow:SetSize(17,22)
	f.OneRow:SetPoint("LEFT", f.Rows, "RIGHT", 3, 0)
	f.OneRow.Action = 1
	f.TwoRows = CreateProfileButton(f, L["TwoRows"])
	f.TwoRows:SetSize(17,22)
	f.TwoRows:SetPoint("LEFT", f.OneRow, "RIGHT", 3, 0)
	f.TwoRows.Action = 2
	f.ThreeRows = CreateProfileButton(f, L["ThreeRows"])
	f.ThreeRows:SetSize(17,22)
	f.ThreeRows:SetPoint("LEFT", f.TwoRows, "RIGHT", 2, 0)
	f.ThreeRows.Action = 3
	f.FourRows = CreateProfileButton(f, L["FourRows"])
	f.FourRows:SetSize(17,22)
	f.FourRows:SetPoint("LEFT", f.ThreeRows, "RIGHT", 2, 0)
	f.FourRows.Action = 4

	-- Columns Presets
	f.Columns = f:CreateFontString()
	f.Columns:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Columns:SetText(L["Columns"])
	f.Columns:SetPoint("LEFT", f.FourRows, "RIGHT", 30, 0)

	f.OneCol = CreateProfileButton(f, L["OneRow"])
	f.OneCol:SetSize(17,22)
	f.OneCol:SetPoint("LEFT", f.Columns, "RIGHT", 3, 0)
	f.OneCol.Action = 6
	f.TwoCol = CreateProfileButton(f, L["TwoRows"])
	f.TwoCol:SetSize(17,22)
	f.TwoCol:SetPoint("LEFT", f.OneCol, "RIGHT", 3, 0)
	f.TwoCol.Action = 7
	f.ThreeCol = CreateProfileButton(f, L["ThreeRows"])
	f.ThreeCol:SetSize(17,22)
	f.ThreeCol:SetPoint("LEFT", f.TwoCol, "RIGHT", 2, 0)
	f.ThreeCol.Action = 8
	f.FourCol = CreateProfileButton(f, L["FourRows"])
	f.FourCol:SetSize(17,22)
	f.FourCol:SetPoint("LEFT", f.ThreeCol, "RIGHT", 2, 0)
	f.FourCol.Action = 9

	f.DragFrame = Ns:GetWidget("DragStat", f, 1)
	f.DragFrame.NewColumn:Hide()
	f.DragFrame:Hide()
	f.DragFrame:Init(f, -1)
	f.DragFrame:EnableMouse(false)
	f.DragFrame:SetScript("OnEnter", nil)
	f.DragFrame:SetScript("OnLeave", nil)
	f.DragFrame:SetIDText("<")
	f.DragFrame:SetBackdropColor(0, 0, 0)
	f.DragFrame.Text:SetTextColor(greenColor.r, greenColor.g, greenColor.b)
	f.DragFrame:SetFrameStrata(parent:GetFrameStrata())
	f.DragFrame:SetFrameLevel(parent:GetFrameLevel() + 100)

	f.LastOrder = Ns:GetWidget("DragStat", f, 1)
	f.LastOrder.NewColumn:Hide()
	f.LastOrder:SetBackdrop({ bgFile="", edgeFile="", })
	f.LastOrder.LastOrder = true

	return f
end

Mixins.functions.DisplayOrderConfig = {}
function Mixins.functions.DisplayOrderConfig.Init(self, anchorframe, parent)
	self.Anchoreframe = anchorframe
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.DisplayOrder = parent.DisplayOrder
	self.SvTable = Ns.Profile
	if not self.StatList then
		self.StatList = {}
	end
	self.ClearAllColumns.Tooltip:Init(self.ClearAllColumns, self.MyInformation)
	self.ClearAllColumns.Tooltip:ClearAllPoints()
	self.ClearAllColumns.Tooltip:SetPoint("LEFT", self.ClearAllColumns, "RIGHT", -197, 0)
	wipe(self.StatList)
	local added, removed = Ns:FillDisplayOrder(self.StatList, self.SvTable, true)
	if added or removed then
		self.Save:SetEnabled(true)
	end
	local firstOnRow, last
	for k, v in ipairs(self.StatList) do
		local f = Ns:GetWidget("DragStat", self, k)
		tinsert(self.WidgetList, f)

		f.NewColumn.Settings = f.NewColumn -- dummy Settings, we'll get the actual checked value during Apply
		f.NewColumn.Key = "newcolumn" -- dummy Key
		f.NewColumn.DelayInit = true
		f.NewColumn:HookScript("OnClick", NewColumnOnClick)
		f.NewColumn:HookScript("OnEnter", NewColumnOnEnter)
		f.NewColumn:HookScript("OnLeave", NewColumnOnLeave)
		if Ns.Profile.NewColumns then
			f.NewColumn:SetChecked(Ns.Profile.NewColumns[v.stat]) -- set direct from SV settings
		end
		f:ClearAllPoints()
		if k == 1 then
			f:SetPoint("TOPLEFT", self, 0, 10)
			firstOnRow = f
			f.FirstOnRow = true
			f.NewColumn:Hide()
		elseif (k-1) % MaxPerColumn == 0 then
			f:SetPoint("TOPLEFT", firstOnRow, "TOPRIGHT", 5, 0)
			firstOnRow = f
			f.FirstOnRow = true
		else
			f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -1)
		end
		last = f
		f:Init(self, k, ShuffleList)
		f:SetIDText(k..".")
		f:SetText(L[v.stat])--(Ns.Profile.StatTextAbreviate and L[v.stat.."Abrev"] or L[v.stat])
		f:Show()
	end
	self.LastOrder:ClearAllPoints()
	self.LastOrder:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -1)
	tinsert(self.WidgetList, self.LastOrder)
	self.LastOrder:Init(self, #self.WidgetList, ShuffleList)
end

function Mixins.functions.DisplayOrderConfig.Reset(self)
	local last = #self.WidgetList
	for k, widget in ipairs(self.WidgetList) do
		if k == last then
			break
		end
		Ns:KillWidget(widget)
	end
	wipe(self.WidgetList)
end

function Mixins.functions.DisplayOrderConfig.RunAction(self, action)
	if action == "Save" then
		if not Ns.Profile.CustomOrderList then
			Ns.Profile.CustomOrderList = {}
		end
		if not Ns.Profile.NewColumns then
			Ns.Profile.NewColumns = {}
		end
		wipe(Ns.Profile.CustomOrderList)
		wipe(Ns.Profile.NewColumns)
		for k, v in ipairs(self.StatList) do
			Ns.Profile.CustomOrderList[k] = v.stat
			if self.WidgetList[k].NewColumn:GetChecked() then
				Ns.Profile.NewColumns[v.stat] = true
			end
		end
		self.Save:SetEnabled(false)
		Ns:InitialiseProfile(Ns.Profile)
	elseif action == "AddAllColumns" then
		local widgetlist = self.WidgetList
		for k, v in ipairs(widgetlist) do
			if v.NewColumn and v.NewColumn.Settings and not v.NewColumn:GetChecked() then
				v.NewColumn:Click()
			end
		end
	elseif action == "ClearAllColumns" then
		local widgetlist = self.WidgetList
		for k, v in ipairs(widgetlist) do
			if v.NewColumn and v.NewColumn.Settings and v.NewColumn:GetChecked() then
				v.NewColumn:Click()
			end
		end
	elseif type(action) == "number" then
		local widgetlist = self.WidgetList
		local counter = 0
		local widgetCount = 0
		local colAction = action - 5
		for k, v in ipairs(widgetlist) do
			if v.NewColumn and v.NewColumn.Settings then
				counter = counter + 1
				if (action > 1) and (action < 5) then
						if counter > 1 and counter % action - 1 == 0 then
							if not v.NewColumn:GetChecked() then
								v.NewColumn:Click()
							end
						else
							if v.NewColumn:GetChecked() then
								v.NewColumn:Click()
							end
						end
				elseif action > 5 then
						if counter > 1 and colAction == 1 then
							if v.NewColumn:GetChecked() then
								v.NewColumn:Click()
							end
						else
							widgetCount = math.ceil((#widgetlist - 1) / colAction)
							if (counter == widgetCount + 1) or (counter == (widgetCount * 2) + 1) or (counter == (widgetCount * 3) + 1) then
								if not v.NewColumn:GetChecked() then
									v.NewColumn:Click()
								end
							else
								if v.NewColumn:GetChecked() then
									v.NewColumn:Click()
								end
							end
						end
				else
					if not v.NewColumn:GetChecked() then
						v.NewColumn:Click()
					end
				end

			end
		end
	end
end

--------------------------
--			FAQ			--
--------------------------
function W.FAQConfig(parent)
	local f = CreateFrame("Frame", "$parentProfiles", parent )
	f.SpecialType = "FAQConfig"
	f:SetSize(400, 170)
	Mixin(f, Mixins.functions.FAQConfig)

	f.First = f:CreateFontString()
	f.First:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.First:SetPoint("TOPLEFT", 0, 0)
	f.First:SetJustifyH("LEFT")
	f.First:SetText(L["FAQFirst"])

	f.Second = f:CreateFontString()
	f.Second:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Second:SetPoint("TOPLEFT", f.First, 0, -70)
	f.Second:SetJustifyH("LEFT")
	f.Second:SetText(L["FAQSecond"])

	f.Third = f:CreateFontString()
	f.Third:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Third:SetPoint("TOPLEFT", f.Second, 0, -70)
	f.Third:SetJustifyH("LEFT")
	f.Third:SetText(L["FAQThird"])

	f.Fourth = f:CreateFontString()
	f.Fourth:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Fourth:SetPoint("TOPLEFT", f.Third, 0, -70)
	f.Fourth:SetJustifyH("LEFT")
	f.Fourth:SetText(L["FAQForth"])

	f.Fifth = f:CreateFontString()
	f.Fifth:SetFont(Ns.ConfigDefaultFont, Ns.ConfigDefaultFontSize -4)
	f.Fifth:SetPoint("TOPLEFT", f.Fourth, 0, -70)
	f.Fifth:SetJustifyH("LEFT")
	f.Fifth:SetText(L["FAQFifth"])

	return f
end

Mixins.functions.FAQConfig = {}
function Mixins.functions.FAQConfig.Init(self, anchorframe, parent)
	self.Anchoreframe = anchorframe
	self.MyInformation = parent.DisplayOrder[self:GetID()]
	self.DisplayOrder = parent.DisplayOrder
end
