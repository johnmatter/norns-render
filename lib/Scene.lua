Scene = {}
Scene.__index = Scene

function Scene:new()
  local scene = {
    objects = {},
    render_style = nil  -- If nil, use Renderer's 
  }
  setmetatable(scene, self)
  return scene
end

function Scene:add(shape)
  table.insert(self.objects, shape)
end

function Scene:remove(shape)
  for i, obj in ipairs(self.objects) do
    if obj == shape then
      table.remove(self.objects, i)
      break
    end
  end
end

function Scene:clear()
  self.objects = {}
end

function Scene:set_render_style(style)
  self.render_style = style
end

return Scene