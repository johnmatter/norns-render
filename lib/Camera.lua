local debug = include('lib/util/debug')
local util = include('lib/util/utils')

Camera = {}
Camera.__index = Camera

function Camera:new(x, y, z)
  local camera = {
    position = { x = x or 0, y = y or 0, z = z or -10 },
    orbital_mode = true,
    
    -- Orbital parameters
    orbital_radius = 10,
    azimuth = 0,   -- Horizontal angle in radians
    elevation = 0, -- Vertical angle in radians
    
    -- Free camera parameters
    yaw = 0,
    pitch = 0,
    
    -- Movement constraints
    min_radius = 5,
    max_radius = 50,
    move_speed = 0.5,
    rotate_speed = 0.05
  }
  setmetatable(camera, Camera)
  return camera
end

function Camera:handle_action(action, value)
  if self.orbital_mode then
    return self:handle_orbital_action(action, value)
  else
    return self:handle_free_action(action, value)
  end
end

function Camera:handle_orbital_action(action, value)
  debug.log("Camera:handle_orbital_action called with action:", action, "value:", value)
  
  if action == InputAction.ORBIT_HORIZONTAL then
    self.azimuth = util.normalize_angle(self.azimuth + value * self.rotate_speed)
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_VERTICAL then
    self.elevation = util.clamp(self.elevation + value * self.rotate_speed, -math.pi/2, math.pi/2)
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_ZOOM_IN then
    self.orbital_radius = util.clamp(self.orbital_radius - self.move_speed, self.min_radius, self.max_radius)
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_ZOOM_OUT then
    self.orbital_radius = util.clamp(self.orbital_radius + self.move_speed, self.min_radius, self.max_radius)
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_ZOOM then
    self.orbital_radius = util.clamp(self.orbital_radius + value * self.move_speed, self.min_radius, self.max_radius)
    self:update_from_orbital()
    return true
  end
  return false
end

function Camera:update_from_orbital()
  -- Convert spherical coordinates to Cartesian
  self.position.x = self.orbital_radius * math.cos(self.elevation) * math.sin(self.azimuth)
  self.position.y = self.orbital_radius * math.sin(self.elevation)
  self.position.z = self.orbital_radius * math.cos(self.elevation) * math.cos(self.azimuth)
  
  debug.log("Camera updated position to:", self.position.x, self.position.y, self.position.z)
end

function Camera:handle_free_action(action, value)
  -- Implement free camera controls if needed
  debug.log("Camera:handle_free_action called with action:", action, "value:", value)
  return false
end

function Camera:update_render_state()
  -- Update any necessary render state based on the camera's new position
  -- This could include recalculating view matrices or other transformations
  debug.log("Camera:update_render_state called")
end

return Camera