local gamepad = require('gamepad')
local Vector = include('lib/Vector')
local debug = include('lib/util/debug')

ControllerBase = {}
ControllerBase.__index = ControllerBase

function ControllerBase:new()
  local controller = setmetatable({}, ControllerBase)
  controller.orbital_mode = false
  controller.camera = nil
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
  -- Base implementation forwards to camera
  if self.camera then
    return self.camera:handle_action(binding.action, binding.value)
  end
  return false
end

return ControllerBase 