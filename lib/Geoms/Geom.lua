local debug = include('lib/util/debug')
local Vector = include('lib/Vector')

Geom = {}
Geom.__index = Geom

-- Abstract method placeholders
function Geom:new()
  local geom = {
    vertices = {},
    faces = {},
    position = Vector:new(0, 0, 0),
    rotation = { x = 0, y = 0, z = 0 }
  }
  setmetatable(geom, self)
  self.__index = self
  return geom
end

function Geom:create_geometry()
  error("create_geometry() must be implemented by subclasses")
end

function Geom:rotate(scaled, axis)
  -- Simple rotation implementation around a given axis
  -- This is a placeholder and should be replaced with actual rotation logic
  for i, vertex in ipairs(self.vertices) do
    -- Apply rotation based on the axis
    -- For example purposes, we're just logging the rotation
    debug.log(string.format("Rotating vertex %d around (%f, %f, %f) by %f", i, axis.x, axis.y, axis.z, scaled))
    -- Implement rotation logic here
  end
end

function Geom:translate(offset)
  self.position = self.position + offset
  debug.log(string.format("Translated Geom to position (%f, %f, %f)", self.position.x, self.position.y, self.position.z))
end

return Geom 