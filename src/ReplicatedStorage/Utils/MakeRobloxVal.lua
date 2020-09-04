return function (attribute_name, value)
    local attribute
    if typeof(value) == "number" then
        attribute = Instance.new("NumberValue")
    elseif typeof(value) == "string" then
        attribute = Instance.new("StringValue")
    elseif typeof(value) == "Vector3" then
        attribute = Instance.new("Vector3Value")
    elseif typeof(value) == "boolean" then
        attribute = Instance.new("BoolValue")
    elseif value:IsA("Instance") then
        attribute = Instance.new("ObjectValue")
    end
    attribute.Name = attribute_name
    attribute.Value = value
    return attribute
end