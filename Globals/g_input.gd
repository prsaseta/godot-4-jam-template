extends Node

# Detecta de forma rápida si estás usando ratón o teclado

enum InputState {
	KEYBOARD,
	GAMEPAD,
}

signal changed_to_gamepad
signal changed_to_keyboard

var _last_input_state: InputState = InputState.KEYBOARD

func _input(event: InputEvent):
	# NOTA:
	# No tiene en cuenta deadzone así que si tienes el mando enchufado pero sin usar
	# puede cambiar rápidamente entre una cosa u otra
	# Elimina el segundo miembro del OR para que solo tenga en cuenta los botones
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var emit: bool = _last_input_state == InputState.KEYBOARD
		_last_input_state = InputState.GAMEPAD
		if emit: changed_to_gamepad.emit()
	if event is InputEventKey or event is InputEventMouseButton:
		var emit: bool = _last_input_state == InputState.GAMEPAD
		_last_input_state = InputState.KEYBOARD
		if emit: changed_to_keyboard.emit()
	
func is_on_keyboard() -> bool:
	return _last_input_state == InputState.KEYBOARD
	
func is_on_gamepad() -> bool:
	return _last_input_state == InputState.GAMEPAD
