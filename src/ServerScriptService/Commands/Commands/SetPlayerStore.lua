return {
	Name = "setplayerstore",
	Aliases = {"sps"},
	Description = "Sets the specified store to value",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player to set"
		},
		{
			Type = "string",
			Name = "Store Name",
			Description = "Store to set"
		},
		{
			Type = "number",
			Name = "Value",
			Description = "value to set"
		}
	}
}
