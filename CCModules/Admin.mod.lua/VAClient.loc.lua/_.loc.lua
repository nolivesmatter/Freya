local Player = game:GetService"Players".LocalPlayer;
local Binds = require(game.ReplicatedStorage.Freya.Main):GetComponent "Input"
local active = false;
local commandSend = script.DoCommand;

-- Init
local commandHistory = {};

-- Create the console
local consoleContainer = Instance.new("ScreenGui", Player:WaitForChild"PlayerGui");
consoleContainer.Name = "VAConsole";
local lowerFrame = Instance.new('Frame', consoleContainer);
lowerFrame.Name = 'Container';
lowerFrame.Size = UDim2.new(1,0,0.4,0);
lowerFrame.BackgroundTransparency = 1;
local inputBox = Instance.new('TextBox', lowerFrame);
inputBox.Size = UDim2.new(1,-60,0,20);
inputBox.Position = UDim2.new(0,0,0,-20);
inputBox.BackgroundColor = Color3.new(0.07,0.07,0.07);
inputBox.BorderSizePixel = 0;
inputBox.ZIndex = 2;
inputBox.ClearTextOnFocus = false;
inputBox.Text = "";
local sendButton = Instance.new('TextButton', lowerFrame);
sendButton.Size = UDim2.new(0,60,0,0);
sendButton.Position = UDim2.new(0,60,0,20);
sendButton.ZIndex = 2;
sendButton.Text = "Send"
local historyContainer = Instance.new('Frame', lowerFrame);
historyContainer.Size = UDim2.new(1,0,1,-20);
historyContainer.Position = UDim2(0,0,0,0);
historyContainer.BackgroundTransparency = 0.4;
historyContainer.BackgroundColor = Color3.new(0.1,0.1,0.1);
historyContainer.ZIndex = 2;

-- Bind to user input to pull up the terminal/console
local Open = Binds:CreateAction("OpenAdmin", function()
	active = not active;
	if active then
		lowerFrame:TweenPosition(UDim2.new(0,0,0,0), nil, 4, 0.4, true)
	else
		lowerFrame:TweenPosition(UDim2.new(0,0,1,0), nil, 4, 0.5, true)
	end
end);
Open:BindControl(Binds.InputSources.Keyboard.Tilde, Binds.InputDirections.Down);
local Focus = Binds:CreateAction("FocusAdmin", function()
	if active then
		inputBox:CaptureFocus();
	else
		inputBox:ReleaseFocus();
	end
end);
Focus:BindControl(Binds.InputSources.Keyboard.Tilde, Binds.InputDirections.Down);

-- Bind the console
sendButton.MouseButton1Click:connect(function()
	commandSend:FireServer(inputBox.Text);
	if #commandHistory >= 10 then
		table.remove(commandHistory,1);
	end;
	commandHistory[#commandHistory+1] = inputBox.Text;
	for i,v in ipairs(historyContainer:GetChildren()) do
		v:Destroy();
	end;
	for i=1,#commandHistory do
		v = commandHistory[i];
		local b = Instance.new("TextButton", historyContainer);
		b.Size = UDim2.new(0,0,0.04,0);
		b.Position = UDim2.new(0,0,1-0.1*i,0);
		b.Text = inputBox.Text;
		b.MouseButton1Click:connect(function()
			inputBox.Text = b.Text;
		end);
		b.BorderSizePixel = 0;
		b.BackgroundColor = Color3.new(0,0,0);
		b.BackgroundTransparency = 0.4;
	end;
	inputBox.Text = '';
end);
