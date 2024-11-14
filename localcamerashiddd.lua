local player = game.Players.LocalPlayer
local playerCam = workspace.CurrentCamera
local cameraUI = script.Parent
local scrollingFrame = cameraUI.ScrollingFrame
local cameraButtonTemplate = scrollingFrame.CameraButtonTemplate
local exitButton = cameraUI.ExitButton
local remoteEvent = game.ReplicatedStorage:WaitForChild("CameraChangeEvent")

-- Exit Button Settings
exitButton.Visible = false
exitButton.Text = "Exit"
exitButton.Size = UDim2.new(0, 100, 0, 50)
exitButton.Position = UDim2.new(0.5, -50, 1, -60)

-- Ensure the template button is hidden (you can also set this in the properties manually)
cameraButtonTemplate.Visible = false

-- Function to Reset Camera to Player's View
local function resetCamera()
	playerCam.CameraType = Enum.CameraType.Custom
	exitButton.Visible = false
end

-- Function to Switch to a Specified "Camera" Part
local function switchToCamera(part)
	playerCam.CameraType = Enum.CameraType.Scriptable
	playerCam.CFrame = part.CFrame
	playerCam.Focus = part.CFrame
	exitButton.Visible = true
end

-- Function to Populate Camera Buttons in UI
local function populateCameraButtons(cameras)
	-- Clear previous buttons, but leave the template intact
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") and child ~= cameraButtonTemplate then
			child:Destroy()
		end
	end

	print("Populating camera buttons, total cameras:", #cameras)  -- Debugging

	-- Create a button for each "camera" part received from the server
	for _, cameraData in ipairs(cameras) do
		local newButton = cameraButtonTemplate:Clone()
		newButton.Parent = scrollingFrame
		newButton.Text = cameraData.name
		newButton.Visible = true  -- Make the clone visible, not the original template
		print("Button created for:", cameraData.name)  -- Debugging

		-- Set up button click to switch to this "camera" part
		newButton.MouseButton1Click:Connect(function()
			switchToCamera(cameraData.part)
		end)
	end
end

-- Listen for the list of cameras from the server
remoteEvent.OnClientEvent:Connect(function(cameras)
	populateCameraButtons(cameras)
end)

-- Exit button action
exitButton.MouseButton1Click:Connect(resetCamera)
