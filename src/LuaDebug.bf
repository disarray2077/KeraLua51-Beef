using System;
using System.Text;

namespace KeraLua
{
    /// Structure for lua debug information
    [CRepr]
    public struct LuaDebug
    {
        /// Debug event code
        public LuaHookEvent Event;
        /// a reasonable name for the given function. Because functions in Lua are first-class values, they do not have a fixed name: some functions can be the value of multiple global variables, while others can be stored only in a table field
        [Inline] public StringView Name => .(name);
        char8* name;
        /// explains the name field. The value of namewhat can be "global", "local", "method", "field", "upvalue", or "" (the empty string)
        [Inline] public StringView NameWhat => .(nameWhat);
        char8* nameWhat;
        /// the string "Lua" if the function is a Lua function, "C" if it is a C function, "main" if it is the main part of a chunk
        [Inline] public StringView What => .(what);
        char8* what;
        /// the name of the chunk that created the function. If source starts with a '@', it means that the function was defined in a file where the file name follows the '@'.
        [Inline] public StringView Source => .(source, SourceLength);
        char8* source;

        /// The length of the string source
        [Inline] public int32 SourceLength => (int32)String.StrLen(source);

        /// the current line where the given function is executing. When no line information is available, currentline is set to -1
        public int32 CurrentLine;
        /// number of upvalues
        public int32 NumberUpValues;
        public int32 LineDefined;
        /// the line number where the definition of the function ends.
        public int32 LastLineDefined;
        
        char8[60] shortSource;

        /// a "printable" version of source, to be used in error messages
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