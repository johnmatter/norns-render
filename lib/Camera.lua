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

return Camera
