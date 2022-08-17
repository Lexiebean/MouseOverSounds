local mouseOverSounds = CreateFrame("Frame","MouseOverSounds")
mouseOverSounds:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
mouseOverSounds:SetParent(GameTooltip) -- To only fire onupdate when tooltip is shown

largeWarningMouseOver = 4
mediumWarningMouseOver = 1
smallWarningMouseOver = -1

playMouseOverXPSound = true
playMouseOverQuestSound = true
MouseOverAddLevelsForNonWarriors = true
MouseOverInGroup = true

local oldLarge = largeWarningMouseOver
local oldMedium = mediumWarningMouseOver
local oldSmall = smallWarningMouseOver
local oldXP = playMouseOverXPSound
local oldQuest = playMouseOverQuestSound
local oldWarrior = MouseOverAddLevelsForNonWarriors
local oldGroup = MouseOverInGroup

local largeWarningSound = "PVPENTERQUEUE" -- "RaidWarning"
local mediumWarningSound = "TalentScreenOpen"  --"MINIMAPCLOSE"
local smallWarningSound = "igMiniMapZoomIn" --"igCreatureAggroSelect" -- "MINIMAPCLOSE" --"igMiniMapZoomIn" 
local xpsound = "igCreatureAggroSelect" --"INTERFACESOUND_MONEYFRAMEOPEN"
local questMobSound = "INTERFACESOUND_GAMESCROLLBUTTON" --"INTERFACESOUND_MONEYFRAMECLOSE" --"INTERFACESOUND_MONEYFRAMEOPEN"
local chestSound = "INTERFACESOUND_MONEYFRAMEOPEN" --"INTERFACESOUND_MONEYFRAMECLOSE" --"INTERFACESOUND_MONEYFRAMEOPEN" "ITEMGENERICSOUND"



local lastmouseoversoundPlayed = 0
local lastmouseovertooltiptext = ""
local lastmouseovertooltiptext0 = ""
local lastmouseovertooltiptext1 = ""
local lastmouseovertooltiptext2 = ""
local lastShowingOfTooltip = 0
local lastUpdateTooltip = 0
local hasHerbalism = false
local hasMining = false


mouseOverSounds:SetScript('OnUpdate', function(self, elapsed)
   if not playMouseOverQuestSound then
		return
	end
	
	local firstShowing = GetTime() > lastShowingOfTooltip + 0.3
	
	lastShowingOfTooltip = GetTime()
	
	if firstShowing then
		lastmouseovertooltiptext = ""
		lastmouseovertooltiptext0 = ""
		lastmouseovertooltiptext1 = ""
		lastmouseovertooltiptext2 = ""
		
	end

	if GetTime() > lastUpdateTooltip + 3 then -- Don't update this every frame (for perf)
		
		local i = 1
		lastUpdateTooltip = GetTime()
		local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)

		hasHerbalism = false
		hasMining = false

		while spellName do
		   
		   if spellName == "Find Herbs" then
		     hasHerbalism = true
			end
		   if spellName == "Find Minerals" then
		     hasMining = true
			end
		   i = i + 1
			spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		end
	end

	
	if getglobal('GameTooltipTextLeft1'):IsVisible()  then
		if GameTooltipTextLeft1 ~= nil then
			local tt = GameTooltipTextLeft1:GetText()
			if tt ~= nil then
				if tt ~= lastmouseovertooltiptext then
					lastmouseovertooltiptext = tt
					if string.find(tt,"!") then
						PlaySound(questMobSound, "SFX")
						lastmouseoversoundPlayed = GetTime()
						return
					end
					if string.find(tt,"Chest") or (string.find(tt,"Herbalism") and hasHerbalism) or (string.find(tt,"Mining") and hasMining) then
						PlaySound(chestSound, "SFX")
						lastmouseoversoundPlayed = GetTime()
						return
					end
				end
			end
		end
	
		if GameTooltipTextLeft2 ~= nil then
			tt = GameTooltipTextLeft2:GetText()
			if tt ~= nil then
				if tt ~= lastmouseovertooltiptext0 then
					lastmouseovertooltiptext0 = tt
					if string.find(tt,"!") then
						PlaySound(questMobSound, "SFX")
						lastmouseoversoundPlayed = GetTime()
						return
					end
					if (string.find(tt,"Herbalism") and hasHerbalism) or (string.find(tt,"Mining") and hasMining) then
						PlaySound(chestSound, "SFX")
						lastmouseoversoundPlayed = GetTime()
						return
					end
				end
			end
		end
	
		if GameTooltipTextLeft3 ~= nil then
			local tt = GameTooltipTextLeft3:GetText()
			if tt ~= nil then
				if tt ~= lastmouseovertooltiptext1 then
					lastmouseovertooltiptext1 = tt
					if string.find(tt,"!") then
						PlaySound(questMobSound, "SFX")
						lastmouseoversoundPlayed = GetTime()
						return
					end
				
				end
			end
		end
	
		if GameTooltipTextLeft4 ~= nil then
			tt = GameTooltipTextLeft4:GetText()
			if tt ~= nil then
				if tt ~= lastmouseovertooltiptext2 then
					lastmouseovertooltiptext2 = tt
					if string.find(tt,"!") then
					  PlaySound(questMobSound, "SFX")
					  lastmouseoversoundPlayed = GetTime()
					  return
					end
					
				end
			end
		end
	end
