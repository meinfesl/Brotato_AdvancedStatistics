extends "res://singletons/weapon_service.gd"

onready var mod_ttf_item_turret = Keys.generate_hash("item_turret")

func explode(effect: ExplodingEffect, args: WeaponServiceExplodeArgs)->Node:
	#if args.damage_tracking_key == Keys.empty_hash and RunData.mod_advstats.damage_tracking_key != Keys.emtpy_hash:
	#	args.damage_tracking_key_hash = RunData.mod_advstats.damage_tracking_key
	var instance = .explode(effect, args)
	if RunData.mod_advstats.exploding_weapon:
		instance.connect("hit_something", RunData.mod_advstats.exploding_weapon, "mod_advstat_count_damage", [instance._hitbox])
	return instance

func spawn_projectile(
		pos: Vector2, 
		weapon_stats: RangedWeaponStats, 
		direction: float, 
		from: Node, 
		args: WeaponServiceSpawnProjectileArgs
	)->Node:
	
	if args.damage_tracking_key_hash == Keys.empty_hash and RunData.mod_advstats.damage_tracking_key != Keys.empty_hash:
		args.damage_tracking_key_hash = RunData.mod_advstats.damage_tracking_key
	if args.damage_tracking_key_hash == mod_ttf_item_turret and RunData.mod_advstats.damage_tracking_key == Keys.item_pocket_factory_hash:
		args.damage_tracking_key_hash = Keys.item_pocket_factory_hash
	return .spawn_projectile(pos, weapon_stats, direction, from, args)
