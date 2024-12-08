local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

NornsController = {}
NornsController.__index = NornsController
setmetatable(NornsController, {__index = ControllerBase})

function NornsController:new()
  local controller = ControllerBase:new()
  controller.k1_held = false
  controller.k2_held = false
  controller.k3_held = false
  controller.orbital_mode = true  -- Norns uses orbital by default
  controller.move_speed = 1.0    -- Add explicit move speed
  controller.rotate_speed = 0.1  -- Add explicit rotate speed
  debug.log("NornsController:new - move_speed:", controller.move_speed, "rotate_speed:", controller.rotate_speed)
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  debug.log("NornsController:key", n, z)
  if n == 1 then
    self.k1_held = z == 1
  elseif n == 2 then
    self.k2_held = z == 1
  elseif n == 3 then
    self.k3_held = z == 1
  end
  
  debug.log("Key states - k1:", self.k1_held, "k2:", self.k2_held, "k3:", self.k3_held)
  
  self.zoom_speed = (self.k2_held and -0.5 or 0) + (self.k3_held and 0.5 or 0)
  debug.log("Updated zoom_speed to:", self.zoom_speed)
end

function NornsController:enc(n, d)
  self.orbit_speed = (self.k2_held and -0.1 or 0) + (self.k3_held and 0.1 or 0)
  debug.log("Updated orbit_speed to:", self.orbit_speed)
end

function NornsController:update_camera(camera)
  if self.orbit_speed and self.orbit_speed ~= 0 then
    camera:orbit_horizontal(self.orbit_speed)
  end
  if self.zoom_speed and self.zoom_speed ~= 0 then
    camera:zoom(self.zoom_speed)
  end
  return 0, 0, 0  -- No direct position changes
end

return NornsController