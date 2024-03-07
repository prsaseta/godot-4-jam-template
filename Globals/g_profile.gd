extends Node

# Permite guardar y cargar perfiles de jugador con datos como logros, etc.
# Usa los comandos de la sección getters/setters para cargar y guardar variables
# Dumpea a disco automáticamente cuando cambias una variable
# Asegúrate de crear un perfil cuando el jugador inicie por primera vez el juego
# con create_profile (p.e. con pantalla de crear perfil o automáticamente 
# si is_profile_loaded() es falso)

# Los perfiles se guardan en:
# C:\Users\{usuario}\AppData\Roaming\Godot\app_userdata\{nombre de tu juego}\Profiles

##################
# Señales
##################

signal profile_loaded

##################
# Constantes
##################

const PROFILE_FOLDER_PATH: String = "user://Profiles/"
const PROFILE_INFO_PATH: String = "user://Profiles/profiles.json"

const PROFILE_INFO_PROPERTY_LAST_PROFILE_FILENAME: String = "last_profile_filename"
const PROFILE_INFO_PROPERTY_PROFILE_COUNT: String = "profile_count"

const PROFILE_PROPERTY_NAME: String = "name"
const PROFILE_PROPERTY_FLOAT_VARS: String = "float_vars"
const PROFILE_PROPERTY_IS_A_PROFILE: String = "is_a_profile"

const PROFILE_BASE_FILENAME: String = "profile"

##################
# Estado global
##################

# El número de perfiles creados hasta el momento
# Para elegir el nombre de fichero cuando creas un nuevo perfil
var _profile_count: int = 0

# Si tiene que dumpear a disco la informacion de perfiles el siguiente frame
var _profile_info_dirty: bool = false

# El perfil que carga por defecto
var _default_profile_filename: String = ""

##################
# Estado de perfil
##################

var _is_profile_loaded: bool = false

# Variables del perfil
# No acceder directamente, usar métodos de Getters/Setters
var _profile_float_vars: Dictionary = {}

# Nombre del archivo del perfil
var _profile_filename: String = ""

# Nombre que aparecerá en pantalla del perfil
var _profile_name: String = ""

# Si hay que dumpear a disco el perfil el siguiente frame
var _profile_dirty: bool = false

#################
# Inicialización
#################

func _ready():
	if not DirAccess.dir_exists_absolute(PROFILE_FOLDER_PATH):
		DirAccess.make_dir_absolute(PROFILE_FOLDER_PATH)
		
	# Intenta cargar los datos globales de perfil
	if FileAccess.file_exists(PROFILE_INFO_PATH):
		var profile_info_file: FileAccess = FileAccess.open(PROFILE_INFO_PATH, FileAccess.READ)
		var profile_info_content = JSON.parse_string(profile_info_file.get_as_text())
		if profile_info_content != null and profile_info_content is Dictionary:
			# Carga datos
			_profile_count = int(profile_info_content.get(PROFILE_INFO_PROPERTY_PROFILE_COUNT, 0))
			# Carga el último perfil usado
			var last_profile_filename: String = profile_info_content.get(PROFILE_INFO_PROPERTY_LAST_PROFILE_FILENAME, "")
			if last_profile_filename != "":
				_default_profile_filename = last_profile_filename
				load_profile(last_profile_filename)

#################
# Proceso
#################

func _process(_delta):
	if _profile_dirty:
		save_profile()
	if _profile_info_dirty:
		save_profile_info()

###################
# Getters / Setters
###################

func get_float_var(v: String) -> float:
	return _profile_float_vars.get(v, 0.0)
	
func set_float_var(v: String, val: float) -> void:
	_profile_float_vars[v] = val
	_profile_dirty = true
	
func sum_float_var(v: String, mod: float) -> void:
	_profile_float_vars[v] = _profile_float_vars.get(v, 0.0) + mod
	_profile_dirty = true

func is_profile_loaded() -> bool:
	return _is_profile_loaded

#################
# Lectura
#################

