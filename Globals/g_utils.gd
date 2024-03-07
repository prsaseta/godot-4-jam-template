extends Node

# Utilidades varias que puedes usar en muchos sitios del proyecto

# Un generador de números aleatorio accesible desde todo el proyecto y randomizado
# Útil para poder setear seeds o si necesitas alguna manipulación que el RNG integrado
# de GDScript no ofrece
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

#################
# Inicialización
#################

func _ready():
	rng.randomize()

#################
# Integridad
#################

# ¿Cansado de intentar manipular objetos en cola de borrado y que el juego cuelge?
# ¡Nunca más!
# Si devuelve verdadero, puedes usar el nodo tranquilamente sabiendo que es seguro de usar
func is_node_valid(n) -> bool:
	return n != null and is_instance_valid(n) and not n.is_queued_for_deletion()

#################
# Sonido
#################

# Recibe: Una lista de reproductores de sonido
# Devuelve: Un reproductor de sonido aleatorio de la lista sin usar
# Útil para aleatorizar sonidos de un conjunto (p.e. sonidos de hit o de muerte)
func get_random_unused_asp_from(list: Array) -> Node:
	var candidates: Array = []
	for i in list:
		if not is_node_valid(i): 
			continue
		if not (i is AudioStreamPlayer or i is AudioStreamPlayer2D or i is AudioStreamPlayer3D): 
			continue
		if i.playing:
			continue
		candidates.append(i)
	
	if len(candidates) == 0: return null
	return candidates[rng.randi() % len(candidates)]

func play_random_unused_asp_from(list: Array) -> void:
	var c: Node = get_random_unused_asp_from(list)
	if is_node_valid(c): c.play()
