local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

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
  debug.log("NornsController:new() created")
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  debug.log("NornsController:key()", n, z)
  if n == 2 then
    self.k2_held = z == 1
  elseif n == 3 then
    self.k3_held = z == 1
  end
  
  -- Update forward/backward movement
  self.movement.z = (self.k2_held and -1 or 0) + (self.k3_held and 1 or 0)
  debug.log("movement.z updated to:", self.movement.z)
end

function NornsController:enc(n, d)
  debug.log("NornsController:enc()", n, d)
  if n == 2 then
    -- Rotate around origin
    self.orbital_angle = self.orbital_angle + (d * 0.1)
    debug.log("orbital_angle updated to:", self.orbital_angle)
  elseif n == 3 then
    -- Adjust height
    self.height = util.clamp(self.height + (d * 0.5), -20, 20)
    debug.log("height updated to:", self.height)
  end
end

function NornsController:poll()
  if self.k2_held or self.k3_held then
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
  
  return 0, 0  -- No additional movement needed
end

return NornsController 