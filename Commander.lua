--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local isTestMode = not RunService:IsEdit()

local toolbar = plugin:CreateToolbar("Commander")
local button = toolbar:CreateButton("Commander", "Opens the Commander menu", "rbxassetid://18845886149")
button.ClickableWhenViewportHidden = true

local widget = plugin:CreateDockWidgetPluginGui("ClassConvert", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	800,
	350,
	600,
	350
	)
)
widget.Name = "Commander"
widget.Title = "Commander"
widget.ResetOnSpawn = false
widget.Enabled = false

local executeButton: TextButton
local colourSyncTargets: {GuiObject | UIStroke} = {}

-- This is not a comprehensive function and it should be updated if new ui objects are added
local function syncOne(v: GuiObject | UIStroke, theme: any, noSyncPrimarySelection: boolean?)
	if v:IsA("UIStroke") then
		v.Color = theme:GetColor(Enum.StudioStyleGuideColor.Border)
	elseif v:IsA("GuiObject") then
		if v == executeButton and v:IsA("TextButton") then
			v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Disabled)
			v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText, Enum.StudioStyleGuideModifier.Disabled)
		elseif v:IsA("TextBox") then
			v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground)
			v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
			v.PlaceholderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText)
		elseif v:IsA("TextLabel") then
			v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
		elseif v:IsA("TextButton") then
			v.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button)
			v.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText)
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
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, 1)

local codeBoxFrame = Instance.new("ScrollingFrame")

codeBoxFrame.Position = UDim2.new(0.2, 4, 0, 4)
codeBoxFrame.Size = UDim2.new(0.8, -8, 0.8, -8)

codeBoxFrame.ClipsDescendants = true
codeBoxFrame.BackgroundTransparency = 1
codeBoxFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
codeBoxFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
codeBoxFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
codeBoxFrame.ScrollBarThickness = 4
codeBoxFrame.CanvasSize = UDim2.new()

codeBoxFrame.Parent = frame

local codeBox = Instance.new("TextBox")

codeBox.TextColor3 = Color3.new(1, 1, 1)
codeBox.TextSize = 18

codeBox.Font = Enum.Font.RobotoMono
codeBox.PlaceholderText = ""
codeBox.Text = ""

codeBox.Size = UDim2.fromScale(1, 1)

codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.AutomaticSize = Enum.AutomaticSize.XY

codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true

do
    local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = codeBox

    local uiStroke = Instance.new("UIStroke")
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    table.insert(colourSyncTargets, uiStroke)
    uiStroke.Parent = codeBox

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, 8)
    uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.Parent = codeBox
end

table.insert(colourSyncTargets, codeBox)
codeBox.Parent = codeBoxFrame

do
	local warningLabel = Instance.new("TextLabel")

	warningLabel.Font = Enum.Font.SourceSans
	warningLabel.Text = "NOTE: Be careful when using Instance:Destroy(), as it is not possible to undo this! Instead, consider using Instance.Parent = nil."
	warningLabel.TextScaled = true

	warningLabel.Position = UDim2.new(0, 4, 0.825, 0)
	warningLabel.Size = UDim2.new(0.55, -8, 0.15, -4)

	warningLabel.BackgroundTransparency = 1

	warningLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	table.insert(colourSyncTargets, warningLabel)
	warningLabel.Parent = frame
end

executeButton = Instance.new("TextButton")
executeButton.BackgroundColor3 = Color3.fromRGB(0, 197, 23)

executeButton.Font = Enum.Font.SourceSans
executeButton.Text = "▶ Execute"
executeButton.TextColor3 = Color3.new(1, 1, 1)

executeButton.Size = UDim2.fromScale(0.2, 0.15)
executeButton.Position = UDim2.new(0.8, -4, 0.9, 0)
executeButton.AnchorPoint = Vector2.new(0, 0.5)
executeButton.TextScaled = true

if isTestMode then
	table.insert(colourSyncTargets, executeButton)
	executeButton.AutoButtonColor = false
end

do
    local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = executeButton

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.PaddingTop = UDim.new(0, 5)
	uiPadding.PaddingLeft = UDim.new(0, 5)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.Parent = executeButton
end

executeButton.Parent = frame

local presetsFrame = Instance.new("ScrollingFrame")

presetsFrame.ScrollBarThickness = 4
presetsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
presetsFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always

presetsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
presetsFrame.CanvasSize = UDim2.new()
presetsFrame.Size = UDim2.new(0.2, -8, 0.8, -8)
presetsFrame.Position = UDim2.fromOffset(4, 4)

