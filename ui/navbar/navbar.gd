class_name Navbar

extends CanvasLayer

@onready var lives_label := $Lives as Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass


func update_lives(lives: int) -> void:
	lives_label.text = "LIVES: " + str(lives)
