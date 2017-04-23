#define IDLE "#idle"
#define PANIC "#panic"

char chickenIdleSounds[][] =  { "ambient/creatures/chicken_idle_01.wav", "ambient/creatures/chicken_idle_02.wav", "ambient/creatures/chicken_idle_03.wav" }
char chickenPanicSounds[][] =  { "ambient/creatures/chicken_panic_01.wav", "ambient/creatures/chicken_panic_02.wav", "ambient/creatures/chicken_panic_03.wav", "ambient/creatures/chicken_panic_04.wav" }

public void Menu_Taunt(int client_index, int args)
{
	Menu menu = new Menu(MenuHandler_Taunt);
	menu.SetTitle("Taunt Menu");
	menu.AddItem(IDLE, "Idle sound");
	menu.AddItem(PANIC, "Panic sound");
	menu.ExitButton = true;
	menu.Display(client_index, MENU_TIME_FOREVER);
}

public int MenuHandler_Taunt(Menu menu, MenuAction action, int param1, int params)
{
	if (action == MenuAction_Select)
	{
		char buffer[64];
		menu.GetItem(params, buffer, sizeof(buffer));
		if (StrEqual(buffer, IDLE))
		playRandomIdleSound(param1);
		else if (StrEqual(buffer, PANIC))
		playRandomPanicSound(param1);
	}
	else if (action == MenuAction_End)
		delete menu;
}

void playRandomPanicSound(int client_index)
{
	int rdmSound = GetRandomInt(0, sizeof(chickenPanicSounds) - 1);
	EmitSoundToAll(chickenPanicSounds[rdmSound], client_index);
	PrintToConsole(client_index, "Playing panic sound");
}

void playRandomIdleSound(int client_index)
{
	int rdmSound = GetRandomInt(0, sizeof(chickenIdleSounds) - 1);
	EmitSoundToAll(chickenIdleSounds[rdmSound], client_index);
	PrintToConsole(client_index, "Playing idle sound");
}