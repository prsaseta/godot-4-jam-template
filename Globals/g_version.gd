extends Node

# Pequeña utilidad para tener acceso fácil a la versión del juego dentro del mismo

var version_major: int = 0
var version_minor: int = 0
var version_hotfix: int = 0

func get_version_string() -> String:
	return "%s.%s.%s" % [version_major, version_minor, version_hotfix]
