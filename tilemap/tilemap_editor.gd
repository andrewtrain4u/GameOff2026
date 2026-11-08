extends Node2D

signal tile_placed(tile : TileManager.Tile, cell_coords : Vector2i, direction : Vector2i)
signal tile_removed(tile : TileManager.Tile, cell_coords : Vector2i)

@export var tilemap : TileMapLayer
@export var tile_manager : TileManager

const MAX_TILE_SIZE : Vector2i = Vector2i(5, 5)

func _ready() -> void:
	assert(tilemap, "TileMap node not found! Check the export")
	assert(tile_manager, "Tile Manager not found! Check the export")

func _process(delta: float) -> void:
	if Input.is_action_pressed("Place"):
		var cell_coords : Vector2i = tilemap.local_to_map(get_local_mouse_position())
		var active_tile : TileManager.Tile = tile_manager.active_tile
		if can_place_tile(cell_coords, active_tile, tile_manager.direction):
			var alt_tile : int = tile_manager.get_direction_transform()
			tilemap.set_cell(cell_coords, active_tile, Vector2i.ZERO, alt_tile)
			tile_placed.emit(active_tile, cell_coords, tile_manager.get_direction_vector())
	
	if Input.is_action_pressed("Delete"):
		var cell_coords : Vector2i = tilemap.local_to_map(get_local_mouse_position())
		delete_tile(cell_coords)
	
	if Input.is_action_just_pressed("Rotate"):
		tile_manager.rotate_active_tile()

func can_place_tile(cell_coords : Vector2i, tile : TileManager.Tile, dir : TileManager.Direction = tile_manager.direction) -> bool:
	var tile_rect : Rect2 = tile_manager.get_tile_rect(tile, dir)
	tile_rect.position += Vector2(cell_coords)
	
	for x : int in range(int(tile_rect.position.x), int(tile_rect.end.x)):
		for y : int in range(int(tile_rect.position.y), int(tile_rect.end.y)):
			if is_cell_in_large_tile(Vector2i(x, y)):
				return false
	return true

func delete_tile(cell_coords : Vector2i) -> void:
	var origin : Variant = get_large_tile_origin(cell_coords)
	if origin != null:
		var origin_coords : Vector2i = origin as Vector2i
		var removed_tile : TileManager.Tile = tilemap.get_cell_source_id(origin_coords)
		tilemap.erase_cell(origin_coords)
		tile_removed.emit(removed_tile, origin_coords)

func is_cell_in_large_tile(cell_coords : Vector2i) -> bool:
	return get_large_tile_origin(cell_coords) != null

func get_large_tile_origin(cell_coords : Vector2i) -> Variant:
	# Iterates over the possible space a large tile could be
	for x : int in range(-MAX_TILE_SIZE.x, MAX_TILE_SIZE.x + 1):
		for y : int in range(-MAX_TILE_SIZE.y, MAX_TILE_SIZE.y + 1):
			var check_coords : Vector2i = cell_coords + Vector2i(x, y)
			var tile : TileManager.Tile = tilemap.get_cell_source_id(check_coords)
			#print(tile)
			if (tile == TileManager.Tile.AIR or tile == -1):
				continue
			# Gets the direction
			var alt_tile : int = tilemap.get_cell_alternative_tile(check_coords)
			var dir : TileManager.Direction = tile_manager.get_direction_from_transform(alt_tile)
			
			var tile_rect : Rect2 = tile_manager.get_tile_rect(tile, dir)
			tile_rect.position += Vector2(check_coords)
			if tile_rect.has_point(Vector2(cell_coords)):
				print("Sucess")
				return check_coords
				
	return null
