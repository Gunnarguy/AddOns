local AddName, Ns = ...

local defaultLocale, newLocale
function Ns.RegisterLocale(locale, default)
	if default then
		if locale == "enUS" and not defaultLocale then
			defaultLocale, newLocale = {}, {}
			Ns.L = setmetatable(newLocale, { __index = function(t, k)
				local v = defaultLocale[k] or tostring(k)
				return v
			end})
			return defaultLocale
		end
	end
	return newLocale
end

-- icons
local path = "Interface\\AddOns\\"..AddName.."\\Textures\\"
Ns.MiscIcon = "\124T" .. path .."Misc:13\124t "
Ns.SettingsIcon = "\124T" .. path .."Settings:13\124t "
Ns.DisplayIcon = "\124T" .. path .."Display:13\124t "
Ns.SpacingIcon = "\124T" .. path .."Spacing:13\124t "
Ns.LayoutIcon = "\124T" .. path .."Order:13\124t "
Ns.ColumnIcon = "\124T" .. path .."CheckColumn:13\124t "
Ns.EventsIcon = "\124T" .. path .."Events:13\124t "
Ns.LockIcon = "\124T" .. path .."Lock:12\124t "
Ns.HideIcon = "\124T" .. path .."Hide:12\124t "
Ns.AttachIcon = "\124T" .. path .."Attach:12\124t "
Ns.StrataIcon = "\124T" .. path .."Strata:12\124t "
Ns.OutlineIcon = "\124T" .. path .."Outline:12\124t "
Ns.BackgroundIcon = "\124T" .. path .."Background:12\124t "
Ns.FontsIcon = "\124T" .. path .."Fonts:12\124t "
Ns.FontSizeIcon = "\124T" .. path .."FontSize:12\124t "
Ns.AlignIcon = "\124T" .. path .."Align:12\124t "
Ns.WidthIcon = "\124T" .. path .."Width:12\124t "
Ns.WidthStringIcon = "\124T" .. path .."WidthString:12\124t "
Ns.HeightIcon = "\124T" .. path .."Height:12\124t "
Ns.CapsIcon = "\124T" .. path .."Caps:12\124t "
Ns.TextColorIcon = "\124T" .. path .."TextColor:12\124t "
Ns.ValueColorIcon = "\124T" .. path .."ValueColor:12\124t "
Ns.AbbreviateIcon = "\124T" .. path .."Abbreviate:12\124t "
Ns.ToggleIconsIcon = "\124T" .. path .."ToggleIcons:12\124t "
Ns.SeparatorIcon = "\124T" .. path .."TextSeparator:12\124t "
Ns.MiniMenuIcon = "\124T" .. path .."MinimapMenu:12\124t "
Ns.CompIcon = "\124T" .. path .."Compartment:12\124t "

-- icon textures
local function getSpell(spellID)
	local info = C_Spell.GetSpellTexture(spellID)
	return info
end

local function getCurrency(spellID)
	local info = C_CurrencyInfo.GetCurrencyInfo(spellID)
	return info.iconFileID
end

local function getItem(itemId)
	local _,_,_,_,icon = C_Item.GetItemInfoInstant(itemId)
	return icon
end

