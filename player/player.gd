extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var last_direction := 1.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position := Vector2.ZERO

@onready var animation_tree := $AnimationTree as AnimationTree


func _ready():
	animation_tree.active = true
	start_position = position


func _process(_delta: float):
	_update_animation_parameters()

	if position.y >= 830:
		position = start_position


func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Check for collision
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)

		if collision:
			if collision.get_collider().is_in_group("Blob"):
				_on_collision_with_blob(collision.get_collider())


func _on_collision_with_blob(blob: CharacterBody2D):
	_bounce_off_the_blob(blob)


func _bounce_off_the_blob(blob: CharacterBody2D):
	# Calculate the bounce direction based on the relative position of the blob
	var bounce_direction = sign(position.x - blob.position.x)

	# Set the bounce speed and direction
	var bounce_speed = SPEED * 4
	velocity.x = bounce_direction * bounce_speed
	velocity.y = JUMP_VELOCITY * 0.5

	# Move the player a bit to avoid getting stuck
	position.x += bounce_direction * 10


func _update_animation_parameters():
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if last_direction:
		animation_tree["parameters/Idle/blend_position"] = Vector2(last_direction, 0)
		animation_tree["parameters/Walk/blend_position"] = Vector2(last_direction, 0)
