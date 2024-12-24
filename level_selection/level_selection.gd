extends Control

@onready var grid_container := $MarginContainer/GridContainer as GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for index in grid_container.get_child_count():
		var button = grid_container.get_child(index)
		button.connect("pressed", _on_button_pressed.bind(button, index))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed(_button: Button, index: int) -> void:
	Globals.change_level(index + 1)
