extends Node

# User: Basic Information
var ID = 0
var NAME = ""

# User: Game Information
var isHost = false
var isOwned = false
var isOnline = false


# Start Steamworks
func _ready() -> void:
	_initialize_Steam()

# Process all Steamworks callbacks
func _process(_delta: float) -> void:
	Steam.run_callbacks()


# Initializing Steamworks
func _initialize_Steam() -> void:

	# Get the initialization dictionary from Steam
	var INIT: Dictionary = Steam.steamInit()

	# If the status isn't one, print out the possible error and quit the program
	if INIT['status'] != 1:
		print("[STEAM] Failed to initialize: " + str(INIT['verbal']) + " Shutting down...")
		get_tree().quit()

	# Fill in User Information
	ID = Steam.getSteamID()
	NAME = Steam.getPersonaName()
	isOwned = Steam.isSubscribed()
	isOnline = Steam.loggedOn()

	# Check if account owns the game
	if isOwned == false:
		print("[STEAM] User does not own this game")
		# Uncomment this line to close the game if the user does not own the game
		# get_tree().quit()
