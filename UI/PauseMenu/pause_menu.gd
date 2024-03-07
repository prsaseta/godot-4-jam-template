extends MarginContainer

# Menú de pausa
# Ponlo invisible en cualquier escena donde lo necesites y funcionará automáticamente
# presionando Escape o Start (se puede cambiar en las opciones de input del proyecto)

class_name PauseMenu

@onready var buttons_pc = %ButtonsPC
@onready var options_menu = %OptionsMenu
@onready var continue_button = %ContinueButton
@onready var options_button = %OptionsButton
@onready var quit_button = %QuitButton

# Si tenía foco en algún otro menú cuando abres la pausa, intenta recuperarlo automáticamente
var _last_focus: Control = null

######################
# Inicialización
######################

func _ready():
	options_menu.cancel_button.pressed.connect(_on_options_closed)

######################
# Entrada
######################

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause"):
		visible = not visible
		
		options_menu.close_menu()
		buttons_pc.visible = true
		
		get_viewport().set_input_as_handled()

######################
# API
######################

func grab_button_focus() -> void:
	continue_button.grab_focus()

######################
# Callbacks
######################

func _on_visibility_changed():
	if visible:
		_last_focus = get_viewport().gui_get_focus_owner()
		GPause.add_source(GConstants.PAUSE_PAUSE_MENU)
		continue_button.grab_focus()
	else:
		if GUtils.is_node_valid(_last_focus):
			_last_focus.call_deferred("grab_focus")
		GPause.remove_source(GConstants.PAUSE_PAUSE_MENU)


func _on_continue_button_pressed():
	visible = false

func _on_options_button_pressed():
	buttons_pc.visible = false
	options_menu.open_menu()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_tree_exited():
	GPause.remove_source(GConstants.PAUSE_PAUSE_MENU)

func _on_options_closed() -> void:
	buttons_pc.visible = true
	options_menu.visible = false
	options_button.grab_focus()


func _on_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")
