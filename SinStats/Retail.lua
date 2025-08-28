local AddName, Ns = ...
local L = Ns.L


------------------------------
--		Stat Options		--
------------------------------
local Both, Enhanced, Base, Damage, DamageTaken, Melee, Ranged, World, Realm, Equipped, Overall, Level, Honor, Max, Live, Enchanted, Ingenuity = 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 2
local Percentage, Rating, MainHand, OffHand, SameLevel, BossLevel, Regen, Casting, Critical, CritDamage, Average, Low, Static, Normal, Shadowflame = 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 2, 3, 2, 1, 1
local Season, Expansion, Spark, Splinter, Gigantic, Plump, Current, Earned, Empty, Vintage = 1, 2, 1, 2, 1, 2, 1, 2, 1, 2

Ns.ConfigWidth = 950
Ns.ConfigHeight = 540
if GetLocale() == "frFR" or GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR" then
	Ns.ConfigWidth = 960
end

--local honorIcon = 73824
--local faction = UnitFactionGroup("player")
--if faction == "Horde" then honorIcon = 59641 end

------------------------------
--		Global Updater		--
------------------------------
function Ns.MeleeUpdate() end
function Ns.DefenseUpdate() end
function Ns.RangedUpdate() end
function Ns.SpellUpdate() end

