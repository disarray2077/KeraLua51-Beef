using System;

namespace KeraLua
{
    /// <summary>
    /// Garbage Collector operations
    /// </summary>
    public enum LuaGC : int32
    {
        /// <summary>
        ///  Stops the garbage collector. 
        /// </summary>
        Stop = 0,
        /// <summary>
        /// Restarts the garbage collector. 
        /// </summary>
        Restart = 1,
        /// <summary>
        /// Performs a full garbage-collection cycle. 
        /// </summary>
        Collect = 2,
        /// <summary>
        ///  Returns the current amount of memory (in Kbytes) in use by Lua. 
        /// </summary>
        Count = 3,
        /// <summary>
        ///  Returns the remainder of dividing the current amount of bytes of memory in use by Lua by 1024
        /// </summary>
        Countb = 4,
        /// <summary>
        ///  Performs an incremental step of garbage collection. 
        /// </summary>
        Step = 5,
        /// <summary>
        /// The options LUA_GCSETPAUSE and LUA_GCSETSTEPMUL of the function lua_gc are deprecated. You should use the new option LUA_GCINC to set them. 
        /// </summary>
        SetPause = 6,
        /// <summary>
        /// The options LUA_GCSETPAUSE and LUA_GCSETSTEPMUL of the function lua_gc are deprecated. You should use the new option LUA_GCINC to set them. 
        /// </summary>
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