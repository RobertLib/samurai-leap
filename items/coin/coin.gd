class_name Coin

extends Area2D

@export_range(0, 2) var frame := 0

@onready var sprite := $Sprite2D as Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.region_rect.position.x += sprite.region_rect.size.x * frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(_body):
	queue_free()
