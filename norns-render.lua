local gamepad = require('gamepad')
local Light = include("lib/Light")
local Renderer = include("lib/Renderer")
local Shape = include("lib/Shape")
local Vector = include("lib/Vector")
local Scene = include("lib/Scene")
local Projection = include("lib/Projection")
local ProController = include('lib/controllers/ProController')

local camera = { x = 0, y = 0, z = -10 }
local projection = Projection:new(
  128,  -- screen width
  64,   -- screen height
  60,   -- FOV in degrees
  0.1,  -- near plane
  100   -- far plane
)
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
local controller = ProController:new()
local camera_rotation = { x = 0, y = 0 }

function init()
  -- Parameters for camera position
  params:add_group("3D Scene", 7)
  params:add_control("cam_x", "Camera X", controlspec.new(-20, 20, 'lin', 0.01, 0, "", 0.01))
  params:add_control("cam_y", "Camera Y", controlspec.new(-20, 20, 'lin', 0.01, 0, "", 0.01))
  params:add_control("cam_z", "Camera Z", controlspec.new(-20, 20, 'lin', 0.01, -10, "", 0.01))
  
  -- Parameters for cube rotation
  params:add_control("rot_x", "Rotation X", controlspec.new(-math.pi, math.pi, 'lin', 0.01, 0, "rad", 0.01))
  params:add_control("rot_y", "Rotation Y", controlspec.new(-math.pi, math.pi, 'lin', 0.01, 0, "rad", 0.01))
  params:add_control("rot_z", "Rotation Z", controlspec.new(-math.pi, math.pi, 'lin', 0.01, 0, "rad", 0.01))
  
  -- Parameter for cube scale
  params:add_control("scale", "Scale", controlspec.new(0.1, 5, 'lin', 0.01, 1, "", 0.01))
  
  -- Parameter change callback
  params.action_write = function(filename)
    update_scene()
  end
  
  -- Create cube and scenes as before
  cube = Shape:new(
  {
    { x = -5, y = -5, z = -5 },
    { x =  5, y = -5, z = -5 },
    { x =  5, y =  5, z = -5 },
    { x = -5, y =  5, z = -5 },
    { x = -5, y = -5, z =  5 },
    { x =  5, y = -5, z =  5 },
    { x =  5, y =  5, z =  5 },
    { x = -5, y =  5, z =  5 },
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
  main_scene:set_render_style(Renderer.RenderStyle.WIREFRAME)
  -- overlay_scene:set_render_style(Renderer.RenderStyle.WIREFRAME)
  
  update_scene()
  
  gamepad.add_callback(function(id, action, value)
    if action == 'add' then
      print("gamepad " .. id .. " added")
      controller:connect(id)
    elseif action == 'remove' then
      print("gamepad " .. id .. " removed")
      controller:disconnect()
    end
  end)
end

function update_scene()
  -- Safely update controller state
  if controller then
    controller:update()
    
    -- Get camera movement from controller
    local success, dx, dz = pcall(function()
      return controller:update_camera(camera, camera_rotation)
    end)
    
    if success and dx and dz then
      params:set("cam_x", params:get("cam_x") + dx)
      params:set("cam_z", params:get("cam_z") + dz)
    end
  end
  
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
      params:get("rot_z")
    )
  end
end

function key(n, z)
  -- K2/K3 cycle through parameters
  if z == 1 and n == 2 then
    selected_param = util.wrap(selected_param + 1, 1, #param_names)
    update_scene()
  elseif z == 1 and n == 3 then
    selected_param = util.wrap(selected_param - 1, 1, #param_names)
    update_scene()
  end
end

function enc(n, d)
  -- Adjust first value of selected parameter
  if n == 1 then
    if param_names[selected_param] == "pos" then
      params:delta("cam_x", d)
    elseif param_names[selected_param] == "scale" then
      params:delta("scale", d)
    elseif param_names[selected_param] == "rotxyz" then
      params:delta("rot_x", d)
    end

  -- Adjust second value of selected parameter
  elseif n == 2 then
    if param_names[selected_param] == "pos" then
      params:delta("cam_y", d)
    elseif param_names[selected_param] == "rotxyz" then
      params:delta("rot_y", d)
    end

  -- Adjust third value of selected parameter
  elseif n == 3 then
    if param_names[selected_param] == "pos" then
      params:delta("cam_z", d)
    elseif param_names[selected_param] == "rotxyz" then
      params:delta("rot_z", d)
    end
  end
  redraw()
end

function redraw()
  local current_time = util.time()

  screen.clear()
  
  -- Update main scene at 30 fps
  if current_time - last_main_update >= (1 / main_scene_fps) then
    renderer:render_scene(main_scene)
  --   renderer:render_scene(overlay_scene)
    last_main_update = current_time
  end
  update_scene()
  
  -- Always draw parameter text
  screen.move(1, 7)
  screen.level(15)
  screen.text(param_display)
  
  screen.update()
end

function cleanup()
end
