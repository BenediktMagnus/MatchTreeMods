extends Node

const DebugSaveManager := preload("res://mods/debugMod/debug_save_manager.gd")

func _init ():
    SaveManager.set_script(DebugSaveManager)
