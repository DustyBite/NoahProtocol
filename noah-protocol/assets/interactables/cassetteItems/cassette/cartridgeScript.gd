extends InteractableDynamic

# Export vars

@export var caseColorNew := Color(1.0, 1.0, 1.0, 1.0)
@export var caseColorAged := Color(.78, 0.65, 0.25, 1.0)

@export var corruptChanceNew: float = 0.02
@export var corruptChanceAged: float = 0.30
@export var wipedChance: float = 0.05
@export var processedChance: float = 0.10

# Basic vars

var cardAge: float = 0

var caseColor: Color
var handleColor: Color

var status: String = "loaded"

var blinkFlip: bool = true
var blinkTimer: float = 0.0
var blinkInterval: float = 0.5  # seconds per blink

var processProgress: float = 0
var wipeProgress: float = 0

func _ready() -> void:
	super._ready()
	cardAge = getRandomAge()
	applyCardVisuals()
	
	randStatus()
	blinkTimer = randf() * blinkInterval

func _process(delta: float) -> void:
	blinkTimer += delta
	if blinkTimer >= blinkInterval:
		blinkTimer = fmod(blinkTimer, blinkInterval)
		blinkIndicLight()
	
	updateStatus()

func getRandomAge():
	var roll = randf()
	if roll < 0.6:
		return randf_range(0.0, 0.2)
	if roll < 0.9:
		return randf_range(0.2, 0.6)
	else:
		return randf_range(0.6, 1.0)

func applyCardVisuals():
	
	for mat in baseMaterial:
		if caseColor == null or caseColor == Color():
			caseColor = caseColorNew.lerp(caseColorAged, cardAge)
		mat.set_shader_parameter("caseColor", caseColor)
		
		if handleColor == null or handleColor == Color():
			handleColor = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
			handleColor = handleColor.lerp(Color(0.6, 0.5, 0.2), cardAge * 0.6)
		mat.set_shader_parameter("handleColor", handleColor)

func getPoints() -> int:
	match status:
		"loaded": return -20
		"processing": return 0
		"clear": return 15
		"corrupted": return -5
	return 0

func updateStatus():
	for mat in baseMaterial:
		match status:
			"loaded":
				mat.set_shader_parameter("indicBColor", Color(0,1,0,0.5))
			"processing":
				mat.set_shader_parameter("indicBColor", Color(1,.5,0,0.5))
			"clear":
				mat.set_shader_parameter("indicBColor", Color(0,0,1,0.5))
			"corrupted":
				mat.set_shader_parameter("indicBColor", Color(1,0,0,0.5))

func blinkIndicLight():
	for mat in baseMaterial:
		blinkFlip = !blinkFlip
		
		if blinkFlip:
			mat.set_shader_parameter("indicAColor", Color(0,0,0,1))
		else:
			mat.set_shader_parameter("indicAColor", Color(0,1,0,1))

func randStatus():
	var corruptChance = lerp(corruptChanceNew, corruptChanceAged, cardAge)
	
	if randf() < corruptChance:
		status = "corrupted"
		return
	
	var roll = randf()
	if roll < wipedChance:
		status = "clear"
		wipeProgress = 100.0
	elif roll < wipedChance + processedChance:
		status = "processing"
		processProgress = 100.0
	else:
		status = "loaded"
