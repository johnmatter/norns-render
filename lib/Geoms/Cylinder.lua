local Geom = include('lib/Geoms/Geom')
local math = require('math')
local debug = include('lib/util/debug')

Cylinder = {}
Cylinder.__index = Cylinder
setmetatable(Cylinder, { __index = Geom })

function Cylinder:new(radius, height, segments)
  local cylinder = Geom.new(self)
  cylinder.radius = radius or 1
  cylinder.height = height or 2
  cylinder.segments = segments or 16
  cylinder:create_geometry()
  return cylinder
end

function Cylinder:create_geometry()
  local angle_increment = (2 * math.pi) / self.segments
  local h = self.height / 2

  -- Create top and bottom circles
  for i = 1, self.segments do
    local angle = i * angle_increment
    local x = self.radius * math.cos(angle)
    local y = self.radius * math.sin(angle)
    table.insert(self.vertices, { x = x, y = y, z = -h }) -- Bottom circle
    table.insert(self.vertices, { x = x, y = y, z = h })  -- Top circle
  end

  -- Create faces
  for i = 1, self.segments do
    local next_i = i % self.segments + 1

    -- Side faces
    table.insert(self.faces, { (i - 1) * 2 + 1, (i - 1) * 2 + 2, (next_i -1) *2 +2, (next_i -1)*2 +1 })

    -- Bottom face
    if i == 1 then
      table.insert(self.faces, {1, 2, 4, 3})
    end

    -- Top face
    if i == 1 then
      table.insert(self.faces, {2, 1, 3, 4})
    end
  end

  debug.log("Cylinder created with radius:", self.radius, "height:", self.height, "segments:", self.segments)
end

return Cylinder 