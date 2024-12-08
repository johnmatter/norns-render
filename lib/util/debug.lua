local DebugLog = {}
DebugLog.__index = DebugLog

function DebugLog:new()
  local instance = setmetatable({}, DebugLog)
  instance.timestamp = os.date("%Y%m%d%H%M")
  instance.filename = string.format("norns-render-debug-%s.txt", instance.timestamp)
  return instance
end

function DebugLog:log(...)
  local args = {...}
  local str = ""
  for i, v in ipairs(args) do
    str = str .. tostring(v) .. " "
  end
  
  -- write to debug file
  local file = io.open(_path.data..self.filename, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. ": " .. str .. "\n")
    file:close()
  end

  -- print to console
  print(str)
end

-- Create a singleton instance
local debug = DebugLog:new()

return debug 