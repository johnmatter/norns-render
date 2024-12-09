local DebugLog = {}
DebugLog.__index = DebugLog

-- Private instance variable
local instance = nil

local function log(...)
  if not DEBUG_LOGGING_ENABLED then return end  -- Exit if logging is disabled

  local args = {...}
  local str = ""
  for i, v in ipairs(args) do
    str = str .. tostring(v) .. " "
  end
  
  -- write to debug file
  local file = io.open(_path.data..instance.filename, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. ": " .. str .. "\n")
    file:close()
  end

  -- print to console
  print(str)
end

-- Create singleton instance
instance = {
  timestamp = os.date("%Y%m%d%H%M"),
  filename = nil,
  log = log
}
instance.filename = string.format("norns-render-debug-%s.txt", instance.timestamp)

return instance 