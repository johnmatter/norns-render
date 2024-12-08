local debug = {}

function debug.log(...)
  local args = {...}
  local str = ""
  for i, v in ipairs(args) do
    str = str .. tostring(v) .. " "
  end
  
  -- Generate timestamp for filename
  local timestamp = os.date("%Y%m%d%H%M")
  local filename = string.format("norns-render-debug-%s.txt", timestamp)
  
  -- write to debug file
  local file = io.open(_path.data..filename, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. ": " .. str .. "\n")
    file:close()
  end

  -- print to console
  print(str)
end

return debug 