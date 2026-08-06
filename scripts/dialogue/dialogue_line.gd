extends Resource
class_name DialogueLine
## Uma fala dentro de um dialogo. Guarda CHAVES de traducao, nunca o texto
## final - quem exibe chama tr() na hora de renderizar, assim o mesmo recurso
## funciona nos 3 idiomas sem duplicar dados.

enum PortraitSide { LEFT, RIGHT }

@export var speaker_key: String = ""
@export var text_key: String = ""
@export var portrait: Texture2D
@export var portrait_side: PortraitSide = PortraitSide.LEFT
