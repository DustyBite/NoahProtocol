extends ListTab

@onready var titleLabel: Label = $fromLabel
@onready var image: TextureRect = $TextureRect
@onready var bodyLabel: RichTextLabel = $RichTextLabel

func _ready() -> void:
	Globals.guideListChanged.connect(refreshList)
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # keeps pixel art crisp
	refreshList()

func getItems() -> Array:
	return Content.guides.filter(func(e): return Globals.guidesUnlocked.has(e.id))

func rowText(g: Dictionary) -> String:
	return g.title

func showItem(g: Dictionary) -> void:
	titleLabel.text = g.title
	bodyLabel.text = g.body
	bodyLabel.scroll_to_line(0)

	var path = g.get("image", "")
	if path != "" and ResourceLoader.exists(path):
		image.texture = load(path)
		image.show()
	else:
		image.hide()   # guides without an image just don't show the box

func clearDetail() -> void:
	titleLabel.text = "NO GUIDES"
	bodyLabel.text = ""
	image.hide()
