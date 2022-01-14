module("L_MyiPhone1", package.seeall)
        
local PV = "0.5" -- plugin version number
local COM_SID = "urn:nodecentral-net:serviceId:MyiPhone1"
local BAT_SID = "urn:micasaverde-com:serviceId:HaDevice1"

function log(msg) 
	luup.log("MyiPh: " .. msg)
end

local function round(x, n) -- x = number, n = characters after decimal point
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

local function distanceBetween(lat1, lon1, lat2, lon2, distance_unit)
	log("[distanceBetween] function Called")
	local lat1 = luup.variable_get(COM_SID, "MyHomeLatitude", lul_device)
	local lon1 = luup.variable_get(COM_SID, "MyHomeLongitude", lul_device)
	log("lat1 - "..lat1.. " lon1 - "..lon1)
	local lat2 = luup.variable_get(COM_SID, "iCloudlatitude", lul_device)
	local lon2 = luup.variable_get(COM_SID, "iCloudlongitude", lul_device)
	log("lat2 - "..lat2.. " lon2 - "..lon2)
	local distance_unit = luup.variable_get(COM_SID, "MyTargetDistanceUnit", lul_device)
 
	local radlat1 = math.pi * lat1/180
	local radlat2 = math.pi * lat2/180
	local radlon1 = math.pi * lon1/180
	local radlon2 = math.pi * lon2/180
	local theta = lon1-lon2
	local radtheta = math.pi * theta/180
	local dist = math.sin(radlat1) * math.sin(radlat2) + math.cos(radlat1) * math.cos(radlat2) * math.cos(radtheta);
	dist = math.acos(dist)
	dist = dist * 180/math.pi
	dist = dist * 60 * 1.1515
	if distance_unit == "K"  then
		dist = dist * 1.609344
	elseif (distance_unit == "N") then
		dist = dist * 0.8684
	end
	local roundedDist = round(dist, 7)
	luup.variable_set(COM_SID, "MyTargetDeviceDistance", roundedDist , lul_device)
	log("lat1/lon1 vs lat2/lon2 = " ..dist)
	return dist
end

function GoGetMyiPhoneInfoErrorHandling(result)
	log("iCloud error handling function called")
	-- add codd in here to handle any errors
	if string.sub(result, 1, 1) == "{" then log("iCloud returned a JSON"); return result
	elseif result == nil then log("iCloud returned nil"); return nil
	elseif result == "null" then log("Null is just text")
	elseif result == "(null)" then log("Null is just text with brackets")
	elseif result == "" then log("Null is nothing")
	elseif result == " " then log("Null is just a space")
	else log("More digging needed on")
	return nil
	end
end
	
function GoGetMyiPhoneInfo(lul_device)
	log("[GoGetMyiPhoneInfo] function Called")
	local username = luup.variable_get(COM_SID, "MyAppleUsername", lul_device)
	local password = luup.variable_get(COM_SID, "MyApplePassword", lul_device)

	local stage1command = "curl -k -s -X POST -D - -o /dev/null -L -u '" .. username .. ":" .. password .. "' -H 'Content-Type: application/json; charset=utf-8' -H 'X-Apple-Find-Api-Ver: 2.0' -H 'X-Apple-Authscheme: UserIdGuest' -H 'X-Apple-Realm-Support: 1.0' -H 'User-agent: Find iPhone/1.3 MeKit (iPad: iPhone OS/4.2.1)' -H 'X-Client-Name: iPad' -H 'X-Client-UUID: 0cf3dc501ff812adb0b202baed4f37274b210853' -H 'Accept-Language: en-us' -H 'Connection: keep-alive' https://fmipmobile.icloud.com/fmipservice/device/" .. username .."/initClient"

	local stage2server = "fmipmobile.icloud.com"

	local stage2command = "curl -k -s -X POST -L -u '" .. username .. ":" .. password .. "' -H 'Content-Type: application/json; charset=utf-8' -H 'X-Apple-Find-Api-Ver: 2.0' -H 'X-Apple-Authscheme: UserIdGuest' -H 'X-Apple-Realm-Support: 1.0' -H 'User-agent: Find iPhone/1.3 MeKit (iPad: iPhone OS/4.2.1)' -H 'X-Client-Name: iPad' -H 'X-Client-UUID: 0cf3dc501ff812adb0b202baed4f37274b210853' -H 'Accept-Language: en-us' -H 'Connection: keep-alive' https://" .. stage2server .. "/fmipservice/device/" .. username .."/initClient"
 
	local handle = io.popen(stage2command)
	local result = handle:read("*a")
	handle:close()
	--luup.log(result)
	log("Check result of CURL request")
	return GoGetMyiPhoneInfoErrorHandling(result)
	--return result
end

