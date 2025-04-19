local _, Ns = ...

----------------------------
-- Local Helper Functions --
----------------------------

-- Number shorterner
function Ns.ShortNumbers(num, places)
    local ret
    local placeValue = ("%%.%df"):format(places or 0)
    if not num then return 0
	elseif num < 1000 then return num
    elseif num < 1000000 then ret = placeValue:format(num / 1000) .. "k"
	elseif num >= 1000000 then ret = placeValue:format(num / 1000000) .. "M"
	else ret = num -- hundreds
    end
    return ret
end

function Ns.StatsCompute()

	-- Init
	Ns.combustion, Ns.serenity, Ns.overflowEnergy, Ns.luckOfDraw = 0, 0, 0, 0
	Ns.hitCombo, Ns.shadowForm, Ns.loneWolf, Ns.runePower = 0, 0, 0, 0
	Ns.incanterFlow, Ns.demonSoul, Ns.tigersFury, Ns.momentum = 0, 0, 0, 0
	Ns.touchOfIce, Ns.demonicSynergy, Ns.seethChaos, Ns.equilibrium = 0, 0, 0, 0
	Ns.iridescence, Ns.arcaneSurge, Ns.enlightened, Ns.symbolsDeath = 0, 0, 0, 0
	Ns.ebonMight, Ns.avatar, Ns.battleShout, Ns.defStance, Ns.feralSpirit = 0, 0, 0, 0, 0
	Ns.bestialWrath, Ns.friendFae, Ns.retAura, Ns.inertia = 0, 0, 0, 0
	Ns.avWrath, Ns.delver, Ns.impetus, Ns.enrage = 0, 0, 0, false

	for i = 1, 40 do
		local aura = C_UnitAuras.GetAuraDataByIndex("player",i, "HELPFUL")

		if not aura then break end

		if Ns.Combustion[aura.spellId] then Ns.combustion = Ns.Combustion[aura.spellId][1] end
		if Ns.Serenity[aura.spellId] then Ns.serenity = Ns.Serenity[aura.spellId][1] end
		if Ns.Overflowing[aura.spellId] then Ns.overflowEnergy = aura.applications * 2 end
		if Ns.LuckOfTheDraw[aura.spellId] then Ns.luckOfDraw = ((aura.applications * 5) / 100 ) end
		if Ns.HitCombo[aura.spellId] then Ns.hitCombo = aura.applications end
		if Ns.Shadowform[aura.spellId] then Ns.shadowForm = Ns.Shadowform[aura.spellId][1] end
		if Ns.LoneWolf[aura.spellId] then Ns.loneWolf = Ns.LoneWolf[aura.spellId][1] end
		if Ns.RuneOfPower[aura.spellId] then Ns.runePower = Ns.RuneOfPower[aura.spellId][1] end
		if Ns.DemonSoul[aura.spellId] then Ns.demonSoul = Ns.DemonSoul[aura.spellId][1] end
		if Ns.TigersFury[aura.spellId] then Ns.tigersFury = Ns.TigersFury[aura.spellId][1] end
		if Ns.Momentum[aura.spellId] then Ns.momentum = Ns.Momentum[aura.spellId][1] end
		if Ns.TouchOfIce[aura.spellId] then Ns.touchOfIce = Ns.TouchOfIce[aura.spellId][1] end
		if Ns.SeethChaos[aura.spellId] then Ns.seethChaos = Ns.SeethChaos[aura.spellId][1] end
		if Ns.DemonicSynergy[aura.spellId] then Ns.demonicSynergy = Ns.DemonicSynergy[aura.spellId][1] end
		if Ns.IncanterFlow[aura.spellId] then Ns.incanterFlow = aura.applications * 4 end
		if Ns.ElementalEquilibrium[aura.spellId] then Ns.equilibrium = Ns.Equilibrium end
		if Ns.Iridescence[aura.spellId] then Ns.iridescence = Ns.Iridescence[aura.spellId][1] end
		if Ns.ArcaneSurge[aura.spellId] then Ns.arcaneSurge = Ns.ArcaneSurge[aura.spellId][1] end
		if Ns.Enlightened[aura.spellId] then Ns.enlightened = Ns.Enlightened[aura.spellId][1] end
		if Ns.Enrage[aura.spellId] then Ns.enrage = true end
		if Ns.SymbolsDeath[aura.spellId] then Ns.symbolsDeath = Ns.SymbolsDeath[aura.spellId][1] end
		if Ns.EbonMight[aura.spellId] then Ns.ebonMight = Ns.EbonMight[aura.spellId][1] end
		if Ns.Avatar[aura.spellId] then Ns.avatar = Ns.Avatar[aura.spellId][1] end
		if Ns.BattleShout[aura.spellId] then Ns.battleShout = Ns.BattleShout[aura.spellId][1] end
		if Ns.DefStance[aura.spellId] then Ns.defStance = Ns.DefStance[aura.spellId][1] end
		if Ns.FeralSpirit[aura.spellId] then Ns.feralSpirit = Ns.FeralSpirit[aura.spellId][1] end
		if Ns.BestialWrath[aura.spellId] then Ns.bestialWrath = Ns.BestialWrath[aura.spellId][1] end
		if Ns.FriendFae[aura.spellId] then Ns.friendFae = Ns.FriendFae[aura.spellId][1] end
		if Ns.AvengeWrath[aura.spellId] then Ns.avWrath = Ns.AvengeWrath[aura.spellId][1] end
		if Ns.RetAura[aura.spellId] then Ns.retAura = Ns.RetAura[aura.spellId][1] end
		if Ns.Inertia[aura.spellId] then Ns.inertia = Ns.Inertia[aura.spellId][1] end
		if Ns.Delver[aura.spellId] then Ns.delver = Ns.Delver[aura.spellId][1] end
		if Ns.Impetus[aura.spellId] then Ns.impetus = Ns.Impetus[aura.spellId][1] end

	end
end

--------------------------------------
--		Global OnEvent function		--
--------------------------------------
function Ns.OnEventFunc(event, ...)

	if event == "PLAYER_TARGET_CHANGED" then
	-----	
		local exists = UnitExists("target")
		local hostile = UnitCanAttack("player", "target")

		if hostile or not exists then Ns.SinLive() end
	-----
	elseif event == "UPDATE_FACTION" then
	-----
		local currentXP = C_MajorFactions.GetMajorFactionData(2564)
		Ns.percentLoamm = 0
		if currentXP == nil then currentXP = 0 end
		Ns.percentLoamm = currentXP.renownReputationEarned
		Ns.percentLoamm = (Ns.percentLoamm * 0.04)
	-----
	elseif event == "TRAIT_CONFIG_UPDATED" then
		Ns.talentScan()
	-----
	else
	-----	

	-- SinLive
	local unit = ...
	if unit == "target" then Ns.SinLive() return end

	Ns.StatsCompute()

end -- end events
end -- end function