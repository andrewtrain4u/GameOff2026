extends Button

@export var tile_manager : TileManager
@export var tile : TileManager.Tile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(tile_manager, "Tile Manager not found! Is the export for the button scene configured right?")
	
	icon = tile_manager.get_tile_texture(tile)
	text = TileManager.Tile.find_key(tile)
	text = text.capitalize()

func _on_button_up() -> void:
	tile_manager.active_tile = tile
