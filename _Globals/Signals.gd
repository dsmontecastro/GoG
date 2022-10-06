extends Node


# Global -------------------------------------------------------------------- #

signal warning(message)
signal reset


# Menu ---------------------------------------------------------------------- #

signal play(message)
signal exit_opts


# Game Signals -------------------------------------------------------------- #

signal send
signal read


# Game Setup ---------------------------------------------------------------- #

signal setup_reset
signal setup_ready(val)
signal setup_finished


# Game Proper --------------------------------------------------------------- #

signal game_play
signal game_over(win)

signal move()	# During Game Proper
signal drop()	# During Setup

signal done_killing
signal done_moving
