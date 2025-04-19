local AddName, Ns = ...

local L = Ns.RegisterLocale("enUS", true)

-- SinLive abilities
L["ScalingText"] = Ns.Colors.Green .. "\nTarget Debuff Scaling |r\n"
L["ScalingText2"] = Ns.Colors.Green .. "\nTarget Scaling: |r"
L["TipsAndInfo"] = Ns.Colors.Green .. "Tips and Info!|r\n\n"
L["SinLive"] = Ns.Colors.Green .. "SinLive™ Stat\nThis stat is interactive and scales with your target|r\n\n"
L["NPCAnyLevel"] = "Target level"
L["DefaultValueText"] = Ns.Colors.Green .. "\n\nDefault value:|r  "
L["NPCSameLevel"] = "Player level"

-- Tooltips
L["Enhanced_BaseTooltip"] = Ns.Colors.Green .. "Enhanced|r\n" .. "Provides the best accuracy by adding \ntalents, buffs, debuffs, flasks, gems, \nenchants and other sources \n\n" .. Ns.Colors.Green .. "Basic|r\n" .. "Displays the stat as is, without additions \nand may not be the most accurate"
L["Percent_RatingTooltip"] = Ns.Colors.Green .. "Percentage|r\n" .. "Displays the stat in percentage \n\n" .. Ns.Colors.Green .. "Rating|r\n" .. "Displays the rating value"
L["Regen_Normal_CastingTooltip"] = Ns.Colors.Green .. "Normal|r\n" .. "Mana regeneration while not casting \n\n" .. Ns.Colors.Green .. "Casting|r\n" .. "Mana regeneration while casting"
L["World_RealmTooltip"] = Ns.Colors.Green .. "Realm|r\n" .. "Average latency from your computer to \nthe Blizzard server in milliseconds\n\n" .. Ns.Colors.Green .. "World|r\n" .. "In-game latency from your computer to \nthe Game World"
L["Melee_RangedTooltip"] = Ns.Colors.Green .. "Melee|r\n" .. "Displays your melee weapon value \n\n" .. Ns.Colors.Green .. "Ranged|r\n" .. "Displays your ranged weapon value"
L["Equipped_OverallTooltip"] = Ns.Colors.Green .. "Equipped|r\n" .. "Average item level of your \nequipped gear \n\n" .. Ns.Colors.Green .. "Max|r\n" .. "Max item level of all your \ngear, including in bags"
L["Max_Average_DamageTooltip"] = Ns.Colors.Green .. "Max, Average and Low|r\n" .. "Displays your full damage range"
L["Damage_TakenTooltip"] = Ns.Colors.Green .. "Offense|r\n" .. "Increase in damage and healing done \n\n" .. Ns.Colors.Green .. "Defense|r\n" .. "Reduction in damage taken"
L["Level_HonorPointsTooltip"] = Ns.Colors.Green .. "Level|r\n" .. "Your current Honor level \n\n" .. Ns.Colors.Green .. "Points|r\n" .. "Your total honor earned"
L["Speed_StaticTooltip"] = Ns.Colors.Green .. "Real-time|r\n" .. "Displays the movement speed of your character's \nevery movement, in real-time (Standing, running, \nswimming, flying, RP walking, Skyriding etc.) \n\n" .. Ns.Colors.Green .. "Static|r\n" .. "Your character's movement speed is static and \nwill change only when traveling methods change \nor speed value increases"
L["Normal_EnchantedTooltip"] = Ns.Colors.Green .. "Normal|r\n" .. "Displays the item's total quantity, including \nin your bags and bank \n\n" .. Ns.Colors.Green .. "Enchanted|r\n" .. "Displays the Enchanted item's quantity, \nincluding in your bags and bank"
L["Season_ExpTooltip"] = Ns.Colors.Green .. "Season|r\n" .. "Displays your Mythic+ rating of \nthe current season \n\n" .. Ns.Colors.Green .. "Expansion|r\n" .. "Displays your best Mythic+ rating \nof the current expansion"
L["Splint_SparkTooltip"] = Ns.Colors.Green .. "Spark|r\n" .. "Displays the total quantity of \nSpark of Fortunes \n\n" .. Ns.Colors.Green .. "Fractured|r\n" .. "Displays the total quantity of \nFractured Spark of Fortunes"
L["Current_EarnedTooltip"] = Ns.Colors.Green .. "Current|r\n" .. "Displays the current quantity \n\n" .. Ns.Colors.Green .. "Earned|r\n" .. "Displays the total earned \nthis season"
L["Empty_VintageTooltip"] = Ns.Colors.Green .. "Empty|r\n" .. "Displays the quanity of \nEmpty Kaja'Cola Cans \n\n" .. Ns.Colors.Green .. "Vintage|r\n" .. "Displays the quantity of \nVintage Kaja'Cola Cans"

