using System;

namespace KeraLua
{
    /// Garbage Collector operations
    public enum LuaGC : int32
    {
        /// Stops the garbage collector.
        Stop = 0,
        /// Restarts the garbage collector.
        Restart = 1,
        /// Performs a full garbage-collection cycle.
        Collect = 2,
        /// Returns the current amount of memory (in Kbytes) in use by Lua.
        Count = 3,
        /// Returns the remainder of dividing the current amount of bytes of memory in use by Lua by 1024
        Countb = 4,
        /// Performs an incremental step of garbage collection.
        Step = 5,
        /// The options LUA_GCSETPAUSE and LUA_GCSETSTEPMUL of the function lua_gc are deprecated. You should use the new option LUA_GCINC to set them.
        SetPause = 6,
        /// The options LUA_GCSETPAUSE and LUA_GCSETSTEPMUL of the function lua_gc are deprecated. You should use the new option LUA_GCINC to set them.
        SetStepMultiplier = 7
    }

	extension LuaGC
	{
		[Inline]
		public static implicit operator int32(LuaGC status)
		{
			return status.Underlying;
		}
	}
}