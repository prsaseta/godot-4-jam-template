extends PanelContainer

@onready var locale_option: OptionButton = $MC/VBC/SettingsSC/SettingsVBC/LocaleHBC/LocaleOB
@onready var resolution_option: OptionButton = $MC/VBC/SettingsSC/SettingsVBC/ResolutionHBC/ResolutionOB
@onready var fullscreen_cb: CheckBox = %FullscreenCB
@onready var music_slider: HSlider = $MC/VBC/SettingsSC/SettingsVBC/MusicHBC/MusicHS
@onready var music_label: Label = $MC/VBC/SettingsSC/SettingsVBC/MusicHBC/MusicLabel
@onready var sfx_slider: HSlider = $MC/VBC/SettingsSC/SettingsVBC/SFXHBC/SFXHS
@onready var sfx_label: Label = $MC/VBC/SettingsSC/SettingsVBC/SFXHBC/SFXLabel

@onready var cancel_button: Button = $MC/VBC/CancelButton

signal cancel_button_pressed

var _locale_ids: Dictionary = {}

func _ready():
	_update_menu()
	
func open_menu() -> void:
	visible = true
	_update_menu()
	
func close_menu() -> void:
	visible = false

func grab_button_focus() -> void:
	fullscreen_cb.call_deferred("grab_focus")

func _update_menu() -> void:
	fullscreen_cb.button_pressed = GConfig.is_fullscreen()
	
	music_slider.min_value = GConfig.MIN_VOL
	music_slider.max_value = GConfig.MAX_VOL
	music_slider.step = 0.01
	music_slider.value = GConfig.get_music_vol()
	
	sfx_slider.min_value = GConfig.MIN_VOL
	sfx_slider.max_value = GConfig.MAX_VOL
	sfx_slider.step = 0.01
	sfx_slider.value = GConfig.get_sfx_vol()
	
	locale_option.clear()
	_locale_ids = {}
	var added_locales: Array = []
	var _selected_locale: int = 0
	for i in range(len(TranslationServer.get_loaded_locales())):
		var locale: String = TranslationServer.get_loaded_locales()[i]
		if locale in added_locales: continue
		added_locales.append(locale)
		locale_option.add_item(TranslationServer.get_locale_name(locale), i)
		_locale_ids[i] = locale
		if locale == GConfig.get_locale():
			_selected_locale = i
	locale_option.select(_selected_locale)
		
	resolution_option.clear()
	var _selected_res: int = 3
	for i in range(len(GConfig.resolution_presets.keys())):
		var preset: Vector2 = GConfig.resolution_presets[i]
		resolution_option.add_item("%sx%s" % [preset.x,preset.y], i)
		if GConfig.get_resolution_preset() == i:
			_selected_res = i
	resolution_option.select(_selected_res)


func _apply_options() -> void:
	GConfig.set_locale(_locale_ids[locale_option.get_selected_id()])
	GConfig.set_resolution_preset(resolution_option.get_selected_id())
	GConfig.set_fullscreen(fullscreen_cb.button_pressed)
	GConfig.set_sfx_vol(sfx_slider.value)
	GConfig.set_music_vol(music_slider.value)
	
	GConfig.save_to_disk()

func _on_apply_button_pressed():
	_apply_options()


func _on_music_hs_value_changed(value):
	music_label.text = str(value * 100) + "%"


func _on_sfxhs_value_changed(value):
	sfx_label.text = str(value * 100) + "%"


func _on_OptionsMenu_visibility_changed():
	if visible:
		if is_node_ready():
			fullscreen_cb.grab_focus()


func _on_cancel_button_pressed():
	cancel_button_pressed.emit()
