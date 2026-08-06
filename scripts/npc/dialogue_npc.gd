extends Node2D
class_name DialogueNpc
## Base reutilizavel pra qualquer cachorro/NPC que conversa com a
## protagonista. As cenas especificas (Flock, Stony, Told) so trocam o
## dialogue_data e o sprite via Inspector - a logica e sempre esta mesma.

@export var dialogue_data: DialogueData
@export var prompt_indicator: CanvasItem

@onready var interaction_area: Area2D = $InteractionArea

var _player_in_range: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	_set_prompt_visible(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed("interact"):
		_start_dialogue()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	_set_prompt_visible(true)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	_set_prompt_visible(false)


func _start_dialogue() -> void:
	if dialogue_data == null or dialogue_data.lines.is_empty():
		return
	EventBus.dialogue_requested.emit(dialogue_data)


func _set_prompt_visible(value: bool) -> void:
	if prompt_indicator:
		prompt_indicator.visible = value