L["Display_AverageTooltip"] = Ns.Colors.Green .. "Average|r\n" .. "Switches from maximum to \naverage values"
L["Display_BasicTooltip"] = Ns.Colors.Green .. "Basic|r\n" .. "Displays the stat as is, without additions \nand may not be the most accurate"
L["Display_RatedTooltip"] = Ns.Colors.Green .. "Rated|r\n" .. "Displays your rated Honor"
L["Display_RatingTooltip"] = Ns.Colors.Green .. "Rating|r\n" .. "Displays the rating value"
L["Display_MainHandTooltip"] = Ns.Colors.Green .. "Main-Hand Only|r\n" .. "Disables the automatic \ndisplay of the Off-hand \nvalue if applicable"
L["Hide_ReputationTooltip"] = Ns.Colors.Green .. "Hide Maxed Reputation|r\n" .. "Hides the Renown level of a faction \nwhen maxed out"
L["Display_PercentageTooltip"] = Ns.Colors.Green .. "Progression|r\n" .. "Displays the percentage \nof progression"
L["Display_MythicBestTooltip"] = Ns.Colors.Green .. "Top score|r\n" .. "Displays your top Mythic+ score of the current expansion"
L["Display_MaxTooltip"] = Ns.Colors.Green .. "Cap color|r\n" .. "Colors your quantity in red \nwhen the weekly cap of this \ncurrency is reached"

-- Stats
L["CritChance"] = "Crit"
L["CritChanceAbrev"] = "Crit"
L["CritChanceMenu"] = "Critical Strike"
L["CritChanceTip"] = ""
L["CritChanceDescription"] = L["SinLive"] .. L["ScalingText"] .. Ns.BetEyesLink

L["Haste"] = "Haste"
L["HasteAbrev"] = "Has"
L["HasteMenu"] = "Haste"
L["HasteTip"] = ""
L["HasteDescription"] = ""

L["Mastery"] = "Mastery"
L["MasteryAbrev"] = "Mas"
L["MasteryMenu"] = "Mastery"
L["MasteryTip"] = ""
L["MasteryDescription"] = ""

L["Versatility"] = "Versatility"
L["VersatilityAbrev"] = "Vers"
L["VersatilityMenu"] = "Versatility"
L["VersatilityTip"] = ""
L["VersatilityDescription"] = ""

L["Avoidance"] = "Avoidance"
L["AvoidanceAbrev"] = "Avo"
L["AvoidanceMenu"] = "Avoidance"
L["AvoidanceTip"] = ""
L["AvoidanceDescription"] = ""

L["Leech"] = "Leech"
L["LeechAbrev"] = "Lee"
L["LeechMenu"] = "Leech"
L["LeechTip"] = ""
L["LeechDescription"] = ""

L["Strength"] = "Strength"
L["StrengthAbrev"] = "Str"
L["StrengthMenu"] = "Strength"
L["StrengthTip"] = ""
L["StrengthDescription"] = L["TipsAndInfo"] .. "A red " .. Ns.Colors.Red .. "Strength|r value indicates that you are affected by a debuff \n"

L["Agility"] = "Agility"
L["AgilityAbrev"] = "Agi"
L["AgilityMenu"] = "Agility"
L["AgilityTip"] = ""
L["AgilityDescription"] = L["TipsAndInfo"] .. "A red " .. Ns.Colors.Red .. "Agility|r value indicates that you are affected by a debuff \n"

L["AP"] = "AP"
L["APAbrev"] = "AP"
L["APMenu"] = "Attack Power"
L["APTip"] = ""
L["APDescription"] = L["TipsAndInfo"] .. "A red " .. Ns.Colors.Red .. "Attack Power|r value indicates that you are affected by a debuff \n"

L["DMG"] = "Damage"
L["DMGAbrev"] = "DMG"
L["DMGMenu"] = "Damage"
L["DMGTip"] = ""
L["DMGDescription"] = L["SinLive"] .. "A red " .. Ns.Colors.Red .. "Damage|r value indicates that you are affected by a debuff \n" .. L["ScalingText"] .. Ns.ColSmashLink .. Ns.FelSunLink .. Ns.MystTouchLink .. Ns.JadefireLink .. Ns.BrittleLink .. Ns.FinalReckLink .. "\n" .. Ns.GhostlyStrikeLink .. Ns.HuntersMarkLink .. Ns.RazorLink

L["DPS"] = "DPS"
L["DPSAbrev"] = "DPS"
L["DPSMenu"] = "DPS"
L["DPSTip"] = ""
L["DPSDescription"] = L["SinLive"] .. L["ScalingText"] .. Ns.ColSmashLink .. Ns.FelSunLink .. Ns.MystTouchLink .. Ns.JadefireLink .. Ns.BrittleLink .. Ns.GhostlyStrikeLink .. "\n" .. Ns.HuntersMarkLink

L["DMGMod"] = "DMG+"
L["DMGModAbrev"] = "DMG+"
L["DMGModMenu"] = "Damage Bonus"
L["DMGModTip"] = ""
L["DMGModDescription"] = L["SinLive"] .. "Physical damage bonus \n" .. L["ScalingText"] .. Ns.ColSmashLink .. Ns.FelSunLink .. Ns.MystTouchLink .. Ns.JadefireLink .. Ns.BrittleLink .. Ns.FinalReckLink .. "\n" .. Ns.GhostlyStrikeLink .. Ns.HuntersMarkLink .. Ns.RazorLink

