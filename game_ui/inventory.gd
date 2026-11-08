extends GridContainer

@export var tile_manager : TileManager
@export var button_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Adds a new button for every tile
	for tile in tile_manager.Tile.size():
		var new_button := button_scene.instantiate()
		new_button.tile = tile
		add_child(new_button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
