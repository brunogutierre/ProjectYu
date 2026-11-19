extends Area2D
## A caminha de cachorro: meta do nivel. So dispara "nivel concluido" quando
## o player encosta e ja recolheu toda a comida.

var _completed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _completed:
		return
	if not body.is_in_group("player"):
		return
	if not GameManager.all_food_collected():
		return
	_completed = true
	EventBus.level_completed.emit()
