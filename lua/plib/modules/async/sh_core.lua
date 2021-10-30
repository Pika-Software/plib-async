PLib:SH("plib/modules/async", "sh_promise.lua")

function await(p)
   assert(type(p) == "table" and p.MetaName == "Promise", "bad argument #1 (Promise expected)")
   assert(p:getStatus() != "invalid", "passed invalid Promise")
   assert(coroutine.running() != nil, "await must be called within async function")

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

function async(func)
   assert(type(func) == "function", "bad argument #1 (function expected)")

   return function(...)
      local args = {...}

      return Promise(function(res, rej)
         local co = coroutine.create(function(...)
            local args = {pcall(func, ...)}

            if args[1] then
               res(unpack(args, 2))
            else
               rej(args[2])
            end
         end)

         local ok, err = coroutine.resume(co, unpack(args))
         assert(ok, err)
      end):catch()
   end
end

PLib:SharedLoad("plib/modules/async/libs")