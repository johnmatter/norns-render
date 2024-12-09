local Geom = include('lib/Geoms/Geom')
local math = require('math')
local debug = include('lib/util/debug')

Sphere = {}
Sphere.__index = Sphere
setmetatable(Sphere, { __index = Geom })

function Sphere:new(radius, segments, rings)
  local sphere = Geom.new(self)
  sphere.radius = radius or 1
  sphere.segments = segments or 16
  sphere.rings = rings or 16
  sphere:create_geometry()
  return sphere
end

function Sphere:create_geometry()
  for i = 0, self.rings do
    local phi = math.pi * i / self.rings
    for j = 0, self.segments do
      local theta = 2 * math.pi * j / self.segments
      local x = self.radius * math.sin(phi) * math.cos(theta)
      local y = self.radius * math.sin(phi) * math.sin(theta)
      local z = self.radius * math.cos(phi)
      table.insert(self.vertices, { x = x, y = y, z = z })
    end
  end

  for i = 0, self.rings -1 do
    for j = 0, self.segments -1 do
      local first = i * (self.segments +1) + j +1
      local second = first + self.segments +1
      table.insert(self.faces, { first, second, second +1, first +1 })
    end
  end

  debug.log("Sphere created with radius:", self.radius, "segments:", self.segments, "rings:", self.rings)
end

return Sphere 