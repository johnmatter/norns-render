local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

-- Add debug flag
local DEBUG = true

NornsController = {}
NornsController.__index = NornsController
setmetatable(NornsController, {__index = ControllerBase})

function NornsController:new()
  local controller = ControllerBase:new()
  controller.k1_held = false
  controller.k2_held = false
  controller.k3_held = false
  controller.orbital_radius = 20    -- Distance from origin
  controller.azimuth = 0           -- Horizontal angle around Y axis
  controller.elevation = 0         -- Vertical angle from XZ plane
  if DEBUG then debug.log("NornsController:new() created") end
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  if DEBUG then debug.log("NornsController:key()", n, z) end
  if n == 1 then
    self.k1_held = z == 1
  elseif n == 2 then
    self.k2_held = z == 1
  elseif n == 3 then
    self.k3_held = z == 1
  end
  
  -- Only update movement if K1 is not held
  if not self.k1_held then
    self.movement.z = (self.k2_held and -1 or 0) + (self.k3_held and 1 or 0)
    if DEBUG then debug.log("movement.z updated to:", self.movement.z) end
  end
end

function NornsController:poll()
  if (self.k2_held or self.k3_held) and DEBUG then
    debug.log("NornsController:poll() - keys held:", self.k2_held, self.k3_held)
  end
end

function NornsController:update_camera(camera, camera_rotation)
  -- If K1 is held, update azimuth/elevation based on K2/K3
  if self.k1_held then
    local rotation_speed = 0.1
    if self.k2_held then
      self.azimuth = self.azimuth - rotation_speed  -- Rotate left
    elseif self.k3_held then
      self.azimuth = self.azimuth + rotation_speed  -- Rotate right
    end
    
    -- Clamp elevation to avoid gimbal lock
    if self.k2_held and self.k3_held then
      self.elevation = util.clamp(self.elevation + rotation_speed, -math.pi/2 + 0.1, math.pi/2 - 0.1)
    end
  end

  -- Calculate camera position using spherical coordinates
  local cos_elevation = math.cos(self.elevation)
  camera.x = math.sin(self.azimuth) * cos_elevation * self.orbital_radius
  camera.y = math.sin(self.elevation) * self.orbital_radius
  camera.z = math.cos(self.azimuth) * cos_elevation * self.orbital_radius
  
  -- Update camera rotation to look at origin
  camera_rotation.y = self.azimuth + math.pi  -- Add pi to face center
  camera_rotation.x = -self.elevation
  
  if DEBUG then 
    debug.log("Camera position updated to:", camera.x, camera.y, camera.z)
    debug.log("Camera rotation updated to:", camera_rotation.x, camera_rotation.y)
  end
  
  -- Calculate forward vector for movement (only used when K1 is not held)
  local forward_x = -math.sin(self.azimuth) * math.cos(self.elevation)
  local forward_y = -math.sin(self.elevation)
  local forward_z = -math.cos(self.azimuth) * math.cos(self.elevation)
  
  -- Return movement based on key presses and camera orientation
  local move_speed = 0.5
  local move = self.movement.z * move_speed
  return forward_x * move, forward_y * move, forward_z * move
end

return NornsController