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
  -- This is a basic implementation - you might want to improve it
  local level = math.floor(brightness * 15)
  self.framebuffer:set_pixel(math.floor(p1.x), math.floor(p1.y), level)
  self.framebuffer:set_pixel(math.floor(p2.x), math.floor(p2.y), level)
  self.framebuffer:set_pixel(math.floor(p3.x), math.floor(p3.y), level)
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
    self:draw_face(shape.vertices, face)
  end
end

return Renderer