L["weaponSpeed"] = "Atk Speed"
L["weaponSpeedAbrev"] = "As"
L["weaponSpeedMenu"] = "Weapon Speed"
L["weaponSpeedTip"] = ""
L["weaponSpeedDescription"] = L["TipsAndInfo"] .. "This stat automatically detects your weapon type and display its value accordingly"

L["EnergyRegen"] = "Energy"
L["EnergyRegenAbrev"] = "EnR"
L["EnergyRegenMenu"] = "Energy Regen"
L["EnergyRegenTip"] = ""
L["EnergyRegenDescription"] = ""

L["Stamina"] = "Stamina"
L["StaminaAbrev"] = "Sta"
L["StaminaMenu"] = "Stamina"
L["StaminaTip"] = ""
L["StaminaDescription"] = L["TipsAndInfo"] .. "A red " .. Ns.Colors.Red .. "Stamina|r value indicates that you are affected by a debuff"

L["Mitigation"] = "DR"
L["MitigationAbrev"] = "DR"
L["MitigationMenu"] = "Mitigation"
L["MitigationTip"] = ""
L["MitigationDescription"] = L["SinLive"] .. "Damage Reduction against attackers of all levels \n" .. L["DefaultValueText"] .. L["NPCSameLevel"] .. L["ScalingText2"] .. L["NPCAnyLevel"]

L["Armor"] = "Armor"
L["ArmorAbrev"] = "Arm"
L["ArmorMenu"] = "Armor"
L["ArmorTip"] = ""
L["ArmorDescription"] = L["TipsAndInfo"] .. "A red " .. Ns.Colors.Red .. "Armor|r value indicates that you are affected by a debuff"

L["Dodge"] = "Dodge"
L["DodgeAbrev"] = "Dod"
L["DodgeMenu"] = "Dodge"
L["DodgeTip"] = ""
L["DodgeDescription"] = ""

L["Parry"] = "Parry"
L["ParryAbrev"] = "Par"
L["ParryMenu"] = "Parry"
L["ParryTip"] = ""
L["ParryDescription"] = ""

L["Block"] = "Block"
L["BlockAbrev"] = "Blo"
L["BlockMenu"] = "Block"
L["BlockTip"] = ""
L["BlockDescription"] = ""

L["Absorb"] = "Absorb"
L["AbsorbAbrev"] = "Abs"
L["AbsorbMenu"] = "Absorb"
L["AbsorbTip"] = ""
L["AbsorbDescription"] = ""

L["Stagger"] = "Stagger"
L["StaggerAbrev"] = "Stag"
L["StaggerMenu"] = "Stagger"
L["StaggerTip"] = ""
L["StaggerDescription"] = ""

L["Intellect"] = "Intellect"
L["IntellectAbrev"] = "Int"
L["IntellectMenu"] = "Intellect"
L["IntellectTip"] = ""
L["IntellectDescription"] = L["TipsAndInfo"] .. "A red " .. Ns.Colors.Red .. "Intellect|r text indicates that you are affected by a debuff \n"

L["SpellPower"] = "Spell"
L["SpellPowerAbrev"] = "Sp"
L["SpellPowerMenu"] = "Spell Power"
L["SpellPowerTip"] = ""
L["SpellPowerDescription"] = L["SinLive"] .. L["ScalingText"] .. Ns.ChaosBrandLink .. Ns.FelSunLink .. Ns.ShatStarLink .. Ns.EradicLink .. "\n" .. Ns.WanTwilightLink .. Ns.HuntersMarkLink

L["DMGModSpell"] = "Spell+"
L["DMGModSpellAbrev"] = "Sp+"
L["DMGModSpellMenu"] = "Damage Bonus"
L["DMGModSpellTip"] = ""
L["DMGModSpellDescription"] = L["SinLive"] .. "Spell damage bonus \n" .. L["ScalingText"] .. Ns.ChaosBrandLink .. Ns.FelSunLink .. Ns.ShatStarLink .. Ns.EradicLink .. "\n" .. Ns.WanTwilightLink .. Ns.HuntersMarkLink

L["Healing"] = "Healing"
L["HealingAbrev"] = "Heal"
L["HealingMenu"] = "Healing Power"
L["HealingTip"] = ""
L["HealingDescription"] = ""

L["ManaRegen"] = "Mana"
L["ManaRegenAbrev"] = "MR"
L["ManaRegenMenu"] = "Mana Regen"
L["ManaRegenTip"] = ""
L["ManaRegenDescription"] = ""

L["Durability"] = "Dura"
L["DurabilityAbrev"] = "Dur"
L["DurabilityMenu"] = "Durability"
L["DurabilityTip"] = ""
L["DurabilityDescription"] = L["TipsAndInfo"] .. "Durability percentage of your currently equipped gear and weapons"

L["RepairCost"] = "Repair"
L["RepairCostAbrev"] = "Rep"
L["RepairCostMenu"] = "Repair Cost"
L["RepairCostTip"] = ""
L["RepairCostDescription"] = L["TipsAndInfo"] .. "Total repair cost"

