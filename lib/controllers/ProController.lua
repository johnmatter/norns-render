local ControllerBase = include('lib/controllers/ControllerBase')

ProController = {}
ProController.__index = ProController
setmetatable(ProController, {__index = ControllerBase})

function ProController:new()
  local controller = ControllerBase:new()
  setmetatable(controller, ProController)
  return controller
end

function ProController:update()
  if not self.connected then return end
  
  -- Update axes
  self.axes.left_x = self:read_axis('leftx')
  self.axes.left_y = self:read_axis('lefty')
  self.axes.right_x = self:read_axis('rightx')
  self.axes.right_y = self:read_axis('righty')
  
  -- Map axes to movement and rotation
  self.movement.x = self.axes.left_x
  self.movement.z = self.axes.left_y
  self.rotation.y = self.axes.right_x
  self.rotation.x = self.axes.right_y
end

return ProController 