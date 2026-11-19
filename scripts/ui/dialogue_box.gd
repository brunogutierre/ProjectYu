extends CanvasLayer
## Caixa de dialogo com retrato grande. Pausa o jogo enquanto esta aberta -
## por isso o proprio CanvasLayer roda em PROCESS_MODE_ALWAYS, senao o input
## de avancar fala nao funcionaria com a arvore pausada.

@onready var panel: PanelContainer = $Control/Panel
@onready var portrait_rect: TextureRect = $Control/Panel/MarginContainer/HBoxContainer/Portrait
@onready var speaker_label: Label = $Control/Panel/MarginContainer/HBoxContainer/VBoxContainer/SpeakerName
@onready var body_label: RichTextLabel = $Control/Panel/MarginContainer/HBoxContainer/VBoxContainer/BodyText

var _current_data: DialogueData
var _line_index: int = 0
var _advance_requested: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.language_changed.connect(_on_language_changed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		_advance_requested = true
		get_viewport().set_input_as_handled()


func _on_dialogue_requested(data: DialogueData) -> void:
	if data == null or data.lines.is_empty():
		return
	if visible:
		return
	play(data)


func play(data: DialogueData) -> void:
	_current_data = data
	_line_index = 0
	visible = true
	get_tree().paused = true
	_show_current_line()
	while _line_index < _current_data.lines.size():
		_advance_requested = false
		await _wait_for_advance()
		_line_index += 1
		if _line_index < _current_data.lines.size():
			_show_current_line()
	_close()


func _wait_for_advance() -> void:
	while not _advance_requested:
		await get_tree().process_frame


func _show_current_line() -> void:
	var line: DialogueLine = _current_data.lines[_line_index]
	speaker_label.text = tr(line.speaker_key)
	body_label.text = tr(line.text_key)
	portrait_rect.texture = line.portrait


func _close() -> void:
	visible = false
	get_tree().paused = false
	_current_data = null
	EventBus.dialogue_finished.emit()


func _on_language_changed(_locale: String) -> void:
	# Texto dinamico setado via tr() em codigo nao atualiza sozinho - so
	# reaplica se ainda tiver uma fala aberta na tela.
	if visible and _current_data:
		_show_current_line()
