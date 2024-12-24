class_name Blob

extends CharacterBody2D

enum BELIEFS { GOOD, EVIL }

const CrystalGreenScene := preload("res://items/crystal/crystal_green/crystal_green.tscn")
const CrystalRedScene := preload("res://items/crystal/crystal_red/crystal_red.tscn")

@export var beliefs: BELIEFS = BELIEFS.GOOD
@export var lives := 1

var direction := -1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed := randf_range(50, 100)
var direction_change_delay := 0.5
var direction_change_timer := 0.0
var attack_delay := 0.5
var attack_timer := 0.0

@onready var container := $Container as Node2D
@onready var mouth := $Container/Mouth as Node2D
@onready var eyes := $Container/Eyes as Node2D
@onready var raycast_left := $RayCast_Left as RayCast2D
@onready var raycast_right := $RayCast_Right as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var animation_tree := $AnimationTree as AnimationTree
@onready var dialog_area := $DialogArea as DialogArea if has_node("DialogArea") else null


func _ready():
	var animation_start_delay := randf_range(0, animation_player.get_animation("walk").length)

	if is_inside_tree():
		await get_tree().create_timer(animation_start_delay).timeout

	animation_tree.active = true

	if randf() > 0.5:
		change_direction()


func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Check if there's ground on the sides
	var is_ground_left := raycast_left.is_colliding()
	var is_ground_right := raycast_right.is_colliding()

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
			if collision.get_collider() is Player:
				_on_collision_with_player(collision.get_collider())

	direction_change_timer = max(0, direction_change_timer - delta)
	attack_timer = max(0, attack_timer - delta)

	if attack_timer == 0:
		mouth.hide()

	move_and_slide()


func change_direction():
	if direction_change_timer == 0:
		direction *= -1
		direction_change_timer = direction_change_delay

		container.scale.x = -direction


func _on_collision_with_enemy(enemy: CharacterBody2D):
	if enemy is Blob:
		change_direction()
		enemy.change_direction()

		if beliefs == BELIEFS.EVIL and enemy.beliefs == BELIEFS.GOOD:
			_attack(enemy)
			enemy.bounce_off_the_evil_blob(self)


func bounce_off_the_evil_blob(blob: Blob):
	var dir := (position - (blob.position - blob.velocity)).normalized()
	velocity.x = dir.x * speed * 5
	velocity.y = -100


func _on_collision_with_player(_player: Player):
	if beliefs == BELIEFS.GOOD:
		change_direction()
	else:
		if velocity.x > 0 and position.x < _player.position.x:
			velocity.x = 0
		elif velocity.x < 0 and position.x > _player.position.x:
			velocity.x = 0


func _attack(enemy: CharacterBody2D):
	if attack_timer == 0:
		# 50% chance to hit the enemy
		if randf() > 0.5:
			mouth.show()
			enemy.take_damage(1)
			_add_life()

			SoundManager.play_sound("enemy_eating")

		attack_timer = attack_delay


func _add_life():
	lives += 1
	_animate_scale(scale * 1.15)


func _animate_scale(to_scale: Vector2):
	var tween := create_tween()
	tween.tween_property(self, "scale", to_scale * 1.2, 0.1)
	tween.tween_property(self, "scale", to_scale * 0.9, 0.1)
	tween.tween_property(self, "scale", to_scale * 1.05, 0.1)
	tween.tween_property(self, "scale", to_scale, 0.1)


func animate_suspension():
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -5), 0.1)
	tween.tween_property(self, "position", position + Vector2(0, 5), 0.1)


func eating():
	mouth.show()
	attack_timer = attack_delay


func take_damage(damage: int):
	lives -= damage
	_animate_scale(scale * 0.85 / damage)

	animation_tree.set("parameters/conditions/damage", true)
	if is_inside_tree():
		await get_tree().create_timer(0.2).timeout

	if lives > 0:
		animation_tree.set("parameters/conditions/damage", false)
		animation_tree.set("parameters/conditions/walk", true)
	else:
		_spawn_crystals()

		if has_node("DialogArea") and dialog_area and dialog_area.has_method("show_dialog"):
			dialog_area.show_dialog()

		queue_free()


func _spawn_crystals():
	var num_crystals := randi_range(1, 3)

	for i in range(num_crystals):
		var crystal := (
			(CrystalRedScene if beliefs == BELIEFS.GOOD else CrystalGreenScene).instantiate()
			as Crystal
		)

		crystal.global_position = global_position

		var angle := randf_range(-PI, 0)

		crystal.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(200, 400)

		get_parent().call_deferred("add_child", crystal)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Crystal:
		if beliefs == BELIEFS.EVIL and body.type == Crystal.TYPE.RED:
			body.queue_free()
			speed += 23
			eyes.show()
			SoundManager.play_sound("enemy_eating")
