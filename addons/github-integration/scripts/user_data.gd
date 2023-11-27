@tool
# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019





# -----------------------------------------------

extends Node

# saves and loads user datas from custom folder in user://github_integration/user_data.ud

var directory : String = ""
var file_name : String = "user_data.ud"
var avatar_name : String = "avatar"

var USER : Dictionary = {}

# --- on the USER usage
# login = username
# avatar
# id

var AVATAR : ImageTexture
var AUTH : String
var TOKEN : String
var MAIL : String

var header : Array = [""]
var gitlfs_header : Array = [""]
var gitlfs_request : String = ".git/info/lfs/objects/batch"

var plugin_version : String = "0.9.4"

func _ready():
	directory = PluginSettings.plugin_path

func user_exists() -> bool:
	var file := FileAccess.open(directory + file_name, FileAccess.READ)
	if file:
		file.close()
		return true
	else:
		return false

func save(user: Dictionary, avatar: PackedByteArray, auth: String, token: String, mail: String) -> void:
	var file := FileAccess.open_encrypted_with_pass(directory + file_name, FileAccess.WRITE, OS.get_unique_id())
	if file:
		USER = user
		AUTH = auth
		TOKEN = token
		MAIL = mail
		var formatting := PackedStringArray()
		var json = JSON.new()
		formatting.append(auth)                     #0
		formatting.append(mail)                     #1
		formatting.append(token)                    #2
		formatting.append(json.print(user))         #3
		formatting.append(plugin_version)           #4
		file.store_csv_line(formatting)
		file.close()
		if PluginSettings.debug:
			print("[GitHub Integration] >> saved user datas in user folder")

	save_avatar(avatar)
	
	header = ["Authorization: Token " + token]

func save_avatar(avatar: PackedByteArray):
	if avatar == null:
		return
	var image := Image.new()
	var extension := avatar.slice(0, 1).hex_encode()
	match extension:
		"ffd8":
			image.load_jpg_from_buffer(avatar)
			var file_jpg := FileAccess.open(directory + avatar_name + ".jpg", FileAccess.WRITE)
			if file_jpg:
				file_jpg.store_buffer(avatar)
				file_jpg.close()
		"8950":
			image.load_png_from_buffer(avatar)
			image.save_png(directory + avatar_name + ".png")
	load_avatar()


func load_avatar():
	var img_text := ImageTexture.new()
	var av := Image.new()

	if FileAccess.file_exists(directory + avatar_name + ".png"):
		av.load(directory + avatar_name + ".png")
		img_text.create_from_image(av)
		AVATAR = img_text
	elif FileAccess.file_exists(directory + avatar_name + ".jpg"):
		av.load(directory + avatar_name + ".jpg")
		img_text.create_from_image(av)
		AVATAR = img_text
	else:
		AVATAR = null


func load_user() -> PackedStringArray:
	var content := PackedStringArray()

	if PluginSettings.debug:
		print("[GitHub Integration] >> loading user profile, checking for existing logfile...")

	if FileAccess.file_exists(directory + file_name):
		if PluginSettings.debug:
			print("[GitHub Integration] >> logfile found, fetching datas..")
		
		var file := FileAccess.open_encrypted_with_pass(directory + file_name, FileAccess.READ, OS.get_unique_id())
		if file:
			content = file.get_csv_line()
			file.close()

			if content.size() < 5:
				if PluginSettings.debug:
					printerr("[GitHub Integration] >> this log file belongs to an older version of this plugin and will not support the mail/password login deprecation, so it will be deleted. Please, insert your credentials again.")
				
				var dir := DirAccess.open("") # Open the current directory
				if dir:
					dir.remove(directory + file_name)
					dir.close()

				content = PackedStringArray()
				return content

			AUTH = content[0]
			MAIL = content[1]
			TOKEN = content[2]

			var test_json_conv := JSON.new()
			var error := test_json_conv.parse(content[3])
			if error == OK:
				USER = test_json_conv.get_data()
			else:
				printerr("Failed to parse JSON")

			load_avatar()

			header = ["Authorization: Token " + TOKEN]
			gitlfs_header = [
				"Accept: application/vnd.github.v3+json",
				"Accept: application/vnd.git-lfs+json",
				"Content-Type: application/vnd.git-lfs+json"
			]
			gitlfs_header.append(header[0])
		else:
			printerr("Failed to open encrypted file: ", directory + file_name)

	else:
		if PluginSettings.debug:
			printerr("[GitHub Integration] >> no logfile found, log in for the first time to create a logfile.")

	return content


func logout_user():
	AUTH = "null"
	MAIL = "null"
	TOKEN = "null"
	USER = {}
	AVATAR = null
	header = []

func delete_user():
	var dir := DirAccess.open(directory)
	if dir:
		if dir.file_exists(directory + file_name):
			dir.remove(directory + file_name)
		if dir.file_exists(directory + avatar_name):
			dir.remove(directory + avatar_name)
		dir.close()
	else:
		printerr("Failed to open directory: ", directory)
