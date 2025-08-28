--[=====[
		## RM Utils library ver. 1.1.3
		## rmUtils-tooltip.lua - Tooltip sub-module
		Wrapper-helper for tooltip object
--]=====]

local U = LibStub("rmUtils-1.1")

local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local type = type

local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR

-- Remove all known globals after this point
-- luacheck: std none

local mixin = {}

function mixin:SetTitle(text, color, wrap)
	local titleColor = color or HIGHLIGHT_FONT_COLOR
	local r, g, b, a = titleColor:GetRGBA()
	self.tooltip:SetText(text, r, g, b, a, wrap)
	return self
end

function mixin:AddNormalLine(text, wrap)
	return self:AddColoredLine(text, NORMAL_FONT_COLOR, wrap)
end

function mixin:AddHighlightLine(text, wrap)
	return self:AddColoredLine(text, HIGHLIGHT_FONT_COLOR, wrap)
end

function mixin:AddColoredLine(text, color, wrap)
	local r, g, b = color:GetRGB()
	self.tooltip:AddLine(text, r, g, b, wrap)
	return self
end

function mixin:AddDoubleLine(textLeft, textRight, colorLeft, colorRight)
	local rL, gL, bL = (colorLeft or NORMAL_FONT_COLOR):GetRGB()
	local rR, gR, bR = (colorRight or NORMAL_FONT_COLOR):GetRGB()
	self.tooltip:AddDoubleLine(textLeft, textRight, rL, gL, bL, rR, gR, bR)
	return self
end

function mixin:AddBlankLines(numLines)
	if numLines then
		for _ = 1, numLines do
			self.tooltip:AddLine(" ")
		end
	end
	return self
end

function U.Tooltip(tooltip)
	return U.Merge(
		setmetatable(
			{ tooltip = tooltip },
			{
				__index = function(self, key)
					local tooltipProperty = rawget(self, "tooltip")[key]
					if tooltipProperty and type(tooltipProperty) == "function" then
						local func = function(tbl, ...)
							return tbl.tooltip[key](tbl.tooltip, ...) or self
						end
						rawset(self, key, func)
						return func
					end
				end
			}
		),
		mixin
	)
end
