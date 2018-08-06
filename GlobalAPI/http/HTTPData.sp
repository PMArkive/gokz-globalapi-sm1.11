// =========================================================== //

public int Global_HTTP_Data(const char[] response, GlobalAPIRequestData hData)
{
	JSON_Object hJson = null;

	char contentType[32];
	hData.GetString("contentType", contentType, sizeof(contentType));

	if (StrEqual(contentType, "application/octet-stream", false) && hData.requestType != GlobalAPIRequestType_POST)
	{
		int iterator = 0;

		char path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, path, sizeof(path), "data/GlobalAPI/TEMP-%d.REPLAY", iterator);

		while (FileExists(path))
		{
			iterator++;
			BuildPath(Path_SM, path, sizeof(path), "data/GlobalAPI/TEMP-%d.REPLAY", iterator); 
		}

		hData.SetString("replayPath", path);
		hData.SetKeyHidden("replayPath", true);

		Handle request = view_as<Handle>(hData.GetInt("requestHandle"));
		SteamWorks_WriteHTTPResponseBodyToFile(request, path);
	}
	else
	{
		hJson.Decode(response);
	}

	any data = hData.data;
	Handle hFwd = hData.callback;
	bool bFailure = hData.failure;

	// We dont plan to have this key as long lasting because its a handle anyways.
	hData.Remove("requestHandle");

	CallForward(hFwd, bFailure, hJson, hData, data);

	// Cleanup
	if (hJson != INVALID_HANDLE) hJson.Cleanup();
	if (hData != INVALID_HANDLE) hData.Cleanup();

	delete hFwd;
	delete hJson;
	delete hData;
}

// =========================================================== //