local AddName, Ns = ...
local L = Ns.L


--------------------------
--		Stat Init		--
--------------------------

-- character and npc 
Ns.raceId = select(3, UnitRace("player"))
Ns.classFilename = select(2, UnitClass("player"))
Ns.greenText, Ns.redText, Ns.orangeText = "|cff71FFC9", "|cffC41E3A", "|cffFF7C0A"
Ns.stopCheck = false
Ns.throttleTime, Ns.inspectDelay = 0, 3
Ns.impMoon, Ns.impRet, Ns.BeastSlaying, Ns.hunterHaste = 0, 0, 0, 0
Ns.playerLevel = UnitLevel("player")
Ns.repairTooltip = CreateFrame("GameTooltip", "SinStatsTooltip", nil, "GameTooltipTemplate")
Ns.repairTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
Ns.SavedTarget = 0
-- general
Ns.armorValue, Ns.armorDebuff, Ns.Resilvalue, Ns.baseDefense, Ns.defenseRating, Ns.gearDefense = 0, 0, 0, 0, 0, 0
Ns.parryChance, Ns.dodgeChance, Ns.averageiLvl, Ns.Berserkering, Ns.bowSpec = 0, 0, 0, 0, 0
Ns.hitMod, Ns.shadowWeaving, Ns.debuffCount, Ns.shatterArmor, Ns.targetArmorReduced, Ns.targetArmor = 0, 0, 0, 0, 0, 0
Ns.inspiSpellHit, Ns.critSpellChance, Ns.regenBase, Ns.regenCasting, Ns.Shatter, Ns.feroInspiration = 0, 0, 0, 0, 0, 0
Ns.castHaste, Ns.meleeHaste, Ns.buffCount, Ns.heroicPresence, Ns.zoneBuff = 0, 0, 0, 0, 0
Ns.buffCount, Ns.heroicPresence, Ns.zoneBuff, Ns.dodgeChance, Ns.parryChance, Ns.blockChance, Ns.avoid = 0, 0, 0, 0, 0, 0, 0
Ns.dwarfRacial, Ns.quickness, Ns.weaponTag, Ns.totalDefense, Ns.runeInvicibility, Ns.talentThrottle, Ns.hiddenHaste, Ns.canInspect = false, 0, 2, 0, 0, false, 0, nil
Ns.meleeCrit, Ns.spellCrit, Ns.rangedCrit, Ns.meleeMissTracker, Ns.spellMissTracker, Ns.rangedMissTracker, Ns.totalParryDodge = 0, 0, 0, 0, 0, 0, 0
Ns.critReceived, Ns.totalDodge, Ns.totalParry, Ns.totalBlock, Ns.simEnabled, Ns.classDR, Ns.buffDR, Ns.auraDR = 0, 0, 0, 0, 0, 1, 1, 1
--mage
Ns.pierceMod, Ns.aiMod, Ns.playFire, Ns.arcticWind, Ns.impFrostbolt, Ns.arcaneFocus, Ns.NetherwindPresence, Ns.moltenArmor = 0, 0, 0, 0, 0, 0, 0, 0
Ns.impSorch, Ns.wintersChill, Ns.arcanePower, Ns.combustionCount, Ns.evoc, Ns.totemWrath, Ns.MoltenFury = 0, 0, 0, 0, 0, 0, 0
Ns.PrismaticCloak, Ns.arcaneEmpowerment = 0, 0
-- paladin
Ns.vengStacks, Ns.vengBuff, Ns.avenWrath, Ns.vengeance, Ns.HeartOfCrusader, Ns.divinity, Ns.avenWrath = 0, 0, 0, 0, 0, 0, 0
Ns.blessingSanc, Ns.divineProt, Ns.rightFury, Ns.riFuryTalent, Ns.Vengeance, Ns.crusadeTalent, Ns.heartCrusader, Ns.ShieldTemplar = 0, 0, 0, 0, 0, 0, 0, 0
Ns.SwiftRetribution, Ns.swiftRet, Ns.faerieCheck, Ns.glyphDivinePlea, Ns.divinePlea, Ns.glyphManaTide = 0, 0, false, 0, 0, false
-- shaman
Ns.stormStrike, Ns.tidalMastery, Ns.purification, Ns.elePrecision, Ns.spiritualHealing, Ns.emberstorm, Ns.maelstromWeapon, Ns.bloodLust = 0, 0, 0, 0, 0, 0, 0, 0
Ns.eleMasteryHaste, Ns.manaTide, Ns.ancestralHealing, Ns.windFury, Ns.ImprovedWindfury, Ns.shamanRage, Ns.wrathAir, Ns.heroism = 0, 0, 0, 0, 0, 0, 0, 0
Ns.callofThunder, Ns.tideTimer = "", false
-- warlock
Ns.masterImp, Ns.masterFel, Ns.masterSucc, Ns.dsSuc, Ns.dsImp, Ns.felEnergy, Ns.DemonicTactics, Ns.ImpDemonicTactics = 0, 0, 0, 0, 0, 0, 0, 0
Ns.shadowMastery, Ns.Suppression, Ns.curseOfWeak, Ns.shadowDmg, Ns.curseElements, Ns.impShadowbolt, Ns.MoltenSkin = 0, 0, 0, 0, 0, 0, 0
Ns.impDemonicTactics, Ns.DemonicPact, Ns.metaDamage, Ns.metaCrit, Ns.demonicEmp, Ns.stones = 0, 0, 0, 0, 0, 0
Ns.devastation = ""
-- warrior
Ns.bloodFrenzy, Ns.sunderArmor, Ns.MaceSpec, Ns.stanceArmorPen, Ns.berserker, Ns.vigilance = 0, 0, 0, 0, 0, 0
Ns.wrynnSet, Ns.wrynnSetArp, Ns.wrynnSetCrit = 0, 0, 0
-- rogue
Ns.hemoDmg, Ns.exposeArmor, Ns.SleightTalent, Ns.SerratedBlades, Ns.savageCombat, Ns.LightningReflexes = 0, 0, 0, 0, 0, 0
Ns.bladeFlurry, Ns.MasterPoisonerTalent, Ns.masterPoisoner, Ns.trickTrade = 0, 0, 0, 0
-- priest
Ns.DarkNessTalent, Ns.blessedResil, Ns.misery, Ns.epiphany, Ns.shadowFormDmg, Ns.innerFocus = 0, 0, 0, 0, 0, 0
Ns.Enlightenment, Ns.inspiration, Ns.FocusedPower = 0, 0, 0
-- death knight
Ns.icyTalons, Ns.bloodGorged, Ns.tundraStalker, Ns.virulence, Ns.frigidDread, Ns.frostFeverDmg = 0, 0, 0, 0, 0, 0
Ns.ebonPlague, Ns.desolation, Ns.frostFever, Ns.rageRivendare, Ns.rageRivenTalent, Ns.bladeBarrier, Ns.armyDead = 0, 0, 0, 0, 0, 0, 0
Ns.frostPresence, Ns.ImpFrostPresence, Ns.iceFortitude, Ns.valorousSet, Ns.valorousBonus, Ns.hysteria = 0, 0, 0, 0, 0, 0
-- druid
Ns.innervate, Ns.isShapeshift = 0, false
Ns.balancePower, Ns.giftNature, Ns.survFittest, Ns.starlight, Ns.earthMother, Ns.predStrikes, Ns.naturesGrace = 0, 0, 0, 0, 0, 0, 0
Ns.faerieFire, Ns.insectSwarm, Ns.treeofLife, Ns.earthMoon, Ns.FaerieImproved, Ns.faerieFireImp, Ns.CelestialFocus = 0, 0, 0, 0, 0, 0, 0
Ns.improvedFaerie, Ns.faerieCrit, Ns.ProtectorPack, Ns.protectorPack, Ns.lashWeave, Ns.lashWeaveSet = 0, 0, 0, 0, false, 0
-- hunter
Ns.huntersMark, Ns.serpentSwift, Ns.scorpidSting, Ns.aspectViper, Ns.Ferocity, Ns.AnimalHandler, Ns.feroInspiration, Ns.KindredSpirits = 0, 0, 0, 0, 0, 0, 0, 0
Ns.FocusedFire, Ns.rapidFire, Ns.ImprovedHuntersMark, Ns.glyphHuntersMark, Ns.quickShots = 0, 0, 0, 0, 0

