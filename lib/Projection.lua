Projection = {}
Projection.__index = Projection

function Projection:new(width, height, fov, center_x, center_y)
  local projection = { width = width, height = height, fov = fov, center_x = center_x, center_y = center_y }
  setmetatable(projection, self)
  return projection
end

function Projection:get_projection_matrix()
  return {
    { self.fov, 0, 0, 0 },
    { 0, self.fov, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 1 }
  }
end 

return Projection
