using System;
using System.Security;

namespace KeraLua
{
	public typealias lua_State = System.Interop.c_intptr;
	public typealias lua_Integer = System.Interop.c_intptr;
	public typealias lua_Number = double;
	public typealias lua_Debug = System.Interop.c_intptr;

    public static class LuaMethods
    {
#if KERALUA_STATIC
		private const String LuaLibraryName = String.Empty;
#elif BF_PLATFORM_IOS
        private const String LuaLibraryName = "@rpath/liblua51.framework/liblua51";
#elif BF_PLATFORM_ANDROID || BF_PLATFORM_LINUX
        private const String LuaLibraryName = "liblua51.so";
#elif BF_PLATFORM_MACOS
        private const String LuaLibraryName = "liblua51.dylib";
#elif BF_PLATFORM_WINDOWS
        private const String LuaLibraryName = "lua51.dll";
#else
        #error Not supported platform.
#endif

        #region Emulated Functions for API Compatibility
        internal static int32 lua_absindex(lua_State luaState, int32 idx)
        {
            if (idx > 0 || idx <= (int32)LuaRegistry.Index)
                return idx;
            return lua_gettop(luaState) + idx + 1;
        }

        internal static void lua_copy(lua_State luaState, int32 fromIndex, int32 toIndex)
        {
            lua_pushvalue(luaState, fromIndex);
            lua_replace(luaState, toIndex);
        }

        internal static void lua_rotate(lua_State L, int32 idx, int32 n)
		{
		    int32 top = lua_gettop(L);
		    int32 i = lua_absindex(L, idx);
		    int32 t = top - i + 1;

		    if (n == 0 || t <= 1)
		        return;

			var n;
		    n %= t;
		    if (n < 0) n += t;
		    if (n == 0) return;

		    int32 m = t - n;

		    lua_checkstack(L, n);
		    for (int32 j = 0; j < n; j++)
		        lua_pushvalue(L, i + m + j);
		    for (int32 j = 0; j < n; j++)
		        lua_remove(L, i + m);
		    for (int32 j = 0; j < n; j++)
		        lua_insert(L, i + j);
		}

        internal static int32 lua_compare(lua_State luaState, int32 index1, int32 index2, int32 op)
        {
            switch ((LuaCompare)op)
            {
                case .Equal:
                    return lua_equal(luaState, index1, index2);
                case .LessThen:
                    return lua_lessthan(luaState, index1, index2);
                case .LessOrEqual:
                    return lua_lessthan(luaState, index2, index1) == 0 ? 1 : 0;
                default:
                    return 0;
            }
        }

        internal static void luaL_setfuncs(lua_State luaState, LuaRegister* luaReg, int32 numUp)
		{
			luaL_checkstack(luaState, numUp + 1, "too many upvalues");
			int32 tableIndex = lua_gettop(luaState) - numUp;
			for (var r = luaReg; r.name != null; r++)
			{
			    if (r.func == null)
			        continue;

			    for (int32 i = 1; i <= numUp; i++)
			        lua_pushvalue(luaState, tableIndex + i);
			    
			    lua_pushcclosure(luaState, r.func, numUp);
			    lua_setfield(luaState, tableIndex, r.name);
			}
			lua_pop(luaState, numUp);
		}

        internal static char8* luaL_tolstring(lua_State luaState, int32 index, out uint len)
        {
			if (lua_type(luaState, index) == (int32)LuaType.None)
				Runtime.FatalError();

            if (luaL_callmeta(luaState, index, "__tostring") == 0)
            {
                switch ((LuaType)lua_type(luaState, index))
                {
                    case .Number, .String:
                        lua_pushvalue(luaState, index);
                        break;
                    case .Boolean:
                        lua_pushstring(luaState, (lua_toboolean(luaState, index) != 0) ? "true" : "false");
                        break;
                    case .Nil:
                        lua_pushstring(luaState, "nil");
                        break;
                    default:
                        lua_pushstring(luaState, scope String()..AppendF("{0}: 0x{1:X}", luaL_typename(luaState, index), (int)lua_topointer(luaState, index)).CStr());
                        break;
                }
            }
            return lua_tolstring(luaState, -1, out len);
        }

		internal static int64 luaL_len(lua_State luaState, int32 index)
		{
		    if (LuaMethods.luaL_callmeta(luaState, index, "__len") != 0)
		    {
		        if (LuaMethods.lua_isnumber(luaState, -1) == 0)
		        {
		            LuaMethods.luaL_error(luaState, "object length is not a number");
		        }
		        int64 result = (int64)LuaMethods.lua_tonumber(luaState, -1);
		        LuaMethods.lua_settop(luaState, -2); 
		        return result;
		    }
		    else
		    {
		        return (int64)LuaMethods.lua_objlen(luaState, index);
		    }
		}