------------------------------
--		Display Order		--
------------------------------
Ns.DefaultOrder = { -- grp = SpellClass, options order = display order, ["on"]/["off"] option is implied in all stats so not required in the table. The [1]..[2] not required but just for example
{ stat="CritChance", onupdate=true, events={}, spell=275336, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Percent_Rating=true, Display_Basic=true, Decimals_Crit=true, Cap_Percent=true, Cap_Rating=true }, subgroup=true, activeonload=true, },
{ stat="Haste", onupdate=true, events={}, spell=342245, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Haste=true, Cap_Percent=true, Cap_Rating=true }, subgroup=true },
{ stat="Mastery", onupdate=true, events={}, spell=207684, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Mastery=true, Cap_Percent=true, Cap_Rating=true }, subgroup=true },
{ stat="Versatility", onupdate=true, events={}, spell=202137, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Damage_Taken=true, Display_Rating=true, Decimals_Versatility=true, Cap_Percent=true }, subgroup=true },
{ stat="Avoidance", onupdate=true, events={}, spell=202138, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Avoidance=true, Cap_Percent=true, Cap_Rating=true }, subgroup=true },
{ stat="Leech", onupdate=true, events={}, spell=204021, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Leech=true, Cap_Percent=true, Cap_Rating=true }, subgroup=true },
{ stat="Speed", onupdate=true, events={}, updatespeed=1, spell=109215, spellclass="Enhancement", widget={ type="CheckBox" }, options={ Speed_Static=true, Decimals_Speed=true }, subgroup=true },
{ stat="Strength", onupdate=true, events={}, spell=48743, spellclass="Physical", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Default=true }, subgroup=true, activeonload=true, },
{ stat="Agility", onupdate=true, events={}, spell=319032, spellclass="Physical", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Default=true }, subgroup=true },
{ stat="Intellect", onupdate=true, events={}, spell=23030, spellclass="Spell", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Default=true }, subgroup=true, activeonload=true, },
{ stat="AP", onupdate=true, events={}, spell=29838, spellclass="Physical", widget={ type="CheckBox" }, options={ Melee_Ranged=true, Decimals_Default=true }, subgroup=true },
{ stat="DMG", onupdate=true, events={}, spell=315720, spellclass="Physical", widget={ type="CheckBox" }, options={ Max_Average_Damage=true, Display_MainHand=true, Decimals_Damage=true }, subgroup=true },
{ stat="DMGMod", onupdate=true, events={}, spell=152175, spellclass="Physical", widget={ type="CheckBox" }, options={ Melee_Ranged=true, Decimals_DmgMod=true }, subgroup=true },
{ stat="DPS", onupdate=true, events={}, spell=115080, spellclass="Physical", widget={ type="CheckBox" }, options={ Melee_Ranged=true, Display_MainHand=true, Decimals_Default=true }, subgroup=true },
{ stat="SpellPower", onupdate=true, events={}, spell=321358, spellclass="Spell", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Default=true }, subgroup=true },
{ stat="DMGModSpell", onupdate=true, events={}, spell=385899, spellclass="Spell", widget={ type="CheckBox" }, options={ Decimals_DmgModSpell=true }, subgroup=true },
{ stat="Healing", onupdate=true, events={}, spell=2050, spellclass="Spell", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Default=true }, subgroup=true },
{ stat="weaponSpeed", onupdate=true, events={}, spell=321281, spellclass="Physical", widget={ type="CheckBox" }, options={ Melee_Ranged=true, Decimals_WepSpeed=true }, subgroup=true },
{ stat="ManaRegen", onupdate=true, events={}, spell=63733, spellclass="Spell", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="EnergyRegen", onupdate=true, events={}, spell=212283, spellclass="Physical", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Energy=true }, subgroup=true },
{ stat="Stamina", onupdate=true, events={}, spell=320380, spellclass="Physical", widget={ type="CheckBox" }, options={ Enhanced_Base=true, Decimals_Default=true }, subgroup=true },
{ stat="Mitigation", onupdate=true, events={}, spell=155147, spellclass="Physical", widget={ type="CheckBox" }, options={ Show=true, Decimals_DR=true }, subgroup=true },
{ stat="Armor", onupdate=true, events={}, spell=321708, spellclass="Physical", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Dodge", onupdate=true, events={}, spell=115008, spellclass="Physical", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Dodge=true, Cap_Percent=true, Cap_Rating=true }, subgroup=true },
{ stat="Parry", onupdate=true, events={}, spell=118038, spellclass="Physical", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Parry=true, Cap_Percent=true, Cap_Rating=true  }, subgroup=true },
{ stat="Block", onupdate=true, events={}, spell=203177, spellclass="Physical", widget={ type="CheckBox" }, options={ Percent_Rating=true, Decimals_Block=true, Cap_Percent=true, Cap_Rating=true  }, subgroup=true },
{ stat="Absorb", onupdate=true, events={}, spell=343744, spellclass="Physical", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true, }, subgroup=true },
{ stat="Stagger", onupdate=true, events={}, spell=280195, spellclass="Physical", widget={ type="CheckBox" }, options={ Show=true, Decimals_Stagger=true }, subgroup=true },
{ stat="Delves", events={ WEEKLY_REWARDS_UPDATE=true, SCENARIO_COMPLETED=true, WALK_IN_DATA_UPDATE=true}, spell=471521, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Editbox_D=true, Display_Delves=true, }, subgroup=true, activeonload=true, },
{ stat="MythicPlus", events={ CHALLENGE_MODE_COMPLETED=true, }, spell=393977, spellclass="Misc", widget={ type="CheckBox" }, options={ Season_Exp=true }, subgroup=true },
{ stat="Karesh", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3129, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Gallagio", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3136, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Cartels", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3120, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Radiance", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3283, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Dornogal", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2897, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Hallowfall", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2899, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Assembly", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2902, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="Severed", onupdate=true, events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2903, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Display_Percentage=true }, subgroup=true },
{ stat="TargetSpeed", onupdate=true, events={}, spell=52358, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="Threat", onupdate=true, events={}, spell=185245, spellclass="Misc", widget={ type="CheckBox" }, options={ Percent_Rating=true, }, subgroup=true },
{ stat="ItemLevel", onupdate=true, events={}, spell=48792, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Equipped_Overall=true, Decimals_iLVL=true }, subgroup=true },
{ stat="PvPiLvl", onupdate=true, events={}, spell=347503, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Decimals_pvpiLVL=true }, subgroup=true },
{ stat="GlobalCD", events={ UNIT_SPELLCAST_SUCCEEDED={ "player" }, }, spell=363929, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, Decimals_Gcd=true }, subgroup=true },
{ stat="Durability", events={ UPDATE_INVENTORY_DURABILITY=true, }, spell=3100, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="Valorstones", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3008, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true, activeonload=true },
{ stat="Weathered", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3285, spellclass="Currency", widget={ type="CheckBox" }, options={ Current_Earned=true, Display_Max=true, Display_Weekly=true }, subgroup=true },
{ stat="Carved", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3287, spellclass="Currency", widget={ type="CheckBox" }, options={ Current_Earned=true, Display_Max=true, Display_Weekly=true  }, subgroup=true },
{ stat="Runed", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3289, spellclass="Currency", widget={ type="CheckBox" }, options={ Current_Earned=true, Display_Max=true, Display_Weekly=true  }, subgroup=true },
{ stat="Gilded", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3290, spellclass="Currency", widget={ type="CheckBox" }, options={ Current_Earned=true, Display_Max=true, Display_Weekly=true  }, subgroup=true },
--{ stat="Puzzling", events={ UNIT_INVENTORY_CHANGED=true, }, item=237502, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true }, subgroup=true },
{ stat="Catalyst", events={ UNIT_INVENTORY_CHANGED=true, }, currency=3269, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true }, subgroup=true },
{ stat="Spark", events={ UNIT_INVENTORY_CHANGED=true, }, item=231756, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Splint_Spark=true, }, subgroup=true },
{ stat="CofferKey", events={ CURRENCY_DISPLAY_UPDATE=true, }, item=3028, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true }, subgroup=true },
{ stat="Stash", events={ WALK_IN_DATA_UPDATE=true, MINIMAP_UPDATE_ZOOM=true, }, item=230935, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="Ethereal", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3278, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Untethered", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3303, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Mementos", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3149, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="KajaCola", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3218, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Empty_Vintage=true, Decimals_Default=true }, subgroup=true },
--{ stat="Plunder", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3139, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Market", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3226, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Crystals", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2815, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Kej", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3056, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Undercoin", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2803, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Iron", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=3090, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Cinder", events={ UNIT_INVENTORY_CHANGED=true, }, item=225557, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true }, subgroup=true },
{ stat="ValorPoints", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=1191, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="BloodyTokens", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2123, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="Honor", events={ CURRENCY_DISPLAY_UPDATE=true, }, spell=269083, spellclass="Currency", widget={ type="CheckBox" }, options={ Level_HonorPoints=true, Display_Rated=true, }, subgroup=true },
{ stat="Conquest", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=1602, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="Timewarped", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=1166, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="TraderTender", events={ CURRENCY_DISPLAY_UPDATE=true, }, currency=2032, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true }, subgroup=true },
{ stat="Lag", onupdate=true, events={}, spell=190447, spellclass="Misc", widget={ type="CheckBox" }, options={ World_Realm=true, }, subgroup=true },
{ stat="FPS", onupdate=true, events={}, updatespeed=1, spell=6196, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
{ stat="Gold", events={ PLAYER_MONEY=true, }, spell=303624, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Display_Gold=true, Decimals_Default=true, }, subgroup=true },
{ stat="WowToken", onupdate=true, events={}, item=122284, spellclass="Currency", widget={ type="CheckBox" }, options={ Show=true, Decimals_Default=true, }, subgroup=true },
--{ stat="RepairCost", events={ UPDATE_INVENTORY_DURABILITY=true, }, spell=52774, spellclass="Misc", widget={ type="CheckBox" }, options={ Show=true, }, subgroup=true },
}

