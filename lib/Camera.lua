Camera = {}
Camera.__index = Camera

function Camera:new(x, y, z)
  local camera = { x = x, y = y, z = z }
  setmetatable(camera, self)
  return camera
end

function Camera:get_view_matrix()
  return {
    { 1, 0, 0, -self.x },
    { 0, 1, 0, -self.y },
    { 0, 0, 1, -self.z },
    { 0, 0, 0, 1 }
  }
end

return Camera
