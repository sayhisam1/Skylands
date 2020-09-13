return {
	Name = "setleaderboardenabled",
	Aliases = {"slb"},
	Description = "Enables/disables leaderboard stats for the player",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player to set"
		},
		{
			Type = "boolean",
			Name = "Value",
			Description = "value to set"
		}
	}
}
