class_name DialogArea

extends Node2D

@export var text := ""
@export var trigger_on_collision := true

@onready var dialog := get_node("/root/Level/Dialog") as Dialog


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if trigger_on_collision and body is Player:
		show_dialog()


func show_dialog():
	dialog.show_dialog(text)
	queue_free()
