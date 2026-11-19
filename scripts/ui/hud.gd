extends CanvasLayer
## HUD simples com contador de comidinhas. Texto e setado via tr() em codigo,
## entao precisa escutar language_changed pra atualizar sozinho.

@onready var food_label: Label = $Control/Panel/FoodCount

var _collected: int = 0
var _total: int = 0


func _ready() -> void:
	EventBus.food_progress_changed.connect(_on_food_progress_changed)
	EventBus.language_changed.connect(_on_language_changed)
	_update_label()


func _on_food_progress_changed(collected: int, total: int) -> void:
	_collected = collected
	_total = total
	_update_label()


func _on_language_changed(_locale: String) -> void:
	_update_label()


func _update_label() -> void:
	var text := tr("HUD_FOOD_COUNT")
	text = text.replace("{collected}", str(_collected)).replace("{total}", str(_total))
	food_label.text = text
