using System;
using System.Text;

using internal KeraLua;

namespace KeraLua
{
    /// <summary>
    /// Lua state class, main interface to use Lua library.
    /// </summary>
    public class Lua : IDisposable
    {
        private lua_State _luaState;
        private readonly Lua _mainState;

        /// <summary>
        /// Internal Lua handle pointer.
        /// </summary>
        public int Handle => _luaState;

        /// <summary>
        /// Encoding for the string conversions
        /// ASCII by default.
        /// </summary>
        public Encoding Encoding { get; set; }

        /// <summary>
        /// Get the main thread object, if the object is the main thread will be equal this
        /// </summary>
        public Lua MainThread => _mainState ?? this;

        /// <summary>
        /// Initialize Lua state, and open the default libs
        /// </summary>
        /// <param name="openLibs">flag to enable/disable opening the default libs</param>
        public this(bool openLibs = true)
        {
            Encoding = System.Text.Encoding.ASCII;

            _luaState = LuaMethods.luaL_newstate();

            if (openLibs)
                OpenLibs();
        }

        /// <summary>
        /// Initialize Lua state with allocator function and user data value
        /// This method will NOT open the default libs.
        /// Creates a new thread running in a new, independent state. Returns NULL if it cannot create the thread or the state (due to lack of memory). The argument f is the allocator function; Lua does all memory allocation for this state through this function (see lua_Alloc). The second argument, ud, is an opaque pointer that Lua passes to the allocator in every call. 
        /// </summary>
        /// <param name="allocator">LuaAlloc allocator function called to alloc/free memory</param>
        /// <param name="ud">opaque pointer passed to allocator</param>
        public this(LuaAlloc allocator, void* ud)
        {
            Encoding = System.Text.Encoding.ASCII;

            _luaState = LuaMethods.lua_newstate(allocator, ud);
        }

        private this(lua_State luaThread, Lua mainState)
        {
            _mainState = mainState;
            _luaState = luaThread;
            Encoding = mainState.Encoding;
        }

        private this(lua_State luaState)
        {
            Encoding = System.Text.Encoding.ASCII;

            _luaState = luaState;
        }


        /// <summary>
        /// Finalizer, will dispose the lua state if wasn't closed
        /// </summary>
        public ~this()
        {
            Dispose();
        }

        /// <summary>
        /// Destroys all objects in the given Lua state (calling the corresponding garbage-collection metamethods, if any) and frees all dynamic memory used by this state
        /// </summary>
        public void Close()
        {
            if (_luaState == 0 || _mainState != null)
                return;

            LuaMethods.lua_close(_luaState);
            _luaState = 0;
        }

        /// <summary>
        /// Dispose the lua context (calling Close)
        /// </summary>
        public void Dispose()
        {
            Close();
        }

        /// <summary>
        /// Converts the acceptable index idx into an equivalent absolute index (that is, one that does not depend on the stack top). 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public int32 AbsIndex(int32 index)
        {
            return LuaMethods.lua_absindex(_luaState, index);
        }

        /// <summary>
        /// Sets a new panic function and returns the old one
        /// </summary>
        /// <param name="panicFunction"></param>
        /// <returns></returns>
        public LuaFunction AtPanic(LuaFunction panicFunction)
        {
            return LuaMethods.lua_atpanic(_luaState, panicFunction);
        }

        /// <summary>
        ///  Calls a function. 
        ///  To call a function you must use the following protocol: first, the function to be called is pushed onto the stack; then, the arguments to the function are pushed in direct order;
        ///  that is, the first argument is pushed first. Finally you call lua_call; nargs is the number of arguments that you pushed onto the stack.
        ///  All arguments and the function value are popped from the stack when the function is called. The function results are pushed onto the stack when the function returns.
        ///  The number of results is adjusted to nresults, unless nresults is LUA_MULTRET. In this case, all results from the function are pushed;
        ///  Lua takes care that the returned values fit into the stack space, but it does not ensure any extra space in the stack. The function results are pushed onto the stack in direct order (the first result is pushed first), so that after the call the last result is on the top of the stack. 
        /// </summary>
        /// <param name="arguments"></param>
        /// <param name="results"></param>
        public void Call(int32 arguments, int32 results)
        {
            LuaMethods.lua_call(_luaState, arguments, results);
        }

        /// <summary>
        /// Ensures that the stack has space for at least n extra slots (that is, that you can safely push up to n values into it). It returns false if it cannot fulfill the request,
        /// </summary>
        /// <param name="nExtraSlots"></param>
        public bool CheckStack(int32 nExtraSlots)
        {
            return LuaMethods.lua_checkstack(_luaState, nExtraSlots) != 0;
        }

        /// <summary>
        /// Compares two Lua values. Returns 1 if the value at index index1 satisfies op when compared with the value at index index2
        /// </summary>
        /// <param name="index1"></param>
        /// <param name="index2"></param>
        /// <param name="comparison"></param>
        /// <returns></returns>
        public bool Compare(int32 index1, int32 index2, LuaCompare comparison)
        {
            return LuaMethods.lua_compare(_luaState, index1, index2, comparison) != 0;
        }

        /// <summary>
        /// Concatenates the n values at the top of the stack, pops them, and leaves the result at the top. If n is 1, the result is the single value on the stack (that is, the function does nothing);
        /// </summary>
        /// <param name="n"></param>
        public void Concat(int32 n)
        {
            LuaMethods.lua_concat(_luaState, n);
        }
        /// <summary>
        /// Copies the element at index fromidx into the valid index toidx, replacing the value at that position
        /// </summary>
        /// <param name="fromIndex"></param>
        /// <param name="toIndex"></param>
        public void Copy(int32 fromIndex, int32 toIndex)
        {
            LuaMethods.lua_copy(_luaState, fromIndex, toIndex);
        }

        /// <summary>
        /// Creates a new empty table and pushes it onto the stack. Parameter narr is a hint for how many elements the table will have as a sequence; parameter nrec is a hint for how many other elements the table will have
        /// </summary>
        /// <param name="elements"></param>
        /// <param name="records"></param>
        public void CreateTable(int32 elements, int32 records)
        {
            LuaMethods.lua_createtable(_luaState, elements, records);
        }

        /// <summary>
        /// Dumps a function as a binary chunk. Receives a Lua function on the top of the stack and produces a binary chunk that, if loaded again, results in a function equivalent to the one dumped
        /// </summary>
        /// <param name="writer"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public int32 Dump(LuaWriter writer, void* data)
        {
            return LuaMethods.lua_dump(_luaState, writer, data);
        }

        /// <summary>
        /// Generates a Lua error, using the value at the top of the stack as the error object. This function does a long jump
        /// (We want it to be inlined to avoid issues with managed stack)
        /// </summary>
        /// <returns></returns>
        [Inline, NoReturn]
        public int32 Error()
        {
            return LuaMethods.lua_error(_luaState);
        }

        /// <summary>
        /// Controls the garbage collector. 
        /// </summary>
        /// <param name="what"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public int32 GarbageCollector(LuaGC what, int32 data)
        {
            return LuaMethods.lua_gc(_luaState, what, data);
        }

