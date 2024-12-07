local InputController = {}
InputController.__index = InputController

function InputController:new()
  local controller = {
    move_speed = 0.5,
    rotate_speed = 0.05,
    movement = { x = 0, y = 0, z = 0 },
    rotation = { x = 0, y = 0 }
  }
  setmetatable(controller, self)
  return controller
end

function InputController:update_camera(camera, camera_rotation)
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

return InputController 