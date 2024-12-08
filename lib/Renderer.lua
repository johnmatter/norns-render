Renderer = {}
Renderer.__index = Renderer

-- Rendering style enum
Renderer.RenderStyle = {
  WIREFRAME = "wireframe",
  DITHERED = "dithered",
  BRIGHTNESS = "brightness"
}

function Renderer:new(camera, projection, light)
  local renderer = {
    camera = camera,
    projection = projection,
    light = light,
    render_style = Renderer.RenderStyle.WIREFRAME
  }
  setmetatable(renderer, self)
  return renderer
end

function Renderer:calculate_normal(v1, v2, v3)
  -- Calculate vectors from v1 to v2 and v1 to v3
  local ax = v2.x - v1.x
  local ay = v2.y - v1.y
  local az = v2.z - v1.z
  
  local bx = v3.x - v1.x
  local by = v3.y - v1.y
  local bz = v3.z - v1.z
  
  -- Calculate cross product
  local nx = ay * bz - az * by
  local ny = az * bx - ax * bz
  local nz = ax * by - ay * bx
  
  -- Normalize
  local length = math.sqrt(nx * nx + ny * ny + nz * nz)
  return {
    x = nx / length,
    y = ny / length,
    z = nz / length
  }
end

function Renderer:draw_triangle(p1, p2, p3, brightness)
  screen.level(math.floor(brightness * 15))
  
  if self.render_style == Renderer.RenderStyle.WIREFRAME then
    -- Draw triangle edges using screen.line
    screen.move(p1.x, p1.y)
    screen.line(p2.x, p2.y)
    screen.line(p3.x, p3.y)
    screen.line(p1.x, p1.y)
    screen.stroke()
    
  elseif self.render_style == Renderer.RenderStyle.DITHERED then
    -- For dithering, we'll use screen.rect for efficiency
    local min_x = math.min(p1.x, p2.x, p3.x)
    local max_x = math.max(p1.x, p2.x, p3.x)
    local min_y = math.min(p1.y, p2.y, p3.y)
    local max_y = math.max(p1.y, p2.y, p3.y)
    
    -- Draw a pattern of small rectangles
    for y = min_y, max_y, 2 do
      for x = min_x + (y % 4), max_x, 4 do
        screen.rect(x, y, 1, 1)
        screen.fill()
      end
    end
    
  else -- BRIGHTNESS
    -- For filled triangles, use screen.move and screen.fill()
    screen.move(p1.x, p1.y)
    screen.line(p2.x, p2.y)
    screen.line(p3.x, p3.y)
    screen.close()
    screen.fill()
  end
end

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

  -- Project the point
  return self.projection:project_point(x, y, z)
end

function Renderer:draw_face(vertices, face)
  if not vertices or not face then
    debug.log("Error: Missing vertices or face data")
    return
  end

  -- Project vertices
  local projected = {}
  for _, index in ipairs(face) do
    local vertex = vertices[index]
    local proj = self:project_vertex(vertex)
    debug.log("Projected vertex", index, "from", vertex.x, vertex.y, vertex.z, "to", proj.x, proj.y)
    table.insert(projected, proj)
  end

  -- Draw the face
  if #projected >= 3 then
    for i = 1, #projected do
      local p1 = projected[i]
      local p2 = projected[i % #projected + 1]
      self:draw_line(p1, p2, 15)  -- Use full brightness for testing
    end
  end
end

function Renderer:render_shape(shape)
  for _, face in ipairs(shape.faces) do
    self:draw_face(shape.vertices, face)
  end
end

function Renderer:draw_line(p1, p2, brightness)
  screen.level(brightness)
  screen.move(p1.x, p1.y)
  screen.line(p2.x, p2.y)
  screen.stroke()
end

function Renderer:render_scene(scene)
  debug.log("Rendering scene with", #scene.objects, "objects")
  
  if scene.render_style then
    -- Save current style
    local previous_style = self.render_style
    self.render_style = scene.render_style
    
    -- Render all objects
    for _, obj in ipairs(scene.objects) do
      debug.log("Rendering object with", #obj.vertices, "vertices and", #obj.faces, "faces")
      self:render_shape(obj)
    end
    
    -- Restore previous style
    self.render_style = previous_style
  else
    -- Render all objects with current style
    for _, obj in ipairs(scene.objects) do
      debug.log("Rendering object with", #obj.vertices, "vertices and", #obj.faces, "faces")
      self:render_shape(obj)
    end
  end
end

return Renderer
