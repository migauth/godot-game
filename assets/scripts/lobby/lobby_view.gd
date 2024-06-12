extends Control

class_name LobbyView

@onready var _join_panel = $Join
@onready var _host_panel = $Host
@onready var _select_panel = $Select


func _ready():
	show_select()
	

func show_select():
	_host_panel.visible = false
	_join_panel.visible = false
	_select_panel.visible = true

	
func show_host():
	_host_panel.visible = true
	_join_panel.visible = false
	_select_panel.visible = false
	
	
func show_join():
	_host_panel.visible = false
	_join_panel.visible = true
	_select_panel.visible = false
