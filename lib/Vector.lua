local debug = include('lib/util/debug')

Vector = {}
Vector.__index = Vector

-- Metamethod for addition
function Vector.__add(a, b)
    return Vector:new(a.x + b.x, a.y + b.y, a.z + b.z)
end

-- Metamethod for subtraction
function Vector.__sub(a, b)
    return Vector:new(a.x - b.x, a.y - b.y, a.z - b.z)
end

-- Metamethod for multiplication by a scalar
function Vector.__mul(a, scalar)
    if type(scalar) == "number" then
        return Vector:new(a.x * scalar, a.y * scalar, a.z * scalar)
    else
        error("Attempt to multiply Vector by a non-number")
    end
end

-- Metamethod for division by a scalar
function Vector.__div(a, scalar)
    if type(scalar) == "number" then
        return Vector:new(a.x / scalar, a.y / scalar, a.z / scalar)
    else
        error("Attempt to divide Vector by a non-number")
    end
end

-- Optional: Metamethod for tostring for easier debugging
function Vector:__tostring()
    return string.format("Vector(x=%.2f, y=%.2f, z=%.2f)", self.x, self.y, self.z)
end

function Vector:new(x, y, z)
    local v = {x = x or 0, y = y or 0, z = z or 0}
    setmetatable(v, self)
    return v
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