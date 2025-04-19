MI2_SummaryFrameMixin = {}

function MI2_SummaryFrameMixin:OnClose()
	self:Hide()
end

function MI2_SummaryFrameMixin:OnReset()
	self.DataProvider:Reset()
	self.SourceDataProvider:Reset()
end

function MI2_SummaryFrameMixin:OnLoad()
	self:ApplyBackdrop()

	self.Tabs:SetTabSystem(self.TabSystem);
	self.Title:SetText(MI2_TXT_Summary)

	self.lootTabID = self.Tabs:AddNamedTab("Loots", self.LootListing);
	self.mobTabID = self.Tabs:AddNamedTab("Mobs", self.SourceListing);

	self:SetResizable(true)

	if self.SettingsButton then
    	self.SettingsButton:SetOnCallback( function(...) self:OnSettings(...) end)
	end

	self.LootListing:Init(self.DataProvider)
	self.LootListing:SetOnUpdateCallback(function(...) self:Update(...) end)
	self.LootListing.FilterDropDown:SetOnCallback( function(qualityFilter)
		self.DataProvider:SetOnFilterCallback( function(entry) return qualityFilter[entry.Quality] end)
		self.DataProvider:SetDirty()
	end)

	self.SourceListing:Init(self.SourceDataProvider)
	-- No filtering support for Sources
	self.SourceListing.FilterDropDown:Hide()

	if self.MaximizeMinimizeFrame then
		local function OnMaximize(frame)
			frame:GetParent():ConfigureSize( false );
		end

		self.MaximizeMinimizeFrame:SetOnMaximizedCallback(OnMaximize);

		local function OnMinimize(frame)
			frame:GetParent():ConfigureSize( true );
		end

		self.MaximizeMinimizeFrame:SetOnMinimizedCallback(OnMinimize);
	end
	self.Tabs:SetTab(self.lootTabID)
	
	if not MI2_WOWRetail then
		if self.CloseButton then
			self.CloseButton:SetSize(28, 28)
			self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 4, 1 )
		end
		if self.MaximizeMinimizeFrame then
			self.MaximizeMinimizeFrame:SetSize(28,28)
			self.MaximizeMinimizeFrame:SetPoint("RIGHT", self.CloseButton, "LEFT", 11, 0 )
		end
	end
end

function MI2_SummaryFrameMixin:OnSettings( value, font)
	if value == 1 then self:OnReset() end
	if value == 2 then
		MobInfoConfig.SummaryFont = font:GetName()
		MI2_SummaryFont.Normal = font
		self:OnSizeChanged(self:GetSize())
		self:SetMinMax(true)
    end
end

function MI2_SummaryFrameMixin:OnHide()
	-- force Maximize when hiding, some issue when restoring a minimized frame after hiding
	-- and then maximzing it
	if self.MaximizeMinimizeFrame then
		self.MaximizeMinimizeFrame:Maximize(true);
	end
end

function MI2_SummaryFrameMixin:OnShow()
  if MobInfoConfig.SummaryFont then
    MI2_SummaryFont.Normal = _G[MobInfoConfig.SummaryFont]
  end

  self:OnSizeChanged(self:GetSize())
  self:SetMinMax(true)
end

function MI2_SummaryFrameMixin:OnMouseDown(button)
	if button == "LeftButton" then
		self:StartMoving()
	end
end

function MI2_SummaryFrameMixin:OnMouseUp(button)
	if button == "LeftButton" then
		self:StopMovingOrSizing()
	end
end

function MI2_SummaryFrameMixin:Update(entries)
	if entries then
		local earliestTime = 2147483640
		local totalAmount = 0
		local totalVendor = 0
		local totalQuantity = 0
		local totalMobs = 0

		for _, entry in pairs(entries) do
			earliestTime = math.min(earliestTime,entry.FirstTime)
			totalMobs = totalMobs + (entry.NumMobs or 0)
			totalAmount = totalAmount + entry.Amount
			totalVendor = totalVendor + entry.Vendor
			if entry.Quality>0 then
				totalQuantity = totalQuantity + entry.Quantity
			end
		end

		local elapsedFactor = 0.36/(GetTime()-earliestTime)
		self.TotalAmount:SetText(GetMoneyString(totalAmount).." ("..GetMoneyString(10000*floor(totalAmount*elapsedFactor)).. "/h)")
		self.TotalVendor:SetText(GetMoneyString(totalVendor).." ("..GetMoneyString(10000*floor(totalVendor*elapsedFactor)).. "/h)")
		self.TotalQuantity:SetText(totalQuantity)

		self.TotalMobs:SetText(self.DataProvider:GetNumMobs())
	end
end

function MI2_SummaryFrameMixin:OnSizeChanged(width,height)
  local fontHeight = MI2_SummaryFont:GetHeight()
  local adjustedHeight = fontHeight+10+math.floor(((height - 130 - 10 - fontHeight)/(fontHeight+1)))*(fontHeight+1)
  self.LootListing:Resize(width,math.max(10+(fontHeight+1)*6,adjustedHeight))
  self.SourceListing:Resize(width,math.max(10+(fontHeight+1)*6,adjustedHeight))
  self.Tabs:SetSize(width,math.max(10+(fontHeight+1)*6,adjustedHeight))
  if not self.isMinimized then
	self.previousWidth, self.previousHeight = self:GetSize()
  end
end

function MI2_SummaryFrameMixin:SetMinMax(resize)
  if not self.isMinimized then
	local minRowHeight = 25+MI2_SummaryFont:GetHeight()*5
    local minRowWidth = math.max(self.LootListing.minWidth or 0, self.SourceListing.minWidth or 0)+10
	if self.ResizeButton then
    	self.ResizeButton:Init(self, math.max(250,minRowWidth),minRowHeight+35);
	end

	local currentWidth, currentHeight = self:GetSize()
	if resize and minRowWidth> currentWidth then
	  self:SetSize(minRowWidth,currentHeight)
	end
  end
end

function MI2_SummaryFrameMixin:ConfigureSize(isMinimized)
	MobInfoConfig.isSummaryMinimized = isMinimized
	local lootButton = self.TabSystem:GetTabButton(self.lootTabID)
	local mobButton = self.TabSystem:GetTabButton(self.mobTabID)
	if isMinimized == true then
		self.LootListing:Hide()
		self.SourceListing:Hide()
		lootButton:Hide()
		mobButton:Hide()
		self.ResizeButton:Init(self, 250,103,250,103);
		self:SetSize(250,103);
		self.ResizeButton:Hide()
	else
		lootButton:Show()
		mobButton:Show()
		if lootButton.LeftActive:IsShown() then
			self.LootListing:Show()
		end

		if mobButton.LeftActive:IsShown() then
			self.SourceListing:Show()
		end

		local oldWidth, oldHeight = self.previousWidth, self.previousHeight
		local currentWidth, currentHeight = self:GetSize()
		self:SetSize(oldWidth or currentWidth, oldHeight or currentHeight);
	end

	self.isMinimized = isMinimized
end

function MI2_SummaryFrameMixin:OnEnter()
  if self.ResizeButton and not self.isMinimized then
    self.ResizeButton:Show()
  end
end

function MI2_SummaryFrameMixin:OnLeave()
  if self.ResizeButton and not self.ResizeButton:IsMouseOver() and not self.isMinimized then
    self.ResizeButton:Hide()
  end
end
