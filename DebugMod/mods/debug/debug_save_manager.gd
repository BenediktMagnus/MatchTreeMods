extends SaveManager

const SAFE_FILE := "MatchTree.sav" # HACK: NO idea why it can find SAVE_DIR from SaveManager but not SAFE_FILE...
const UNENCRYPTED_SAFE_FILE := SAFE_FILE + ".json"

func _init ():
    # NOTE: Before this here, the SaveManager already tried to load the save game.

    UseEncryption = false

    var directory := DirAccess.open(SAVE_DIR)

    if directory.file_exists(UNENCRYPTED_SAFE_FILE):
        load_game()
    else:
        save_game()

func save_game ():
    super()

    var directory := DirAccess.open(SAVE_DIR)
    directory.rename(SAFE_FILE, UNENCRYPTED_SAFE_FILE)

func load_game ():
    var directory := DirAccess.open(SAVE_DIR)

    if directory.file_exists(UNENCRYPTED_SAFE_FILE):
        directory.rename(UNENCRYPTED_SAFE_FILE, SAFE_FILE)

    super()

    directory.rename(SAFE_FILE, UNENCRYPTED_SAFE_FILE)
