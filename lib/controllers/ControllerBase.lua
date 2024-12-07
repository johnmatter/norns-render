ControllerBase = {}
ControllerBase.__index = ControllerBase

function ControllerBase:new()
  local controller = {
    id = nil,
    connected = false,
    deadzone = 0.1,
    move_speed = 0.5,
    rotate_speed = 0.05,
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

function ControllerBase:update_camera(camera, camera_rotation)
  if not self.connected then return end
  
  -- Update camera rotation (right stick)
  camera_rotation.y = camera_rotation.y + (self.axes.right_x * self.rotate_speed)
  camera_rotation.x = util.clamp(
    camera_rotation.x + (self.axes.right_y * self.rotate_speed),
    -math.pi/2,
    math.pi/2
  )
  
  -- Calculate movement vectors
  local forward_x = math.sin(camera_rotation.y)
  local forward_z = math.cos(camera_rotation.y)
  local right_x = math.cos(camera_rotation.y)
  local right_z = -math.sin(camera_rotation.y)
  
  -- Update camera position (left stick)
  local dx = (right_x * self.axes.left_x - forward_x * self.axes.left_y) * self.move_speed
  local dz = (right_z * self.axes.left_x - forward_z * self.axes.left_y) * self.move_speed
  
  return dx, dz
end

return ControllerBase 