local mod = {}

function mod.checkType(...)
   local dinfo = debug.getinfo(2, "n")
   local len = select('#', ...)
   for i = 1, len, 2 do
      local validType = select(i, ...)
      local curentType = type(select(i + 1, ...))
      assert(curentType == validType, ("bad argument #%d to '%s' (%s expected, got %s)"):format(math.floor((i + 1) / 2), dinfo.name, validType, curentType))
   end
end

function mod.checkGenType(gtype, ...)
   local dinfo = debug.getinfo(2, "n")
   local len = select('#', ...)
   for i = 1, len do
      local curentType = type(select(i, ...))
      assert(curentType == gtype, ("bad argument #%d to '%s' (%s expected, got %s)"):format(i, dinfo.name, validType, curentType))
   end
end

return mod
