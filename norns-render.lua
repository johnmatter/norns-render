local Light = include("lib/Light")
local Renderer = include("lib/Renderer")
local Shape = include("lib/Shape")
local Vector = include("lib/Vector")
local Scene = include("lib/Scene")

local camera = { x = 0, y = 0, z = -10 }
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
local last_main_update = 0

-- Add after other local variables
local cube
local param_names = {
  "posx", "posy", "posz",
  "rotx", "roty", "rotz",
  "scale"
}
local selected_param = 1
local param_display = ""
local fine_step = 0.01
local coarse_step = 0.1

function init()
  -- Parameters for camera position
  params:add_group("3D Scene", 7)
  params:add_control("posx", "Position X", controlspec.new(-20, 20, 'lin', fine_step, 0))
  params:add_control("posy", "Position Y", controlspec.new(-20, 20, 'lin', fine_step, 0))
  params:add_control("posz", "Position Z", controlspec.new(-30, -1, 'lin', fine_step, -10))
  
  -- Parameters for cube rotation
  params:add_control("rotx", "Rotation X", controlspec.new(-math.pi, math.pi, 'lin', fine_step, 0))
  params:add_control("roty", "Rotation Y", controlspec.new(-math.pi, math.pi, 'lin', fine_step, 0))
  params:add_control("rotz", "Rotation Z", controlspec.new(-math.pi, math.pi, 'lin', fine_step, 0))
  
  -- Parameter for cube scale
  params:add_control("scale", "Scale", controlspec.new(0.1, 5, 'lin', fine_step, 1))
  
  -- Parameter change callback
  params.action_write = function(filename)
    update_scene()
  end
  
  -- Create cube and scenes as before
  cube = Shape:new(
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
  
  update_scene()
end

function update_scene()
  -- Update camera position
  camera.x = params:get("posx")
  camera.y = params:get("posy")
  camera.z = params:get("posz")
  
  -- Update cube rotation
  cube:rotate(params:get("rotx"), {x = 1, y = 0, z = 0})
  cube:rotate(params:get("roty"), {x = 0, y = 1, z = 0})
  cube:rotate(params:get("rotz"), {x = 0, y = 0, z = 1})
  
  -- Update cube scale
  cube:set_scale(params:get("scale"))
  
  -- Update parameter display
  local param_name = param_names[selected_param]
  param_display = string.format("%s = %.2f", param_name, params:get(param_name))
end

function enc(n, d)
  if n == 2 then
    -- Cycle through parameters
    selected_param = util.wrap(selected_param + d, 1, #param_names)
    update_scene()
  elseif n == 3 then
    -- Adjust selected parameter value
    local param_name = param_names[selected_param]
    local step = k1_held and coarse_step or fine_step
    params:delta(param_name, d * step)
    update_scene()
  end
  redraw()
end

-- Add key function to track K1 state
local k1_held = false

function key(n, z)
  if n == 1 then
    k1_held = z == 1
  end
end

function redraw()
  local current_time = util.time()
  
  screen.clear()
  
  -- Update main scene at 30 fps
  if current_time - last_main_update >= (1 / main_scene_fps) then
    renderer:render_scene(main_scene)
    renderer:render_scene(overlay_scene)
    last_main_update = current_time
  end
  
  -- Always draw parameter text
  screen.move(127, 7)
  screen.level(15)
  screen.text_right(param_display)
  
  screen.update()
end

function cleanup()
end
