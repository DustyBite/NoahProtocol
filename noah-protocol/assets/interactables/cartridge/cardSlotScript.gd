extends ItemSlot

func loadItem(card: PackedScene, doSpawn: bool, status = null) -> void:
	if doSpawn:
		var I = card.instantiate()
		slotItem(I)
		if status != null:
			I.status = status

func deloadItem() -> void:
	if slottedItem != null:
		slottedItem.queue_free()