function readMyiPhoneVariables(lul_device)
	log("[readMyiPhoneVariables] function Called")
	local data = {}
		
	data.MyAppleUsername = luup.variable_get(COM_SID, "MyAppleUsername", lul_device)
	data.MyApplePassword = luup.variable_get(COM_SID, "MyApplePassword", lul_device)
	
	data.MyTargetDeviceName = luup.variable_get(COM_SID, "MyTargetDeviceName", lul_device)
	data.MyTargetDeviceDistance = luup.variable_get(COM_SID, "MyTargetDeviceDistance", lul_device)
	data.MyTargetDistanceUnit = luup.variable_get(COM_SID, "MyTargetDistanceUnit", lul_device)
	
	data.MyHomeLongitude = luup.variable_get(COM_SID, "MyHomeLongitude", lul_device)
	data.MyHomeLatitude = luup.variable_get(COM_SID, "MyHomeLatitude", lul_device)
	--data.MyHomeSkew = luup.variable_get(COM_SID, "MyHomeSkew", lul_device)
	
	data.iCloudName = luup.variable_get(COM_SID, "iCloudName", lul_device)
	data.iCloudDisplayName = luup.variable_get(COM_SID, "iCloudDisplayName", lul_device)
	
	data.iCloudlocationEnabled = luup.variable_get(COM_SID, "iCloudlocationEnabled", lul_device)
	data.iCloudlongitude = luup.variable_get(COM_SID, "iCloudlongitude", lul_device)
	data.iCloudlatitude = luup.variable_get(COM_SID, "iCloudlatitude", lul_device)
	data.iCloudlocationTimestamp = luup.variable_get(COM_SID, "iCloudlocationTimestamp", lul_device)
	data.iCloudlocationTimestampHR = luup.variable_get(COM_SID, "iCloudlocationTimestampHR", lul_device)
	
	data.iCloudbatteryLevel = luup.variable_get(COM_SID, "iCloudbatteryLevel", lul_device)
	data.iCloudbatteryStatus = luup.variable_get(COM_SID, "iCloudbatteryStatus", lul_device)
	data.BatteryLevel = luup.variable_get(BAT_SID, "BatteryLevel", lul_device)
	data.BatteryDate = luup.variable_get(BAT_SID, "BatteryDate", lul_device)
	
	return data
		
end

function refreshMyiPhoneLocation(lul_device) 
	log("[refreshMyiPhoneLocation] function called")
	local lul_device = tonumber(lul_device)
	local AppleResponse = GoGetMyiPhoneInfo(lul_device)
	local json = require('dkjson')
	local output = json.decode(AppleResponse)
	local TargetDevName = luup.variable_get(COM_SID, "MyTargetDeviceName", lul_device)
	log("Target device to find = " ..TargetDevName)
	--local areyouhome = false
	local next = next 
	for key,value in pairs(output.content) do
		local outputDevName = value.name
			if outputDevName == TargetDevName then 
				log(outputDevName .." - " ..TargetDevName .. " are a match!")
				local outputDevDispName = value.deviceDisplayName 
				local outputModDispName = value.modelDisplayName
				local outputlocEnabled = tostring(value.locationEnabled) 
				--local outputdeviceClass = value.deviceClass 
				
				local outputbatteryLevelA = tonumber(value.batteryLevel)
			--	log("outputbatteryLevelA = " ..outputbatteryLevelA)
				local outputbatteryLevelB = outputbatteryLevelA * 100
		--		log("outputbatteryLevelB = " ..outputbatteryLevelB)
				local outputbatteryLevelC = round(outputbatteryLevelB,0) or 0
		--		log("outputbatteryLevelC = " ..outputbatteryLevelC)
				local outputbatteryStatus = value.batteryStatus
				
				luup.variable_set(COM_SID, "iCloudDisplayName", outputDevDispName , lul_device)
				luup.variable_set(COM_SID, "iCloudmodelDisplayName", outputModDispName , lul_device)
				luup.variable_set(COM_SID, "iCloudlocationEnabled", outputlocEnabled , lul_device)
				--luup.variable_set(COM_SID, "iCloudClass", outputdeviceClass , lul_device)
				
				luup.variable_set(COM_SID, "iCloudbatteryLevel", outputbatteryLevelA , lul_device)
				luup.variable_set(COM_SID, "iCloudbatteryStatus", outputbatteryStatus , lul_device)
				
				luup.variable_set(BAT_SID, "BatteryLevel", outputbatteryLevelC, lul_device)
				luup.variable_set(BAT_SID, "BatteryDate", os.time() , lul_device)
				
				local outputlongitude = tonumber(value.location.longitude)
				local outputlatitude = tonumber(value.location.latitude)
				local outputserverTimestampA = tonumber(value.location.timeStamp)
				local outputserverTimestampB = 1641937445742 / 1000 -- remove milliseconds
				local outputserverTimestampHR = os.date( "%H:%M:%S - %d/%m/%Y" , outputserverTimestampB )
				
				luup.variable_set(COM_SID, "iCloudlatitude", outputlatitude , lul_device)
				luup.variable_set(COM_SID, "iCloudlongitude", outputlongitude , lul_device)
				luup.variable_set(COM_SID, "iCloudlocationTimestamp", outputserverTimestamp , lul_device)
				luup.variable_set(COM_SID, "iCloudlocationTimestampHR", outputserverTimestampHR , lul_device)
				
				local outputdistance = distanceBetween()
				
			else
				log(outputDevName .." - " ..TargetDevName .. " not a match")
			end
	end
	--luup.call_timer("NC_MYiPstartNewDay", 2, "23:59:00", "1,2,3,4,5,6,7", lul_device)
	--luup.call_delay("NC_MYiPstartUpAppleCheckIn", 60, lul_device)
