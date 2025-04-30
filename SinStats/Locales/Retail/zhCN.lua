local AddName, Ns = ...

if GetLocale() ~= "zhCN" then return end
local L = Ns.RegisterLocale("zhCN", true)

-- SinLive 能力
L["ScalingText"] = Ns.Colors.Green .. "\n目标减益缩放 |r\n"
L["ScalingText2"] = Ns.Colors.Green .. "\n目标缩放: |r"
L["TipsAndInfo"] = Ns.Colors.Green .. "提示和信息!|r\n\n"
L["SinLive"] = Ns.Colors.Green .. "SinLive™ 属性\n该属性是交互式的，并随目标缩放|r\n\n"
L["NPCAnyLevel"] = "目标等级"
L["DefaultValueText"] = Ns.Colors.Green .. "\n\n默认值:|r  "
L["NPCSameLevel"] = "玩家等级"

-- 提示
L["Enhanced_BaseTooltip"] = Ns.Colors.Green .. "增强|r\n" .. "通过添加天赋、增益、减益、药水、宝石、附魔和其他来源提供最佳准确性\n\n" .. Ns.Colors.Green .. "基础|r\n" .. "显示属性本身，没有附加内容，可能不是最准确的"
L["Percent_RatingTooltip"] = Ns.Colors.Green .. "百分比|r\n" .. "以百分比显示属性\n\n" .. Ns.Colors.Green .. "数值|r\n" .. "显示数值"
L["Regen_Normal_CastingTooltip"] = Ns.Colors.Green .. "正常|r\n" .. "不施法时的法力恢复\n\n" .. Ns.Colors.Green .. "施法|r\n" .. "施法时的法力恢复"
L["World_RealmTooltip"] = Ns.Colors.Green .. "服务器|r\n" .. "从您的计算机到暴雪服务器的平均延迟（毫秒）\n\n" .. Ns.Colors.Green .. "世界|r\n" .. "从您的计算机到游戏世界的延迟"
L["Melee_RangedTooltip"] = Ns.Colors.Green .. "近战|r\n" .. "显示您的近战武器值\n\n" .. Ns.Colors.Green .. "远程|r\n" .. "显示您的远程武器值"
L["Equipped_OverallTooltip"] = Ns.Colors.Green .. "装备|r\n" .. "您装备的装备的平均物品等级\n\n" .. Ns.Colors.Green .. "最大|r\n" .. "所有装备的最大物品等级，包括背包中的"
L["Max_Average_DamageTooltip"] = Ns.Colors.Green .. "最大、平均和最低|r\n" .. "显示您的完整伤害范围"
L["Damage_TakenTooltip"] = Ns.Colors.Green .. "攻击|r\n" .. "增加造成的伤害和治疗\n\n" .. Ns.Colors.Green .. "防御|r\n" .. "减少受到的伤害"
L["Level_HonorPointsTooltip"] = Ns.Colors.Green .. "等级|r\n" .. "您当前的荣誉等级\n\n" .. Ns.Colors.Green .. "点数|r\n" .. "您获得的总荣誉"
L["Speed_StaticTooltip"] = Ns.Colors.Green .. "实时|r\n" .. "实时显示您角色的移动速度（站立、奔跑、游泳、飞行、角色扮演走路、滑翔等）\n\n" .. Ns.Colors.Green .. "静态|r\n" .. "您角色的移动速度是静态的，只有在旅行方式改变或速度值增加时才会变化"
L["Normal_EnchantedTooltip"] = Ns.Colors.Green .. "正常|r\n" .. "显示物品的总数量，包括在您的背包和银行中\n\n" .. Ns.Colors.Green .. "附魔|r\n" .. "显示附魔物品的数量，包括在您的背包和银行中"
-- need Check below
L["Season_ExpTooltip"] = Ns.Colors.Green .. "赛季|r\n" .. "显示您当前赛季的大秘境评分\n\n" .. Ns.Colors.Green .. "版本|r\n" .. "显示您当前版本的最佳大秘境评分"
L["Splint_SparkTooltip"] = Ns.Colors.Green .. "时运火花|r\n" .. "显示时运火花的总数量\n\n" .. Ns.Colors.Green .. "分裂火花|r\n" .. "显示分裂的时运火花的总数量"
L["Current_EarnedTooltip"] = Ns.Colors.Green .. "当前|r\n" .. "显示当前拥有的数量\n\n" .. Ns.Colors.Green .. "已获得|r\n" .. "显示总获得的数量"
L["Empty_VintageTooltip"] = Ns.Colors.Green .. "Empty|r\n" .. "Displays the quanity of \nEmpty Kaja'Cola Cans \n\n" .. Ns.Colors.Green .. "Vintage|r\n" .. "Displays the quantity of \nVintage Kaja'Cola Cans"

