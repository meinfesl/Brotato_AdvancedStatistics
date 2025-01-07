extends "res://singletons/weapon_service.gd"


func explode(effect: Effect, args: WeaponServiceExplodeArgs)->Node:
	var instance = .explode(effect, args)
	if RunData.mod_advstats.exploding_weapon:
		instance.connect("hit_something", RunData.mod_advstats.exploding_weapon, "mod_advstat_count_damage", [instance._hitbox])
	return instance

