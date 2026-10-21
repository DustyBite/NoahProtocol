extends Node

var singleplayerMode = true
var launchMode: String

var devMode: bool = false

var pointTotal: float = 0
var cardsProcessed: float = 0

var powerOn: bool = true

var type2Consumables: bool = false

var avalibleEmail: int = 0

var unlockArray = [0,0,0,0,0,0,0,0,0]

var hoverColor: Color = Color(1,1,1,1)

func _process(_delta: float) -> void:
	if cardsProcessed > 6:
			avalibleEmail = 1
	elif cardsProcessed > 100:
			avalibleEmail = 2

# Email Functions

signal emailListChanged
signal emailsChanged

var emailsUnlocked: Dictionary = {}
var emailsRead: Dictionary = {}

func unlockEmail(id: String) -> void:
	if emailsUnlocked.has(id):
		return
	emailsUnlocked[id] = true
	emailListChanged.emit()
	emailsChanged.emit()

func markEmailRead(id: String) -> void:
	if emailsRead.has(id):
		return
	emailsRead[id] = true
	emailsChanged.emit()

func hasUnreadEmail() -> bool:
	for id in emailsUnlocked:
		if not emailsRead.has(id):
			return true
	return false

func refreshEmails() -> void:   # call after loading a save
	emailListChanged.emit()
	emailsChanged.emit()

# Guide Functions

signal guideListChanged
signal guidesChanged

var guidesUnlocked: Dictionary = {}
var guidesRead: Dictionary = {}

func unlockGuide(id: String) -> void:
	if guidesUnlocked.has(id):
		return
	guidesUnlocked[id] = true
	guideListChanged.emit()
	guidesChanged.emit()

func markGuideRead(id: String) -> void:
	if guidesRead.has(id):
		return
	guidesRead[id] = true
	guidesChanged.emit()

func hasUnreadGuide() -> bool:
	for id in guidesUnlocked:
		if not guidesRead.has(id):
			return true
	return false

func refreshGuide() -> void:
	guideListChanged.emit()
	guidesChanged.emit()

# Upgrade Functions

signal upgradesChanged

var upgradesOwned: Dictionary = {}   # { "processing_chip": 2 }

func ownedCount(id: String) -> int:
	return int(upgradesOwned.get(id, 0))   # int(): JSON loads numbers back as floats

func upgradeCost(u: Dictionary) -> int:
	return int(u.cost) + int(u.get("costStep", 0)) * ownedCount(u.id)

func canBuy(u: Dictionary) -> bool:
	return ownedCount(u.id) < int(u.max) and pointTotal >= upgradeCost(u)

func buyUpgrade(u: Dictionary) -> bool:
	if not canBuy(u):
		return false
	pointTotal -= upgradeCost(u)
	upgradesOwned[u.id] = ownedCount(u.id) + 1
	upgradesChanged.emit()
	return true
