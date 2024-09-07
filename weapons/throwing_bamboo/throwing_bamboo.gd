class_name ThrowingBamboo

extends Area2D

const SPEED := 1000.0

var direction := 1.0
var timer := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	timer += delta

	if timer > 2.0:
		queue_free()

	position.x += SPEED * direction * delta


func _on_body_entered(body: Node2D):
	if body.is_in_group("Enemies"):
		SoundManager.play_sound("bamboo_hit")
		body.take_damage(1)
		queue_free()