        /// <summary>
        /// Returns the memory-allocation function of a given state. If ud is not NULL, Lua stores in *ud the opaque pointer given when the memory-allocator function was set. 
        /// </summary>
        /// <param name="ud"></param>
        /// <returns></returns>
        public LuaAlloc GetAllocFunction(ref void* ud)
        {
            return LuaMethods.lua_getallocf(_luaState, ref ud);
        }

        /// <summary>
        ///  Pushes onto the stack the value t[k], where t is the value at the given index. As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).
        /// </summary>
        /// <param name="index"></param>
        /// <param name="key"></param>
        /// <returns></returns>
		public void GetField(int32 index, StringView key)
		{
		    LuaMethods.lua_getfield(_luaState, index, key.ToScopeCStr!());
		}

        /// <summary>
        ///  Pushes onto the stack the value t[k], where t is the value at the given index. As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).
        /// </summary>
        /// <param name="index"></param>
        /// <param name="key"></param>
        /// <returns></returns>
        public void GetField(LuaRegistry index, StringView key)
        {
            GetField((int32)index, key);
        }

        /// <summary>
        /// Pushes onto the stack the value of the global name. Returns the type of that value
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public void GetGlobal(StringView name)
		{
		    LuaMethods.lua_getglobal(_luaState, name.ToScopeCStr!());
		}

        /// <summary>
        /// Pushes onto the stack the value t[i], where t is the value at the given index
        /// </summary>
        /// <param name="index"></param>
        /// <param name="i"></param>
        /// <returns></returns>
        public void GetInteger(int32 index, int64 i)
		{
		    PushInteger(i);
		    GetTable(index);
		}


        /// <summary>
        /// Gets information about a specific function or function invocation. 
        /// </summary>
        /// <param name="what"></param>
        /// <param name="ar"></param>
        /// <returns>This function returns false on error (for instance, an invalid option in what). </returns>
        public bool GetInfo(StringView what, LuaDebug* ar)
        {
            return LuaMethods.lua_getinfo(_luaState, what.ToScopeCStr!(), (int)(void*)ar) != 0;
        }

        /// <summary>
        /// Gets information about a specific function or function invocation. 
        /// </summary>
        /// <param name="what"></param>
        /// <param name="ar"></param>
        /// <returns>This function returns false on error (for instance, an invalid option in what). </returns>
        public bool GetInfo(StringView what, ref LuaDebug ar)
        {
            return GetInfo(what, &ar);
        }

        /// <summary>
        /// Gets information about a local variable of a given activation record or a given function. 
        /// </summary>
        /// <param name="ar"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public StringView GetLocal(LuaDebug* ar, int32 n)
        {
            char8* ptr = LuaMethods.lua_getlocal(_luaState, (int)(void*)ar, n);
            return .(ptr);
        }

        /// <summary>
        /// Gets information about a local variable of a given activation record or a given function. 
        /// </summary>
        /// <param name="ar"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public StringView GetLocal(ref LuaDebug ar, int32 n)
        {
            return GetLocal(&ar, n);
        }

        /// <summary>
        /// If the value at the given index has a metatable, the function pushes that metatable onto the stack and returns 1
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool GetMetaTable(int32 index)
        {
            return LuaMethods.lua_getmetatable(_luaState, index) != 0;
        }

        /// <summary>
        /// Gets information about the interpreter runtime stack. 
        /// </summary>
        /// <param name="level"></param>
        /// <param name="ar"></param>
        /// <returns></returns>
        public int32 GetStack(int32 level, LuaDebug* ar)
        {
            return LuaMethods.lua_getstack(_luaState, level, (int)(void*)ar);
        }

        /// <summary>
        /// Gets information about the interpreter runtime stack. 
        /// </summary>
        /// <param name="level"></param>
        /// <param name="ar"></param>
        /// <returns></returns>
        public int32 GetStack(int32 level, ref LuaDebug ar)
        {
            return GetStack(level, &ar);
        }


        /// <summary>
        /// Pushes onto the stack the value t[k], where t is the value at the given index and k is the value at the top of the stack. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void GetTable(int32 index)
		{
		    LuaMethods.lua_gettable(_luaState, index);
		}

        /// <summary>
        /// Pushes onto the stack the value t[k], where t is the value at the given index and k is the value at the top of the stack. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void GetTable(LuaRegistry index)
        {
            GetTable((int32)index);
        }


        /// <summary>
        /// Returns the index of the top element in the stack. 0 means an empty stack.
        /// </summary>
        /// <returns>Returns the index of the top element in the stack.</returns>
        public int32 GetTop() => LuaMethods.lua_gettop(_luaState);

        /// <summary>
        ///  Pushes onto the stack the 1th user value associated with the full userdata at the given index
        /// If the userdata does not have that value, pushes nil.
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void GetUserValue(int32 index)
		{
			LuaMethods.lua_getfenv(_luaState, index);
		}

        /// <summary>
        ///  Gets information about the n-th upvalue of the closure at index funcindex. It pushes the upvalue's value onto the stack and returns its name. Returns NULL (and pushes nothing) when the index n is greater than the number of upvalues.
        ///  For C functions, this function uses the empty string "" as a name for all upvalues. (For Lua functions, upvalues are the external local variables that the function uses, and that are consequently included in its closure.)
        ///  Upvalues have no particular order, as they are active through the whole function. They are numbered in an arbitrary order. 
        /// </summary>
        /// <param name="functionIndex"></param>
        /// <param name="n"></param>
        /// <returns>Returns the type of the pushed value. </returns>
        public StringView GetUpValue(int32 functionIndex, int32 n)
        {
            char8* ptr = LuaMethods.lua_getupvalue(_luaState, functionIndex, n);
            return .(ptr);
        }
            
		
        /// <summary>
        /// Returns the current hook function. 
        /// </summary>
        public LuaHookFunction Hook => LuaMethods.lua_gethook(_luaState);

        /// <summary>
        /// Returns the current hook count. 
        /// </summary>
        public int32 HookCount => LuaMethods.lua_gethookcount(_luaState);

        /// <summary>
        /// Returns the current hook mask. 
        /// </summary>
        public LuaHookMask HookMask => (LuaHookMask)LuaMethods.lua_gethookmask(_luaState);

        /// <summary>
        /// Moves the top element into the given valid index, shifting up the elements above this index to open space. This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position. 
        /// </summary>
        /// <param name="index"></param>
        public void Insert(int32 index) => LuaMethods.lua_insert(_luaState, index);

        /// <summary>
        /// Returns  if the value at the given index is a boolean
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsBoolean(int32 index) => Type(index) == LuaType.Boolean;

        /// <summary>
        /// Returns  if the value at the given index is a C(#) function
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsCFunction(int32 index) => LuaMethods.lua_iscfunction(_luaState, index) != 0;

        /// <summary>
        /// Returns  if the value at the given index is a function
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsFunction(int32 index) => Type(index) == LuaType.Function;

        /// <summary>
        /// Returns  if the value at the given index is an integer
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsInteger(int32 index) => LuaMethods.lua_isinteger(_luaState, index) != 0;

        /// <summary>
        /// Returns  if the value at the given index is light user data
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsLightUserData(int32 index) => Type(index) == LuaType.LightUserData;