end
		
function AppleiCloudCheckIn(lul_device)
	log("(4) Checking iCloud access..." )
	local AppleResponse = GoGetMyiPhoneInfo(lul_device)
	local json = require('dkjson')
	local output = json.decode(AppleResponse) or "ERROR! No Output returned"
	local next = next 
	if not next(output) then -- Table is empty
		luup.log("ERROR: iCloud returned an empty table = " ..tostring(output))
		luup.variable_set(COM_SID, "PluginStatus", "ERROR: Empty iCloud response! 3/4")
		luup.variable_set(COM_SID, "Icon", 2, lul_device)
	else
		luup.log("SUCCESS: iCloud returned = " ..tostring(output))
		luup.variable_set(COM_SID, "PluginStatus", "Successfully Configured! 4/4", lul_device)
		luup.variable_set(COM_SID, "Icon", 1, lul_device)
		
		local allregDevices = ""
		for key,value in pairs(output.content) do
			local outputDevName = value.name
			allregDevices = allregDevices ..", "..outputDevName
			--log(allregDevices)
		end
		log(allregDevices)
		luup.variable_set(COM_SID, "AppleRegisteredDevices", allregDevices:sub(3), lul_device)
		luup.call_delay("NC_MYiPrefreshMyiPhoneLocation", 20, lul_device)
		luup.call_timer("NC_MYiPrefreshMyiPhoneLocation", 1, "30m", "", lul_device) 
	end
end
		
function checkSetUp(lul_device)
	log("(3) Checking plugin configuration...")
	
	local data = readMyiPhoneVariables(lul_device)
	local varmissing = ""
	
	if data.MyAppleUsername == "Enter Apple UserID Here" then varmissing = "Username, " end
	if data.MyApplePassword == "Enter Apple Password Here" then varmissing = varmissing .. "Password, " end
	if data.MyTargetDeviceName == "Enter Target Device Name Here" then varmissing = varmissing .. "Registered Device, " end
	if data.MyHomeLongitude == 0 then varmissing = varmissing .. "Home Longitude, " end
	if data.MyHomeLatitude == 0 then varmissing = varmissing .. "Home Latitude, " end
	-- if data.MyHomeSkew == 0 then varmissing = varmissing .. "Home Skew, " end	
		if varmissing ~= "" then
			luup.variable_set(COM_SID, "PluginStatus", "ERROR: "..varmissing.." Missing! 2/4", lul_device)
			luup.variable_set(COM_SID, "Icon", 2, lul_device)
			log("ERROR: " ..varmissing.. " Missing!")
			log("Plugin unable to progress any further!")
		else
			luup.variable_set(COM_SID, "PluginStatus", "Required Variables Registered 3/4", lul_device)
			luup.variable_set(COM_SID, "Icon", 1, lul_device)
			log("SUCCESS: Required Variables registered..")
			AppleiCloudCheckIn(lul_device) 
			luup.call_timer("NC_MYiPrefreshMyiPhoneLocation", 1, "30m", "", lul_device) 
		end
end

