extends "res://main.gd"

func _ready():
	RunData.mod_advstats.on_wave_started()

func on_consumable_picked_up(consumable:Node)->void:
	RunData.mod_advstats.heal_source = "HP_HEALED_FRUIT"
	if consumable.consumable_data.my_id == "consumable_item_box" || consumable.consumable_data.my_id == "consumable_legendary_item_box":
		RunData.mod_advstats.on_item_box_picked_up()
	.on_consumable_picked_up(consumable)
	RunData.mod_advstats.heal_source = ""


func on_levelled_up()->void:
	# Prevent +1 hp on levelup from tracking
	RunData.mod_advstats.levelup = true
	.on_levelled_up()
	RunData.mod_advstats.levelup = false


func on_gold_picked_up(gold:Node)->void:
	RunData.mod_advstats.materials_source = "MATERIALS_GAINED_PICKED_UP"
	RunData.mod_advstats.damage_source = "item_baby_elephant"
	.on_gold_picked_up(gold)
	RunData.mod_advstats.materials_source = ""
	RunData.mod_advstats.damage_source = ""


func manage_harvesting()->void:
	RunData.mod_advstats.materials_source = "MATERIALS_GAINED_HARVESTING"
	.manage_harvesting()
	RunData.mod_advstats.materials_source = ""


func on_item_box_take_button_pressed(item_data:ItemParentData)->void:
	.on_item_box_take_button_pressed(item_data)
	RunData.mod_advstats.on_loot_box_taken(item_data)


func on_item_box_discard_button_pressed(item_data:ItemParentData)->void:
	RunData.mod_advstats.materials_source = "MATERIALS_GAINED_RECYCLING"
	.on_item_box_discard_button_pressed(item_data)
	RunData.mod_advstats.materials_source = ""
	RunData.mod_advstats.on_loot_box_discarded()


func clean_up_room(is_last_wave:bool = false, is_run_lost:bool = false, is_run_won:bool = false)->void:
	.clean_up_room(is_last_wave, is_run_lost, is_run_won)
	
	RunData.mod_advstats.on_room_clean_up(is_run_lost, is_run_won)
	

func _on_EndWaveTimer_timeout():
	RunData.mod_advstats.update_loot_box_count()
	._on_EndWaveTimer_timeout()
