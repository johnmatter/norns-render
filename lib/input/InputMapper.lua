local InputAction = include('lib/input/InputAction')
local InputBinding = include('lib/input/InputBinding')

InputMapper = {}
InputMapper.__index = InputMapper

function InputMapper:new()
  local mapper = {
    bindings = {},
    active_modifiers = {
      k1 = false,
      k2 = false,
      k3 = false
    }
  }
  setmetatable(mapper, self)
  return mapper
end

function InputMapper:map_norns_controls()
  -- All keys can act as modifiers
  self.bindings.keys = {
    [1] = {
      [1] = InputBinding:new(InputAction.MODIFIER_K1, 1),
      [0] = InputBinding:new(InputAction.MODIFIER_K1, 0)
    },
    [2] = {
      [1] = InputBinding:new(InputAction.MODIFIER_K2, 1),
      [0] = InputBinding:new(InputAction.MODIFIER_K2, 0)
    },
    [3] = {
      [1] = InputBinding:new(InputAction.MODIFIER_K3, 1),
      [0] = InputBinding:new(InputAction.MODIFIER_K3, 0)
    }
  }
  
  -- Encoder mappings based on modifier combinations
  self.bindings.encoders = {
    [1] = function(delta)
      if self.active_modifiers.k1 and self.active_modifiers.k2 then
        return InputBinding:new(InputAction.PAN_X, delta * 0.05)
      elseif self.active_modifiers.k1 and self.active_modifiers.k3 then
        return InputBinding:new(InputAction.PAN_Y, delta * 0.05)
      elseif self.active_modifiers.k1 then
        return InputBinding:new(InputAction.ORBIT_VERTICAL, delta * 0.1)
      else
        return InputBinding:new(InputAction.ORBIT_HORIZONTAL, delta * 0.1)
      end
    end,
    [2] = function(delta)
      if self.active_modifiers.k1 and self.active_modifiers.k2 then
        return InputBinding:new(InputAction.ROTATE_X, delta * 0.05)
      elseif self.active_modifiers.k2 then
        return InputBinding:new(InputAction.PAN_Z, delta * 0.1)
      else
        return InputBinding:new(InputAction.ZOOM, delta * 0.1)
      end
    end,
    [3] = function(delta)
      if self.active_modifiers.k1 and self.active_modifiers.k3 then
        return InputBinding:new(InputAction.ROTATE_Z, delta * 0.05)
      elseif self.active_modifiers.k3 then
        return InputBinding:new(InputAction.ROTATE_Y, delta * 0.1)
      else
        return InputBinding:new(InputAction.ZOOM, delta * -0.1)
      end
    end
  }
end

function InputMapper:handle_key(n, z)
  local binding = self.bindings.keys[n] and self.bindings.keys[n][z]
  if binding then
    if binding.action:match("_MODIFIER$") then
      self.active_modifiers[binding.action] = (binding.value ~= 0)
    end
    return binding
  end
  return nil
end

function InputMapper:handle_encoder(n, delta)
  local binding_fn = self.bindings.encoders[n]
  if binding_fn then
    return binding_fn(delta)
  end
  return nil
end

return InputMapper 