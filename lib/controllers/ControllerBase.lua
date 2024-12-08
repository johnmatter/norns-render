local gamepad = require('gamepad')
local Vector = include('lib/Vector')

ControllerBase = {}
ControllerBase.__index = ControllerBase

function ControllerBase:new()
  local controller = {
    id = nil,
    connected = false,
    deadzone = 0.1,
    move_speed = 0.5,
    rotate_speed = 0.05,
    movement = Vector:new(0, 0, 0),
    rotation = Vector:new(0, 0, 0),
    orbital_mode = false,
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

function ControllerBase:update_camera(camera)
  if self.orbital_mode then
    return self:update_orbital_camera(camera)
  else
    return self:update_free_camera(camera)
  end
end

function ControllerBase:update_free_camera(camera)
  -- Update camera rotation
  local rot_x, rot_y = camera:get_rotation()
  rot_y = rot_y + (self.rotation.y * self.rotate_speed)
  rot_x = util.clamp(
    rot_x + (self.rotation.x * self.rotate_speed),
    -math.pi/2,
    math.pi/2
  )
  camera:set_rotation(rot_x, rot_y, 0)
  
  -- Calculate movement vectors based on camera rotation
  local forward_x = math.sin(rot_y)
  local forward_z = math.cos(rot_y)
  local right_x = math.cos(rot_y)
  local right_z = -math.sin(rot_y)
  
  -- Calculate movement deltas
  local dx = (right_x * self.movement.x - forward_x * self.movement.z) * self.move_speed
  local dy = self.movement.y * self.move_speed
  local dz = (right_z * self.movement.x - forward_z * self.movement.z) * self.move_speed
  
  return dx, dy, dz
end

function ControllerBase:update_orbital_camera(camera)
  if self.rotation.y ~= 0 then
    camera.azimuth = camera.azimuth + (self.rotation.y * self.rotate_speed)
  end
  
  if self.rotation.x ~= 0 then
    camera.elevation = util.clamp(
      camera.elevation + (self.rotation.x * self.rotate_speed),
      -math.pi/2 + 0.1,
      math.pi/2 - 0.1
    )
  end
  
  camera:update_from_orbital()
  return 0, 0, 0  -- No direct position changes in orbital mode
end

function ControllerBase:poll()
  -- Base implementation does nothing
  -- Override in derived controllers if needed
end

return ControllerBase 