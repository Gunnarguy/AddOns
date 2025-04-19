local TABLE_LAYOUT = {
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "Name",MI2_TXT_SourceName.text, MI2_TXT_SourceName.tooltipText  },
    headerText = MI2_TXT_SourceName.text,
    cellTemplate = "MI2_SourceKeyCellTemplate",
    cellParameters = { "LEFT" },
    canHide = false
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "Type",MI2_TXT_SourceType.text, MI2_TXT_SourceType.tooltipText  },
    headerText = MI2_TXT_SourceType.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "Type" },
    defaultHide = true,
    canHide = true
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "NumItems", MI2_TXT_NumItems.text, MI2_TXT_NumItems.tooltipText },
    headerText = MI2_TXT_NumItems.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "NumItems", "RIGHT" },
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
    headerParameters = { "AverageAmount", MI2_TXT_AverageValue.text, MI2_TXT_AverageValue.tooltipText },
    headerText = MI2_TXT_AverageValue.text,
    cellTemplate = "MI2_PriceCellTemplate",
    cellParameters = { "AverageAmount" },
    defaultHide = true,
    width = 100
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
    headerParameters = { "AverageVendor", MI2_TXT_AverageVendor.text, MI2_TXT_AverageVendor.tooltipText },
    headerText = MI2_TXT_AverageVendor.text,
    cellTemplate = "MI2_PriceCellTemplate",
    cellParameters = { "AverageVendor" },
    defaultHide = true,
    width = 100
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "NumSources", MI2_TXT_NumSources.text, MI2_TXT_NumSources.tooltipText },
    headerText = MI2_TXT_NumSources.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "NumSources", "RIGHT" },
    defaultHide = true,
    width = 40,
  },
  {
    headerTemplate = "MI2_StringColumnHeaderTemplate",
    headerParameters = { "NumUniqueItems", MI2_TXT_NumUniqueItems.text, MI2_TXT_NumUniqueItems.tooltipText },
    headerText = MI2_TXT_NumUniqueItems.text,
    cellTemplate = "MI2_StringCellTemplate",
    cellParameters = { "NumUniqueItems", "RIGHT" },
    defaultHide = true,
    width = 40
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
  AverageAmount = MI2_NumberComparator,
  Name = MI2_StringComparator,
  Type = MI2_StringComparator,
  Quantity = MI2_NumberComparator,
  Vendor = MI2_NumberComparator,
  AverageVendor = MI2_NumberComparator,
  Time = MI2_NumberComparator,
  NumItems = MI2_NumberComparator,
  NumUniqueItems = MI2_NumberComparator,
  NumSources = MI2_NumberComparator,
  ID = MI2_NumberComparator
}

MI2_SourceDataProviderMixin = CreateFromMixins(MI2_DataProviderMixin)

function MI2_SourceDataProviderMixin:OnLoad()
  MI2_DataProviderMixin.OnLoad(self)
  self.items = {}
  self.uniqueMobs = {}
  self.uniqueNumMobs = 0
  self.hideStates = {}
  self:SetUpEvents()
end

function MI2_SourceDataProviderMixin:Reset()
  MI2_DataProviderMixin.Reset(self)
  self.uniqueMobs = {}
  self.uniqueNumMobs = 0
end

function MI2_SourceDataProviderMixin:SetOnFilterCallback(onfilterCallback)
  self.onFilter = onfilterCallback
end

function MI2_SourceDataProviderMixin:Filter(entries)
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

function MI2_SourceDataProviderMixin:SetUpEvents()
  MI2_EventBus:RegisterSource(self, "SourceDataProvider")

  MI2_EventBus:Register(self, { "NEW_LOOT" })
end

function MI2_SourceDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  local entries = {}
  if eventName == "NEW_LOOT" then
    if eventData.Mobs then
      for key, mob in ipairs(eventData.Mobs) do
        local _
        local mobEntry = {}
        mobEntry.item = eventData
        mobEntry.mobKey = key
        mobEntry.Name = mob.Name
        mobEntry.Level = mob.Level
--        mobEntry.Type, _, _, _, _, mobEntry.ID = strsplit("-", mob.GUID)
        mobEntry.Type = mob.Type
        mobEntry.ID = mob.Id
