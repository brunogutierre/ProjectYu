extends Node2D
## Marca um esconderijo pra onde esquilos fogem com comida roubada. Sem
## logica propria - so precisa existir no grupo "hideouts" pra ser encontrado
## pelo squirrel_controller.

func _ready() -> void:
	add_to_group("hideouts")
