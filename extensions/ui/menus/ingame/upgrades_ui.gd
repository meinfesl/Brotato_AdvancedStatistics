extends "res://ui/menus/ingame/upgrades_ui.gd"


func _on_RerollButton_pressed()->void:
	RunData.mod_advstats.materials_source = "MATERIALS_SPENT_REROLL_LEVEL_UP"
	._on_RerollButton_pressed()
	RunData.mod_advstats.materials_source = ""
