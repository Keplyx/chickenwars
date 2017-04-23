
#define IDLE "#idle"
#define PANIC "#panic"

#define USP "weapon_hkp2000"
#define SSG "weapon_ssg08"
#define SMOKE "weapon_smokegrenade"
#define DECOY "weapon_decoy"
#define TACTIC "weapon_tagrenade"

int uspPrice = 2500;
int ssgPrice = 5000;
int smokePrice = 1000;
int decoyPrice = 1500;
int tacticPrice = 3000;

char chickenIdleSounds[][] =  { "ambient/creatures/chicken_idle_01.wav", "ambient/creatures/chicken_idle_02.wav", "ambient/creatures/chicken_idle_03.wav" }
char chickenPanicSounds[][] =  { "ambient/creatures/chicken_panic_01.wav", "ambient/creatures/chicken_panic_02.wav", "ambient/creatures/chicken_panic_03.wav", "ambient/creatures/chicken_panic_04.wav" }

bool canBuy = true;

Menu playerMenus[MAXPLAYERS];

public void Menu_Taunt(int client_index, int args)
{
	Menu menu = new Menu(MenuHandler_Taunt);
	menu.SetTitle("Taunt Menu");
	menu.AddItem(IDLE, "Idle sound");
	menu.AddItem(PANIC, "Panic sound");
	menu.ExitButton = true;
	menu.Display(client_index, MENU_TIME_FOREVER);
}

public void Menu_Buy(int client_index, int args)
{
	playerMenus[client_index] = new Menu(MenuHandler_Buy);
	playerMenus[client_index].SetTitle("Chicken Wars | Buy Menu");
	
	playerMenus[client_index].AddItem(USP, "usp-s");
	playerMenus[client_index].AddItem(SSG, "ssg08");
	playerMenus[client_index].AddItem(SMOKE, "Chicken Spawner");		//Smoke
	playerMenus[client_index].AddItem(DECOY, "Bait");					//Decoy
	playerMenus[client_index].AddItem(TACTIC, "Detector");				//Tactical grenade
	playerMenus[client_index].ExitButton = true;
	playerMenus[client_index].Display(client_index, MENU_TIME_FOREVER);
}

public void CloseBuyMenus()
{
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if(IsClientInGame(i) && IsValidEntity(i))
			delete playerMenus[i];
	}
}

public int MenuHandler_Taunt(Menu menu, MenuAction action, int param1, int params)
{
	if (action == MenuAction_Select)
	{
		char buffer[64];
		menu.GetItem(params, buffer, sizeof(buffer));
		if (StrEqual(buffer, IDLE))
			PlayRandomIdleSound(param1);
		else if (StrEqual(buffer, PANIC))
			PlayRandomPanicSound(param1);
	}
	else if (action == MenuAction_End)
	{
			delete menu;
	}
		
}

public int MenuHandler_Buy(Menu menu, MenuAction action, int param1, int params)
{
	if (action == MenuAction_Select)
	{
		char buffer[64];
		menu.GetItem(params, buffer, sizeof(buffer));
		BuyWeapon(param1, buffer);
	}
	else if (action == MenuAction_End)
		delete menu;
}

void BuyWeapon(int client_index, char[] weapon_classname) //Buy weapon if not already owned and have enough money
{
	int money = GetEntProp(client_index, Prop_Send, "m_iAccount");
	if (!CheckWeapon(client_index, weapon_classname))
	{
		if (StrEqual(weapon_classname, USP) && money >= uspPrice)
		{
			DropWeapon(client_index, 1);
			SetEntProp(client_index, Prop_Send, "m_iAccount", money - uspPrice);
			GivePlayerItem(client_index, weapon_classname);
		}
		else if (StrEqual(weapon_classname, SSG) && money >= ssgPrice)
		{
			DropWeapon(client_index, 0);
			SetEntProp(client_index, Prop_Send, "m_iAccount", money - ssgPrice);
			GivePlayerItem(client_index, weapon_classname);
		}
		else if (StrEqual(weapon_classname, SMOKE) && money >= smokePrice)
		{
			SetEntProp(client_index, Prop_Send, "m_iAccount", money - smokePrice);
			GivePlayerItem(client_index, weapon_classname);
		}
		else if (StrEqual(weapon_classname, DECOY) && money >= decoyPrice)
		{
			SetEntProp(client_index, Prop_Send, "m_iAccount", money - decoyPrice);
			GivePlayerItem(client_index, weapon_classname);
		}
		else if (StrEqual(weapon_classname, TACTIC) && money >= tacticPrice)
		{
			SetEntProp(client_index, Prop_Send, "m_iAccount", money - tacticPrice);
			GivePlayerItem(client_index, weapon_classname);
		}
		else
		{
			PrintHintText(client_index, "<font color='#ff0000' size='30'>Not enough money</font>");
		}
	}
	else
	{
		PrintHintText(client_index, "<font color='#ff0000' size='30'>Gun already owned</font>");
	}
}

void DropWeapon(int client_index, int slot)
{
	int weapon_index = GetPlayerWeaponSlot(client_index, slot);
	if (weapon_index != -1)
	{
		CS_DropWeapon(client_index, weapon_index, false, false);
	}
}

bool CheckWeapon(int client_index, char[] weapon_classname) //Cycles through player's weapons and check if already have selected
{
	for (int i = 0; i <= 10; i++)
	{
		int weapon_index = GetPlayerWeaponSlot(client_index, i);
		if (weapon_index != -1)
		{
			char buffer[64];
			GetEntityClassname(weapon_index, buffer, sizeof(buffer));
			if (StrEqual(buffer, weapon_classname))
			{
				return true;// If 2 grenades owned, the second is ignored
			}
		}
	}
	return false;
}


void PlayRandomPanicSound(int client_index)
{
	int rdmSound = GetRandomInt(0, sizeof(chickenPanicSounds) - 1);
	EmitSoundToAll(chickenPanicSounds[rdmSound], client_index);
	PrintToConsole(client_index, "Playing panic sound");
}

void PlayRandomIdleSound(int client_index)
{
	int rdmSound = GetRandomInt(0, sizeof(chickenIdleSounds) - 1);
	EmitSoundToAll(chickenIdleSounds[rdmSound], client_index);
	PrintToConsole(client_index, "Playing idle sound");
}