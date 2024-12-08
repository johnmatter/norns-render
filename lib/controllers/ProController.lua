local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

ProController = {}
ProController.__index = ProController
setmetatable(ProController, {__index = ControllerBase})

function ProController:new()
  local controller = ControllerBase:new()
  controller.orbital_mode = true
  setmetatable(controller, ProController)
  controller:setup_orbital_mode_mappings()
  return controller
end

function ProController:setup_orbital_mode_mappings()
  -- Mode toggle
  self.input_mapper:map_digital("start", 1, InputAction.TOGGLE_ORBITAL)
  
  -- Left stick (analog inputs)
  self.input_mapper:map_analog("leftx", InputAction.PAN_X, 1.0)
  self.input_mapper:map_analog("lefty", InputAction.PAN_Z, 1.0)
  
  -- Right stick (analog inputs)
  self.input_mapper:map_analog("rightx", InputAction.ORBIT_HORIZONTAL, 1.0)
  self.input_mapper:map_analog("righty", InputAction.ORBIT_VERTICAL, 1.0)
  
  -- Triggers
  self.input_mapper:map_analog("triggerleft", InputAction.ORBIT_ZOOM_OUT, 1.0)
  self.input_mapper:map_analog("triggerright", InputAction.ORBIT_ZOOM_IN, 1.0)
end

function ProController:setup_free_mode_mappings()
  -- Mode toggle
  self.input_mapper:map_digital("start", 1, InputAction.TOGGLE_ORBITAL)
  
  -- Left stick (analog inputs)
  self.input_mapper:map_analog("leftx", InputAction.MOVE_RIGHT, 1.0)
  self.input_mapper:map_analog("lefty", InputAction.MOVE_FORWARD, -1.0)
  
  -- Right stick (analog inputs)
  self.input_mapper:map_analog("rightx", InputAction.ROTATE_YAW, 1.0)
  self.input_mapper:map_analog("righty", InputAction.ROTATE_PITCH, 1.0)
end

function ProController:update()
  if not self.connected then return end
  
  -- Handle analog inputs
  for axis, value in pairs(self:read_axes()) do
    if math.abs(value) > 0.1 then -- Add deadzone
      local binding = self.input_mapper:handle_analog(axis, value)
      if binding then
        self:handle_input_binding(binding)
      end
    end
  end
end

function ProController:handle_input_binding(binding)
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

return ProController 