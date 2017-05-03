/*
*   This file is part of Chicken Strike.
*   Copyright (C) 2017  Keplyx
*
*   This program is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*   
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*   
*   You should have received a copy of the GNU General Public License
*   along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#define IDLE "#idle"
#define PANIC "#panic"

char itemNames[][] = {"weapon_hkp2000", "weapon_ssg08", "weapon_smokegrenade", "weapon_decoy", "weapon_tagrenade", "weapon_molotov", "weapon_hegrenade", "weapon_healthshot"};
char displayNames[][] = {"usp-s", "ssg08", "Chicken Spawner", "Bait", "Detector", "Zombie Egg", "Kamikaze","Health Buff"};
int itemPrices[sizeof(itemNames)]; 
int itemsBrought[MAXPLAYERS + 1][sizeof(itemNames)];

char chickenIdleSounds[][] =  { "ambient/creatures/chicken_idle_01.wav", "ambient/creatures/chicken_idle_02.wav", "ambient/creatures/chicken_idle_03.wav" }
char chickenPanicSounds[][] =  { "ambient/creatures/chicken_panic_01.wav", "ambient/creatures/chicken_panic_02.wav", "ambient/creatures/chicken_panic_03.wav", "ambient/creatures/chicken_panic_04.wav" }

bool canBuyAll = false;
bool canBuy[MAXPLAYERS + 1];

Menu playerMenus[MAXPLAYERS];

public void UpdatePrices(Handle[] prices, bool isFFA)
{
	for (int i = 0; i < sizeof(itemNames); i++)
	{
		if (!isFFA)
			itemPrices[i] = GetConVarInt(prices[i]);
		else
			itemPrices[i] = 0;
	}	
}

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
	
	char buffer[64];
	
	for (int i = 0; i < sizeof(itemNames); i++)
	{
		Format(buffer, sizeof(buffer), "%s | %i $",displayNames[i] ,itemPrices[i]);
		playerMenus[client_index].AddItem(itemNames[i], buffer);
	}
	
	playerMenus[client_index].ExitButton = true;
	playerMenus[client_index].Display(client_index, MENU_TIME_FOREVER);
}

public void CloseBuyMenus()
{
	canBuyAll = false;
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		ClosePlayerBuyMenu(i);
	}
}

public void ClosePlayerBuyMenu(int client_index)
{
	if(IsValidClient(client_index) && playerMenus[client_index] != INVALID_HANDLE){
		canBuy[client_index] = false;
		delete playerMenus[client_index];
	}
}

public void ResetAllItems()
{
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		ResetClientItems(i);
	}
}

public void ResetClientItems(int client_index)
{
	for (int i = 0; i < sizeof(itemNames); i++)
	{
		itemsBrought[client_index][i] = 0;
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

void BuyWeapon(int client_index, char[] weapon_classname) //Buy weapon if not already bought and have enough money
{
	int money = GetEntProp(client_index, Prop_Send, "m_iAccount");
	
	for (int i = 0; i < sizeof(itemNames); i++)
	{
		if (StrEqual(weapon_classname, itemNames[i]) && money >= itemPrices[i] && itemsBrought[client_index][i] != 1)
		{
			if (StrEqual(weapon_classname, "weapon_hkp2000"))
				DropWeapon(client_index, 1);
			if (StrEqual(weapon_classname, "weapon_ssg08"))
				DropWeapon(client_index, 0);
			SetEntProp(client_index, Prop_Send, "m_iAccount", money - itemPrices[i]);
			GivePlayerItem(client_index, weapon_classname);
			itemsBrought[client_index][i] = 1;
		}
		else if (StrEqual(weapon_classname, itemNames[i]) && money < itemPrices[i])
		{
			PrintHintText(client_index, "<font color='#ff0000' size='30'>Not enough money</font>");
		}
		else if (StrEqual(weapon_classname, itemNames[i]) && itemsBrought[client_index][i] == 1)
		{
			PrintHintText(client_index, "<font color='#ff0000' size='30'>Item already bought</font>");
		}
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
