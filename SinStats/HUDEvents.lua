local _, Ns = ...

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)

	if event == "PET_BATTLE_OPENING_START" then
		Ns.Profile.HideHUD = true
		SinStatsFrame.HUD:Hide()
	elseif event == "PET_BATTLE_OVER" then
		Ns.Profile.HideHUD = false
		SinStatsFrame.HUD:Show()
	end

	if event == "PLAYER_ENTERING_WORLD" then

--	local isInitialLogin, isReloadingUi = ...
--	if isInitialLogin then
--		C_Timer.After(1, Ns.ResizeBackground)
--	end

if Ns.Profile.EventEnable then
	local inInstance, instanceType = IsInInstance()
	
	if (Ns.Profile.EventDungeon and instanceType == "party" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = false
		SinStatsFrame.HUD:Show()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (Ns.Profile.EventDungeon and not inInstance and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (not Ns.Profile.EventDungeon and Ns.eventChecked and instanceType == "party" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	end
	
	if (Ns.Profile.EventRaid and instanceType == "raids" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = false	
		SinStatsFrame.HUD:Show()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (Ns.Profile.EventRaid and not inInstance and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (not Ns.Profile.EventRaid and Ns.eventChecked and instanceType == "raids" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	end
	
	if (Ns.Profile.EventPvP and instanceType == "pvp" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat ) then
		Ns.Profile.HideHUD = false	
		SinStatsFrame.HUD:Show()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (Ns.Profile.EventPvP and not inInstance and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (not Ns.Profile.EventPvP and Ns.eventChecked and instanceType == "pvp" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	end	

	if (Ns.Profile.EventArena and instanceType == "arena" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = false	
		SinStatsFrame.HUD:Show()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (Ns.Profile.EventArena and not inInstance and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	elseif (not Ns.Profile.EventArena and Ns.eventChecked and instanceType == "arena" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	end
	
	if (Ns.Profile.EventWorld and instanceType == "none" and not Ns.Profile.CharPanel and not Ns.Profile.EventCombat) then
		Ns.Profile.HideHUD = false	
		SinStatsFrame.HUD:Show()
		Ns:InitialiseProfile(Ns.Profile)
	end
	
	if (Ns.Profile.EventCombat and not Ns.Profile.EventWorld and not Ns.Profile.EventArena and not Ns.Profile.EventPvP and not Ns.Profile.EventRaid and not Ns.Profile.EventDungeon) and (not UnitAffectingCombat('player') or not InCombatLockdown()) then
		Ns.Profile.HideHUD = true	
		SinStatsFrame.HUD:Hide()
		Ns:InitialiseProfile(Ns.Profile)
	end
end
elseif event == "PLAYER_REGEN_DISABLED" then
	if Ns.Profile.EventEnable then 
		if (Ns.Profile.EventCombat and not Ns.CharPanel and (UnitAffectingCombat('player') or InCombatLockdown())) then
			Ns.Profile.HideHUD = false	
			SinStatsFrame.HUD:Show()
			Ns:InitialiseProfile(Ns.Profile)
		end
	end
elseif event == "PLAYER_REGEN_ENABLED" then
	if Ns.Profile.EventEnable then 
		if (Ns.Profile.EventCombat and not Ns.CharPanel and (not UnitAffectingCombat('player') or not InCombatLockdown())) then
			Ns.Profile.HideHUD = true	
			SinStatsFrame.HUD:Hide()
			Ns:InitialiseProfile(Ns.Profile)
		end
	end
end
end)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PET_BATTLE_OPENING_START")
f:RegisterEvent("PET_BATTLE_OVER")