-- function Ns.WrapColor(text, colorHexString)
-- 	return ("%s%s|r"):format(colorHexString, text)
-- end

----------------------------------------------
--			Racial & Classic Racial			--
----------------------------------------------
if (Ns.raceId == 3) then Ns.dwarfRacial = true end
if (Ns.raceId == 4) then Ns.quickness = 2 end
if (Ns.raceId == 8) then Ns.bowSpec = true end
if (Ns.classFilename == "HUNTER") then Ns.hunterHaste = 15 end


--------------------------
--		ID Tables		--
--------------------------

Ns.ImprovedFae = {}

-- Buffs
Ns.manaTideCheck = {
	[16190] = true,
	[39609] = true,
	[39610] = true,
}

Ns.HeroicPresence = {
	[28878] = {1},
}

Ns.OutlandsBuffs = {
	[32071] = {0.05},
	[32049] = {0.05},
	[33779] = {0.05},
	[33377] = {0.05},
	[33795] = {0.05},
}

Ns.BladeBarrier = {
	[51789] = {1},
	[64855] = {2},
	[64856] = {3},
	[64858] = {4},
	[64859] = {5},
}

Ns.FrostPresence = {
	[48263] = {8},
}

Ns.Berserkering = {
	[26297] = {20},
}

Ns.Metamorphosis = {
	[47241] = {0.2, 6},
}

