extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if Input.is_action_just_pressed("ui_select"):
		_change_scene()


func _on_video_stream_player_finished():
	_change_scene()


func _change_scene():
	get_tree().change_scene_to_file("res://level_selection/level_selection.tscn")


func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		_change_scene()
