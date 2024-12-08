local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

-- Add debug flag
local DEBUG = true

NornsController = {}
NornsController.__index = NornsController
setmetatable(NornsController, {__index = ControllerBase})

function NornsController:new()
  local controller = ControllerBase:new()
  controller.k2_held = false
  controller.k3_held = false
  controller.orbital_radius = 20  -- Distance from origin
  controller.orbital_angle = 0    -- Angle around Y axis
  controller.height = 0           -- Height above origin
  if DEBUG then debug.log("NornsController:new() created") end
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  if DEBUG then debug.log("NornsController:key()", n, z) end
  if n == 2 then
    self.k2_held = z == 1
  elseif n == 3 then
    self.k3_held = z == 1
  end
  
  -- Update forward/backward movement
  self.movement.z = (self.k2_held and -1 or 0) + (self.k3_held and 1 or 0)
  if DEBUG then debug.log("movement.z updated to:", self.movement.z) end
end

function NornsController:enc(n, d)
  if DEBUG then debug.log("NornsController:enc()", n, d) end
  if n == 2 then
    -- Rotate around origin
    self.orbital_angle = self.orbital_angle + (d * 0.1)
    if DEBUG then debug.log("orbital_angle updated to:", self.orbital_angle) end
  elseif n == 3 then
    -- Adjust orbital radius instead of height
    self.orbital_radius = util.clamp(self.orbital_radius + (d * 0.5), 5, 40)
    if DEBUG then debug.log("orbital_radius updated to:", self.orbital_radius) end
  end
end

function NornsController:poll()
  if (self.k2_held or self.k3_held) and DEBUG then
    debug.log("NornsController:poll() - keys held:", self.k2_held, self.k3_held)
  end
end

function NornsController:update_camera(camera, camera_rotation)
  -- Calculate camera position based on orbital parameters
  camera.x = math.sin(self.orbital_angle) * self.orbital_radius
  camera.y = self.height
  camera.z = math.cos(self.orbital_angle) * self.orbital_radius
  
  -- Calculate direction to origin for camera rotation
  local dx = -camera.x
  local dy = -camera.y
  local dz = -camera.z
  local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
  
  -- Update camera rotation to look at origin
  camera_rotation.y = math.atan2(dx, dz)
  camera_rotation.x = -math.asin(dy/distance)
  
  -- Get movement deltas from base class
  return ControllerBase.update_camera(self, camera, camera_rotation)
end

return NornsController