PLib:SH("plib/modules/async", "sh_promise.lua")

function await(p)
   assert(type(p) == "table" and p.MetaName == "Promise", "bad argument #1 (Promise expected)")
   assert(p:getStatus() != "invalid", "passed invalid Promise")

   if p:getStatus() != "pending" then
      if p:getStatus() == "fulfilled" then
         local args
         p:on(function(...)
            args = {...}
         end)

         return unpack(args)
      else
         local err
         p:catch(function(e)
            err = e
         end)

         error(err or "unknown error")
      end

      return -- ???
   end

   local co = coroutine.running()

   p:on(function(...)
      local ok, err = coroutine.resume(co, true, {...})
      assert(ok, err)
   end):catch(function(err)
      local ok, err = coroutine.resume(co, false, err)
      assert(ok, err)
   end)

   local ok, args = coroutine.yield()
   if not ok then
      error(args)
   end

   return unpack(args)
end

function async(func, ...)
   assert(type(func) == "function", "bad argument #1 (function expected)")

   local co = coroutine.create(func)
   local ok, err = coroutine.resume(co, ...)
   assert(ok, err)
end

PLib:SharedLoad("plib/modules/async/libs")

async(function()
   local body, size, headers, code = await(http.AsyncFetch('https://google.com'))

   print('https://google.com returned ' .. code)
end)