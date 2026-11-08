extends RefCounted
class_name TrackedTileData

var cell_pos : Vector2i
var tile_type : TileManager.Tile
var atlas_coords : Vector2i
var direction : Vector2i = Vector2i.UP
var is_conveyor : bool = false

func _init(pos : Vector2i, type : TileManager.Tile, dir : Vector2i = Vector2i.UP) -> void:
	cell_pos = pos
	tile_type = type
	direction = dir

func update():
	pass

class ConveyorTileData extends TrackedTileData:
	func _init(pos : Vector2i, type : TileManager.Tile, dir : Vector2i) -> void:
		super(pos, type, dir)
		is_conveyor = true

class SourceTileData extends TrackedTileData:
	const SPAWN_INTERVAL : float = 0.5
	var cooldown : float = SPAWN_INTERVAL
	var spawn_string : String = "Hello"

class AdderTileData extends TrackedTileData:
	pass

class SlicerTileData extends TrackedTileData:
	pass
