-- Phantom UI - ClickGUI Edition (Purple Theme)

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Library = {
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(20, 15, 25), -- Panel background
        Header = Color3.fromRGB(35, 20, 50),     -- Panel header
        Accent = Color3.fromRGB(150, 100, 255),  -- Toggled state / accents (Purple)
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 180),
        Element = Color3.fromRGB(30, 25, 40),    -- Element background
        Hover = Color3.fromRGB(40, 35, 50)       -- Element hover
    }
}

local Utility = {}

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, properties, duration)
    local info = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:Window(options)
    local winName = type(options) == "table" and (options.Name or "Phantom UI") or (type(options) == "string" and options or "Phantom UI")
    
    local guiName = HttpService:GenerateGUID(false)
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then pcall(function() ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end) end

    local Window = {
        Panels = {},
        Keybinds = {},
        UpdateFunctions = {},
        Toggled = true,
        Gui = ScreenGui,
        PanelCount = 0
    }
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
            Window.Toggled = not Window.Toggled
            ScreenGui.Enabled = Window.Toggled
        end
        if not processed and Window.Toggled then
            for modName, key in pairs(Window.Keybinds) do
                if input.KeyCode == key and Window.UpdateFunctions[modName .. "_Toggle"] then
                    Window.UpdateFunctions[modName .. "_Toggle"]()
                end
            end
        end
    end)

    function Window:CreateCategory(categoryName)
        local cName = type(categoryName) == "table" and categoryName.Name or categoryName
        Window.PanelCount = Window.PanelCount + 1
        
        -- Layout panels horizontally
        local xOffset = 20 + ((Window.PanelCount - 1) * 190)
        
        local Panel = Utility:Create("Frame", {
            Name = cName .. "_Panel",
            Size = UDim2.new(0, 180, 0, 30), -- Starts collapsed to header, expands later
            Position = UDim2.new(0, xOffset, 0, 20),
            BackgroundColor3 = Library.Theme.Background,
            BackgroundTransparency = 0.2, -- Translucent modern look
            BorderSizePixel = 0,
            Parent = ScreenGui,
            ClipsDescendants = true
        })
        
        local Header = Utility:Create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Library.Theme.Header,
            BorderSizePixel = 0,
            Parent = Panel
        })
        Utility:MakeDraggable(Header, Panel)
        
        local HeaderTitle = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = cName,
            TextColor3 = Library.Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header
        })
        
        local ContentScroll = Utility:Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = Panel
        })
        
        local UIListLayout = Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
            Parent = ContentScroll
        })
        
        local UIPadding = Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            Parent = ContentScroll
        })
        
        local expanded = true
        
        local function UpdateCanvasSize()
            local contentHeight = UIListLayout.AbsoluteContentSize.Y + 10 -- account for padding
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            if expanded then
                local targetHeight = contentHeight + 30
                if targetHeight > 500 then targetHeight = 500 end
                Panel.Size = UDim2.new(0, 180, 0, targetHeight)
            end
        end
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                expanded = not expanded
                if expanded then
                    UpdateCanvasSize()
                else
                    Utility:Tween(Panel, {Size = UDim2.new(0, 180, 0, 30)})
                end
            end
        end)

        local Category = {}
        
        function Category:CreateSection(options)
            local secName = type(options) == "table" and (options.Name or "Section") or (type(options) == "string" and options or "Section")
            
            local SectionContainer = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Parent = ContentScroll
            })
            
            local SectionLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = secName,
                TextColor3 = Library.Theme.Accent,
                Font = Enum.Font.GothamSemibold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = SectionContainer
            })
            
            local Section = {}
            
            function Section:CreateToggle(opts)
                local tName = opts.Name or opts[1] or "Toggle"
                local flag = opts.Flag or tName
                local default = opts.Default or false
                local callback = opts.Callback or function() end
                
                Library.Flags[flag] = default
                
                local ToggleFrame = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ContentScroll
                })
                
                local Title = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -5, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tName,
                    TextColor3 = default and Library.Theme.Accent or Library.Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local function SetState(state)
                    Library.Flags[flag] = state
                    Utility:Tween(Title, {TextColor3 = state and Library.Theme.Accent or Library.Theme.TextDim}, 0.15)
                    pcall(callback, state)
                end
                
                ToggleFrame.MouseButton1Click:Connect(function()
                    SetState(not Library.Flags[flag])
                end)
                ToggleFrame.MouseEnter:Connect(function() Utility:Tween(ToggleFrame, {BackgroundColor3 = Library.Theme.Hover, BackgroundTransparency = 0.5}, 0.1) end)
                ToggleFrame.MouseLeave:Connect(function() Utility:Tween(ToggleFrame, {BackgroundTransparency = 1}, 0.1) end)
                
                Window.UpdateFunctions[flag .. "_Toggle"] = function()
                    SetState(not Library.Flags[flag])
                end
                
                SetState(default)
                return { Set = SetState }
            end

            function Section:CreateSlider(opts)
                local sName = opts.Name or opts[1] or "Slider"
                local flag = opts.Flag or sName
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = opts.Default or min
                local callback = opts.Callback or function() end
                
                Library.Flags[flag] = default
                
                local SliderFrame = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = ContentScroll
                })
                
                local Title = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 15),
                    Position = UDim2.new(0, 5, 0, 2),
                    BackgroundTransparency = 1,
                    Text = sName,
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 15),
                    Position = UDim2.new(0, 5, 0, 2),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = Library.Theme.Accent,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local BarBG = Utility:Create("TextButton", {
                    Size = UDim2.new(1, -10, 0, 4),
                    Position = UDim2.new(0, 5, 0, 20),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = SliderFrame
                })
                
                local BarFill = Utility:Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = BarBG
                })
                
                local function SetValue(val)
                    val = math.clamp(math.round(val * 10) / 10, min, max)
                    Library.Flags[flag] = val
                    ValueLabel.Text = tostring(val)
                    Utility:Tween(BarFill, {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}, 0.1)
                    pcall(callback, val)
                end
                
                local dragging = false
                BarBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local pct = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                        SetValue(min + (max - min) * pct)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pct = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                        SetValue(min + (max - min) * pct)
                    end
                end)
                
                SetValue(default)
                return { Set = SetValue }
            end
            
            function Section:CreateColorpicker(opts)
                local cpName = opts.Name or opts[1] or "Colorpicker"
                local flag = opts.Flag or cpName
                local default = opts.Default or Color3.new(1,1,1)
                local callback = opts.Callback or function() end
                
                Library.Flags[flag] = default
                
                local CPFrame = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = ContentScroll
                })
                
                local Title = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = cpName,
                    TextColor3 = Library.Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = CPFrame
                })
                
                local ColorDisplay = Utility:Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -17, 0.5, -6),
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Parent = CPFrame
                })
                
                local function SetCol(col)
                    Library.Flags[flag] = col
                    ColorDisplay.BackgroundColor3 = col
                    pcall(callback, col)
                end
                
                return { Set = SetCol }
            end
            
            function Section:CreateDropdown(opts)
                local tName = opts.Name or opts[1] or "Dropdown"
                local flag = opts.Flag or tName
                local list = opts.List or {}
                local callback = opts.Callback or function() end
                
                Library.Flags[flag] = list[1]
                
                local DDFrame = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentScroll
                })
                
                local Title = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 16),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tName,
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DDFrame
                })
                
                local DisplayBtn = Utility:Create("TextButton", {
                    Size = UDim2.new(1, -10, 0, 16),
                    Position = UDim2.new(0, 5, 0, 16),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0,
                    Text = tostring(list[1] or "None"),
                    TextColor3 = Library.Theme.Accent,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    Parent = DDFrame
                })
                
                DisplayBtn.MouseButton1Click:Connect(function()
                    local currentIdx = table.find(list, Library.Flags[flag]) or 0
                    local nextIdx = currentIdx + 1
                    if nextIdx > #list then nextIdx = 1 end
                    
                    local selected = list[nextIdx]
                    Library.Flags[flag] = selected
                    DisplayBtn.Text = tostring(selected)
                    pcall(callback, selected)
                end)
                
                return {}
            end

            function Section:CreateKeybind(opts)
                local kName = opts.Name or opts[1] or "Keybind"
                local flag = opts.Flag or kName
                local default = opts.Default or Enum.KeyCode.Unknown
                local callback = opts.Callback or function() end
                
                Library.Flags[flag] = default
                Window.Keybinds[kName] = default
                
                local KFrame = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = ContentScroll
                })
                
                local Title = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = kName,
                    TextColor3 = Library.Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KFrame
                })
                
                local BindBtn = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 14),
                    Position = UDim2.new(1, -45, 0.5, -7),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0,
                    Text = (default == Enum.KeyCode.Unknown and "None" or default.Name),
                    TextColor3 = Library.Theme.Accent,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    Parent = KFrame
                })
                
                local binding = false
                BindBtn.MouseButton1Click:Connect(function()
                    binding = true
                    BindBtn.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if key == Enum.KeyCode.Escape then
                            key = Enum.KeyCode.Unknown
                        end
                        Library.Flags[flag] = key
                        Window.Keybinds[kName] = key
                        BindBtn.Text = (key == Enum.KeyCode.Unknown and "None" or key.Name)
                        binding = false
                        pcall(callback, key)
                    end
                end)
                
                return {}
            end
            
            function Section:CreateTextBox(opts)
                local tbName = opts.Name or opts[1] or "TextBox"
                local flag = opts.Flag or tbName
                local default = opts.Default or ""
                local callback = opts.Callback or function() end
                
                Library.Flags[flag] = default
                
                local TBFrame = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentScroll
                })
                
                local Title = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 16),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tbName,
                    TextColor3 = Library.Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TBFrame
                })
                
                local TextBoxBlock = Utility:Create("TextBox", {
                    Size = UDim2.new(1, -10, 0, 16),
                    Position = UDim2.new(0, 5, 0, 16),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0,
                    Text = default,
                    PlaceholderText = "...",
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    Parent = TBFrame
                })
                
                TextBoxBlock.FocusLost:Connect(function()
                    Library.Flags[flag] = TextBoxBlock.Text
                    pcall(callback, TextBoxBlock.Text)
                end)
                
                return {}
            end
            
            function Section:CreateButton(opts)
                local btnName = opts.Name or opts[1] or "Button"
                local callback = opts.Callback or function() end
                
                local Wrapper = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = ContentScroll
                })
                
                local BtnFrame = Utility:Create("TextButton", {
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 5, 0, 2),
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0,
                    Text = btnName,
                    TextColor3 = Library.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    Parent = Wrapper
                })
                
                BtnFrame.MouseButton1Click:Connect(callback)
            end
            
            -- Aliases
            Section.Toggle = Section.CreateToggle
            Section.Slider = Section.CreateSlider
            Section.Colorpicker = Section.CreateColorpicker
            Section.Dropdown = Section.CreateDropdown
            Section.Keybind = Section.CreateKeybind
            Section.TextBox = Section.CreateTextBox
            Section.Button = Section.CreateButton
            
            return Section
        end
        
        -- Aliases
        Category.Section = Category.CreateSection

        return Category
    end
    
    function Window:BuildSettingsTab()
         local settingsCat = Window:CreateCategory("Settings")
         local main = settingsCat:CreateSection("Config")
         local cfgName = "default_config"
         
         main:CreateTextBox({
             Name = "Config Name",
             Flag = "ConfigName",
             Default = "default_config",
             Callback = function(v) cfgName = v end
         })
         
         main:CreateButton({
             Name = "Save Config",
             Callback = function()
                 if not isfolder("PhantomConfigs") then makefolder("PhantomConfigs") end
                 
                 local dataToSave = {}
                 for name, val in pairs(Library.Flags) do
                     dataToSave[name] = val
                 end
                 
                 local encoded = HttpService:JSONEncode(dataToSave)
                 writefile("PhantomConfigs/" .. cfgName .. ".txt", encoded)
             end
         })
         
         main:CreateButton({
             Name = "Load Config",
             Callback = function()
                 if isfile("PhantomConfigs/" .. cfgName .. ".txt") then
                     local decoded = HttpService:JSONDecode(readfile("PhantomConfigs/" .. cfgName .. ".txt"))
                     for name, val in pairs(decoded) do
                         if Library.Flags[name] ~= nil then
                             Library.Flags[name] = val
                             if Window.UpdateFunctions[name .. "_Toggle"] then
                                 Window.UpdateFunctions[name .. "_Toggle"]()
                             end
                         end
                     end
                 end
             end
         })
    end
    
    function Window:Watermark(text) return { SetText = function() end } end
    function Window:KeybindList() return { SetVisibility = function() end, ClearAllItems = function() end, Add = function() end } end
    function Window:ArmorViewer() return { SetVisibility = function() end, ClearAllItems = function() end, SetTitle = function() end, Add = function() end } end

    -- Aliases
    Window.Category = Window.CreateCategory
    Window.Page = Window.CreateCategory

    return Window
end

Library.CreateWindow = Library.Window
function Library:CreateSettingsPage() end

return Library
