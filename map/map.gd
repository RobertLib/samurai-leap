extends Node2D

var timer := 0.0

@onready var map1 := $Map1 as Sprite2D
@onready var map2 := $Map2 as Sprite2D
@onready var maps := [map1, map2]
@onready var label1 := $CanvasLayer/MarginContainer/MarginContainer/Label1 as Label
@onready var label2 := $CanvasLayer/MarginContainer/MarginContainer/Label2 as Label
@onready var labels := [label1, label2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.level in range(1, 3):
		maps[0].visible = true
		labels[0].visible = true
	elif Globals.level in range(3, 6):
		maps[1].visible = true
		labels[1].visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta

	if timer > 5.0:
		Globals.next_level()
