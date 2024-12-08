local debug = {}

function debug.log(...)
  local args = {...}
  local str = ""
  for i, v in ipairs(args) do
    str = str .. tostring(v) .. " "
  end
  
  local file = io.open(_path.data.."norns-render-debug.txt", "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S") .. ": " .. str .. "\n")
    file:close()
  end
end

return debug 