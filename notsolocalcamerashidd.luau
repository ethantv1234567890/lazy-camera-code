-- ServerScriptService > CameraDetectorScript
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "CameraChangeEvent"
remoteEvent.Parent = game.ReplicatedStorage

-- Function to gather all camera parts in LANEMASTER models and send to client
local function sendCameraListToClient(player)
	local cameras = {}

	-- Search for all "LANEMASTER" models in Workspace
	for _, lanemasterModel in ipairs(workspace:GetChildren()) do
		if lanemasterModel:IsA("Model") and lanemasterModel.Name == "LANEMASTER" then
			print("Found LANEMASTER model:", lanemasterModel.Name)  -- Debugging

			-- Find the pairnumber part and ensure it's an IntValue
			local pairnumberPart = lanemasterModel:FindFirstChild("pairnumber")
			if pairnumberPart and pairnumberPart:IsA("IntValue") then
				local pairnumber = pairnumberPart.Value
				print("Pairnumber found:", pairnumber)  -- Debugging

				-- Calculate lane numbers based on pairnumber
				local lane1 = (pairnumber * 2) - 1
				local lane2 = pairnumber * 2
				print("Lane numbers for pairnumber", pairnumber, "are:", lane1, "and", lane2)  -- Debugging

				-- Find the Lane model inside LANEMASTER
				local laneModel = lanemasterModel:FindFirstChild("Lane")
				if laneModel and laneModel:IsA("Model") then
					print("Found Lane model inside LANEMASTER:", laneModel.Name)  -- Debugging

					-- Iterate over the children of Lane model to find Camera parts
					local cameraIndex = 1
					for _, item in ipairs(laneModel:GetChildren()) do
						if item:IsA("BasePart") and item.Name == "Camera" then
							-- Assign lane numbers swapped to maintain numerical order in UI
							local laneNumber = (cameraIndex == 1) and lane2 or lane1
							local cameraName = "Lane " .. laneNumber .. " - Camera"
							print("Camera found:", item.Name, "assigned to:", cameraName)  -- Debugging

							-- Add this camera to the list to send to client
							table.insert(cameras, {part = item, name = cameraName, laneNumber = laneNumber})
							cameraIndex = cameraIndex + 1
						else
							print("Item in Lane is not a Camera:", item.Name, item.ClassName)  -- Debugging
						end
					end
				else
					print("Lane model not found in LANEMASTER:", lanemasterModel.Name)  -- Debugging
				end
			else
				print("No valid pairnumber found in LANEMASTER:", lanemasterModel.Name)  -- Debugging
			end
		end
	end

	-- Sort the cameras list by laneNumber to ensure numerical order in the UI
	table.sort(cameras, function(a, b)
		return a.laneNumber < b.laneNumber
	end)

	-- Send the sorted list of cameras to the client
	print("Sending camera list to client:", #cameras, "cameras found")  -- Debugging
	remoteEvent:FireClient(player, cameras)
end

-- When a player joins, send them the list of cameras
game.Players.PlayerAdded:Connect(function(player)
	sendCameraListToClient(player)
end)
