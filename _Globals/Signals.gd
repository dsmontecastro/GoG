extends Node


# Global -------------------------------------------------------------------- #

signal warning(message)


# Menu ---------------------------------------------------------------------- #

signal play(message)
signal exit_opts


# Game ---------------------------------------------------------------------- #

signal setup_reset
signal setup_finished

signal game_over(win)


signal move()	# During Game Proper
signal drop()	# During Setup

signal done_killing
signal done_moving