        /// <summary>
        /// Returns  if the value at the given index is nil
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsNil(int32 index) => Type(index) == LuaType.Nil;

        /// <summary>
        /// Returns  if the value at the given index is none
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsNone(int32 index) => Type(index) == LuaType.None;

        /// <summary>
        /// Check if the value at the index is none or nil
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsNoneOrNil(int32 index) => IsNone(index) || IsNil(index);

        /// <summary>
        /// Returns  if the value at the given index is a number
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsNumber(int32 index) => LuaMethods.lua_isnumber(_luaState, index) != 0;

        /// <summary>
        /// Returns  if the value at the given index is a string or a number (which is always convertible to a string)
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsStringOrNumber(int32 index)
        {
            return LuaMethods.lua_isstring(_luaState, index) != 0;
        }

        /// <summary>
        /// Returns  if the value at the given index is a string
        /// NOTE: This is different from the lua_isstring, which return true if the value is a number
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsString(int32 index) => Type(index) == LuaType.String;

        /// <summary>
        /// Returns  if the value at the given index is a table. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsTable(int32 index) => Type(index) == LuaType.Table;

        /// <summary>
        /// Returns  if the value at the given index is a thread. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsThread(int32 index) => Type(index) == LuaType.Thread;

        /// <summary>
        /// Returns  if the value at the given index is a user data. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool IsUserData(int32 index) => LuaMethods.lua_isuserdata(_luaState, index) != 0;

        /// <summary>
        /// Returns  if the given coroutine can yield, and 0 otherwise
        /// </summary>
        public bool IsYieldable => LuaMethods.lua_isyieldable(_luaState) != 0;

        /// <summary>
        /// Push the length of the value at the given index on the stack. It is equivalent to the '#' operator in Lua (see §3.4.7) and may trigger a metamethod for the "length" event (see §2.4). The result is pushed on the stack. 
        /// </summary>
        /// <param name="index"></param>
        public void PushLength(int32 index)
		{
			if (LuaMethods.luaL_callmeta(_luaState, index, "__len") == 0)
			{
			    LuaMethods.lua_pushnumber(_luaState, (double)LuaMethods.lua_objlen(_luaState, index));
			}
		}

        /// <summary>
        /// Loads a Lua chunk without running it. If there are no errors, lua_load pushes the compiled chunk as a Lua function on top of the stack. Otherwise, it pushes an error message. 
        /// The lua_load function uses a user-supplied reader function to read the chunk (see lua_Reader). The data argument is an opaque value passed to the reader function. 
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="data"></param>
        /// <param name="chunkName"></param>
        /// <returns></returns>
        public LuaStatus Load
            (LuaReader reader,
             void* data,
             StringView chunkName)
        {
            return (LuaStatus)LuaMethods.lua_load(_luaState,
                                                     reader,
                                                     data,
                                                     chunkName.ToScopeCStr!());
        }

        /// <summary>
        /// Creates a new empty table and pushes it onto the stack
        /// </summary>
        public void NewTable() => LuaMethods.lua_createtable(_luaState, 0, 0);

        /// <summary>
        /// Creates a new thread, pushes it on the stack, and returns a pointer to a lua_State that represents this new thread. The new thread returned by this function shares with the original thread its global environment, but has an independent execution stack. 
        /// </summary>
        /// <returns></returns>
        public Lua NewThread()
        {
            lua_State thread = LuaMethods.lua_newthread(_luaState);
            return new Lua(thread, this);
        }
		
		/// <summary>
		///  This function creates and pushes on the stack a new full userdata, called user values, plus an associated block of raw memory with size bytes.
		///  The function returns the address of the block of memory.
		/// </summary>
		/// <param name="size"></param>
		/// <param name="uv"></param>
		/// <returns></returns>
        public void* NewUserData(int32 size)
        {
            return LuaMethods.lua_newuserdata(_luaState, (uint) size);
        }

        /// <summary>
        /// Pops a key from the stack, and pushes a key–value pair from the table at the given index (the "next" pair after the given key).
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool Next(int32 index) => LuaMethods.lua_next(_luaState, index) != 0;

        /// <summary>
        /// Calls a function in protected mode. 
        /// </summary>
        /// <param name="arguments"></param>
        /// <param name="results"></param>
        /// <param name="errorFunctionIndex"></param>
        public LuaStatus PCall(int32 arguments, int32 results, int32 errorFunctionIndex)
        {
            return (LuaStatus)LuaMethods.lua_pcall(_luaState, arguments, results, errorFunctionIndex);
        }

        /// <summary>
        /// Pops n elements from the stack. 
        /// </summary>
        /// <param name="n"></param>
        public void Pop(int32 n) => LuaMethods.lua_settop(_luaState, -n - 1);

        /// <summary>
        /// Pushes a boolean value with value b onto the stack. 
        /// </summary>
        /// <param name="b"></param>
        public void PushBoolean(bool b) => LuaMethods.lua_pushboolean(_luaState, b ? 1 : 0);

        /// <summary>
        ///  Pushes a new C closure onto the stack. When a C function is created, it is possible to associate 
        ///  some values with it, thus creating a C closure (see §4.4); these values are then accessible to the function 
        ///  whenever it is called. To associate values with a C function, first these values must be pushed onto the 
        ///  stack (when there are multiple values, the first value is pushed first). 
        ///  Then lua_pushcclosure is called to create and push the C function onto the stack, 
        ///  with the argument n telling how many values will be associated with the function. 
        ///  lua_pushcclosure also pops these values from the stack. 
        /// </summary>
        /// <param name="function"></param>
        /// <param name="n"></param>
        public void PushCClosure(LuaFunction func, int32 n)
        {
            LuaMethods.lua_pushcclosure(_luaState, func, n);
        }

        /// <summary>
        /// Pushes a C function onto the stack. This function receives a pointer to a C function and pushes onto the stack a Lua value of type function that, when called, invokes the corresponding C function. 
        /// </summary>
        /// <param name="function"></param>
        public void PushCFunction(LuaFunction func)
        {
            PushCClosure(func, 0);
        }

        /// <summary>
        /// Pushes the global environment onto the stack. 
        /// </summary>
        public void PushGlobalTable()
        {
            LuaMethods.lua_pushvalue(_luaState, LuaGlobals.Index);
        }
        /// <summary>
        /// Pushes an integer with value n onto the stack. 
        /// </summary>
        /// <param name="n"></param>
        public void PushInteger(int64 n) => LuaMethods.lua_pushinteger(_luaState, n);

        /// <summary>
        /// Pushes a light userdata onto the stack.
        /// Userdata represent C values in Lua. A light userdata represents a pointer, a void*. It is a value (like a number): you do not create it, it has no individual metatable, and it is not collected (as it was never created). A light userdata is equal to "any" light userdata with the same C address. 
        /// </summary>
        /// <param name="data"></param>
        public void PushLightUserData(void* data)
        {
            LuaMethods.lua_pushlightuserdata(_luaState, data);
        }