do
	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = presetsFrame

	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.fromScale(1, 0.2)
	uiGridLayout.Parent = presetsFrame
end

table.insert(colourSyncTargets, presetsFrame)
presetsFrame.Parent = frame

type Presets = {
	[string]: string?,
}

local function getPresets(): Presets
	local presets = plugin:GetSetting("Presets")
	if not presets then
		return {
			["Hello, World!"] = 'print("Hello, World!")',
		}
	end
	return HttpService:JSONDecode(plugin:GetSetting("Presets"))
end

local function updatePreset(name: string, code: string?): ()
	local presets = getPresets()
	presets[name] = code

	plugin:SetSetting("Presets", HttpService:JSONEncode(presets))
end

local function loadPreset(name: string): ()
	local data = getPresets()
	if not data then
		return warn("Failed to load preset " .. name)
	end

	local code = data[name]
	if not code then
		return warn("Failed to load preset " .. name)
	end

	local preset = code
	codeBox.Text = preset
end

local function createPresetButton(name: string): ()
	local button = Instance.new("TextButton")
	button.Font = Enum.Font.SourceSans
	button.Text = name
	
	button.TextScaled = true

	do
		local uiCorner = Instance.new("UICorner")
		uiCorner.Parent = button
	end

	button.MouseButton1Click:Connect(function()
		loadPreset(name)
	end)

	button.MouseButton2Click:Connect(function()
		updatePreset(name, nil)
		button:Destroy()
	end)

	table.insert(colourSyncTargets, button)
	syncOne(button, settings().Studio.Theme)
	button.Parent = presetsFrame
end

local function saveAsPreset(name: string)
	if not getPresets()[name] then
		createPresetButton(name)
	end
	updatePreset(name, codeBox.Text)
end

for i in getPresets() do
	createPresetButton(i)
end

local saveAs = Instance.new("TextBox")
saveAs.Font = Enum.Font.SourceSans
saveAs.Text = ""
saveAs.PlaceholderText = "Save as..."

saveAs.AnchorPoint = Vector2.new(0, 0.5)
saveAs.Position = UDim2.new(0.575, -4, 0.9, 0)
saveAs.Size = UDim2.fromScale(0.2, 0.15)
saveAs.TextScaled = true

do
	local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = saveAs

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.PaddingTop = UDim.new(0, 5)
	uiPadding.PaddingLeft = UDim.new(0, 5)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.Parent = saveAs
end

table.insert(colourSyncTargets, saveAs)
saveAs.Parent = frame

saveAs.FocusLost:Connect(function(enterPressed)
	if not enterPressed or saveAs.Text == "" then
		return
	end

	saveAsPreset(saveAs.Text)
end)

frame.Parent = widget

if isTestMode then
	local warning = Instance.new("TextButton")

	warning.Size = UDim2.fromScale(1, 0.1)

	warning.TextScaled = true
	warning.Font = Enum.Font.SourceSans

	warning.TextColor3 = Color3.new(1, 1, 1)
	warning.BackgroundColor3 = Color3.fromRGB(255, 179, 0)
	warning.BorderSizePixel = 0

	warning.Text = "NOTE: Running in test mode, execution will not be possible. Instead you can copy-paste code into the standard Studio command bar. Undo will not be available."

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingBottom = UDim.new(0.05, 0)
	uiPadding.PaddingTop = UDim.new(0.05, 0)
	uiPadding.Parent = warning

	warning.Parent = frame

	warning.Activated:Connect(function()
		warning.Parent = nil
	end)
end

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	if widget.Enabled then
		codeBox:CaptureFocus()
	end
end)

if not isTestMode then
	executeButton.MouseButton1Click:Connect(function()
		local recording: string?
		if not isTestMode then
			recording = ChangeHistoryService:TryBeginRecording("Execute commander code")
			if not recording then
				return warn("Unable to create undo waypoint, possibly due to another execution already in progress. Execution aborted.")
			end
		end
	
		local code = codeBox.Text
	
		local success, result = pcall(function(): (any, any)
			local exec, err = loadstring(code)
			if not exec then
				return error(err or "Unknown error occured")
			end
			return exec()
		end)
	
		if not success then
			warn(result)
		end
	
		if recording and not isTestMode then
			ChangeHistoryService:FinishRecording(recording, if success then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel)
		end
	end)
end

syncColours()
settings().Studio.ThemeChanged:Connect(syncColours)
