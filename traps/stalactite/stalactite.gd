extends Node2D

@onready var stalactite := $RigidBody2D as RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_body_entered(_body: Node2D) -> void:
	call_deferred("unfreeze_stalactite")


func unfreeze_stalactite() -> void:
	stalactite.freeze = false
