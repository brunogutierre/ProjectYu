extends Node
## Bootstrap da cena principal: registra o total de comida do nivel carregado,
## e mostra a tela de fim de nivel quando a caminha e alcancada.

@onready var level_complete_panel: CanvasLayer = $LevelCompletePanel
@onready var complete_title: Label = $LevelCompletePanel/Control/Panel/VBoxContainer/Title
@onready var complete_body: Label = $LevelCompletePanel/Control/Panel/VBoxContainer/Body


func _ready() -> void:
	level_complete_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	level_complete_panel.visible = false

	EventBus.level_completed.connect(_on_level_completed)
	EventBus.language_changed.connect(_on_language_changed)

	GameManager.reset_level_progress()
	GameManager.register_food_total(get_tree().get_nodes_in_group("food").size())

	get_tree().paused = true


func _on_level_completed() -> void:
	_update_complete_texts()
	level_complete_panel.visible = true
	get_tree().paused = true


func _on_language_changed(_locale: String) -> void:
	if level_complete_panel.visible:
		_update_complete_texts()


func _update_complete_texts() -> void:
	complete_title.text = tr("UI_LEVEL_COMPLETE_TITLE")
	complete_body.text = tr("UI_LEVEL_COMPLETE_BODY")