        /// <summary>
        /// Pushes a reference data (Beef object)  onto the stack. 
        /// This function uses lua_pushlightuserdata, but uses a GCHandle to store the reference inside the Lua side.
        /// The CGHandle is create as Normal, and will be freed when the value is pop
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="obj"></param>
        public void PushObject<T>(T obj)
        {
            if(obj == null)
            {
                PushNil();
                return;
            }

            PushLightUserData(Internal.UnsafeCastToPtr(obj));
        }


        /// <summary>
        /// Pushes binary buffer onto the stack (usually UTF encoded string) or any arbitraty binary data
        /// </summary>
        /// <param name="buffer"></param>
        public void PushBuffer(uint8[] buffer)
        {
            if(buffer == null)
            {
                PushNil();
                return;
            }

            LuaMethods.lua_pushlstring(_luaState, (.)buffer.Ptr, (.)buffer.Count);
        }
		
		/// <summary>
		/// Pushes binary buffer onto the stack (usually UTF encoded string) or any arbitraty binary data
		/// </summary>
		/// <param name="buffer"></param>
		public void PushBuffer<CSize>(uint8[CSize] buffer) where CSize : const int
        {
#unwarn
            LuaMethods.lua_pushlstring(_luaState, (.)&buffer[0], (.)CSize);
        }

        /// <summary>
        /// Pushes a string onto the stack
        /// </summary>
        /// <param name="value"></param>
        public void PushString(String value)
        {
            if(value == null)
            {
                PushNil();
                return;
            }

            uint8[] buffer = Encoding.GetBytes(value, .. ?);
            PushBuffer(buffer);
			delete buffer;
        }

        /// <summary>
        /// Pushes a string onto the stack
        /// </summary>
        /// <param name="value"></param>
        public void PushString(StringView value)
        {
            uint8[] buffer = Encoding.GetBytes(value, .. ?);
            PushBuffer(buffer);
			delete buffer;
        }

        /// <summary>
        /// Push a instring using string.Format 
        /// PushString("Foo {0}", 10);
        /// </summary>
        /// <param name="value"></param>
        /// <param name="args"></param>
        public void PushString(String value, params Object[] args)
        {
            PushString(scope String()..AppendF(value, params args));
        }

        /// <summary>
        /// Pushes a nil value onto the stack. 
        /// </summary>
        public void PushNil() => LuaMethods.lua_pushnil(_luaState);

        /// <summary>
        /// Pushes a double with value n onto the stack. 
        /// </summary>
        /// <param name="number"></param>
        public void PushNumber(double number) => LuaMethods.lua_pushnumber(_luaState, number);

        /// <summary>
        /// Pushes the current thread onto the stack. Returns true if this thread is the main thread of its state. 
        /// </summary>
        /// <returns></returns>
        public bool PushThread()
        {
            return LuaMethods.lua_pushthread(_luaState) == 1;
        }

		/// <summary>
		/// Pushes a copy of the element at the given index onto the stack. (lua_pushvalue)
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		public void PushValue(int32 index)
		{
		    LuaMethods.lua_pushvalue(_luaState, index);
		}

        /// <summary>
        /// Returns true if the two values in indices index1 and index2 are primitively equal (that is, without calling the __eq metamethod). Otherwise returns false. Also returns false if any of the indices are not valid. 
        /// </summary>
        /// <param name="index1"></param>
        /// <param name="index2"></param>
        /// <returns></returns>
        public bool RawEqual(int32 index1, int32 index2)
        {
            return LuaMethods.lua_rawequal(_luaState, index1, index2) != 0;
        }

        /// <summary>
        /// Similar to GetTable, but does a raw access (i.e., without metamethods). 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void RawGet(int32 index)
        {
           	LuaMethods.lua_rawget(_luaState, index);
        }

        /// <summary>
        /// Similar to GetTable, but does a raw access (i.e., without metamethods). 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void RawGet(LuaRegistry index)
        {
            LuaMethods.lua_rawget(_luaState, index);
        }

        /// <summary>
        /// Pushes onto the stack the value t[n], where t is the table at the given index. The access is raw, that is, it does not invoke the __index metamethod. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public void RawGetInteger(int32 index, int32 n)
        {
            LuaMethods.lua_rawgeti(_luaState, index, n);
        }

        /// <summary>
        /// Pushes onto the stack the value t[n], where t is the table at the given index. The access is raw, that is, it does not invoke the __index metamethod. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public void RawGetInteger(LuaRegistry index, int32 n)
        {
            LuaMethods.lua_rawgeti(_luaState, index, n);
        }


        /// <summary>
        /// Pushes onto the stack the value t[k], where t is the table at the given index and k is the pointer p represented as a light userdata. The access is raw; that is, it does not invoke the __index metamethod. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="obj"></param>
        /// <returns></returns>
        public void RawGetByHashCode<T>(int32 index, T obj) where T : IHashable
        {
            LuaMethods.lua_pushlightuserdata(_luaState, (void*)obj.GetHashCode());
			LuaMethods.lua_rawget(_luaState, index);
        }

        /// <summary>
        /// Returns the raw "length" of the value at the given index: for strings, this is the string length; for tables, this is the result of the length operator ('#') with no metamethods; for userdata, this is the size of the block of memory allocated for the userdata; for other values, it is 0. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public int32 RawLen(int32 index)
        {
            return (int32)LuaMethods.lua_objlen(_luaState, index);
        }

        /// <summary>
        /// Similar to lua_settable, but does a raw assignment (i.e., without metamethods).
        /// </summary>
        /// <param name="index"></param>
        public void RawSet(int32 index)
        {
            LuaMethods.lua_rawset(_luaState, index);
        }

        /// <summary>
        /// Similar to lua_settable, but does a raw assignment (i.e., without metamethods).
        /// </summary>
        /// <param name="index"></param>
        public void RawSet(LuaRegistry index)
        {
            LuaMethods.lua_rawset(_luaState, index);
        }

        /// <summary>
        ///  Does the equivalent of t[i] = v, where t is the table at the given index and v is the value at the top of the stack.
        ///  This function pops the value from the stack. The assignment is raw, that is, it does not invoke the __newindex metamethod. 
        /// </summary>
        /// <param name="index">index of table</param>
        /// <param name="i">value</param>
        public void RawSetInteger(int32 index, int32 i)
        {
            LuaMethods.lua_rawseti(_luaState, index, i);
        }

        /// <summary>
        ///  Does the equivalent of t[i] = v, where t is the table at the given index and v is the value at the top of the stack.
        ///  This function pops the value from the stack. The assignment is raw, that is, it does not invoke the __newindex metamethod. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="i"></param>
        public void RawSetInteger(LuaRegistry index, int32 i)
        {
            LuaMethods.lua_rawseti(_luaState, index, i);
        }


        /// <summary>
        /// Does the equivalent of t[p] = v, where t is the table at the given index, p is encoded as a light userdata, and v is the value at the top of the stack. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="obj"></param>
        public void RawSetByHashCode<T>(int32 index, T obj) where T : IHashable
        {
			LuaMethods.lua_pushlightuserdata(_luaState, (void*)obj.GetHashCode());
			LuaMethods.lua_insert(_luaState, -2);
			LuaMethods.lua_rawset(_luaState, index);
        }

