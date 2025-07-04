extends Node

# TODO: Would it be possible to have proper typing here for the game's classes without copying game code?

class CharacterState:
    var character: Node2D # Actually a CharacterTile
    var is_stuck: bool
    var coordinates: Vector2i
    func _init (_character: Node2D, _is_stuck: bool, _coordinates: Vector2i):
        character = _character
        is_stuck = _is_stuck
        coordinates = _coordinates

class TileState:
    var object_type: int # Actually an ObjectType
    var coordinates: Vector2i
    func _init (_object_type: int, _coordinates: Vector2i):
        object_type = _object_type
        coordinates = _coordinates

@export var undo_button_packed_scene: PackedScene
var undo_button: Button

var last_characters: Array[CharacterState] = []
var last_tiles: Array[TileState] = []
var last_map_energy := 0

var current_characters: Array[CharacterState] = []
var current_tiles: Array[TileState] = []
var current_map_energy := 0

var last_round := 0

## The real rounds are the matchings the user did (so not counting everything else like using a tool).
var real_rounds := -1
var was_reset_this_round := true

var grid_manager: Node2D # Actually a GridManager

func _enter_tree ():
    _connect_stats_updated()

func _ready ():
    grid_manager = get_parent().get_node("%TileMap") # A GridManager
    grid_manager.OnGameOver.connect(_on_game_finished)
    grid_manager.OnGameWon.connect(_on_game_finished)

    var hud = get_parent().get_node("%HUD")
    hud.CheatWinMap.connect(_on_game_finished)

    undo_button = undo_button_packed_scene.instantiate()
    undo_button.pressed.connect(reset_game_state)
    get_parent().get_node("HUD").add_child(undo_button)

    grid_manager.get_node("objects").changed.connect(_after_map_initialised_before_characters_moved)

func _after_map_initialised_before_characters_moved ():
    grid_manager.get_node("objects").changed.disconnect(_after_map_initialised_before_characters_moved)

    _save_game_state()

    last_characters = current_characters
    last_tiles = current_tiles
    last_map_energy = current_map_energy

func _exit_tree ():
    _disconnect_stats_updated()

func _on_game_finished ():
    undo_button.visible = false
    _disconnect_stats_updated()

func _connect_stats_updated ():
    Globals.UpdateStats.connect(_on_globals_stats_updated)

func _disconnect_stats_updated ():
    if Globals.UpdateStats.is_connected(_on_globals_stats_updated):
        Globals.UpdateStats.disconnect(_on_globals_stats_updated)

func _on_globals_stats_updated ():
    if Globals.PlayerTurns != last_round:
        _save_game_state()

    last_round = Globals.PlayerTurns

    # The mouse_mode is invisible while a tool is being used.
    if last_map_energy == current_map_energy and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        real_rounds += 1
        was_reset_this_round = false

func _save_game_state ():
    last_characters = current_characters
    current_characters = []
    for character in grid_manager.Characters:
        var character_state = CharacterState.new(character, character.Stuck, character.Coord)
        current_characters.append(character_state)

    last_tiles = current_tiles
    current_tiles = []
    for tile in grid_manager.Tiles:
        var tile_state = TileState.new(tile.ObjectType, tile.Coord)
        current_tiles.append(tile_state)

    last_map_energy = current_map_energy
    current_map_energy = Globals.MapEnergy

func reset_game_state ():
    if current_characters == last_characters and current_tiles == last_tiles:
        return

    Globals.MapEnergy = last_map_energy
    _disconnect_stats_updated()
    Globals.UpdateStats.emit()
    _connect_stats_updated()

    _reset_tiles()
    _reset_characters()
    _reset_background_tiles()
    _reset_goals()

    current_characters = last_characters
    current_tiles = last_tiles
    current_map_energy = last_map_energy

    if not was_reset_this_round:
        real_rounds -= 1
        was_reset_this_round = true

    if real_rounds > 0:
        grid_manager.ProcessCharacters(true, true)
    elif not grid_manager.HasPlayerMovesLeft():
        grid_manager.ProcessCharacters(true)

func _reset_tiles ():
    _remove_new_tiles()
    _restore_missing_tiles()

func _remove_new_tiles ():
    var tiles_on_grid: Array = grid_manager.Tiles.duplicate()

    for present_tile in tiles_on_grid:
        var identical_to_previous := false

        for last_tile in last_tiles: # TODO: Use a dictionary for faster lookup.
            if present_tile.Coord == last_tile.coordinates and present_tile.ObjectType == last_tile.object_type:
                identical_to_previous = true
                break

        if not identical_to_previous:
            grid_manager.RemoveTile(present_tile.Coord, present_tile.Coord)

func _restore_missing_tiles ():
    for last_tile in last_tiles:
        var identical_to_present := false

        var tiles_on_grid: Array = grid_manager.Tiles.duplicate()
        for present_tile in tiles_on_grid: # TODO: Use a dictionary for faster lookup.
            if last_tile.coordinates == present_tile.Coord and last_tile.object_type == present_tile.ObjectType:
                identical_to_present = true
                break

        if not identical_to_present:
            grid_manager.AddTileByObjectType(last_tile.coordinates, last_tile.object_type, false)

func _reset_characters ():
    for character_state in last_characters:
        character_state.character.Coord = character_state.coordinates
        character_state.character.ToggleStuckFeedback(character_state.is_stuck)

        character_state.character.z_index = character_state.coordinates.y + 3

        var new_position: Vector2 = grid_manager.GetCellGlobalPos(character_state.coordinates)
        var walking_time := 0.35
        character_state.character.create_tween() \
            .tween_property(character_state.character, "global_position", new_position, walking_time) \
            .set_trans(Tween.TRANS_CUBIC) \
            .set_ease(Tween.EASE_IN_OUT)

func _reset_background_tiles ():
    for background_tile in grid_manager.TilesBG:
        var tile_at_coordinates: Node2D = grid_manager.GetTileAtCoord(background_tile.Coord) # Actually an ObjectTile

        var locked := false
        if tile_at_coordinates != null:
            if "Locked" in tile_at_coordinates:
                locked = tile_at_coordinates.Locked

        background_tile.ToggleTileLocked(locked)

func _reset_goals ():
    for goal in grid_manager.LevelGoals:
        goal.Current = 0
        for tile in grid_manager.Tiles:
            goal.CheckGoal(tile)

    grid_manager.OnGoalChange.emit(grid_manager.LevelGoals)
