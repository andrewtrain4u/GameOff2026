extends Node2D

@export var tilemap : TileMapLayer
@export var tile_manager : TileManager
@export var item_scene : PackedScene
@export var max_pool_size : int = 50
@export var move_speed : float = 64.0

var active_items : Array[Item] = []
var unused_items : Array[Item] = []
var occupied_cells : Dictionary[Vector2i, Item] = {}
var tracked_tiles : Dictionary[Vector2i, TrackedTileData] = {}

func _ready() -> void:
	assert(tilemap, "TileMap node not found! Check the export")
	assert(tile_manager, "Tile Manager not found! Check the export")
	assert(item_scene, "Item scene not found! Check the export")
	
	create_new_item(Vector2i(10, 10), "Hello World!")

func _process(delta: float) -> void:
	for tile_data : TrackedTileData in tracked_tiles.values():
		if tile_data is TrackedTileData.SourceTileData:
			_update_source_tile(tile_data as TrackedTileData.SourceTileData, delta)
	
	for item : Item in active_items:
		_update_item_movement(item, delta)

func _update_source_tile(source_data : TrackedTileData.SourceTileData, delta : float) -> void:
	source_data.cooldown -= delta
	if source_data.cooldown <= 0.0:
		var spawn_cell : Vector2i = source_data.cell_pos + source_data.direction
		if not occupied_cells.has(spawn_cell):
			create_new_item(spawn_cell, source_data.spawn_string)
			source_data.cooldown = TrackedTileData.SourceTileData.SPAWN_INTERVAL
		else:
			source_data.cooldown = 0.0

func _update_item_movement(item : Item, delta : float) -> void:
	if not item.is_moving:
		var current_tile_data : TrackedTileData = tracked_tiles.get(item.cell_pos)
		if current_tile_data == null or not current_tile_data.is_conveyor:
			return
		
		var next_cell : Vector2i = item.cell_pos + current_tile_data.direction
		var next_tile_data : TrackedTileData = tracked_tiles.get(next_cell)
		
		if next_tile_data == null or not next_tile_data.is_conveyor:
			return
		
		if occupied_cells.has(next_cell):
			return
		
		item.target_cell = next_cell
		item.is_moving = true
		occupied_cells[next_cell] = item
	
	if item.is_moving:
		var target_pos : Vector2 = tilemap.map_to_local(item.target_cell)
		item.position = item.position.move_toward(target_pos, move_speed * delta)
		if item.position.is_equal_approx(target_pos):
			item.position = target_pos
			if occupied_cells.get(item.cell_pos) == item:
				occupied_cells.erase(item.cell_pos)
			item.cell_pos = item.target_cell
			item.is_moving = false

func create_new_item(cell_pos : Vector2i, initial_string : String) -> Item:
	if occupied_cells.has(cell_pos):
		return null
	
	var new_item : Item
	if not unused_items.is_empty():
		new_item = unused_items.pop_back()
		new_item.visible = true
	else:
		new_item = item_scene.instantiate() as Item
		add_child(new_item)
	
	new_item.text = initial_string
	new_item.cell_pos = cell_pos
	new_item.target_cell = cell_pos
	new_item.is_moving = false
	new_item.position = tilemap.map_to_local(cell_pos)
	
	active_items.append(new_item)
	occupied_cells[cell_pos] = new_item
	return new_item

func remove_item(item : Item) -> void:
	var index : int = active_items.find(item)
	if index != -1:
		active_items.remove_at(index)
	
	if occupied_cells.get(item.cell_pos) == item:
		occupied_cells.erase(item.cell_pos)
	if occupied_cells.get(item.target_cell) == item:
		occupied_cells.erase(item.target_cell)
	
	item.is_moving = false
	
	if unused_items.size() < max_pool_size:
		item.visible = false
		unused_items.append(item)
	else:
		item.queue_free()

func _create_tile_data(tile : TileManager.Tile, cell_coords : Vector2i, direction : Vector2i) -> TrackedTileData:
	match tile:
		TileManager.Tile.CONVEYOR:
			return TrackedTileData.ConveyorTileData.new(cell_coords, tile, direction)
		TileManager.Tile.SOURCE:
			return TrackedTileData.SourceTileData.new(cell_coords, tile, direction)
		TileManager.Tile.ADDER:
			return TrackedTileData.AdderTileData.new(cell_coords, tile, direction)
		TileManager.Tile.SLICER:
			return TrackedTileData.SlicerTileData.new(cell_coords, tile, direction)
		_:
			return null

func _on_tile_editor_tile_placed(tile : TileManager.Tile, cell_coords : Vector2i, direction : Vector2i) -> void:
	var tile_data : TrackedTileData = _create_tile_data(tile, cell_coords, direction)
	if tile_data != null:
		tracked_tiles[cell_coords] = tile_data

func _on_tile_editor_tile_removed(tile : TileManager.Tile, cell_coords : Vector2i) -> void:
	tracked_tiles.erase(cell_coords)
