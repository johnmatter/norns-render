local gamepad = require('gamepad')
local Light = include("lib/Light")
local Renderer = include("lib/Renderer")
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

local DEBUG_LOGGING_ENABLED = false

local camera = Camera:new(0, 0, -20)
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

local main_scene_fps = 15
local last_main_update = 0

local active_controller
redraw_metro = nil
input_clock = nil

-- Add at the top with other local variables
local current_shape_index = 1
local shapes = {
  "cube",
  "cylinder", 
  "sphere",
  "tetrahedron",
  "octahedron"
}

-- Add this function to create a new shape
function create_shape(shape_type)
  local Geom = include('lib/Geoms/Geom')
  local Cube = include('lib/Geoms/Cube')
  local Cylinder = include('lib/Geoms/Cylinder')
  local Sphere = include('lib/Geoms/Sphere')
  local PlatonicSolid = include('lib/Geoms/PlatonicSolid')
  
  if shape_type == "cube" then
    return Cube:new(2)
  elseif shape_type == "cylinder" then
    return Cylinder:new(1, 3, 16)
  elseif shape_type == "sphere" then
    return Sphere:new(1.5, 16, 16)
  elseif shape_type == "tetrahedron" then
    return PlatonicSolid:new(PlatonicSolid.Types.TETRAHEDRON, 2)
  elseif shape_type == "octahedron" then
    return PlatonicSolid:new(PlatonicSolid.Types.OCTAHEDRON, 2)
  end
end

-- Add these functions to handle the new actions
function cycle_shape()
  current_shape_index = (current_shape_index % #shapes) + 1
  main_scene.objects = {}  -- Clear existing objects
  local new_shape = create_shape(shapes[current_shape_index])
  new_shape:translate(Vector:new(0, 0, 0))
  main_scene:add(new_shape)
end

function random_rotate()
  if #main_scene.objects > 0 then
    local shape = main_scene.objects[1]
    shape:rotate(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
  end
end

-- Modify the handle_action function in Camera.lua to handle these new actions
function Camera:handle_action(action, value)
  if action == InputAction.CYCLE_SHAPE then
    cycle_shape()
    return true
  elseif action == InputAction.RANDOM_ROTATE then
    random_rotate()
    return true
  end
  
  if self.orbital_mode then
    return self:handle_orbital_action(action, value)
  else
    return self:handle_free_action(action, value)
  end
end

-- init
function init()
  -- Parameter for cube scale
  params:add_control("scale", "Scale", controlspec.new(0.1, 5, 'lin', 0.01, 1, "", 0.01))
  
  -- Parameter change callback
  params.action_write = function(filename)
    update_scene()
  end
  
  -- Add to parameters group first
  params:add_option("control_scheme", "Control Scheme", {"Norns", "Keyboard", "Gamepad"}, 1)
  params:set_action("control_scheme",
    function(value)
      if value == 2 then
        set_active_controller(KeyboardController:new())
      elseif value == 3 then
        set_active_controller(ProController:new())
      else
        set_active_controller(NornsController:new())
      end
    end
  )
  
  -- Initialize with Norns controller by default
  set_active_controller(NornsController:new())
  
  -- Setup gamepad callback only if user switches to gamepad mode
  if gamepad then
    -- Register connect callback
    gamepad.connect = function(id)
      debug.log("Gamepad " .. id .. " connected")
      if active_controller.connect and params:get("control_scheme") == 3 then
        active_controller:connect(id)
      end
    end
    
    -- Register disconnect callback
    gamepad.disconnect = function(id)
      debug.log("Gamepad " .. id .. " disconnected")
      if active_controller.disconnect and params:get("control_scheme") == 3 then
        active_controller:disconnect()
      end
    end
  end
  
  -- Create geometric objects
  local Geom = include('lib/Geoms/Geom')
  local Cube = include('lib/Geoms/Cube')
  local Cylinder = include('lib/Geoms/Cylinder')
  local Sphere = include('lib/Geoms/Sphere')
  local PlatonicSolid = include('lib/Geoms/PlatonicSolid')
  
  -- Arrange objects

  -- geom = Cube:new(2)
  -- geom = main_scene:add(Cylinder:new(1, 3, 16))
  -- geom = Sphere:new(1.5, 16, 16)
  -- geom = PlatonicSolid:new(PlatonicSolid.Types.TETRAHEDRON, 2)

  local initial_shape = create_shape(shapes[current_shape_index])
  initial_shape:translate(Vector:new(0, 0, 0))
  main_scene:add(initial_shape)

  
  -- Set render styles
  main_scene:set_render_style(Renderer.RenderStyle.WIREFRAME)
  
  -- Initialize input polling clock
  input_clock = clock.run(function()
    debug.log("Input clock started")
    while true do
      clock.sleep(1/30) -- 30Hz polling rate
      if active_controller and active_controller.poll then
        active_controller:poll()
        update_scene()
      end
    end
  end)
  
  -- Initialize redraw metro
  local redraw_event = function()
    local menu_status = norns.menu.status()
    debug.log("Redraw metro tick, menu_status:", menu_status)
    if not menu_status then
      redraw()
    end
  end

  -- Try to get a metro from the pool
  redraw_metro = metro.init()
  if redraw_metro then
    redraw_metro.event = redraw_event
    redraw_metro.time = 1/fps
    redraw_metro:start()
  else
    print("ERROR: No metros available in pool")
    -- Fallback to a clock-based redraw
    redraw_clock = clock.run(function()
      while true do
        clock.sleep(1/fps)
        redraw_event()
      end
    end)
  end
  
  -- Log scene details
  if DEBUG_LOGGING_ENABLED then
    debug.log("Main scene objects:", #main_scene.objects)
    for i, obj in ipairs(main_scene.objects) do
      debug.log(string.format("Object %d: Type=%s, Position=%s", 
        i, 
        obj.type or "Geom", 
        tostring(obj.position)
      ))
    end
  end
end

-- Update scene based on controller inputs
function update_scene()
  if active_controller then
    -- Controller updates camera directly through input bindings
    if active_controller.update then
      active_controller:update()
    end
    debug.log(string.format("Camera position: %s", tostring(camera.position)))
  end
end

-- Redraw function
function redraw()
  local success, err = pcall(function()
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
  end)
  
  if not success then
    debug.log("Error in redraw:", err)
  end
end

-- Cleanup function
function cleanup()
  -- Cancel the input clock
  if input_clock then
    clock.cancel(input_clock)
    input_clock = nil
  end
  
  -- Stop and free the redraw metro
  if redraw_metro then
    redraw_metro:stop()
    redraw_metro:free()
    redraw_metro = nil
  end
end

-- Set active controller
function set_active_controller(new_controller)
  active_controller = new_controller
  active_controller.camera = camera
end

-- Key event handler
function key(n, z)
  if DEBUG_LOGGING_ENABLED then debug.log("main key()", n, z) end
  if active_controller and active_controller.key then
    if DEBUG_LOGGING_ENABLED then debug.log("Forwarding key event to controller") end
    active_controller:key(n, z)
    update_scene()
  end
end

-- Encoder event handler
function enc(n, d)
  if DEBUG_LOGGING_ENABLED then debug.log("main enc()", n, d) end
  if active_controller and active_controller.enc then
    if DEBUG_LOGGING_ENABLED then debug.log("Forwarding encoder event to controller") end
    active_controller:enc(n, d)
    update_scene()
  end
end
