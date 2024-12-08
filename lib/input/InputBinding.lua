local InputAction = include('lib/input/InputAction')

InputBinding = {}
InputBinding.__index = InputBinding

function InputBinding:new(action, value, modifier)
  return setmetatable({
    action = action,
    value = value or 1.0,
    modifier = modifier or 1.0
  }, self)
end

return InputBinding 