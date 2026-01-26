extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var credit_label: Label = $credit_label
@onready var items_label: Label = $items_label


var current_money = 0
var current_items = 0

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
		credit_label.text = "Credit: " + str(current_money)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Item:
		current_items += 1
		items_label.text = "Items: " + str(current_items)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Item:
		current_items -= 1
		items_label.text = "Items: " + str(current_items)
