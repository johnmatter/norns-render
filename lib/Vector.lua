Vector = {}
Vector.__index = Vector

function Vector:new(x, y, z)
  local vector = { x = x, y = y, z = z }
  setmetatable(vector, self)
  return vector
end

function Vector:cross(other)
  return Vector:new(
    self.y * other.z - self.z * other.y,
    self.z * other.x - self.x * other.z,
    self.x * other.y - self.y * other.x
  )
end

function Vector:dot(other)
  return self.x * other.x + self.y * other.y + self.z * other.z
end

function Vector:normalize()
  local magnitude = math.sqrt(self:dot(self))
  return Vector:new(self.x / magnitude, self.y / magnitude, self.z / magnitude)
end

function Vector:is_normalized()
  return math.abs(self:dot(self) - 1) < 1e-6
end

return Vector