        /// <summary>
        /// Sets the Beef function f as the new value of global name
        /// </summary>
        /// <param name="name"></param>
        /// <param name="function"></param>
        public void Register(StringView name, LuaFunction func)
        {
            PushCFunction(func);
            SetGlobal(name);
        }


        /// <summary>
        /// Removes the element at the given valid index, shifting down the elements above this index to fill the gap. This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position. 
        /// </summary>
        /// <param name="index"></param>
        public void Remove(int32 index)
        {
			LuaMethods.lua_remove(_luaState, index);
        }

        /// <summary>
        /// Moves the top element into the given valid index without shifting any element (therefore replacing the value at that given index), and then pops the top element.
        /// </summary>
        /// <param name="index"></param>
        public void Replace(int32 index)
        {
            Copy(-1, index);
            Pop(1);
        }

        /// <summary>
        /// Starts and resumes a coroutine in the given thread L.
        /// To start a coroutine, you push onto the thread stack the main function plus any arguments; then you call lua_resume, with nargs being the number of arguments.This call returns when the coroutine suspends or finishes its execution. When it returns, * nresults is updated and the top of the stack contains the* nresults values passed to lua_yield or returned by the body function. lua_resume returns LUA_YIELD if the coroutine yields, LUA_OK if the coroutine finishes its execution without errors, or an error code in case of errors (see lua_pcall). In case of errors, the error object is on the top of the stack.
        /// To resume a coroutine, you clear its stack, push only the values to be passed as results from yield, and then call lua_resume.
        /// The parameter from represents the coroutine that is resuming L. If there is no such coroutine, this parameter can be NULL.  
        /// </summary>
        /// <param name="from"></param>
        /// <param name="arguments"></param>
        /// <returns></returns>
        public LuaStatus Resume(Lua from, int32 arguments)
        {
            return (LuaStatus)LuaMethods.lua_resume(_luaState, arguments);
        }

        /// <summary>
        ///  Rotates the stack elements between the valid index idx and the top of the stack. The elements are rotated n positions in the direction of the top, for a positive n, or -n positions in the direction of the bottom, for a negative n. The absolute value of n must not be greater than the size of the slice being rotated. This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="n"></param>
        public void Rotate(int32 index, int32 n)
        {
            LuaMethods.lua_rotate(_luaState, index, n);
        }

        /// <summary>
        /// Changes the allocator function of a given state to f with user data ud. 
        /// </summary>
        /// <param name="alloc"></param>
        /// <param name="ud"></param>
        public void SetAllocFunction(LuaAlloc alloc, ref void* ud)
        {
            LuaMethods.lua_setallocf(_luaState, alloc, ud);
        }

        /// <summary>
        /// Does the equivalent to t[k] = v, where t is the value at the given index and v is the value at the top of the stack.
        /// </summary>
        /// <param name="index"></param>
        /// <param name="key"></param>
        public void SetField(int32 index, StringView key)
        {
            LuaMethods.lua_setfield(_luaState, index, key.ToScopeCStr!());
        }

        /// <summary>
        /// Sets the debugging hook function. 
        /// 
        /// Argument f is the hook function. mask specifies on which events the hook will be called: it is formed by a bitwise OR of the constants
        /// </summary>
        /// <param name="hookFunction">Hook function callback</param>
        /// <param name="mask">hook mask</param>
        /// <param name="count">count (used only with LuaHookMas.Count)</param>
        public void SetHook(LuaHookFunction hookFunction, LuaHookMask mask, int32 count)
        {
            LuaMethods.lua_sethook(_luaState, hookFunction, mask, count);
        }

        /// <summary>
        /// Pops a value from the stack and sets it as the new value of global name. 
        /// </summary>
        /// <param name="name"></param>
        public void SetGlobal(StringView name)
        {
            LuaMethods.lua_setglobal(_luaState, name.ToScopeCStr!());
        }

        /// <summary>
        /// Does the equivalent to t[n] = v, where t is the value at the given index and v is the value at the top of the stack. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="n"></param>
        public void SetInteger(int32 index, int32 n)
        {
            LuaMethods.lua_rawseti(_luaState, index, n);
        }

        /// <summary>
        /// Sets the value of a local variable of a given activation record. It assigns the value at the top of the stack to the variable and returns its name. It also pops the value from the stack. 
        /// </summary>
        /// <param name="ar"></param>
        /// <param name="n"></param>
        /// <returns>Returns NULL (and pops nothing) when the index is greater than the number of active local variables. </returns>
        public StringView SetLocal(LuaDebug* ar, int32 n)
        {
            char8* ptr = LuaMethods.lua_setlocal(_luaState, (int)(void*)ar, n);
            return .(ptr);
        }

        /// <summary>
        /// Sets the value of a local variable of a given activation record. It assigns the value at the top of the stack to the variable and returns its name. It also pops the value from the stack. 
        /// </summary>
        /// <param name="ar"></param>
        /// <param name="n"></param>
        /// <returns>Returns NULL (and pops nothing) when the index is greater than the number of active local variables. </returns>
        public StringView SetLocal(ref LuaDebug ar, int32 n)
        {
            return SetLocal(&ar, n);
        }

        /// <summary>
        /// Pops a table from the stack and sets it as the new metatable for the value at the given index. 
        /// </summary>
        /// <param name="index"></param>
        public void SetMetaTable(int32 index)
        {
            LuaMethods.lua_setmetatable(_luaState, index);
        }

        /// <summary>
        ///  Does the equivalent to t[k] = v, where t is the value at the given index, v is the value at the top of the stack, and k is the value just below the top
        /// </summary>
        /// <param name="index"></param>
        public void SetTable(int32 index)
        {
            LuaMethods.lua_settable(_luaState, index);
        }

        /// <summary>
        /// Accepts any index, or 0, and sets the stack top to this index. If the new top is larger than the old one, then the new elements are filled with nil. If index is 0, then all stack elements are removed. 
        /// </summary>
        /// <param name="newTop"></param>
        public void SetTop(int32 newTop)
        {
            LuaMethods.lua_settop(_luaState, newTop);
        }

        /// <summary>
        /// Sets the value of a closure's upvalue. It assigns the value at the top of the stack to the upvalue and returns its name. It also pops the value from the stack. 
        /// </summary>
        /// <param name="functionIndex"></param>
        /// <param name="n"></param>
        /// <returns>Returns NULL (and pops nothing) when the index n is greater than the number of upvalues. </returns>
        public StringView SetUpValue(int32 functionIndex, int32 n)
        {
            char8* ptr = LuaMethods.lua_setupvalue(_luaState, functionIndex, n);
            return .(ptr);
        }

        /// <summary>
        ///  Pops a value from the stack and sets it as the new 1th user value associated to the full userdata at the given index. Returns 0 if the userdata does not have that value. 
        /// </summary>
        /// <param name="index"></param>
        /// <param name="nth"></param>
        public void SetUserValue(int32 index)
        {
			LuaMethods.lua_setfenv(_luaState, index);
        }

