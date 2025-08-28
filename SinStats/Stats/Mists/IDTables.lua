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
Ns.BeastSlaying, Ns.hunterHaste = 0, 0
Ns.playerLevel = UnitLevel("player")
Ns.repairTooltip = CreateFrame("GameTooltip", "SinStatsTooltip", nil, "GameTooltipTemplate")
Ns.repairTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
Ns.SavedTarget = 0
-- general
Ns.armorValue, Ns.armorDebuff, Ns.Resilvalue, Ns.defenseRating, Ns.gearDefense = 0, 0, 0, 0, 0
Ns.bowSpec, Ns.lightBreath = 0, 0
Ns.debuffCount, Ns.shatterArmor, Ns.targetArmorReduced, Ns.targetArmor = 0, 0, 0, 0
Ns.inspiSpellHit, Ns.critSpellChance, Ns.regenBase, Ns.regenCasting, Ns.Shatter, Ns.feroInspiration = 0, 0, 0, 0, 0, 0
Ns.buffCount, Ns.zoneBuff = 0, 0
Ns.dodgeChance, Ns.parryChance, Ns.blockChance, Ns.avoid = 0, 0, 0, 0
Ns.dwarfRacial, Ns.quickness, Ns.weaponTag, Ns.talentThrottle, Ns.commEffect, Ns.canInspect = false, 0, 2, false, 0, nil
Ns.meleeCrit, Ns.spellCrit, Ns.rangedCrit, Ns.meleeMissTracker, Ns.spellMissTracker, Ns.rangedMissTracker, Ns.totalParryDodge = 0, 0, 0, 0, 0, 0, 0
Ns.critReceived, Ns.totalDodge, Ns.totalParry, Ns.totalBlock, Ns.simEnabled, Ns.classDR, Ns.buffDR, Ns.auraDR = 0, 0, 0, 0, 0, 1, 1, 1
Ns.stoneForm, Ns.armorReduction, Ns.fullDR = 0, 0, 0

-- death knight
Ns.armyDead, Ns.bloodPresence, Ns.iceFortitude, Ns.BladeBarrier, Ns.scarletFever = 0, 0, 0, 0, 0
Ns.boneShield, Ns.SanguineFort, Ns.ImpBlood, Ns.impBlood, Ns.willNecro = 0, 0, 0, 0, 0
Ns.WillNecropolis, Ns.brittleBones, Ns.FrozenWastes = 0, 0, 0
-- druid
Ns.moonSpell, Ns.moonDmg, Ns.eclipseLunar, Ns.earthMoon, Ns.EarthMoonTalent = 0, 0, 0, 0, 0
Ns.owlFrenzy, Ns.ThickHide, Ns.NaturalReaction, Ns.naturalReaction, Ns.survInstinct = 0, 0, 0, 0, 0
Ns.barkCrit, Ns.barkskin, Ns.treeofLife, Ns.faerieFire, Ns.innervate = 0, 0, 0, 0, 0
-- warrior
Ns.BastionDefense, Ns.safeGuard, Ns.shieldWall, Ns.deathWish, Ns.reckless = 0, 0, 0, 0, 0
Ns.bloodFrenzy, Ns.sunderArmor = 0, 0
-- shaman
Ns.flameTongue, Ns.rockBiter, Ns.elePrecision, Ns.eleOath, Ns.masterySpell, Ns.masteryDmg = 0, 0, 0, 0, 0, 0
Ns.flameTongueOH, Ns.shamRage, Ns.AncResolve, Ns.ancResolve, Ns.SparkLife, Ns.ancFort = 0, 0, 0, 0, 0, 0
Ns.eleWeapons = 0
-- paladin
Ns.divinity, Ns.Communion, Ns.auraSpell, Ns.sancCrit, Ns.sancDmg, Ns.vindication = 0, 0, 0, 0, 0, 0
Ns.ardentDef, Ns.ancientKings, Ns.conviction, Ns.divineProt, Ns.avenWrath = 0, 0, 0, 0, 0
--mage
Ns.invocation, Ns.invoCount, Ns.arcaneTactics, Ns.arcPotency, Ns.moltenFury, Ns.MoltenFury = 0, 0, 0, 0, 0, 0
Ns.PrismaticCloak, Ns.moltenArmor, Ns.arcanePower, Ns.evoc, Ns.firePower = 0, 0, 0, 0, 0
-- warlock
Ns.curseElements, Ns.deathEmbrace, Ns.DeathEmbrace, Ns.shadowandFlame, Ns.ImpSoulFire = 0, 0, 0, 0, 0
Ns.curseWeak, Ns.soulFire, Ns.DemonicPact = 0, 0, 0
-- rogue
Ns.exposeArmor, Ns.savageCombat, Ns.bladeFlurry, Ns.masterPoisoner, Ns.trickTrade = 0, 0, 0, 0, 0
Ns.DeadNerves = 0
-- priest
Ns.archangel, Ns.painSuppress, Ns.focusWill, Ns.FocusWillTalent, Ns.powerBarrier = 0, 0, 0, 0, 0
Ns.TwistedFaith, Ns.shadowForm, Ns.dispDmg, Ns.dispRegen, Ns.inspiration = 0, 0, 0, 0, 0
-- hunter
Ns.huntersMark, Ns.feroInspiration, Ns.NoEscape, Ns.noEscape = 0, 0, 0, 0


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

