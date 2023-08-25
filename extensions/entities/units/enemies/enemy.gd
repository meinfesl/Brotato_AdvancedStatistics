extends "res://entities/units/enemies/enemy.gd"


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, p_player_ref:Node2D = null, entity_spawner_ref:EntitySpawner = null)->void:
	.init(zone_min_pos, zone_max_pos, p_player_ref, entity_spawner_ref)
	
	RunData.mod_advstats.on_enemy_spawned(self)


func take_damage(value:int, hitbox:Hitbox = null, dodgeable:bool = true, armor_applied:bool = true, custom_sound:Resource = null, base_effect_scale:float = 1.0)->Array:
	var dmg = .take_damage(value, hitbox, dodgeable, armor_applied, custom_sound, base_effect_scale)
	RunData.mod_advstats.on_enemy_damage_taken(dmg, hitbox)
	return dmg


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void:
	.die(knockback_vector, p_cleaning_up)
	
	#p_cleaning_up is not viable on_group_spawn_timing_reached calls just die()
	if current_stats.health == 0:
		RunData.mod_advstats.on_enemy_killed(self)
