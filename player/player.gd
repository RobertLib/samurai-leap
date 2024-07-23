class_name Player

extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var last_direction := 1.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position := Vector2.ZERO
var lives := 3
var is_immortal := false
var immortal_blink_time := 0.1
var blink_timer: Timer
var immortal_timer: Timer
var touched_ground := false
var is_on_ground := false
var is_attacking := false
var is_attacking_from_below := false
var green_crystals := 0
var red_crystals := 0

@onready var animation_tree := $AnimationTree as AnimationTree
@onready var navbar := get_node("/root/Level/Navbar") as Navbar
@onready var player_container := $Container as Node2D
@onready var attack_area := $Container/AttackArea as Area2D
@onready var attack_area_position := ($Container/AttackArea as Area2D).position
@onready var attack_area_bottom_position := Vector2(0, 200)
@onready var face_injury := $Container/Polygons/Head/FaceInjury as Sprite2D


func _ready():
	randomize()

	animation_tree.active = true
	start_position = position

	# Setting timer for immortality
	immortal_timer = Timer.new()
	immortal_timer.wait_time = 5.0  # Time of immortality
	immortal_timer.one_shot = true
	immortal_timer.connect("timeout", Callable(self, "_end_immortality"))
	add_child(immortal_timer)

	# Setting timer for flashing
	blink_timer = Timer.new()
	blink_timer.wait_time = immortal_blink_time
	blink_timer.one_shot = false
	blink_timer.connect("timeout", Callable(self, "_toggle_blink"))
	add_child(blink_timer)

	# Connect attack area signals
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))


func _process(_delta: float):
	_update_animation_parameters()

	if position.y >= 830:
		position = start_position


func _physics_process(delta: float):
	# Add the gravity.
	if is_on_floor():
		if not touched_ground:
			touched_ground = true
			SoundManager.play_sound("hero_jump_land")
			_end_bottom_attack()
	else:
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		touched_ground = false
		is_on_ground = false
		velocity.y = JUMP_VELOCITY
		SoundManager.play_sound("hero_jump")

	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		_start_attack()

	# Handle bottom attack
	if Input.is_action_just_pressed("ui_down") and not is_on_floor() and not is_attacking:
		_start_bottom_attack()

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
			if collision.get_collider().is_in_group("Terrain"):
				is_on_ground = true
			if collision.get_collider().is_in_group("Enemies"):
				_on_collision_with_enemy(collision.get_collider())


func _start_attack():
	is_attacking = true
	attack_area.set_monitoring(true)  # Enable attack area monitoring
	SoundManager.play_sound("hero_sword_slash_miss")
	if get_tree():
		await get_tree().create_timer(0.4).timeout
	is_attacking = false
	attack_area.set_monitoring(false)  # Disable attack area monitoring


func _start_bottom_attack():
	is_attacking = true
	is_attacking_from_below = true
	attack_area.set_monitoring(true)  # Enable attack area monitoring
	attack_area.position = attack_area_bottom_position


func _end_bottom_attack():
	is_attacking = false
	attack_area.set_monitoring(false)  # Disable attack area monitoring
	attack_area.position = attack_area_position
	if get_tree():
		await get_tree().create_timer(0.2).timeout
	is_attacking_from_below = false


func _on_attack_area_body_entered(body: Node2D):
	if body.is_in_group("Enemies"):
		body.take_damage(1)
		SoundManager.play_sound("hero_sword_slash_hit")

		if body.is_in_group("Good") and is_attacking_from_below:
			_bounce_off_the_good_blob(body)


func _on_collision_with_enemy(enemy: CharacterBody2D):
	if not is_immortal:
		if enemy is Blob:
			if enemy.is_in_group("Good"):
				if not is_on_ground:
					_bounce_off_the_good_blob(enemy)

			if enemy.is_in_group("Evil"):
				_bounce_off_the_evil_blob(enemy)
				_subtract_life()
				_start_immortality()

				(enemy as Blob).eating()

				SoundManager.play_sound("hero_got_hit")


func _bounce_off_the_good_blob(blob: Blob):
	var direction := (position - (blob.position - blob.velocity)).normalized()
	velocity = direction * SPEED * 1.5

	if velocity.y < JUMP_VELOCITY / 2:
		blob.animate_suspension()

		SoundManager.play_sound("hero_bounced_off_enemy")


func _bounce_off_the_evil_blob(blob: Blob):
	var direction := (position - (blob.position - blob.velocity)).normalized()
	velocity.x = direction.x * SPEED * 5
	velocity.y = JUMP_VELOCITY / 2

	SoundManager.play_sound("hero_bounced_off_enemy")


func _subtract_life():
	lives -= 1

	navbar.update_lives(lives)

	if lives == 0:
		get_tree().reload_current_scene()


func _update_animation_parameters():
	if is_attacking:
		animation_tree.set("parameters/conditions/idle", false)
		animation_tree.set("parameters/conditions/is_moving", false)
		animation_tree.set("parameters/conditions/is_attack", true)
	else:
		if velocity == Vector2.ZERO:
			animation_tree.set("parameters/conditions/idle", true)
			animation_tree.set("parameters/conditions/is_moving", false)
			animation_tree.set("parameters/conditions/is_attack", false)
		else:
			animation_tree.set("parameters/conditions/idle", false)
			animation_tree.set("parameters/conditions/is_moving", true)
			animation_tree.set("parameters/conditions/is_attack", false)

	if last_direction:
		animation_tree.set(
			"parameters/Idle/blend_position",
			Vector2(last_direction, -1 if Input.is_action_pressed("ui_down") else 0)
		)
		animation_tree.set(
			"parameters/Move/blend_position", Vector2(last_direction, 0 if is_on_floor() else 1)
		)
		animation_tree.set(
			"parameters/Attack/blend_position",
			Vector2(
				last_direction,
				-1 if is_attacking_from_below else 0 if velocity == Vector2.ZERO else 1
			)
		)


func _start_immortality():
	is_immortal = true
	set_collision_mask_value(3, false)
	face_injury.show()
	if get_tree():
		await get_tree().create_timer(0.5).timeout
	face_injury.hide()
	immortal_timer.start()
	blink_timer.start()


func _end_immortality():
	is_immortal = false
	set_collision_mask_value(3, true)
	blink_timer.stop()
	player_container.modulate.a = 1.0


func _toggle_blink():
	if player_container.modulate.a == 1.0:
		player_container.modulate.a = 0.6
	else:
		player_container.modulate.a = 1.0


func pick_up_crystal(type: String):
	if type == "green":
		green_crystals += 1
	elif type == "red":
		red_crystals += 1

	navbar.update_crystals(green_crystals, red_crystals)