L["Speed"] = "Speed"
L["SpeedAbrev"] = "Spe"
L["SpeedMenu"] = "Speed"
L["SpeedTip"] = ""
L["SpeedDescription"] = L["TipsAndInfo"] .. "Your character's movement speed in real-time, including your " .. Ns.Colors.Green .. "Skyriding speed|r.\n\nA red " .. Ns.Colors.Red .. "Speed|r value indicates that you are affected by slowing effects or moving at a slower speed than normal"

L["Gallagio"] = "Galla"
L["GallagioAbrev"] = "Glc"
L["GallagioMenu"] = "Gallagio Loyalty"
L["GallagioTip"] = ""
L["GallagioDescription"] = L["TipsAndInfo"] .. "Displays the renown rank of " .. Ns.GallaLink

L["Cartels"] = "Cartel"
L["CartelsAbrev"] = "Car"
L["CartelsMenu"] = "Cartels Undermine"
L["CartelsTip"] = ""
L["CartelsDescription"] = L["TipsAndInfo"] .. "Displays the renown rank of " .. Ns.CartelLink

L["Dornogal"] = "Dorno"
L["DornogalAbrev"] = "Dor"
L["DornogalMenu"] = "Dornogal"
L["DornogalTip"] = ""
L["DornogalDescription"] = L["TipsAndInfo"] .. "Displays the renown rank of " .. Ns.DonorLink

L["Hallowfall"] = "Hallow"
L["HallowfallAbrev"] = "Hfa"
L["HallowfallMenu"] = "Hallowfall Arathi"
L["HallowfallTip"] = ""
L["HallowfallDescription"] = L["TipsAndInfo"] .. "Displays the renown rank of " .. Ns.HalloLink

L["Assembly"] = "Deeps"
L["AssemblyAbrev"] = "Asb"
L["AssemblyMenu"] = "The Assembly"
L["AssemblyTip"] = ""
L["AssemblyDescription"] = L["TipsAndInfo"] .. "Displays the renown rank of " .. Ns.AssemLink

L["Severed"] = "Severed"
L["SeveredAbrev"] = "Tst"
L["SeveredMenu"] = "Severed Threads"
L["SeveredTip"] = ""
L["SeveredDescription"] = L["TipsAndInfo"] .. "Displays the renown rank of " .. Ns.SevereLink

L["TargetSpeed"] = "Target Speed"
L["TargetSpeedAbrev"] = "Spe+"
L["TargetSpeedMenu"] = "Target Speed"
L["TargetSpeedTip"] = ""
L["TargetSpeedDescription"] = L["TipsAndInfo"] .. "The current movement speed of your target, in real-time\n\n" .. Ns.Colors.Red .. "Speed|r value in red indicates that your target is affected by slowing effects or moving at a slower speed than normal"

L["ItemLevel"] = "iLevel"
L["ItemLevelAbrev"] = "iLvl"
L["ItemLevelMenu"] = "Item Level"
L["ItemLevelTip"] = ""
L["ItemLevelDescription"] = L["TipsAndInfo"] .. "Average item level"

L["Threat"] = "Threat"
L["ThreatAbrev"] = "Thr"
L["ThreatMenu"] = "Threat"
L["ThreatTip"] = ""
L["ThreatDescription"] = L["TipsAndInfo"] .. "Threat against current target in percentage, value or both"

L["PvPiLvl"] = "PvP iLvl"
L["PvPiLvlAbrev"] = "PLvl"
L["PvPiLvlMenu"] = "PvP Item Level"
L["PvPiLvlTip"] = ""
L["PvPiLvlDescription"] = L["TipsAndInfo"] .. "Player vs player item level"

L["GlobalCD"] = "Gcd"
L["GlobalCDAbrev"] = "Gcd"
L["GlobalCDMenu"] = "Global CD"
L["GlobalCDTip"] = ""
L["GlobalCDDescription"] = L["TipsAndInfo"] .. "Global cooldown"

