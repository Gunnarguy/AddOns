----------------------------------------------------------------------
-- Leatrix Sounds Locale
----------------------------------------------------------------------

-- Create locale structure
local GameLocale = GetLocale()
local void, Leatrix_Sounds = ...
local function localeFunc(L, key) return key end
local L = setmetatable({}, {__index = localeFunc})
Leatrix_Sounds.L = L

-- Locale override (enUS, zhCN, zhTW, ruRU, koKR, deDE, esMX, frFR, itIT, ptBR)
-- GameLocale = "enUS"

-- zhCN: Simplified Chinese (People's Republic of China)
if GameLocale == "zhCN" then
L["Cataclysm"] = "旧时经典：大地的裂变"
L["Classic Era"] = "旧时经典"
L["Effects"] = "效果"
L["Help"] = "帮助"
L["If checked, music will be shown in the listing."] = "如果选中，音乐将显示在列表中。"
L["If checked, sound effects will be shown in the listing."] = "如果选中，声音效果将显示在列表中。"
L["If checked, unknown sound files will be shown in the listing.|n|nThese are typically newer sound files which do not have names yet.|n|nNote that some unknown sound files may not be currently playable."] = "如果选中，未知音频文件将显示在列表中。|n|n这些通常是较新的音频文件，还没有严格命名。|n|n请注意，某些未知的音频文件当前可能无法播放。"
L["LEATRIX SOUNDS: THIS IS FOR THE WAR WITHIN ONLY!"] = "LEATRIX SOUNDS：这只能在正式服生效！"
L["Music"] = "音乐"
L["No search results found"] = "未找到搜索结果"
L["Oops!"] = "啊！"
L["result"] = "结果"
L["results"] = "个结果"
L["Searches can consist of up to 10 keywords.  Keywords prefixed with ! are excluded from search results.|n|nWhile a track is selected, you can press W and S to play the previous and next track, E to replay the currently selected track or Q to stop playback.|n|nHold SHIFT and click to print (left-click) or insert (right-click) the selected track details in chat.|n|nHold CONTROL and click to print (left-click) or insert (right-click) the selected track ID in chat."] = "搜索最多可包含10个关键字。前缀为!从搜索结果中排除。|n|n选中音频时，您可以按W和S播放上一条和下一条音频，按E重播当前选定的条，按Q停止播放。|n|n按住SHIFT并单击以在聊天框中直接打印（左键单击）或在聊天输入框插入（右键单击）选定的曲目详细信息。|n|n按住CTRL并单击以在聊天框中直接打印（左键单击）或在聊天输入框插入（右键单击）所选音频ID。"
L["SFX"] = "音效"
L["So I guess there's nothing to see here."] = "所以我想这里什么也没找到。"
L["Sound Files"] = "音频文件"
L["Stop"] = "停止"
L["The War Within"] = "地心之战"
L["Toggle panel"] = "开关插件面板"
L["Unknown"] = "未知音频"
L["You need to select at least one sound category."] = "您需要至少选择一个音频类别。"

end

-- zhTW: Traditional Chinese (Taiwan)
if GameLocale == "zhTW" then

end

-- ruRU: Russian
if GameLocale == "ruRU" then

end

-- koKR: Korean
if GameLocale == "koKR" then

end

-- deDE: German
if GameLocale == "deDE" then
	
end

-- esMX: Spanish (Mexico)
if GameLocale == "esMX" then

end

-- esES: Spanish (Spain)
if GameLocale == "esES" then

end

-- frFR: French
if GameLocale == "frFR" then

end

-- itIT: Italian
if GameLocale == "itIT" then

end

-- ptBR: Portugese (Brazil)
if GameLocale == "ptBR" then

end
