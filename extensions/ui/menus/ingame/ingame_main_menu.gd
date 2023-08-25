extends "res://ui/menus/ingame/ingame_main_menu.gd"

var mod_advstats_button
var mod_advstats_menu
onready var mod_advstats_vbox = $Content / MarginContainer / HBoxContainer / VBoxContainer


func _ready():
	var stats_label = $Content / MarginContainer / HBoxContainer / StatsContainer / MarginContainer/ VBoxContainer2 / StatsLabel
	var button = load("res://mods-unpacked/meinfesl-AdvancedStatistics/ui/stats_button.tscn").instance()
	mod_advstats_button = button
	stats_label.add_child(button)
	
	var _error = button.connect("pressed", self, "mod_advstats_button_pressed")
	
	var standalone_popup = load("res://ui/menus/ingame/item_panel_ui.tscn").instance()
	standalone_popup.hide()
	add_child(standalone_popup)
	
	mod_advstats_menu = load("res://mods-unpacked/meinfesl-AdvancedStatistics/ui/stats_menu.tscn").instance()
	mod_advstats_menu.hide()
	
	mod_advstats_menu.weapons_container = $Content/MarginContainer/HBoxContainer/VBoxContainer/WeaponsContainer/ScrollContainer/MarginContainer/Elements
	mod_advstats_menu.items_container = $Content/MarginContainer/HBoxContainer/VBoxContainer/ItemsContainer/ScrollContainer/MarginContainer/Elements
	mod_advstats_menu.inventory_popup = $ItemPopup
	mod_advstats_menu.standalone_popup = standalone_popup
	
	$Content/MarginContainer/HBoxContainer.add_child_below_node(mod_advstats_vbox, mod_advstats_menu)
	
	_error = get_parent().get_parent().connect("paused", mod_advstats_menu, "build_statistics")
	


func mod_advstats_button_pressed():
	if mod_advstats_vbox.visible:
		var x = mod_advstats_vbox.rect_size.x
		mod_advstats_vbox.hide()
		mod_advstats_menu.rect_min_size.x = x
		mod_advstats_menu.show()
		mod_advstats_menu.build_statistics()
		mod_advstats_button.text = "-"
	else:
		mod_advstats_menu.hide()
		mod_advstats_vbox.show()
		mod_advstats_button.text = "+"
