return {
	Name = "give-pickaxe",
	Aliases = {"gp"},
	Description = "Gives a pickaxe",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player to give to"
		},
		{
			Type = "pickaxe",
			Name = "Pickaxe",
			Description = "pickaxe to add"
		}
	}
}
