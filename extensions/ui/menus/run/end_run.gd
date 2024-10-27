extends "res://ui/menus/run/end_run.gd"

var mod_advstats_button
var mod_advstats_menu

onready var mod_advstats_end_screen = $MarginContainer / VBoxContainer /  PanelContainer / HBoxContainer / MarginContainer2 / VBoxContainer

func _ready():
	var stats_label = $"%StatsContainer"/MarginContainer/VBoxContainer2/StatsLabel
	var button = load("res://mods-unpacked/meinfesl-AdvancedStatistics/ui/stats_button.tscn").instance()
	mod_advstats_button = button
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = SIZE_EXPAND
	hbox.rect_min_size.x = stats_label.rect_size.x
	hbox.alignment = BoxContainer.ALIGN_END
	hbox.add_child(button)
	var _error = button.connect("pressed", self, "mod_advstats_button_pressed")
	stats_label.add_child(hbox)
	
	# So it won't shrink/expand on text changes
	button.rect_min_size.x = button.rect_size.x
	
	var standalone_popup = load("res://ui/menus/ingame/item_panel_ui.tscn").instance()
	standalone_popup.hide()
	add_child(standalone_popup)
	
	mod_advstats_menu = load("res://mods-unpacked/meinfesl-AdvancedStatistics/ui/stats_menu.tscn").instance()
	
	var panel_con = $MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/MarginContainer2
	panel_con.add_child(mod_advstats_menu)
	
	mod_advstats_menu.weapons_container = $"%WeaponsContainer"/ScrollSizeContainer/ScrollContainer/Elements
	mod_advstats_menu.items_container = $"%ItemsContainer"/ScrollSizeContainer/ScrollContainer/Elements
	mod_advstats_menu.inventory_popup = $ItemPopup
	mod_advstats_menu.standalone_popup = standalone_popup
	
	mod_advstats_menu.build_statistics()
	mod_advstats_menu.hide()


func mod_advstats_button_pressed():
	if mod_advstats_end_screen.visible:
		var x = mod_advstats_end_screen.rect_size.x
		mod_advstats_end_screen.hide()
		mod_advstats_menu.rect_min_size.x = x
		mod_advstats_menu.show()
		mod_advstats_button.text = "-"
	else:
		mod_advstats_menu.hide()
		mod_advstats_end_screen.show()
		mod_advstats_button.text = "+"

