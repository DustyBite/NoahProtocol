extends Control

@onready var tabButtons: Array = [$Panel/mainNavigationTerminal/emailTabButton, $Panel/mainNavigationTerminal/upgradeTabButton, $Panel/mainNavigationTerminal/achivementTabButton, $Panel/mainNavigationTerminal/saveTabButton]

@onready var tabs: Array = [$Panel/emailTerminal, $Panel/upgradeTerminal, $Panel/achivementsTerminal, $Panel/saveTerminal]

@onready var emailTab = $Panel/emailTerminal
@onready var upgradeTab = $Panel/upgradeTerminal
@onready var achievmentsTab = $Panel/achivementsTerminal
@onready var saveTab = $Panel/saveTerminal

# basic vars

var activeTab
var currentTab = 0
var activeButtons: Array

var emailTabNum: int = 0
var upgradeTabNum: int = 0
var achievmentsTabNum: int = 0
var saveTabNum: int = 0

var TEMPI = 0

func _process(_delta: float) -> void:
	checkEmails()

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
			print(emailTabNum)
			emailTabNum += value
			print(emailTabNum)
			
			if emailTabNum < 0:
				emailTabNum = 2
			elif emailTabNum > 2:
				emailTabNum = 0
			
			print(emailTabNum)
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

func _on_email_tab_button_pressed() -> void:
	setActiveTab(0)

func _on_upgrade_tab_button_pressed() -> void:
	setActiveTab(1)

func _on_achivement_tab_button_pressed() -> void:
	setActiveTab(2)

func _on_save_tab_button_pressed() -> void:
	setActiveTab(3)
