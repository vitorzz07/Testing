local httpService = game:GetService("HttpService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "AppleHubSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        MenuKeybind = "LeftControl"
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library

    -- === Elegante Theme Overrides ===    local darkRed = Color3.fromRGB(180, 0, 0)    -- Tab styling
    self.Library.Styles.TabBackground = Color3.fromRGB(0, 0, 0)
    self.Library.Styles.TabTextColor = Color3.fromRGB(220, 220, 220)    self.Library.Styles.TabTextFont = Enum.Font.GothamBold
    self.Library.Styles.TabCornerRadius = UDim.new(0, 12)
    -- Button styling
    self.Library.Styles.ButtonBackground = Color3.fromRGB(0, 0, 0)
    self.Library.Styles.ButtonTextColor = Color3.fromRGB(220, 220, 220)    self.Library.Styles.ButtonTextFont = Enum.Font.GothamBold
    self.Library.Styles.ButtonCornerRadius = UDim.new(0, 12)    self.Library.Styles.ButtonShadow = {
        Color = Color3.new(0,0,0),
        Transparency = 0.7,
        Offset = Vector2.new(2,2),
        BlurRadius = 10
    }

    -- Global container styling
    self.Library.Styles.ContainerCornerRadius = UDim.new(0, 12)
    self.Library.Styles.ContainerBackground = Color3.fromRGB(0, 0, 0)
    self.Library.Styles.ContainerBorderColor = darkRed
    self.Library.Styles.ContainerBorderSize = 3

    -- Accent highlights
    self.Library.Styles.AccentColor = darkRed

    -- Font defaults
    self.Library.Styles.DefaultFont = Enum.Font.GothamBold

    -- Shadows for containers
    self.Library.Styles.ContainerShadow = {
        Color = Color3.new(0,0,0),
        Transparency = 0.8,
        Offset = Vector2.new(3,3),
        BlurRadius = 12
    }

	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder)
		table.insert(paths, self.Folder .. "/settings")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		local section = tab:AddSection("Interface")

		local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
			Title = "Theme",
			Description = "Changes the interface theme.",
			Values = Library.Themes,
			Default = Settings.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
			end
		})

        InterfaceTheme:SetValue(Settings.Theme)
	
		if Library.UseAcrylic then
			section:AddToggle("AcrylicToggle", {
				Title = "Acrylic",
				Description = "The blurred background requires graphic quality 8+",
				Default = Settings.Acrylic,
				Callback = function(Value)
					Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
				end
			})
		end
	
		section:AddToggle("TransparentToggle", {
			Title = "Transparency",
			Description = "Makes the interface transparent.",
			Default = Settings.Transparency,
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
		})
	
		local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
		MenuKeybind:OnChanged(function()
			Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
		end)
		Library.MinimizeKeybind = MenuKeybind
    end
end

return InterfaceManager