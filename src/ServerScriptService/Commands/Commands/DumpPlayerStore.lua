return {
	Name = "dumpplayerstore",
	Aliases = {"dps"},
	Description = "Dumps store to output",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player"
		},
		{
			Type = "string",
			Name = "Store Name",
			Description = "Store to dump"
		}
	}
}
