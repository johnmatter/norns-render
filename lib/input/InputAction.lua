-- Enumeration of all possible input actions
InputAction = {
  -- Camera Movement
  ORBIT_HORIZONTAL = "orbit_horizontal",
  ORBIT_VERTICAL = "orbit_vertical",
  ZOOM = "zoom",
  PAN_X = "pan_x",
  PAN_Y = "pan_y",
  PAN_Z = "pan_z",
  
  -- Camera Modes
  TOGGLE_ORBITAL = "toggle_orbital",
  TOGGLE_FREE = "toggle_free",
  
  -- Object Control
  ROTATE_X = "rotate_x",
  ROTATE_Y = "rotate_y",
  ROTATE_Z = "rotate_z",
  SCALE = "scale",
  
  -- Modifiers
  MODIFIER_K1 = "modifier_k1",
  MODIFIER_K2 = "modifier_k2",
  MODIFIER_K3 = "modifier_k3",
  PRECISION = "precision",
  
  -- Movement
  MOVE_RIGHT = "move_right",
  MOVE_FORWARD = "move_forward",
  ROTATE_YAW = "rotate_yaw",
  ROTATE_PITCH = "rotate_pitch",
  
  -- Zoom
  ORBIT_ZOOM_OUT = "orbit_zoom_out",
  ORBIT_ZOOM_IN = "orbit_zoom_in",
  ORBIT_ZOOM = "orbit_zoom",
  
  -- Macro actions for script-specific functionality
  MACRO_1 = "macro_1",
  MACRO_2 = "macro_2",
  MACRO_3 = "macro_3",
  MACRO_4 = "macro_4",
  
  -- Shape control
  CYCLE_SHAPE = "cycle_shape",
  RANDOM_ROTATE = "random_rotate"
}

return InputAction 