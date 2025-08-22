using System;

namespace KeraLua
{
    /// Operation value used by Arith method
    public enum LuaOperation : int32
    {
        /// adition(+)
        Add = 0,
        /// substraction (-)
        Sub = 1,
        /// Multiplication (*)
        Mul = 2,

        /// Modulo (%)
        Mod = 3,

        /// Exponentiation (^)
        Pow = 4,
        /// performs float division (/)
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