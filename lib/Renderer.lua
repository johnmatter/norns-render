Renderer = {}
Renderer.__index = Renderer

function Renderer:new(framebuffer, camera, projection, light)
  local renderer = {
    framebuffer = framebuffer,
    camera = camera,
    projection = projection,
    light = light
  }
  setmetatable(renderer, self)
  return renderer
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
  local normal = calculate_normal(v1, v2, v3)
  local brightness = self.light:calculate_normal_lighting(normal)

  -- Rasterize triangle
  draw_triangle(self.framebuffer, p1, p2, p3, brightness)
end

function Renderer:render_shape(shape)
  for _, face in ipairs(shape.faces) do
    self:draw_face(shape.vertices, face)
  end
end