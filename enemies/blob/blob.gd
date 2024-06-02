class_name Blob

extends CharacterBody2D

const SPEED := 100.0

var direction := -1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var raycast_left := $RayCast_Left as RayCast2D
@onready var raycast_right := $RayCast_Right as RayCast2D


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
	queue_free()
