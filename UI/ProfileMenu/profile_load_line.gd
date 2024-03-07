extends MarginContainer

signal button_pressed(profile_list_line: ProfileListLine)

@onready var label = %Label
@onready var in_use_label = %InUseLabel
@onready var button = %Button

var line: ProfileListLine = null

func setup(profile: ProfileListLine) -> void:
	line = profile
	in_use_label.visible = line.in_use
	label.text = line.profile_name

func _on_button_pressed():
	button_pressed.emit(line)

func grab_button_focus() -> void:
	button.call_deferred("grab_focus")
