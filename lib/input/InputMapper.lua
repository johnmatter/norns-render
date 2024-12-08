local InputAction = include('lib/input/InputAction')
local InputBinding = include('lib/input/InputBinding')

InputMapper = {}
InputMapper.__index = InputMapper

function InputMapper:new()
  local mapper = {
    bindings = {
      digital = {},  -- For buttons, keys, digital triggers
      analog = {},   -- For axes, encoders, analog inputs
    },
    active_modifiers = {}
  }
  setmetatable(mapper, self)
  return mapper
end

function InputMapper:map_digital(id, state, action, value)
  if not self.bindings.digital[id] then
    self.bindings.digital[id] = {}
  end
  self.bindings.digital[id][state] = InputBinding:new(action, value or state)
end

function InputMapper:map_analog(id, action, scale)
  self.bindings.analog[id] = function(value)
    return InputBinding:new(action, value * (scale or 1.0))
  end
end

function InputMapper:handle_digital(id, state)
  local binding = self.bindings.digital[id] and self.bindings.digital[id][state]
  if binding then
    if binding.action:match("_MODIFIER$") then
      self.active_modifiers[binding.action] = (binding.value ~= 0)
    end
    return binding
  end
  return nil
end

function InputMapper:handle_analog(id, value)
  local binding_fn = self.bindings.analog[id]
  if binding_fn then
    return binding_fn(value)
  end
  return nil
end

return InputMapper 