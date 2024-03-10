extends Node

var sounds := {}


func _ready():
	sounds["enemy_eating"] = preload("res://audio/enemy_eating.ogg")
	sounds["hero_bounced_off_enemy"] = preload("res://audio/hero_bounced_off_enemy.ogg")
	sounds["hero_got_hit"] = preload("res://audio/hero_got_hit.ogg")
	sounds["hero_health_picked_up"] = preload("res://audio/hero_health_picked_up.ogg")
	sounds["hero_jump"] = preload("res://audio/hero_jump.ogg")
	sounds["hero_jump_land"] = preload("res://audio/hero_jump_land.ogg")
	sounds["hero_sword_slash_hit"] = preload("res://audio/hero_sword_slash_hit.ogg")
	sounds["hero_sword_slash_miss"] = preload("res://audio/hero_sword_slash_miss.ogg")
	sounds["bamboo_hit"] = preload("res://audio/bamboo_hit.ogg")
	sounds["bamboo_throw"] = preload("res://audio/bamboo_throw.ogg")


func play_sound(sound_name: String):
	if sound_name in sounds:
		var audio_player := AudioStreamPlayer.new()

		add_child(audio_player)

		audio_player.stream = sounds[sound_name]
		audio_player.connect("finished", Callable(audio_player, "_on_audio_finished"))
		audio_player.play()
	else:
		print("Error: Sound not found!")


func _on_audio_finished():
	queue_free()
