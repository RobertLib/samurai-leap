extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("_change_scene")


func _change_scene() -> void:
	get_tree().change_scene_to_file("res://map/map.tscn")
