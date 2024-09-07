class_name BambooTree

extends Area2D

const BambooTwigScene := preload("res://items/bamboo_twig/bamboo_twig.tscn")

var dead := false

@onready var shader_material := $Sprite2D.material as ShaderMaterial
@onready var sprite := $Sprite2D as Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	shader_material = ShaderMaterial.new()
	shader_material.shader = sprite.material.shader
	sprite.material = shader_material

	shader_material.set_shader_parameter("time", randf_range(0, 5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	shader_material.set_shader_parameter(
		"time", shader_material.get_shader_parameter("time") + delta
	)


func spawn_bamboo_twigs():
	if dead:
		return

	var num_bamboo_twigs := randi_range(1, 3)

	for i in range(num_bamboo_twigs):
		var bamboo_twig := BambooTwigScene.instantiate()

		bamboo_twig.global_position = global_position

		var angle := randf_range(-PI, 0)

		bamboo_twig.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(200, 400)
		bamboo_twig.angular_velocity = randf_range(-2, 2)

		get_parent().call_deferred("add_child", bamboo_twig)

	dead = true

	_desaturate()


func _desaturate():
	var desaturation_shader := Shader.new()
	(
		desaturation_shader
		. set_code(
			"shader_type canvas_item; void fragment() { COLOR.rgb = vec3(dot(COLOR.rgb, vec3(0.333))); }"
		)
	)

	var desaturation_material := ShaderMaterial.new()
	desaturation_material.shader = desaturation_shader

	sprite.material = desaturation_material