Ns.ArcaneEmpowerment = {
	[31579] = {0.01},
	[31582] = {0.02},
	[31583] = {0.03},
}

Ns.FerociousInspiration = {
	[75593] = {0.01},
	[75446] = {0.02},
	[75447] = {0.03},
}

Ns.ImprovedHMark = {
	[31579] = {0.01},
	[31582] = {0.02},
	[31583] = {0.03},
}

Ns.RenewedHope = {
	[57470] = {3},
	[63944] = {3},
}

Ns.DivinePlea = {
	[54428] = true,
}

Ns.RetributionAura = {
	[7294] = true, -- retribution
	[10298] = true,
	[10299] = true,
	[10300] = true,
	[10301] = true,
	[27150] = true,
	[54043] = true,
	[465] = true, -- devotion
	[10290] = true,
	[643] = true,
	[10291] = true,
	[1032] = true,
	[10292] = true,
	[10293] = true,
	[27149] = true,
	[48941] = true,
	[48942] = true,
	[19746] = true, -- concentration
	[48943] = true, -- shadow
	[48945] = true, -- frost
	[48947] = true, -- fire
	[32223] = true, -- crusader
}

Ns.Eradication = {
	[64371] = {20},
}

Ns.Berserker = {
	[1719] = {100},
}

Ns.Vigilance = {
	[50720] = {3},
}

Ns.RapidFire = {
	[3045] = {40},
}

Ns.Moonkin = {
	[24858] = true,
}

Ns.MoonkinAura = {
	[24907] = true,
}

Ns.ShamanisticRage = {
	[30823] = {30},
}

Ns.WindFuryTotem = {
	[8515] = {16},
}

Ns.MaelstromWeapon = {
	[53817] = {20},
}

Ns.MoltenArmor = {
	[30482] = {5},
}

Ns.BorrowedTime = {
	[59887] = {5},
	[59888] = {10},
	[59889] = {15},
	[59890] = {20},
	[59891] = {25},
}

Ns.SpellStones = {
	[3615] = {10},
	[3616] = {20},
	[3617] = {30},
	[3618] = {40},
	[3619] = {50},
	[3620] = {60},
}

Ns.levelRating = {
	[60] = {10},
	[70] = {15.76},
	[71] = {17.46},
	[72] = {19.17},
	[73] = {20.87},
	[74] = {22.57},
	[75] = {24.27},
	[76] = {25.98},
	[77] = {27.68},
	[78] = {29.38},
	[79] = {31.09},
	[80] = {32.79},
}

Ns.AncestralHealing = {
	[16177] = {3},
	[16236] = {7},
	[16237] = {10},
}

Ns.ArmyofDead = {
	[42650] = {0},
}

Ns.IceboundFort = {
	[48792] = {30},
}

Ns.AntiMagic = {
	[48707] = {10},
}

Ns.PowerInfusion = {
	[10060] = {20},
}

Ns.Inspiration = {
	[14893] = {3},
	[15357] = {7},
	[15359] = {10},
}

Ns.BlessingOfSanc = {
	[20911] = {3},
	[25899] = {3},
}

Ns.Desolation = {
	[66803] = {0.05},
}

Ns.RuneInvicibility = {
	[7865] = {5},
}

Ns.InnervateEffect = {
	[29166] = {2.25},
}

Ns.Heroism = {
	[32182] = {30},
}

Ns.BloodLust = {
	[2825] = {30},
}

