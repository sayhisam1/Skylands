local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FabricLib = require(ReplicatedStorage.Lib.Fabric)
local Fabric = FabricLib.Fabric
local ServerOre = require(script.Parent.ServerOre)
return function()
    local fabric, testComponent, testPart

    beforeEach(
        function()
            fabric = Fabric.new("test")
            FabricLib.useReplication(fabric)
            FabricLib.useTags(fabric)
            testComponent = ServerOre(fabric)
            fabric:registerComponent(testComponent)
            testPart = Instance.new("Part")
            testPart.Anchored = true
            testPart.CanCollide = false
            testPart.Size = Vector3.new(7, 7, 7)
        end
    )

    describe(
        "Ore",
        function()
            it(
                "should attach to tagged",
                function()
                    CollectionService:AddTag(testPart, testComponent.tag)
                    local component = fabric:getComponentByRef("Ore", testPart)
                    expect(component).to.be.ok()
                end
            )
        end
    )

    afterEach(
        function()
            testPart:Destroy()
        end
    )
end
