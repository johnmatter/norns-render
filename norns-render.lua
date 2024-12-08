local gamepad = require('gamepad')
local Light = include("lib/Light")
local Renderer = include("lib/Renderer")
local Shape = include("lib/Shape")
local Vector = include("lib/Vector")
local Scene = include("lib/Scene")
local Projection = include("lib/Projection")
local Camera = include("lib/Camera")
local ProController = include('lib/controllers/ProController')
local NornsController = include('lib/controllers/NornsController')
local KeyboardController = include('lib/controllers/KeyboardController')
local lfo = require('lfo')
local clock = require('clock')
local metro = require('metro')
local debug = include('lib/util/debug')

local camera = Camera:new(0, 0, -10)
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
local fps = 5
local last_redraw = 0

-- Create scenes for different purposes
local main_scene = Scene:new()
local overlay_scene = Scene:new()

local main_scene_fps = 15
local last_main_update = 0

-- Add after other local variables
local cube
local active_controller
local rotation_lfos = {
  x = lfo.new(
    'sine',
    -0.00,
    0.00,
    1,
    'free',
    300,
    function(scaled, raw)
      if cube then
        cube:rotate(scaled, {x = 1, y = 0, z = 0})
      end
    end
  ),
  y = lfo.new(
    'sine',
    -0.00,
    0.00,
    1,
    'free',
    300,
    function(scaled, raw)
      if cube then
        cube:rotate(scaled, {x = 0, y = 1, z = 0})
      end
    end
  ),
  z = lfo.new(
    'sine',
    -0.00,
    0.00,
    1,
    'free',
    280,
    function(scaled, raw)
      if cube then
        cube:rotate(scaled, {x = 0, y = 0, z = 1})
      end
    end
  )
}
local redraw_clock
local input_clock

