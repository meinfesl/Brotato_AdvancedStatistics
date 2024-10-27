extends "res://entities/units/neutral/neutral.gd"


func take_damage(value: int, args: TakeDamageArgs)->Array:
	var dmg = .take_damage(value, args)
	RunData.mod_advstats.on_enemy_damage_taken(dmg, args.hitbox)
	return dmg


func die(_args: = Entity.DieArgs.new())->void:
	.die(_args)
	
	if !_args.cleaning_up:
		RunData.mod_advstats.on_tree_killed()
