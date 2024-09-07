class_name Level

extends Node2D

@onready var camera := $Player/Camera2D as Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.limit_right = (
		$TileMapLayer.get_used_rect().size.x
		* $TileMapLayer.tile_set.tile_size.x
		* $TileMapLayer.scale.x
	)

	camera.limit_bottom = (
		$TileMapLayer.get_used_rect().size.y
		* $TileMapLayer.tile_set.tile_size.y
		* $TileMapLayer.scale.y
	)


func get_limit_right() -> float:
	return camera.limit_right


func get_limit_bottom() -> float:
	return camera.limit_bottom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
