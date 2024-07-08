class_name Blob

extends CharacterBody2D

enum BlobState { GOOD, EVIL }

const CrystalGreen := preload("res://items/crystal_green/crystal_green.tscn")
const CrystalRed := preload("res://items/crystal_red/crystal_red.tscn")

@export var state: BlobState = BlobState.GOOD

var direction := -1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed := randf_range(50, 100)
var direction_change_delay := 0.5
var direction_change_timer := 0.0
var attack_delay := 0.5
var attack_timer := 0.0
var lives := 1

@onready var sprite := $Sprite2D as Sprite2D
@onready var raycast_left := $RayCast_Left as RayCast2D
@onready var raycast_right := $RayCast_Right as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var animation_tree := $AnimationTree as AnimationTree


func _ready():
	_update_state()

	var animation_start_delay = randf_range(0, animation_player.get_animation("walk").length)

	await get_tree().create_timer(animation_start_delay).timeout

	animation_tree.active = true


func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Check if there's ground on the sides
	var is_ground_left = raycast_left.is_colliding()
	var is_ground_right = raycast_right.is_colliding()

	# Change direction if there's a risk of falling.
	if (direction == 1 and not is_ground_right) or (direction == -1 and not is_ground_left):
		change_direction()

	# Check for collision and change direction if needed
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)

		if collision and collision.get_collider():
			if collision.get_collider().is_in_group("Terrain"):
				# Check if the collision is on the left or right side
				if (
					(velocity.x > 0 and collision.get_normal().x < 0)
					or (velocity.x < 0 and collision.get_normal().x > 0)
				):
					change_direction()
			if collision.get_collider().is_in_group("Enemies"):
				_on_collision_with_enemy(collision.get_collider())
			if collision.get_collider().is_in_group("Player"):
				_on_collision_with_player(collision.get_collider())

	direction_change_timer = max(0, direction_change_timer - delta)
	attack_timer = max(0, attack_timer - delta)

	move_and_slide()


func change_direction():
	if direction_change_timer == 0:
		direction *= -1
		direction_change_timer = direction_change_delay


func _on_collision_with_enemy(enemy: CharacterBody2D):
	if enemy.is_in_group("Blob"):
		change_direction()
		enemy.change_direction()

		if state == BlobState.EVIL and enemy.state == BlobState.GOOD:
			_attack(enemy)


func _on_collision_with_player(_player: CharacterBody2D):
	if state == BlobState.GOOD:
		change_direction()


func _attack(enemy: CharacterBody2D):
	if attack_timer == 0:
		# 50% chance to hit the enemy
		if randf() > 0.5:
			enemy.take_damage(1)
			_add_life()

			SoundManager.play_sound("enemy_eating")

		attack_timer = attack_delay


func _add_life():
	lives += 1
	_animate_scale(scale * 1.15)


func _animate_scale(to_scale: Vector2):
	var tween = create_tween()
	tween.tween_property(self, "scale", to_scale * 1.2, 0.1)
	tween.tween_property(self, "scale", to_scale * 0.9, 0.1)
	tween.tween_property(self, "scale", to_scale * 1.05, 0.1)
	tween.tween_property(self, "scale", to_scale, 0.1)


func take_damage(damage: int):
	lives -= damage

	animation_tree.set("parameters/conditions/damage", true)
	await get_tree().create_timer(0.2).timeout

	if lives > 0:
		animation_tree.set("parameters/conditions/damage", false)
		animation_tree.set("parameters/conditions/walk", true)
	else:
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

		crystal.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(200, 400)

		get_parent().call_deferred("add_child", crystal)


func _update_collision_mask():
	if state == BlobState.GOOD:
		collision_mask |= 1 << 0  # Player
	else:
		collision_mask &= ~(1 << 0)


func _update_state():
	if state == BlobState.EVIL:
		sprite.texture = preload("res://enemies/blob/blob_evil.png")
	else:
		sprite.texture = preload("res://enemies/blob/blob_good.png")

	_update_collision_mask()


func _set_state(new_state: BlobState):
	state = new_state
	_update_state()
