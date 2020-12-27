-- lua file containing code for in game interface

-- Define Global Variables
tracked_abilities = _G.tracked_abilities
ability_status = _G.ability_status
num_abilities = 0
ability_labels = {}
proc_labels = {}
current_uptime_labels = {}
total_uptime_labels = {}
MAX_ABILITIES = 10
TIME_INTERVAL = 1.0

UIConfig = CreateFrame("Frame", "Uptime Frame", UIParent, "BasicFrameTemplateWithInset")
UIConfig:SetSize(260, 360)
UIConfig:SetPoint("CENTER")
UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
UIConfig.title:SetText("Uptime");

-- make frame draggable
UIConfig:SetMovable(true)
UIConfig:EnableMouse(true)
UIConfig:RegisterForDrag("LeftButton")
UIConfig:SetScript("OnDragStart", UIConfig.StartMoving)
UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing)

-- RESET BUTTON -------------------------------------------
UIConfig.resetBtn = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate")
UIConfig.resetBtn:SetPoint("CENTER", UIConfig, "TOP", -105, -40)
UIConfig.resetBtn:SetSize(30, 30)
UIConfig.resetBtn:SetText("Reset")
UIConfig.resetBtn:SetNormalFontObject("GameFontNormalSmall")
UIConfig.resetBtn:SetHighlightFontObject("GameFontHighlightSmall")

UIConfig.resetBtn:SetScript("OnClick", function(self, button, down)
	print("Uptime reset!")
	--print(PrintTable(tracked_abilities)) 

	-- hide all ability labels
	for i=1, num_abilities do
		ability_labels[i]:Hide()
		proc_labels[i]:Hide()
		current_uptime_labels[i]:Hide()
		total_uptime_labels[i]:Hide()
	end
	tracked_abilities = {}
	num_abilities = 0

	-- reset total combat time
	_G.start_combat_time = nil
	_G.total_combat_time = 0

	-- reset timer labels
	UIConfig.totalCombatValue:SetText("00:00")
	UIConfig.currentCombatValue:SetText("00:00")

	-- make sure textbox is shown
	UIConfig.userText:Show()
end)


-- Ability Table Label -----------------------------
UIConfig.abilityLabel = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.abilityLabel:SetText("Ability")
UIConfig.abilityLabel:SetPoint("CENTER", UIConfig, "CENTER", -60, 75)

UIConfig.procLabel = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.procLabel:SetText("Procs")
UIConfig.procLabel:SetPoint("CENTER", UIConfig, "CENTER", 0, 75)

UIConfig.currentLabel = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.currentLabel:SetText("Current %")
UIConfig.currentLabel:SetPoint("Center", UIConfig, "Center", 50, 75)

UIConfig.totalLabel = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.totalLabel:SetText("Total %")
UIConfig.totalLabel:SetPoint("Center", UIConfig, "Center", 100, 75)


-- Combat Timer Lables ----------------------------------
UIConfig.totalCombatLabel = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.totalCombatLabel:SetText("Total: ")
UIConfig.totalCombatLabel:SetPoint("BOTTOMLEFT", UIConfig, "BOTTOMLEFT", 10, 10)

UIConfig.currentCombatLabel = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.currentCombatLabel:SetText("Current: ")
UIConfig.currentCombatLabel:SetPoint("BOTTOMLEFT", UIConfig, "BOTTOMLEFT", 10, 25)

UIConfig.totalCombatValue = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.totalCombatValue:SetText("00:00")
UIConfig.totalCombatValue:SetPoint("BOTTOMLEFT", UIConfig, "BOTTOMLEFT", 65, 10)

UIConfig.currentCombatValue = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.currentCombatValue:SetText("00:00")
UIConfig.currentCombatValue:SetPoint("BOTTOMLEFT", UIConfig, "BOTTOMLEFT", 65, 25)


-- Create 5 Hidden ability labels -----------------------
for i=1, MAX_ABILITIES do
	ability_labels[i] = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
	ability_labels[i]:SetText(string.format("Ability %s", i))
	ability_labels[i]:SetPoint("Center", UIConfig, "Center", -60, 75 - 20*i)
	ability_labels[i]:Hide()

	proc_labels[i] = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
	proc_labels[i]:SetText(string.format("Ability %s", i))
	proc_labels[i]:SetPoint("Center", UIConfig, "Center", 0, 75 - 20*i)
	proc_labels[i]:Hide()

	current_uptime_labels[i] = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
	current_uptime_labels[i]:SetText(string.format("Ability %s", i))
	current_uptime_labels[i]:SetPoint("Center", UIConfig, "Center", 50, 75 - 20*i)
	current_uptime_labels[i]:Hide()

	total_uptime_labels[i] = UIConfig:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
	total_uptime_labels[i]:SetText(string.format("Ability %s", i))
	total_uptime_labels[i]:SetPoint("Center", UIConfig, "Center", 100, 75 - 20*i)
	total_uptime_labels[i]:Hide()
	
end

-- Text Box for User Input ---------------------

-- EDIT BOX ------------------------------
UIConfig.userText = CreateFrame("EditBox", nil, UIConfig)
UIConfig.userText:SetAutoFocus(false)
--UIConfig.userText:SetText("Enter Ability: ")
UIConfig.userText:SetSize(100, 25)
UIConfig.userText:SetFontObject(GameFontNormal)
UIConfig.userText.texture = UIConfig.userText:CreateTexture(nil, "BACKGROUND")
UIConfig.userText.texture:SetAllPoints(UIConfig.userText)
UIConfig.userText.texture:SetColorTexture(1.0, 1.0, 1.0)
UIConfig.userText:SetPoint("LEFT", UIConfig, "TOP", 15, -40)
UIConfig.userText.label = UIConfig.userText:CreateFontString(nil, "BORDER", "GameFontNormal")
UIConfig.userText.label:SetJustifyH("RIGHT")
UIConfig.userText.label:SetPoint("RIGHT", UIConfig.userText, "LEFT", 0)
UIConfig.userText.label:SetText("Enter Ability: ")

