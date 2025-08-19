using System;

namespace KeraLua
{
    /// <summary>
    /// Operation value used by Arith method
    /// </summary>
    public enum LuaOperation : int32
    {
        /// <summary>
        /// adition(+)
        /// </summary>
        Add = 0,
        /// <summary>
        ///  substraction (-)
        /// </summary>
        Sub = 1,
        /// <summary>
        /// Multiplication (*)
        /// </summary>
        Mul = 2,

        /// <summary>
        /// Modulo (%)
        /// </summary>
        Mod = 3,

        /// <summary>
        /// Exponentiation (^)
        /// </summary>
        Pow = 4,
        /// <summary>
        ///  performs float division (/)
        /// </summary>
        Div = 5
    }

	extension LuaOperation
	{
		[Inline]
		public static implicit operator int32(LuaOperation op)
		{
			return op.Underlying;
		}
	}
}