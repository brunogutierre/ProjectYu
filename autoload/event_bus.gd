extends Node
## Barramento global de sinais.
##
## Desacopla player, esquilos, HUD e sistema de dialogo entre si: quem gera um
## evento nao precisa conhecer quem vai reagir a ele.

## Emitido quando a cachorrinha late. Esquilos escutam e decidem se estao perto
## o suficiente pra ficar assustados.
signal player_barked(global_pos: Vector2, radius: float)

## Emitido por um FoodItem quando o player efetivamente coleta a comida.
signal food_item_collected(item: Node2D)

## Emitido pelo GameManager sempre que o placar de comida muda (coletado/total).
signal food_progress_changed(collected: int, total: int)

## Emitido por um DialogueNpc quando o player interage e pede pra abrir um dialogo.
signal dialogue_requested(data: DialogueData)

## Emitido pela DialogueBox quando termina de mostrar todas as falas.
signal dialogue_finished()

## Emitido pelo LocalizationManager sempre que o idioma muda em runtime.
## Telas com texto dinamico (nao-Control automatico) devem escutar isso e
## reaplicar tr() manualmente.
signal language_changed(locale: String)

## Emitido quando a cachorrinha chega na caminha com o objetivo do nivel cumprido.
signal level_completed()
