Light = {}
Light.__index = Light

function Light:new(direction, ambient, diffuse)
  local light = {
    direction = direction or { x = 0, y = 0, z = -1 },
    ambient = ambient or 0.2,
    diffuse = diffuse or 0.8
  }
  setmetatable(light, self)
  return light
end

function Light:calculate_normal_lighting(normal)
  local dot = math.max(0, normal.x * self.direction.x + normal.y * self.direction.y + normal.z * self.direction.z)
  return self.ambient + self.diffuse * dot
end

return Light
