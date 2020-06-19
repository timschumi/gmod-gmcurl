#include <string>
#include <curl/curl.h>
#include <GarrysMod/Lua/Interface.h>

using namespace GarrysMod;

#define ADD_NUM(key, val) { LUA->PushString(key); LUA->PushNumber(val); LUA->SetTable(-3); }
#define ADD_FUN(key, val) { LUA->PushString(key); LUA->PushCFunction(val); LUA->SetTable(-3); }

static int typeid_curl;

void log(Lua::ILuaBase *LUA, std::string message) {
	LUA->PushSpecial(Lua::SPECIAL_GLOB);
	LUA->GetField(-1, "print");
	LUA->PushString(("[curl] " + message).c_str());
	LUA->Call(1, 0);
	LUA->Pop();
}

LUA_FUNCTION(lua_curl_easy_init) {
	CURL *curl = curl_easy_init();

	LUA->PushUserType(curl, typeid_curl);
	return 1;
}

LUA_FUNCTION(lua_curl_easy_cleanup) {
        CURL *curl = LUA->GetUserType<CURL>(1, typeid_curl);

        if (curl == NULL)
                LUA->ArgError(1, "Not a curl object (or object was NULL).");

        curl_easy_cleanup(curl);
        return 0;
}

LUA_FUNCTION(lua_curl_easy_perform) {
	CURL *curl = LUA->GetUserType<CURL>(1, typeid_curl);

	if (curl == NULL)
		LUA->ArgError(1, "Not a curl object (or object was NULL).");

	CURLcode res = curl_easy_perform(curl);

	LUA->PushNumber(res);
	return 1;
}

LUA_FUNCTION(lua_curl_easy_setopt) {
	CURL *curl = LUA->GetUserType<CURL>(1, typeid_curl);

	if (curl == NULL)
		LUA->ArgError(1, "Not a curl object (or object was NULL).");

	CURLoption option = (CURLoption) LUA->CheckNumber(2);

	CURLcode res;
	if (LUA->IsType(3, Lua::Type::String))
		res = curl_easy_setopt(curl, option, LUA->GetString(3));
	else if (LUA->IsType(3, Lua::Type::Number))
		res = curl_easy_setopt(curl, option, LUA->GetNumber(3));
	else if (LUA->IsType(3, Lua::Type::Bool))
		res = curl_easy_setopt(curl, option, LUA->GetBool(3));
	else
		LUA->ArgError(3, "Value is not one of the supported types.");

	LUA->PushNumber(res);
	return 1;
}

LUA_FUNCTION(lua_curl_easy_strerror) {
	CURLcode res = (CURLcode) LUA->CheckNumber(1);

	const char *error = curl_easy_strerror(res);

	LUA->PushString(error);
	return 1;
}

GMOD_MODULE_OPEN() {
#ifdef WINDOWS_BUILD
	// Try setting the SSL default to schannel on Windows
	curl_global_sslset(CURLSSLBACKEND_SCHANNEL, NULL, NULL);
#endif

	curl_global_init(CURL_GLOBAL_ALL);

	// Initialize custom userdata types
	typeid_curl = LUA->CreateMetaTable("CURL");
	LUA->Pop();

	// We are working on the global table today
	LUA->PushSpecial(Lua::SPECIAL_GLOB);

	ADD_NUM("CURLOPT_URL", CURLOPT_URL);
	ADD_NUM("CURLOPT_PORT", CURLOPT_PORT);
	ADD_NUM("CURLOPT_FOLLOWLOCATION", CURLOPT_FOLLOWLOCATION);

	ADD_NUM("CURLE_OK", CURLE_OK);

	ADD_FUN("curl_easy_init", lua_curl_easy_init);
	ADD_FUN("curl_easy_cleanup", lua_curl_easy_cleanup);
	ADD_FUN("curl_easy_perform", lua_curl_easy_perform);
	ADD_FUN("curl_easy_setopt", lua_curl_easy_setopt);
	ADD_FUN("curl_easy_strerror", lua_curl_easy_strerror);

	// Pop the global table from the stack again
	LUA->Pop();
	return 0;
}

GMOD_MODULE_CLOSE() {
	curl_global_cleanup();
	return 0;
}
