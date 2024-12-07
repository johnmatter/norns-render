local ControllerBase = include('lib/controllers/ControllerBase')

KeyboardController = {}
KeyboardController.__index = KeyboardController
setmetatable(KeyboardController, {__index = ControllerBase})

function KeyboardController:new()
  local controller = ControllerBase:new()
  controller.keys = {
    w = false,
    a = false,
    s = false,
    d = false,
    i = false,
    j = false,
    k = false,
    l = false
  }
  setmetatable(controller, KeyboardController)
  return controller
end

function KeyboardController:key_pressed(key)
  if self.keys[key] ~= nil then
    self.keys[key] = true
    self:update_movement_and_rotation()
  end
end

function KeyboardController:key_released(key)
  if self.keys[key] ~= nil then
    self.keys[key] = false
    self:update_movement_and_rotation()
  end
end

function KeyboardController:update_movement_and_rotation()
  -- Update movement based on WASD
  self.movement.x = (self.keys.d and 1 or 0) - (self.keys.a and 1 or 0)
  self.movement.z = (self.keys.s and 1 or 0) - (self.keys.w and 1 or 0)
  
  -- Update rotation based on IJKL
  -- We'll use a fixed rotation amount when keys are held
  local rotation_amount = 0.1
  self.rotation.x = (self.keys.k and rotation_amount or 0) - (self.keys.i and rotation_amount or 0)
  self.rotation.y = (self.keys.l and rotation_amount or 0) - (self.keys.j and rotation_amount or 0)
end

function KeyboardController:update()
  -- This will be called every frame to maintain continuous movement/rotation
  -- The movement and rotation values are already set by key events
end

return KeyboardController 