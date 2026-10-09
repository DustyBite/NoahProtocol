extends InteractableDynamic

# Export vars

@export var caseColorNew := Color(1.0, 1.0, 1.0, 1.0)
@export var caseColorAged := Color(.78, 0.65, 0.25, 1.0)

# Basic vars

var cardAge: float = 0

var status: String = "upload"

var blinkFlip: bool = true
var blinkTimer: float = 0.0
var blinkInterval: float = 0.5  # seconds per blink

var processProgress: float = 0
var wipeProgress: float = 0

func _ready() -> void:
	super._ready()
	cardAge = getRandomAge()
	applyCardVisuals()
	
	TEMPrandStatus()
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
	var caseColor = caseColorNew.lerp(caseColorAged, cardAge)
	baseMaterial.set_shader_parameter("caseColor", caseColor)
	var handleColorBase = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
	var handleColorAged = handleColorBase.lerp(Color(0.6, 0.5, 0.2), cardAge * 0.6)
	baseMaterial.set_shader_parameter("handleColor", handleColorAged)

func getPoints() -> int:
	match status:
		"loaded": return -20
		"processing": return 0
		"clear": return 15
		"corrupted": return -5
	return 0

func updateStatus():
	match status:
		"loaded":
			baseMaterial.set_shader_parameter("indicBColor", Color(0,1,0,1))
		"processing":
			baseMaterial.set_shader_parameter("indicBColor", Color(1,.5,0,1))
		"clear":
			baseMaterial.set_shader_parameter("indicBColor", Color(0,0,1,1))
		"corrupted":
			baseMaterial.set_shader_parameter("indicBColor", Color(1,0,0,1))

func blinkIndicLight():
	blinkFlip = !blinkFlip
	
	if blinkFlip:
		baseMaterial.set_shader_parameter("indicAColor", Color(0,0,0,1))
	else:
		baseMaterial.set_shader_parameter("indicAColor", Color(0,1,0,1))

func TEMPrandStatus():
	if randf() < 0.05:
		status = "corrupted"
	else:
		status = "loaded"
