extends Resource
class_name DialogueData
## Uma conversa completa: um id (pra debug/flags de historia futuras) e a
## lista ordenada de falas que a DialogueBox vai mostrar uma por uma.

@export var id: StringName = &""
@export var lines: Array[DialogueLine] = []