-- Buffs

Ns.Flametongue = {
	[5] = {0.05}, -- flametongue
}

Ns.Rockbiter = {
	[3021] = {5}, -- rockbiter
}

Ns.Stoneform = {
	[65116] = {10},
}

Ns.ScarletFever = {
	[96265] = {5},
	[81130] = {10},
}

Ns.AncFortitude = {
	[16177] = {5},
	[16236] = {10},
}

Ns.BoneShield = {
	[49222] = {20},
}

Ns.WillNecro = {
	[81162] = true,
}

Ns.LightningBreath = {
	[24844] = {0.08},
}

Ns.OwlFrenzy = {
	[48391] = {0.1},
}

Ns.BrittleBones = {
	[81325] = {0.02},
	[81326] = {0.04},
}

Ns.Barkskin = {
	[22812] = {20},
}

Ns.Amberskin = {
	[63058] = {25},
}

Ns.SurvInstinct = {
	[61336] = {50},
}

Ns.ShamRage = {
	[30823] = {30},
}

Ns.SafeGuard = {
	[46946] = {15},
	[46947] = {30},
}

Ns.ShieldWall = {
	[871] = {40},
}

Ns.EarthMoon = {
	[60433] = {0.08},
}

Ns.DeathWish = {
	[12292] = {20},
}

Ns.Reckless = {
	[1719] = {20},
}

Ns.ElementalOath = {
	[51466] = {0.05},
	[51470] = {0.1},
}

Ns.ElementalMastery = {
	[64701] = {0.15, 20},
}

Ns.OutlandsBuffs = {
	[32071] = {0.05},
	[32049] = {0.05},
	[33779] = {0.05},
	[33377] = {0.05},
	[33795] = {0.05},
}

Ns.HunterTraps = {
	[3355] = true,
	[13810] = true,
}

Ns.BloodPresence = {
	[48263] = {8},
}

Ns.Vindication = {
	[26017] = {10},
}

Ns.Conviction = {
	[20050] = {0.01},
	[20052] = {0.02},
	[20053] = {0.03},
}

Ns.AncientKings = {
	[86150] = {50},
}

Ns.ArdentDef = {
	[31850] = {20},
}

Ns.Metamorphosis = {
	[47241] = {0.2, 6},
}

Ns.Archangel = {
	[81700] = {0.03},
}

Ns.FerociousInspiration = {
	[75447] = {0.03},
}

Ns.SoulFire = {
	[85383] = true,
}

Ns.PainSuppress = {
	[33206] = {40},
}

Ns.FocusWill = {
	[45242] = true,
}

Ns.PowerBarrier = {
	[81782] = {25},
}

Ns.RetributionAura = {
	[7294] = true, -- retribution
	[465] = true, -- devotion
	[19746] = true, -- concentration
	[19891] = true, -- resistance
	[32223] = true, -- crusader
}

Ns.Moonkin = {
	[24858] = {0.1, 15},
}

Ns.EclipseLunar = {
	[48518] = {0.25},
}

Ns.ShamanisticRage = {
	[30823] = {30},
}

Ns.MoltenArmor = {
	[30482] = {5},
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

Ns.ArmyofDead = {
	[42650] = {0},
}

Ns.IceFortitude = {
	[48792] = {20},
}

Ns.AntiMagic = {
	[48707] = {10},
}

Ns.Inspiration = {
	[14893] = {5},
	[15357] = {10},
}

Ns.Innervate = {
	[29166] = {0.2,0.05},
}

Ns.BladeFlurry = {
	[13877] = {20},
}

Ns.ArcanePower = {
	[12042] = {0.2},
}

Ns.RighteousFury = {
	[25780] = true,
}

Ns.DivineProtection = {
	[498] = {20},
}

Ns.ShadowAndFlame = {
	[17800] = {5},
}

Ns.TreeOfLife = {
	[33891] = {0.15},
}

Ns.Evocation = {
	[12051] = {0.45},
}

Ns.AvengingWrath = {
	[31884] = {0.2},
}

Ns.ShadowForm = {
	[15473] = {15},
}

Ns.Dispersion = {
	[47585] = {90, 0.06},
}

Ns.WrathOfAir = {
	[2895] = {5},
}

-- Debuffs
Ns.Blood = {
	[30069] = {0.02},
	[30070] = {0.04},
}

Ns.HuntsMark = {
	[1130] = {20},
}

Ns.CurseElements = {
	[1490] = {0.08},
}

Ns.CurseWeak = {
	[702] = {10},
}

Ns.BloodPlague = {
	[55078] = true,
}

Ns.MasterPoisoner = {
	[93068] = {0.05},
}

Ns.SavageCombat = {
	[58684] = {0.02},
	[58683] = {0.04},
}

Ns.Shatter = {
	[16928] = {200},
}

Ns.TrickTrade = {
	[57934] = {0.15},
}

Ns.MaceEquipped = {
	[4] = true,
	[5] = true,
}

Ns.Enrage = {
	[5229] = true,
}

-- Mage
Ns.Invocation = {
	[87098] = true,
}

Ns.ArcaneTactics = {
	[82930] = {0.03},
}

Ns.ArcPotency = {
	[57531] = true,
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