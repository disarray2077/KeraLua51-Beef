using System;

namespace KeraLua
{
    /// Enum for pseudo-index used by globals table
    public enum LuaGlobals : int32
    {
        /* LUAI_MAXSTACK		1000000 */
        /// pseudo-index used by globals table
        Index = -10002
    }

	extension LuaGlobals
	{
		[Inline]
		public static implicit operator int32(LuaGlobals status)
		{
			return status.Underlying;
		}
	}
}