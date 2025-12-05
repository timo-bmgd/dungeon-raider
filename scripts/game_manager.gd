extends Node

@onready var ui: CanvasLayer = %ui

var inventory = Array()

func collect_item(item):
	inventory.append(item)
	print(item)
	ui.add_item(item)
