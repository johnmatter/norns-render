local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')
local InputMapper = include('lib/input/InputMapper')
local InputAction = include('lib/input/InputAction')

NornsController = {}
NornsController.__index = NornsController
setmetatable(NornsController, {__index = ControllerBase})

function NornsController:new()
  local controller = ControllerBase:new()
  controller.orbital_mode = true
  setmetatable(controller, NornsController)
  controller:setup_orbital_mode_mappings()
  return controller
end

function NornsController:setup_orbital_mode_mappings()
  -- Map Norns keys (digital inputs)
  self.input_mapper:map_digital("key1", 1, InputAction.MODIFIER_K1, 1)
  self.input_mapper:map_digital("key1", 0, InputAction.MODIFIER_K1, 0)
  self.input_mapper:map_digital("key2", 1, InputAction.ORBIT_ZOOM_OUT)
  self.input_mapper:map_digital("key3", 1, InputAction.ORBIT_ZOOM_IN)
  
  -- Add mode toggle when K1+K2+K3 are pressed
  self.input_mapper:map_digital("key1+key2+key3", 1, InputAction.TOGGLE_ORBITAL)
  
  -- Map encoders (analog inputs)
  self.input_mapper:map_analog("enc2", InputAction.ORBIT_HORIZONTAL, 1.0)
  self.input_mapper:map_analog("enc3", InputAction.ORBIT_VERTICAL, 1.0)
end

function NornsController:setup_free_mode_mappings()
  -- Map Norns keys (digital inputs)
  self.input_mapper:map_digital("key1", 1, InputAction.MODIFIER_K1, 1)
  self.input_mapper:map_digital("key1", 0, InputAction.MODIFIER_K1, 0)
  self.input_mapper:map_digital("key2", 1, InputAction.MOVE_BACKWARD)
  self.input_mapper:map_digital("key3", 1, InputAction.MOVE_FORWARD)
  
  -- Map encoders (analog inputs)
  self.input_mapper:map_analog("enc2", InputAction.ROTATE_YAW, 0.1)
  self.input_mapper:map_analog("enc3", InputAction.ROTATE_PITCH, 0.1)
end

function NornsController:key(n, z)
  local binding = self.input_mapper:handle_digital("key" .. n, z)
  if binding then
    self:handle_input_binding(binding)
  end
end

function NornsController:enc(n, d)
  local binding = self.input_mapper:handle_analog("enc" .. n, d)
  if binding then
    self:handle_input_binding(binding)
  end
end

function NornsController:handle_input_binding(binding)
  if not self.camera then return false end
  
  -- Handle mode toggles first
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
  
  -- Forward camera actions to camera
  return self.camera:handle_action(binding.action, binding.value)
end

return NornsController