		internal static double lua_tonumberx(lua_State luaState, int32 index, out int32 isNumber)
		{
			if (LuaMethods.lua_isnumber(luaState, index) != 0)
			{
				isNumber = 1;
			    return LuaMethods.lua_tonumber(luaState, index);
			}

			if (LuaMethods.lua_isstring(luaState, index) == 0)
			{
				isNumber = 0;
			    return 0;
			}

			double result = LuaMethods.lua_tonumber(luaState, index);
			if (result != 0.0)
			{
				isNumber = 1;
			    return result;
			}

			uint len;
			char8* buff = LuaMethods.lua_tolstring(luaState, index, out len);
			StringView str = StringView(buff, (.)len);

			if (double.Parse(str) case .Ok(let parsedValue))
			{
				isNumber = 1;
			    return parsedValue;
			}
			
			isNumber = 0;
			return 0;
		}

		internal static int64 lua_tointegerx(lua_State luaState, int32 index, out int32 isInteger)
		{
		    int32 isNumber;
		    double num = lua_tonumberx(luaState, index, out isNumber);

		    if (isNumber == 0)
		    {
		        isInteger = 0;
		        return 0;
		    }

		    int64 i = (int64)num;
		    if (num == (double)i)
		    {
		        isInteger = 1;
		        return i;
		    }
		    else
		    {
		        isInteger = 0;
		        return 0;
		    }
		}

		internal static int32 lua_isinteger(lua_State luaState, int32 index)
		{
			if (LuaMethods.lua_isnumber(luaState, index) == 0)
			    return 0;
			double num = LuaMethods.lua_tonumber(luaState, index);
			return num == (double)(int64)num ? 1 : 0;
		}

		internal static uint lua_stringtonumber(lua_State luaState, char8* s)
		{
			uint len = (.)String.StrLen(s);
		    LuaMethods.lua_pushlstring(luaState, s, len);

		    int32 isNumber;
		    double num = lua_tonumberx(luaState, -1, out isNumber);

		    if (isNumber != 0)
		    {
		        LuaMethods.lua_pushnumber(luaState, num);
		        LuaMethods.lua_replace(luaState, -2);
		        return len;
		    }
		    else
		    {
		        LuaMethods.lua_settop(luaState, -2);
		        return 0;
		    }
		}

        internal static void lua_getglobal(lua_State L, char8* name)
		{
			lua_getfield(L, LuaGlobals.Index, name);
		}

        internal static void lua_setglobal(lua_State L, char8* name)
		{
			lua_setfield(L, LuaGlobals.Index, name);
		}

        internal static char8* luaL_typename(lua_State L, int32 i)
		{
			return lua_typename(L, lua_type(L, i));
		}

		internal static void lua_pop(lua_State L, int32 n)
		{
			lua_settop(L, -(n)-1);
		}

		internal static void lua_pushcfunction(lua_State L, LuaFunction f)
		{
			lua_pushcclosure(L, f, 0);
		}
        #endregion

