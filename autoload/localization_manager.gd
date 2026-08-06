extends Node
## Troca de idioma em runtime e persistencia da preferencia do jogador.
##
## Textos setados via tr() em codigo (HUD, DialogueBox etc) nao atualizam
## sozinhos quando o locale muda - por isso emitimos language_changed pra
## quem precisar reaplicar tr() manualmente.

const SUPPORTED_LOCALES: Array[String] = ["en", "fr", "pt_BR"]
const DEFAULT_LOCALE: String = "en"
const SETTINGS_PATH: String = "user://settings.cfg"


func _ready() -> void:
	_load_saved_locale()


func change_language(locale: String) -> void:
	if not (locale in SUPPORTED_LOCALES):
		push_warning("Locale nao suportado: %s" % locale)
		return
	TranslationServer.set_locale(locale)
	_save_locale(locale)
	EventBus.language_changed.emit(locale)


func get_current_locale() -> String:
	return TranslationServer.get_locale()


func _load_saved_locale() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	var locale := DEFAULT_LOCALE
	if err == OK:
		locale = config.get_value("localization", "locale", DEFAULT_LOCALE)
	if not (locale in SUPPORTED_LOCALES):
		locale = DEFAULT_LOCALE
	TranslationServer.set_locale(locale)


func _save_locale(locale: String) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH) # ignora erro se o arquivo ainda nao existir
	config.set_value("localization", "locale", locale)
	config.save(SETTINGS_PATH)
