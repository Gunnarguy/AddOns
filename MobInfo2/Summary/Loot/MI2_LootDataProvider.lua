local TABLE_LAYOUT = {
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "Name",MI2_TXT_LootName.text, MI2_TXT_LootName.tooltipText  },
    headerText = MI2_TXT_LootName.text,
    cellTemplate = "MI2_LootKeyCellTemplate",
    cellParameters = { "LEFT" },
    canHide = false
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "NumLoots", MI2_TXT_Quantity.text, MI2_TXT_Quantity.tooltipText },
    headerText = MI2_TXT_Quantity.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "NumLoots", "RIGHT" },
    width = 40
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "Amount", MI2_TXT_Price.text, MI2_TXT_Price.tooltipText },
    headerText = MI2_TXT_Price.text,
    cellTemplate = "MI2_PriceCellTemplate",
    cellParameters = { "Amount" },
    width = 120
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "Vendor", MI2_TXT_Vendor.text, MI2_TXT_Vendor.tooltipText },
    headerText = MI2_TXT_Vendor.text,
    cellTemplate = "MI2_PriceCellTemplate",
    cellParameters = { "Vendor" },
    defaultHide = true,
    width = 120,
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "NumMobs", MI2_TXT_NumMobs.text, MI2_TXT_NumMobs.tooltipText },
    headerText = MI2_TXT_NumMobs.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "NumMobs", "RIGHT" },
    defaultHide = true,
    width = 40,
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "NumNonMobs", MI2_TXT_NumMobs.text, MI2_TXT_NumMobs.tooltipText },
    headerText = MI2_TXT_NumNonMobs.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "NumNonMobs", "RIGHT" },
    defaultHide = true,
    width = 40,
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "ID", MI2_TXT_ID.text, MI2_TXT_ID.tooltipText },
    headerText = MI2_TXT_ID.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "ID" },
    defaultHide = true,
    width = 60
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "Time", MI2_TXT_Time.text, MI2_TXT_Time.tooltipText },
    headerText = MI2_TXT_Time.text,
    cellTemplate = "MI2_TimeCellTemplate",
    cellParameters = { "Time" },
    width = 60
  }
}

local COMPARATORS = {
  Amount = MI2_NumberComparator,
  Name = MI2_StringComparator,
  NumLoots = MI2_NumberComparator,
  Vendor = MI2_NumberComparator,
  Time = MI2_NumberComparator,
  NumMobs = MI2_NumberComparator,
  NumNonMobs = MI2_NumberComparator,
  ID = MI2_NumberComparator
}

MI2_LootDataProviderMixin = CreateFromMixins(MI2_DataProviderMixin)

function MI2_LootDataProviderMixin:OnLoad()
  MI2_DataProviderMixin.OnLoad(self)
  self.mobs = {}
  self.uniqueMobs = {}
  self.uniqueNumMobs = 0
  self.hideStates = {}
  self:SetUpEvents()
end

function MI2_LootDataProviderMixin:Reset()
  MI2_DataProviderMixin.Reset(self)
  self.uniqueMobs = {}
  self.uniqueNumMobs = 0
end

function MI2_LootDataProviderMixin:SetOnFilterCallback(onfilterCallback)
  self.onFilter = onfilterCallback
end

function MI2_LootDataProviderMixin:Filter(entries)
  if self.onFilter then
    local filteredResults = {}
    for _, entry in pairs(entries) do
      if self.onFilter(entry) then
        table.insert(filteredResults, entry)
      end
    end
    return filteredResults
  end
  return entries
end

function MI2_LootDataProviderMixin:SetUpEvents()
  MI2_EventBus:RegisterSource(self, "LootDataProvider")

  MI2_EventBus:Register(self, { "NEW_LOOT" })
end

function MI2_LootDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == "NEW_LOOT" then
    self:ProcessEntries({ eventData }, true)
  end
end

