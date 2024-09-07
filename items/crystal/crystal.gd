class_name Crystal

extends RigidBody2D

enum TYPE { GREEN, RED }

@export var type: TYPE = TYPE.GREEN

var colliding_player: Player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if colliding_player and Input.is_action_pressed("ui_down"):
		colliding_player.pick_up_crystal("green" if type == TYPE.GREEN else "red")
		queue_free()


func _on_area_2d_body_entered(body: Node2D):
	if body is Player:
		colliding_player = body


func _on_area_2d_body_exited(body: Node2D):
	if body is Player:
		colliding_player = null
