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
  PRECISION = "precision"
}

return InputAction 