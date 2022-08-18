local mouseOverSounds = CreateFrame("Frame","MouseOverSounds")
mouseOverSounds:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
mouseOverSounds:SetParent(GameTooltip) -- To only fire onupdate when tooltip is shown

largeWarningMouseOver = 4
mediumWarningMouseOver = 1
smallWarningMouseOver = -1

largeWarningMouseOverHP = 2.0
mediumWarningMouseOverHP = 1.0							 
playMouseOverXPSound = true
playMouseOverQuestSound = true
MouseOverAddLevelsForNonWarriors = true
MouseOverInGroup = true

local oldLarge = largeWarningMouseOver
local oldMedium = mediumWarningMouseOver
local oldSmall = smallWarningMouseOver
local oldLargeHP = largeWarningMouseOverHP
local oldMediumHP = mediumWarningMouseOverHP
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
					if string.find(tt,"Tattered Chest") or string.find(tt,"Battered Chest") or string.find(tt,"Solid Chest") or (string.find(tt," Herbalism") and hasHerbalism) or (string.find(tt," Mining") and hasMining) then
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
					if (string.find(tt,"Requires Herbalism") and hasHerbalism) or (string.find(tt," Mining") and hasMining) then
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
		
		if (uc == 'worldboss' or uc == 'rareelite' or uc == 'elite' or uc == 'rare') then
			playerLvl = playerLvl - 10
		end
		if largeWarningMouseOver>-10 and uenemy and (((playerLvl - 1 + largeWarningMouseOver < unitLvl) or (unitLvl == -1)) or
		   (UnitHealth("player") * largeWarningMouseOverHP < UnitHealth(unit))) then
		  PlaySound(largeWarningSound,"SFX") -- Large warning

		elseif mediumWarningMouseOver>-10 and uenemy and UnitHealth("player")*mediumWarningMouseOverHP < UnitHealth(unit) then
		  PlaySound(mediumWarningSound,"SFX")  -- Medium warning
		
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
mouseOverSettings:SetHeight(216+36+36+36+36+30+30+20)
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
mouseOverSettings.cancel:SetPoint("BOTTOMRIGHT", mouseOverSettings, "BOTTOMRIGHT", -38, 17)
mouseOverSettings.cancel:SetText(CANCEL)
mouseOverSettings.cancel:SetScript("OnClick", function()
  largeWarningMouseOver = oldLarge
  mediumWarningMouseOver = oldMedium
  smallWarningMouseOver = oldSmall

  largeWarningMouseOverHP = oldLargeHP
  mediumWarningMouseOverHP = oldMediumHP							  
  playMouseOverQuestSound = oldQuest
  playMouseOverXPSound = oldXP
  MouseOverAddLevelsForNonWarriors = oldWarrior
  MouseOverInGroup = oldGroup
 
  mouseOverSettings.bigWarningLevels:SetValue(largeWarningMouseOver)
  mouseOverSettings.mediumWarningLevels:SetValue(mediumWarningMouseOver)
  mouseOverSettings.smallWarningLevels:SetValue(smallWarningMouseOver)

  mouseOverSettings.bigWarningLevelsHP:SetValue(largeWarningMouseOverHP)
  mouseOverSettings.mediumWarningLevelsHP:SetValue(mediumWarningMouseOverHP)																		
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

mouseOverSettings.bigWarningLevels.tooltipText = 'Mob levels over the player for large warning sound. Rares/elites counts as -10 lvs.'   
getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Low'):SetText('-10')    
getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'High'):SetText('10')   
getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Text'):SetText('Large warning: ' ..  largeWarningMouseOver .. ", lvl " ..(UnitLevel("player") + largeWarningMouseOver).." ("..(UnitLevel("player") + largeWarningMouseOver-10).." rares)")

mouseOverSettings.bigWarningLevels:SetMinMaxValues(-10, 10)
mouseOverSettings.bigWarningLevels:SetValue(largeWarningMouseOver)
mouseOverSettings.bigWarningLevels:SetValueStep(1)
mouseOverSettings.bigWarningLevels:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

mouseOverSettings.bigWarningLevels:SetScript("OnValueChanged",function()
  getglobal(mouseOverSettings.bigWarningLevels:GetName() .. 'Text'):SetText('Large warning: ' ..  largeWarningMouseOver .. ", lvl " ..(UnitLevel("player") + largeWarningMouseOver).." ("..(UnitLevel("player") + largeWarningMouseOver-10).." rares)")
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
mouseOverSettings.bigWarningLevelsHP = CreateFrame("Slider", "SliderBigWarningLevelsHP", mouseOverSettings, "OptionsSliderTemplate")
mouseOverSettings.bigWarningLevelsHP:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing, -yoff)
mouseOverSettings.bigWarningLevelsHP:SetWidth(200)
mouseOverSettings.bigWarningLevelsHP:SetHeight(16)
mouseOverSettings.bigWarningLevelsHP:SetOrientation('HORIZONTAL')
mouseOverSettings.bigWarningLevelsHP:Show()

