local gamepad = require('gamepad')

ControllerBase = {}
ControllerBase.__index = ControllerBase

function ControllerBase:new()
  local controller = {
    id = nil,
    connected = false,
    deadzone = 0.1,
    move_speed = 0.5,
    rotate_speed = 0.05,
    movement = { x = 0, y = 0, z = 0 },
    rotation = { x = 0, y = 0 },
    axes = {
      left_x = 0,
      left_y = 0,
      right_x = 0,
      right_y = 0
    }
  }
  setmetatable(controller, self)
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

function ControllerBase:update_camera(camera, camera_rotation)
  -- Update camera rotation
  camera_rotation.y = camera_rotation.y + (self.rotation.y * self.rotate_speed)
  camera_rotation.x = util.clamp(
    camera_rotation.x + (self.rotation.x * self.rotate_speed),
    -math.pi/2,
    math.pi/2
  )
  
  -- Calculate movement vectors
  local forward_x = math.sin(camera_rotation.y)
  local forward_z = math.cos(camera_rotation.y)
  local right_x = math.cos(camera_rotation.y)
  local right_z = -math.sin(camera_rotation.y)
  
  -- Calculate movement deltas
  local dx = (right_x * self.movement.x - forward_x * self.movement.z) * self.move_speed
  local dz = (right_z * self.movement.x - forward_z * self.movement.z) * self.move_speed
  
  return dx, dz
end

function ControllerBase:poll()
  -- Base implementation does nothing
  -- Override in derived controllers if needed
end

return ControllerBase 