        /// <summary>
        ///  The status can be 0 (LUA_OK) for a normal thread, an error code if the thread finished the execution of a lua_resume with an error, or LUA_YIELD if the thread is suspended. 
        ///  You can only call functions in threads with status LUA_OK. You can resume threads with status LUA_OK (to start a new coroutine) or LUA_YIELD (to resume a coroutine). 
        /// </summary>
        public LuaStatus Status => (LuaStatus)LuaMethods.lua_status(_luaState);

        /// <summary>
        /// Converts the zero-terminated string s to a number, pushes that number into the stack,
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public bool StringToNumber(StringView s)
        {
            return LuaMethods.lua_stringtonumber(_luaState, s.ToScopeCStr!()) != 0;
        }

        /// <summary>
        /// Converts the Lua value at the given index to a Beef boolean value
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool ToBoolean(int32 index)
        {
            return LuaMethods.lua_toboolean(_luaState, index) != 0;
        }

        /// <summary>
        /// Converts a value at the given index to a Beef function. That value must be a Beef function; otherwise, returns NULL
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public LuaFunction ToCFunction(int32 index)
        {
            return LuaMethods.lua_tocfunction(_luaState, index);
        }

        /// <summary>
        /// Converts the Lua value at the given index to the signed integral type lua_Integer. The Lua value must be an integer, or a number or string convertible to an integer (see §3.4.3); otherwise, lua_tointegerx returns 0. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public int64 ToInteger(int32 index)
        {
            int32 isNum;
            return LuaMethods.lua_tointegerx(_luaState, index, out isNum);
        }

        /// <summary>
        /// Converts the Lua value at the given index to the signed integral type lua_Integer. The Lua value must be an integer, or a number or string convertible to an integer (see §3.4.3); otherwise, lua_tointegerx returns 0. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public int64? ToIntegerX(int32 index)
        {
            int32 isInteger;
            int64 value = LuaMethods.lua_tointegerx(_luaState, index, out isInteger);
            if(isInteger != 0)
                return value;
            return null;
        }

        /// <summary>
        /// Converts the Lua value at the given as byte array
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void ToBuffer(int32 index, out uint8[] buffer)
        {
            ToBuffer(index, true, out buffer);
        }

        /// <summary>
        /// Converts the Lua value at the given index to a byte array.
        /// </summary>
        /// <param name="index"></param>
        /// <param name="callMetamethod">Calls __tostring field if present</param>
        /// <returns></returns>
        public void ToBuffer(int32 index, bool callMetamethod, out uint8[] buffer)
        {
            uint len;
            char8* buff;

            if (callMetamethod)
            {
                buff = LuaMethods.luaL_tolstring(_luaState, index, out len);
                Pop(1);
            }
            else
            {
                buff = LuaMethods.lua_tolstring(_luaState, index, out len);
            }

            if(buff == null)
			{
                buffer = null;
				return;
			}

            int length = (int)len;
            if(length == 0)
			{
                buffer = new uint8[0];
				return;
			}

            buffer = new uint8[length];
            Internal.MemCpy(buffer.Ptr, buff, length);
        }

		/// <summary>
		/// Converts the Lua value at the given index to a Beef StringView (no encoding is done)
		/// ToStringView returns a StringView to a string inside the Lua state. This string always has a zero ('\0') after its last character (as in C), but can contain other zeros in its body. Because Lua has garbage collection, there is no guarantee that the pointer returned by ToStringView will be valid after the corresponding value is removed from the stack.
		/// </summary>
		/// <param name="index"></param>
		/// <returns></returns>
		public StringView ToStringView(int32 index, bool callMetamethod = true)
		{
			uint len;
			char8* buff;

			if (callMetamethod)
			{
			    buff = LuaMethods.luaL_tolstring(_luaState, index, out len);
			    Pop(1);
			}
			else
			{
			    buff = LuaMethods.lua_tolstring(_luaState, index, out len);
			}

			return StringView(buff, (.)len);
		}

        /// <summary>
        /// Converts the Lua value at the given index to a Beef string
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void ToString(int32 index, String outString)
        {
            ToString(index, true, outString);
        }

        /// <summary>
        /// Converts the Lua value at the given index to a Beef string
        /// </summary>
        /// <param name="index"></param>
        /// <param name="callMetamethod">Calls __tostring field if present</param>
        /// <returns></returns>
        public void ToString(int32 index, bool callMetamethod, String outString)
        {
            uint len;
			char8* buff;

			if (callMetamethod)
			{
			    buff = LuaMethods.luaL_tolstring(_luaState, index, out len);
			    Pop(1);
			}
			else
			{
			    buff = LuaMethods.lua_tolstring(_luaState, index, out len);
			}

			if(buff == null)
			{
			    outString.Clear();
				return;
			}

			int length = (int)len;
			if(length == 0)
			{
			    outString.Clear();
				return;
			}

			Encoding.DecodeToUTF8(Span<uint8>((.)buff, length), outString);
        }

        /// <summary>
        /// Converts the Lua value at the given index to a Beef double
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public double ToNumber(int32 index)
        {
            int32 isNum;
            return LuaMethods.lua_tonumberx(_luaState, index, out isNum);
        }

        /// <summary>
        /// Converts the Lua value at the given index to a Beef double?
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public double? ToNumberX(int32 index)
        {
            int32 isNumber;
            double value = LuaMethods.lua_tonumberx(_luaState, index, out isNumber);
            if(isNumber != 0)
                return value;
            return null;
        }

        /// <summary>
        ///  Converts the value at the given index to a generic C pointer (void*). The value can be a userdata, a table, a thread, or a function; otherwise, lua_topointer returns NULL. Different objects will give different pointers. There is no way to convert the pointer back to its original value.
        ///  Typically this function is used only for hashing and debug information. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void* ToPointer(int32 index)
        {
            return LuaMethods.lua_topointer(_luaState, index);
        }

        /// <summary>
        /// Return an object (refence) at the index
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="index"></param>
        /// <returns></returns>
        public T ToObject<T>(int32 index)
        {
            if(IsNil(index) || !IsLightUserData(index))
                return default(T);

            void* data = ToUserData(index);
            if(data == null)
                return default(T);

            return (.)Internal.UnsafeCastToObject(data);
        }

        /// <summary>
        /// If the value at the given index is a full userdata, returns its block address. If the value is a light userdata, returns its pointer. Otherwise, returns NULL
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void* ToUserData(int32 index)
        {
            return LuaMethods.lua_touserdata(_luaState, index);
        }


        /// <summary>
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public LuaType Type(int32 index)
        {
            return (LuaType)LuaMethods.lua_type(_luaState, index);
        }

        /// <summary>
        /// Returns the name of the type of the value at the given index. 
        /// </summary>
        /// <param name="type"></param>
        /// <returns>Name of the type of the value at the given index</returns>
        public StringView TypeName(LuaType type)
        {
            char8* ptr = LuaMethods.lua_typename(_luaState, type);
            return .(ptr);
        }

        /// <summary>
        ///  Returns a unique identifier for the upvalue numbered n from the closure at index funcindex.
        /// </summary>
        /// <param name="functionIndex"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public int64 UpValueId(int32 functionIndex, int32 n)
        {
            return (int64)(int)LuaMethods.lua_upvalueid(_luaState, functionIndex, n);
        }

