extends Panel


signal message_logged(text)
var log_history: Array[String] = []

func log_message(text: String):
	print(text) # Still outputs to Godot's terminal
	log_history.append(text)
	message_logged.emit(text) # UI elements can listen to this to update live

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
