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
  -- Translate to camera space
  local x = vertex.x - self.camera.x
  local y = vertex.y - self.camera.y
  local z = vertex.z - self.camera.z

  -- Apply projection
  local screen_x = x / -z * self.projection.fov + self.projection.center_x
  local screen_y = y / -z * self.projection.fov + self.projection.center_y

  return { x = screen_x, y = screen_y }
end

function Renderer:draw_face(vertices, face)
  local v1 = vertices[face[1]]
  local v2 = vertices[face[2]]
  local v3 = vertices[face[3]]

  -- Transform vertices
  local p1 = self:project_vertex(v1)
  local p2 = self:project_vertex(v2)
  local p3 = self:project_vertex(v3)

  -- Calculate normal and lighting
  local normal = self:calculate_normal(v1, v2, v3)
  local brightness = self.light:calculate_normal_lighting(normal)

  -- Rasterize triangle
  self:draw_triangle(p1, p2, p3, brightness)
end

function Renderer:render_shape(shape)
  for _, face in ipairs(shape.faces) do
    for _, vertex in ipairs(face) do
      print(vertex)
    end
    self:draw_face(shape.vertices, face)
  end
end

function Renderer:render()
  screen.update()
end

function Renderer:draw_line(p1, p2, brightness)
  screen.level(brightness)
  screen.move(p1.x, p1.y)
  screen.line(p2.x, p2.y)
  screen.stroke()
end

function Renderer:render_scene(scene)
  local previous_style = self.render_style
  
  -- Use scene-specific render style if specified
  if scene.render_style then
    self.render_style = scene.render_style
  end
  
  for _, shape in ipairs(scene.objects) do
    self:render_shape(shape)
  end
  
  -- Restore previous render style
  self.render_style = previous_style
end

return Renderer