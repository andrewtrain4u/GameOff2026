extends Resource
class_name TileManager

var tileset : TileSet = preload("res://tilemap/tiles/tileset.tres")

var active_tile : Tile = Tile.CONVEYOR
var direction : Direction = Direction.UP

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

enum Tile {
	AIR,
	
	CONVEYOR,
	ADDER,
	SLICER,
	SOURCE,
}

const direction_vectors := {
	Direction.UP : Vector2i.UP,
	Direction.RIGHT : Vector2i.RIGHT,
	Direction.DOWN : Vector2i.DOWN,
	Direction.LEFT : Vector2i.LEFT,
}

const direction_transforms := {
	Direction.UP : 0,
	Direction.RIGHT : TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	Direction.DOWN : TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	Direction.LEFT : TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

func get_direction_vector(dir : Direction = direction) -> Vector2i:
	return direction_vectors[dir]

func get_direction_transform(dir : Direction = direction) -> int:
	return direction_transforms[dir]

func get_direction_from_transform(alt_tile : int) -> Direction:
	var dir = direction_transforms.find_key(alt_tile)
	if dir == null:
		return Direction.UP
	return dir

func get_tile_size(tile : Tile) -> Vector2i:
	if not tileset:
		return Vector2i.ONE
	var atlas_source : TileSetAtlasSource = tileset.get_source(tile) as TileSetAtlasSource
	if not atlas_source:
		return Vector2i.ONE
	return atlas_source.get_tile_size_in_atlas(Vector2i.ZERO)

func get_active_tile_size() -> Vector2i:
	return get_tile_size(active_tile)

func get_tile_rect(tile : Tile, dir : Direction = Direction.UP) -> Rect2:
	if tile == Tile.AIR or not tileset:
		return Rect2()
	
	var atlas_source : TileSetAtlasSource = tileset.get_source(tile) as TileSetAtlasSource
	if not atlas_source:
		return Rect2(Vector2.ZERO, Vector2.ONE)
	
	var size : Vector2 = get_tile_size(tile)
	var tile_data : TileData = atlas_source.get_tile_data(Vector2i.ZERO, 0)
	var texture_origin : Vector2 = Vector2(tile_data.texture_origin) if tile_data else Vector2.ZERO
	var cell_size : Vector2 = Vector2(tileset.tile_size)
	
	var pos : Vector2 = -(size - Vector2.ONE) / 2.0 - (texture_origin / cell_size)
	
	match dir:
		Direction.RIGHT:
			return Rect2(Vector2(-pos.y - size.y + 1.0, pos.x), Vector2(size.y, size.x))
		Direction.DOWN:
			return Rect2(Vector2(-pos.x - size.x + 1.0, -pos.y - size.y + 1.0), size)
		Direction.LEFT:
			return Rect2(Vector2(pos.y, -pos.x - size.x + 1.0), Vector2(size.y, size.x))
		_:
			return Rect2(pos, size)

func get_tile_texture(tile: Tile) -> Texture2D:
	if not tileset:
		return null
	
	var atlas_source: TileSetAtlasSource = tileset.get_source(tile) as TileSetAtlasSource
	if not atlas_source:
		return null
	
	var atlas_texture : AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas_source.texture
	atlas_texture.region = atlas_source.get_tile_texture_region(Vector2i.ZERO)
	return atlas_texture

func rotate_direction(dir : Direction, ccw := false) -> Direction:
	if ccw:
		return posmod(dir - 1, Direction.size()) as Direction
	else:
		return posmod(dir + 1, Direction.size()) as Direction

func rotate_active_tile(ccw := false) -> void:
	direction = rotate_direction(direction, ccw)
