extends Node2D
func _ready():
	# Retrieve the MainTileMapLayers node
	var main_tilemap_layers = get_node("/root/MainScene/WorldTileMap")

	# Load the TileSet
	var my_tileset = preload("res://MapTileSet.tres")

	# Clone each necessary TileMapLayer
	for layer in ["Ground1", "Ground2", "Walls"]:
		var original_layer = main_tilemap_layers.get_node(layer)
		var cloned_layer = original_layer.duplicate()
		cloned_layer.tile_set = my_tileset
		add_child(cloned_layer)
