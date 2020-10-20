-- Combines a binder with a dictionary of base assets (to add lookup functionality)
-- @classmod AssetBinder
local AssetBinder = {}

function AssetBinder.new(binder, assets)
    local bases = {}
    for _, asset in pairs(assets) do
        bases[asset.Name] = binder:Bind(asset)
    end

    function binder:LookupBase(asset)
        if typeof(asset) == "string" then
            return bases[asset]
        elseif typeof(asset) == "table" then
            return bases[asset:GetInstance().Name]
        end
    end

    function binder:CloneFrom(asset)
        assert(typeof(asset) == "table", "Invalid asset!")
        return self:Bind(asset:GetInstance():Clone())
    end

    function binder:GetAllBase()
        return bases
    end

    return binder
end

return AssetBinder
