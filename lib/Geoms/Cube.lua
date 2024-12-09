local Geom = include('lib/Geoms/Geom')
local debug = include('lib/util/debug')

Cube = {}
Cube.__index = Cube
setmetatable(Cube, { __index = Geom })

function Cube:new(size)
  local cube = Geom.new(self)
  cube.size = size or 1
  cube:create_geometry()
  return cube
end

function Cube:create_geometry()
  local s = self.size / 2
  self.vertices = {
    { x = -s, y = -s, z = -s },
    { x =  s, y = -s, z = -s },
    { x =  s, y =  s, z = -s },
    { x = -s, y =  s, z = -s },
    { x = -s, y = -s, z =  s },
    { x =  s, y = -s, z =  s },
    { x =  s, y =  s, z =  s },
    { x = -s, y =  s, z =  s },
  }

  self.faces = {
    {1, 2, 3, 4}, -- Back
    {5, 6, 7, 8}, -- Front
    {1, 2, 6, 5}, -- Bottom
    {2, 3, 7, 6}, -- Right
    {3, 4, 8, 7}, -- Top
    {4, 1, 5, 8}, -- Left
  }

  debug.log("Cube created with size:", self.size)
end

return Cube 