end)

mouseOverSounds:SetScript("OnEvent", function(self,event, ...)

		local unit = 'mouseover' 

		if UnitIsPlayer(unit) or UnitPlayerControlled(unit) then -- Don't use the warnings for players
		  return
		end

		if UnitIsDead(unit) then -- Don't warn for dead units
		  return
		end

		if (GetPartyMember(1) and MouseOverInGroup) then -- Don't use the warnings if in a group.
		  return
		end


		local uenemy = UnitIsEnemy("player",unit)
		local uc = UnitClassification(unit)
		local playerLvl = UnitLevel("player")
		local unitLvl = UnitLevel(unit)

		local localizedClass, englishClass, classIndex = UnitClass(unit)
		
		if MouseOverAddLevelsForNonWarriors then
			if englishClass ~= "WARRIOR" then
			  unitLvl = unitLvl + 2
			end
		end
		
		if largeWarningMouseOver>-10 and uenemy and ((uc == 'worldboss' or uc == 'rareelite' or uc == 'elite' or uc == 'rare') or 
		   ((playerLvl - 1 + largeWarningMouseOver < unitLvl) or (unitLvl == -1)) or
		   (UnitHealth("player") * 2 < UnitHealth(unit))) then
		  PlaySound(largeWarningSound,"SFX") -- Large warning

		--elseif mediumWarningMouseOver>-10 and uenemy and UnitHealth("player") < UnitHealth(unit) then
		  --PlaySound(mediumWarningSound,"SFX")  -- Medium warning
		
		elseif mediumWarningMouseOver>-10 and uenemy and (playerLvl - 1 + mediumWarningMouseOver < unitLvl) then
		  PlaySound(mediumWarningSound,"SFX")  -- Medium warning
		
		elseif smallWarningMouseOver>-10 and uenemy and playerLvl - 1 + smallWarningMouseOver < unitLvl then
		  PlaySound(smallWarningSound,"SFX")  -- Small warning
		elseif UnitCanAttack("player", unit) and playMouseOverXPSound and (not UnitIsTrivial(unit) and GetTime() > lastmouseoversoundPlayed+0.2)  then
		  PlaySound(xpsound,"SFX")  -- Small warning
		  lastmouseoversoundPlayed = GetTime()
		end
end)



local mouseOverSettings = CreateFrame("Frame", "MouseOverSettingsGUI", UIParent)
mouseOverSettings:Hide()

table.insert(UISpecialFrames, "MouseOverSettingsGUI")
mouseOverSettings:SetScript("OnHide", function()
  ShowUIPanel(GameMenuFrame)
  UpdateMicroButtons()
end)

mouseOverSettings:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mouseOverSettings:SetWidth(256)
mouseOverSettings:SetHeight(216+36+36+36+36)
mouseOverSettings:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

mouseOverSettings:SetMovable(true)
mouseOverSettings:EnableMouse(true)
mouseOverSettings:SetClampedToScreen(true)
mouseOverSettings:RegisterForDrag("LeftButton")
	mouseOverSettings:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not this.isMoving then
			this:StartMoving();
			this.isMoving = true;
		end
	end)
	mouseOverSettings:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end
	end)
	mouseOverSettings:SetScript("OnHide", function()
		if this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end
	end)

mouseOverSettings.title = CreateFrame("Frame", "MouseOverSettingsGUITtitle", mouseOverSettings)
mouseOverSettings.title:SetPoint("TOP", mouseOverSettings, "TOP", 0, 12)
mouseOverSettings.title:SetWidth(256)
mouseOverSettings.title:SetHeight(64)

mouseOverSettings.title.tex = mouseOverSettings.title:CreateTexture(nil, "MEDIUM")
mouseOverSettings.title.tex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
mouseOverSettings.title.tex:SetAllPoints()

