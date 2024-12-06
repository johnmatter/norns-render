local Framebuffer = include("lib/Framebuffer")
local Light = include("lib/Light")
local Renderer = include("lib/Renderer")
local Shape = include("lib/Shape")
local Vector = include("lib/Vector")

local framebuffer = Framebuffer:new(128, 64)
local camera = { x = 0, y = 0, z = -20 }
local projection = { fov = 1, center_x = 64, center_y = 32 }
local light = Light:new({ x = 0, y = 0, z = -1 }, 0.2, 0.8)
local renderer = Renderer:new(framebuffer, camera, projection, light)

-- Add these near the top with other globals
local fps = 30
local last_redraw = 0

function init()
  -- declare a cube
  local cube = Shape:new(
  {
    { x = -1, y = -1, z = -1 },
    { x =  1, y = -1, z = -1 },
    { x =  1, y =  1, z = -1 },
    { x = -1, y =  1, z = -1 },
    { x = -1, y = -1, z =  1 },
    { x =  1, y = -1, z =  1 },
    { x =  1, y =  1, z =  1 },
    { x = -1, y =  1, z =  1 },
  },
  {
    { 1, 2, 3, 4 }, -- Back face
    { 5, 6, 7, 8 }, -- Front face
    { 1, 2, 6, 5 }, -- Left face
    { 4, 3, 7, 8 }, -- Right face
    { 1, 4, 8, 5 }, -- Top face
    { 2, 3, 7, 6 }, -- Bottom face
  }
)
  renderer:render_shape(cube)
  renderer:render()
end

function redraw()
  -- Throttle frame rate
  local current_time = util.time()
  if current_time - last_redraw < (1 / fps) then
    return
  end
  last_redraw = current_time

  screen.clear()
  renderer:render()
  screen.update()
end

function cleanup()
end
