local char = game.Players.LocalPlayer.Character

local PointLight = Instance.new("PointLight")
PointLight.Parent = char.PrimaryPart
PointLight.Color = Color3.fromRGB(255, 170, 0)
PointLight.Brightness = 2
PointLight.Range = 20
