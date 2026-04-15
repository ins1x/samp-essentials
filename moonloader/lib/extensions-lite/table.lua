-- This file is part of SA MoonLoader package.
-- Licensed under the MIT License.
-- Copyright (c) 2016, BlastHack Team <blast.hk>

local util = require 'extensions-lite.core.util'
local tableex = {}

 -- http://lua-users.org/wiki/CopyTable
function tableex.deepcopy(object, mt)
   util.checkType("table", object)
   local lookup_table = {}
   mt = mt or false
   local function _copy(object)
         if type(object) ~= "table" then
            return object
         elseif lookup_table[object] then
            return lookup_table[object]
         end
         local new_table = {}
         lookup_table[object] = new_table
         for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
         end
         return mt and setmetatable(new_table, getmetatable(object)) or new_table
   end
   return _copy(object)
end

function tableex.copy(object, mt)
   util.checkType("table", object)
   mt = mt or false
   local newt = {}
   for k, v in pairs(object) do
      newt[k] = v
   end
   return mt and setmetatable(newt, getmetatable(object)) or newt
end

function tableex.contains(object, value)
   util.checkType("table", object, "string", value)
   for k, v in pairs(object) do
      if v == value then
         return true
      end
   end
   return false
end

function tableex.merge(...)
   local len = select('#', ...)
   assert(len > 1, "impossible to merge less than two tables")
   util.checkGenType("table", ...)
   local newTable = {}
   for i = 1, len do
      local t = select(i, ...)
      for k, v in pairs(t) do
         table.insert(newTable, v)
      end
   end
   return newTable
end

function tableex.assocMerge(...)
   local len = select('#', ...)
   assert(len > 1, "impossible to merge less than two tables")
   util.checkGenType("table", ...)
   local newTable = {}
   for i = 1, len do
      local t = select(i, ...)
      for k, v in pairs(t) do
         newTable[k] = v
      end
   end
   return newTable
end

function tableex.map(object, func) -- lume
   util.checkType("table", object, "function", func)
   local newTable = {}
   for k, v in pairs(object) do
      if type(v) == "table" then
         newTable[k] = tableex.map(v, func)
      else
         newTable[k] = func(v)
      end
   end
   return newTable
end

function tableex.transform(object, func)
   util.checkType("table", object, "function", func)
   for k, v in pairs(object) do
      if type(v) == "table" then
         object[k] = tableex.transform(v, func)
      else
         object[k] = func(v)
      end
   end
   return object
end

function tableex.invert(object) -- lume
   util.checkType("table", object)
   local newTable = {}
   for k, v in pairs(object) do
      newTable[v] = k
   end
   return newTable
 end

 function tableex.keys(object) -- lume
   util.checkType("table", object)
   local newTable = {}
   local i = 0
   for k in pairs(object) do
      i = i + 1
      newTable[i] = k
   end
   return newTable
 end

 function tableex.getIndexOf(object, value)
   util.checkType("table", object, "string", value)
   for k, v in pairs(object) do
      if v == value then
         return k
      end
   end
   return nil
end

function tableex.removeByValue(object, value)
   util.checkType("table", object)
   local getIndexOf = tableex.getIndexOf(object, value)
   if getIndexOf then
      object[getIndexOf] = nil
   end
   return getIndexOf
end

return tableex
