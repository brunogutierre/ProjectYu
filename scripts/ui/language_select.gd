extends CanvasLayer
## Tela de selecao de idioma mostrada no boot. Continua respondendo a clique
## mesmo com a arvore pausada (PROCESS_MODE_ALWAYS), porque e ela quem
## despausa o jogo depois que o idioma e escolhido.

@onready var title_label: Label = $Control/Panel/VBoxContainer/Title
@onready var btn_en: Button = $Control/Panel/VBoxContainer/ButtonEnglish
@onready var btn_fr: Button = $Control/Panel/VBoxContainer/ButtonFrench
@onready var btn_pt: Button = $Control/Panel/VBoxContainer/ButtonPortuguese


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_en.pressed.connect(_on_pressed.bind("en"))
	btn_fr.pressed.connect(_on_pressed.bind("fr"))
	btn_pt.pressed.connect(_on_pressed.bind("pt_BR"))
	EventBus.language_changed.connect(_on_language_changed)
	_update_texts()


func _on_pressed(locale: String) -> void:
	LocalizationManager.change_language(locale)
	get_tree().paused = false
	queue_free()


func _on_language_changed(_locale: String) -> void:
	_update_texts()


func _update_texts() -> void:
	title_label.text = tr("UI_LANGUAGE_TITLE")
	btn_en.text = tr("UI_LANG_ENGLISH")
	btn_fr.text = tr("UI_LANG_FRENCH")
	btn_pt.text = tr("UI_LANG_PORTUGUESE")
