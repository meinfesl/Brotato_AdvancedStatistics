extends "res://ui/menus/title_screen/title_screen.gd"


onready var mod_advstat_menu_player_info = load("res://mods-unpacked/meinfesl-AdvancedStatistics/ui/player_info.tscn").instance()


func _ready():
	var button_player_info = MyMenuButton.new()
	button_player_info.text = "Player Info"
	button_player_info.connect("pressed", self, "mod_advstats_menu_button_pressed")
	
	$MarginContainer/Menus/MainMenu/HBoxContainer/ButtonsLeft.add_child_below_node(
		$MarginContainer/Menus/MainMenu/HBoxContainer/ButtonsLeft/ProgressButton, button_player_info)
	
	_main_menu.set_neighbours(button_player_info, $MarginContainer/Menus/MainMenu/HBoxContainer/ButtonsRight/CommunityButton)
	
	var button_back = mod_advstat_menu_player_info.get_node("MarginContainer/VBoxContainer/ButtonBack")
	
	button_back.connect("pressed", self, "mod_advstats_back_button_pressed")
	mod_advstat_menu_player_info.hide()
	_menus.add_child(mod_advstat_menu_player_info)
	
	_menus.connect("menu_page_switched", self, "mod_advstats_save_if_needed")


func mod_advstats_menu_button_pressed():
	_menus.switch(_main_menu, mod_advstat_menu_player_info)


func mod_advstats_back_button_pressed():
	_menus.switch(mod_advstat_menu_player_info, _main_menu)


func mod_advstats_save_if_needed(_from, _to):
	if mod_advstat_menu_player_info.changed:
		get_tree().get_root().get_node("ModLoader/meinfesl-AdvancedStatistics/StatsTracker").save()
		mod_advstat_menu_player_info.changed = false
