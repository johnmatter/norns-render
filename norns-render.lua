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
local selected_param = 1
local param_names = {"pos", "scale", "rotxyz"}
local param_display = ""

function init()
  -- Parameters for camera position
  params:add_group("3D Scene", 7)
  params:add_control("cam_x", "Camera X", controlspec.new(-20, 20, 'lin', 0.1, 0, "", 0.1))
  params:add_control("cam_y", "Camera Y", controlspec.new(-20, 20, 'lin', 0.1, 0, "", 0.1))
  params:add_control("cam_z", "Camera Z", controlspec.new(-30, -1, 'lin', 0.1, -10, "", 0.1))
  
  -- Parameters for cube rotation
  params:add_control("rot_x", "Rotation X", controlspec.new(-math.pi, math.pi, 'lin', 0.01, 0, "rad", 0.01))
  params:add_control("rot_y", "Rotation Y", controlspec.new(-math.pi, math.pi, 'lin', 0.01, 0, "rad", 0.01))
  params:add_control("rot_z", "Rotation Z", controlspec.new(-math.pi, math.pi, 'lin', 0.01, 0, "rad", 0.01))
  
  -- Parameter for cube scale
  params:add_control("scale", "Scale", controlspec.new(0.1, 5, 'lin', 0.1, 1, "", 0.1))
  
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
  camera.x = params:get("cam_x")
  camera.y = params:get("cam_y")
  camera.z = params:get("cam_z")
  
  -- Update cube rotation
  cube:rotate(params:get("rot_x"), {x = 1, y = 0, z = 0})
  cube:rotate(params:get("rot_y"), {x = 0, y = 1, z = 0})
  cube:rotate(params:get("rot_z"), {x = 0, y = 0, z = 1})
  
  -- Update cube scale
  cube:set_scale(params:get("scale"))
  
  -- Update parameter display
  if param_names[selected_param] == "pos" then
    param_display = string.format("pos = %.2f %.2f %.2f", camera.x, camera.y, camera.z)
  elseif param_names[selected_param] == "scale" then
    param_display = string.format("scale = %.2f", params:get("scale"))
  elseif param_names[selected_param] == "rotxyz" then
    param_display = string.format("rotxyz = %.2f %.2f %.2f", 
      params:get("rot_x"),
      params:get("rot_y"),
      params:get("rot_z"))
  end
end

function enc(n, d)
  if n == 3 then
    -- Cycle through parameters
    selected_param = util.wrap(selected_param + d, 1, #param_names)
  elseif n == 1 then
    -- Adjust first value of selected parameter
    if param_names[selected_param] == "pos" then
      params:delta("cam_x", d)
    elseif param_names[selected_param] == "scale" then
      params:delta("scale", d)
    elseif param_names[selected_param] == "rotxyz" then
      params:delta("rot_x", d)
    end
  elseif n == 2 then
    -- Adjust second value of selected parameter
    if param_names[selected_param] == "pos" then
      params:delta("cam_y", d)
    elseif param_names[selected_param] == "rotxyz" then
      params:delta("rot_y", d)
    end
  end
  update_scene()
  redraw()
end

function redraw()
  local current_time = util.time()
  
  -- Update main scene at 30 fps
  if current_time - last_main_update >= (1 / main_scene_fps) then
    screen.clear()
    renderer:render_scene(main_scene)
    renderer:render_scene(overlay_scene)
    last_main_update = current_time
  end
  
  screen.update()
  
  -- Add to existing redraw function
  screen.move(127, 7)
  screen.level(15)
  screen.text_right(param_display)
end

function cleanup()
end
