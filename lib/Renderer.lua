Renderer = {}
Renderer.__index = Renderer

-- Rendering style enum
Renderer.RenderStyle = {
  WIREFRAME = "wireframe",
  DITHERED = "dithered",
  BRIGHTNESS = "brightness"
}

function Renderer:new(framebuffer, camera, projection, light)
  local renderer = {
    framebuffer = framebuffer,
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
  -- Simple triangle rasterization
  -- TODO: face culling
  local level = math.floor(brightness * 15)
  
  if self.render_style == Renderer.RenderStyle.WIREFRAME then
    -- Draw triangle edges
    self:draw_line(p1, p2, level)
    self:draw_line(p2, p3, level)
    self:draw_line(p3, p1, level)
    
  elseif self.render_style == Renderer.RenderStyle.DITHERED then
    -- Simple dithering pattern based on position and brightness
    for y = math.min(p1.y, p2.y, p3.y), math.max(p1.y, p2.y, p3.y) do
      for x = math.min(p1.x, p2.x, p3.x), math.max(p1.x, p2.x, p3.x) do
        if (x + y) % 2 == 0 then  -- Checkerboard pattern
          self.framebuffer:set_pixel(math.floor(x), math.floor(y), level)
        end
      end
    end
    
  else -- BRIGHTNESS
    self.framebuffer:set_pixel(math.floor(p1.x), math.floor(p1.y), level)
    self.framebuffer:set_pixel(math.floor(p2.x), math.floor(p2.y), level)
    self.framebuffer:set_pixel(math.floor(p3.x), math.floor(p3.y), level)
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
  self.framebuffer:render()
end

function Renderer:draw_line(p1, p2, brightness)
  local dx = p2.x - p1.x
  local dy = p2.y - p1.y
  local steps = math.max(math.abs(dx), math.abs(dy))
  
  local x_inc = dx / steps
  local y_inc = dy / steps
  
  local x = p1.x
  local y = p1.y
  
  for i = 0, steps do
    self.framebuffer:set_pixel(math.floor(x), math.floor(y), brightness)
    x = x + x_inc
    y = y + y_inc
  end
end

return Renderer