mouseOverSettings.title.text = mouseOverSettings.title:CreateFontString(nil, "HIGH", "GameFontNormal")
mouseOverSettings.title.text:SetText("Mouseover settings")
mouseOverSettings.title.text:SetPoint("TOP", 0, -14)

mouseOverSettings.cancel = CreateFrame("Button", "MouseOverSettingsGUICancel", mouseOverSettings, "GameMenuButtonTemplate")
mouseOverSettings.cancel:SetWidth(90)
mouseOverSettings.cancel:SetPoint("BOTTOMRIGHT", mouseOverSettings, "BOTTOMRIGHT", -17, 17)
mouseOverSettings.cancel:SetText(CANCEL)
mouseOverSettings.cancel:SetScript("OnClick", function()
  largeWarningMouseOver = oldLarge
  mediumWarningMouseOver = oldMedium
  smallWarningMouseOver = oldSmall

  playMouseOverQuestSound = oldQuest
  playMouseOverXPSound = oldXP
  MouseOverAddLevelsForNonWarriors = oldWarrior
  MouseOverInGroup = oldGroup
 
  mouseOverSettings.bigWarningLevels:SetValue(largeWarningMouseOver)
  mouseOverSettings.mediumWarningLevels:SetValue(mediumWarningMouseOver)
  mouseOverSettings.smallWarningLevels:SetValue(smallWarningMouseOver)

  mouseOverSettings.xpButton:SetChecked(playMouseOverXPSound)
  mouseOverSettings.questButton:SetChecked(playMouseOverQuestSound)
  mouseOverSettings.warriorButton:SetChecked(MouseOverAddLevelsForNonWarriors)
  
  
  mouseOverSettings:Hide()
  PlaySound("gsTitleOptionOK","SFX")
end)

mouseOverSettings.okay = CreateFrame("Button", "MouseOverSettingsGUIOkay", mouseOverSettings, "GameMenuButtonTemplate")
mouseOverSettings.okay:SetWidth(90)
mouseOverSettings.okay:SetPoint("RIGHT", mouseOverSettings.cancel, "LEFT", 0, 0)
mouseOverSettings.okay:SetText(OKAY)
mouseOverSettings.okay:SetScript("OnClick", function()
  mouseOverSettings:Hide()
  PlaySound("gsTitleOptionOK","SFX")
end)

local spacing = 30
local yoff = 12 + 40

mouseOverSettings.bigWarningLevels = CreateFrame("Slider", "SliderBigWarningLevels", mouseOverSettings, "OptionsSliderTemplate")
mouseOverSettings.bigWarningLevels:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing, -yoff)
mouseOverSettings.bigWarningLevels:SetWidth(200)
mouseOverSettings.bigWarningLevels:SetHeight(16)
mouseOverSettings.bigWarningLevels:SetOrientation('HORIZONTAL')
mouseOverSettings.bigWarningLevels:Show()

mouseOverSettings.bigWarningLevels.tooltipText = 'Mob levels over the player for large warning sound. This sound also plays for rares/elites or mobs with health 2X the players health.'   -- Creates a tooltip on mouseover.
getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Low'):SetText('-10')    
getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'High'):SetText('10')   
getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Text'):SetText('Large warning: ' ..  largeWarningMouseOver .. ", lvl " ..(UnitLevel("player") + largeWarningMouseOver))

mouseOverSettings.bigWarningLevels:SetMinMaxValues(-10, 10)
mouseOverSettings.bigWarningLevels:SetValue(largeWarningMouseOver)
mouseOverSettings.bigWarningLevels:SetValueStep(1)
mouseOverSettings.bigWarningLevels:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

mouseOverSettings.bigWarningLevels:SetScript("OnValueChanged",function()
  getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Text'):SetText('Large warning: ' .. mouseOverSettings.bigWarningLevels:GetValue() .. ", lvl " ..(UnitLevel("player") + mouseOverSettings.bigWarningLevels:GetValue())) 
  largeWarningMouseOver = mouseOverSettings.bigWarningLevels:GetValue()
  if largeWarningMouseOver == -10 then
    getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Text'):SetText('Large warning: Off') 
  end 
  if GetTime() > lastmouseoversoundPlayed + 2 then
	PlaySound(largeWarningSound,"SFX") -- Large warning
	  lastmouseoversoundPlayed = GetTime()
  end
end)

yoff = yoff + 40

