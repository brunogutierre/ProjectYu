extends Area2D
class_name FoodItem
## Uma comidinha coletavel. Nunca e destruida quando um esquilo rouba - so
## fica "held" (carregada) e depois solta de novo em outro lugar. So e
## removida de verdade quando o player efetivamente coleta.

var is_held: bool = false


func _ready() -> void:
	add_to_group("food")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_held:
		return
	if not body.is_in_group("player"):
		return
	_collect()


func _collect() -> void:
	EventBus.food_item_collected.emit(self)
	queue_free()


## Chamado pelo esquilo ao pegar o item: desliga a deteccao ate ser solto de novo.
func pick_up() -> void:
	is_held = true
	monitoring = false
	monitorable = false


## Chamado pelo esquilo (assustado ou ao chegar no esconderijo) pra soltar o
## item de volta no mundo, pronto pra ser coletado pelo player de novo.
func drop_at(global_pos: Vector2) -> void:
	is_held = false
	global_position = global_pos
	monitoring = true
	monitorable = true
