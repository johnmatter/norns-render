local debug = include('lib/util/debug')

Mesh = {}
Mesh.__index = Mesh

function Mesh:new(vertices, faces)
    local mesh = {
        transformed_vertices = vertices or {},
        faces = faces or {}
    }
    setmetatable(mesh, self)
    return mesh
end

function Mesh:add_vertex(vertex)
    table.insert(self.transformed_vertices, vertex)
end

function Mesh:add_face(face)
    table.insert(self.faces, face)
end

return Mesh