local AddName, Ns = ...

function Ns.IsSpellTalented(spellID)
    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if configInfo == nil then return end

    for _, treeID in ipairs(configInfo.treeIDs) do
        local nodes = C_Traits.GetTreeNodes(treeID)
        for i, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                if entryInfo and entryInfo.definitionID then
                    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                    if definitionInfo.spellID == spellID then
                        return configID, nodeID
                    end
                end
            end
        end
    end
    return false
end

function Ns.talentScan()
	local classFilename = select(2, UnitClass("player"))

	if classFilename == "EVOKER" then
		if IsPlayerSpell(376164) then
			Ns.InstinctArcana = C_Traits.GetNodeInfo(Ns.IsSpellTalented(376164))
			Ns.InstinctArcana = Ns.InstinctArcana.ranksPurchased * 2
		end
	end

	if classFilename == "MONK" then
		if IsPlayerSpell(388674) then
			Ns.FerocityXuen = C_Traits.GetNodeInfo(Ns.IsSpellTalented(388674))
			Ns.ferocityXuen = Ns.FerocityXuen.ranksPurchased * 2
		end
		if IsPlayerSpell(450427) then
			Ns.MartialInstincts = C_Traits.GetNodeInfo(Ns.IsSpellTalented(450427))
			Ns.martial = Ns.MartialInstincts.ranksPurchased * 2
		end
	end

	if classFilename == "SHAMAN" then
		if IsPlayerSpell(378271) then
			Ns.Equilibrium = C_Traits.GetNodeInfo(Ns.IsSpellTalented(378271))
			Ns.Equilibrium = Ns.Equilibrium.ranksPurchased
			if (Ns.Equilibrium == 1) then Ns.Equilibrium = 8
			else Ns.Equilibrium = 15
			end
		end
	end

end

