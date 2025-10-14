# (DEPRECATED) Legacy user document saver. Replaced by single `characters` collection architecture in `firebase_characters.gd`.
# Retained temporarily for compatibility; scheduled for removal once UI migrates fully.
class_name FirebaseSaver
extends Object

const USER_COLLECTION_ID = "users"

static func save_user(login_data):
	# Defensive auth handling: plugin may expose auth as Dictionary or object.
	var auth_wrapper = Firebase.Auth
	var user_id = ""
	if auth_wrapper.has_method("get_current_user"):
		var current_user = auth_wrapper.get_current_user()
		if current_user and typeof(current_user) == TYPE_DICTIONARY:
			user_id = current_user.get("uid", "")
		elif current_user and current_user.has_method("get"):
			# Fallback if returned as custom object
			user_id = current_user.uid if current_user.has_property("uid") else ""
	else:
		# Legacy field access attempt
		var legacy_auth = auth_wrapper.auth
		if typeof(legacy_auth) == TYPE_DICTIONARY:
			user_id = legacy_auth.get("localid", "")
		elif legacy_auth and legacy_auth.has_property("localid"):
			user_id = legacy_auth.localid

	if user_id == "":
		print("[FirebaseSaver] No authenticated user; aborting save_user")
		return

	var collection: FirestoreCollection = Firebase.Firestore.collection(USER_COLLECTION_ID)
	var data = login_data.to_dict()
	var document = await collection.get_doc(user_id)

	if document:
		for key in data.keys():
			document.add_or_update_field(key, data[key])
		var task = await collection.update(document)
		if task:
			print("[FirebaseSaver] Document updated successfully")
		else:
			print("[FirebaseSaver] Failed to update document")
	else:
		document = await collection.add(user_id, data)
		if document:
			print("[FirebaseSaver] Document created successfully")
		else:
			print("[FirebaseSaver] Failed to create document")
