return {
	Name = "minedown",
	Aliases = {"md"},
	Description = "Mines down the specified number of blocks",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "number",
			Name = "depth",
			Description = "number of blocks to mine down"
		}
	}
}
