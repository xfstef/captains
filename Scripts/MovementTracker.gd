extends Node2D

var tile_x
var tile_y
var enabled = true
var m_t_e
var m_t_d

func _ready():
	m_t_e = get_node("MoveTrackerEnabled")
	m_t_d = get_node("MoveTrackerDisabled")

func setTrackerIndex(x):
	m_t_e.frame = x
	m_t_d.frame = x

func setEnabled(new_value):
	enabled = new_value
	if enabled == true:
		m_t_e.visible = true
		m_t_d.visible = false
	else:
		m_t_e.visible = false
		m_t_d.visible = true
