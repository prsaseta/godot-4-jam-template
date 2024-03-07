extends MarginContainer

signal profile_loaded

@onready var load_list_pc = %LoadListPC
@onready var load_lines_parent = %LoadLinesParent
@onready var new_profile_pc = %NewProfilePC
@onready var line_edit = %LineEdit
@onready var new_profile_button = %NewProfileButton
@onready var new_profile_accept_button = %NewProfileAcceptButton

func update_load_list() -> void:
	for child in load_lines_parent.get_children():
		child.queue_free()
		
	var lines: Array[ProfileListLine] = GProfile.get_profile_list()
	for i in lines:
		var ui: Control = preload("res://UI/ProfileMenu/profile_load_line.tscn").instantiate()
		load_lines_parent.add_child(ui)
		ui.setup(i)
		ui.button_pressed.connect(_on_profile_line_button_pressed)

func grab_button_focus() -> void:
	for c in load_lines_parent.get_children():
		if GUtils.is_node_valid(c):
			c.grab_button_focus()
			return
	new_profile_button.call_deferred("grab_focus")

func _on_profile_line_button_pressed(line: ProfileListLine) -> void:
	GProfile.load_profile(line.filename)
	profile_loaded.emit()
	visible = false

func _on_visibility_changed():
	if visible:
		update_load_list()

func _on_back_button_pressed():
	visible = false


func _on_new_profile_button_pressed():
	load_list_pc.visible = false
	new_profile_pc.visible = true
	new_profile_accept_button.grab_focus()
	
	if OS.has_environment("USERNAME"):
		line_edit.text = OS.get_environment("USERNAME")
	else:
		line_edit.text = tr("PROFILE_LIST_DEFAULT_NAME")


func _on_new_profile_accept_button_pressed():
	if len(line_edit.text) == 0:
		return
	GProfile.create_profile(line_edit.text)
	profile_loaded.emit()
	load_list_pc.visible = true
	new_profile_pc.visible = false
	visible = false


func _on_new_profile_back_button_pressed():
	load_list_pc.visible = true
	new_profile_pc.visible = false
	new_profile_button.grab_focus()
