extends Sprite2D
var tilemap: TileMapLayer

func _ready() -> void:
	tilemap = get_parent().get_node("TileMapLayer")

func _process(_delta: float) -> void:
	var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(get_global_mouse_position()))
	global_position = tilemap.to_global(tilemap.map_to_local(tile_pos))