-- spell links
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then

	Ns.ShatStarLink = "|T"..getSpell(370452)..":0|t" .. C_Spell.GetSpellLink(370452) .. "  "
	Ns.MystTouchLink = "|T"..getSpell(113746)..":0|t" .. C_Spell.GetSpellLink(331653) .. "  "
	Ns.JadefireLink = "|T"..getSpell(395414)..":0|t" .. C_Spell.GetSpellLink(395414) .. "  "
	Ns.BetEyesLink = "|T"..getSpell(315341)..":0|t" .. C_Spell.GetSpellLink(315341) .. "  "
	Ns.ChaosBrandLink = "|T"..getSpell(1490)..":0|t" .. C_Spell.GetSpellLink(1490) .. "  "
	Ns.ColSmashLink = "|T"..getSpell(208086)..":0|t" .. C_Spell.GetSpellLink(167105) .. "  "
	Ns.FelSunLink = "|T"..getSpell(387402)..":0|t" .. C_Spell.GetSpellLink(387402) .. "  "
	Ns.BrittleLink = "|T"..getSpell(374557)..":0|t" .. C_Spell.GetSpellLink(374557) .. "  "
	Ns.EradicLink = "|T"..getSpell(196414)..":0|t" .. C_Spell.GetSpellLink(196414) .. "  "
	Ns.FinalReckLink = "|T"..getSpell(343721)..":0|t"..C_Spell.GetSpellLink(343721).."   "
	Ns.GhostlyStrikeLink = "|T"..getSpell(196937)..":0|t"..C_Spell.GetSpellLink(196937).."   "
	Ns.WanTwilightLink = "|T"..getSpell(394083)..":0|t"..C_Spell.GetSpellLink(394083).."   "
	Ns.HuntersMarkLink = "|T"..getSpell(257284)..":0|t"..C_Spell.GetSpellLink(257284).."   "
	Ns.RazorLink = "|T"..getSpell(51714)..":0|t"..C_Spell.GetSpellLink(51714).."   "
	Ns.StashLink = "|T"..getSpell(1216211)..":0|t"..C_Spell.GetSpellLink(1216211).."   "
	Ns.KejLink = "|T".. getCurrency(3056)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3056)
	Ns.WeathLink = "|T".. getCurrency(3285)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3285)
	Ns.CarvedLink = "|T".. getCurrency(3287)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3287)
	Ns.RunedLink = "|T".. getCurrency(3289)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3289)
	Ns.GildedLink = "|T".. getCurrency(3290)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3290)
	Ns.ValorLink = "|T".. getCurrency(3008)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3008)
	Ns.CrystalLink = "|T".. getCurrency(2815)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2815)
	Ns.DonorLink = "|T".. getCurrency(2897)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2897)
	Ns.ValorPvPLink = "|T".. getCurrency(1191)..":0|t"..C_CurrencyInfo.GetCurrencyLink(1191)
	Ns.BloodyLink = "|T".. getCurrency(2123)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2123)
	Ns.HonorLink = "|T".. getCurrency(1792)..":0|t"..C_CurrencyInfo.GetCurrencyLink(1792)
	Ns.ConqLink = "|T".. getCurrency(1602)..":0|t"..C_CurrencyInfo.GetCurrencyLink(1602)
	Ns.TimeLink = "|T".. getCurrency(1166)..":0|t"..C_CurrencyInfo.GetCurrencyLink(1166)
	Ns.TenderLink = "|T".. getCurrency(2032)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2032)
	Ns.CartelLink = "|T".. getCurrency(3120)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3120)
	Ns.HalloLink = "|T".. getCurrency(2899)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2899)
	Ns.AssemLink = "|T".. getCurrency(2902)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2902)
	Ns.SevereLink = "|T".. getCurrency(2903)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2903)
	Ns.CofferLink = "|T".. getCurrency(3028)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3028)
	Ns.CoinLink = "|T".. getCurrency(2803)..":0|t"..C_CurrencyInfo.GetCurrencyLink(2803)
	Ns.CatalystLink = "|T".. getCurrency(3269)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3269)
	Ns.CelebLink = "|T".. getCurrency(3100)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3100)
	Ns.IronLink = "|T".. getCurrency(3090)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3090)
	Ns.PlundLink = "|T".. getCurrency(3139)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3139)
	Ns.KajaLink = "|T".. getCurrency(3218)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3218)
	Ns.VintageLink = "|T".. getCurrency(3220)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3220)
	Ns.MarketLink = "|T".. getCurrency(3226)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3226)
	Ns.DarkfuseLink = "|T".. getCurrency(3177)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3177)
	Ns.GallaLink = "|T".. getCurrency(3136)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3136)
	Ns.RadianceLink = "|T".. getCurrency(3283)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3283)
	Ns.MementosLink = "|T".. getCurrency(3149)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3149)
	Ns.KareshLink = "|T".. getCurrency(3129)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3129)
	Ns.UntethLink = "|T".. getCurrency(3303)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3303)
	Ns.EtherealLink = "|T".. getCurrency(3278)..":0|t"..C_CurrencyInfo.GetCurrencyLink(3278)
	Ns.PuzzlingLink = "|T".. getItem(237502)..":0|t"
	Ns.SparkLink = "|T".. getItem(231757)..":0|t"
	Ns.CinderLink = "|T".. getItem(225557)..":0|t"

