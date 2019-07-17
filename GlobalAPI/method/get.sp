// =========================================================== //

/*
	BASE HTTP GET METHOD FOR NATIVES
*/
bool HTTPGet(GlobalAPIRequestData hData)
{
	if (hData.keyRequired && !gB_usingAPIKey && !gCV_Debug.BoolValue)
	{
		LogMessage("[GlobalAPI] Using this method requires an API key, and you dont seem to have one setup!");
		return false;
	}
	
	char requestParams[GlobalAPI_Max_QueryParams_Length];
	hData.ToString(requestParams, sizeof(requestParams));

	char requestUrl[GlobalAPI_Max_QueryUrl_Length];
	hData.GetString("url", requestUrl, sizeof(requestUrl));
	StrCat(requestUrl, sizeof(requestUrl), requestParams);

	GlobalAPIRequest request = new GlobalAPIRequest(requestUrl, k_EHTTPMethodGET);
	
	if (request == null)
	{
		delete hData;
		delete request;
		return false;
	}

	char mmVersion[32] = "Unknown";
	if (gCV_MetaModVersion != null)
	{
		gCV_MetaModVersion.GetString(mmVersion, sizeof(mmVersion));
	}

	char smVersion[32] = "Unknown";
	if (gCV_SourceModVersion != null)
	{
		gCV_SourceModVersion.GetString(smVersion, sizeof(smVersion));
	}

	request.SetData(hData);
	request.SetTimeout(15);
	request.SetCallbacks();
	request.SetAuthHeader();
	request.SetPoweredByHeader();
	request.SetEnvironmentHeaders(mmVersion, smVersion);
	request.SetAcceptHeaders(hData);
	request.SetContentTypeHeader(hData);
	request.SetRequestOriginHeader(hData);
	request.Send(hData);

	return true;
}

// =========================================================== //