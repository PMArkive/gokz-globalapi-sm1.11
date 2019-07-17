// ====================== DEFINITIONS ======================== //

#define PLUGIN_NAME "GlobalAPI"
#define PLUGIN_AUTHOR "Sikari"

#define DATA_DIR "data/GlobalAPI"
#define CONFIG_DIR "sourcemod/GlobalAPI"
 
#define APIKEY_PATH "cfg/sourcemod/GlobalAPI/GlobalAPI-key.cfg"

// =========================================================== //

#include <sourcemod>
#include <SteamWorks>

#include <GlobalAPI>
#include <GlobalAPI/request>

// ====================== FORMATTING ========================= //

#pragma dynamic 131072
#pragma newdecls required

// ====================== VARIABLES ========================== //

// Plugin
bool gB_usingAPIKey = false;
char gC_apiKey[GlobalAPI_Max_APIKey_Length];
char gC_baseUrl[GlobalAPI_Max_BaseUrl_Length];

ConVar gCV_MetaModVersion = null;
ConVar gCV_SourceModVersion = null;

// Cached vars
char gC_mapName[64];
char gC_mapPath[PLATFORM_MAX_PATH];
int gI_mapFilesize = -1;

// Modules
ArrayList g_statsModules;
ArrayList g_loggingModules;
ArrayList g_retryingModules;

// ======================= INCLUDES ========================== //

#include "GlobalAPI/api/convars.sp"
#include "GlobalAPI/api/modules.sp"
#include "GlobalAPI/api/natives.sp"
#include "GlobalAPI/api/forwards.sp"

#include "GlobalAPI/misc.sp"
#include "GlobalAPI/commands.sp"

#include "GlobalAPI/method/get.sp"
#include "GlobalAPI/method/post.sp"

#include "GlobalAPI/http/HTTPData.sp"
#include "GlobalAPI/http/HTTPHeaders.sp"
#include "GlobalAPI/http/HTTPStarted.sp"
#include "GlobalAPI/http/HTTPCompleted.sp"
#include "GlobalAPI/http/HTTPDataReceived.sp"

// ====================== PLUGIN INFO ======================== //

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = GlobalAPI_Plugin_Desc,
	version = GlobalAPI_Plugin_Version,
	url = GlobalAPI_Plugin_Url
};

// ======================= MAIN CODE ========================= //

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary(PLUGIN_NAME);

	CreateConvars();
	CreateNatives();
	CreateForwards();
	CreateCommands();

	CreateDataDir();
	CreateConfigDir();
}

public void OnPluginStart()
{
	gCV_MetaModVersion = FindConVar("metamod_version");
	gCV_SourceModVersion = FindConVar("sourcemod_Version");

	g_statsModules = new ArrayList();
	g_loggingModules = new ArrayList();
	g_retryingModules = new ArrayList();

	gB_usingAPIKey = ReadAPIKey();
	AutoExecConfig(true, PLUGIN_NAME, CONFIG_DIR);
}

public void OnMapStart()
{
	GetMapDisplay(gC_mapName, sizeof(gC_mapName));
	GetMapFullPath(gC_mapPath, sizeof(gC_mapPath));
	gI_mapFilesize = FileSize(gC_mapPath);
}

public void OnConfigsExecuted()
{
	Initialize();
	Call_Global_OnInitialized();
}

// =========================================================== //

public void GlobalAPI_OnRequestStarted(Handle request, GlobalAPIRequestData hData)
{
	char requestUrl[GlobalAPI_Max_BaseUrl_Length];
	hData.GetString("url", requestUrl, sizeof(requestUrl));

	GlobalAPI_DebugMessage("HTTP Request to \"%s\" started!", requestUrl);
}

public void GlobalAPI_OnRequestFailed(Handle request, GlobalAPIRequestData hData)
{
	char requestUrl[GlobalAPI_Max_BaseUrl_Length];
	hData.GetString("url", requestUrl, sizeof(requestUrl));
	
	GlobalAPI_DebugMessage("HTTP Request to \"%s\" failed! - Status: %d", requestUrl, hData.status);
}

public void GlobalAPI_OnRequestFinished(Handle request, GlobalAPIRequestData hData)
{
	char requestUrl[GlobalAPI_Max_BaseUrl_Length];
	hData.GetString("url", requestUrl, sizeof(requestUrl));
	
	GlobalAPI_DebugMessage("HTTP Request to \"%s\" completed! - Status: %d", requestUrl, hData.status);
}

// =========================================================== //