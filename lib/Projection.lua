Projection = {}
Projection.__index = Projection

function Projection:new(width, height, fov_degrees, near, far)
  local projection = {
    width = width,
    height = height,
    aspect_ratio = width / height,
    fov_radians = math.rad(fov_degrees),
    near = near or 0.1,
    far = far or 1000,
    center_x = width / 2,
    center_y = height / 2
  }
  
  -- Calculate projection constants
  local f = 1.0 / math.tan(projection.fov_radians / 2)
  projection.scale_x = f / projection.aspect_ratio
  projection.scale_y = f
  projection.scale_z = -(far + near) / (far - near)
  projection.translate_z = -(2 * far * near) / (far - near)
  
  setmetatable(projection, self)
  return projection
end

function Projection:project_point(x, y, z)
  -- Perspective division
  local w = -z
  
  -- Apply perspective transformation
  local px = x * self.scale_x / w
  local py = y * self.scale_y / w
  
  -- Map to screen coordinates
  return {
    x = (px + 1) * self.center_x,
    y = (py + 1) * self.center_y
  }
end

return Projection
