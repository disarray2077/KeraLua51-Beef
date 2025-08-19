using System;
using System.Text;

namespace KeraLua
{
    /// <summary>
    /// Structure for lua debug information
    /// </summary>
    /// <remarks>
    /// Do not change this struct because it must match the lua structure lua_Debug
    /// </remarks>
    /// <author>Reinhard Ostermeier</author>
    [CRepr]
    public struct LuaDebug
    {
        /// <summary>
        /// Debug event code
        /// </summary>
        public LuaHookEvent Event;
        /// <summary>
        ///  a reasonable name for the given function. Because functions in Lua are first-class values, they do not have a fixed name: some functions can be the value of multiple global variables, while others can be stored only in a table field
        /// </summary>
        [Inline] public StringView Name => .(name);
        char8* name;
        /// <summary>
        /// explains the name field. The value of namewhat can be "global", "local", "method", "field", "upvalue", or "" (the empty string)
        /// </summary>
        [Inline] public StringView NameWhat => .(nameWhat);
        char8* nameWhat;
        /// <summary>
        ///  the string "Lua" if the function is a Lua function, "C" if it is a C function, "main" if it is the main part of a chunk
        /// </summary>
        [Inline] public StringView What => .(what);
        char8* what;
        /// <summary>
        ///  the name of the chunk that created the function. If source starts with a '@', it means that the function was defined in a file where the file name follows the '@'.
        /// </summary>
        /// 
        [Inline] public StringView Source => .(source, SourceLength);
        char8* source;

        /// <summary>
        /// The length of the string source
        /// </summary>
        [Inline] public int32 SourceLength => (int32)String.StrLen(source);

        /// <summary>
        ///  the current line where the given function is executing. When no line information is available, currentline is set to -1
        /// </summary>
        public int32 CurrentLine;
        /// <summary>
        /// number of upvalues
        /// </summary>
        public int32 NumberUpValues;
        /// <summary>
        /// 
        /// </summary>
        public int32 LineDefined;
        /// <summary>
        ///  the line number where the definition of the function ends. 
        /// </summary>
        public int32 LastLineDefined;
        
        char8[60] shortSource;

        /// <summary>
        /// a "printable" version of source, to be used in error messages
        /// </summary>
        public StringView ShortSource
        {
            [Inline] get
            {
#unwarn
				return .(&shortSource[0]);
            }
        }

        void* i_ci;
    }
}