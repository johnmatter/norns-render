local debug = include('lib/util/debug')
local Mesh = include('lib/Mesh')  -- Ensure Mesh class is included
local RenderStyle = include('lib/RenderStyle')
local math = require('math')

Renderer = {}
Renderer.__index = Renderer

function Renderer:new(camera, projection, light)
    local renderer = {
        camera = camera,
        projection = projection,
        light = light,
        render_style = RenderStyle.WIREFRAME  -- Default render style
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

-- Draw WIREFRAME style
function Renderer:draw_wireframe(projected_vertices, face)
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

-- Draw FILLED style (Simple polygon fill by outlining for demonstration)
function Renderer:draw_filled(projected_vertices, face)
    -- Note: Norns does not natively support filled polygons.
    -- This is a placeholder for actual filled polygon rendering.
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

-- Draw DASHED style
function Renderer:draw_dashed(projected_vertices, face)
    local dash_length = 5
    local gap_length = 3

    for i = 1, #face do
        local current_index = face[i]
        local next_index = face[(i % #face) + 1]
        if projected_vertices[current_index] and projected_vertices[next_index] then
            local x1, y1 = projected_vertices[current_index].x, projected_vertices[current_index].y
            local x2, y2 = projected_vertices[next_index].x, projected_vertices[next_index].y
            local dx = x2 - x1
            local dy = y2 - y1
            local distance = math.sqrt(dx * dx + dy * dy)
            local steps = math.floor(distance / (dash_length + gap_length))
            for step = 0, steps - 1 do
                local start_x = x1 + (dx / distance) * (step * (dash_length + gap_length))
                local start_y = y1 + (dy / distance) * (step * (dash_length + gap_length))
                local end_x = start_x + (dx / distance) * dash_length
                local end_y = start_y + (dy / distance) * dash_length
                screen.line(start_x, start_y, end_x, end_y)
            end
        end
    end
    screen.stroke()
end

-- Draw DITHERED style
function Renderer:draw_dithered(projected_vertices, face)
    -- Simple dithering by alternating line intensities
    for i = 1, #face do
        local current_index = face[i]
        local next_index = face[(i % #face) + 1]
        if projected_vertices[current_index] and projected_vertices[next_index] then
            if i % 2 == 0 then
                screen.level(5)  -- Dim line
            else
                screen.level(15) -- Bright line
            end
            screen.line(projected_vertices[current_index].x, projected_vertices[current_index].y,
                       projected_vertices[next_index].x, projected_vertices[next_index].y)
        end
    end
    screen.stroke()
end

-- Draw EXPR style using Shader (Procedural Rendering)
function Renderer:draw_shader(projected_vertices, face)
    -- Placeholder for procedural rendering
    -- Example: Varying line thickness based on face index
    for i = 1, #face do
        local current_index = face[i]
        local next_index = face[(i % #face) + 1]
        if projected_vertices[current_index] and projected_vertices[next_index] then
            local thickness = (i % 3) + 1  -- Vary thickness between 1 to 3
            screen.level(15 - thickness)    -- Vary brightness
            screen.move(projected_vertices[current_index].x, projected_vertices[current_index].y)
            screen.line(projected_vertices[next_index].x, projected_vertices[next_index].y)
            screen.stroke_width(thickness)
            screen.stroke()
            screen.stroke_width(1)  -- Reset to default
        end
    end
end

-- Render a Mesh object
function Renderer:render_mesh(mesh)
    if not mesh or not mesh.faces then
        debug.log("Error: Invalid mesh or missing face data")
        return
    end

    for _, face in ipairs(mesh.faces) do
        self.render_style.draw_face(self, mesh.transformed_vertices, face)
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
