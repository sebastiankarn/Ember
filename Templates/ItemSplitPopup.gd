extends Popup

var data

func _ready():
	get_node("N/M/H/Amount").grab_focus()

func _on_Confirm_pressed():
	var split_amount = get_node("N/M/H/Amount").get_text()
	if split_amount == "":
		split_amount = 1
	if int(split_amount) >= data["original_stack"]:
		split_amount = data["original_stack"] - 1
	get_parent().SplitStack(int(split_amount), data)
	self.queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_Confirm_pressed()
