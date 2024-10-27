extends "res://singletons/weapon_service.gd"


func explode(effect: Effect, args: WeaponServiceExplodeArgs)->Node:
	var instance = .explode(effect, args)
	if RunData.mod_advstats.exploding_weapon:
		instance.connect("hit_something", RunData.mod_advstats.exploding_weapon, "on_weapon_hit_something")
	return instance

