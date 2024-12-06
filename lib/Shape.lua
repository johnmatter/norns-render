Shape = {}
Shape.__index = Shape

function Shape:new(vertices, faces)
  local shape = {
    vertices = vertices or {},
    faces = faces or {}
  }
  setmetatable(shape, self)
  return shape
end

function Shape:transform(transform_fn)
  for i, vertex in ipairs(self.vertices) do
    self.vertices[i] = transform_fn(vertex)
  end
end

return Shape
