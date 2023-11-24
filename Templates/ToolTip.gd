extends Popup


var origin
var slot = ""
var valid = false

func _ready():
	var item_id
	var info
	var stats
	var enchanted = ""
	if origin == "Inventory":
		if PlayerData.inv_data[slot]["Item"] != null:
			item_id = str(PlayerData.inv_data[slot]["Item"])
			valid = true
			info = PlayerData.inv_data[slot]["Info"] 
			stats = PlayerData.inv_data[slot]["Stats"] 
			if stats != null && PlayerData.inv_data[slot]["Stats"]["EnchantedLevel"] != null && PlayerData.inv_data[slot]["Stats"]["EnchantedLevel"] != 0:
				enchanted += " (" + str(PlayerData.inv_data[slot]["Stats"]["EnchantedLevel"]) + ")"
	if origin == "CharacterSheet": 
		if PlayerData.equipment_data[slot]["Item"] != null:
			item_id = str(PlayerData.equipment_data[slot]["Item"])
			valid = true
			info = PlayerData.equipment_data[slot]["Info"]
			stats = PlayerData.equipment_data[slot]["Stats"] 
			if PlayerData.equipment_data[slot]["Stats"]["EnchantedLevel"] != null && PlayerData.equipment_data[slot]["Stats"]["EnchantedLevel"] != 0:
				enchanted += " (" + str(PlayerData.equipment_data[slot]["Stats"]["EnchantedLevel"]) + ")"
	if origin == "SkillPanel":
		if (slot == "Skill"):
			slot = "Skill1"
		if PlayerData.skills_data[slot]["Id"] != null:
			item_id = str(ImportData.skill_data[PlayerData.skills_data[slot]["Id"]].SkillName)
			valid = true
			
	if valid:
		if origin == "SkillPanel":
			get_node("N/M/V/ItemName").set_text(item_id)
			return
		var item_stat = 1
		var item_data_list = null
		var prefix = ""
		var suffix = ""
		var title_color = "dddddd"
		if info != null:
			item_data_list = info
			if item_data_list["magical"]:
				if item_data_list["prefix"] != null:
					prefix = item_data_list["prefix"]
				if item_data_list["suffix"] != null:
					suffix = item_data_list["suffix"]
			if item_data_list["item_rarity"] == "Uncommon":
				title_color = "83df65"
			if item_data_list["item_rarity"] == "Rare":
				title_color = "123ce0"
			if item_data_list["item_rarity"] == "Epic":
				title_color = "aa13cf"
			if item_data_list["item_rarity"] == "Legendary":
				title_color = "daa812"
			get_node("N/M/V/Rarity").set_text(item_data_list["item_rarity"])
			get_node("N/M/V/Rarity").set("theme_override_colors/font_color", Color(title_color))
			get_node("N/M/V/Rarity").visible = true
			
		var original_name = prefix + " " + ImportData.item_data[item_id]["Name"] + " " + suffix + enchanted
		if (original_name.length() > 16):
			var words_array = original_name.split(" ")
			var too_long = 0
			var first_row_string = ""
			var second_row_string = ""
			var on_first_row = true
			for i in words_array:
				if on_first_row:
					too_long += i.length() + 1
					if too_long >= 16:
						on_first_row = false
						second_row_string += i
					else:
						if (first_row_string == ""):
							first_row_string += i
						else:
							first_row_string += " " + i
				else:
					second_row_string += " " + i
			if (second_row_string == ""):
				get_node("N/M/V/ItemName2").set_text("")
				get_node("N/M/V/ItemName2").hide()
				get_node("N/M/V/ItemName").set_text(original_name)
			else:
				get_node("N/M/V/ItemName").set_text(first_row_string)
				get_node("N/M/V/ItemName2").show()
				get_node("N/M/V/ItemName2").set_text(second_row_string)
		else:
			get_node("N/M/V/ItemName2").set_text("")
			get_node("N/M/V/ItemName2").hide()
			get_node("N/M/V/ItemName").set_text(original_name)
		get_node("N/M/V/ItemName").set("theme_override_colors/font_color", Color(title_color))
		get_node("N/M/V/ItemName2").set("theme_override_colors/font_color", Color(title_color))
		
		if info != null:
			item_data_list = stats
		for i in range(ImportData.item_stats.size()):
			var stat_name = ImportData.item_stats[i]
			var stat_label = ImportData.item_stat_labels[i]
			var stat_value = null
			var stat_exists = false
			if item_data_list != null:
				if stat_name in item_data_list:
					stat_exists = true
			if ImportData.item_data[item_id][stat_name] != null or stat_exists:
				stat_value = ImportData.item_data[item_id][stat_name]
				if item_data_list != null:
					if stat_name in item_data_list:
						stat_value = item_data_list[stat_name]
			var equipment_slot = ImportData.item_data[item_id]["EquipmentSlot"]
			if has_stat_of_equipped(equipment_slot, stat_name):
				if stat_value == null:
					stat_value = 0
			if stat_value != null:
				get_node("N/M/V/Stat" + str(item_stat) + "/Stat").set_text(stat_label + ": "+ str(stat_value))
				if ImportData.item_data[item_id]["EquipmentSlot"] != null and origin == "Inventory":
					var stat_difference = CompareItems(item_id, stat_name, stat_value)
					if stat_difference > 0:
						get_node("N/M/V/Stat" + str(item_stat) + "/Difference").set_text(" +" + str(stat_difference))
						get_node("N/M/V/Stat" + str(item_stat) + "/Difference").set("theme_override_colors/font_color", Color("3eff00"))
						get_node("N/M/V/Stat" + str(item_stat) + "/Difference").show()
					elif stat_difference < 0:
						get_node("N/M/V/Stat" + str(item_stat) + "/Difference").set_text(" " + str(stat_difference))
						get_node("N/M/V/Stat" + str(item_stat) + "/Difference").set("theme_override_colors/font_color", Color("ff0000"))
						get_node("N/M/V/Stat" + str(item_stat) + "/Difference").show()
				item_stat += 1

func has_stat_of_equipped(equipment_slot, stat_name):
	if equipment_slot != null:
		if PlayerData.equipment_data[equipment_slot]["Item"] != null:
			var item_id_current = PlayerData.equipment_data[equipment_slot]["Item"]
			var stat_value_current = PlayerData.equipment_data[equipment_slot]["Stats"][stat_name]
			if stat_value_current != null:
				return true
	return false

func CompareItems(item_id, stat_name, stat_value):
	var stat_difference
	var equipment_slot = ImportData.item_data[item_id]["EquipmentSlot"]
	if PlayerData.equipment_data[equipment_slot]["Item"] != null:
		var item_id_current = PlayerData.equipment_data[equipment_slot]["Item"]
		var stat_value_current = PlayerData.equipment_data[equipment_slot]["Stats"][stat_name]
		if stat_value_current != null:
			stat_difference = (stat_value - stat_value_current)
		else:
			stat_difference = stat_value
	else:
		stat_difference = stat_value
	return stat_difference
