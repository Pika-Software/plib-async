local PromiseMeta = debug.getregistry().Promise or {}
debug.getregistry().Promise = PromiseMeta

--[[-------------------------------------------
    Promise Class
---------------------------------------------]]
PromiseMeta.__index = PromiseMeta
PromiseMeta.MetaName = "Promise"

PromiseMeta.__onFulfilled = function() end
PromiseMeta.__onRejected = error
PromiseMeta.__onFinally = function() end

function PromiseMeta:getStatus()
   return self._state or "invalid"
end

function PromiseMeta:isValid()
   return self._state != nil
end

function PromiseMeta:__tostring()
   return string.format("Promise <%s>", self:getStatus())
end

function PromiseMeta:resolve(...)
   if not self:isValid() then return end
   if self._state != "pending" then return end

   self._state = "fulfilled"

   if self._onFulfilled then
      xpcall(self._onFulfilled, ErrorNoHaltWithStack, ...)
   else
      self._value = {...}
   end

   if self._onFinally then
      xpcall(self._onFinally, ErrorNoHaltWithStack)
   end
end

function PromiseMeta:reject(err)
   if not self:isValid() then return end
   if self._state != "pending" then return end

   self._state = "rejected"

   if self._onRejected then
      xpcall(self._onRejected, ErrorNoHaltWithStack, err)
   else
      self._value = err
   end

   if self._onFinally then
      xpcall(self._onFinally, ErrorNoHaltWithStack)
   end
end

function PromiseMeta:on(onFulfilled)
   if not self:isValid() then return self end
   if type(onFulfilled) != "function" then
      onFulfilled = self.__onFulfilled
   end

   self._onFulfilled = onFulfilled

   if self._state == "fulfilled" then
      xpcall(self._onFulfilled, ErrorNoHaltWithStack, unpack(self._value))
   end

   return self
end

function PromiseMeta:catch(onRejected)
   if not self:isValid() then return self end
   if type(onRejected) != "function" then
      onRejected = self.__onRejected
   end

   self._onRejected = onRejected

   if self._state == "rejected" then
      xpcall(self._onRejected, ErrorNoHaltWithStack, self._value)
   end

   return self
end

function PromiseMeta:finally(onFinally)
   if not self:isValid() then return self end
   if type(onFinally) != "function" then
      onFinally = self.__onFinally
   end

   self._onFinally = onFinally

   if self._state != "pending" then
      xpcall(self._onFinally, ErrorNoHaltWithStack)
   end

   return self
end

--[[-------------------------------------------
    Promise Global
---------------------------------------------]]
Promise = Promise or {}
local Promise = Promise

setmetatable(Promise, {
   __call = function(self, ...)
      return self.new(...)
   end
})

function Promise.new(func)
   assert(type(func) == "function", "bad argument #1 (function expected)")
   local p = setmetatable({}, PromiseMeta)
   p._state = "pending"

   local function resolve(...)
      p:resolve(...)
   end

   local function reject(...)
      p:reject(...)
   end

   func(resolve, reject)
   return p
end

function Promise.resolve(...)
   local p = setmetatable({}, PromiseMeta)
   p._state = "pending"

   p:resolve(...)
   return p
end

function Promise.reject(err)
   local p = setmetatable({}, PromiseMeta)
   p._state = "pending"

   p:reject(err)
   return p
end