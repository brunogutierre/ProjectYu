extends Node
## Estado de sessao do jogo: progresso de coleta e flags de historia.
##
## Nao guarda referencia direta a nos da cena - so numeros e flags. Quem
## precisa saber de mudancas escuta os sinais do EventBus.

var food_total: int = 0
var food_collected: int = 0
var story_flags: Dictionary = {}


func _ready() -> void:
	EventBus.food_item_collected.connect(_on_food_item_collected)


## Chamado pelo nivel ao carregar, com quantos itens de comida existem no total.
func register_food_total(count: int) -> void:
	food_total = count
	food_collected = 0
	EventBus.food_progress_changed.emit(food_collected, food_total)


func all_food_collected() -> bool:
	return food_total > 0 and food_collected >= food_total


func set_story_flag(flag_name: StringName, value: bool = true) -> void:
	story_flags[flag_name] = value


func get_story_flag(flag_name: StringName) -> bool:
	return story_flags.get(flag_name, false)


func reset_level_progress() -> void:
	food_total = 0
	food_collected = 0


func _on_food_item_collected(_item: Node2D) -> void:
	food_collected += 1
	EventBus.food_progress_changed.emit(food_collected, food_total)
