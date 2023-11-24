extends SlotContainer

func _ready():
	display_item_slots(Inventory.cols, Inventory.rows)
	await get_tree().idle_frame
	position = (get_viewport_rect().size - size) / 2
	hide()
	
