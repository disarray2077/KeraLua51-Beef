using System;

namespace KeraLua
{
    /// <summary>
    /// Enum for pseudo-index used by globals table
    /// </summary>
    public enum LuaGlobals : int32
    {
        /* LUAI_MAXSTACK		1000000 */
        /// <summary>
        /// pseudo-index used by globals table
        /// </summary>
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