--        mobEntry.ID = tonumber(mobEntry.ID)
        table.insert(entries,mobEntry)
      end
    end
    self:ProcessEntries(entries, true)
  end
end

function MI2_SourceDataProviderMixin:UniqueKey(entry)
  return entry.ID
end

function MI2_SourceDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function MI2_SourceDataProviderMixin:GetTableLayout()
  return TABLE_LAYOUT
end

function MI2_SourceDataProviderMixin:GetColumnHideStates()
  return self.hideStates
end

function MI2_SourceDataProviderMixin:ProcessItem(rowData, entry)
  local itemInfo = self.items[entry.item.ID]
  local quality = entry.item.Quality
  local quantity = entry.item.Mobs[entry.mobKey].Quantity
  local mobGUID = entry.item.Mobs[entry.mobKey].GUID

  if quality ~= -1 then
    rowData.NumItems = (rowData.NumItems or 0) + quantity
  else
    rowData.NumItems = (rowData.NumItems or 0) + 1
  end

  local updateItem = function()
    if quality == 1 then
      rowData.Amount = (rowData.Amount or 0) + quantity * (itemInfo.vendorPrice or 0)
      rowData.Vendor = (rowData.Vendor or 0) + quantity * (itemInfo.vendorPrice or 0)
    elseif quality > 1 then
      rowData.Amount = (rowData.Amount or 0) + quantity * (itemInfo.auctionPrice or itemInfo.vendorPrice or 0)
      rowData.Vendor = (rowData.Vendor or 0) + quantity * (itemInfo.vendorPrice or 0)
    else
      rowData.Amount = (rowData.Amount or 0) + quantity
      rowData.Vendor = (rowData.Vendor or 0) + quantity
    end

    if not self.uniqueMobs[mobGUID] then
      self.uniqueMobs[mobGUID] = true
      rowData.NumSources = (rowData.NumSources or 0) + 1
    end

    if rowData.Amount and rowData.NumSources then
      rowData.AverageAmount = rowData.Amount / rowData.NumSources
    end
    if rowData.Price and rowData.NumSources then
      rowData.AveragePrice = rowData.Price / rowData.NumSources
    end
    if rowData.Amount and rowData.NumSources then
      rowData.AverageVendor = rowData.Vendor / rowData.NumSources
    end

    -- cleanup what we don't need anymore
    entry.item = nil
    entry.mobKey = nil
  end

  if not itemInfo and entry.item.Link then
    itemInfo = {}
    self.items[entry.item.ID] = itemInfo
    local item = Item:CreateFromItemLink(entry.item.Link)
    if not item:IsItemEmpty() then
      item:ContinueOnItemLoad(function()
        itemInfo.vendorPrice = MI2_FindItemValue(entry.item.Link)
        if Auctionator then
          local auctionPrice = Auctionator.API.v1.GetAuctionPriceByItemLink("MI2", entry.item.Link)
          if itemInfo.vendorPrice and auctionPrice and auctionPrice > itemInfo.vendorPrice then
            itemInfo.auctionPrice = auctionPrice
          end
        end
        updateItem()
      end)
    end
  else
    updateItem()
  end
end

function MI2_SourceDataProviderMixin:onEntryProcessed(entry)
  entry.FirstTime = entry.item.Time
  entry.Time = entry.FirstTime

  entry.items = {}
  entry.items[entry.item.ID] = entry.item
  entry.NumUniqueItems = 1

  entry.Name = MI2_GetNameForId(entry.ID) or entry.Name or tostring(entry.ID)

  self:ProcessItem(entry,entry)
end

function MI2_SourceDataProviderMixin:onEntryUpdate(rowData, entry)
    if rowData.items[entry.item.ID] == nil then
      rowData.items[entry.item.ID] = entry.item
      rowData.NumUniqueItems = rowData.NumUniqueItems + 1
    end
    if not entry.isCreature and tonumber(rowData.Name) ~= nil and entry.Name ~= nil then
      rowData.Name = entry.Name
    end
    rowData.Time = math.max(rowData.Time, entry.item.Time)

    self:ProcessItem(rowData,entry)
end
