extends Panel

@onready var textColorSliders: Array = [
	$textRSlider, 
	$textGSlider, 
	$textBSlider
]
@onready var HoverColorSliders: Array = [
	$hoverRSlider,
	$hoverGSlider,
	$hoverBSlider
]

@onready var textColorRec = $textColorRec
@onready var hoverColorRec = $hoverColorRec

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HoverColorSliders[0].value = Globals.hoverColor.r * 100
	HoverColorSliders[1].value = Globals.hoverColor.g * 100
	HoverColorSliders[2].value = Globals.hoverColor.b * 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var hoverColorNew = Color(HoverColorSliders[0].value/100,HoverColorSliders[1].value/100,HoverColorSliders[2].value/100)
	var textColorNew = Color(textColorSliders[0].value/100,textColorSliders[1].value/100,textColorSliders[2].value/100)
	
	hoverColorRec.color = hoverColorNew
	Globals.hoverColor = hoverColorNew
	
	textColorRec.color = textColorNew
