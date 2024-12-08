local debug = include('lib/util/debug')

Camera = {}
Camera.__index = Camera

function Camera:new(x, y, z)
  local camera = {
    position = { x = x or 0, y = y or 0, z = z or -10 },
    orbital_mode = true,
    
    -- Orbital parameters
    orbital_radius = 10,
    azimuth = 0,
    elevation = 0,
    
    -- Free camera parameters
    yaw = 0,
    pitch = 0,
    
    -- Movement constraints
    min_radius = 5,
    max_radius = 50,
    move_speed = 0.1,
    rotate_speed = 0.1
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
  if action == InputAction.ORBIT_HORIZONTAL then
    self.azimuth = self.azimuth + value
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_VERTICAL then
    self.elevation = self.elevation + value
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_ZOOM_IN then
    self.orbital_radius = math.max(self.min_radius, self.orbital_radius - self.move_speed)
    self:update_from_orbital()
    return true
  elseif action == InputAction.ORBIT_ZOOM_OUT then
    self.orbital_radius = math.min(self.max_radius, self.orbital_radius + self.move_speed)
    self:update_from_orbital()
    return true
  end
  return false
end

function Camera:handle_free_action(action, value)
  if action == InputAction.MOVE_FORWARD then
    local forward = self:get_forward_vector()
    self.position = self:add_vectors(self.position, self:scale_vector(forward, value * self.move_speed))
    return true
  elseif action == InputAction.MOVE_BACKWARD then
    local forward = self:get_forward_vector()
    self.position = self:add_vectors(self.position, self:scale_vector(forward, -value * self.move_speed))
    return true
  elseif action == InputAction.MOVE_RIGHT then
    local right = self:get_right_vector()
    self.position = self:add_vectors(self.position, self:scale_vector(right, value * self.move_speed))
    return true
  elseif action == InputAction.ROTATE_YAW then
    self.yaw = self.yaw + (value * self.rotate_speed)
    return true
  elseif action == InputAction.ROTATE_PITCH then
    self.pitch = util.clamp(
      self.pitch + (value * self.rotate_speed),
      -math.pi/2 + 0.1,
      math.pi/2 - 0.1
    )
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
  -- Convert spherical coordinates to Cartesian
  self.position.x = self.orbital_radius * math.cos(self.elevation) * math.sin(self.azimuth)
  self.position.y = self.orbital_radius * math.sin(self.elevation)
  self.position.z = self.orbital_radius * math.cos(self.elevation) * math.cos(self.azimuth)
  
  -- Update look direction to always point at origin in orbital mode
  self.look_at = { x = 0, y = 0, z = 0 }
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

return Camera