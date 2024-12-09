local utils = {}

function utils.clamp(value, min, max)
  return math.min(math.max(value, min), max)
end

function utils.lerp(a, b, t)
  return a + (b - a) * t
end

function utils.normalize_angle(angle)
  while angle > math.pi do
    angle = angle - 2 * math.pi
  end
  while angle < -math.pi do
    angle = angle + 2 * math.pi
  end
  return angle
end

return utils
