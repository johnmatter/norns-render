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
    elevation = 0          -- Vertical angle
  }
  setmetatable(camera, self)
  return camera
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

function Camera:orbit_horizontal(angle)
  -- Rotate around Y axis, maintaining distance from origin
  local rx, ry, rz = self:get_rotation()
  self:set_rotation(rx, ry + angle, rz)
  debug.log("Camera orbital rotation:", rx, ry + angle, rz)
end

function Camera:orbit_vertical(angle)
  -- Rotate around X axis, maintaining distance from origin
  local rx, ry, rz = self:get_rotation()
  self:set_rotation(rx + angle, ry, rz)
  debug.log("Camera orbital rotation:", rx + angle, ry, rz)
end

function Camera:zoom(distance)
  -- Move camera closer/further from origin along view direction
  local x, y, z = self:get_position()
  local magnitude = math.sqrt(x*x + y*y + z*z)
  local new_magnitude = magnitude + distance
  
  -- Prevent zooming too close or too far
  if new_magnitude < 5 or new_magnitude > 50 then return end
  
  -- Scale position to maintain direction but change distance
  local scale = new_magnitude / magnitude
  self:set_position(x * scale, y * scale, z * scale)
  debug.log("Camera zoom from", magnitude, "to", new_magnitude)
end

return Camera
