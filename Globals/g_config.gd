extends Node

# Guarda la configuración del juego y automáticamente la escribe y lee de disco

##########################
# Señales
##########################

signal config_changed

##########################
# Constantes
##########################

var resolution_presets: Dictionary = {
	0: Vector2(960,540), 
	1: Vector2(1280,720), 
	2: Vector2(1600,900), 
	3: Vector2(1920,1080), 
	4: Vector2(2560,1440), 
	5: Vector2(3840,2160)
}

const MIN_VOL: float = 0.0
const MAX_VOL: float = 1.0

const CONFIG_PATH: String = "user://config.json"

##########################
# Propiedades privadas
##########################

var _update_window_flag: bool = false

##########################
# Propiedades públicas
##########################

var _resolution_preset: int = 3 : set = set_resolution_preset, get = get_resolution_preset
var _fullscreen: bool = true :  set = set_fullscreen, get = is_fullscreen
var _music_vol: float = 0.5 : set = set_music_vol, get = get_music_vol
var _sfx_vol: float = 0.5 : set = set_sfx_vol, get = get_sfx_vol
var _locale: String = "es" : set = set_locale, get =  get_locale

##########################
# _process y _ready
##########################

func _ready():
	load_from_disk()

func _process(_delta):
	if _update_window_flag:
		_update_window()
		_update_window_flag = false

##########################
# Gestión de ficheros
##########################

func save_to_disk() -> void:
	var save: Dictionary = {
		"res_preset": _resolution_preset,
		"fullscreen": _fullscreen,
		"music_vol": _music_vol,
		"sfx_vol": _sfx_vol,
		"locale": _locale,
	}
	
	var file = FileAccess.open(CONFIG_PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(save))
	file.close()

func load_from_disk() -> void:
	var file = FileAccess.open(CONFIG_PATH,FileAccess.READ)
	if !file:
		return
	var contents = JSON.parse_string(file.get_as_text())
	file.close()
	
	var save: Dictionary
	if typeof(contents) == TYPE_DICTIONARY:
		save = contents
	else:
		save = {}
	
	set_fullscreen(bool(save.get("fullscreen", true)))
	set_resolution_preset(int(save.get("res_preset", 3)))
	set_music_vol(float(save.get("music_vol", 1.0)))
	set_sfx_vol(float(save.get("sfx_vol", 1.0)))
	set_locale(String(save.get("locale", TranslationServer.get_locale())))
	
##########################
# Getters/Setters
##########################
	
func get_resolution_preset() -> int:
	return _resolution_preset
	
func set_resolution_preset(pre: int) -> void:
	if not pre in resolution_presets.keys():
		pre = 3
	_resolution_preset = pre
	_update_window_flag = true
	emit_signal("config_changed")
	
func is_fullscreen() -> bool:
	return _fullscreen
	
func set_fullscreen(full: bool) -> void:
	_fullscreen = full
	_update_window_flag = true
	emit_signal("config_changed")
	
func get_music_vol() -> float:
	return _music_vol
	
func set_music_vol(vol: float) -> void:
	_music_vol = clamp(vol, MIN_VOL, MAX_VOL)
	emit_signal("config_changed")
	
func get_sfx_vol() -> float:
	return _sfx_vol
	
func set_sfx_vol(vol: float) -> void:
	_sfx_vol = clamp(vol, MIN_VOL, MAX_VOL)
	emit_signal("config_changed")

func set_locale(loc: String) -> void:
	if not loc in TranslationServer.get_loaded_locales():
		loc = "es"
	_locale = loc
	TranslationServer.set_locale(loc)
	emit_signal("config_changed")
	
func get_locale() -> String:
	return _locale
	
##########################
# Update
##########################
	
func _update_window() -> void:
	
	if _fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
	
	DisplayServer.window_set_size(resolution_presets.get(_resolution_preset, Vector2(1920, 1080)))