        /// <summary>
        /// Returns the pseudo-index that represents the i-th upvalue of the running function 
        /// </summary>
        /// <param name="i"></param>
        /// <returns></returns>
		[Inline]
        public static int32 UpValueIndex(int32 i)
        {
            return (int32)LuaGlobals.Index - i;
        }

        /// <summary>
        /// Make the n1-th upvalue of the Lua closure at index funcindex1 refer to the n2-th upvalue of the Lua closure at index funcindex2
        /// </summary>
        /// <param name="functionIndex1"></param>
        /// <param name="n1"></param>
        /// <param name="functionIndex2"></param>
        /// <param name="n2"></param>
        public void UpValueJoin(int32 functionIndex1, int32 n1, int32 functionIndex2, int32 n2)
        {
            LuaMethods.lua_upvaluejoin(_luaState, functionIndex1, n1, functionIndex2, n2);
        }

        /// <summary>
        /// Return the version of Lua (e.g 504)
        /// </summary>
        /// <returns></returns>
        public double Version()
        {
            return 501;
        }

        /// <summary>
        ///  Exchange values between different threads of the same state.
        ///  This function pops n values from the current stack, and pushes them onto the stack to. 
        /// </summary>
        /// <param name="to"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public void XMove(Lua to, int32 n)
        {
            LuaMethods.lua_xmove(_luaState, to._luaState, n);
        }

        /// <summary>
        /// This function is equivalent to lua_yieldk, but it has no continuation (see §4.7). Therefore, when the thread resumes, it continues the function that called the function calling lua_yield. 
        /// </summary>
        /// <param name="results"></param>
        /// <returns></returns>
        public int32 Yield(int32 results)
        {
            return LuaMethods.lua_yield(_luaState, results);
        }

        /* Auxialiary Library Functions */

        /// <summary>
        /// Checks whether cond is true. If it is not, raises an error with a standard message
        /// </summary>
        /// <param name="condition"></param>
        /// <param name="argument"></param>
        /// <param name="message"></param>
        public void ArgumentCheck(bool condition, int32 argument, StringView message)
        {
            if (condition)
                return;
            ArgumentError(argument, message);
        }

        /// <summary>
        /// Raises an error reporting a problem with argument arg of the C function that called it, using a standard message that includes extramsg as a comment: 
        /// </summary>
        /// <param name="argument"></param>
        /// <param name="message"></param>
        /// <returns></returns>
        public int32 ArgumentError(int32 argument, StringView message)
        {
            return LuaMethods.luaL_argerror(_luaState, argument, message.ToScopeCStr!());
        }

        /// <summary>
        /// If the object at index obj has a metatable and this metatable has a field e, this function calls this field passing the object as its only argument.
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="field"></param>
        /// <returns>If there is no metatable or no metamethod, this function returns false (without pushing any value on the stack)</returns>
        public bool CallMetaMethod(int32 obj, StringView field)
        {
            return LuaMethods.luaL_callmeta(_luaState, obj, field.ToScopeCStr!()) != 0;
        }

        /// <summary>
        /// Checks whether the function has an argument of any type (including nil) at position arg. 
        /// </summary>
        /// <param name="argument"></param>
        public void CheckAny(int32 argument)
        {
            LuaMethods.luaL_checkany(_luaState, argument);
        }

        /// <summary>
        /// Checks whether the function argument arg is an integer (or can be converted to an integer)
        /// </summary>
        /// <param name="argument"></param>
        /// <returns></returns>
        public int64 CheckInteger(int32 argument)
        {
            return LuaMethods.luaL_checkinteger(_luaState, argument);
        }
		// TODO
		/*
        /// <summary>
        /// Checks whether the function argument arg is a string and returns this string;
        /// </summary>
        /// <param name="argument"></param>
        /// <returns></returns>
        public byte[] CheckBuffer(int32 argument)
        {
            UIntPtr len;
            IntPtr buff = NativeMethods.luaL_checklstring(_luaState, argument, out len);
            if (buff == 0)
                return null;

            int32 length = (int)len;
            if(length == 0)
                return new byte[0];

            byte[] output = new byte[length];
            Marshal.Copy(buff, output, 0, length);
            return output;
        }

        /// <summary>
        /// Checks whether the function argument arg is a string and returns this string;
        /// </summary>
        /// <param name="argument"></param>
        /// <returns></returns>
        public string CheckString(int32 argument)
        {
            byte[] buffer = CheckBuffer(argument);
            if(buffer == null)
                return null;
            return Encoding.GetString(buffer);
        }

        /// <summary>
        /// Checks whether the function argument arg is a number and returns this number. 
        /// </summary>
        /// <param name="argument"></param>
        /// <returns></returns>
        public double CheckNumber(int32 argument)
        {
            return NativeMethods.luaL_checknumber(_luaState, argument);
        }


        /// <summary>
        /// Checks whether the function argument arg is a string and searches for this string in the array lst 
        /// </summary>
        /// <param name="argument"></param>
        /// <param name="def"></param>
        /// <param name="list"></param>
        /// <returns></returns>
        public int32 CheckOption(int32 argument, string def, string[] list)
        {
            return NativeMethods.luaL_checkoption(_luaState, argument, def, list);
        }


        /// <summary>
        /// Grows the stack size to top + sz elements, raising an error if the stack cannot grow 
        /// </summary>
        /// <param name="newSize"></param>
        /// <param name="message"></param>
        public void CheckStack(int32 newSize, string message)
        {
            NativeMethods.luaL_checkstack(_luaState, newSize, message);
        }

        /// <summary>
        /// Checks whether the function argument arg has type type
        /// </summary>
        /// <param name="argument"></param>
        /// <param name="type"></param>
        public void CheckType(int32 argument, LuaType type)
        {
            NativeMethods.luaL_checktype(_luaState, argument, (int)type);
        }

        /// <summary>
        /// Checks whether the function argument arg is a userdata of the type tname
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="argument"></param>
        /// <param name="typeName"></param>
        /// <param name="freeGCHandle">True to release the GCHandle</param>
        /// <returns></returns>
        public T CheckObject<T>(int32 argument, string typeName, bool freeGCHandle = true)
        {
            if(IsNil(argument) || !IsLightUserData(argument))
                return default(T);

            IntPtr data = CheckUserData(argument, typeName);
            if(data == 0)
                return default(T);

            var handle = GCHandle.FromIntPtr(data);
            if(!handle.IsAllocated)
                return default(T);

            var reference = (T)handle.Target;

            if(freeGCHandle)
                handle.Free();

            return reference;
        }

        /// <summary>
        /// Checks whether the function argument arg is a userdata of the type tname (see luaL_newmetatable) and returns the userdata address
        /// </summary>
        /// <param name="argument"></param>
        /// <param name="typeName"></param>
        /// <returns></returns>
        public IntPtr CheckUserData(int32 argument, string typeName)
        {
            return NativeMethods.luaL_checkudata(_luaState, argument, typeName);
        }
		*/
        /// <summary>
        /// Loads and runs the given file
        /// </summary>
        /// <param name="file"></param>
        /// <returns>It returns false if there are no errors or true in case of errors. </returns>
        public bool DoFile(StringView file)
        {
            bool hasError = LoadFile(file) != LuaStatus.OK || PCall(0, -1, 0) != LuaStatus.OK;
            return hasError;
        }

