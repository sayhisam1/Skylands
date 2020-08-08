return {
	Name = "givepet";
	Aliases = {"gt"};
	Description = "Gives a pet";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "player to give to"
		},
		{
			Type = "pet",
			Name = "Pet",
			Description = "pet to add"
		}
	};
}