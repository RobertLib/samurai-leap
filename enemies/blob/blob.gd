class_name Blob

extends CharacterBody2D

enum BlobState { GOOD, EVIL }

const SPEED := 100.0

const CrystalGreen := preload("res://items/crystal_green/crystal_green.tscn")
const CrystalRed := preload("res://items/crystal_red/crystal_red.tscn")

@export var state: BlobState = BlobState.GOOD

var direction := -1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite := $Sprite2D as Sprite2D
@onready var raycast_left := $RayCast_Left as RayCast2D
@onready var raycast_right := $RayCast_Right as RayCast2D


func _ready():
	_update_state()


func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Check if there's ground on the sides
	var is_ground_left = raycast_left.is_colliding()
	var is_ground_right = raycast_right.is_colliding()

	# Change direction if there's a risk of falling.
	if (direction == 1 and not is_ground_right) or (direction == -1 and not is_ground_left):
		direction *= -1

	# Check for collision and change direction if needed
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)

		if collision and collision.get_collider().is_in_group("Terrain"):
			# Check if the collision is on the left or right side
			if (
				(velocity.x > 0 and collision.get_normal().x < 0)
				or (velocity.x < 0 and collision.get_normal().x > 0)
			):
				direction *= -1  # Change direction
				break  # Exit the loop as we have already processed the collision

	move_and_slide()


func take_damage(_damage: int):
	_spawn_crystals()
	queue_free()


func _spawn_crystals():
	var num_crystals = randi_range(1, 3)

	for i in range(num_crystals):
		var crystal = (
			(CrystalRed if state == BlobState.GOOD else CrystalGreen).instantiate() as RigidBody2D
		)

		crystal.global_position = global_position

		var angle = randf_range(-PI, 0)
		var speed = randf_range(200, 400)

		crystal.linear_velocity = Vector2(cos(angle), sin(angle)) * speed

		get_parent().call_deferred("add_child", crystal)


func _update_state():
	if state == BlobState.EVIL:
		sprite.modulate = Color(1, 0.4, 0.4)  # Set sprite to red color
	else:
		sprite.modulate = Color(1, 1, 1)  # Reset sprite to default color


func _set_state(new_state: BlobState):
	state = new_state
	_update_state()
