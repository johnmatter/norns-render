local gamepad = require('gamepad')
local Vector = include('lib/Vector')
local debug = include('lib/util/debug')
local InputMapper = include('lib/input/InputMapper')
local InputAction = include('lib/input/InputAction')

ControllerBase = {}
ControllerBase.__index = ControllerBase

function ControllerBase:new()
  local controller = {
    camera = nil,
    input_mapper = InputMapper:new(),
    orbital_mode = true
  }
  setmetatable(controller, ControllerBase)
  return controller
end

function ControllerBase:connect(id)
  self.id = id
  self.connected = true
end

function ControllerBase:disconnect()
  self.id = nil
  self.connected = false
end

function ControllerBase:apply_deadzone(value)
  return math.abs(value) > self.deadzone and value or 0
end

function ControllerBase:read_axis(axis_name)
  if not self.id then return 0 end
  
  local success, value = pcall(function()
    return gamepad.axis(self.id, axis_name)
  end)
  
  if success then
    return self:apply_deadzone(value)
  else
    return 0
  end
end

function ControllerBase:poll()
  -- Base implementation does nothing
  -- Override in derived controllers if needed
end

function ControllerBase:handle_input_binding(binding)
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

return ControllerBase 