local function populateFixedVariables(lul_device)
	log("(2) Populating fixed variables...")
	
	local MyAppleUsername = luup.variable_get(COM_SID, "MyAppleUsername", lul_device)
		if (MyAppleUsername == nil) then luup.variable_set(COM_SID, "MyAppleUsername", "Enter Apple UserID Here" , lul_device) end
	local MyApplePassword = luup.variable_get(COM_SID, "MyApplePassword", lul_device)
		if (MyApplePassword == nil) then luup.variable_set(COM_SID, "MyApplePassword", "Enter Apple Password Here" , lul_device) end
	
	--My Home Location
	local MyHomeLongitude = luup.variable_get(COM_SID, "MyHomeLongitude", lul_device)
		if (MyHomeLongitude == nil) then luup.variable_set(COM_SID, "MyHomeLongitude", 0 , lul_device) end
	local MyHomeLatitude = luup.variable_get(COM_SID, "MyHomeLatitude", lul_device)
		if (MyHomeLatitude == nil) then luup.variable_set(COM_SID, "MyHomeLatitude", 0 , lul_device) end
	--local MyHomeSkew = luup.variable_get(COM_SID, "MyHomeSkew", lul_device)
		--if (MyHomeSkew == nil) then luup.variable_set(COM_SID, "MyHomeSkew", 0 , lul_device) end
	
	-- My Target Apple Device
	local MyTargetDeviceName = luup.variable_get(COM_SID, "MyTargetDeviceName", lul_device)
		if (MyTargetDeviceName == nil) then luup.variable_set(COM_SID, "MyTargetDeviceName", "Enter Target Device Name Here" , lul_device) end
	local MyTargetDeviceDistance = luup.variable_get(COM_SID, "MyTargetDeviceDistance", lul_device)
		if (MyTargetDeviceDistance == nil) then luup.variable_set(COM_SID, "MyTargetDeviceDistance", "" , lul_device) end
	local MyTargetDistanceUnit = luup.variable_get(COM_SID, "MyTargetDistanceUnit", lul_device)
		if (MyTargetDistanceUnit == nil) then luup.variable_set(COM_SID, "MyTargetDistanceUnit", "K" , lul_device) end
		
	-- Apple Device details returned
	local iCloudDisplayName = luup.variable_get(COM_SID, "iCloudDisplayName", lul_device)
		if (iCloudDisplayName == nil) then luup.variable_set(COM_SID, "iCloudDisplayName", "" , lul_device) end
	local iCloudmodelDisplayName = luup.variable_get(COM_SID, "iCloudmodelDisplayName", lul_device)
		if (iCloudmodelDisplayName == nil) then luup.variable_set(COM_SID, "iCloudmodelDisplayName", "" , lul_device) end
		
	-- Apple Device location details returned
	local iCloudlocationEnabled = luup.variable_get(COM_SID, "iCloudlocationEnabled", lul_device)
		if (iCloudlocationEnabled == nil) then luup.variable_set(COM_SID, "iCloudlocationEnabled", "" , lul_device) end
	local iCloudlongitude = luup.variable_get(COM_SID, "iCloudlongitude", lul_device)
		if (iCloudlongitude == nil) then luup.variable_set(COM_SID, "iCloudlongitude", 0 , lul_device) end
	local iCloudlatitude = luup.variable_get(COM_SID, "iCloudlatitude", lul_device)
		if (iCloudlatitude == nil) then luup.variable_set(COM_SID, "iCloudlatitude", 0 , lul_device) end
	local iCloudlocationTimestamp = luup.variable_get(COM_SID, "iCloudlocationTimestamp", lul_device)
		if (iCloudlocationTimestamp == nil) then luup.variable_set(COM_SID, "iCloudlocationTimestamp", 0 , lul_device) end
	local iCloudlocationTimestampHR = luup.variable_get(COM_SID, "iCloudlocationTimestampHR", lul_device)
		if (iCloudlocationTimestampHR) == nil then luup.variable_set(COM_SID,"iCloudlocationTimestampHR", "" , lul_device) end
		
	-- Apple Device Battary Variables
	local iCloudbatteryLevel = luup.variable_get(COM_SID, "iCloudbatteryLevel", lul_device)
		if (iCloudbatteryLevel == nil) then luup.variable_set(COM_SID, "iCloudbatteryLevel", "0" , lul_device) end
	local iCloudbatteryStatus = luup.variable_get(COM_SID, "iCloudbatteryStatus", lul_device)
		if (iCloudbatteryStatus == nil) then luup.variable_set(COM_SID, "iCloudbatteryStatus", "" , lul_device) end
	
	-- Luup/Vera Battery Variables
	local batteryLevel = luup.variable_get(BAT_SID, "BatteryLevel", lul_device)
		if (batteryLevel == nil) then luup.variable_set(BAT_SID, "BatteryLevel", 0 , lul_device) end	
	local batteryDate = luup.variable_get(BAT_SID, "BatteryDate", lul_device)
		if (batteryDate == nil) then luup.variable_set(BAT_SID, "BatteryDate", 0 , lul_device) end
	
	luup.variable_set(COM_SID, "PluginStatus", "Fixed variables set up 2/4", lul_device)
	
	checkSetUp(lul_device)
	
end

function MyiPhoneStartUp(lul_device)
	log("(1) Setting up plugin...")
	luup.variable_set(COM_SID, "Icon", 0, lul_device)
	luup.variable_set(COM_SID, "PluginVersion", PV, lul_device)
	luup.variable_set(COM_SID, "Debug", true, lul_device)
	luup.variable_set(COM_SID, "PluginStatus", "Plugin being installed 1/4 ", lul_device)
	populateFixedVariables(lul_device)
end