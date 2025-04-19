local _, Ns = ...

----------------------
--		SinLive		--
----------------------
function Ns.SinLive(self)

	Ns.shatteringStar, Ns.betweenEyes = 0, 0
	Ns.chaosBrand, Ns.mysticTouch, Ns.colossusSmash, Ns.razorIce = 0, 0, 0, 0
	Ns.felSunder, Ns.jadeFire, Ns.brittle, Ns.eradication = 0, 0, 0, 0
	Ns.finalReck = 0
	Ns.ghostlyStrike, Ns.wanTwilight, Ns.huntersMark = 0, 0, 0

	for i = 1, 40 do
	local debuff = C_UnitAuras.GetAuraDataByIndex("target",i, "HARMFUL")
	if not debuff then break end

	if Ns.ChaosBrand[debuff.spellId] then Ns.chaosBrand = Ns.ChaosBrand[debuff.spellId][1] end
	if Ns.MysticTouch[debuff.spellId] then Ns.mysticTouch = Ns.MysticTouch[debuff.spellId][1] end

	if debuff.sourceUnit == "player" then
		if Ns.ShatteringStar[debuff.spellId] then Ns.shatteringStar = Ns.ShatteringStar[debuff.spellId][1] end
		if Ns.Brittle[debuff.spellId] then Ns.brittle = Ns.Brittle[debuff.spellId][1] end
		if Ns.FinalReckoning[debuff.spellId] then Ns.finalReck = Ns.FinalReckoning[debuff.spellId][1] end
		if Ns.ColossusSmash[debuff.spellId] then Ns.colossusSmash = Ns.ColossusSmash[debuff.spellId][1] end
		if Ns.RazorIce[debuff.spellId] then Ns.razorIce = debuff.applications * 3 / 100 end
		if Ns.FelSunder[debuff.spellId] then Ns.felSunder = debuff.applications / 100 end
	 	if Ns.Jadefire[debuff.spellId] then Ns.jadeFire = Ns.Jadefire[debuff.spellId][1] end
		if Ns.WaningTwilight[debuff.spellId] then Ns.wanTwilight = Ns.WaningTwilight[debuff.spellId][1] end
		if Ns.BetweenEyes[debuff.spellId] then Ns.betweenEyes = Ns.BetweenEyes[debuff.spellId][1] end
		if Ns.GhostlyStrike[debuff.spellId] then Ns.ghostlyStrike = Ns.GhostlyStrike[debuff.spellId][1] end
		if Ns.Eradication[debuff.spellId] then Ns.eradication = Ns.Eradication[debuff.spellId][1] end
	end

		--health percentage-based debuffs
		local health = UnitHealth("target")
		local maxHealth = UnitHealthMax("target")
		local percentHealth = (health / maxHealth) * 100
		if Ns.HuntersMark[debuff.spellId] and percentHealth >= 80 then
			Ns.huntersMark = Ns.HuntersMark[debuff.spellId][1]
		end

	end
end