class_name Boulder

extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision := move_and_collide(Vector2(-1000 * delta, 0))

	if collision and collision.get_collider() is Player:
		if is_inside_tree():
			await get_tree().create_timer(0.1).timeout
		queue_free()

	if global_position.x < -100:
		queue_free()
