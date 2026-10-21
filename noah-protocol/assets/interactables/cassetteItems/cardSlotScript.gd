extends ItemSlot

func loadCard(card: PackedScene, doSpawn: bool, status, caseColor: Color, handleColor: Color) -> void:
	if doSpawn:
		var I = card.instantiate()
		slotItem(I)
		if status != null:
			I.status = status
			I.caseColor = caseColor
			I.handleColor = handleColor
			I.applyCardVisuals()

func deloadCard() -> void:
	if slottedItem != null:
		slottedItem.queue_free()