mouseOverSettings.mediumWarningLevels = CreateFrame("Slider", "SliderMediumWarningLevels", mouseOverSettings, "OptionsSliderTemplate")
mouseOverSettings.mediumWarningLevels:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing, -yoff)
mouseOverSettings.mediumWarningLevels:SetWidth(200)
mouseOverSettings.mediumWarningLevels:SetHeight(16)
mouseOverSettings.mediumWarningLevels:SetOrientation('HORIZONTAL')
mouseOverSettings.mediumWarningLevels:Show()

mouseOverSettings.mediumWarningLevels.tooltipText = 'Mob levels over the player for medium warning sound.'   -- Creates a tooltip on mouseover.
getglobal(mouseOverSettings.mediumWarningLevels:GetName() .. 'Low'):SetText('-10')      
getglobal(mouseOverSettings.mediumWarningLevels:GetName() .. 'High'):SetText('10')     
getglobal(mouseOverSettings.mediumWarningLevels:GetName() .. 'Text'):SetText('Medium warning: ' .. mediumWarningMouseOver .. ", lvl " ..(UnitLevel("player") + mediumWarningMouseOver)) 

mouseOverSettings.mediumWarningLevels:SetMinMaxValues(-10, 10)
mouseOverSettings.mediumWarningLevels:SetValue(mediumWarningMouseOver)
mouseOverSettings.mediumWarningLevels:SetValueStep(1)
mouseOverSettings.mediumWarningLevels:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

mouseOverSettings.mediumWarningLevels:SetScript("OnValueChanged",function()
  getglobal(mouseOverSettings.mediumWarningLevels:GetName() .. 'Text'):SetText('Medium warning: ' .. mouseOverSettings.mediumWarningLevels:GetValue() .. ", lvl " ..(UnitLevel("player") + mouseOverSettings.mediumWarningLevels:GetValue())) 
  mediumWarningMouseOver = mouseOverSettings.mediumWarningLevels:GetValue()
  if mediumWarningMouseOver == -10 then
    getglobal(mouseOverSettings.mediumWarningLevels:GetName() .. 'Text'):SetText('Medium warning: Off') 
  end 
  if GetTime() > lastmouseoversoundPlayed + 1 then
	  PlaySound(mediumWarningSound,"SFX") -- Large warning
	  lastmouseoversoundPlayed = GetTime()
  end
end)

yoff = yoff + 40

mouseOverSettings.smallWarningLevels = CreateFrame("Slider", "SliderSmallWarningLevels", mouseOverSettings, "OptionsSliderTemplate")
mouseOverSettings.smallWarningLevels:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing, -yoff)
mouseOverSettings.smallWarningLevels:SetWidth(200)
mouseOverSettings.smallWarningLevels:SetHeight(16)
mouseOverSettings.smallWarningLevels:SetOrientation('HORIZONTAL')
mouseOverSettings.smallWarningLevels:Show()

mouseOverSettings.smallWarningLevels.tooltipText = 'Mob levels over player for small warning.'   
getglobal(mouseOverSettings.smallWarningLevels:GetName() .. 'Low'):SetText('-10')       
getglobal(mouseOverSettings.smallWarningLevels:GetName() .. 'High'):SetText('10')    
getglobal(mouseOverSettings.smallWarningLevels:GetName() .. 'Text'):SetText('Small warning: ' ..  smallWarningMouseOver .. ", lvl " ..(UnitLevel("player") + smallWarningMouseOver)) 

mouseOverSettings.smallWarningLevels:SetMinMaxValues(-10, 10)
mouseOverSettings.smallWarningLevels:SetValue(smallWarningMouseOver)
mouseOverSettings.smallWarningLevels:SetValueStep(1)
mouseOverSettings.smallWarningLevels:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

mouseOverSettings.smallWarningLevels:SetScript("OnValueChanged",function()

  getglobal(mouseOverSettings.smallWarningLevels:GetName() .. 'Text'):SetText('Small warning: ' .. mouseOverSettings.smallWarningLevels:GetValue() .. ", lvl " ..(UnitLevel("player") + mouseOverSettings.smallWarningLevels:GetValue())) 
  smallWarningMouseOver = mouseOverSettings.smallWarningLevels:GetValue()
  if smallWarningMouseOver == -10 then
    getglobal(mouseOverSettings.smallWarningLevels:GetName() .. 'Text'):SetText('Small warning: Off') 
  end 
  if GetTime() > lastmouseoversoundPlayed + 1 then
  PlaySound(smallWarningSound,"SFX") -- Large warning
	  lastmouseoversoundPlayed = GetTime()
  end
end)


yoff = yoff + 36

