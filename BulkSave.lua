--!strict
local Selection = game:GetService("Selection")

local toolbar = plugin:CreateToolbar("Bulk Save")

local button = toolbar:CreateButton("Save", "Individually saves selected Instances", "rbxassetid://94073691148866")
button.ClickableWhenViewportHidden = true

button.Click:Connect(function()
	local allSelected = Selection:Get()

	for _, v in allSelected do
		Selection:Set({v})
		plugin:PromptSaveSelection(v.Name)
	end

	Selection:Set(allSelected)
end)