Ns.BladeFlurry = {
	[13877] = {20},
}

Ns.IcyTalons = {
	[58578] = {20},
}

Ns.IcyTalonsImp = {
	[55610] = {20},
}

Ns.Combustion = {
	[28682] = {10},
}

Ns.ArcanePower = {
	[12042] = {0.2},
}

Ns.RighteousFury = {
	[25780] = true,
}

Ns.Vengeance = {
	[20050] = true,
	[20052] = true,
	[20053] = true,
}

Ns.IcyVeins = {
	[12472] = {20},
}

Ns.TouchOfShadow = {
	[18791] = {0.15},
}

Ns.BurningWish = {
	[18789] = {0.15},
}

Ns.DivineProtection = {
	[498] = {50},
}

Ns.MasterDemoImp = {
	[23825] = {1},
	[23826] = {2},
	[23827] = {3},
	[23828] = {4},
	[23829] = {5},
}

Ns.MasterDemoSucc = {
	[23832] = {1},
	[23833] = {2},
	[23834] = {3},
	[23835] = {4},
	[23836] = {5},
}

Ns.MasterDemoFel = {
	[30702] = {1},
	[30703] = {2},
	[30704] = {3},
	[30705] = {4},
	[30706] = {5},
}

Ns.FelEnergy = {
	[18792] = {0.03},
}

Ns.TreeOfLife = {
	[34123] = {0.06},
}

Ns.NaturesGrace = {
	[16886] = {20},
}

Ns.AspectOfViper = {
	[34074] = {0.04},
}

Ns.Evocation = {
	[12051] = {0.6},
}

Ns.AvengingWrath = {
	[31884] = {0.2},
}

Ns.Epiphany = {
	[28804] = {30},
}

Ns.ShadowForm = {
	[15473] = {0.15},
}

Ns.InnerFocus = {
	[14751] = {25},
}

Ns.ElementalMastery = {
	[64701] = {15},
}

Ns.Flurry = {
	[12966] = {5},
	[12967] = {10},
	[12968] = {15},
	[12969] = {20},
	[12970] = {25},
	-- [16257] = {6},
	-- [16277] = {12},
	-- [16278] = {18},
	-- [16279] = {24},
	-- [16280] = {30},
}

-- Ns.SliceAndDice = {
-- 	[5171] = {20},
-- 	[6774] = {40},
-- }

-- Ns.BladeFlurry = {
-- 	[13877] = {20},
-- }

-- Ns.IcyTalons = {
-- 	[58578] = {20},
-- }

Ns.IcyTalonsImp = {
	[55610] = {20},
}

Ns.TotemOfWrath = {
	[57658] = {3},
	[57660] = {3},
	[57662] = {3},
	[57663] = {3},
}

-- Ns.UnholyPresence = {
-- 	[48265] = {15},
-- }

Ns.WrathOfAir = {
	[2895] = {5},
}

Ns.QuickShots = {
	[6150] = {15},
}

-- Debuffs
Ns.Blood = {
	[30069] = {0.02},
	[30070] = {0.04},
}
Ns.Hemo = {
	[16511] = {13},
	[17347] = {21},
	[17348] = {29},
	[26864] = {42},
}
Ns.Stormstrike = {
	[17364] = {0.2},
}

Ns.HuntsMark = {
	[1130] = {20},
	[14323] = {45},
	[14324] = {75},
	[14325] = {110},
	[53338] = {500},
}

Ns.CurseOfEl = {
	[1490] = {0.06},
	[11721] = {0.08},
	[11722] = {0.10},
	[27228] = {0.11},
	[47865] = {0.13},
}

Ns.Misery = {
	[33196] = {1},
	[33197] = {2},
	[33198] = {3},
}

Ns.Scorpid = {
	[3043] = {3},
}

Ns.Insect = {
	[5570] = {3},
	[24974] = {3},
	[24975] = {3},
	[24976] = {3},
	[24977] = {3},
	[27013] = {3},
	[48468] = {3},
}

Ns.EbonPlaguebringer = {
	[51726] = {0.04},
	[51734] = {0.09},
	[51735] = {0.13},
}

Ns.EarthAndMoon = {
	[60431] = {0.04},
	[60432] = {0.09},
	[60433] = {0.13},
}

Ns.FrostFever = {
	[55095] = true,
}

Ns.BloodPlague = {
	[55078] = true,
}

