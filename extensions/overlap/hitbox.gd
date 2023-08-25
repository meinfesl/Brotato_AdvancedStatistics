extends "res://overlap/hitbox.gd"


func added_gold_on_crit(gold_added:int)->void :
	.added_gold_on_crit(gold_added)
	RunData.mod_advstats.on_materials_gained_from_weapon_crit()


func hit_something(thing_hit:Node, damage_dealt:int)->void:
	if from:
		RunData.mod_advstats.exploding_weapon = from
	.hit_something(thing_hit, damage_dealt)
	RunData.mod_advstats.exploding_weapon = null
	RunData.mod_advstats.waiting_for_damage_source = false
