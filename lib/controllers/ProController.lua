local ControllerBase = include('lib/controllers/ControllerBase')
local debug = include('lib/util/debug')

ProController = {}
ProController.__index = ProController
setmetatable(ProController, {__index = ControllerBase})

function ProController:new()
  local controller = ControllerBase:new()
  controller.orbital_mode = false  -- Gamepad uses free camera by default
  setmetatable(controller, ProController)
  return controller
end

function ProController:update()
  if not self.connected then return end
  
  -- Convert axis values to input bindings
  local bindings = {}
  
  -- Left stick controls movement
  local left_x = self:read_axis('leftx')
  local left_y = self:read_axis('lefty')
  if left_x ~= 0 then table.insert(bindings, InputBinding:new(InputAction.PAN_X, left_x)) end
  if left_y ~= 0 then table.insert(bindings, InputBinding:new(InputAction.PAN_Z, left_y)) end
  
  -- Right stick controls rotation
  local right_x = self:read_axis('rightx')
  local right_y = self:read_axis('righty')
  if right_x ~= 0 then table.insert(bindings, InputBinding:new(InputAction.ORBIT_HORIZONTAL, right_x)) end
  if right_y ~= 0 then table.insert(bindings, InputBinding:new(InputAction.ORBIT_VERTICAL, right_y)) end
  
  -- Apply all bindings
  for _, binding in ipairs(bindings) do
    self:handle_input_binding(binding)
  end
end

return ProController 