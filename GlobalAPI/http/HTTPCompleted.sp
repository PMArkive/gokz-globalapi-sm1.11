// =========================================================== //

public int Global_HTTP_Completed(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, GlobalAPIRequestData hData)
{
	PrintDebugMessage("HTTP Request completed!");

	hData.status = view_as<int>(statusCode);
	hData.failure = (failure || !requestSuccessful || statusCode != k_EHTTPStatusCode200OK);
	hData.responseTime = CalculateResponseTime(hData);

	Call_Global_OnRequestFinished(request, hData);
}

// =========================================================== //