elseif WOW_PROJECT_ID == 14 then
	-- Ns.DeathEmbLink = ""--"|T"..select(3, GetSpellInfo(47198))..":0|t"..GetSpellLink(47198).."   "
	-- Ns.FaeFireLink = ""--"|T"..select(3, GetSpellInfo(91565))..":0|t"..GetSpellLink(91565).."   "
	-- Ns.EarMoonLink = ""--"|T"..select(3, GetSpellInfo(60433))..":0|t"..GetSpellLink(60433).."   "
	-- Ns.HuntMarkLink = ""--"|T"..select(3, GetSpellInfo(1130))..":0|t"..GetSpellLink(1130).."   "
	-- Ns.ScarFeverLink = ""--"|T"..select(3, GetSpellInfo(81130))..":0|t"..GetSpellLink(81130).."   "
	-- Ns.ExpArmLink = ""--"|T"..select(3, GetSpellInfo(8647))..":0|t"..GetSpellLink(8647).."   "
	-- Ns.SunArmLink = ""--"|T"..select(3, GetSpellInfo(58567))..":0|t"..GetSpellLink(58567).."   "
	-- Ns.CursEleLink = ""--"|T"..select(3, GetSpellInfo(1490))..":0|t"..GetSpellLink(1490).."   "
	-- Ns.BeaSlayLink = ""--"|T"..select(3, GetSpellInfo(20557))..":0|t"..GetSpellLink(20557).."   "
	-- Ns.MolFuryLink = ""--"|T"..select(3, GetSpellInfo(31679))..":0|t"
	-- Ns.BrittleLink = ""--"|T"..select(3, GetSpellInfo(81326))..":0|t"..GetSpellLink(81326).."   "
	-- Ns.SavCombLink = ""--"|T"..select(3, GetSpellInfo(58413))..":0|t"
	-- Ns.MasPoisLink = ""--"|T"..select(3, GetSpellInfo(93068))..":0|t"..GetSpellLink(93068).."   "
	-- Ns.BloFrenLink = ""--"|T"..select(3, GetSpellInfo(30070))..":0|t"..GetSpellLink(30070).."   "
	-- Ns.NoEscapeLink = ""--"|T"..select(3, GetSpellInfo(53298))..":0|t"
	-- Ns.ShadFlameLink = ""--"|T"..select(3, GetSpellInfo(76768))..":0|t"..GetSpellLink(17800).."   "
	-- Ns.VindiLink = ""--"|T"..select(3, GetSpellInfo(26017))..":0|t"..GetSpellLink(26017).."   "
	-- Ns.LightBreathLink = ""--"|T"..select(3, GetSpellInfo(24844))..":0|t"..GetSpellLink(24844).."   "

elseif WOW_PROJECT_ID == 19 then
	Ns.DeathEmbLink = ""--"|T"..select(3, GetSpellInfo(47198))..":0|t"..GetSpellLink(47198).."   "
	Ns.FaeFireLink = ""--"|T"..select(3, GetSpellInfo(91565))..":0|t"..GetSpellLink(91565).."   "
	Ns.EarMoonLink = ""--"|T"..select(3, GetSpellInfo(60433))..":0|t"..GetSpellLink(60433).."   "
	Ns.HuntMarkLink = ""--"|T"..select(3, GetSpellInfo(1130))..":0|t"..GetSpellLink(1130).."   "
	Ns.ScarFeverLink = ""--"|T"..select(3, GetSpellInfo(81130))..":0|t"..GetSpellLink(81130).."   "
	Ns.ExpArmLink = ""--"|T"..select(3, GetSpellInfo(8647))..":0|t"..GetSpellLink(8647).."   "
	Ns.SunArmLink = ""--"|T"..select(3, GetSpellInfo(58567))..":0|t"..GetSpellLink(58567).."   "
	Ns.CursEleLink = ""--"|T"..select(3, GetSpellInfo(1490))..":0|t"..GetSpellLink(1490).."   "
	Ns.BeaSlayLink = ""--"|T"..select(3, GetSpellInfo(20557))..":0|t"..GetSpellLink(20557).."   "
	Ns.MolFuryLink = ""--"|T"..select(3, GetSpellInfo(31679))..":0|t"
	Ns.BrittleLink = ""--"|T"..select(3, GetSpellInfo(81326))..":0|t"..GetSpellLink(81326).."   "
	Ns.SavCombLink = ""--"|T"..select(3, GetSpellInfo(58413))..":0|t"
	Ns.MasPoisLink = ""--"|T"..select(3, GetSpellInfo(93068))..":0|t"..GetSpellLink(93068).."   "
	Ns.BloFrenLink = ""--"|T"..select(3, GetSpellInfo(30070))..":0|t"..GetSpellLink(30070).."   "
	Ns.NoEscapeLink = ""--"|T"..select(3, GetSpellInfo(53298))..":0|t"
	Ns.ShadFlameLink = ""--"|T"..select(3, GetSpellInfo(76768))..":0|t"..GetSpellLink(17800).."   "
	Ns.VindiLink = ""--"|T"..select(3, GetSpellInfo(26017))..":0|t"..GetSpellLink(26017).."   "
	Ns.LightBreathLink = ""--"|T"..select(3, GetSpellInfo(24844))..":0|t"..GetSpellLink(24844).."   "
end

-- class colors
Ns.Colors = {
	Green = "|cff71ffc9",
	Red = "|cffC41E3A"	,
	Warrior = "|cffC69B6D",
	Rogue = "|cffFFF468",
	Warlock = "|cff8788EE",
	Paladin = "|cffF48CBA",
	DeathKnight = "|cffC41E3A",
	Druid = "|cffFF7C0A",
	Hunter = "|cffAAD372",
	Mage = "|cff3FC7EB",
	Shaman = "|cff0070DD",
	Evoker = "|cff33937F",
	Monk = "|cff00FF98",
	DemonHunter = "|cffA330C9",
}