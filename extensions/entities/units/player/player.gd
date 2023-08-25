extends "res://entities/units/player/player.gd"


func take_damage(value:int, hitbox:Hitbox = null, dodgeable:bool = true, armor_applied:bool = true, custom_sound:Resource = null, base_effect_scale:float = 1.0, bypass_invincibility:bool = false)->Array:
	RunData.mod_advstats.damage_source = "item_riposte"
	var dmg = .take_damage(value, hitbox, dodgeable, armor_applied, custom_sound, base_effect_scale, bypass_invincibility)
	RunData.mod_advstats.on_player_damage_taken(self, value, dmg, hitbox)
	RunData.mod_advstats.damage_source = ""
	return dmg


func heal(value:int, is_from_torture:bool = false)->int:
	var amount = .heal(value, is_from_torture)
	if amount > 0:
		RunData.mod_advstats.on_player_healed(amount)
	return amount


func _on_HealthRegenTimer_timeout()->void:
	RunData.mod_advstats.heal_source = "HP_HEALED_REGEN"
	._on_HealthRegenTimer_timeout()
	RunData.mod_advstats.heal_source = ""


func on_lifesteal_effect(value:int)->void:
	RunData.mod_advstats.heal_source = "HP_HEALED_LIFESTEAL"
	.on_lifesteal_effect(value)
	RunData.mod_advstats.heal_source = ""
