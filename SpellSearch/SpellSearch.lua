local _, ADDONSELF = ...
local L = ADDONSELF.L

-- Function to register events for a frame
function RegEvent(frame, event, handler)
    frame:RegisterEvent(event)
    frame:SetScript("OnEvent", function(self, ...)
        handler(self, ...)
    end)
end

-- Create the main frame for the spell search
local frame = CreateFrame("Frame", "SpellSearch", UIParent, "BackdropTemplate")
frame:SetSize(330, 280)
frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:SetClampedToScreen(true)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0, 0, 0, 1)
-- Hide the frame on startup
frame:Hide()
-- Title Text with Rainbow Effect
local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", 0, -10)
titleText:SetText("Spell ID Search")

local colors = {
    {1, 0, 0},   -- Red
    {1, 0.5, 0}, -- Orange
    {1, 1, 0},   -- Yellow
    {0, 1, 0},   -- Green
    {0, 0, 1},   -- Blue
    {0.75, 0, 1} -- Violet
}
local colorIndex = 1
local function UpdateTitleColor()
    titleText:SetTextColor(unpack(colors[colorIndex]))
    colorIndex = colorIndex % #colors + 1
    C_Timer.After(1.3, UpdateTitleColor) -- Timer for Title color Change
end
UpdateTitleColor()

-- Create a close button ("X") for the frame
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
closeButton:SetScript("OnClick", function() frame:Hide() end)

-- Create the search input box
local searchInput = CreateFrame("EditBox", "SpellSearchInput", frame, "InputBoxTemplate")
searchInput:SetSize(170, 30)
searchInput:SetPoint("TOPLEFT", 30, -40)
searchInput:SetAutoFocus(false)
searchInput:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    SpellSearch_OnEnterPressed(self)
end)

-- Create the search button
local searchButton = CreateFrame("Button", "SpellSearchButton", frame, "UIPanelButtonTemplate")
searchButton:SetSize(80, 25)
searchButton:SetPoint("TOPRIGHT", -20, -43)
searchButton:SetText("Search")
searchButton:SetScript("OnClick", function()
    SpellSearch_OnEnterPressed(searchInput)
end)

-- Create the scroll frame
local scrollFrame = CreateFrame("ScrollFrame", "SpellSearchScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -80)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- Results child frame (to be recreated each search)
local resultsChild

-- Tooltip frame for spell details
local tooltipFrame = CreateFrame("GameTooltip", "SpellSearchTooltip", UIParent, "GameTooltipTemplate")
tooltipFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -5) -- Fixed position at the top left of the main frame
tooltipFrame:Hide()

-- Spell icon for the tooltip
local spellIcon = tooltipFrame:CreateTexture(nil, "ARTWORK")
spellIcon:SetSize(35, 35)
spellIcon:SetPoint("TOPRIGHT", tooltipFrame, "TOPRIGHT", 35, -3) -- Positioning at the top right of the tooltip

-- Escape Lua pattern function
local function escapeLuaPattern(s)
    return s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Create result text and handle events
local function CreateResultText(match, parent, index)
    local resultText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resultText:SetPoint("TOPLEFT", 0, -(index - 1) * 20)
    resultText:SetText(string.format("%s (Spell ID: %d)", match.name, match.id)) -- Added Spell ID
    resultText:SetTextColor(1, 1, 0)

    resultText:SetScript("OnEnter", function(self)
        -- Check if the result text is within the bounds of the main frame
        local mouseX, mouseY = GetCursorPosition()
        local frameX, frameY = frame:GetCenter()
        local scale = frame:GetEffectiveScale()

        -- Convert mouse coordinates to frame-relative coordinates
        mouseX = mouseX / scale
        mouseY = mouseY / scale

        -- Calculate frame bounds for tooltip
        local frameLeft = frameX - frame:GetWidth() / 2
        local frameRight = frameX + frame:GetWidth() / 2
        local frameTop = frameY + frame:GetHeight() / 4
        local frameBottom = frameY - frame:GetHeight() / 2

        -- Check if the mouse is within frame bounds
        if mouseX >= frameLeft and mouseX <= frameRight and mouseY >= frameBottom and mouseY <= frameTop then
            resultText:SetTextColor(1, 1, 1)

            -- Set the tooltip owner to the main frame
            tooltipFrame:SetOwner(frame, "ANCHOR_NONE") -- Set owner to the main frame

            -- Set the spell by ID and the icon
            tooltipFrame:SetSpellByID(match.id)
            spellIcon:SetTexture(match.icon)

            -- Position the tooltip relative to the main frame with an offset
            tooltipFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 10, 0) -- Adjusts position to the right of the main frame

            -- Show the tooltip
            tooltipFrame:Show()
        end
    end)
    
    resultText:SetScript("OnLeave", function()
        resultText:SetTextColor(1, 1, 0)
        tooltipFrame:Hide()
    end)
end

-- Hide results function
function HideResults()
    if resultsChild then
        resultsChild:Hide()
    end
end

-- Search handling function
function SpellSearch_OnEnterPressed(self)
    local searchTerm = escapeLuaPattern(self:GetText())
    tooltipFrame:Hide()
    spellIcon:SetTexture(nil)

    -- Clear previous results by removing them from memory
    HideResults()  -- Ensure we call this to remove existing results

    -- Create a new results child frame for this search
    resultsChild = CreateFrame("Frame", nil, scrollFrame)
    resultsChild:SetSize(260, 1)
    scrollFrame:SetScrollChild(resultsChild)

    local matches = {}
    for spellID = 1, 30000 do
        local spellName, _, icon = GetSpellInfo(spellID)
        if spellName and spellName:lower():find(searchTerm:lower()) then
            table.insert(matches, {name = spellName, id = spellID, icon = icon})
        end
    end

    if #matches > 0 then
        for i, match in ipairs(matches) do
            CreateResultText(match, resultsChild, i) -- Create new result text for each match
        end
        resultsChild:SetHeight(#matches * 20) -- Set height based on number of results
    else
        resultsChild:Hide() -- No matches found
    end
end
-- Slash command to toggle frame visibility
SLASH_SPELLSEARCH1 = "/spellsearch"
SlashCmdList["SPELLSEARCH"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Initialize tooltip frame
tooltipFrame:Hide()
