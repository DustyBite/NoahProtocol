extends ListTab

@onready var fromLabel: Label = $VBoxContainer/fromLabel
@onready var subjectLabel: Label = $VBoxContainer/subjectLabel
@onready var bodyLabel: RichTextLabel = $VBoxContainer/RichTextLabel

func _ready() -> void:
	Globals.emailListChanged.connect(refreshList)
	refreshList()

func getItems() -> Array:
	return Content.emails.filter(func(e): return Globals.emailsUnlocked.has(e.id))

func rowText(e: Dictionary) -> String:
	var unread = not Globals.emailsRead.has(e.id)
	return ("*" if unread else "") + "[ " + e.from + " ]  " + e.subject

func showItem(e: Dictionary) -> void:
	fromLabel.text = "FROM: " + e.from
	subjectLabel.text = "SUBJ: " + e.subject
	bodyLabel.text = e.body
	bodyLabel.scroll_to_line(0)
	Globals.markEmailRead(e.id)

func clearDetail() -> void:
	fromLabel.text = ""
	subjectLabel.text = "NO MESSAGES"
	bodyLabel.text = ""
