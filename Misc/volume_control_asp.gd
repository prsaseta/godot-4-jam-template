extends AudioStreamPlayer

# Adjunta este script a un control de volumen para que automáticamente ajuste
# su volumen en base a la configuración de GConfig

enum ASPType {
	SFX,
	MUSIC
}

@export var base_vol: float = 1.0 : set = set_base_vol , get = get_base_vol

@export var asp_type: ASPType = ASPType.SFX : set = set_asp_type , get = get_asp_type

func _ready():
	GConfig.connect("config_changed", _on_config_change)
	_update_vol()

func _update_vol() -> void:
	var mul: float
	if asp_type == ASPType.SFX:
		mul = GConfig.get_sfx_vol()
	else:
		mul = GConfig.get_music_vol()
	
	volume_db = linear_to_db(base_vol * mul)
	
func _on_config_change() -> void:
	_update_vol()

func set_base_vol(vol: float) -> void:
	base_vol = vol
	_update_vol()
	
func get_base_vol() -> float:
	return base_vol
	
func set_asp_type(t: int) -> void:
	asp_type = t
	_update_vol()

func get_asp_type() -> int:
	return asp_type
