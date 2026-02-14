extends "res://entities/units/neutral/neutral.gd"


func take_damage(value: int, args: TakeDamageArgs)->Array:
	var dmg = .take_damage(value, args)
	
	if args.hitbox and is_instance_valid(args.hitbox.from):
		if args.hitbox.from is Lootworm:
			RunData.mod_advstats.lootworm_damage += dmg[1]
			
	RunData.mod_advstats.on_enemy_damage_taken(dmg, args.hitbox)
	return dmg


func die(_args: = Entity.DieArgs.new())->void:
	.die(_args)
	
	if !_args.cleaning_up:
		RunData.mod_advstats.on_tree_killed()