------------------------------
--		Global Events		--
------------------------------
Ns.GlobalEvents = {
	UNIT_AURA={ "player", "target", },
	UNIT_INVENTORY_CHANGED={ "player", },
	UNIT_STATS={ "player", },
	UPDATE_INVENTORY_DURABILITY=true,
	UPDATE_FACTION=true,
	BIND_ENCHANT=true,
	CHARACTER_POINTS_CHANGED=true,
	PLAYER_LEVEL_UP=true,
	PLAYER_TARGET_CHANGED=true,
	REPLACE_ENCHANT=true,
	GET_ITEM_INFO_RECEIVED=true,
	TRAIT_CONFIG_UPDATED=true,
	MASTERY_UPDATE=true,
}

------------------------------
--		Settings Groups		--
------------------------------
Ns.SpellClass = {
	[0] = { stat="Settings", grp=Ns.SettingsGroupOrder, order=Ns.SettingsDisplayOrder, icon="Settings", },
	[1] = { stat="Enhancement", icon="Melee", },
	[2] = { stat="Physical", icon="Defense", },
	[3] = { stat="Spell", icon="Spell", },
	[4] = { stat="Currency", icon="Currency", },
	[5] = { stat="Misc", icon="Misc", },
}

------------------------------
--		Stat Options		--
------------------------------
Ns.Options = {
	{ stat="Show", widget={ type="CheckBox", } },
	{ stat="Enhanced_Base", spellclass="Enhanced_Base", widget={ type="Radio", }, tooltip=true,  default=1, labels={ "Enhanced", "Base", "Both"}, },
	{ stat="Percent_Rating", spellclass="Percent_Rating", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Percentage", "Rating", "Both"}, },
	{ stat="Damage_Taken", spellclass="Damage_Taken", widget={ type="Radio", }, tooltip=true,  default=1, labels={ "Damage", "DamageTaken", "Both"}, },
	{ stat="Melee_Ranged", spellclass="Melee_Ranged", widget={ type="Radio", }, tooltip=true,  default=1, labels={ "Melee", "Ranged", "Both"}, },
	{ stat="Display_Average", spellclass="Display_Average", widget={ type="CheckBox", }, tooltip=true,  default=false, labels={ "Display_Average"}, },
	{ stat="World_Realm", spellclass="World_Realm", widget={ type="Radio", }, tooltip=true,  default=1, labels={ "World", "Realm", "Both"}, },
	{ stat="Equipped_Overall", spellclass="Equipped_Overall", widget={ type="Radio", }, tooltip=true,  default=1, labels={ "Equipped", "Max", "Both"}, },
	{ stat="Level_HonorPoints", spellclass="Level_HonorPoints", widget={ type="Radio", }, tooltip=true,  default=1, labels={ "Level", "Honor", "Both"}, },
	{ stat="Max_Average_Damage", spellclass="Max_Average_Damage", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Max", "Average", "Low"}, },
	{ stat="Current_Earned", spellclass="Current_Earned", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Current", "Earned", "Both"}, },
	{ stat="Display_Rated", spellclass="Display_Rated", widget={ type="CheckBox", }, tooltip=true,  default=false, labels={ "Display_Rated"}, },
	{ stat="Display_Rating", spellclass="Display_Rating", widget={ type="CheckBox", }, tooltip=true,  default=false, labels={ "Display_Rating"}, },
	{ stat="Display_Basic", spellclass="Display_Basic", widget={ type="CheckBox", }, tooltip=true, default=false, labels={ "Display_Basic"}, },
	{ stat="Display_Percentage", spellclass="Display_Percentage", widget={ type="CheckBox", }, tooltip=true, default=false, labels={ "Display_Percentage"}, },
	{ stat="Hide_Reputation", spellclass="Hide_Reputation", widget={ type="CheckBox", }, tooltip=true, default=false, labels={ "Hide_Reputation"}, },
	{ stat="Display_MainHand", spellclass="Display_MainHand", widget={ type="CheckBox", }, tooltip=true, default=false, labels={ "Display_MainHand"}, },
	{ stat="Speed_Static", spellclass="Speed_Static", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Live", "Static", "Both"}, },
	{ stat="Normal_Enchanted", spellclass="Normal_Enchanted", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Normal", "Enchanted", "Both"}, },
	{ stat="Shadow_Ing", spellclass="Shadow_Ing", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Shadowflame", "Ingenuity", "Both"}, },
	{ stat="Season_Exp", spellclass="Season_Exp", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Season", "Expansion", "Both"}, },
	{ stat="Splint_Spark", spellclass="Splint_Spark", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Spark", "Splinter", "Both"}, },
	{ stat="Display_Max", spellclass="Display_Max", widget={ type="CheckBox", }, tooltip=true, default=true, labels={ "Display_Max"}, },
	{ stat="Display_Gold", spellclass="Display_Gold", widget={ type="CheckBox", }, tooltip=false, default=false, labels={ "Display_Gold"}, },
	{ stat="Display_Weekly", spellclass="Display_Weekly", widget={ type="CheckBox", }, tooltip=false, default=false, labels={ "Display_Weekly"}, },
	{ stat="Empty_Vintage", spellclass="Empty_Vintage", widget={ type="Radio", }, tooltip=true, default=1, labels={ "Empty", "Vintage", "Both"}, },
	-- decimals
	{ stat="Decimals_Crit", spellclass="Decimals_Crit", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Haste", spellclass="Decimals_Haste", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Mastery", spellclass="Decimals_Mastery", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Versatility", spellclass="Decimals_Versatility", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Avoidance", spellclass="Decimals_Avoidance", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Leech", spellclass="Decimals_Leech", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Speed", spellclass="Decimals_Speed", default=0, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Damage", spellclass="Decimals_Damage", default=0, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Block", spellclass="Decimals_Block", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Parry", spellclass="Decimals_Parry", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Dodge", spellclass="Decimals_Dodge", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Stagger", spellclass="Decimals_Stagger", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Energy", spellclass="Decimals_Energy", default=1, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_iLVL", spellclass="Decimals_iLVL", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_pvpiLVL", spellclass="Decimals_pvpiLVL", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Gcd", spellclass="Decimals_Gcd", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_DPS", spellclass="Decimals_DPS", default=0, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_WepSpeed", spellclass="Decimals_WepSpeed", default=2, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_DmgMod", spellclass="Decimals_DmgMod", default=0, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_DmgModSpell", spellclass="Decimals_DmgModSpell", default=0, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_Default", spellclass="Decimals_Default", default=0, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	{ stat="Decimals_DR", spellclass="Decimals_DR", default=1, widget={ type="Slider", min=0, max=3, valuestep=1, width=140, } , newline=true, },
	--1{ stat="Stat_Color", spellclass="Stat_Color", default={ r=1, g=1, b=1, }, widget={ type="ColorPicker", } , newline=true, },

	-- caps
	{ stat="Cap_Percent", spellclass="Cap_Percent", default=100, tooltip=true, widget={ type="EditBox", width=60, height=20, numeric=true, format="%.2f%%", }, },
	{ stat="Cap_Rating", spellclass="Cap_Rating", default=0, tooltip=true, widget={ type="EditBox", width=60, height=20, numeric=true, format="%.2f", }, },
	{ stat="Editbox_D", spellclass="Editbox_D", default=8, tooltip=true, widget={ type="EditBox", width=60, height=20, numeric=true, format="%.0f", }, },
	{ stat="Display_Delves", spellclass="Display_Delves", widget={ type="CheckBox", }, tooltip=false, default=false, labels={ "Display_Delves"}, },
}

--------------------------
--		Class & ID		--
--------------------------
Ns.byPlayerClass = {
--10.0 DF
	["EVOKER"] = 13,
--7.0 Legion
	["DEMONHUNTER"] = 12,
--5.0 Pandaria
	["MONK"] = 10,
--3.0 Wrath
	["DEATHKNIGHT"] = 6,
--1.0 Classic
	["DRUID"] = 11,
	["HUNTER"] = 3,
	["MAGE"] = 8,
	["PALADIN"] = 2,
	["PRIEST"] = 5,
	["ROGUE"] = 4,
	["SHAMAN"] = 7,
	["WARLOCK"] = 9,
	["WARRIOR"] = 1,
}

------------------------------
--		Class defaults		--
------------------------------
function Ns:GetClassDefaults(class)
	local defaults = {
--10.0 DF
		EVOKER = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			ManaRegen = true,
			SpellPower = true,
			Healing = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
--7.0 Legion
		DEMONHUNTER  = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Leech = true,
			Strength = true,
			AP = true,
			DMG = true,
			Armor = true,
			Absorb = true,
			Dodge = true,
			Speed = true,
			Durability = true,
		},
--5.0 Panda
		MONK = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Stagger = true,
			AP = true,
			Agility = true,
			Armor = true,
			Absorb = true,
			Dodge = true,
			Speed = true,
			Durability = true,
		},
--3.0 Wrath
		DEATHKNIGHT = { -- setup will check the stat. exists for game version being played
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Leech = true,
			AP = true,
			Strength = true,
			Armor = true,
			Parry = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
--1.0 Classic
		DRUID = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			AP = true,
			SpellPower = true,
			Intellect = true,
			ManaRegen = true,
			EnergyRegen = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
		HUNTER = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Agility = true,
			Mastery = true,
			AP = true,
			Speed = true,
			Durability = true,
		},
		MAGE = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Intellect = true,
			SpellPower = true,
			ManaRegen = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
		PALADIN = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Intellect = true,
			ManaRegen = true,
			Healing = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
		PRIEST = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Intellect = true,
			ManaRegen = true,
			SpellPower = true,
			Healing = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
		ROGUE = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Agility = true,
			AP = true,
			EnergyRegen = true,
			Dodge = true,
			Speed = true,
			Durability = true,
		},
		SHAMAN = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Intellect = true,
			ManaRegen = true,
			SpellPower = true,
			Healing = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
		WARLOCK = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Intellect = true,
			SpellPower = true,
			Absorb = true,
			Speed = true,
			Durability = true,
		},
		WARRIOR = {
			Haste = true,
			Versatility = true,
			CritChance = true,
			Mastery = true,
			Strength = true,
			AP = true,
			Armor = true,
			Absorb = true,
			Block = true,
			Dodge = true,
			Speed = true,
			Durability = true,
		},
	}
	return class and defaults[strupper(class)] or defaults
end