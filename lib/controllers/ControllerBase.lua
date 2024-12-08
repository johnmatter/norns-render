local gamepad = require('gamepad')
local Vector = include('lib/Vector')
local debug = include('lib/util/debug')

ControllerBase = {}
ControllerBase.__index = ControllerBase

function ControllerBase:new()
  local controller = setmetatable({}, ControllerBase)
  controller.movement = { x = 0, y = 0, z = 0 }
  controller.rotation = { x = 0, y = 0, z = 0 }
  controller.move_speed = 0.1
  controller.rotate_speed = 0.1
  controller.orbital_mode = false
  debug.log("ControllerBase:new - Created with movement:", controller.movement, "rotation:", controller.rotation)
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
  debug.log("update_camera movement:", self.movement.x, self.movement.y, self.movement.z)
  debug.log("update_camera rotation:", self.rotation.x, self.rotation.y, self.rotation.z)
  debug.log("update_camera move_speed:", self.move_speed)
  debug.log("update_camera rotate_speed:", self.rotate_speed)
  
  if self.orbital_mode then
    debug.log("Using orbital camera mode")
    -- Calculate movement deltas
    local dx = self.movement.x * self.move_speed
    local dy = self.movement.y * self.move_speed
    local dz = self.movement.z * self.move_speed
    
    debug.log("Calculated deltas:", dx, dy, dz)
    
    return dx, dy, dz
  else
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