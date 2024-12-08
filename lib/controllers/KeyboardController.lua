local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

KeyboardController = {}
KeyboardController.__index = KeyboardController
setmetatable(KeyboardController, {__index = ControllerBase})

function KeyboardController:new()
  local controller = ControllerBase:new()
  controller.orbital_mode = true
  controller.keys = {}
  setmetatable(controller, KeyboardController)
  controller:setup_orbital_mode_mappings()
  return controller
end

function KeyboardController:setup_orbital_mode_mappings()
  -- Mode toggle
  self.input_mapper:map_digital("tab", 1, InputAction.TOGGLE_ORBITAL)
  
  -- Movement keys (digital inputs)
  self.input_mapper:map_digital("w", 1, InputAction.ORBIT_ZOOM_IN)
  self.input_mapper:map_digital("s", 1, InputAction.ORBIT_ZOOM_OUT)
  
  -- Rotation keys
  self.input_mapper:map_digital("left", 1, InputAction.ORBIT_HORIZONTAL, -0.1)
  self.input_mapper:map_digital("right", 1, InputAction.ORBIT_HORIZONTAL, 0.1)
  self.input_mapper:map_digital("up", 1, InputAction.ORBIT_VERTICAL, -0.1)
  self.input_mapper:map_digital("down", 1, InputAction.ORBIT_VERTICAL, 0.1)
end

function KeyboardController:setup_free_mode_mappings()
  -- Mode toggle
  self.input_mapper:map_digital("tab", 1, InputAction.TOGGLE_ORBITAL)
  
  -- Movement keys
  self.input_mapper:map_digital("w", 1, InputAction.MOVE_FORWARD)
  self.input_mapper:map_digital("s", 1, InputAction.MOVE_BACKWARD)
  self.input_mapper:map_digital("a", 1, InputAction.MOVE_LEFT)
  self.input_mapper:map_digital("d", 1, InputAction.MOVE_RIGHT)
  
  -- Look keys
  self.input_mapper:map_digital("left", 1, InputAction.ROTATE_YAW, -0.1)
  self.input_mapper:map_digital("right", 1, InputAction.ROTATE_YAW, 0.1)
  self.input_mapper:map_digital("up", 1, InputAction.ROTATE_PITCH, -0.1)
  self.input_mapper:map_digital("down", 1, InputAction.ROTATE_PITCH, 0.1)
end

function KeyboardController:update()
  for key, state in pairs(self.keys) do
    if state then
      local binding = self.input_mapper:handle_digital(key, 1)
      if binding then
        self:handle_input_binding(binding)
      end
    end
  end
end

function KeyboardController:handle_input_binding(binding)
  if not self.camera then return false end
  
  if binding.action == InputAction.TOGGLE_ORBITAL then
    self.orbital_mode = not self.orbital_mode
    if self.orbital_mode then
      self:setup_orbital_mode_mappings()
    else
      self:setup_free_mode_mappings()
    end
    self.camera.orbital_mode = self.orbital_mode
    return true
  end
  
  return self.camera:handle_action(binding.action, binding.value)
end

return KeyboardController 