L["Display_AverageTooltip"] = Ns.Colors.Green .. "平均|r\n" .. "从最大值切换到平均值"
L["Display_BasicTooltip"] = Ns.Colors.Green .. "基础|r\n" .. "显示属性本身，没有附加内容，可能不是最准确的"
L["Display_RatedTooltip"] = Ns.Colors.Green .. "数值|r\n" .. "显示您的荣誉值"
L["Display_RatingTooltip"] = Ns.Colors.Green .. "数值|r\n" .. "显示数值"
L["Display_MainHandTooltip"] = Ns.Colors.Green .. "主手专用|r\n" .. "如果适用，禁用副手值的自动显示"
L["Hide_ReputationTooltip"] = Ns.Colors.Green .. "隐藏已满声望|r\n" .. "当声望满时隐藏该阵营的声望等级"
L["Display_PercentageTooltip"] = Ns.Colors.Green .. "进程|r\n" .. "显示当前进程的完成百分比"
L["Display_MythicBestTooltip"] = Ns.Colors.Green .. "最佳评分|r\n" .. "显示您当前版本的最佳大秘境评分"
L["Display_MaxTooltip"] = Ns.Colors.Green .. "每周上限|r\n" .. "当达到该货币的每周上限时，将您的数量标记为红色"

-- 属性
L["CritChance"] = "爆击"
L["CritChanceAbrev"] = "爆"
L["CritChanceMenu"] = "爆击"
L["CritChanceTip"] = ""
L["CritChanceDescription"] = L["SinLive"] .. L["ScalingText"] .. Ns.BetEyesLink

L["Haste"] = "急速"
L["HasteAbrev"] = "急"
L["HasteMenu"] = "急速"
L["HasteTip"] = ""
L["HasteDescription"] = ""

L["Mastery"] = "精通"
L["MasteryAbrev"] = "精"
L["MasteryMenu"] = "精通"
L["MasteryTip"] = ""
L["MasteryDescription"] = ""

L["Versatility"] = "全能"
L["VersatilityAbrev"] = "全"
L["VersatilityMenu"] = "全能"
L["VersatilityTip"] = ""
L["VersatilityDescription"] = ""

L["Avoidance"] = "闪避"
L["AvoidanceAbrev"] = "闪避"
L["AvoidanceMenu"] = "闪避"
L["AvoidanceTip"] = ""
L["AvoidanceDescription"] = ""

L["Leech"] = "吸血"
L["LeechAbrev"] = "吸血"
L["LeechMenu"] = "吸血"
L["LeechTip"] = ""
L["LeechDescription"] = ""

L["Strength"] = "力量"
L["StrengthAbrev"] = "力"
L["StrengthMenu"] = "力量"
L["StrengthTip"] = ""
L["StrengthDescription"] = L["TipsAndInfo"] .. "红色 " .. Ns.Colors.Red .. "力量|r 值表示您受到减益影响\n"

L["Agility"] = "敏捷"
L["AgilityAbrev"] = "敏"
L["AgilityMenu"] = "敏捷"
L["AgilityTip"] = ""
L["AgilityDescription"] = L["TipsAndInfo"] .. "红色 " .. Ns.Colors.Red .. "敏捷|r 值表示您受到减益影响\n"

L["AP"] = "攻击强度"
L["APAbrev"] = "攻强"
L["APMenu"] = "攻击强度"
L["APTip"] = ""
L["APDescription"] = L["TipsAndInfo"] .. "红色 " .. Ns.Colors.Red .. "攻击强度|r 值表示您受到减益影响\n"

L["DMG"] = "伤害"
L["DMGAbrev"] = "伤害"
L["DMGMenu"] = "伤害"
L["DMGTip"] = ""
L["DMGDescription"] = L["SinLive"] .. "红色 " .. Ns.Colors.Red .. "伤害|r 值表示您受到减益影响\n" .. L["ScalingText"] .. Ns.ColSmashLink .. Ns.FelSunLink .. Ns.MystTouchLink .. Ns.JadefireLink .. Ns.BrittleLink .. Ns.FinalReckLink .. "\n" .. Ns.GhostlyStrikeLink .. Ns.HuntersMarkLink .. Ns.RazorLink

L["DPS"] = "每秒伤害"
L["DPSAbrev"] = "秒伤"
L["DPSMenu"] = "每秒伤害"
L["DPSTip"] = ""
L["DPSDescription"] = L["SinLive"] .. L["ScalingText"] .. Ns.ColSmashLink .. Ns.FelSunLink .. Ns.MystTouchLink .. Ns.JadefireLink .. Ns.BrittleLink .. Ns.GhostlyStrikeLink .. "\n" .. Ns.HuntersMarkLink

L["DMGMod"] = "伤害+"
L["DMGModAbrev"] = "伤害+"
L["DMGModMenu"] = "伤害加成"
L["DMGModTip"] = ""
L["DMGModDescription"] = L["SinLive"] .. "物理伤害加成\n" .. L["ScalingText"] .. Ns.ColSmashLink .. Ns.FelSunLink .. Ns.MystTouchLink .. Ns.JadefireLink .. Ns.BrittleLink .. Ns.FinalReckLink .. "\n" .. Ns.GhostlyStrikeLink .. Ns.HuntersMarkLink .. Ns.RazorLink