        #region Lua 5.1 Core API Imports
		[Import(LuaLibraryName), CLink]
		internal static extern LuaFunction lua_atpanic(lua_State luaState, LuaFunction panicf);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_call(lua_State luaState, int32 nargs, int32 nresults);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_checkstack(lua_State luaState, int32 extra);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_close(lua_State luaState);
        [Import(LuaLibraryName), CLink]
        internal static extern int32 lua_equal(lua_State L, int32 idx1, int32 idx2);
        [Import(LuaLibraryName), CLink]
        internal static extern int32 lua_lessthan(lua_State L, int32 idx1, int32 idx2);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_concat(lua_State luaState, int32 n);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_createtable(lua_State luaState, int32 elements, int32 records);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_dump(lua_State luaState, LuaWriter writer, void* data);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_error(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_gc(lua_State luaState, int32 what, int32 data);
		[Import(LuaLibraryName), CLink]
		internal static extern LuaAlloc lua_getallocf(lua_State luaState, ref void* ud);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_getfield(lua_State luaState, int32 index, char8* k);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_getfenv(lua_State L, int32 idx);
		[Import(LuaLibraryName), CLink]
		internal static extern LuaHookFunction lua_gethook(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_gethookcount(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_gethookmask(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_getinfo(lua_State luaState, char8* what, lua_Debug ar);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* lua_getlocal(lua_State luaState, lua_Debug ar, int32 n);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_getmetatable(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_getstack(lua_State luaState, int32 level, lua_Debug n);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_gettable(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_gettop(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* lua_getupvalue(lua_State luaState, int32 funcIndex, int32 n);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_iscfunction(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_isnumber(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_isstring(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_isuserdata(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_load(lua_State luaState, LuaReader reader, void* data, char8* chunkName);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_State lua_newstate(LuaAlloc allocFunction, void* ud);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_State lua_newthread(lua_State luaState);
        [Import(LuaLibraryName), CLink]
        internal static extern void* lua_newuserdata(lua_State L, uint size);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_next(lua_State luaState, int32 index);
        [Import(LuaLibraryName), CLink]
        internal static extern int32 lua_pcall(lua_State luaState, int32 nargs, int32 nresults, int32 errfunc);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushboolean(lua_State luaState, int32 value);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushcclosure(lua_State luaState, LuaFunction f, int32 n);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushinteger(lua_State luaState, lua_Integer n);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushlightuserdata(lua_State luaState, void* udata);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushlstring(lua_State luaState, char8* s, uint len);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_pushstring(lua_State L, char8* s);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushnil(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushnumber(lua_State luaState, lua_Number number);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_pushthread(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_pushvalue(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_rawequal(lua_State luaState, int32 index1, int32 index2);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_rawget(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_rawgeti(lua_State luaState, int32 index, int32 n);
        [Import(LuaLibraryName), CLink]
        internal static extern uint lua_objlen(lua_State L, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_rawset(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_rawseti(lua_State luaState, int32 index, int32 i);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_remove(lua_State L, int32 idx);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_insert(lua_State L, int32 idx);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_replace(lua_State L, int32 idx);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_resume(lua_State luaState, int32 nargs);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_setallocf(lua_State luaState, LuaAlloc f, void* ud);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_setfield(lua_State luaState, int32 index, char8* key);
        [Import(LuaLibraryName), CLink]
        internal static extern int32 lua_setfenv(lua_State L, int32 idx);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_sethook(lua_State luaState, LuaHookFunction f, int32 mask, int32 count);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* lua_setlocal(lua_State luaState, lua_Debug ar, int32 n);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_setmetatable(lua_State luaState, int32 objIndex);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_settable(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_settop(lua_State luaState, int32 newTop);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* lua_setupvalue(lua_State luaState, int32 funcIndex, int32 n);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_status(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_toboolean(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern LuaFunction lua_tocfunction(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_Integer lua_tointeger(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* lua_tolstring(lua_State luaState, int32 index, out uint strLen);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_Number lua_tonumber(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern void* lua_topointer(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_State lua_tothread(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern void* lua_touserdata(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 lua_type(lua_State luaState, int32 index);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* lua_typename(lua_State luaState, int32 type);
		[Import(LuaLibraryName), CLink]
		internal static extern void lua_xmove(lua_State from, lua_State to, int32 n);
        [Import(LuaLibraryName), CLink]
        internal static extern int32 lua_yield(lua_State L, int32 nresults);
        #endregion

        #region LuaJIT Backported API
        [Import(LuaLibraryName), CLink]
        internal static extern int32 lua_isyieldable(lua_State luaState);
        [Import(LuaLibraryName), CLink]
        internal static extern void* lua_upvalueid(lua_State luaState, int32 funcIndex, int32 n);
        [Import(LuaLibraryName), CLink]
        internal static extern void lua_upvaluejoin(lua_State luaState, int32 funcIndex1, int32 n1, int32 funcIndex2, int32 n2);
        #endregion

        #region Lua 5.1 Auxiliary Library Imports
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_argerror(lua_State luaState, int32 arg, char8* message);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_callmeta(lua_State luaState, int32 obj, char8* e);
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_checkany(lua_State luaState, int32 arg);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_Integer luaL_checkinteger(lua_State luaState, int32 arg);
		[Import(LuaLibraryName), CLink]
		internal static extern char8* luaL_checklstring(lua_State luaState, int32 arg, out uint len);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_Number luaL_checknumber(lua_State luaState, int32 arg);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_checkoption(lua_State luaState, int32 arg, char8* def, char8** list);
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_checkstack(lua_State luaState, int32 sz, char8* message);
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_checktype(lua_State luaState, int32 arg, int32 type);
		[Import(LuaLibraryName), CLink]
		internal static extern void* luaL_checkudata(lua_State luaState, int32 arg, char8* tName);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_error(lua_State luaState, char8* message);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_getmetafield(lua_State luaState, int32 obj, char8* e);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_loadbuffer(lua_State luaState, char8* buff, uint sz, char8* name);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_loadfile(lua_State luaState, char8* name);
        [Import(LuaLibraryName), CLink]
        internal static extern int32 luaL_loadstring(lua_State L, char8* s);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_newmetatable(lua_State luaState, char8* name);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_State luaL_newstate();
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_openlibs(lua_State luaState);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_Integer luaL_optinteger(lua_State luaState, int32 arg, lua_Integer d);
		[Import(LuaLibraryName), CLink]
		internal static extern lua_Number luaL_optnumber(lua_State luaState, int32 arg, lua_Number d);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_ref(lua_State luaState, int32 registryIndex);
        [Import(LuaLibraryName), CLink]
        internal static extern void luaL_register(lua_State L, char8* libname, LuaRegister* l);
		[Import(LuaLibraryName), CLink]
		internal static extern void* luaL_testudata(lua_State luaState, int32 arg, char8* tName);
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_traceback(lua_State luaState, lua_State luaState2, char8* message, int32 level);
		[Import(LuaLibraryName), CLink]
		internal static extern int32 luaL_typeerror(lua_State luaState, int32 arg, char8* typeName);
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_unref(lua_State luaState, int32 registryIndex, int32 reference);
		[Import(LuaLibraryName), CLink]
		internal static extern void luaL_where(lua_State luaState, int32 level);
        #endregion
    }
}