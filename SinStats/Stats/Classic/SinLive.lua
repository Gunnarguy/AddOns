local AddName, Ns = ...
local L = Ns.L


----------------------
--		SinLive		--
----------------------
function Ns.SinLive(self)

Ns.huntersMark, Ns.debuffCount, Ns.exposeWeakness = 0, 0, 0
	
	for i = 1, 40 do
	local _, _, dcount, _, _, _, _, _, _, debuffId = UnitDebuff("target", i)
		if not debuffId then break end
		
		local targetGUID = UnitGUID("target")
		
		if debuffId then
			Ns.debuffCount = i
		end
		
		Ns.debuffCount = Ns.debuffCount
		
		if Ns.HuntsMark[debuffId] then
			Ns.huntersMark = Ns.HuntsMark[debuffId][1]
		end
		
		if Ns.ExposeWeakness[debuffId] then
			Ns.exposeWeakness = Ns.ExposeWeakness[debuffId][1]
		end
		
	end
end