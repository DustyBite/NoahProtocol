extends Control

# Export vars

@export var upgrades: Array [Button]
@export var mainTerminal: Node

# Onready vars


@onready var tabButtons: Array = [$Panel/mainNavigation/buttons/guidesTabButton, $Panel/mainNavigation/buttons/emailTabButton, $Panel/mainNavigation/buttons/upgradeTabButton, $Panel/mainNavigation/buttons/achievementTabButton, $Panel/mainNavigation/buttons/saveTabButton]

@onready var tabs: Array = [$Panel/guideTab, $Panel/emailTab, $Panel/upgradeTab, $Panel/achivementsTab, $Panel/saveTab]


@onready var emailTab = $Panel/emailTab
@onready var guideTab = $Panel/guideTab

@onready var upgradeTab = $Panel/upgradeTab
@onready var achievmentsTab = $Panel/achivementsTab
@onready var saveTab = $Panel/saveTab


# basic vars

var activeTab
var currentTab = 0

var emailTabNum: int = 0
var upgradeTabNum: int = 0
var achievmentsTabNum: int = 0
var saveTabNum: int = 0

var currentUpgrade = 0

func _ready() -> void:
	upgradeTab.mainTerminal = mainTerminal

func _process(_delta: float) -> void:
	checkUnlocks()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("navLeft") or event.is_action_pressed("left"):
		if currentTab < tabButtons.size()-1:
			currentTab += 1
			tabButtons[currentTab].grab_focus()
			tabButtons[currentTab].pressed.emit()
		else:
			currentTab = 0
			tabButtons[currentTab].grab_focus()
			tabButtons[currentTab].pressed.emit()
	
	if event.is_action_pressed("navRight") or event.is_action_pressed("right"):
		if currentTab > 0:
			currentTab -= 1
			tabButtons[currentTab].grab_focus()
			tabButtons[currentTab].pressed.emit()
		else:
			currentTab = tabButtons.size()-1
			tabButtons[currentTab].grab_focus()
			tabButtons[currentTab].pressed.emit()
	
	if event.is_action_pressed("navUp") or event.is_action_pressed("forward"):
		chanceTab(-1)
	
	if event.is_action_pressed("navDown") or event.is_action_pressed("back"):
		chanceTab(1)
	
	if event.is_action_pressed("select"):
		if activeTab == upgradeTab:
			upgradeTab.buy()

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
		upgradeTab:
			upgradeTab.navigate(value)
		emailTab:
			emailTab.navigate(value)
		guideTab:
			guideTab.navigate(value)

func checkUnlocks():
	var i = upgrades.size()
	while i > 0:
		i -= 1
		if Globals.unlockArray[i] == 1:
			upgrades[i].text = "Purchased!"

func _on_guides_tab_button_pressed() -> void:
	setActiveTab(0)

func _on_email_tab_button_pressed() -> void:
	setActiveTab(1)

func _on_upgrade_tab_button_pressed() -> void:
	setActiveTab(2)

func _on_achivement_tab_button_pressed() -> void:
	setActiveTab(3)

func _on_save_tab_button_pressed() -> void:
	setActiveTab(4)
