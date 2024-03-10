class_name Checkpoint

extends Area2D

var active := false

@onready var color_rect := $ColorRect as ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		color_rect.color = Color(0, 0.5, 0, 0.5)
		active = true
