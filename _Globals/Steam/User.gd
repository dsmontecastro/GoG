extends Node

# User Information
var ID = 0
var NAME = ""

# Basic Information
var isOwned = false
var isOnline = false

# Game Information
var HOSTING = false
var READIED = false
var IN_GAME = false
var IS_TURN = false


# Initialize Steamworks
func _ready():

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

# Initial User Values
func _reset():
	HOSTING = false
	READIED = false
	IN_GAME = false
	IS_TURN = false
