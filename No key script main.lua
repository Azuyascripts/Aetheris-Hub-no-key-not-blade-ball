local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

local engine = getgenv().HubEngine
if not engine then
	warn("[AETHERIS CORE ERROR] Part 1 Core Engine must be executed before running the Repo Loader!")
	return
end

local sendNotification = engine.SendNotification
local loadKeyboardModule = engine.LoadKeyboardModule

local ScriptDatabase = {
	["SUSPECT"] = {
		Tag = "[AETHERIS | FRIEND / SUSPECT]",
		PlaceIds = {
			121268060261990
		},
		Keywords = {"suspect", "friend", "murder", "impostor"},
		Url = "https://raw.githubusercontent.com/Azuyascripts/gan-hub.1/refs/heads/main/suspect.lua"
	},
	["GRANNY"] = {
		Tag = "[AETHERIS | DODGE GRANNY]",
		PlaceIds = {
			97848363466906
		},
		Keywords = {"granny", "dodge granny", "dodge"},
		Url = "https://raw.githubusercontent.com/Azuyascripts/gan-hub.2/refs/heads/main/gareey.lua"
	}
}

local function executeExternalScript(scriptUrl, tag)
	sendNotification(tag, "Fetching script module...")

	task.spawn(function()
		local success, rawScript = pcall(function()
			return game:HttpGet(scriptUrl)
		end)

		if success and rawScript and #rawScript > 0 then
			local execSuccess, execErr = pcall(function()
				loadstring(rawScript)()
			end)

			if execSuccess then
				sendNotification(tag, "Module initialized successfully!")
			else
				warn(execErr)
				sendNotification("Execution Error", "Failed to run target module.")
			end
		else
			warn(rawScript)
			sendNotification("Fetch Error", "Failed to connect to repository.")
		end
	end)
end

local function detectAndLoad()
	local currentPlaceId = game.PlaceId
	local gameName = "Unknown Game"

	pcall(function()
		local productInfo = MarketplaceService:GetProductInfo(currentPlaceId)
		if productInfo and productInfo.Name then
			gameName = productInfo.Name
		end
	end)

	sendNotification("Aetheris Loader", "Scanning Place ID: " .. tostring(currentPlaceId))

	local matchedEntry = nil
	local lowerGameName = gameName:lower()

	for _, data in pairs(ScriptDatabase) do
		for _, id in ipairs(data.PlaceIds) do
			if id == currentPlaceId then
				matchedEntry = data
				break
			end
		end
		if matchedEntry then break end
	end

	if not matchedEntry then
		for _, data in pairs(ScriptDatabase) do
			for _, keyword in ipairs(data.Keywords) do
				if lowerGameName:find(keyword) then
					matchedEntry = data
					break
				end
			end
			if matchedEntry then break end
		end
	end

	if matchedEntry then
		sendNotification("Aetheris Target Found", matchedEntry.Tag .. " (" .. gameName .. ")")
		executeExternalScript(matchedEntry.Url, matchedEntry.Tag)
	else
		sendNotification("[AETHERIS | GENERIC]", "Unsupported game. Deploying WASD overlay...")
		if loadKeyboardModule then
			loadKeyboardModule(true)
		end
	end

	local extensionUrl = "https://raw.githubusercontent.com/Azuyascripts/gan-hub/refs/heads/main/load.Extension.lua"
	task.spawn(function()
		pcall(function()
			local extScript = game:HttpGet(extensionUrl)
			if extScript and #extScript > 0 then
				loadstring(extScript)()
			end
		end)
	end)
end

detectAndLoad()
