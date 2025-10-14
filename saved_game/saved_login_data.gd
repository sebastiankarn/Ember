class_name SavedLoginData
extends Resource

@export var user_name:String
@export var password:String
@export var saved_characters:Array[int]
@export var highest_character_id:int
@export var firebase_character_ids:Dictionary = {} # key: local character_id (int) -> firestore doc id (String)

func to_dict() -> Dictionary:
	return {
		"user_name": user_name,
		"password": password,
		"saved_characters": saved_characters,
		"highest_character_id": highest_character_id,
		"firebase_character_ids": firebase_character_ids
	}

static func from_dict(data: Dictionary) -> SavedLoginData:
	var login_data = SavedLoginData.new()
	login_data.user_name = data.user_name
	login_data.password = data.password
	login_data.saved_characters = data.saved_characters
	login_data.highest_character_id = data.highest_character_id
	if data.has("firebase_character_ids"):
		login_data.firebase_character_ids = data.firebase_character_ids
	return login_data
