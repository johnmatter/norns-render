include('lib/util/debug')
local Shader = include('lib/Shader')

RenderStyle = {}
RenderStyle.__index = RenderStyle

-- Constructor
function RenderStyle:new(name, draw_face_fn)
    local render_style = {
        name = name,
        draw_face = draw_face_fn  -- Function defining how to draw a face
    }
    setmetatable(render_style, self)
    return render_style
end

-- Predefined Render Styles

-- WIREFRAME: Draws only the edges of the faces
RenderStyle.WIREFRAME = RenderStyle:new("WIREFRAME", function(renderer, projected_vertices, face)
    renderer:draw_wireframe(projected_vertices, face)
end)

-- FILLED: Draws filled polygons
RenderStyle.FILLED = RenderStyle:new("FILLED", function(renderer, projected_vertices, face)
    renderer:draw_filled(projected_vertices, face)
end)

-- DASHED: Draws dashed edges for the faces
RenderStyle.DASHED = RenderStyle:new("DASHED", function(renderer, projected_vertices, face)
    renderer:draw_dashed(projected_vertices, face)
end)

-- DITHERED: Applies a dithering pattern to the drawn faces
RenderStyle.DITHERED = RenderStyle:new("DITHERED", function(renderer, projected_vertices, face)
    renderer:draw_dithered(projected_vertices, face)
end)

-- EXPR (EXPRESSION): Procedural rendering using shaders
local expr_shader = Shader:new("BasicExpressionShader", function(renderer, projected_vertices, face)
    -- Example procedural effect: Varying color based on face orientation
    -- Since Norns screen doesn't support colors, use brightness instead

    -- Calculate face normal (simplified)
    local v1 = projected_vertices[face[1]]
    local v2 = projected_vertices[face[2]]
    local v3 = projected_vertices[face[3]]
    local dx1 = v2.x - v1.x
    local dy1 = v2.y - v1.y
    local dx2 = v3.x - v1.x
    local dy2 = v3.y - v1.y
    local normal = (dx1 * dy2) - (dx2 * dy1)

    -- Determine brightness based on normal
    local brightness = math.abs(normal) / 100  -- Arbitrary scaling
    brightness = math.min(math.max(brightness, 1), 15)  -- Clamp between 1 and 15

    -- Set screen level based on brightness
    screen.level(brightness)

    for i = 1, #face do
        local current_index = face[i]
        local next_index = face[(i % #face) + 1]
        if projected_vertices[current_index] and projected_vertices[next_index] then
            screen.line(projected_vertices[current_index].x, projected_vertices[current_index].y,
                       projected_vertices[next_index].x, projected_vertices[next_index].y)
        end
    end
    screen.stroke()
end)

RenderStyle.EXPR = RenderStyle:new("EXPR", function(renderer, projected_vertices, face)
    renderer:draw_shader(projected_vertices, face)
end)

return RenderStyle 