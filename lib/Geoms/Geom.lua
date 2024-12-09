local debug = include('lib/util/debug')
local Vector = include('lib/Vector')
local math = require('math')

Geom = {}
Geom.__index = Geom

-- Constructor
function Geom:new()
  local geom = {
    vertices = {},       -- Local vertices
    faces = {},
    position = Vector:new(0, 0, 0),   -- Position in global space
    rotation = { x = 0, y = 0, z = 0 }, -- Rotation angles in radians
    scale = 1             -- Uniform scaling factor
  }
  setmetatable(geom, self)
  return geom
end

-- Abstract method placeholder
function Geom:create_geometry()
  error("create_geometry() must be implemented by subclasses")
end

-- Translate the Geom by a given offset (Vector)
function Geom:translate(offset)
  debug.log("Translating Geom from position:", tostring(self.position))
  self.position = self.position + offset
  debug.log("Translated Geom to position:", tostring(self.position))
end

-- Rotate the Geom by adding to its current rotation angles
-- scaled: scalar to scale the rotation
-- axis: Vector indicating the axis of rotation ('x', 'y', 'z')
function Geom:rotate(scaled, axis)
  if axis.x then
    self.rotation.x = self.rotation.x + scaled * axis.x
  end
  if axis.y then
    self.rotation.y = self.rotation.y + scaled * axis.y
  end
  if axis.z then
    self.rotation.z = self.rotation.z + scaled * axis.z
  end
  debug.log(string.format("Rotated Geom to angles (x=%.2f, y=%.2f, z=%.2f)", 
    math.deg(self.rotation.x), math.deg(self.rotation.y), math.deg(self.rotation.z)))
end

-- Scale the Geom uniformly by a given factor
function Geom:scale_geom(factor)
  self.scale = self.scale * factor
  for i, vertex in ipairs(self.vertices) do
    self.vertices[i].x = vertex.x * factor
    self.vertices[i].y = vertex.y * factor
    self.vertices[i].z = vertex.z * factor
  end
  debug.log(string.format("Scaled Geom by a factor of %.2f", factor))
end

-- Helper function to rotate a point around the X-axis
local function rotate_x(vertex, angle)
  local cos = math.cos(angle)
  local sin = math.sin(angle)
  return {
    x = vertex.x,
    y = vertex.y * cos - vertex.z * sin,
    z = vertex.y * sin + vertex.z * cos
  }
end

-- Helper function to rotate a point around the Y-axis
local function rotate_y(vertex, angle)
  local cos = math.cos(angle)
  local sin = math.sin(angle)
  return {
    x = vertex.x * cos + vertex.z * sin,
    y = vertex.y,
    z = -vertex.x * sin + vertex.z * cos
  }
end

-- Helper function to rotate a point around the Z-axis
local function rotate_z(vertex, angle)
  local cos = math.cos(angle)
  local sin = math.sin(angle)
  return {
    x = vertex.x * cos - vertex.y * sin,
    y = vertex.x * sin + vertex.y * cos,
    z = vertex.z
  }
end

-- Get the transformed (global) vertices after applying scaling, rotation, and translation
function Geom:get_transformed_vertices()
  local transformed = {}
  for i, vertex in ipairs(self.vertices) do
    local v = {
      x = vertex.x * self.scale,
      y = vertex.y * self.scale,
      z = vertex.z * self.scale
    }
    
    -- Apply rotation
    v = rotate_x(v, self.rotation.x)
    v = rotate_y(v, self.rotation.y)
    v = rotate_z(v, self.rotation.z)
    
    -- Apply translation
    v.x = v.x + self.position.x
    v.y = v.y + self.position.y
    v.z = v.z + self.position.z
    
    table.insert(transformed, v)
  end
  return transformed
end

return Geom