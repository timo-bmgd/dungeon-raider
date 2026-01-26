extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var score: Label = $Score
var current_money = 0

func _on_lever_lever_activated(is_on: bool) -> void:
	if(is_on):
		var bodies = area_2d.get_overlapping_bodies()
		var items = []
		var money_made = 0
		for body in bodies:
			if body is Item:
				var item : Item = body
				items.append(item)
		for item in items:
			money_made += item.value
		current_money += money_made
		for item in items:
			item.queue_free()
		score.text = "Current Money: " + str(current_money)