L["weaponSpeed"] = "攻击速度"
L["weaponSpeedAbrev"] = "攻速"
L["weaponSpeedMenu"] = "武器速度"
L["weaponSpeedTip"] = ""
L["weaponSpeedDescription"] = L["TipsAndInfo"] .. "该属性自动检测您的武器类型并相应显示其值"

L["EnergyRegen"] = "能量回复"
L["EnergyRegenAbrev"] = "回能"
L["EnergyRegenMenu"] = "能量回复"
L["EnergyRegenTip"] = ""
L["EnergyRegenDescription"] = L["TipsAndInfo"] .. "能量回复"

L["Stamina"] = "耐力"
L["StaminaAbrev"] = "耐"
L["StaminaMenu"] = "耐力"
L["StaminaTip"] = ""
L["StaminaDescription"] = L["TipsAndInfo"] .. "红色 " .. Ns.Colors.Red .. "耐力|r 值表示您受到减益影响\n"

L["Mitigation"] = "伤害减免"
L["MitigationAbrev"] = "减伤"
L["MitigationMenu"] = "伤害减免"
L["MitigationTip"] = ""
L["MitigationDescription"] = L["SinLive"] .. "对所有等级攻击者的伤害减少\n" .. L["DefaultValueText"] .. L["NPCSameLevel"] .. L["ScalingText2"] .. L["NPCAnyLevel"]

L["Armor"] = "护甲"
L["ArmorAbrev"] = "护甲"
L["ArmorMenu"] = "护甲"
L["ArmorTip"] = ""
L["ArmorDescription"] = L["TipsAndInfo"] .. "红色 " .. Ns.Colors.Red .. "护甲|r 值表示您受到减益影响\n"

L["Dodge"] = "躲闪"
L["DodgeAbrev"] = "躲闪"
L["DodgeMenu"] = "躲闪"
L["DodgeTip"] = ""
L["DodgeDescription"] = ""

L["Parry"] = "招架"
L["ParryAbrev"] = "招架"
L["ParryMenu"] = "招架"
L["ParryTip"] = ""
L["ParryDescription"] = ""

L["Block"] = "格挡"
L["BlockAbrev"] = "格挡"
L["BlockMenu"] = "格挡"
L["BlockTip"] = ""
L["BlockDescription"] = ""

L["Absorb"] = "吸收"
L["AbsorbAbrev"] = "吸收"
L["AbsorbMenu"] = "吸收"
L["AbsorbTip"] = ""
L["AbsorbDescription"] = ""

L["Stagger"] = "偏转"
L["StaggerAbrev"] = "偏转"
L["StaggerMenu"] = "偏转"
L["StaggerTip"] = ""
L["StaggerDescription"] = ""

L["Intellect"] = "智力"
L["IntellectAbrev"] = "智"
L["IntellectMenu"] = "智力"
L["IntellectTip"] = ""
L["IntellectDescription"] = L["TipsAndInfo"] .. "红色 " .. Ns.Colors.Red .. "智力|r 值表示您受到减益影响\n"

L["SpellPower"] = "法术强度"
L["SpellPowerAbrev"] = "法强"
L["SpellPowerMenu"] = "法术强度"
L["SpellPowerTip"] = ""
L["SpellPowerDescription"] = L["SinLive"] .. L["ScalingText"] .. Ns.ChaosBrandLink .. Ns.FelSunLink .. Ns.ShatStarLink .. Ns.EradicLink .. "\n" .. Ns.WanTwilightLink .. Ns.HuntersMarkLink

L["DMGModSpell"] = "法术+"
L["DMGModSpellAbrev"] = "法术+"
L["DMGModSpellMenu"] = "法伤加成"
L["DMGModSpellTip"] = ""
L["DMGModSpellDescription"] = L["SinLive"] .. "法术伤害加成\n" .. L["ScalingText"] .. Ns.ChaosBrandLink .. Ns.FelSunLink .. Ns.ShatStarLink .. Ns.EradicLink .. "\n" .. Ns.WanTwilightLink .. Ns.HuntersMarkLink

L["Healing"] = "治疗"
L["HealingAbrev"] = "治"
L["HealingMenu"] = "治疗强度"
L["HealingTip"] = ""
L["HealingDescription"] = L["TipsAndInfo"] .. "治疗强度"

L["ManaRegen"] = "法力回复"
L["ManaRegenAbrev"] = "回蓝"
L["ManaRegenMenu"] = "法力回复"
L["ManaRegenTip"] = ""
L["ManaRegenDescription"] = L["TipsAndInfo"] .. "治疗强度"

L["Durability"] = "耐久"
L["DurabilityAbrev"] = "耐久"
L["DurabilityMenu"] = "耐久"
L["DurabilityTip"] = ""
L["DurabilityDescription"] = L["TipsAndInfo"] .. "您当前装备的装备和武器的耐久百分比"

L["RepairCost"] = "修理"
L["RepairCostAbrev"] = "修"
L["RepairCostMenu"] = "修理费用"
L["RepairCostTip"] = ""
L["RepairCostDescription"] = L["TipsAndInfo"] .. "总修理费用"

