Framebuffer = {}
Framebuffer.__index = Framebuffer

function Framebuffer:new(width, height)
  local fb = {
    width = width,
    height = height,
    data = {}
  }
  setmetatable(fb, self)

  for y = 1, height do
    fb.data[y] = {}
    for x = 1, width do
      fb.data[y][x] = 0
    end
  end

  return fb
end

function Framebuffer:set_pixel(x, y, brightness)
  if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
    self.data[y][x] = math.max(0, math.min(15, brightness))
  end
end

function Framebuffer:clear()
  for y = 1, self.height do
    for x = 1, self.width do
      self.data[y][x] = 0
    end
  end
end

function Framebuffer:render_to_screen()
  screen.clear()
  for y = 1, self.height do
    for x = 1, self.width do
      screen.level(self.data[y][x])
      screen.pixel(x - 1, y - 1)
    end
  end
  screen.update()
end

return Framebuffer
