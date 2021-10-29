return {
   Name = "Async",
   DisableAutoload = true,
   Init = function(PLib)
      PLib:SH("plib/modules/async", "sh_core.lua")
      PLib:Log(nil, "Module Loaded: ", PLib._C.module, "Async")
   end
}