L["Speed"] = "速度"
L["SpeedAbrev"] = "速"
L["SpeedMenu"] = "速度"
L["SpeedTip"] = ""
L["SpeedDescription"] = L["TipsAndInfo"] .. "您角色的实时移动速度，包括您的 " .. Ns.Colors.Green .. "滑翔速度|r。\n\n红色 " .. Ns.Colors.Red .. "速度|r 值表示您受到减速效果影响或以比正常速度慢的速度移动"

L["Gallagio"] = "加乐宫"
L["GallagioAbrev"] = "加乐宫"
L["GallagioMenu"] = "加乐宫"
L["GallagioTip"] = ""
L["GallagioDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.GallaLink

L["Cartels"] = "安德麦财阀"
L["CartelsAbrev"] = "安德麦财阀"
L["CartelsMenu"] = "安德麦财阀"
L["CartelsTip"] = ""
L["CartelsDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.CartelLink

L["Radiance"] = "圣焰之耀"
L["RadianceAbrev"] = "圣焰之耀"
L["RadianceMenu"] = "圣焰之耀"
L["RadianceTip"] = ""
L["RadianceDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.RadianceLink

L["Dornogal"] = "多恩诺嘉尔议会"
L["DornogalAbrev"] = "多恩诺嘉尔"
L["DornogalMenu"] = "多恩诺嘉尔议会"
L["DornogalTip"] = ""
L["DornogalDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.DonorLink

L["Hallowfall"] = "陨圣峪阿拉希人"
L["HallowfallAbrev"] = "陨圣峪"
L["HallowfallMenu"] = "陨圣峪阿拉希人"
L["HallowfallTip"] = ""
L["HallowfallDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.HalloLink

L["Assembly"] = "邃渊协盟"
L["AssemblyAbrev"] = "邃渊协盟"
L["AssemblyMenu"] = "邃渊协盟"
L["AssemblyTip"] = ""
L["AssemblyDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.AssemLink

L["Severed"] = "斩离之丝"
L["SeveredAbrev"] = "斩离之丝"
L["SeveredMenu"] = "斩离之丝"
L["SeveredTip"] = ""
L["SeveredDescription"] = L["TipsAndInfo"] .. "显示名望：" .. Ns.SevereLink

L["TargetSpeed"] = "目标速度"
L["TargetSpeedAbrev"] = "速+"
L["TargetSpeedMenu"] = "目标速度"
L["TargetSpeedTip"] = ""
L["TargetSpeedDescription"] = L["TipsAndInfo"] .. "目标的当前移动速度，实时显示\n\n红色 " .. Ns.Colors.Red .. "速度|r 值表示您的目标受到减速效果影响或以比正常速度慢的速度移动"

L["ItemLevel"] = "装备等级"
L["ItemLevelAbrev"] = "装等"
L["ItemLevelMenu"] = "装备等级"
L["ItemLevelTip"] = ""
L["ItemLevelDescription"] = L["TipsAndInfo"] .. "平均物品等级"

L["Threat"] = "威胁"
L["ThreatAbrev"] = "威胁"
L["ThreatMenu"] = "威胁"
L["ThreatTip"] = ""
L["ThreatDescription"] = L["TipsAndInfo"] .. "针对当前目标的威胁百分比、值或两者"

L["PvPiLvl"] = "PvP装备等级"
L["PvPiLvlAbrev"] = "PvP装等"
L["PvPiLvlMenu"] = "PvP装备等级"
L["PvPiLvlTip"] = ""
L["PvPiLvlDescription"] = L["TipsAndInfo"] .. "玩家对玩家的物品等级"

L["GlobalCD"] = "Gcd"
L["GlobalCDAbrev"] = "Gcd"
L["GlobalCDMenu"] = "GCD"
L["GlobalCDTip"] = ""
L["GlobalCDDescription"] = L["TipsAndInfo"] .. "公共冷却时间"

L["BloodyTokens"] = "血腥硬币"
L["BloodyTokensAbrev"] = "血币"
L["BloodyTokensMenu"] = "血腥硬币"
L["BloodyTokensTip"] = ""
L["BloodyTokensDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.BloodyLink

L["Honor"] = "荣誉点数"
L["HonorAbrev"] = "荣誉"
L["HonorMenu"] = "荣誉点数"
L["HonorTip"] = ""
L["HonorDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.HonorLink

 L["Valorstones"] = "神勇石"
 L["ValorstonesAbrev"] = "神勇石"
L["ValorstonesMenu"] = "神勇石"
 L["ValorstonesTip"] = ""
L["ValorstonesDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.ValorLink

L["Weathered"] = "风化先驱纹章"
L["WeatheredAbrev"] = "风化"
L["WeatheredMenu"] = "风化先驱纹章"
L["WeatheredTip"] = ""
L["WeatheredDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.WeathLink

L["Carved"] = "蚀刻先驱纹章"
L["CarvedAbrev"] = "蚀刻"
L["CarvedMenu"] = "蚀刻先驱纹章"
L["CarvedTip"] = ""
L["CarvedDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CarvedLink

L["Runed"] = "符文先驱纹章"
L["RunedAbrev"] = "符文"
L["RunedMenu"] = "符文先驱纹章"
L["RunedTip"] = ""
L["RunedDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.RunedLink

L["Gilded"] = "鎏金先驱纹章"
L["GildedAbrev"] = "鎏金"
L["GildedMenu"] = "鎏金先驱纹章"
L["GildedTip"] = ""
L["GildedDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.GildedLink

L["Catalyst"] = "化生台"
L["CatalystAbrev"] = "化生台"
L["CatalystMenu"] = "化生台"
L["CatalystTip"] = ""
L["CatalystDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CatalystLink

L["CofferKey"] = "宝匣钥匙"
L["CofferKeyAbrev"] = "宝匣"
L["CofferKeyMenu"] = "修复的宝匣钥匙"
L["CofferKeyTip"] = ""
L["CofferKeyDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CofferLink

L["Stash"] = "鎏金藏匿物"
L["StashAbrev"] = "鎏金藏匿物"
L["StashMenu"] = "鎏金藏匿物"
L["StashTip"] = ""
L["StashDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.StashLink

L["Spark"] = "时运火花"
L["SparkAbrev"] = "时运火花"
L["SparkMenu"] = "时运火花"
L["SparkTip"] = ""
L["SparkDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.SparkLink .. "时运火花"

L["Cinder"] = "酷热燧烬花粉"
L["CinderAbrev"] = "酷热燧烬花粉"
L["CinderMenu"] = "酷热燧烬花粉"
L["CinderTip"] = ""
L["CinderDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CinderLink .. "酷热燧烬花粉"

L["Undercoin"] = "晦幽铸币"
L["UndercoinAbrev"] = "晦幽铸币"
L["UndercoinMenu"] = "晦幽铸币"
L["UndercoinTip"] = ""
L["UndercoinDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CoinLink

L["Iron"] = "焰祝之铁"
L["IronAbrev"] = "焰祝之铁"
L["IronMenu"] = "焰祝之铁"
L["IronTip"] = ""
L["IronDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.IronLink

L["KajaCola"] = "卡亚可乐"
L["KajaColaAbrev"] = "卡亚可乐"
L["KajaColaMenu"] = "空卡亚可乐罐"
L["KajaColaTip"] = ""
L["KajaColaDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.KajaLink .. " & " .. Ns.VintageLink

L["Market"] = "市场研究"
L["MarketAbrev"] = "市场研究"
L["MarketMenu"] = "市场研究"
L["MarketTip"] = ""
L["MarketDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.MarketLink

L["Crystals"] = "共鸣水晶"
L["CrystalsAbrev"] = "共鸣水晶"
L["CrystalsMenu"] = "共鸣水晶"
L["CrystalsTip"] = ""
L["CrystalsDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CrystalLink

L["Kej"] = "刻基"
L["KejAbrev"] = "刻基"
L["KejMenu"] = "刻基"
L["KejTip"] = ""
L["KejDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.KejLink

L["ValorPoints"] = "勇气"
L["ValorPointsAbrev"] = "勇气"
L["ValorPointsMenu"] = "勇气"
L["ValorPointsTip"] = ""
L["ValorPointsDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.ValorPvPLink

L["Conquest"] = "征服"
L["ConquestAbrev"] = "征服"
L["ConquestMenu"] = "征服"
L["ConquestTip"] = ""
L["ConquestDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.ConqLink

L["Celebration"] = "青铜"
L["CelebrationAbrev"] = "青铜"
L["CelebrationMenu"] = "青铜庆典奖币"
L["CelebrationTip"] = ""
L["CelebrationDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.CelebLink

L["Timewarped"] = "时空扭曲徽章"
L["TimewarpedAbrev"] = "时光"
L["TimewarpedMenu"] = "时空扭曲徽章"
L["TimewarpedTip"] = ""
L["TimewarpedDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.TimeLink

L["TraderTender"] = "商贩标币"
L["TraderTenderAbrev"] = "商栈"
L["TraderTenderMenu"] = "商贩标币"
L["TraderTenderTip"] = ""
L["TraderTenderDescription"] = L["TipsAndInfo"] .. "显示：" .. Ns.TenderLink

L["Delves"] = "地下堡"
L["DelvesAbrev"] = "地下堡"
L["DelvesMenu"] = "地下堡"
L["DelvesTip"] = ""
L["DelvesDescription"] = L["TipsAndInfo"] .. "Displays the number of completed Delves runs \nSelect the Tier to track or track all Tier 8 completed runs and above"

L["MythicPlus"] = "M+"
L["MythicPlusAbrev"] = "M+"
L["MythicPlusMenu"] = "大秘境评分"
L["MythicPlusTip"] = ""
L["MythicPlusDescription"] = L["TipsAndInfo"] .. "显示您当前赛季的大秘境评分或您版本的最佳评分"

L["Lag"] = "延迟"
L["LagAbrev"] = "延"
L["LagMenu"] = "延迟"
L["LagTip"] = ""
L["LagDescription"] = L["TipsAndInfo"] .. "连接延迟（Ping）"

L["FPS"] = "FPS"
L["FPSAbrev"] = "FPS"
L["FPSMenu"] = "FPS"
L["FPSTip"] = ""
L["FPSDescription"] = L["TipsAndInfo"] .. "每秒帧数 [FPS]"

L["Gold"] = "金钱"
L["GoldAbrev"] = "金"
L["GoldMenu"] = "金钱"
L["GoldTip"] = ""
L["GoldDescription"] = L["TipsAndInfo"] .. "您角色拥有的总金钱数量"

L["WowToken"] = "时光徽章"
L["WowTokenAbrev"] = "时光徽章"
L["WowTokenMenu"] = "时光徽章"
L["WowTokenTip"] = ""
L["WowTokenDescription"] = L["TipsAndInfo"] .. "您所在地区时光徽章的实时价值"

------------------
--    配置    --
------------------

-- 类别
L["HUDMenu"] = "HUD"
L["FontsMenu"] = "字体"
L["DisplayMenu"] = "显示"
L["DisplayOrderMenu"] = "布局"
L["EventsMenu"] = "事件"
L["ProfilesMenu"] = "配置文件"
L["FAQMenu"] = "常见问题"
L["Settings"] = "设置"
L["SettingsDescription"] = ""
L["Physical"] = "物理"
L["PhysicalDescription"] = ""
L["Enhancement"] = "增强"
L["EnhancementDescription"] = ""
L["Spell"] = "法术"
L["SpellDescription"] = ""
L["Misc"] = "杂项"
L["MiscDescription"] = ""
L["Currency"] = "货币"
L["CurrencyDescription"] = ""

-- HUD
L["SettingsDescription"] = ""
L["HideHUD"] = "隐藏"
L["HideHUDTip"] = Ns.HideIcon.. "隐藏统计信息 HUD"
L["LockHUD"] = "锁定"
L["LockHUDTip"] = Ns.LockIcon .. "锁定统计信息 HUD"
L["PanelDisplay"] = "附加"
L["PanelDisplayTip"] = Ns.AttachIcon.. "角色面板"
L["PanelShow"] = "自动显示"
L["PanelShowTip"] = Ns.AttachIcon.. "角色面板统计（大灾变）"
L["HUDBgColor"] = ""
L["HUDBgColorTip"] = Ns.BackgroundIcon .. "背景颜色"
L["HUDBgAlpha"] = ""
L["HUDBgAlphaTip"] = Ns.BackgroundIcon .. "背景透明度"
L["ResetPosition"] = "重置 HUD 位置"
L["ResetPositionTip"] = "重置统计信息 HUD 的位置"
L["HUDStrataTip"] = Ns.StrataIcon.. "框架层级"
L["MinimapGroupText"] = "小地图"
L["Minimap"] = "显示"
L["MinimapTip"] = Ns.MiniMenuIcon .. "小地图按钮"
L["CompButton"] = "显示"
L["CompButtonTip"] = Ns.CompIcon .. "隔间按钮"
L["Lowest"] = "最低"
L["Low"] = "低"
L["Medium"] = "中"
L["High"] = "高"
L["Highest"] = "最高"

-- 字体
L["StatFontTip"] = Ns.FontsIcon .. "字体"
L["StatFontSizeTip"] = Ns.FontSizeIcon .. "字体大小"
L["StatFontFlagsTip"] = Ns.OutlineIcon .. "轮廓"
L["Default Font"] = "Arial Narrow"
L["Thin"] = "细"
L["Thick"] = "粗"
L["Monochrome"] = "单色"
L["Thin Monochrome"] = "细单色"
L["Thick Monochrome"] = "粗单色"
L["None"] = "无"

-- 显示
L["StatIconsTip"] = Ns.ToggleIconsIcon .. "在统计信息上切换图标"
L["StatIcons"] = "显示图标"
L["StatTextAbreviateTip"] = Ns.AbbreviateIcon .. "缩写属性名称"
L["StatTextAbreviate"] = "缩写   "
L["StatTextCapsTip"] = Ns.CapsIcon .. "切换文本大写"
L["StatTextCaps"] = "大写"
L["StatTextColorTip"] = Ns.TextColorIcon .. "文本颜色：名称"
L["StatTextColor"] = ""
L["ClassColorsTip"] = Ns.TextColorIcon .. "文本颜色：名称"
L["ClassColors"] = "职业颜色"
L["AlignmentText"] = "对齐和间距"
L["StatWidthTip"] = Ns.WidthStringIcon .. "文本：宽度"
L["StatWidthTooltip"] = Ns.Colors.Green .. "文本字符串宽度|r\n" .. "调整文本字符串宽度以适应您的统计信息\n增加宽度以创建更多空间，如果\n文本被截断（...）\n\n当在 1 行或 1 列上显示统计信息时，此选项被禁用"
L["StatSpacingHTip"] = Ns.WidthIcon .. "间距：宽度"
L["StatSpacingVTip"] = Ns.HeightIcon .. "间距：高度"
L["StatAlignmentTip"] = Ns.AlignIcon .. "对齐：文本"
L["IconAlignmentTip"] = Ns.AlignIcon .. "对齐：图标"
L["DataColor"] = ""
L["DataColorTip"] = Ns.ValueColorIcon .. "文本颜色：值"
L["SplitColors"] = "启用"
L["SplitColorsTip"] = Ns.ValueColorIcon .. "文本颜色：值"
L["SplitColorsTooltip"] = Ns.Colors.Green .. "值文本颜色|r\n" .. "启用此选项将允许统计信息\n值设置为与统计信息名称不同的颜色\n\n使用" .. Ns.Colors.Green .. "文本颜色（值）|r颜色选择器设置颜色"
L["Left"] = "左"
L["Right"] = "右"
L["Center"] = "居中"
L["TextSeparatorTip"] = Ns.SeparatorIcon .. "分隔符"

-- 布局
L["ClearAllColumns"] = "重置"
L["Rows"] = "行预设"
L["Columns"] = "列预设"
L["OneRow"] = "1"
L["TwoRows"] = "2"
L["ThreeRows"] = "3"
L["FourRows"] = "4"
L["DisplayOrderDescription"] = ""
L["StatOrderSettingsTooltip"] = Ns.Colors.Green .. "统计顺序|r\n" .. "自定义统计信息显示的顺序\n只需拖放下面的统计信息\n\n" .. Ns.Colors.Green .. "列|r\n" .. "选择统计信息旁边的复选框将创建一个新\n列，包含所选统计信息和下面的统计信息。\n\124T" .. "Interface\\AddOns\\"..AddName.."\\Textures\\" .."CheckColumn:0:0:0:0:16:16:0:16:0:16:112:255:201\124t标记新列的开始\n\n" .. Ns.Colors.Green .. "行和列预设|r\n" .. "选择一个最多由 4 行或\n列组成的预设布局。此选项有助于快速创建布局。\n行和列也可以手动创建\n\n完成后按应用"

-- 常见问题
L["FAQFirst"] = Ns.MiscIcon .. Ns.Colors.Green .. "某些统计信息的文本被截断 (...)|r\n\n " .. Ns.SettingsIcon .. "设置 >> " .. Ns.DisplayIcon .. "显示 >> " .. Ns.SpacingIcon .. "间距和对齐：调整 " .. Ns.WidthStringIcon .. Ns.Colors.Green .. "文本：宽度|r 滑块"
L["FAQSecond"] = Ns.MiscIcon .. Ns.Colors.Green .. "如何以列或行显示统计信息|r\n\n " .. Ns.SettingsIcon .. "设置 >> " .. Ns.LayoutIcon .. "布局：将鼠标悬停在其 " .. Ns.MiscIcon .. "图标上以获取更多详细信息"
L["FAQThird"] = Ns.MiscIcon .. Ns.Colors.Green .. "如何在一行中显示统计信息|r\n\n " .. Ns.SettingsIcon .. "设置 >> " .. Ns.LayoutIcon .. "布局：单击 " .. Ns.Colors.Green .. "行预设|r 中的 1 按钮或手动激活所有 " .. Ns.ColumnIcon .. "复选框"
L["FAQForth"] = Ns.MiscIcon .. Ns.Colors.Green .. "如何重新排序统计信息|r\n\n " .. Ns.SettingsIcon .. "设置 >> " .. Ns.LayoutIcon .. "布局：拖放列表中的统计信息"
L["FAQFifth"] = Ns.MiscIcon .. Ns.Colors.Green .. "如何仅在战斗中或其他特定情况下启用统计信息|r\n\n " .. Ns.SettingsIcon .. "设置 >> " .. Ns.EventsIcon .. "事件：使统计信息仅在所选事件中可见"

-- 事件
L["EventEnable"] = "启用"
L["EventEnableTip"] = "HUD 事件"
L["EventEnableTooltip"] = Ns.Colors.Green .. "HUD 事件|r\n" .. "使您的统计信息严格按照下面的事件可见。\n否则您的统计信息将被隐藏\n\n战斗具有更高的优先级"
L["EventWorld"] = "开放世界"
L["EventWorldTip"] = Ns.Colors.Green .. "仅在以下情况下显示统计信息"
L["EventDungeon"] = "地下城"
L["EventDungeonTip"] = ""
L["EventRaid"] = "团队"
L["EventRaidTip"] = ""
L["EventPvP"] = "战场"
L["EventPvPTip"] = ""
L["EventArena"] = "竞技场"
L["EventArenaTip"] = ""
L["EventCombat"] = "战斗"
L["EventCombatTip"] = ""

-- 小地图
L["QuickAccess"] = "快速访问"
L["OpenSettings"] = "打开设置"
L["EnableDisable"] = "启用/禁用 HUD"
L["ShiftRightClick"] = "+ Shift"
L["UnlockHUD"] = "锁定/解锁 HUD"

-- 设置配置文件
L["Selected"] = "应用"
L["SelectProfile"] = "管理您的配置文件：选择、创建、复制或删除\n被角色使用的配置文件无法删除"
L["ProfileSelected"] = "配置文件"
L["ProfileUsed"] = "配置文件当前正在使用，无法删除！"
L["NewProfile"] = "创建新配置文件"
L["CurrentProfile"] = "当前配置文件"
L["Copy"] = "复制自"
L["Delete"] = "删除"
L["ConfirmDelete"] = "确认"
L["Cancel"] = "取消"
L["ProfileCopyDelete"] = "选择、删除或复制到新配置文件。"

-- 设置选项
L["OptionsTip"] = "|cffFFBD50" .. "扩展选项|r"
L["Show"] = "显示"
L["ShowTip"] = ""
L["Enhanced"] = "增强"
L["Base"] = "基础"
L["Display_Rating"] = "数值"
L["Display_RatingTip"] = "数值"
L["Damage"] = "攻击"
L["DamageTaken"] = "防御"
L["World"] = "世界"
L["Realm"] = "服务器"
L["Max"] = "最大"
L["Low"] = "低"
L["Average"] = "平均"
L["Level"] = "等级"
L["Honor"] = "荣誉"
L["Both"] = "两者"
L["MainHand"] = "主手"
L["OffHand"] = "副手"
L["Live"] = "实时"
L["Static"] = "静态"
L["Display_PercentageTip"] = "数值"
L["Display_Percentage"] = "进程"
L["Normal"] = "正常"
L["Enchanted"] = "附魔"
L["Shadowflame"] = "暗影烈焰"
L["Ingenuity"] = "灵思"
L["Season"] = "赛季"
L["Expansion"] = "版本"
L["Spark"] = "火花"
L["Splinter"] = "碎片"
L["Gigantic"] = "硕大"
L["Plump"] = "饱满"
L["Current"] = "当前"
L["Owned"] = "已拥有"
L["Display_Average"] = "平均"
L["Display_AverageTip"] = ""
L["Display_Rated"] = "数值"
L["Display_RatedTip"] = ""
L["Display_Basic"] = "基础"
L["Display_BasicTip"] = ""
L["Display_MainHand"] = "禁用副手"
L["Display_MainHandTip"] = ""
L["Hide_Reputation"] = "隐藏已满声望"
L["Hide_ReputationTip"] = ""
L["Season"] = "赛季"
L["Expansion"] = "版本"
L["Display_Short"] = "短数字"
L["Display_ShortTip"] = ""
L["Display_Max"] = "每周上限"
L["Display_MaxTip"] = ""
L["Display_Gold"] = "仅显示金币"
L["Display_GoldTip"] = ""
L["Display_Delves"] = "Tier 8+"
L["Display_DelvesTip"] = "Tier 8 and above only"
L["Editbox_D"] = "Delves Tier"
L["Editbox_DTooltip"] = Ns.Colors.Green .. "Delves Tier|r\n" .. "Set the Delves Tier level \nto display the number of \ncompleted runs \n\n" .. "The option " .. Ns.Colors.Green .. "Tier 8+|r will \noverride this option"

-- 小数
L["Decimals_CritTip"] = "四舍五入小数"
L["Decimals_HasteTip"] = "四舍五入小数"
L["Decimals_MasteryTip"] = "四舍五入小数"
L["Decimals_VersatilityTip"] = "四舍五入小数"
L["Decimals_AvoidanceTip"] = "四舍五入小数"
L["Decimals_LeechTip"] = "四舍五入小数"
L["Decimals_SpeedTip"] = "四舍五入小数"
L["Decimals_DamageTip"] = "四舍五入小数"
L["Decimals_BlockTip"] = "四舍五入小数"
L["Decimals_ParryTip"] = "四舍五入小数"
L["Decimals_DodgeTip"] = "四舍五入小数"
L["Decimals_StaggerTip"] = "四舍五入小数"
L["Decimals_EnergyTip"] = "四舍五入小数"
L["Decimals_ManaRegenTip"] = "四舍五入小数"
L["Decimals_iLVLTip"] = "四舍五入小数"
L["Decimals_pvpiLVLTip"] = "四舍五入小数"
L["Decimals_DPSTip"] = "四舍五入小数"
L["Decimals_WepSpeedTip"] = "四舍五入小数"
L["Decimals_DmgModTip"] = "四舍五入小数"
L["Decimals_DmgModSpellTip"] = "四舍五入小数"
L["Decimals_GcdTip"] = "四舍五入小数"
L["Decimals_DefaultTip"] = "数值缩写"
L["Decimals_DRTip"] = "四舍五入小数"
L["Decimals_SpellTip"] = "数值缩写"

-- 上限
-- Caps
L["Cap_Percent"] = "Percentage cap"
L["Cap_PercentTooltip"] = Ns.Colors.Green .. "Percentage cap|r\n" .. "Set the percentage of your soft or hard cap. It can also be used to set a diminishing return cap or any other personal threshold \n\nYour stat will be colored green upon reaching the set value \n\nSet value to 0 to disable cap colors"
L["Cap_Rating"] = "Rating cap"
L["Cap_RatingTooltip"] = Ns.Colors.Green .. "Rating cap|r\n" .. "Set the rating of your soft or hard cap. It can also be used to set a diminishing return cap or any other personal threshold. Your stat will be colored green upon reaching the set value \n\nSet value to 0 to disable cap colors"
