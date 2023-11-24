extends ColorRect

@onready var item_icon = $ItemIcon
@onready var item_quantity = $ItemQuantity

func display_item(item):
	if item:
		item_icon.texture = load("res://Sprites/Items/%s" % item.icon)
		item_quantity.text = str(item.quantity) if item.stackable else ""
	else:
		item_icon.texture = null
		item_quantity.text = ""
	if get_parent() and get_parent().name == "HotBar":
		if get_index() == Inventory.selected:
			color = "#7b7b7b"
		else:
			color = "#333333"
