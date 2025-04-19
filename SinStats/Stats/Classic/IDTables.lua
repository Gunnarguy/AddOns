local AddName, Ns = ...
local L = Ns.L


--------------------------
--		Stat Init		--
--------------------------

-- character and npc 
Ns.raceId = select(3, UnitRace("player"))
Ns.classFilename = select(2, UnitClass("player"))
Ns.greenText, Ns.redText, Ns.orangeText = "|cff71FFC9", "|cffC41E3A", "|cffFF7C0A"

--mage
Ns.pierceMod, Ns.aiMod, Ns.arcaneFocus, Ns.arcaneMod = 0, 0, 0, 0
Ns.arcanePower, Ns.apFrost, Ns.apFire, Ns.firepowerMod, Ns.combustionCount = 0, 0, 0, 0, 0
-- paladin
Ns.vengeance, Ns.wisTalent, Ns.sancAura = 0, 0, 0
-- shaman
Ns.purification, Ns.emberstorm = 0, 0 
-- warlock
Ns.shadowMastery, Ns.dsSuc, Ns.dsImp = 0, 0, 0
-- priest
Ns.DarkNessTalent, Ns.spiritualHealing, Ns.shadowFormDmg = 0, 0, 0
-- hunter
Ns.huntersMark = 0
-- other
Ns.hitMod, Ns.dmfbuff, Ns.silithyst, Ns.spellCritMod, Ns.speedColor, Ns.labelSpellCrit, Ns.labelHit = 0, 0, 0, 0, 0, "", ""
Ns.playerLevel = UnitLevel("player")
Ns.weaponTag = "Weapon"
Ns.headerLoc = "Weapon Skills"
Ns.defenseLoc = DEFENSE
Ns.weaponID = 2
Ns.spirit = 0
Ns.meleeHaste, Ns.castHaste, Ns.totalHaste, Ns.totalRangedHaste = 0, 0, 0, 0
Ns.totalMP5, Ns.totalMP2, Ns.castingMP2, Ns.buffCount, Ns.debuffCount, Ns.castingMP5 = 0, 0, 0, 0, 0, 0

--------------------------------------
--		Defense Localization		--
--------------------------------------
if (GetLocale() == "frFR") then
	Ns.headerLoc = "Compétences d’armes"
	Ns.defenseLoc = DEFENSE
	Ns.weaponTag = "Arme"
elseif (GetLocale() == "esES") then
	Ns.weaponTag = "Arma"
	Ns.headerLoc = "Habilidades con armas"
	Ns.defenseLoc = DEFENSE	
elseif (GetLocale() == "deDE") then
	Ns.weaponTag = "Waffe"
	Ns.headerLoc = "Waffenfertigkeiten"
	Ns.defenseLoc = DEFENSE		
elseif (GetLocale() == "itIT") then
	Ns.weaponTag = "Arma"
	Ns.headerLoc = "Abilità con le armi"
	Ns.defenseLoc = DEFENSE		
elseif (GetLocale() == "ruRU") then
	Ns.weaponTag = "Oружие"
	Ns.headerLoc = "Оружейные навыки"
	Ns.defenseLoc = DEFENSE		
elseif (GetLocale() == "ptBR") then
	Ns.weaponTag = "Arma"
	Ns.headerLoc = "Weapon Skills"
	Ns.defenseLoc = DEFENSE	
elseif (GetLocale() == "zhCN") then
	Ns.headerLoc = "武器技能"
	Ns.defenseLoc = DEFENSE	
elseif (GetLocale() == "koKR") then
	Ns.headerLoc = "무기 기술"
	Ns.defenseLoc = "방어"	
elseif (GetLocale() == "zhTW") then
	Ns.headerLoc = "武器技能"
	Ns.defenseLoc = DEFENSE		
else 
	Ns.weaponTag = "Weapon"
	Ns.headerLoc = "Weapon Skills"
	Ns.defenseLoc = DEFENSE	
end

Ns.HuntsMark = {
	[1130] = {20},
	[14323] = {45},
	[14324] = {75},
	[14325] = {110},
}

Ns.ExposeWeakness = {
	[23577] = {450},
}