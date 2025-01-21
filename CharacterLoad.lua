--!strict
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if not RunService:IsEdit() then
	return
end

local toolbar = plugin:CreateToolbar("Character Load")
local button = toolbar:CreateButton("Character Load", "Opens the Character Load menu", "rbxassetid://134618113656697")
button.ClickableWhenViewportHidden = true

local widget = plugin:CreateDockWidgetPluginGui("ClassConvert", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	310,
	110,
	100,
	100
	)
)
widget.Name = "Character Load"
widget.Title = "Character Load"
widget.ResetOnSpawn = false
widget.Enabled = false

type OutputTextColour = "None" | "Success" | "Error"

local colourSyncTargets: {GuiObject | UIStroke} = {}

local function getTheme(): StudioTheme
	return settings().Studio.Theme
end

-- This is not a comprehensive function and it should be updated if new ui objects are added
local function syncOne(v: GuiObject | UIStroke, theme: StudioTheme)
	if v:IsA("UIStroke") then
		v.Color = theme:GetColor(Enum.StudioStyleGuideColor.Border)
	elseif v:IsA("GuiObject") then
		if v:IsA("TextBox") then
			v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground)
			v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
			v.PlaceholderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText)
		elseif v:IsA("TextLabel") then
			v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
		elseif v:IsA("TextButton") then
			local textColour: OutputTextColour? = v:GetAttribute("TextColour") :: OutputTextColour?
			if textColour then
				if textColour == "None" or textColour == "Success" then
					v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
				elseif textColour == "Error" then
					v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ErrorText)
				else
					error("Unknown text colour: " .. textColour)
				end
			else
				v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText)
			end
			v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button)
		else
			v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		end
	end
end

local function syncColours()
	local theme = settings().Studio.Theme
	for _, v in colourSyncTargets do
		syncOne(v, theme)
	end
end

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.Transparency = 1

do
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 5)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.PaddingTop = UDim.new(0, 5)
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.Parent = frame
end

local inputBox = Instance.new("TextBox")
inputBox.Font = Enum.Font.SourceSans
inputBox.PlaceholderText = "Enter Username or User ID..."
inputBox.Text = ""
inputBox.TextScaled = true
inputBox.Size = UDim2.fromScale(1, 0.4)
inputBox.ClearTextOnFocus = false
inputBox.Name = "Input"

do
	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = inputBox

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	table.insert(colourSyncTargets, uiStroke)
	uiStroke.Parent = inputBox
end

table.insert(colourSyncTargets, inputBox)
inputBox.Parent = frame

local output = Instance.new("TextLabel")
output.Font = Enum.Font.SourceSans
output.Size = UDim2.fromScale(1, 0.15)
output.Position = UDim2.fromScale(0, 0.425)
output.BackgroundTransparency = 1
output.TextScaled = true
output.Name = "Output"

table.insert(colourSyncTargets, output)

local function updateOutputText(text: string, colour: OutputTextColour): ()
	output.Text = text
	output:SetAttribute("TextColour", colour)
	syncOne(output, getTheme())
end

updateOutputText("", "None")
output.Parent = frame

local spawnR6Button = Instance.new("TextButton")
spawnR6Button.Font = Enum.Font.SourceSans
spawnR6Button.Text = "Spawn R6"
spawnR6Button.TextScaled = true
spawnR6Button.Position = UDim2.fromScale(0, 0.6)
spawnR6Button.Size = UDim2.new(0.5, -3, 0.4, 0)
spawnR6Button.Name = "SpawnR6"

do
	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = spawnR6Button

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	table.insert(colourSyncTargets, uiStroke)
	uiStroke.Parent = spawnR6Button
end

table.insert(colourSyncTargets, spawnR6Button)
spawnR6Button.Parent = frame

local spawnR15Button = spawnR6Button:Clone()
spawnR15Button.Text = "Spawn R15"
spawnR15Button.Position = UDim2.fromScale(1, 0.6)
spawnR15Button.AnchorPoint = Vector2.new(1, 0)
spawnR15Button.Name = "SpawnR15"

do
	local uiStroke = spawnR15Button:FindFirstChildOfClass("UIStroke")
	assert(uiStroke)
	table.insert(colourSyncTargets, uiStroke)
end

table.insert(colourSyncTargets, spawnR15Button)
spawnR15Button.Parent = frame

local userIdCache: {[string]: number} = {}
local function tryGetUserIdFromText(text: string): number?
	if userIdCache[text] then
		return userIdCache[text]
	end

	local asNumber = tonumber(text, 10)
	if asNumber then
		return asNumber
	end

	local _, result: number | string = pcall(Players.GetUserIdFromNameAsync, Players, text)

	if typeof(result) == "number" then
		userIdCache[text] = result
		return result
	end

	updateOutputText(result:split("Players:GetUserIdFromNameAsync() failed: ")[2], "Error")

	return nil
end

local descriptionCache: {[number]: HumanoidDescription} = {}
local function tryLoadCharacter(userId: number, mode: "R6" | "R15"): ()
	local description: HumanoidDescription
	if descriptionCache[userId] then
		description = descriptionCache[userId]
	else
		local _, result: HumanoidDescription | string = pcall(Players.GetHumanoidDescriptionFromUserId, Players, userId)
		if typeof(result) == "string" then
			return updateOutputText(result:split("Players:GetHumanoidDescriptionFromUserId() ")[2], "Error")
		end
		description = result
	end

	local model = Players:CreateHumanoidModelFromDescription(description, if mode == "R6" then Enum.HumanoidRigType.R6 else Enum.HumanoidRigType.R15)
	
	local recording = ChangeHistoryService:TryBeginRecording("Load character")
	if not recording then
		return warn("Unable to create undo waypoint, possibly due to another character already being loaded. Load aborted.")
	end

	model.Name = tostring(userId)
	model.Parent = workspace

	ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	updateOutputText("Successfully loaded character!", "Success")
end

spawnR15Button.Activated:Connect(function(): ()
	local id = tryGetUserIdFromText(inputBox.Text)
	if id then
		tryLoadCharacter(id, "R15")
	end
end)

spawnR6Button.Activated:Connect(function(): ()
	local id = tryGetUserIdFromText(inputBox.Text)

	if id then
		tryLoadCharacter(id, "R6")
	end
end)

inputBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateOutputText("", "None")
end)

frame.Parent = widget

syncColours()
settings().Studio.ThemeChanged:Connect(syncColours)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)