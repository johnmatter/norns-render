local ControllerBase = include('lib/controllers/ControllerBase')

NornsController = {}
NornsController.__index = NornsController
setmetatable(NornsController, {__index = ControllerBase})

function NornsController:new()
  local controller = ControllerBase:new()
  controller.k2_held = false
  controller.k3_held = false
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  if n == 2 then
    self.k2_held = z == 1
  elseif n == 3 then
    self.k3_held = z == 1
  end
  
  -- Update forward/backward movement
  self.movement.z = (self.k2_held and -1 or 0) + (self.k3_held and 1 or 0)
end

function NornsController:enc(n, d)
  if n == 2 then
    self.rotation.y = d * 0.1  -- Yaw
  elseif n == 3 then
    self.rotation.x = d * 0.1  -- Pitch
  end
end

return NornsController 