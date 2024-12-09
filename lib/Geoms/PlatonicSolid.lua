local Geom = include('lib/Geoms/Geom')
local math = require('math')
local debug = include('lib/util/debug')

PlatonicSolid = {}
PlatonicSolid.__index = PlatonicSolid
setmetatable(PlatonicSolid, { __index = Geom })

PlatonicSolid.Types = {
  TETRAHEDRON = "tetrahedron",
  HEXAHEDRON = "hexahedron", -- Cube
  OCTAHEDRON = "octahedron",
  DODECAHEDRON = "dodecahedron",
  ICOSAHEDRON = "icosahedron"
}

function PlatonicSolid:new(type, size)
  local solid = Geom.new(self)
  solid.type = type or PlatonicSolid.Types.HEXAHEDRON
  solid.size = size or 1
  solid:create_geometry()
  return solid
end

function PlatonicSolid:create_geometry()
  if self.type == PlatonicSolid.Types.TETRAHEDRON then
    self:create_tetrahedron()
  elseif self.type == PlatonicSolid.Types.HEXAHEDEON then
    self:create_hexahedron()
  elseif self.type == PlatonicSolid.Types.OCTAHEDRON then
    self:create_octahedron()
  elseif self.type == PlatonicSolid.Types.DODECAHEDRON then
    self:create_dodecahedron()
  elseif self.type == PlatonicSolid.Types.ICOSAHEDRON then
    self:create_icosahedron()
  else
    error("Unknown Platonic Solid type: " .. tostring(self.type))
  end
end

function PlatonicSolid:create_tetrahedron()
  local s = self.size / math.sqrt(2)
  self.vertices = {
    { x =  s, y =  s, z =  s },
    { x = -s, y = -s, z =  s },
    { x = -s, y =  s, z = -s },
    { x =  s, y = -s, z = -s },
  }
  self.faces = {
    {1, 2, 3},
    {1, 4, 2},
    {1, 3, 4},
    {2, 4, 3},
  }
  debug.log("Created Tetrahedron")
end

function PlatonicSolid:create_hexahedron()
  -- A cube is a hexahedron
  local GeomClass = include('lib/Geoms/Cube')
  local cube = GeomClass:new(self.size)
  self.vertices = cube.vertices
  self.faces = cube.faces
  debug.log("Created Hexahedron (Cube)")
end

function PlatonicSolid:create_octahedron()
  local s = self.size / math.sqrt(2)
  self.vertices = {
    { x =  s, y = 0, z = 0 },
    { x = -s, y = 0, z = 0 },
    { x = 0, y =  s, z = 0 },
    { x = 0, y = -s, z = 0 },
    { x = 0, y = 0, z =  s },
    { x = 0, y = 0, z = -s },
  }
  self.faces = {
    {1, 3, 5},
    {3, 2, 5},
    {2, 4, 5},
    {4, 1, 5},
    {3, 1, 6},
    {2, 3, 6},
    {4, 2, 6},
    {1, 4, 6},
  }
  debug.log("Created Octahedron")
end

function PlatonicSolid:create_dodecahedron()
  -- Placeholder: Dodecahedron creation logic
  error("Dodecahedron creation not implemented yet")
end

function PlatonicSolid:create_icosahedron()
  -- Placeholder: Icosahedron creation logic
  error("Icosahedron creation not implemented yet")
end

return PlatonicSolid 