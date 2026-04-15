-- This file is part of SA MoonLoader package.
-- Licensed under the MIT License.
-- Copyright (c) 2016, BlastHack Team <blast.hk>

local util = require 'extensions-lite.core.util'
local stringex = {}

local patternescape = function(str) -- lume for funcs
   return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

function stringex.split(str, delim, plain) -- bh FYP
   util.checkType("string", str, "string", delim)
   -- assert(type(str) == "string", ("bad argument #1 to 'split' (string expected, got %s)"):format(type(str)))
   -- assert(type(delim) == "string", ("bad argument #2 to 'split' (string expected, got %s)"):format(type(delim)))
   local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
   repeat
       local npos, epos = string.find(str, delim, pos, plain)
       table.insert(tokens, string.sub(str, pos, npos and npos - 1))
       pos = epos and epos + 1
   until not pos
   return tokens
end

function stringex.trim(str, chars) -- lume
   util.checkType("string", str)
   if not chars then
      return str:match("^[%s]*(.-)[%s]*$")
   end
   local chars = patternescape(chars)
   return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function stringex.contains(str, substr)
   util.checkType("string", str, "string", substr)
   return string.find(str, substr, 1, true) ~= nil
end

function stringex.rfind(str, pattern, offset, plain)
   util.checkType("string", str, "string", pattern)
   local pos, lnpos, lepos, plain = offset and offset - 1 or 0, offset or 1, -1, not (plain == false)
   repeat
      local npos, epos = string.find(str, pattern, pos, plain)
      pos = epos and epos + 1
      if pos then
         lnpos, lepos = npos, epos
      end
   until not pos
   return lnpos, lepos
end

return stringex
