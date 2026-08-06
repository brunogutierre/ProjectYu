extends Node2D
## Configura os limites de camera do nivel com base no player instanciado na cena.

@export var level_width: float = 1216.0
@export var level_height: float = 360.0


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var cam: Camera2D = player.get_node_or_null("Camera2D")
	if cam == null:
		return
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(level_width)
	cam.limit_bottom = int(level_height)
	cam.make_current()
