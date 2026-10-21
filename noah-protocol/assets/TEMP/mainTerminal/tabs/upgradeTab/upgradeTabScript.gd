extends ListTab

@onready var nameLabel: Label = $VBoxContainer/fromLabel
@onready var infoLabel: Label = $VBoxContainer/subjectLabel
@onready var descLabel: RichTextLabel = $VBoxContainer/RichTextLabel

var mainTerminal: Node
@onready var upgradeCard = preload("res://assets/interactables/cassetteItems/upgradeCartridge.tscn")

func _ready() -> void:
	Globals.upgradesChanged.connect(refreshList)
	refreshList()

func getItems() -> Array:
	return Content.purchases

func rowText(u: Dictionary) -> String:
	var owned = Globals.ownedCount(u.id)
	var price = "MAXED" if owned >= int(u.max) else "%04d" % Globals.upgradeCost(u)
	return "%-22s %d/%s  %s" % [u.name, owned, u.max, price]

func showItem(u: Dictionary) -> void:
	var owned = Globals.ownedCount(u.id)
	nameLabel.text = u.name
	descLabel.text = u.body
	if owned >= int(u.max):
		infoLabel.text = "OWNED %d/%s  MAXED" % [owned, u.max]
	else:
		infoLabel.text = "OWNED %d/%s  COST %04d" % [owned, u.max, Globals.upgradeCost(u)]

func clearDetail() -> void:
	nameLabel.text = "NO UPGRADES"

# call from your confirm key
func buy() -> void:
	if shown.is_empty():
		return

	var u = shown[currentIndex]
	var owned = Globals.ownedCount(u.id)

	if owned >= int(u.max):
		print("Can't buy %s: already owned" % u.name)
		return

	var cost = Globals.upgradeCost(u)
	if Globals.pointTotal < cost:
		print("Can't buy %s: need %d points, have %d" % [u.name, cost, Globals.pointTotal])
		return

	if Globals.buyUpgrade(u):
		print("Purchased %s for %d points" % [u.name, cost])
		applyEffect(u)


func applyEffect(u: Dictionary) -> void:
	match u.get("effect", "none"):
		"spawnUpgrade":
			mainTerminal.spawnUpgrade(upgradeCard, u.type, int(u.value))
		"flag":
			Globals.set(u.flag, true)
		"none":
			pass
		_:
			push_warning("Unknown upgrade effect: " + str(u.effect))
