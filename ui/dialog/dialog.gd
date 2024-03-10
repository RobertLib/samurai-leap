class_name Dialog

extends CanvasLayer

var timer := 0.0

@onready var label := $MarginContainer/MarginContainer/Label as Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		timer += delta

		if timer > 10:
			_close_dialog()


func show_dialog(text: String) -> void:
	label.text = text
	show()
	timer = 0


func _close_dialog() -> void:
	label.text = ""
	hide()
	timer = 0
