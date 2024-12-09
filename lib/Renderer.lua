local debug = include('lib/util/debug')
local Mesh = include('lib/Mesh')  -- Ensure Mesh class is included
local math = require('math')

Renderer = {}
Renderer.__index = Renderer

function Renderer:new(camera, projection, light)
    local renderer = {
        camera = camera,
        projection = projection,
        light = light,
        render_style = 'WIREFRAME'  -- Default render style
    }
    setmetatable(renderer, self)
    return renderer
end

-- Project a 3D vertex to 2D screen coordinates
function Renderer:project_vertex(vertex)
    if not vertex then
        debug.log("Error: Attempted to project nil vertex")
        return {x = 0, y = 0}  -- Return safe default
    end
    
    if not vertex.x or not vertex.y or not vertex.z then
        debug.log("Error: Vertex missing coordinates:", vertex)
        return {x = 0, y = 0}  -- Return safe default
    end

    -- Transform vertex position by camera
    local x = vertex.x - self.camera.position.x
    local y = vertex.y - self.camera.position.y
    local z = vertex.z - self.camera.position.z

    -- Avoid division by zero
    if z == 0 then z = 0.0001 end

    -- Simple perspective projection
    local fov_rad = math.rad(self.projection.fov)
    local scale = 1 / (math.tan(fov_rad / 2))
    local projected_x = (x * scale) / z
    local projected_y = (y * scale) / z

    -- Convert to screen coordinates
    local screen_x = (projected_x + 1) * (self.projection.width / 2)
    local screen_y = (1 - projected_y) * (self.projection.height / 2)

    return {x = screen_x, y = screen_y}
end

-- Draw a face based on projected vertices
function Renderer:draw_face(projected_vertices, face)
    if not projected_vertices or not face then
        debug.log("Error: Missing projected vertices or face data")
        return
    end

    -- Depending on render style, draw lines or filled polygons
    if self.render_style == 'WIREFRAME' then
        for i = 1, #face do
            local current_index = face[i]
            local next_index = face[(i % #face) + 1]
            if projected_vertices[current_index] and projected_vertices[next_index] then
                screen.line(projected_vertices[current_index].x, projected_vertices[current_index].y,
                           projected_vertices[next_index].x, projected_vertices[next_index].y)
            end
        end
        screen.stroke()
    elseif self.render_style == 'SOLID' then
        -- Filled polygon rendering is more complex and might require a custom implementation
        -- For simplicity, we'll outline the polygon
        for i = 1, #face do
            local current_index = face[i]
            local next_index = face[(i % #face) + 1]
            if projected_vertices[current_index] and projected_vertices[next_index] then
                screen.line(projected_vertices[current_index].x, projected_vertices[current_index].y,
                           projected_vertices[next_index].x, projected_vertices[next_index].y)
            end
        end
        screen.stroke()
    end
end

-- Render a Mesh object
function Renderer:render_mesh(mesh)
    if not mesh or not mesh.faces then
        debug.log("Error: Invalid mesh or missing face data")
        return
    end

    for _, face in ipairs(mesh.faces) do
        self:draw_face(mesh.transformed_vertices, face)
    end
end

-- Render a single Geom object by calling its render method
function Renderer:render_shape(geom)
    if not geom or not geom.render then
        debug.log("Error: Invalid Geom object or missing render method")
        return
    end

    local mesh = geom:render()
    self:render_mesh(mesh)
end

-- Render an entire scene
function Renderer:render_scene(scene)
    debug.log("Rendering scene with", #scene.objects, "objects")
    
    if not scene or not scene.objects then
        debug.log("Error: Invalid scene or missing objects")
        return
    end

    -- Set render style from the scene if available
    if scene.render_style then
        -- Save current style
        local previous_style = self.render_style
        self.render_style = scene.render_style
        
        -- Render all objects
        for i, obj in ipairs(scene.objects) do
            debug.log("Rendering object", i, "with", #obj.vertices, "vertices and", #obj.faces, "faces")
            self:render_shape(obj)
        end
        
        -- Restore previous style
        self.render_style = previous_style
    else
        -- Render all objects with current style
        for i, obj in ipairs(scene.objects) do
            debug.log("Rendering object", i, "with", #obj.vertices, "vertices and", #obj.faces, "faces")
            self:render_shape(obj)
        end
    end
end

return Renderer
