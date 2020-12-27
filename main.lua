-- Entry point for Uptime WoW addon

-- Entering Combat: "PLAYER_REGEN_DISABLED"
-- Exiting Combat: "PLAYER_REGEN_ENABLED"

local f = CreateFrame("Frame")

-- threshold for determining if a buff was reactivated 
buff_threshold = 0.002

-- Global variables
tracked_abilities = {}
ability_status = {}
total_combat_time = 0
start_combat_time = nil
in_combat = false

function CombatEntered()
	--print("Combat Entered!")
	in_combat = true

	-- Hide reset button to avoid erros
	_G.UIConfig.resetBtn:Hide()

	-- start times for combat
	start_combat_time = GetTime()

	-- buff already active when entering combat, set start time
	for buff, value in pairs(tracked_abilities) do
		if value.status == true then
			value.start_time = GetTime()
		end
	end
end

function CombatExited()
	--print("Combat Exited!")

	start_time = nil

	-- increment total time in combat for latest combat engagement
	total_combat_time = total_combat_time + (GetTime() - start_combat_time)

	-- variable for storing length of last combat engagement
	last_combat_time = GetTime() - start_combat_time

	-- set starting combat times to nil
	start_combat_time = nil

	-- set combat flag to false
	in_combat = false

	-- show reset button on leaving combat
	_G.UIConfig.resetBtn:Show()

	-- iterate through any abilities to check if still active
	for buff, value in pairs(tracked_abilities) do
		if value.status == true then
			-- increment total time based on ability active time during combat
			value.total_time = value.total_time + value.current_time + (GetTime() - value.start_time)
			value.last_current_time = value.current_time + (GetTime() - value.start_time)
			
		else
			value.total_time = value.total_time + value.current_time
			value.last_current_time = value.current_time
		end
		value.start_time = nil

		value.current_time = 0
		value.proc_time = 0

		value.final_current_time = value.total_time
		value.final_total_time = value.total_time
	end
end

-- Checks if tracked ability statuses have changed
function CheckBuff(event)
	for buff, value in pairs(tracked_abilities) do
		name, _, count, _, duration, expirationTime = AuraUtil.FindAuraByName(buff, "player")
		if name then
			-- print(name)
			if value.status == false then
				--print("Buff Activated!")
				value.status = true
				if in_combat == true then
					value.procs = value.procs + 1
					value.start_time = GetTime()

				end
			elseif value.status and in_combat == true then
				-- buff re-activated (full duration)
				if math.abs((expirationTime - GetTime()) - duration) < buff_threshold then
					--print("Reactivated!")
					value.procs = value.procs + 1
				else
				-- DO NOTHING
				end
			end
		
		elseif value.status then
			-- buff deactivated
			value.status = false

			--print("Buff lost!")
			if in_combat == true then
				--value.total_time = value.total_time + GetTime() - value.start_time
				--value.total_time = value.total_time + (GetTime() - value.start_time)
				value.current_time = value.current_time + (GetTime() - value.start_time)
				value.proc_time = 0
			end

			value.start_time = nil
			
		end
	end
		
end

-- Set handler functions for events
f:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		CombatEntered()
	elseif event == "PLAYER_REGEN_ENABLED" then
		CombatExited()
	elseif event == "UNIT_AURA" then
		local unit = select(1,...)
		if unit == "player" then
			CheckBuff()
		end
	end
end)

f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("UNIT_AURA")






