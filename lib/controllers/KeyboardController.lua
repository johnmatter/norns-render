local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

KeyboardController = {}
KeyboardController.__index = KeyboardController
setmetatable(KeyboardController, {__index = ControllerBase})

function KeyboardController:new()
  local controller = ControllerBase:new()
  controller.keys = {
    w = false, a = false, s = false, d = false,  -- Movement
    i = false, j = false, k = false, l = false,  -- Rotation
    q = false, e = false                         -- Vertical movement
  }
  controller.orbital_mode = false  -- Keyboard uses free camera by default
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
  -- Convert key states to input bindings
  local bindings = {}
  
  -- Movement bindings
  if self.keys.w then table.insert(bindings, InputBinding:new(InputAction.PAN_Z, -1)) end
  if self.keys.s then table.insert(bindings, InputBinding:new(InputAction.PAN_Z, 1)) end
  if self.keys.a then table.insert(bindings, InputBinding:new(InputAction.PAN_X, -1)) end
  if self.keys.d then table.insert(bindings, InputBinding:new(InputAction.PAN_X, 1)) end
  if self.keys.q then table.insert(bindings, InputBinding:new(InputAction.PAN_Y, -1)) end
  if self.keys.e then table.insert(bindings, InputBinding:new(InputAction.PAN_Y, 1)) end
  
  -- Rotation bindings
  if self.keys.i then table.insert(bindings, InputBinding:new(InputAction.ORBIT_VERTICAL, -0.1)) end
  if self.keys.k then table.insert(bindings, InputBinding:new(InputAction.ORBIT_VERTICAL, 0.1)) end
  if self.keys.j then table.insert(bindings, InputBinding:new(InputAction.ORBIT_HORIZONTAL, -0.1)) end
  if self.keys.l then table.insert(bindings, InputBinding:new(InputAction.ORBIT_HORIZONTAL, 0.1)) end
  
  -- Apply all bindings
  for _, binding in ipairs(bindings) do
    self:handle_input_binding(binding)
  end
end

return KeyboardController 