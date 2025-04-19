local AddName, Ns = ...
local L = Ns.L


--------------------------
--		Stat Init		--
--------------------------

Ns.greenText, Ns.redText, Ns.orangeText, Ns.blueText, Ns.purpleText, Ns.whiteText = "|cff71FFC9", "|cffC41E3A", "|cffFF7C0A", "|cff0070FF", "|cffA335EE", "|cffffffff"
Ns.classFilename = select(2, UnitClass("player"))
Ns.classId = select(3, UnitClass("player"))
Ns.shatteringStar, Ns.combustion, Ns.luckOfDraw, Ns.percentLoamm = 0, 0, 0, 0
Ns.masteryFx, Ns.delver = 0, 0
-- evoker
Ns.InstinctArcana, Ns.iridescence, Ns.ebonMight = 0, 0, 0
-- monk
Ns.mysticTouch, Ns.jadeFire, Ns.serenity, Ns.hitCombo = 0, 0, 0, 0
Ns.ferocityXuen, Ns.FerocityXuen, Ns.martial, Ns.MartialInstincts = 0, 0, 0, 0
-- mage
Ns.arcaneSurge, Ns.enlightened, Ns.impetus = 0, 0, 0
-- dh
Ns.chaosBrand, Ns.demonSoul = 0, 0
-- rogue
Ns.betweenEyes, Ns.symbolsDeath, Ns.ghostlyStrike = 0, 0, 0
-- warrior
Ns.colossusSmash, Ns.avatar, Ns.battleShout, Ns.defStance = 0, 0, 0, 0
Ns.enrage = false
-- dk
Ns.razorIce = 0
-- warlock
Ns.felSunder, Ns.eradication, Ns.demonicSynergy = 0, 0, 0
-- mage
Ns.overflowEnergy, Ns.runePower, Ns.incanterFlow, Ns.touchOfIce = 0, 0, 0, 0
-- priest
Ns.shadowForm = 0
-- hunter
Ns.LoneWolf, Ns.barbedShot, Ns.bestialWrath, Ns.huntersMark = 0, 0, 0, 0
-- druid
Ns.tigersFury = 0
-- paladin
Ns.finalReck, Ns.retAura, Ns.avWrath = 0, 0, 0
-- demon hunter
Ns.momentum, Ns.seethChaos, Ns.inertia = 0, 0, 0
-- shaman
Ns.equilibrium, Ns.Equilibrium, Ns.feralSpirit = 0, 0, 0
-- druid
Ns.friendFae, Ns.wanTwilight = 0, 0

--------------------------
--		ID Tables		--
--------------------------

Ns.ShatteringStar = {
	[370452] = {0.2},
}

Ns.GhostlyStrike = {
	[196937] = {0.15},
}

Ns.FriendFae = {
	[394083] = {10},
}

Ns.Delver = {
	[455329] = {10},
}

Ns.WaningTwilight = {
	[393957] = {6},
}

Ns.Momentum = {
	[208628] = {8},
}

Ns.Enrage = {
	[184362] = {22},
}

Ns.Impetus = {
	[393939] = {10},
}

Ns.HuntersMark = {
	[257284] = {0.08},
}

Ns.Combustion = {
	[190319] = {100},
}

Ns.ArcaneSurge = {
	[365362] = {35},
}

Ns.Enlightened = {
	[321388] = {6},
}

Ns.AvengeWrath = {
	[31884] = {20},
}

Ns.SymbolsDeath = {
	[212283] = {10},
}

Ns.Iridescence = {
	[386399] = {20},
}

Ns.BetweenEyes = {
	[315341] = {20},
}

Ns.ChaosBrand = {
	[1490] = {0.03},
}

Ns.MysticTouch = {
	[113746] = {0.05},
}

Ns.ColossusSmash = {
	[208086] = {0.3},
}

Ns.ElementalEquilibrium = {
	[378275] = true,
}

Ns.LoneWolf = {
	[164273] = {5},
}

Ns.RazorIce = {
	[51714] = true,
}

Ns.FelSunder = {
	[387402] = true,
}

Ns.Jadefire = {
	[395414] = {0.06},
}

Ns.EbonMight = {
	[395296] = {0.14},
}

Ns.Serenity = {
	[152173] = {0.15},
}

Ns.Overflowing = {
	[394195] = true,
}

Ns.LuckOfTheDraw = {
	[72221] = true,
}

Ns.HitCombo = {
	[196741] = true,
}

Ns.Shadowform = {
	[232698] = {0.10},
}

Ns.Brittle = {
	[374557] = {0.06},
}

Ns.TigersFury = {
	[5217] = {15},
}

Ns.Eradication = {
	[196414] = {5},
}

Ns.RuneOfPower = {
	[116014] = {0.40},
}

Ns.IncanterFlow = {
	[116267] = true,
}

Ns.DemonSoul = {
	[347765] = {20},
}

Ns.FinalReckoning = {
	[343721] = {30},

}

Ns.TouchOfIce = {
	[394994] = {0.08},
}

Ns.DemonicSynergy = {
	[171982] = {0.1},
}

Ns.SeethChaos = {
	[394934] = {0.05},
}

Ns.Avatar = {
	[107574] = {20},
}

Ns.BattleShout = {
	[6673] = {5},
}

Ns.RetAura = {
	[404996] = {5},
}

Ns.Inertia = {
	[427641] = {18},
}

Ns.Crest = {
	Whelp = {"211520", "211520", "211520"},
	Drake = {204195},
	Wyrm = {"211518", "211518", "211518"},
	Aspect = {"211519", "211519", "211519"},
}

Ns.Spark = {
	Shadowflame = 204440,
	Ingenuity = 190453,
	Dreams = 206959,
	splDreams = 208396,
	Awake = 211516,
	splAwake = 211515,
}

Ns.DefStance = {
	[386208] = {10},
}

Ns.FeralSpirit = {
	[333957] = {15},
}

Ns.BarbedShot = {
	[272790] = {3},
}

Ns.Seeds = {
	Gigantic = 208047,
	Plump = 208067,
	Bloom = 211376,
}

Ns.BestialWrath = {
	[19574] = {25},
}