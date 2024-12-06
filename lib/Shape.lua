Shape = {}
Shape.__index = Shape

function Shape:new(vertices, faces)
  local shape = {
    vertices = vertices or {},
    faces = faces or {},
    rotation = { x = 0, y = 0, z = 0 },
    scale = 1
  }
  setmetatable(shape, self)
  return shape
end

function Shape:get_center()
  local sum_x, sum_y, sum_z = 0, 0, 0
  local count = #self.vertices
  
  if count == 0 then
    return {x = 0, y = 0, z = 0}
  end
  
  for _, vertex in ipairs(self.vertices) do
    sum_x = sum_x + vertex.x
    sum_y = sum_y + vertex.y
    sum_z = sum_z + vertex.z
  end
  
  return {
    x = sum_x / count,
    y = sum_y / count,
    z = sum_z / count
  }
end

function Shape:transform(transform_fn)
  for i, vertex in ipairs(self.vertices) do
    self.vertices[i] = transform_fn(vertex)
  end
end

-- Rotate by an angle in radians around an axis
-- Uses Rodrigues' rotation formula:
-- v_rot = v * cos(θ) + (k × v) * sin(θ) + k * (k · v) * (1 - cos(θ))
-- where k is the normalized axis vector and θ is the angle
-- The axis is centered on the shape's center
function Shape:rotate(angle, axis)
  -- Get the center of the shape
  local center = self:get_center()
  
  -- Normalize the axis vector
  local length = math.sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)
  local k = {
    x = axis.x / length,
    y = axis.y / length,
    z = axis.z / length
  }
  
  -- Cache trig values
  local cos_theta = math.cos(angle)
  local sin_theta = math.sin(angle)
  local one_minus_cos = 1 - cos_theta
  
  self:transform(function(v)
    -- Translate point to origin (relative to center)
    local px = v.x - center.x
    local py = v.y - center.y
    local pz = v.z - center.z
    
    -- Calculate dot product k·v
    local dot = k.x * px + k.y * py + k.z * pz
    
    -- Calculate cross product k×v
    local cross_x = k.y * pz - k.z * py
    local cross_y = k.z * px - k.x * pz
    local cross_z = k.x * py - k.y * px
    
    -- Apply Rodrigues' rotation formula
    return {
      x = px * cos_theta + cross_x * sin_theta + k.x * dot * one_minus_cos + center.x,
      y = py * cos_theta + cross_y * sin_theta + k.y * dot * one_minus_cos + center.y,
      z = pz * cos_theta + cross_z * sin_theta + k.z * dot * one_minus_cos + center.z
    }
  end)
end

function Shape:set_scale(scale)
  local center = self:get_center()
  self:transform(function(v)
    return {
      x = center.x + (v.x - center.x) * scale,
      y = center.y + (v.y - center.y) * scale,
      z = center.z + (v.z - center.z) * scale
    }
  end)
  self.scale = scale
end

return Shape