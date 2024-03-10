extends Node2D

var timer := 0.0

@onready var map1 := $Map1 as Sprite2D
@onready var map2 := $Map2 as Sprite2D
@onready var map3 := $Map3 as Sprite2D
@onready var map4 := $Map4 as Sprite2D
@onready var label1 := $CanvasLayer/MarginContainer/MarginContainer/Label1 as Label
@onready var label2 := $CanvasLayer/MarginContainer/MarginContainer/Label2 as Label
@onready var label3 := $CanvasLayer/MarginContainer/MarginContainer/Label3 as Label
@onready var label4 := $CanvasLayer/MarginContainer/MarginContainer/Label4 as Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.level in range(1, 3):
		map1.visible = true
		label1.visible = true
	elif Globals.level in range(3, 6):
		map2.visible = true
		label2.visible = true
	elif Globals.level in range(6, 9):
		map3.visible = true
		label3.visible = true
	elif Globals.level in range(9, 12):
		map4.visible = true
		label4.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta

	if timer > 5.0:
		Globals.next_level()