function MI2_LootDataProviderMixin:UniqueKey(entry)
  return entry.ID
end

function MI2_LootDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function MI2_LootDataProviderMixin:GetTableLayout()
  return TABLE_LAYOUT
end

function MI2_LootDataProviderMixin:GetColumnHideStates()
  return self.hideStates
end

local function MI2_ProcessMobs(self, rowData, entry)
  if entry.Mobs then
    for _, mob in pairs(entry.Mobs) do
      if mob.isCreature then
        if not self.uniqueMobs[mob.GUID] then
          self.uniqueNumMobs = self.uniqueNumMobs + 1
          self.uniqueMobs[mob.GUID] = true
        end

        if mob.Id then
          local mobItems = self.mobs[mob.Id]
          if mobItems == nil then
            mobItems = {}
            self.mobs[mob.Id] = mobItems
          end
          table.insert(mobItems, rowData)
        end
      end
    end
  end
end

function MI2_LootDataProviderMixin:onEntryProcessed(entry)
  entry.FirstTime = entry.Time
  local numLoots = 1
  if entry.Mobs and #entry.Mobs > 0 then
    numLoots = #entry.Mobs
    if entry.Mobs[1].isCreature then
      entry.NumMobs = numLoots
    else
      entry.NumNonMobs = numLoots
    end
  end
  if entry.Quality == -1 then
    entry.Amount = entry.Quantity
    entry.Vendor = entry.Quantity
    entry.NumLoots = numLoots
  elseif entry and entry.ID then
    entry.Amount = 0
    entry.Vendor = 0
    entry.NumLoots = entry.Quantity
    local item = Item:CreateFromItemLink(entry.Link)
    if item:IsItemEmpty() then
      -- check for currency without checking link
      local currency = C_CurrencyInfo.GetCurrencyInfoFromLink(entry.Link)
      if not currency then return end
      entry.iconTexture = currency.iconFileID
    else
      item:ContinueOnItemLoad(function()
        entry.iconTexture = item:GetItemIcon()
        entry.vendorPrice = MI2_FindItemValue(entry.Link)
        if Auctionator then
          local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemLink("MI2", entry.Link)
          if entry.vendorPrice and auctionPrice and auctionPrice > entry.vendorPrice then
            entry.auctionPrice = auctionPrice
          end
        end
        self:setAmount(entry)
        self:SetDirty()
      end)
    end
  end
  MI2_ProcessMobs(self, entry, entry)
end

function MI2_LootDataProviderMixin:setAmount(entry)
  entry.Amount = entry.Quantity
  entry.Vendor = entry.Quantity
  if entry.Quality == 1 then
    entry.Amount = entry.Quantity * (entry.vendorPrice or 0)
    entry.Vendor = entry.Amount
  elseif entry.Quality > 1 then
    entry.Amount = entry.Quantity * (entry.auctionPrice or entry.vendorPrice or 0)
    entry.Vendor = entry.Quantity * (entry.vendorPrice or 0)
  end
end

function MI2_LootDataProviderMixin:onEntryUpdate(rowData, entry)
  local numLoots = 1
  rowData.Quantity = rowData.Quantity + entry.Quantity
  rowData.Time = entry.Time
  if entry.Mobs and #entry.Mobs > 0 then
    numLoots = #entry.Mobs
    if entry.Mobs[1].isCreature then
      rowData.NumMobs = (rowData.NumMobs or 0) + numLoots
    else
      rowData.NumNonMobs = (rowData.NumNonMobs or 0) + numLoots
    end
  end
  self:setAmount(rowData)
  if entry.Quality ~= -1 then
    rowData.NumLoots = rowData.NumLoots + entry.Quantity
  else
    rowData.NumLoots = rowData.NumLoots + numLoots
  end
  MI2_ProcessMobs(self, rowData, entry)
end

function MI2_LootDataProviderMixin:GetNumMobs()
  return self.uniqueNumMobs
end
