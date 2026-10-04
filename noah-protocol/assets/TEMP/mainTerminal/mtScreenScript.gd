extends Control

# Export vars

@export var upgrades: Array [Button]
@export var mainTerminal: Node

# Onready vars


@onready var tabButtons: Array = [$Panel/mainNavigationTerminal/emailTabButton, $Panel/mainNavigationTerminal/upgradeTabButton, $Panel/mainNavigationTerminal/achivementTabButton, $Panel/mainNavigationTerminal/saveTabButton]

@onready var tabs: Array = [$Panel/emailTerminal, $Panel/upgradeTerminal, $Panel/achivementsTerminal, $Panel/saveTerminal]


@onready var emailTab = $Panel/emailTerminal
@onready var upgradeTab = $Panel/upgradeTerminal
@onready var achievmentsTab = $Panel/achivementsTerminal
@onready var saveTab = $Panel/saveTerminal

@onready var upgradeCard = preload("res://assets/interactables/cartridge/upgradeCartridge.tscn")

# basic vars

var activeTab
var currentTab = 0

var emailTabNum: int = 0
var upgradeTabNum: int = 0
var achievmentsTabNum: int = 0
var saveTabNum: int = 0

var currentUpgrade = 0

func _process(_delta: float) -> void:
	checkEmails()
	
	checkUnlocks()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("navDown") or event.is_action_pressed("back"):
		if currentTab < tabButtons.size()-1:
			currentTab += 1
			tabButtons[currentTab].grab_focus()
		else:
			currentTab = 0
			tabButtons[currentTab].grab_focus()
	
	if event.is_action_pressed("navUp") or event.is_action_pressed("forward"):
		if currentTab > 0:
			currentTab -= 1
			tabButtons[currentTab].grab_focus()
		else:
			currentTab = tabButtons.size()-1
			tabButtons[currentTab].grab_focus()
	
	if event.is_action_pressed("navLeft") or event.is_action_pressed("left"):
		chanceTab(-1)
	
	if event.is_action_pressed("navRight") or event.is_action_pressed("right"):
		chanceTab(1)

func setActiveTab(tabNumber):
	if activeTab == null:
		tabs[tabNumber].visible = true
		activeTab = tabs[tabNumber]
	elif activeTab != null:
		activeTab.visible = false
		tabs[tabNumber].visible = true
		activeTab = tabs[tabNumber]

func chanceTab(value):
	match activeTab:
		emailTab:
			emailTabNum += value
			
			if emailTabNum < 0:
				emailTabNum = 2
			elif emailTabNum > 2:
				emailTabNum = 0
			
			match emailTabNum:
				0:
					$Panel/emailTerminal/email1.visible = true
					$Panel/emailTerminal/email2.visible = false
					$Panel/emailTerminal/email3.visible = false
				1:
					$Panel/emailTerminal/email1.visible = false
					$Panel/emailTerminal/email3.visible = false
					
					if Globals.avalibleEmail >= 1:
						$Panel/emailTerminal/email2.visible = true
				2:
					$Panel/emailTerminal/email1.visible = false
					$Panel/emailTerminal/email2.visible = false
					
					if Globals.avalibleEmail >= 2:
						$Panel/emailTerminal/email3.visible = true
		upgradeTab:
			currentUpgrade += value
			
			if currentUpgrade < 0:
				currentUpgrade = upgrades.size()-1
			elif currentUpgrade > upgrades.size()-1:
				currentUpgrade = 0
			upgrades[currentUpgrade].grab_focus()

func checkEmails():
	match Globals.avalibleEmail:
		0:
			$Panel/emailTerminal/emailTab1.visible = true
		1:
			$Panel/emailTerminal/emailTab1.visible = true
			$Panel/emailTerminal/emailTab2.visible = true
		2:
			$Panel/emailTerminal/emailTab1.visible = true
			$Panel/emailTerminal/emailTab2.visible = true
			$Panel/emailTerminal/emailTab3.visible = true

func checkUnlocks():
	var i = upgrades.size()
	while i > 0:
		i -= 1
		if Globals.unlockArray[i] == 1:
			upgrades[i].text = "Purchased!"

func _on_email_tab_button_pressed() -> void:
	setActiveTab(0)

func _on_upgrade_tab_button_pressed() -> void:
	setActiveTab(1)

func _on_achivement_tab_button_pressed() -> void:
	setActiveTab(2)

func _on_save_tab_button_pressed() -> void:
	setActiveTab(3)

# upgrade Buttons

func _on_process_1_pressed() -> void:
	if Globals.unlockArray[0] == 0 and Globals.pointTotal >= 100:
		Globals.unlockArray[0] = 1
		Globals.pointTotal -= 100
		
		mainTerminal.spawnUpgrade(upgradeCard, "processUpgrade", 4)

func _on_upload_1_pressed() -> void:
	if Globals.unlockArray[1] == 0 and Globals.pointTotal >= 100:
		Globals.unlockArray[1] = 1
		Globals.pointTotal -= 100
		
		mainTerminal.spawnUpgrade(upgradeCard, "uploadUpgrade", 4)

func _on_wipe_1_pressed() -> void:
	if Globals.unlockArray[2] == 0 and Globals.pointTotal >= 100:
		Globals.unlockArray[2] = 1
		Globals.pointTotal -= 100
		
		mainTerminal.spawnUpgrade(upgradeCard, "wipeUpgrade", 4)

func _on_process_2_pressed() -> void:
	if Globals.unlockArray[3] == 0 and Globals.pointTotal >= 1000:
		Globals.unlockArray[3] = 1
		Globals.pointTotal -= 1000
		
		mainTerminal.spawnUpgrade(upgradeCard, "processUpgrade", 2)

func _on_upload_2_pressed() -> void:
	if Globals.unlockArray[4] == 0 and Globals.pointTotal >= 1000:
		Globals.unlockArray[4] = 1
		Globals.pointTotal -= 1000
		
		mainTerminal.spawnUpgrade(upgradeCard, "uploadUpgrade", 2)

func _on_wipe_2_pressed() -> void:
	if Globals.unlockArray[5] == 0 and Globals.pointTotal >= 1000:
		Globals.unlockArray[5] = 1
		Globals.pointTotal -= 1000
		
		mainTerminal.spawnUpgrade(upgradeCard, "wipeUpgrade", 2)

func _on_food_1_pressed() -> void:
	if Globals.unlockArray[6] == 0 and Globals.pointTotal >= 500:
		Globals.unlockArray[6] = 1
		Globals.pointTotal -= 500
		
		Globals.type2Consumables = true

func _on_arcade_1_pressed() -> void:
	if Globals.unlockArray[8] == 0 and Globals.pointTotal >= 250:
		Globals.unlockArray[8] = 1
		Globals.pointTotal -= 250