Ns.HeartOfCrusader = {
	[21183] = {1},
	[54498] = {2},
	[54499] = {3},
}

Ns.MasterPoisoner = {
	[5760] = {0}, -- Mind-numbing
	[3409] = {0}, -- Crippling
	[2818] = {0}, -- Deadly
	[2819] = {0},
	[13218] = {0}, -- Wound Poison
	[13222] = {0},
	[13223] = {0},
	[13224] = {0},
	[27189] = {0},
	[57974] = {0},
	[57975] = {0},
	[11353] = {0},
	[11354] = {0},
	[25349] = {0},
	[26968] = {0},
	[27187] = {0},
	[57969] = {0},
	[57970] = {0},
}

Ns.ImprovedScorch = {
	[22959] = {5},
}

Ns.WintersChill = {
	[12579] = {1},
}

Ns.SavageCombat = {
	[58684] = {0.02},
	[58683] = {0.04},
}

Ns.ShadowMastery = {
	[17800] = {5},
}

Ns.Shatter = {
	[16928] = {200},
}

Ns.ImprovedFaerieFire = {
	[65863] = {1},
}

Ns.TrickTrade = {
	[57934] = {0.15},
}

Ns.WrynnSet = {
	[48372] = true, -- wrynn (10)
	[48375] = true,
	[48371] = true,
	[48373] = true,
	[48374] = true,
	[48376] = true, -- wrynn (25)
	[48377] = true,
	[48378] = true,
	[48379] = true,
	[48380] = true,
	[48385] = true, -- wrynn (25H)
	[48384] = true,
	[48383] = true,
	[48382] = true,
	[48381] = true,
	[48386] = true, -- hellscream (10)
	[48387] = true,
	[48388] = true,
	[48389] = true,
	[48390] = true,
	[48391] = true, -- hellscream (25)
	[48392] = true,
	[48393] = true,
	[48394] = true,
	[48395] = true,
	[48396] = true, -- hellscream (25H)
	[48397] = true,
	[48398] = true,
	[48399] = true,
	[48400] = true,
}

Ns.MaceEquipped = {
	[4] = true,
	[5] = true,
}

Ns.Enrage = {
	[5229] = true,
}

Ns.Hysteria = {
	[55213] = {0.4},
}

Ns.LashweaveSet = {
	[50824] = true, -- Lasherweave Battlegear (10)
	[50825] = true,
	[50826] = true,
	[50827] = true,
	[50828] = true,
	[51140] = true, -- Sanctified Lasherweave Battlegear (25)
	[51141] = true,
	[51142] = true,
	[51143] = true,
	[51144] = true,
	[51295] = true, -- Sanctified Lasherweave Battlegear (25H)
	[51296] = true,
	[51297] = true,
	[51298] = true,
	[51299] = true,
}

