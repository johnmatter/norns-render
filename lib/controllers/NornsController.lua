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
  setmetatable(controller, NornsController)
  return controller
end

function NornsController:key(n, z)
  if n == 1 then
    self.k1_held = z == 1
  elseif n == 2 then
    self.k2_held = z == 1
  elseif n == 3 then
    self.k3_held = z == 1
  end
  
  -- Update rotation/movement based on key states
  if self.k1_held then
    self.rotation.y = (self.k2_held and -1 or 0) + (self.k3_held and 1 or 0)
  else
    self.movement.z = (self.k2_held and -1 or 0) + (self.k3_held and 1 or 0)
  end
end

return NornsController