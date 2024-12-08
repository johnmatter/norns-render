local Vector = include('lib/Vector')
local debug = include('lib/util/debug')

Camera = {}
Camera.__index = Camera

function Camera:new(x, y, z)
  local camera = {
    position = Vector:new(x or 0, y or 0, z or 0),
    rotation = Vector:new(0, 0, 0),
    orbital_radius = 20,    -- For orbital camera mode
    azimuth = 0,           -- Horizontal angle
    elevation = 0,         -- Vertical angle
    min_radius = 5,        -- Minimum zoom distance
    max_radius = 50,       -- Maximum zoom distance
    rotate_speed = 0.1,    -- Speed for all rotations (both orbital and free)
    move_speed = 0.5      -- Speed for all movements (both orbital and free)
  }
  setmetatable(camera, self)
  return camera
end

function Camera:handle_action(action, value)
  local position_changed = false
  
  if action == InputAction.ORBIT_HORIZONTAL then
    self.azimuth = self.azimuth + (value * self.rotate_speed)
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_VERTICAL then
    self.elevation = util.clamp(
      self.elevation + (value * self.rotate_speed),
      -math.pi/2 + 0.1,
      math.pi/2 - 0.1
    )
    self:update_from_orbital()
    return true
  elseif action == InputAction.ZOOM then
    self.orbital_radius = util.clamp(
      self.orbital_radius + (value * self.move_speed),
      self.min_radius,
      self.max_radius
    )
    self:update_from_orbital()
    return true
  elseif action == InputAction.PAN_X then
    self.position.x = self.position.x + (value * self.move_speed)
    position_changed = true
  elseif action == InputAction.PAN_Y then
    self.position.y = self.position.y + (value * self.move_speed)
    position_changed = true
  elseif action == InputAction.PAN_Z then
    self.position.z = self.position.z + (value * self.move_speed)
    position_changed = true
  end
  
  if position_changed then
    -- Notify that camera position changed
    debug.log("Camera position updated to:", self.position.x, self.position.y, self.position.z)
    return true
  end
  return false
end

function Camera:set_position(x, y, z)
  self.position.x = x
  self.position.y = y
  self.position.z = z
end

function Camera:get_position()
  return self.position.x, self.position.y, self.position.z
end

function Camera:set_rotation(x, y, z)
  self.rotation.x = x
  self.rotation.y = y
  self.rotation.z = z
end

function Camera:get_rotation()
  return self.rotation.x, self.rotation.y, self.rotation.z
end

function Camera:set_orbital_params(radius, azimuth, elevation)
  self.orbital_radius = radius
  self.azimuth = azimuth
  self.elevation = elevation
  self:update_from_orbital()
end

function Camera:update_from_orbital()
  local cos_elevation = math.cos(self.elevation)
  self.position.x = math.sin(self.azimuth) * cos_elevation * self.orbital_radius
  self.position.y = math.sin(self.elevation) * self.orbital_radius
  self.position.z = math.cos(self.azimuth) * cos_elevation * self.orbital_radius
  
  -- Update rotation to look at origin
  self.rotation.y = self.azimuth + math.pi
  self.rotation.x = -self.elevation
end

function Camera:get_view_matrix()
  return {
    { 1, 0, 0, -self.position.x },
    { 0, 1, 0, -self.position.y },
    { 0, 0, 1, -self.position.z },
    { 0, 0, 0, 1 }
  }
end

function Camera:move_free(dx, dy, dz, rotation)
    -- Update camera rotation
    local rot_x, rot_y = self:get_rotation()
    rot_y = rot_y + (rotation.y * self.rotate_speed)
    rot_x = util.clamp(
        rot_x + (rotation.x * self.rotate_speed),
        -math.pi/2,
        math.pi/2
    )
    self:set_rotation(rot_x, rot_y, 0)
    
    -- Calculate movement vectors based on camera rotation
    local forward_x = math.sin(rot_y)
    local forward_z = math.cos(rot_y)
    local right_x = math.cos(rot_y)
    local right_z = -math.sin(rot_y)
    
    -- Calculate and apply movement deltas
    local move_dx = (right_x * dx - forward_x * dz) * self.move_speed
    local move_dy = dy * self.move_speed
    local move_dz = (right_z * dx - forward_z * dz) * self.move_speed
    
    self:set_position(
        self.position.x + move_dx,
        self.position.y + move_dy,
        self.position.z + move_dz
    )
end

function Camera:move_orbital(dx, dy, dz, rotation)
    if rotation.y ~= 0 then
        self.azimuth = self.azimuth + (rotation.y * self.rotate_speed)
    end
    
    if rotation.x ~= 0 then
        self.elevation = util.clamp(
            self.elevation + (rotation.x * self.rotate_speed),
            -math.pi/2 + 0.1,
            math.pi/2 - 0.1
        )
    end
    
    self:update_from_orbital()
end

function Camera:needs_redraw()
  -- Compare current position/rotation with last rendered position/rotation
  -- Store these values after each successful render
  if not self.last_render_state then
    self.last_render_state = {
      position = Vector:new(self.position.x, self.position.y, self.position.z),
      rotation = Vector:new(self.rotation.x, self.rotation.y, self.rotation.z),
      orbital_radius = self.orbital_radius,
      azimuth = self.azimuth,
      elevation = self.elevation
    }
    return true
  end
  
  local state_changed = 
    self.position.x ~= self.last_render_state.position.x or
    self.position.y ~= self.last_render_state.position.y or
    self.position.z ~= self.last_render_state.position.z or
    self.rotation.x ~= self.last_render_state.rotation.x or
    self.rotation.y ~= self.last_render_state.rotation.y or
    self.rotation.z ~= self.last_render_state.rotation.z or
    self.orbital_radius ~= self.last_render_state.orbital_radius or
    self.azimuth ~= self.last_render_state.azimuth or
    self.elevation ~= self.last_render_state.elevation
    
  if state_changed then
    -- Update last render state
    self.last_render_state.position:set(self.position.x, self.position.y, self.position.z)
    self.last_render_state.rotation:set(self.rotation.x, self.rotation.y, self.rotation.z)
    self.last_render_state.orbital_radius = self.orbital_radius
    self.last_render_state.azimuth = self.azimuth
    self.last_render_state.elevation = self.elevation
    return true
  end
  
  return false
end

return Camera
