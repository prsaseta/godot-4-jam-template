extends Node

# Gestiona el pausar el juego
# Permite tener múltiples nodos poniendo el juego en pausa
# El juego está en pausa si tiene al menos una fuente de pausa
# Añade o quita fuentes con los métodos add_source y remove_source

var _sources: Array = []

func _ready():
	get_tree().paused = len(_sources) > 0

func add_source(source: String) -> void:
	if not source in _sources:
		_sources.append(source)
	_update_pause()
	
func remove_source(source: String) -> void:
	_sources.erase(source)
	_update_pause()

func has_source(source: String) -> bool:
	return source in _sources
	
func is_paused() -> bool:
	return _sources.size() > 0

func _update_pause() -> void:
	if is_node_ready() and get_tree() != null:
		get_tree().paused = len(_sources) > 0
