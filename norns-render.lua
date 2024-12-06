local Light = include("lib/Light")
local Renderer = include("lib/Renderer")
local Shape = include("lib/Shape")
local Vector = include("lib/Vector")
local Scene = include("lib/Scene")

local camera = { x = 0, y = 0, z = -20 }
local projection = { fov = 1, center_x = 64, center_y = 32 }
local light = Light:new({ x = 0, y = 0, z = -1 }, 0.2, 0.8)
local renderer = Renderer:new(camera, projection, light)

-- Frame rate throttling
local fps = 30
local last_redraw = 0

-- Create scenes for different purposes
local main_scene = Scene:new()
local overlay_scene = Scene:new()

local main_scene_fps = 30
local overlay_fps = 60
local last_main_update = 0
local last_overlay_update = 0

function init()
  -- Create the cube
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
  
  -- Add cube to main scene
  main_scene:add(cube)
  
  -- Set different render styles for different scenes
  main_scene:set_render_style(Renderer.RenderStyle.DITHERED)
  overlay_scene:set_render_style(Renderer.RenderStyle.WIREFRAME)
end

function redraw()
  local current_time = util.time()
  
  -- Update main scene at 30 fps
  if current_time - last_main_update >= (1 / main_scene_fps) then
    screen.clear()
    renderer:render_scene(main_scene)
    last_main_update = current_time
  end
  
  -- Update overlay at 60 fps
  if current_time - last_overlay_update >= (1 / overlay_fps) then
    renderer:render_scene(overlay_scene)
    last_overlay_update = current_time
  end
  
  screen.update()
end

function cleanup()
end
