extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var credit_label: Label = $credit_label
@onready var items_label: Label = $items_label


var current_money = 0:
	set(value):
		current_money = value
		_update_save_state()
var current_items = 0

func _update_save_state():	
	SceneManager.save_game_state(current_money)

func _ready() -> void:
	current_money = SceneManager.get_game_state()["money"]
	_update_labels()


func _update_labels() -> void:
	credit_label.text = "Credit: " + str(current_money)
	items_label.text = "Items: " + str(current_items)

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
		_update_labels()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Item:
		current_items += 1
		_update_labels()



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Item:
		current_items -= 1
		_update_labels()
