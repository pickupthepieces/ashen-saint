class_name DialogueBox
extends CanvasLayer

signal dialogue_finished

var _lines: Array = []
var _index := 0

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var line_label: Label = $Panel/LineLabel

func _ready() -> void:
	panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("basic_attack"):
		advance()
		get_viewport().set_input_as_handled()

func show_lines(lines: Array) -> void:
	_lines = lines
	_index = 0
	if _lines.is_empty():
		panel.visible = false
		dialogue_finished.emit()
		return
	panel.visible = true
	_show_current_line()

func advance() -> void:
	if not panel.visible:
		return
	_index += 1
	if _index >= _lines.size():
		panel.visible = false
		dialogue_finished.emit()
		return
	_show_current_line()

func is_showing() -> bool:
	return panel.visible

func _show_current_line() -> void:
	var line = _lines[_index]
	speaker_label.text = String(line.get("speaker", ""))
	line_label.text = String(line.get("text", ""))
