extends "res://ui/menus/ingame/pause_menu.gd"

func _ready():
	var _error = connect("paused", RunData.mod_advstats, "on_game_paused")
	_error = connect("unpaused", RunData.mod_advstats, "on_game_unpaused")
