extends ItemSlot

var storedCard: Dictionary = {"card": 0, "status": null}
var spawn: bool = false

func loadItem(card, intitialSpawn):
	if spawn or intitialSpawn:
		var I = card.instantiate()
		slotItem(I)

func deloadItem():
	if slottedItem != null:
		slottedItem.queue_free()

func saveCardInfo(card):
	if card == null:
		storedCard = {"card": 0, "status": null}
		spawn = false
	else:
		storedCard = {"card": 1, "status": card.status}
		spawn = true

func getCardInfo(card):
	card.status = storedCard.status

func slotItem(card) -> void:
	super.slotItem(card)
	
	if storedCard.card == 0:
		saveCardInfo(card)
	else:
		getCardInfo(card)

func clearSlot() -> void:
	super.clearSlot()
	saveCardInfo(null)