function init()
  -- Parameter for cube scale
  params:add_control("scale", "Scale", controlspec.new(0.1, 5, 'lin', 0.01, 1, "", 0.01))
  
  -- Parameter change callback
  params.action_write = function(filename)
    update_scene()
  end
  
  -- Add to parameters group first
  params:add_option("control_scheme", "Control Scheme", {"Norns", "Keyboard", "Gamepad"}, 1)
  params:set_action("control_scheme", function(value)
    if value == 2 then
      set_active_controller(KeyboardController:new())
    elseif value == 3 then
      set_active_controller(ProController:new())
    else
      set_active_controller(NornsController:new())
    end
  end)
  
  -- Initialize with Norns controller by default
  set_active_controller(NornsController:new())
  
  -- Setup gamepad callback only if user switches to gamepad mode
  if gamepad then
    -- Register connect callback
    gamepad.connect = function(id)
      print("gamepad " .. id .. " connected")
      if active_controller.connect and params:get("control_scheme") == 3 then
        active_controller:connect(id)
      end
    end
    
    -- Register disconnect callback
    gamepad.disconnect = function(id)
      print("gamepad " .. id .. " disconnected")
      if active_controller.disconnect and params:get("control_scheme") == 3 then
        active_controller:disconnect()
      end
    end
  end
  
  -- Create cube and scenes as before
  cube = Shape:new(
    {
      { x = -3, y = -3, z = -3 },
      { x =  3, y = -3, z = -3 },
      { x =  3, y =  3, z = -3 },
      { x = -3, y =  3, z = -3 },
      { x = -3, y = -3, z =  3 },
      { x =  3, y = -3, z =  3 },
      { x =  3, y =  3, z =  3 },
      { x = -3, y =  3, z =  3 },
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
  
  -- Setup LFOs for cube rotation
  params:add_group("Rotation LFOs", 9)
  
  -- X rotation LFO
  params:add_option("lfo_x_shape", "X LFO Shape", {"sine", "tri", "square", "random"}, 1)
  params:add_control("lfo_x_freq", "X LFO Freq", controlspec.new(0.001, 0.1, 'exp', 0.001, 0.01, 'hz'))
  params:add_control("lfo_x_depth", "X LFO Depth", controlspec.new(0, math.pi, 'lin', 0.1, math.pi/4, 'rad'))
  
  -- Y rotation LFO
  params:add_option("lfo_y_shape", "Y LFO Shape", {"sine", "tri", "square", "random"}, 1)
  params:add_control("lfo_y_freq", "Y LFO Freq", controlspec.new(0.001, 0.1, 'exp', 0.001, 0.015, 'hz'))
  params:add_control("lfo_y_depth", "Y LFO Depth", controlspec.new(0, math.pi, 'lin', 0.1, math.pi/4, 'rad'))
  
  -- Z rotation LFO
  params:add_option("lfo_z_shape", "Z LFO Shape", {"sine", "tri", "square", "random"}, 1)
  params:add_control("lfo_z_freq", "Z LFO Freq", controlspec.new(0.001, 0.1, 'exp', 0.001, 0.02, 'hz'))
  params:add_control("lfo_z_depth", "Z LFO Depth", controlspec.new(0, math.pi, 'lin', 0.1, math.pi/4, 'rad'))
  
  -- Configure LFOs
  for axis, lfo_obj in pairs(rotation_lfos) do
    lfo_obj:add_params("rot_" .. axis)  -- Add params with unique ID
    lfo_obj:start()  -- Start the LFO
  end
  
  -- Modify LFO parameter actions
  for axis in pairs(rotation_lfos) do
    params:set_action("lfo_"..axis.."_shape", function(value)
      rotation_lfos[axis].shape = value
    end)
    params:set_action("lfo_"..axis.."_freq", function(value)
      rotation_lfos[axis].period = 1/value
    end)
    params:set_action("lfo_"..axis.."_depth", function(value)
      rotation_lfos[axis].depth = value
    end)
  end
  
  update_scene()
  
  -- Initialize input polling clock
  input_clock = clock.run(function()
    while true do
      clock.sleep(1/30) -- 30Hz polling rate
      if active_controller and active_controller.poll then
        active_controller:poll()
        update_scene()
      end
    end
  end)
  
  -- Initialize redraw clock
  redraw_clock = clock.run(function()
    while true do
      clock.sleep(1/fps)
      local menu_status = norns.menu.status()
      debug.log("Redraw clock tick, menu_status:", menu_status)
      if not menu_status then
        redraw()
      end
    end
  end)
  
  -- Add after cube creation (around line 145)
  debug.log("Cube vertices:", #cube.vertices, "faces:", #cube.faces)
  for i, v in ipairs(cube.vertices) do
    debug.log("Vertex", i, ":", v.x, v.y, v.z)
  end
  
end

function update_scene()
  if active_controller then
    -- Controller updates camera directly through input bindings
    if active_controller.update then
      active_controller:update()
    end
    debug.log("Camera position:", camera.position.x, camera.position.y, camera.position.z)
  end
end

function key(n, z)
  debug.log("main key()", n, z)
  if active_controller and active_controller.key then
    debug.log("Forwarding key event to controller")
    active_controller:key(n, z)
    update_scene()
  end
end

function enc(n, d)
  debug.log("main enc()", n, d)
  if active_controller and active_controller.enc then
    debug.log("Forwarding encoder event to controller")
    active_controller:enc(n, d)
    update_scene()
  end
end

function redraw()
  debug.log("Starting redraw")
  screen.clear()
  
  debug.log("Main scene objects:", #main_scene.objects)
  
  -- Render the scenes
  renderer:render_scene(main_scene)
  -- renderer:render_scene(overlay_scene)
  
  -- Update camera render state after successful render
  camera:update_render_state()
  
  screen.update()
  debug.log("Completed redraw")
end

function cleanup()
  clock.cancel(input_clock)
  clock.cancel(redraw_clock)
  -- Stop all LFOs
  for _, lfo_obj in pairs(rotation_lfos) do
    lfo_obj:stop()
  end
end

function set_active_controller(new_controller)
  active_controller = new_controller
  active_controller.camera = camera
end