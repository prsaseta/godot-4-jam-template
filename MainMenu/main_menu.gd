extends Node

@onready var buttons_container = %ButtonsContainer
@onready var options_menu = %OptionsMenu
@onready var profile_menu = %ProfileMenu
@onready var options_button = %OptionsButton
@onready var profile_button = %ProfileButton
@onready var start_game_button = %StartGameButton
@onready var credits = %CreditsVBC
@onready var credits_back_button = %CreditsBackButton
@onready var credits_button = %CreditsButton

func _ready():
	# Si no tiene perfil, oculta el botón de jugar hasta que cree uno
	# Si no te gusta esta funcionalidad, puedes eliminar este _ready y crear un perfil
	# automáticamente cuando gustes
	if GProfile.is_profile_loaded():
		start_game_button.grab_focus()
	else:
		profile_button.grab_focus()
		start_game_button.visible = false
		
		GProfile.profile_loaded.connect(func(): start_game_button.visible = true)

func _on_options_button_pressed():
	buttons_container.visible = false
	options_menu.open_menu()
	options_menu.grab_button_focus()

func _on_options_menu_cancel_button_pressed():
	buttons_container.visible = true
	options_menu.close_menu()
	options_button.grab_focus()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_profile_menu_visibility_changed():
	if profile_menu.visible:
		buttons_container.visible = false
	else:
		buttons_container.visible = true
		profile_button.grab_focus()
		
func _on_start_game_button_pressed():
	pass # TODO Pon el cambiar la escena a tu juego aquí

func _on_profile_button_pressed():
	profile_menu.visible = true
	buttons_container.visible = false
	profile_menu.grab_button_focus()

func _on_credits_back_button_pressed():
	credits.visible = false
	buttons_container.visible = true
	credits_button.grab_focus()
	
func _on_credits_button_pressed():
	credits.visible = true
	buttons_container.visible = false
	credits_back_button.grab_focus()
