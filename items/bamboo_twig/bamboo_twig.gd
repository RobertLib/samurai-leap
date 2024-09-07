class_name BambooTwig

extends RigidBody2D

const MAX_BAMBOOS := 2

var colliding_player: Player = null
var timer := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	timer += delta

	if timer > 60:
		queue_free()

	if colliding_player and Input.is_action_pressed("ui_down"):
		if colliding_player.bamboos_count < MAX_BAMBOOS:
			colliding_player.pick_up_bamboo_twig()
			queue_free()


func _on_area_2d_body_entered(body: Node2D):
	if body is Player:
		colliding_player = body


func _on_area_2d_body_exited(body: Node2D):
	if body is Player:
		colliding_player = null