L["BloodyTokens"] = "Bloody"
L["BloodyTokensAbrev"] = "BT"
L["BloodyTokensMenu"] = "Bloody Tokens"
L["BloodyTokensTip"] = ""
L["BloodyTokensDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.BloodyLink

L["Honor"] = "Honor"
L["HonorAbrev"] = "Hon"
L["HonorMenu"] = "Honor"
L["HonorTip"] = ""
L["HonorDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.HonorLink

L["Valorstones"] = "Stones"
L["ValorstonesAbrev"] = "Vs"
L["ValorstonesMenu"] = "Valorstones"
L["ValorstonesTip"] = ""
L["ValorstonesDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.ValorLink

L["Weathered"] = "Weath"
L["WeatheredAbrev"] = "Whc"
L["WeatheredMenu"] = "Weathered Crest"
L["WeatheredTip"] = ""
L["WeatheredDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.WeathLink

L["Carved"] = "Carved"
L["CarvedAbrev"] = "Chc"
L["CarvedMenu"] = "Carved Crest"
L["CarvedTip"] = ""
L["CarvedDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CarvedLink

L["Runed"] = "Runed"
L["RunedAbrev"] = "Rhc"
L["RunedMenu"] = "Runed Crest"
L["RunedTip"] = ""
L["RunedDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.RunedLink

L["Gilded"] = "Gilded"
L["GildedAbrev"] = "Ghc"
L["GildedMenu"] = "Gilded Crest"
L["GildedTip"] = ""
L["GildedDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.GildedLink

L["Catalyst"] = "Catalyst"
L["CatalystAbrev"] = "Cat"
L["CatalystMenu"] = "Catalyst"
L["CatalystTip"] = ""
L["CatalystDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CatalystLink

L["CofferKey"] = "Key"
L["CofferKeyAbrev"] = "Key"
L["CofferKeyMenu"] = "Coffer Key"
L["CofferKeyTip"] = ""
L["CofferKeyDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CofferLink

L["Stash"] = "Stash"
L["StashAbrev"] = "Stash"
L["StashMenu"] = "Gilded Stash"
L["StashTip"] = ""
L["StashDescription"] = L["TipsAndInfo"] .. "Displays the quantity of looted " .. Ns.StashLink

L["Spark"] = "Spark"
L["SparkAbrev"] = "Spk"
L["SparkMenu"] = "Spark Fortunes"
L["SparkTip"] = ""
L["SparkDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.SparkLink .. "Spark of Fortunes"

L["Undercoin"] = "Coin"
L["UndercoinAbrev"] = "Coin"
L["UndercoinMenu"] = "Undercoin"
L["UndercoinTip"] = ""
L["UndercoinDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CoinLink

L["Cinder"] = "Pollen"
L["CinderAbrev"] = "Pol"
L["CinderMenu"] = "Cinderpollen"
L["CinderTip"] = ""
L["CinderDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CinderLink .. "Sizzling Cinderpollen"

L["Iron"] = "Iron"
L["IronAbrev"] = "Iro"
L["IronMenu"] = "Flame-Blessed"
L["IronTip"] = ""
L["IronDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.IronLink

L["KajaCola"] = "Cola"
L["KajaColaAbrev"] = "Col"
L["KajaColaMenu"] = "Kaja'Cola"
L["KajaColaTip"] = ""
L["KajaColaDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.KajaLink .. " & " .. Ns.VintageLink

L["Market"] = "Market"
L["MarketAbrev"] = "Mar"
L["MarketMenu"] = "Market Research"
L["MarketTip"] = ""
L["MarketDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.MarketLink

L["Crystals"] = "Crystals"
L["CrystalsAbrev"] = "Rcr"
L["CrystalsMenu"] = "Crystals"
L["CrystalsTip"] = ""
L["CrystalsDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CrystalLink

L["Kej"] = "Kej"
L["KejAbrev"] = "Kej"
L["KejMenu"] = "Kej"
L["KejTip"] = ""
L["KejDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.KejLink

L["ValorPoints"] = "Valor"
L["ValorPointsAbrev"] = "Val"
L["ValorPointsMenu"] = "Valor"
L["ValorPointsTip"] = ""
L["ValorPointsDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.ValorPvPLink

L["Conquest"] = "Conquest"
L["ConquestAbrev"] = "Conq"
L["ConquestMenu"] = "Conquest"
L["ConquestTip"] = ""
L["ConquestDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.ConqLink

L["Celebration"] = "Bronze"
L["CelebrationAbrev"] = "Bct"
L["CelebrationMenu"] = "Celebration"
L["CelebrationTip"] = ""
L["CelebrationDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.CelebLink

L["Timewarped"] = "Timewarped"
L["TimewarpedAbrev"] = "TWb"
L["TimewarpedMenu"] = "Timewarped"
L["TimewarpedTip"] = ""
L["TimewarpedDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.TimeLink

L["TraderTender"] = "Trader"
L["TraderTenderAbrev"] = "Trt"
L["TraderTenderMenu"] = "Trader's Tender"
L["TraderTenderTip"] = ""
L["TraderTenderDescription"] = L["TipsAndInfo"] .. "Displays the currency " .. Ns.TenderLink

L["Delves"] = "Delves"
L["DelvesAbrev"] = "Del"
L["DelvesMenu"] = "Delves"
L["DelvesTip"] = ""
L["DelvesDescription"] = L["TipsAndInfo"] .. "Displays the number of completed Delves runs on the Great Vault \nSelect the Tier to track or track only Tier 8 completed runs and above"

L["MythicPlus"] = "Mythic+"
L["MythicPlusAbrev"] = "M+"
L["MythicPlusMenu"] = "Mythic+ Rating"
L["MythicPlusTip"] = ""
L["MythicPlusDescription"] = L["TipsAndInfo"] .. "Displays your Mythic+ rating for the current season or your expansion's best rating"

L["Lag"] = "Ping"
L["LagAbrev"] = "Ping"
L["LagMenu"] = "Ping"
L["LagTip"] = ""
L["LagDescription"] = L["TipsAndInfo"] .. "Connection latency (Ping)"

L["FPS"] = "FPS"
L["FPSAbrev"] = "FPS"
L["FPSMenu"] = "FPS"
L["FPSTip"] = ""
L["FPSDescription"] = L["TipsAndInfo"] .. "Frames per second [FPS]"

L["Gold"] = "Gold"
L["GoldAbrev"] = "G"
L["GoldMenu"] = "Money"
L["GoldTip"] = ""
L["GoldDescription"] = L["TipsAndInfo"] .. "Total amount of money in your character's possession"

L["WowToken"] = "Token"
L["WowTokenAbrev"] = "WT"
L["WowTokenMenu"] = "WoW Token"
L["WowTokenTip"] = ""
L["WowTokenDescription"] = L["TipsAndInfo"] .. "Live value of the WoW Token in your region"

------------------
--    Config    --
------------------

-- Categories
L["HUDMenu"] = "HUD"
L["FontsMenu"] = "Fonts"
L["DisplayMenu"] = "Display"
L["DisplayOrderMenu"] = "Layout"
L["EventsMenu"] = "Events"
L["ProfilesMenu"] = "Profiles"
L["FAQMenu"] = "FAQ"
L["Settings"] = "Settings"
L["SettingsDescription"] = ""
L["Physical"] = "Physical"
L["PhysicalDescription"] = ""
L["Enhancement"] = "Enhancement"
L["EnhancementDescription"] = ""
L["Spell"] = "Spell"
L["SpellDescription"] = ""
L["Misc"] = "Misc"
L["MiscDescription"] = ""
L["Currency"] = "Currency"
L["CurrencyDescription"] = ""

-- HUD
L["SettingsDescription"] = ""
L["HideHUD"] = "Hide"
L["HideHUDTip"] = Ns.HideIcon.. "Hide stats HUD"
L["LockHUD"] = "Lock"
L["LockHUDTip"] = Ns.LockIcon .. "Lock stats HUD"
L["PanelDisplay"] = "Attach"
L["PanelDisplayTip"] = Ns.AttachIcon.. "Character Panel"
L["PanelShow"] = "Auto Show"
L["PanelShowTip"] = Ns.AttachIcon.. "Character Panel Stats (Cataclysm)"
L["HUDBgColor"] = ""
L["HUDBgColorTip"] = Ns.BackgroundIcon .. "Background Color"
L["HUDBgAlpha"] = ""
L["HUDBgAlphaTip"] = Ns.BackgroundIcon .. "Background Alpha"
L["ResetPosition"] = "Reset HUD Position"
L["ResetPositionTip"] = "Reset the stats HUD's position"
L["HUDStrataTip"] = Ns.StrataIcon.. "Frame Strata"
L["MinimapGroupText"] = "Minimap"
L["Minimap"] = "Show"
L["MinimapTip"] = Ns.MiniMenuIcon .. "Minimap Button"
L["CompButton"] = "Show"
L["CompButtonTip"] = Ns.CompIcon .. "Compartment Button"
L["Lowest"] = "Lowest"
L["Low"] = "Low"
L["Medium"] = "Medium"
L["High"] = "High"
L["Highest"] = "Highest"

-- Fonts
L["StatFontTip"] = Ns.FontsIcon .. "Fonts"
L["StatFontSizeTip"] = Ns.FontSizeIcon .. "Font Size"
L["StatFontFlagsTip"] = Ns.OutlineIcon .. "Outline"
L["Default Font"] = "Arial Narrow"
L["Thin"] = "Thin"
L["Thick"] = "Thick"
L["Monochrome"] = "Monochrome"
L["Thin Monochrome"] = "Thin Monochrome"
L["Thick Monochrome"] = "Thick Monochrome"
L["None"] = "None"

-- Display
L["StatIconsTip"] = Ns.ToggleIconsIcon .. "Toggle icons on stats"
L["StatIcons"] = "Show Icons"
L["StatTextAbreviateTip"] = Ns.AbbreviateIcon .. "Abbreviate stat names"
L["StatTextAbreviate"] = "Abbreviate   "
L["StatTextCapsTip"] = Ns.CapsIcon .. "Toggle text caps"
L["StatTextCaps"] = "Uppercase"
L["StatTextColorTip"] = Ns.TextColorIcon .. "Text color: Name"
L["StatTextColor"] = ""
L["ClassColorsTip"] = Ns.TextColorIcon .. "Text color: Name"
L["ClassColors"] = "Class Color"
L["AlignmentText"] = "Alignment and Spacing"
L["StatWidthTip"] = Ns.WidthStringIcon .. "Text: Width"
L["StatWidthTooltip"] = Ns.Colors.Green .. "Text string width|r\n" .. "Adjust the text string width to fit your stats \nIncrease the width to create more space if \na text is truncated (...) \n\nThis option is disabled when displaying your \nstats on 1 row or on 1 column"
L["StatSpacingHTip"] = Ns.WidthIcon .. "Spacing: Width"
L["StatSpacingVTip"] = Ns.HeightIcon .. "Spacing: Height"
L["StatAlignmentTip"] = Ns.AlignIcon .. "Alignment: Text"
L["IconAlignmentTip"] = Ns.AlignIcon .. "Alignment: Icons"
L["DataColor"] = ""
L["DataColorTip"] = Ns.ValueColorIcon .. "Text color: Value"
L["SplitColors"] = "Enable"
L["SplitColorsTip"] = Ns.ValueColorIcon .. "Text color: Value"
L["SplitColorsTooltip"] = Ns.Colors.Green .. "Value text color|r\n" .. "Enabling this option will allow stat \nvalues to be set in a different color \nfrom the stat name \n\nUse the" .. Ns.Colors.Green .. " Text color (Value)|r color \npicker to set a color"
L["Left"] = "Left"
L["Right"] = "Right"
L["Center"] = "Center"
L["TextSeparatorTip"] = Ns.SeparatorIcon .. "Separator"

-- Layout
L["ClearAllColumns"] = "Reset"
L["Rows"] = "Row Presets"
L["Columns"] = "Column Presets"
L["OneRow"] = "1"
L["TwoRows"] = "2"
L["ThreeRows"] = "3"
L["FourRows"] = "4"
L["DisplayOrderDescription"] = ""
L["StatOrderSettingsTooltip"] = Ns.Colors.Green .. "Stats Order|r\n" .. "Customize the order in which the stats are displayed \nSimply drag and drop the stats below \n\n" .. Ns.Colors.Green .. "Columns|r\n" .. "Selecting a checkbox next to a stat will create a new \ncolumn with the selected stat and the stats below it. \n\124T" .. "Interface\\AddOns\\"..AddName.."\\Textures\\" .."CheckColumn:0:0:0:0:16:16:0:16:0:16:112:255:201\124t marks the start of a new column \n\n" .. Ns.Colors.Green .. "Row and Column Presets|r\n" .. "Select a preset layout composed of up to 4 rows or \ncolumns. This option helps to quickly create a layout. \nRows and Columns can also be created manually \n\nPress Apply when done"

-- FAQ
L["FAQFirst"] = Ns.MiscIcon .. Ns.Colors.Green .. "Some of the stats' text is truncated (...)|r\n\n " .. Ns.SettingsIcon .. "Settings >> " .. Ns.DisplayIcon .. "Display >> " .. Ns.SpacingIcon .. "Spacing & Alignment: Adjust the " .. Ns.WidthStringIcon .. Ns.Colors.Green .. "Text: Width|r slider"
L["FAQSecond"] = Ns.MiscIcon .. Ns.Colors.Green .. "How to display the stats in columns or rows|r\n\n " .. Ns.SettingsIcon .. "Settings >> " .. Ns.LayoutIcon .. "Layout: Mouse-over its " .. Ns.MiscIcon .. "icon for more details"
L["FAQThird"] = Ns.MiscIcon .. Ns.Colors.Green .. "How to display the stats on one single row|r\n\n " .. Ns.SettingsIcon .. "Settings >> " .. Ns.LayoutIcon .. "Layout: Click the 1 button in " .. Ns.Colors.Green .. "Row Presets|r or manually by activating all the " .. Ns.ColumnIcon .. "checkboxes next to each stats"
L["FAQForth"] = Ns.MiscIcon .. Ns.Colors.Green .. "How to re-order the stats|r\n\n " .. Ns.SettingsIcon .. "Settings >> " .. Ns.LayoutIcon .. "Layout: Drag and drop the stats on the list"
L["FAQFifth"] = Ns.MiscIcon .. Ns.Colors.Green .. "How to enable stats in-combat only or in other specific situations|r\n\n " .. Ns.SettingsIcon .. "Settings >> " .. Ns.EventsIcon .. "Events: Make the stats only visible in the selected events"

-- Events
L["EventEnable"] = "Enable"
L["EventEnableTip"] = "HUD Events"
L["EventEnableTooltip"] = Ns.Colors.Green .. "HUD Events|r\n" .. "Make your stats strictly visible in the \nevent(s) below. \nYour stats will be hidden otherwise \n\nCombat has a higher priority"
L["EventWorld"] = "Open World"
L["EventWorldTip"] = Ns.Colors.Green .. "Show stats only while in"
L["EventDungeon"] = "Dungeons"
L["EventDungeonTip"] = ""
L["EventRaid"] = "Raids"
L["EventRaidTip"] = ""
L["EventPvP"] = "Battlegrounds"
L["EventPvPTip"] = ""
L["EventArena"] = "Arena"
L["EventArenaTip"] = ""
L["EventCombat"] = "Combat"
L["EventCombatTip"] = ""

-- Minimap
L["QuickAccess"] = "Quick Access"
L["OpenSettings"] = "Open Settings"
L["EnableDisable"] = "Enable/Disable HUD"
L["ShiftRightClick"] = "+ Shift"
L["UnlockHUD"] = "Lock/Unlock HUD"

-- Settings Profile
L["Selected"] = "Apply"
L["SelectProfile"] = "Manage your profiles: Select, Create, Copy or Delete \nProfiles used by a character cannot be deleted"
L["ProfileSelected"] = "Profiles"
L["ProfileUsed"] = "Profile is currently in use, unable to delete!"
L["NewProfile"] = "Create New Profile"
L["CurrentProfile"] = "Active Profile"
L["Copy"] = "Copy from"
L["Delete"] = "Delete"
L["ConfirmDelete"] = "Confirm"
L["Cancel"] = "Cancel"
L["ProfileCopyDelete"] = "Select, delete or copy to new profile."

-- Settings Options
L["OptionsTip"] = "|cffFFBD50" .. "Extended Options|r"
L["Show"] = "Show"
L["ShowTip"] = ""
L["Enhanced"] = "Enhanced"
L["Base"] = "Basic"
L["Display_Rating"] = "Rating"
L["Display_RatingTip"] = ""
L["Damage"] = "Offense"
L["DamageTaken"] = "Defense"
L["World"] = "World"
L["Realm"] = "Realm"
L["Max"] = "Max"
L["Low"] = "Low"
L["Average"] = "Average"
L["Level"] = "Level"
L["Honor"] = "Points"
L["Both"] = "Both"
L["MainHand"] = "Main-Hand"
L["OffHand"] = "Off-Hand"
L["Live"] = "Real-time"
L["Static"] = "Static"
L["Display_PercentageTip"] = ""
L["Display_Percentage"] = "Progression"
L["Normal"] = "Normal"
L["Enchanted"] = "Enchanted"
L["Shadowflame"] = "Shadowflame"
L["Ingenuity"] = "Ingenuity"
L["Season"] = "Season"
L["Expansion"] = "Expansion"
L["Spark"] = "Spark"
L["Splinter"] = "Fractured"
L["Gigantic"] = "Gigantic"
L["Plump"] = "Plump"
L["Current"] = "Current"
L["Owned"] = "Owned"
L["Empty"] = "Empty"
L["Vintage"] = "Vintage"
L["Display_Average"] = "Average"
L["Display_AverageTip"] = ""
L["Display_Rated"] = "Rated"
L["Display_RatedTip"] = ""
L["Display_Basic"] = "Basic"
L["Display_BasicTip"] = ""
L["Display_MainHand"] = "Disable Off-Hand"
L["Display_MainHandTip"] = ""
L["Hide_Reputation"] = "Hide Maxed Renown"
L["Hide_ReputationTip"] = ""
L["Season"] = "Season"
L["Expansion"] = "Expansion"
L["Display_Short"] = "Short Number"
L["Display_ShortTip"] = ""
L["Display_Max"] = "Cap color"
L["Display_MaxTip"] = ""
L["Display_Gold"] = "Show Gold only"
L["Display_GoldTip"] = ""
L["Display_Weekly"] = "Show Cap"
L["Display_WeeklyTip"] = ""
L["Display_Delves"] = "Tier 8+"
L["Display_DelvesTip"] = "Tier 8 and above only"
L["Editbox_D"] = "Delves Tier"
L["Editbox_DTooltip"] = Ns.Colors.Green .. "Delves Tier|r\n" .. "Set the Delves Tier level \nto display the number of \ncompleted runs \n\n" .. "The option " .. Ns.Colors.Green .. "Tier 8+|r will \noverride this option"

-- Decimals
L["Decimals_CritTip"] = "Rounding decimals"
L["Decimals_HasteTip"] = "Rounding decimals"
L["Decimals_MasteryTip"] = "Rounding decimals"
L["Decimals_VersatilityTip"] = "Rounding decimals"
L["Decimals_AvoidanceTip"] = "Rounding decimals"
L["Decimals_LeechTip"] = "Rounding decimals"
L["Decimals_SpeedTip"] = "Rounding decimals"
L["Decimals_DamageTip"] = "Rounding decimals"
L["Decimals_BlockTip"] = "Rounding decimals"
L["Decimals_ParryTip"] = "Rounding decimals"
L["Decimals_DodgeTip"] = "Rounding decimals"
L["Decimals_StaggerTip"] = "Rounding decimals"
L["Decimals_EnergyTip"] = "Rounding decimals"
L["Decimals_ManaRegenTip"] = "Rounding decimals"
L["Decimals_iLVLTip"] = "Rounding decimals"
L["Decimals_pvpiLVLTip"] = "Rounding decimals"
L["Decimals_DPSTip"] = "Rounding decimals"
L["Decimals_WepSpeedTip"] = "Rounding decimals"
L["Decimals_DmgModTip"] = "Rounding decimals"
L["Decimals_DmgModSpellTip"] = "Rounding decimals"
L["Decimals_GcdTip"] = "Rounding decimals"
L["Decimals_DefaultTip"] = "Number Break Place"
L["Decimals_DRTip"] = "Rounding decimals"
L["Decimals_SpellTip"] = "Number Break Place"

-- Caps
L["Cap_Percent"] = "Percentage cap"
L["Cap_PercentTooltip"] = Ns.Colors.Green .. "Percentage cap|r\n" .. "Set the percentage of your soft \nor hard cap. It can also be used \nto set a diminishing return cap \nor any other personal threshold \n\nYour stat will be colored green \nupon reaching the set value \n\nSet value to 0 to disable cap \ncolors"
L["Cap_Rating"] = "Rating cap"
L["Cap_RatingTooltip"] = Ns.Colors.Green .. "Rating cap|r\n" .. "Set the rating of your soft or \nhard cap. It can also be used \nto set a diminishing return cap \nor any other personal threshold \n\nYour stat will be colored green \nupon reaching the set value \n\nSet value to 0 to disable cap \ncolors"