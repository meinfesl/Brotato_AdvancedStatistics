extends "res://singletons/weapon_service.gd"


func explode(effect:Effect, pos:Vector2, damage:int, accuracy:float, crit_chance:float, crit_dmg:float, burning_data:BurningData, is_healing:bool = false, ignored_objects:Array = [], damage_tracking_key:String = "")->Node:
	var instance = .explode(effect, pos, damage, accuracy, crit_chance, crit_dmg, burning_data, is_healing, ignored_objects, damage_tracking_key)
	if RunData.mod_advstats.exploding_weapon:
		instance.connect("hit_something", RunData.mod_advstats.exploding_weapon, "on_weapon_hit_something")
	return instance

