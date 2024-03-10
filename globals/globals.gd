extends Node

const LEVELS = 12

var level = 1


func next_level():
	level += 1

	if level > LEVELS:
		level = 1

	get_tree().change_scene_to_file("res://levels/level%d/level.tscn" % level)


func change_level(number: int):
	level = number

	get_tree().change_scene_to_file("res://levels/level%d/level.tscn" % level)
