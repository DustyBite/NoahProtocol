extends Node

@onready var emailTxt = "res://assets/TEMP/mainTerminal/tabs/emailTab/emails.txt"
@onready var guideTxt = "res://assets/TEMP/mainTerminal/tabs/guideTab/guides.txt"
@onready var purchaseTxt = "res://assets/TEMP/mainTerminal/tabs/upgradeTab/upgrades.txt"

var emails: Array = []
var guides: Array = []
var purchases: Array = []

func _ready() -> void:
	
	emails = parseFile(emailTxt,["id", "from", "subject"])
	guides = parseFile(guideTxt,["id", "title"])
	purchases = parseFile(purchaseTxt,["id", "name", "cost", "max"])

	for e in emails:
		if e.get("unlock", "") == "start":
			Globals.unlockEmail(e.id)
	
	for g in guides:
		if g.get("unlock", "") == "start":
			Globals.unlockGuide(g.id)

func parseFile(path: String, required: Array) -> Array:
	var text = FileAccess.get_file_as_string(path).replace("\r\n", "\n")
	var result = []

	for block in text.split("\n===\n"):
		var parts = block.split("\n---\n", true, 1)
		if parts.size() < 2:
			continue

		var entry = {}
		for line in parts[0].split("\n"):
			var kv = line.split(":", true, 1)
			if kv.size() == 2:
				entry[kv[0].strip_edges()] = kv[1].strip_edges()

		var valid = true
		for key in required:
			if not entry.has(key):
				push_warning("%s: entry missing '%s': %s" % [path, key, str(entry)])
				valid = false
		if not valid:
			continue

		entry["body"] = parts[1].strip_edges()
		result.append(entry)

	return result
