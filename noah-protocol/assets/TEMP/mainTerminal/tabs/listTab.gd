class_name ListTab
extends Node

@onready var list: ItemList = $ItemList

var shown: Array = []
var currentIndex := 0

# each tab overrides these three
func getItems() -> Array: return []
func rowText(_item: Dictionary) -> String: return ""
func showItem(_item: Dictionary) -> void: pass
func clearDetail() -> void: pass

func refreshList() -> void:
	list.clear()
	shown = getItems()
	for item in shown:
		list.add_item(rowText(item))

	if shown.is_empty():
		clearDetail()
		return
	selectItem(clampi(currentIndex, 0, shown.size() - 1))

func navigate(direction: int) -> void:
	if shown.is_empty():
		return
	selectItem(clampi(currentIndex + direction, 0, shown.size() - 1))

func selectItem(i: int) -> void:
	currentIndex = i
	list.select(i)
	list.ensure_current_is_visible()
	showItem(shown[i])
	list.set_item_text(i, rowText(shown[i]))