        /// <summary>
        /// Loads and runs the given string
        /// </summary>
        /// <param name="file"></param>
        /// <returns>It returns false if there are no errors or true in case of errors. </returns>
        public bool DoString(StringView file)
        {
            bool hasError = LoadString(file) != LuaStatus.OK || PCall(0, -1, 0) != LuaStatus.OK;
            return hasError;
        }

        /// <summary>
        /// Raises an error. The error message format is given by fmt plus any extra arguments
        /// </summary>
        /// <param name="value"></param>
        /// <param name="v"></param>
        /// <returns></returns>
        public int32 Error(StringView value, params Object[] v)
        {
            String message = scope String()..AppendF(value, params v);
            return LuaMethods.luaL_error(_luaState, message.CStr());
        }

        /// <summary>
        /// Pushes onto the stack the field e from the metatable of the object at index obj and returns the type of the pushed value
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="field"></param>
        /// <returns></returns>
        public LuaType GetMetaField(int32 obj, StringView field)
        {
            return (LuaType)LuaMethods.luaL_getmetafield(_luaState, obj, field.ToScopeCStr!());
        }

        /// <summary>
        /// Pushes onto the stack the metatable associated with name tname in the registry (see luaL_newmetatable) (nil if there is no metatable associated with that name)
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns></returns>
        public void GetMetaTable(StringView tableName)
        {
            GetField(LuaRegistry.Index, tableName);
        }

        /// <summary>
        /// Returns the "length" of the value at the given index as a number; it is equivalent to the '#' operator in Lua
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public int64 Length(int32 index) => LuaMethods.luaL_len(_luaState, index);
		
        /// <summary>
        /// Loads a buffer as a Lua chunk
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="name"></param>
        /// <param name="mode"></param>
        /// <returns></returns>
        public LuaStatus LoadBuffer(uint8[] buffer, StringView? name)
        {
            return (LuaStatus)LuaMethods.luaL_loadbuffer(_luaState, (.)buffer.Ptr, (uint)buffer.Count, name?.ToScopeCStr!() ?? null);
        }

        /// <summary>
        /// Loads a buffer as a Lua chunk
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public LuaStatus LoadBuffer(uint8[] buffer, String name)
        {
            return (LuaStatus)LuaMethods.luaL_loadbuffer(_luaState, (.)buffer.Ptr, (uint)buffer.Count, name?.CStr() ?? null);
        }

        /// <summary>
        /// Loads a buffer as a Lua chunk
        /// </summary>
        /// <param name="buffer"></param>
        /// <returns></returns>
        public LuaStatus LoadBuffer(uint8[] buffer)
        {
            return LoadBuffer(buffer, (String)null);

        }

        /// <summary>
        /// Loads a string as a Lua chunk
        /// </summary>
        /// <param name="chunk"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public LuaStatus LoadString(StringView chunk, StringView? name)
        {
            uint8[] buffer = Encoding.GetBytes(chunk, .. ?);
            var status = LoadBuffer(buffer, name);
			delete buffer;
			return status;
        }

        /// <summary>
        /// Loads a string as a Lua chunk
        /// </summary>
        /// <param name="chunk"></param>
        /// <returns></returns>
        public LuaStatus LoadString(StringView chunk)
        {
            return LoadString(chunk, null);
        }

        /// <summary>
        /// Loads a file as a Lua chunk. This function uses lua_load to load the chunk in the file named filename
        /// </summary>
        /// <param name="file"></param>
        /// <returns>The status of operation</returns>
        public LuaStatus LoadFile(StringView file)
        {
            return (LuaStatus)LuaMethods.luaL_loadfile(_luaState, file.ToScopeCStr!());
        }

        /// <summary>
        /// Creates a new table and registers there the functions in list library. 
        /// </summary>
        /// <param name="library"></param>
        public void NewLib(LuaRegister [] library)
        {
            NewLibTable(library);
            SetFuncs(library, 0);
        }

        /// <summary>
        /// Creates a new table with a size optimized to store all entries in the array l (but does not actually store them)
        /// </summary>
        /// <param name="library"></param>
        public void NewLibTable(LuaRegister [] library)
        {
            CreateTable(0, (.)library.Count);
        }

        /// <summary>
        /// Creates a new table to be used as a metatable for userdata
        /// </summary>
        /// <param name="name"></param>
        /// <returns>If the registry already has the key tname, returns false.,</returns>
        public bool NewMetaTable(StringView name)
        {
            return LuaMethods.luaL_newmetatable(_luaState, name.ToScopeCStr!()) != 0;
        }

        /// <summary>
        /// Opens all standard Lua libraries into the given state. 
        /// </summary>
        public void OpenLibs()
        {
            LuaMethods.luaL_openlibs(_luaState);
        }

        /// <summary>
        /// If the function argument arg is an integer (or convertible to an integer), returns this integer. If this argument is absent or is nil, returns d
        /// </summary>
        /// <param name="argument"></param>
        /// <param name="d">default value</param>
        /// <returns></returns>
        public int64 OptInteger(int32 argument, int64 d)
        {
            return LuaMethods.luaL_optinteger(_luaState, argument, d);
        }

        /// <summary>
        /// Creates and returns a reference, in the table at index t, for the object at the top of the stack (and pops the object). 
        /// </summary>
        /// <param name="tableIndex"></param>
        /// <returns></returns>
        public int32 Ref(LuaRegistry tableIndex)
        {
            return LuaMethods.luaL_ref(_luaState, tableIndex);
        }

        /// <summary>
        /// Registers all functions in the array l (see luaL_Reg) into the table on the top of the stack (below optional upvalues, see next).        /// </summary>
        /// <param name="library"></param>
        /// <param name="numberUpValues"></param>
        public void SetFuncs(LuaRegister [] library, int32 numberUpValues)
        {
            LuaMethods.luaL_setfuncs(_luaState, library.Ptr, numberUpValues);
        }

        /// <summary>
        /// Sets the metatable of the object at the top of the stack as the metatable associated with name tname in the registry
        /// </summary>
        /// <param name="name"></param>
        public void SetMetaTable(StringView name)
		{
		    GetMetaTable(name);
		    SetMetaTable(-2);
		}

        /// <summary>
        /// Returns the name of the type of the value at the given index. 
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public StringView TypeName(int32 index)
        {
            LuaType type = Type(index);
            return TypeName(type);
        }

        /// <summary>
        /// Releases reference ref from the table at index t (see luaL_ref). The entry is removed from the table, so that the referred object can be collected. The reference ref is also freed to be used again
        /// </summary>
        /// <param name="tableIndex"></param>
        /// <param name="reference"></param>
        public void Unref(LuaRegistry tableIndex, int32 reference)
        {
            LuaMethods.luaL_unref(_luaState, tableIndex, reference);
        }


        /// <summary>
        /// Pushes onto the stack a string identifying the current position of the control at level lvl in the call stack
        /// </summary>
        /// <param name="level"></param>
        public void Where(int32 level)
        {
            LuaMethods.luaL_where(_luaState, level);
        }
    }
}
