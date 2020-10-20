return {
	Name = "give-backpack",
	Aliases = {"gb"},
	Description = "Gives a backpack",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player to give to"
		},
		{
			Type = "backpack",
			Name = "Backpack",
			Description = "backpack to add"
		}
	}
}
