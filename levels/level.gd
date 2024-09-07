extends Node2D

@onready var camera := $Player/Camera2D as Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.limit_right = (
		$TileMapLayer.get_used_rect().size.x
		* $TileMapLayer.tile_set.tile_size.x
		* $TileMapLayer.scale.x
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
