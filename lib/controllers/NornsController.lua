local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')
local InputMapper = include('lib/input/InputMapper')
local InputAction = include('lib/input/InputAction')

NornsController = {}
NornsController.__index = NornsController
setmetatable(NornsController, {__index = ControllerBase})

function NornsController:new()
  local controller = ControllerBase:new()
  controller.input_mapper = InputMapper:new()
  controller.input_mapper:map_norns_controls()
  controller.orbital_mode = true
  controller.camera = nil  -- Will be set by update_camera
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  local binding = self.input_mapper:handle_key(n, z)
  if binding then
    self:handle_input_binding(binding)
    return true
  end
  return false
end

function NornsController:enc(n, d)
  local binding = self.input_mapper:handle_encoder(n, d)
  if binding then
    self:handle_input_binding(binding)
    return true
  end
  return false
end

function NornsController:handle_input_binding(binding)
  if not self.camera then return false end
  
  -- Handle mode toggles first
  if binding.action == InputAction.TOGGLE_ORBITAL then
    self.orbital_mode = not self.orbital_mode
    return true
  end
  
  -- Forward camera actions to camera and return movement deltas
  if self.camera:handle_action(binding.action, binding.value) then
    -- Return actual position changes
    return self.camera.position.x - self.last_x,
           self.camera.position.y - self.last_y,
           self.camera.position.z - self.last_z
  end
  return 0, 0, 0
end

function NornsController:update_camera(camera)
  if not self.last_x then
    self.last_x = camera.position.x
    self.last_y = camera.position.y
    self.last_z = camera.position.z
  end
  self.camera = camera
  return 0, 0, 0
end

return NornsController