# Devuelve una lista de todos los perfiles que hay en disco
# Para p.e. mostrar pantalla de elegir perfil
# No modifica estado, usa load_profile con el filename que desees para cargar perfil
func get_profile_list() -> Array[ProfileListLine]:
	var dir: DirAccess = DirAccess.open(PROFILE_FOLDER_PATH)
	dir.list_dir_begin()
	
	var results: Array[ProfileListLine] = []
	var file_name: String = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			pass
		else:
			var f: FileAccess = FileAccess.open(PROFILE_FOLDER_PATH + file_name, FileAccess.READ)
			var profile_content = JSON.parse_string(f.get_as_text())
	
			if profile_content == null or not profile_content is Dictionary:
				printerr("Profile cannot be loaded or has invalid formatting!\nPath: %s\nError: %s" % [PROFILE_FOLDER_PATH + file_name, f.get_error()])
				file_name = dir.get_next()
				continue # TODO Abstraer a método privado
				
			if not profile_content.get(PROFILE_PROPERTY_IS_A_PROFILE, false):
				file_name = dir.get_next()
				continue
				
			var line: ProfileListLine = ProfileListLine.new()
			line.filename = file_name
			line.profile_name = profile_content.get(PROFILE_PROPERTY_NAME, "")
			line.in_use = file_name == _profile_filename
			results.append(line)
			
			f.close()
			
		file_name = dir.get_next()
		
	return results

# Recibe: Nombre de fichero de perfil dentro de la carpeta de Profiles (sin ruta completa)
# Carga el perfil especificado si existe
func load_profile(filename: String) -> void:
	_is_profile_loaded = false
	_profile_filename = ""
	_profile_name = ""
	_profile_float_vars = {}
	
	var path: String = PROFILE_FOLDER_PATH + filename
	if not FileAccess.file_exists(path): 
		printerr("Profile at path does not exist! Path: %s" % path)
		return
		
	var profile_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var profile_content = JSON.parse_string(profile_file.get_as_text())
	
	if profile_content == null or not profile_content is Dictionary:
		printerr("Profile cannot be loaded or has invalid formatting!\nPath: %s\nError: %s" % [path, profile_file.get_error()])
		return
	
	if not profile_content.get(PROFILE_PROPERTY_IS_A_PROFILE, false):
		printerr("Profile file is not a profile! %s" % profile_content)
		return
	
	# Guarda los datos cargados correctamente en variables
	_profile_filename = filename
	_profile_name = profile_content.get(PROFILE_PROPERTY_NAME, "")
	_profile_float_vars = profile_content.get(PROFILE_PROPERTY_FLOAT_VARS, {})
	_is_profile_loaded = true
	_profile_dirty = false
	
	# Si se ha cargado un perfil nuevo, pone como dirty el profile info para 
	# guardar el nuevo perfil por defecto
	_profile_info_dirty = _profile_info_dirty or filename != _default_profile_filename
	
	profile_loaded.emit()

#################
# Escritura
#################

func save_profile_info() -> void:
	var profile_info_file: FileAccess = FileAccess.open(PROFILE_INFO_PATH, FileAccess.WRITE)
	var json: String = JSON.stringify({
		PROFILE_INFO_PROPERTY_LAST_PROFILE_FILENAME: _default_profile_filename,
		PROFILE_INFO_PROPERTY_PROFILE_COUNT: _profile_count,
	})
	profile_info_file.store_string(json)
	profile_info_file.close()
	_profile_info_dirty = false
	
func save_profile() -> void:
	var profile_file: FileAccess = FileAccess.open(PROFILE_FOLDER_PATH + _profile_filename, FileAccess.WRITE)
	var json: String = JSON.stringify({
		PROFILE_PROPERTY_FLOAT_VARS: _profile_float_vars,
		PROFILE_PROPERTY_NAME: _profile_name,
		PROFILE_PROPERTY_IS_A_PROFILE: true,
	})
	profile_file.store_string(json)
	profile_file.close()
	_profile_dirty = false
	
	if _default_profile_filename != _profile_filename:
		_default_profile_filename = _profile_filename
		_profile_info_dirty = true

#################
# Misc
#################

func create_profile(profile_name: String) -> void:
	_profile_count += 1
	
	_profile_filename = PROFILE_BASE_FILENAME + str(_profile_count) + ".json"
	_profile_name = profile_name
	_profile_float_vars = {}
	
	_is_profile_loaded = true
	
	_default_profile_filename = _profile_filename
	
	_profile_dirty = true
	_profile_info_dirty = true
	
	profile_loaded.emit()