mouseOverSettings.bigWarningLevelsHP.tooltipText = 'Mob HP > The players HP for large warning sound.'   
getglobal(mouseOverSettings.bigWarningLevelsHP:GetName() .. 'Low'):SetText('0.5')    
getglobal(mouseOverSettings.bigWarningLevelsHP:GetName() .. 'High'):SetText('4.0')   
getglobal(mouseOverSettings.bigWarningLevelsHP:GetName() .. 'Text'):SetText('Or mob HP > ' .. string.format("%.1f",largeWarningMouseOverHP) .. '  (' ..string.format("%d",UnitHealth("player") * largeWarningMouseOverHP)..')') 

mouseOverSettings.bigWarningLevelsHP:SetMinMaxValues(0.5, 4.0)
mouseOverSettings.bigWarningLevelsHP:SetValue(largeWarningMouseOverHP)
mouseOverSettings.bigWarningLevelsHP:SetValueStep(0.1)
mouseOverSettings.bigWarningLevelsHP:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

mouseOverSettings.bigWarningLevelsHP:SetScript("OnValueChanged",function()
  largeWarningMouseOverHP = mouseOverSettings.bigWarningLevelsHP:GetValue()
  getglobal(mouseOverSettings.bigWarningLevelsHP:GetName() .. 'Text'):SetText('Or mob HP > ' .. string.format("%.1f",largeWarningMouseOverHP) .. '  (' ..string.format("%d",UnitHealth("player") * largeWarningMouseOverHP)..')') 
  if GetTime() > lastmouseoversoundPlayed + 2 then
	PlaySound(largeWarningSound,"SFX") -- Large warning
	lastmouseoversoundPlayed = GetTime()
  end
end)

yoff = yoff + 50																																	

mouseOverSettings.mediumWarningLevels = CreateFrame("Slider", "SliderMediumWarningLevels", mouseOverSettings, "OptionsSliderTemplate")
mouseOverSettings.mediumWarningLevels:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing, -yoff)
mouseOverSettings.mediumWarningLevels:SetWidth(200)
mouseOverSettings.mediumWarningLevels:SetHeight(16)
mouseOverSettings.mediumWarningLevels:SetOrientation('HORIZONTAL')
mouseOverSettings.mediumWarningLevels:Show()

mouseOverSettings.mediumWarningLevels.tooltipText = 'Mob levels over the player for medium warning sound.'  
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

yoff = yoff + 36

mouseOverSettings.mediumWarningLevelsHP = CreateFrame("Slider", "SliderMediumWarningLevelsHP", mouseOverSettings, "OptionsSliderTemplate")
mouseOverSettings.mediumWarningLevelsHP:SetPoint("TOPLEFT", mouseOverSettings, "TOPLEFT", spacing, -yoff)
mouseOverSettings.mediumWarningLevelsHP:SetWidth(200)
mouseOverSettings.mediumWarningLevelsHP:SetHeight(16)
mouseOverSettings.mediumWarningLevelsHP:SetOrientation('HORIZONTAL')
mouseOverSettings.mediumWarningLevelsHP:Show()

mouseOverSettings.mediumWarningLevelsHP.tooltipText = 'Mob HP > The players HP for medium warning sound.'   
getglobal(mouseOverSettings.mediumWarningLevelsHP:GetName() .. 'Low'):SetText('0.1')    
getglobal(mouseOverSettings.mediumWarningLevelsHP:GetName() .. 'High'):SetText('4.0')   
getglobal(mouseOverSettings.mediumWarningLevelsHP:GetName() .. 'Text'):SetText('Or mob HP > ' .. string.format("%.1f",mediumWarningMouseOverHP) .. '  (' ..string.format("%d",UnitHealth("player") * mediumWarningMouseOverHP)..')') 

mouseOverSettings.mediumWarningLevelsHP:SetMinMaxValues(0.1, 4.0)
mouseOverSettings.mediumWarningLevelsHP:SetValue(mediumWarningMouseOverHP)
mouseOverSettings.mediumWarningLevelsHP:SetValueStep(0.1)
mouseOverSettings.mediumWarningLevelsHP:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

mouseOverSettings.mediumWarningLevelsHP:SetScript("OnValueChanged",function()
  mediumWarningMouseOverHP = mouseOverSettings.mediumWarningLevelsHP:GetValue()
  getglobal(mouseOverSettings.mediumWarningLevelsHP:GetName() .. 'Text'):SetText('Or mob HP > ' .. string.format("%.1f",mediumWarningMouseOverHP) .. '  (' ..string.format("%d",UnitHealth("player") * mediumWarningMouseOverHP)..')') 
  if GetTime() > lastmouseoversoundPlayed + 2 then
	PlaySound(mediumWarningSound,"SFX") 
	lastmouseoversoundPlayed = GetTime()
  end
end)
yoff = yoff + 50

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
  oldLargeHP = largeWarningMouseOverHP
  oldMediumHP = mediumWarningMouseOverHP
 
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
