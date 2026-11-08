extends TileMapLayer

@export var tile_manager : TileManager

var previous_mouse_cell_coord : Vector2i = Vector2i.MAX
var previous_direction : TileManager.Direction = TileManager.Direction.UP
var previous_tile : TileManager.Tile = TileManager.Tile.AIR

func _ready() -> void:
	assert(tile_manager, "Tile Manager not found! Check the export")

func _process(delta: float) -> void:
	var mouse_cell_coord : Vector2i = local_to_map(get_local_mouse_position())
	if mouse_cell_coord != previous_mouse_cell_coord or tile_manager.direction != previous_direction or tile_manager.active_tile != previous_tile:
		erase_cell(previous_mouse_cell_coord)
		var active_tile : TileManager.Tile = tile_manager.active_tile
		var alt_tile : int = tile_manager.get_direction_transform()
		set_cell(mouse_cell_coord, active_tile, Vector2i.ZERO, alt_tile)
		
		previous_mouse_cell_coord = mouse_cell_coord
		previous_direction = tile_manager.direction
		previous_tile = tile_manager.active_tile