UIConfig.userText:SetScript("OnEnterPressed", function(self)
	if self:GetText() ~= "" then
		ability=self:GetText()
		print(ability, "Added!")
		num_abilities = num_abilities + 1
		--tracked_abilities[num_abilities] = {Ability=self:GetText(), 
											--status=false,
											--total_time=0,
											--procs=0}

		tracked_abilities[ability] = {number=num_abilities, 
											status=false,
											start_time=nil,
											proc_time=0,
											current_time=0,
											final_current_time=0,
											last_current_time=0,
											total_time=0,
											final_total_time=0,
											procs=0}

		-- create dictionary for the status of the ability. Easier to access
		ability_status[self:GetText()] = false

		-- update and show label in UI
		ability_labels[num_abilities]:SetText(self:GetText())
		ability_labels[num_abilities]:Show()

		proc_labels[num_abilities]:SetText(tracked_abilities[ability].procs)
		proc_labels[num_abilities]:Show()

		current_uptime_labels[num_abilities]:SetText("0.00")
		current_uptime_labels[num_abilities]:Show()

		total_uptime_labels[num_abilities]:SetText("0.00")
		total_uptime_labels[num_abilities]:Show()

	end
	
	-- Clear textbox and return focus to game
	self:SetText("")
	self:ClearFocus()

	-- hide text box if the max number of abilities is reached
	if num_abilities == MAX_ABILITIES then
		self:Hide()
	end
	
end)


-- Fuction to update UI when out of combat after frame is no longer hidden---------------
function updateUI()
	current_time = _G.last_combat_time
	total_time = _G.total_combat_time

	-- total_time =  math.floor((GetTime() - _G.start_combat_time) + .5 + _G.total_combat_time)

	-- Update the combat timers ---------------------------------------------------------
	total_mins = math.floor(total_time / 60)
	total_secs = math.floor(total_time - total_mins*60)
	UIConfig.totalCombatValue:SetText(string.format("%02.f", total_mins)..":"..string.format("%02.f", total_secs))

	current_mins = math.floor(current_time / 60)
	current_secs = math.floor(current_time - current_mins*60)
	UIConfig.currentCombatValue:SetText(string.format("%02.f", current_mins)..":"..string.format("%02.f", current_secs))
		----------------------------------------------------------------------------------------

	for index, ability in pairs(tracked_abilities) do
		-- update labels for each ability
		proc_labels[ability.number]:SetText(ability.procs)
		current_uptime_labels[ability.number]:SetText(string.format("%.2f" , ability.final_current_time))
		total_uptime_labels[ability.number]:SetText(string.format("%.2f", ability.final_total_time))
	end
end


-------------------------
-- Attach OnUpdate listener to main UI frame
------------------------
UIConfig.elapsed = TIME_INTERVAL
UIConfig:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed - elapsed
	if self.elapsed > 0 then return end

	-- print total time in combat
	if _G.in_combat then
		current_time = GetTime() - _G.start_combat_time
		total_time = current_time + _G.total_combat_time

		-- total_time =  math.floor((GetTime() - _G.start_combat_time) + .5 + _G.total_combat_time)

		-- Update the combat timers ---------------------------------------------------------
		total_mins = math.floor(total_time / 60)
		total_secs = math.floor(total_time - total_mins*60)
		UIConfig.totalCombatValue:SetText(string.format("%02.f", total_mins)..":"..string.format("%02.f", total_secs))

		current_mins = math.floor(current_time / 60)
		current_secs = math.floor(current_time - current_mins*60)
		UIConfig.currentCombatValue:SetText(string.format("%02.f", current_mins)..":"..string.format("%02.f", current_secs))
		----------------------------------------------------------------------------------------

		for index, ability in pairs(tracked_abilities) do
			-- calculate active times for ability
			if ability.start_time == nil then
				ability_current_time = ability.current_time
				ability_total_time = ability.total_time + ability.current_time
			else 

				ability_current_time = ability.current_time + GetTime() - ability.start_time
				ability_total_time = ability.total_time + ability_current_time
			end

			--print(ability_current_time)

			-- update labels for each ability
			proc_labels[ability.number]:SetText(ability.procs)
			current_uptime_labels[ability.number]:SetText(string.format("%.2f" , (ability_current_time / current_time)*100))
			total_uptime_labels[ability.number]:SetText(string.format("%.2f", (ability_total_time / total_time)*100))
		end
	end
		 
	-- enough time has passed
	self.elapsed = TIME_INTERVAL

end)



-- Create slash commands for use in game ----------------
-- /show: show UI if hidden
-- /hide: hide UI if not hidden (same as exiting the frame)
SLASH_CMD1 = "/uptime"
SlashCmdList["CMD"] = function(msg)
	if msg == 'show' then
		UIConfig:Show()
		if _G.in_combat == false then
			updateUI()
		end
	elseif msg == 'hide' then
		UIConfig:Hide()
	else
		print(string.format("Invalid command! (%s)", msg))
	end
end

---- print table helper function -------------------
function PrintTable(t)
	for index, data in ipairs(t) do
		print(index, data)
	end
end