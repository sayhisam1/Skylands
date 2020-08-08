return {
	Name = "reset-player-data",
	Aliases = {""},
	Description = "Forces a reset of the given player's data",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player whose data to reset"
		}
	}
}