mouseOverSettings.xpButton = CreateFrame("CheckButton", "mouseoverXpSoundCheckbox", mouseOverSettings, "OptionsCheckButtonTemplate");
mouseOverSettings.xpButton:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing-4, -yoff)
mouseoverXpSoundCheckboxText:SetText("Play a sound for non gray mobs")
mouseOverSettings.xpButton.tooltipText = "A small select sound for mobs that give XP"
mouseOverSettings.xpButton:SetChecked(playMouseOverXPSound)
mouseOverSettings.xpButton:SetScript("OnClick", 
  function()
    playMouseOverXPSound = mouseOverSettings.xpButton:GetChecked()
	PlaySound(xpsound,"SFX")
  end
);

yoff = yoff + 36

mouseOverSettings.questButton = CreateFrame("CheckButton", "mouseoverQuestSoundCheckbox", mouseOverSettings, "OptionsCheckButtonTemplate");
mouseOverSettings.questButton:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing-4, -yoff)
mouseoverQuestSoundCheckboxText:SetText("Play a sound for pfQuest mobs")
mouseOverSettings.questButton.tooltipText = "A small sound for mobs that have ! in the tooltip."
mouseOverSettings.questButton:SetChecked(playMouseOverQuestSound)
mouseOverSettings.questButton:SetScript("OnClick", 
  function()
    playMouseOverQuestSound = mouseOverSettings.questButton:GetChecked()
	PlaySound(questMobSound,"SFX")
  end
);

yoff = yoff + 36

mouseOverSettings.warriorButton = CreateFrame("CheckButton", "mouseoverWarriorCheckbox", mouseOverSettings, "OptionsCheckButtonTemplate");
mouseOverSettings.warriorButton:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing-4, -yoff)
mouseoverWarriorCheckboxText:SetText("Add 2 levels for non Warrior mobs")
mouseOverSettings.warriorButton.tooltipText = "Add 2 levels for Casters, Paladins etc."
mouseOverSettings.warriorButton:SetChecked(MouseOverAddLevelsForNonWarriors)
mouseOverSettings.warriorButton:SetScript("OnClick", 
  function()
    MouseOverAddLevelsForNonWarriors = mouseOverSettings.warriorButton:GetChecked()
  end
);

yoff = yoff + 36

mouseOverSettings.groupButton = CreateFrame("CheckButton", "mouseoverGroupCheckbox", mouseOverSettings, "OptionsCheckButtonTemplate");
mouseOverSettings.groupButton:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing-4, -yoff)
mouseoverGroupCheckboxText:SetText("Disable while in a group")
mouseOverSettings.groupButton.tooltipText = "Disable while in a group."
mouseOverSettings.groupButton:SetChecked(MouseOverInGroup)
mouseOverSettings.groupButton:SetScript("OnClick", 
  function()
    MouseOverInGroup = mouseOverSettings.groupButton:GetChecked()
  end
);

GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 22)


local MouseoverSounds = CreateFrame("Button", "GameMenuButtonMouseOverSoundsSettings", GameMenuFrame, "GameMenuButtonTemplate")
MouseoverSounds:SetPoint("TOP", GameMenuButtonKeybindings, "BOTTOM", 0, -1)
MouseoverSounds:SetText("Mouseover sounds")
MouseoverSounds:SetScript("OnClick", function()
  HideUIPanel(GameMenuFrame)
  PlaySound("igMainMenuOption","SFX")
  oldLarge = largeWarningMouseOver
  oldMedium = mediumWarningMouseOver
  oldSmall = smallWarningMouseOver

  oldQuest = playMouseOverQuestSound 
  oldXP = playMouseOverXPSound 
  oldWarrior = MouseOverAddLevelsForNonWarriors
  oldGroup = MouseOverInGroup

  mouseOverSettings.bigWarningLevels:SetValue(largeWarningMouseOver)
  mouseOverSettings.mediumWarningLevels:SetValue(mediumWarningMouseOver)
  mouseOverSettings.smallWarningLevels:SetValue(smallWarningMouseOver)
  
  mouseOverSettings.xpButton:SetChecked(playMouseOverXPSound)
  mouseOverSettings.questButton:SetChecked(playMouseOverQuestSound)
  mouseOverSettings.warriorButton:SetChecked(MouseOverAddLevelsForNonWarriors)
  mouseOverSettings.groupButton:SetChecked(MouseOverInGroup)
  
  
  mouseOverSettings:Show()
end)

GameMenuButtonMacros:ClearAllPoints()
GameMenuButtonMacros:SetPoint("TOP", MouseoverSounds, "BOTTOM", 0, -1)
