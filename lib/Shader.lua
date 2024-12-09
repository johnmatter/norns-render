local debug = include('lib/util/debug')

Shader = {}
Shader.__index = Shader

-- Constructor
function Shader:new(name, shader_fn)
    local shader = {
        name = name,
        shader_fn = shader_fn  -- Function defining procedural rendering
    }
    setmetatable(shader, self)
    return shader
end

-- Apply the shader to a face
function Shader:apply(renderer, projected_vertices, face)
    if self.shader_fn and type(self.shader_fn) == "function" then
        self.shader_fn(renderer, projected_vertices, face)
    else
        debug.log("Error: Shader function not defined for", self.name)
    end
end

return Shader