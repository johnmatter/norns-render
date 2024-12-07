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
  
  -- Map Pro Controller specific axes
  self.axes.left_x = self:apply_deadzone(gamepad.axis(self.id, 'leftx'))
  self.axes.left_y = self:apply_deadzone(gamepad.axis(self.id, 'lefty'))
  self.axes.right_x = self:apply_deadzone(gamepad.axis(self.id, 'rightx'))
  self.axes.right_y = self:apply_deadzone(gamepad.axis(self.id, 'righty'))
end

return ProController 