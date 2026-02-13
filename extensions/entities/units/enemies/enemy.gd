extends "res://entities/units/enemies/enemy.gd"


func init(zone_min_pos: Vector2, zone_max_pos: Vector2, p_players_ref: Array = [], entity_spawner_ref = null)->void:
	.init(zone_min_pos, zone_max_pos, p_players_ref, entity_spawner_ref)
	
	if not (zone_min_pos == Vector2.ZERO and zone_max_pos == Vector2.ZERO):
		RunData.mod_advstats.on_enemy_spawned(self)


func take_damage(value: int, args: TakeDamageArgs)->Array:
	var dmg = .take_damage(value, args)
	RunData.mod_advstats.on_enemy_damage_taken(dmg, args.hitbox)
	return dmg


func die(args: = Utils.default_die_args)->void:
	.die(args)
	
	#p_cleaning_up is not viable on_group_spawn_timing_reached calls just die()
	if current_stats.health == 0:
		RunData.mod_advstats.on_enemy_killed(self)
