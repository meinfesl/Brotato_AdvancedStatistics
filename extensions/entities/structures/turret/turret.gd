extends "res://entities/structures/turret/turret.gd"

var mod_tooltiptracking_key = Keys.empty_hash


func shoot()->void :
	RunData.mod_advstats.damage_tracking_key = mod_tooltiptracking_key
	.shoot()
	RunData.mod_advstats.damage_tracking_key = Keys.empty_hash

