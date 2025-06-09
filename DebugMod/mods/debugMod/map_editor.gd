extends Node

# TODO: Would it be better if this wasn't a global class but a node added to the level?

var loaded_level: Node2D = null

func _enter_tree ():
    var modding_api: Node = get_parent().get_parent() # Actually the ModdingApi class
    modding_api.level_loaded.connect(_level_loaded)

func _level_loaded (level: Node2D):
    loaded_level = level

func _input (event: InputEvent):
    if loaded_level == null:
        return

    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
            _handle_mouse_click(event.position)

func _handle_mouse_click (position: Vector2):
    if loaded_level == null:
        return

    var grid_manager: Node2D = loaded_level.tm # Actually a GridManager
    if grid_manager == null:
        return

    var coordinates: Vector2i = grid_manager.GetCellFromGlobalPos(position)

    if Input.is_key_pressed(KEY_0):
        _set_tile(coordinates, Globals.ObjectType.NONE)
    elif Input.is_key_pressed(KEY_C):
        if Input.is_key_pressed(KEY_1):
            _set_tile(coordinates, Globals.ObjectType.CARROT_01)
        elif Input.is_key_pressed(KEY_2):
            _set_tile(coordinates, Globals.ObjectType.CARROT_02)
        elif Input.is_key_pressed(KEY_3):
            _set_tile(coordinates, Globals.ObjectType.CARROT_03)
        elif Input.is_key_pressed(KEY_4):
            _set_tile(coordinates, Globals.ObjectType.CARROT_04)
    elif Input.is_key_pressed(KEY_F):
        if Input.is_key_pressed(KEY_1):
            _set_tile(coordinates, Globals.ObjectType.FLOWER_01)
        elif Input.is_key_pressed(KEY_2):
            _set_tile(coordinates, Globals.ObjectType.FLOWER_02)
        elif Input.is_key_pressed(KEY_3):
            _set_tile(coordinates, Globals.ObjectType.FLOWER_03)
        elif Input.is_key_pressed(KEY_4):
            _set_tile(coordinates, Globals.ObjectType.FLOWER_04)
    elif Input.is_key_pressed(KEY_T):
        if Input.is_key_pressed(KEY_1):
            _set_tile(coordinates, Globals.ObjectType.TREE_01)
        elif Input.is_key_pressed(KEY_2):
            _set_tile(coordinates, Globals.ObjectType.TREE_02)
        elif Input.is_key_pressed(KEY_3):
            _set_tile(coordinates, Globals.ObjectType.TREE_03)
        elif Input.is_key_pressed(KEY_4):
            _set_tile(coordinates, Globals.ObjectType.TREE_04)
    elif Input.is_key_pressed(KEY_H):
        if Input.is_key_pressed(KEY_1):
            _set_tile(coordinates, Globals.ObjectType.HOUSE_01)
        elif Input.is_key_pressed(KEY_2):
            _set_tile(coordinates, Globals.ObjectType.HOUSE_02)
    elif Input.is_key_pressed(KEY_A):
        _set_character(coordinates, Globals.ChainType.FLOWER)
    elif Input.is_key_pressed(KEY_G):
        _set_character(coordinates, Globals.ChainType.CARROT)
    elif Input.is_key_pressed(KEY_W):
        _set_character(coordinates, Globals.ChainType.TREE)
    elif Input.is_key_pressed(KEY_S):
        _set_character(coordinates, Globals.ChainType.NONE)

func _set_tile (coordinates: Vector2i, tile_type: Globals.ObjectType):
    var grid_manager: Node2D = loaded_level.tm # Actually a GridManager

    if grid_manager.GetTileAtCoord(coordinates) != null:
        grid_manager.RemoveTile(coordinates, coordinates)

    if tile_type != Globals.ObjectType.NONE:
        grid_manager.AddTileByObjectType(coordinates, tile_type, false)

    _recalculate_character_stuckness()

func _set_character (coordinates: Vector2i, character_type: Globals.ChainType):
    var grid_manager: Node2D = loaded_level.tm # Actually a GridManager

    var character_number := 1
    if Input.is_key_pressed(KEY_2):
        character_number = 2
    elif Input.is_key_pressed(KEY_3):
        character_number = 3
    elif Input.is_key_pressed(KEY_4):
        character_number = 4

    var character_counter := 0
    for character in grid_manager.Characters:
        if character.ChainType == character_type:
            character_counter += 1

            if character_counter >= character_number:
                character.Coord = coordinates
                character.z_index = coordinates.y + 3
                character.global_position = grid_manager.GetCellGlobalPos(coordinates)
                break

    _recalculate_character_stuckness()

func _recalculate_character_stuckness ():
    var grid_manager: Node2D = loaded_level.tm # Actually a GridManager

    for character in grid_manager.Characters:
        if character.ChainType == Globals.ChainType.NONE:
            continue

        var possible_move_targets: Array = grid_manager.GetFreeNeighbourCells(character.Coord)
        if possible_move_targets.size() == 0:
            character.ToggleStuckFeedback(true)
        else:
            character.ToggleStuckFeedback(false)
