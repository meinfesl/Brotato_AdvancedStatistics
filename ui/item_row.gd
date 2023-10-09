extends MarginContainer


func _ready():
	var _error = $MarginContainer/HBoxContainer.connect("focus_entered", self, "on_focus_entered")
	_error = $MarginContainer/HBoxContainer.connect("focus_exited",  self, "on_focus_exited")
	_error = $MarginContainer/HBoxContainer.connect("mouse_entered", self, "on_mouse_entered")
	_error = $MarginContainer/HBoxContainer.connect("mouse_exited",  self, "on_mouse_exited")


func on_focus_entered():
	$ColorRect.show()


func on_focus_exited():
	$ColorRect.hide()


func on_mouse_entered():
	$MarginContainer/HBoxContainer.grab_focus()


func on_mouse_exited():
	$MarginContainer/HBoxContainer.release_focus()
