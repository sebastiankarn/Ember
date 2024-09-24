extends TileMap


# In MapTileMap.gd
var main_tilemap_1
var main_tilemap_2


func _ready():
	main_tilemap_1 = get_node("/root/MainScene/TileMap/Ground1")
	main_tilemap_2 = get_node("/root/MainScene/TileMap/Ground1")
	print(main_tilemap_1)
	#copy_tile_data(main_tilemap_1)
	#copy_tile_data(main_tilemap_1)
#
#
#
#
#
#func copy_tile_data(tilemap):
	#print(tilemap)
	#for position in tilemap.get_used_cells():
		#var tile_id = tilemap.get_cell(position)
		#set_cell(position, tile_id)
		#print("hej")