----------------------------------
--			GearScore			--
----------------------------------
Ns.GearScoreItems = {
	["INVTYPE_HEAD"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 1, ["Enchantable"] = true},
	["INVTYPE_NECK"] = {["SlotMOD"] = 0.5625, ["ItemSlot"] = 2, ["Enchantable"] = false},
    ["INVTYPE_SHOULDER"] = {["SlotMOD"] = 0.7500, ["ItemSlot"] = 3, ["Enchantable"] = true},
	["INVTYPE_BODY"] = {["SlotMOD"] = 0, ["ItemSlot"] = 4, ["Enchantable"] = false},
	["INVTYPE_CHEST"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 5, ["Enchantable"] = true},
    ["INVTYPE_ROBE"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 5, ["Enchantable"] = true},
    ["INVTYPE_WAIST"] = {["SlotMOD"] = 0.7500, ["ItemSlot"] = 6, ["Enchantable"] = false},
    ["INVTYPE_LEGS"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 7, ["Enchantable"] = true},
    ["INVTYPE_FEET"] = {["SlotMOD"] = 0.75, ["ItemSlot"] = 8, ["Enchantable"] = true},
    ["INVTYPE_WRIST"] = {["SlotMOD"] = 0.5625, ["ItemSlot"] = 9, ["Enchantable"] = true},
    ["INVTYPE_HAND"] = {["SlotMOD"] = 0.7500, ["ItemSlot"] = 10, ["Enchantable"] = true},
	["INVTYPE_CLOAK"] = {["SlotMOD"] = 0.5625, ["ItemSlot"] = 15, ["Enchantable"] = true},
    ["INVTYPE_2HWEAPON"] = {["SlotMOD"] = 2.000, ["ItemSlot"] = 16, ["Enchantable"] = true},
    ["INVTYPE_WEAPONMAINHAND"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 16, ["Enchantable"] = true},
    ["INVTYPE_WEAPONOFFHAND"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 17, ["Enchantable"] = true},
	["INVTYPE_HOLDABLE"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 17, ["Enchantable"] = false},
	["INVTYPE_SHIELD"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 17, ["Enchantable"] = true},
	["INVTYPE_RELIC"] = {["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = false},
    ["INVTYPE_RANGED"] = {["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = true},
    ["INVTYPE_THROWN"] = {["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = false},
    ["INVTYPE_RANGEDRIGHT"] = {["SlotMOD"] = 0.3164, ["ItemSlot"] = 18, ["Enchantable"] = false},
    ["INVTYPE_FINGER"] = {["SlotMOD"] = 0.5625, ["ItemSlot"] = 31, ["Enchantable"] = false},
	["INVTYPE_TRINKET"] = {["SlotMOD"] = 0.5625, ["ItemSlot"] = 33, ["Enchantable"] = false},
	["INVTYPE_WEAPON"] = {["SlotMOD"] = 1.0000, ["ItemSlot"] = 36, ["Enchantable"] = true},
}

Ns.GearScoreSettings = {
    ["Player"] = true,
    ["Item"] = true,
    ["Compare"] = true,
    ["Level"] = false,
}

Ns.GearScoreModifiers = {
    ["A"] = {
        [4] = {["A"] = 91.4500, ["B"] = 0.6500},
        [3] = {["A"] = 81.3750, ["B"] = 0.8125},
        [2] = {["A"] = 73.0000, ["B"] = 1.0000}
    },
    ["B"] = {
        [4] = {["A"] = 26.0000, ["B"] = 1.2000},
        [3] = {["A"] = 0.7500, ["B"] = 1.8000},
        [2] = {["A"] = 8.0000, ["B"] = 2.0000},
        [1] = {["A"] = 0.0000, ["B"] = 2.2500}
    }
}

Ns.GearScoreColor = {
    [6000] = {
        ["Red"] = {["A"] = 0.94, ["B"] = 5000, ["C"] = 0.00006, ["D"] = 1},
        ["Green"] = {["A"] = 0.47, ["B"] = 5000, ["C"] = 0.00047, ["D"] = -1},
        ["Blue"] = {["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0},
        ["Description"] = "Legendary"
    },
    [5000] = {
        ["Red"] = {["A"] = 0.69, ["B"] = 4000, ["C"] = 0.00025, ["D"] = 1},
        ["Green"] = {["A"] = 0.28, ["B"] = 4000, ["C"] = 0.00019, ["D"] = 1},
        ["Blue"] = {["A"] = 0.97, ["B"] = 4000, ["C"] = 0.00096, ["D"] = -1},
        ["Description"] = "Epic"
    },
    [4000] = {
        ["Red"] = {["A"] = 0.0, ["B"] = 3000, ["C"] = 0.00069, ["D"] = 1},
        ["Green"] = {["A"] = 0.5, ["B"] = 3000, ["C"] = 0.00022, ["D"] = -1},
        ["Blue"] = {["A"] = 1, ["B"] = 3000, ["C"] = 0.00003, ["D"] = -1},
        ["Description"] = "Superior"
    },
    [3000] = {
        ["Red"] = {["A"] = 0.12, ["B"] = 2000, ["C"] = 0.00012, ["D"] = -1},
        ["Green"] = {["A"] = 1, ["B"] = 2000, ["C"] = 0.00050, ["D"] = -1},
        ["Blue"] = {["A"] = 0, ["B"] = 2000, ["C"] = 0.001, ["D"] = 1},
        ["Description"] = "Uncommon"
    },
    [2000] = {
        ["Red"] = {["A"] = 1, ["B"] = 1000, ["C"] = 0.00088, ["D"] = -1},
        ["Green"] = {["A"] = 1, ["B"] = 000, ["C"] = 0.00000, ["D"] = 0},
        ["Blue"] = {["A"] = 1, ["B"] = 1000, ["C"] = 0.001, ["D"] = -1},
        ["Description"] = "Common"
    },
    [1000] = {
        ["Red"] = {["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1},
        ["Green"] = {["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1},
        ["Blue"] = {["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1},
        ["Description"] = "Trash"
    }
}