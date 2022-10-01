require("gmcurl")

local curl = curl_easy_init()

if not curl then
	print("curl did not init!")
	return
end

curl_easy_setopt(curl, CURLOPT_URL, "https://example.com")
curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1)

local res = curl_easy_perform(curl)

if res != CURLE_OK then
	print("curl_easy_perform() failed: "..curl_easy_strerror(res))
end

curl_easy_cleanup(curl)
