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

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <csgocolors>
#include <menus>

#pragma newdecls required;

#include "chickenwars/chickenplayer.sp"
#include "chickenwars/chickenmanager.sp"
#include "chickenwars/customweapons.sp"
#include "chickenwars/weapons.sp"
#include "chickenwars/menus.sp"

/*  BUGS
*
*   Reload while ammo full //Y U DO DIS
*   Foot shadow under chicken (client side thirdperson only) // Does it really need a fix?
*	Incendiary grenade not calling custom function
*/


/*  New in this version
*
*	Changed cvar prefix from cs_ to cw_
*	New custom buy menu
*	Tactical grenades and health shots now available
*	Change grenades model to eggs
*	Slow player falling speed by pressing [SPACE]
*
*/

//Gamemode: Everyone is a chicken (weapons show, exept the knife), in a map full of chickens. Must kill the enemy team

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#define LoopIngameClients(%1) for(int %1 = 1; %1 <= MaxClients; ++%1)\
if (IsClientInGame( % 1))

#define LoopIngamePlayers(%1) for(int %1 = 1; %1 <= MaxClients; ++%1)\
if (IsClientInGame( % 1) && !IsFakeClient( % 1))

#define LoopAlivePlayers(%1) for(int %1 = 1;%1 <= MaxClients; ++%1)\
if (IsClientInGame( % 1) && IsPlayerAlive( % 1))

#define VERSION "1.0.4"
#define PLUGIN_NAME "Chicken Wars",

#define ENT_RADAR 1 << 12

int collisionOffsets;

ConVar cvar_viewModel = null;
ConVar cvar_chicken_kill_limit = null;
ConVar cvar_health = null;
ConVar cvar_welcome_message = null;
ConVar cvar_hideradar = null;
ConVar cvar_chicken_number = null;
ConVar cvar_spawnorigin = null;

ConVar cvar_hats[6];

ConVar cvar_skin = null;
ConVar cvar_player_styles = null;

ConVar cvar_customsmoke = null;
ConVar cvar_customdecoy = null;
ConVar cvar_custominc = null;
ConVar cvar_custombuymenu = null;


int chickenKilledCounter[MAXPLAYERS + 1];

bool lateload;

public Plugin myinfo =
{
	name = PLUGIN_NAME
	author = "Keplyx",
	description = "Counter Strike, but chickens only.",
	version = VERSION,
	url = "https://github.com/Keplyx/chickenwars"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	lateload = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	PrecacheModel(eggModel, true); //Make sure the model is precached to prevent crash
	PrecacheModel(chickenModel, true);
	
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("round_start", Event_RoundStart);
	AddNormalSoundHook(NormalSHook);
	
	CreateConVars();
	RegisterCommands();
	
	UpdateChickenCvars(cvar_hats, cvar_skin, cvar_chicken_number, cvar_spawnorigin);
	
	collisionOffsets = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	InitPlayersStyles();
	
	//Throws Error
	//	LoopIngameClients(i)
	//		OnClientPostAdminCheck(i);
	
	
	if (lateload)
	ServerCommand("mp_restartgame 1");
	
	PrintToServer("***********************************");
	PrintToServer("* Chicken Wars successfuly loaded *");
	PrintToServer("***********************************");
}

public void CreateConVars()
{
	CreateConVar("chickenwars_version", VERSION, "Chicken Strike", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	cvar_viewModel = CreateConVar("cw_viewmodel", "0", "Show view model? 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_chicken_kill_limit = CreateConVar("cw_chickenkill_limit", "1", "How many chickens (npc) the player can kill before being auto killed? 0 = no limit, x = can only kill x before dying", FCVAR_NOTIFY, true, 0.0);
	cvar_health = CreateConVar("cw_health", "15", "Set player's health. min = 1, max = 30000", FCVAR_NOTIFY, true, 1.0, true, 3000.0);
	cvar_welcome_message = CreateConVar("cw_welcomemessage", "1", "Displays a welcome message to new players. 0 = no message, 1 = display message", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_hideradar = CreateConVar("cw_hideradar", "1", "Set whether to hide radar from players. 0 = show, 1 = hide", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_chicken_number = CreateConVar("cw_chicken_number", "100", "MIGHT CRASH SERVER IF TOO HIGH | Number of chickens to create on round start. min = 0, max = 1000", FCVAR_NOTIFY, true, 0.0, true, 1000.0);
	cvar_spawnorigin = CreateConVar("cw_spawnorigin", "1", "Set whether to spawn chickens around the world origin. Set this to 0 only if the map is not built around the world origin. 0 = around pos(0,0,0), 1 = around spawns", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	cvar_hats[0] = CreateConVar("cw_no_hat", "1", "Set if chickens cannot have hats. If this is set to 0 and no hats are enabled, this will be ignored. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_hats[1] = CreateConVar("cw_bday_hat", "0", "Set if chickens can wear a Bday hat. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_hats[2] = CreateConVar("cw_ghost_hat", "0", "Set if chickens can wear a ghost cap. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_hats[3] = CreateConVar("cw_xmas_hat", "", "Set if chickens can wear a Xmas sweater. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_hats[4] = CreateConVar("cw_bunny_hat", "0", "Set if chickens can wear bunny ears. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_hats[5] = CreateConVar("cw_pumpkin_hat", "0", "Set if chickens can wear a pumpkin head. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_skin = CreateConVar("cw_skin", "0", "Set the chicken's skin. 0 = white, 1 = brown, 2 = both", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	cvar_player_styles = CreateConVar("cw_playerstyles", "0", "Set whether players can choose hats and skins. 0 = no, 1 = yes", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	cvar_customsmoke = CreateConVar("cw_customsmoke", "1", "Set whether to enable custom smokes. 0 = disabled, 1 = enabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_customdecoy = CreateConVar("cw_customdecoy", "1", "Set whether to enable custom decoys. 0 = disabled, 1 = enabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_custominc = CreateConVar("cw_custominc", "1", "Set whether to enable custom incendiary grenades. 0 = disabled, 1 = enabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_custombuymenu = CreateConVar("cw_custombuymenu", "20", "Set how much time the custom buy menu should be displayed after player spawn. 0 = disabled, x = x seconds", FCVAR_NOTIFY, true, 0.0, true, 3600.0);
	
	AutoExecConfig(true, "chickenwars");
}

public void OnConfigsExecuted()
{
	//Set team names
	SetConVarString(FindConVar("mp_teamname_1"), "Guardian Chickens");
	SetConVarString(FindConVar("mp_teamname_2"), "Rebel Chickens");
	
	//Enable hiding of players
	SetConVarBool(FindConVar("sv_disable_immunity_alpha"), true);
	
	//Disable footsteps
	SetConVarFloat(FindConVar("sv_footstep_sound_frequency"), 500.0);
	
	//Disable the event if any (easter, halloween, xmas...)
	SetConVarBool(FindConVar("sv_holiday_mode"), false);
	//Set player weapon
	SetConVarString(FindConVar("mp_t_default_secondary"), "weapon_p250");
	SetConVarString(FindConVar("mp_ct_default_secondary"), "weapon_p250");
	
	//Set healthshot paramaters
	SetConVarInt(FindConVar("healthshot_health"), 15);
	SetConVarInt(FindConVar("ammo_item_limit_healthshot"), 1);
}

static void RegisterCommands()
{
	RegConsoleCmd("cw_set_skin", SetChickenSkin);
	RegConsoleCmd("cw_set_hat", SetChickenHat);
	RegAdminCmd("cw_strip_weapons", StripWeapons, ADMFLAG_GENERIC);
}

public Action NormalSHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (IsValidEntity(entity))
	{
		char sClassname[64];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (StrContains(sClassname, "_projectile") != -1)
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	DisableChicken(victim);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client_index = GetClientOfUserId(GetEventInt(event, "userid"));
	//Get player's viewmodel for future hiding
	clientsViewmodels[client_index] = GetViewModelIndex(client_index);
	//Set player server sided skins
	serverSkin[client_index] = GetChickenSkin();
	serverHat[client_index] = GetChickenHat();
	//Transformation!!
	SetChicken(client_index);
	//Remove player collisions
	SetEntData(client_index, collisionOffsets, 2, 1, true);
	//Reset the chicken killed count
	chickenKilledCounter[client_index] = 0;
	
	CreateTimer(0.0, Timer_RemoveRadar, GetClientUserId(client_index));
}

public void Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client_index = GetClientOfUserId(GetEventInt(event, "userid"));
	DisableChicken(client_index);
}

public void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	SpawnChickens();
	ResetAllItems();
	CPrintToChatAll("{yellow}Open the buy menu bu pressing {white}[S]");
	//Setup buy menu
	canBuy = true;
	CreateTimer(GetConVarFloat(cvar_custombuymenu), Timer_BuyMenu);
}

public void OnClientPostAdminCheck(int client_index)
{
	SDKHook(client_index, SDKHook_PostThinkPost, Hook_OnPostThinkPost);
	SDKHookEx(client_index, SDKHook_WeaponSwitchPost, Hook_WeaponSwitchPost);
	//Displays the welcome message 3 sec after player's connection so he can see it
	CreateTimer(3.0, Timer_WelcomeMessage, client_index);
}

public void OnClientDisconnect(int client_index)
{
	DisableChicken(client_index);
	ResetPlayerStyle(client_index);
	ResetClientItems(client_index);
}

public void OnEntityCreated(int entity_index, const char[] classname)
{
	if (StrEqual(classname, "chicken", false))
	{
		SDKHook(entity_index, SDKHook_OnTakeDamage, Hook_ChickenTakeDamage);
	}
	if (StrEqual(classname, "smokegrenade_projectile", false) && GetConVarBool(cvar_customsmoke))
	{
		SDKHook(entity_index, SDKHook_ThinkPost, Hook_OnGrenadeThinkPost);
	}
	if (StrEqual(classname, "decoy_projectile", false) && GetConVarBool(cvar_customdecoy))
	{
		SDKHook(entity_index, SDKHook_ThinkPost, Hook_OnGrenadeThinkPost);
	}
	if (StrEqual(classname, "incgrenade_projectile", false) && GetConVarBool(cvar_custominc))
	{
		SDKHook(entity_index, SDKHook_ThinkPost, Hook_OnGrenadeThinkPost);
	}
}


public Action Timer_WelcomeMessage(Handle timer, int client_index)
{
	if (cvar_welcome_message.BoolValue && IsClientConnected(client_index) && IsClientInGame(client_index))
	{
		//Welcome message (white text in red box)
		CPrintToChat(client_index, "{darkred}********************************");
		CPrintToChat(client_index, "{darkred}* {default}Welcome to Chicken Wars");
		CPrintToChat(client_index, "{darkred}*            {default}Made by Keplyx");
		CPrintToChat(client_index, "{darkred}********************************");
	}
}

public Action Timer_RemoveRadar(Handle timer, any userid) {
	int client_index = GetClientOfUserId(userid);
	if (GetConVarBool(cvar_hideradar) && client_index && IsClientInGame(client_index) && IsPlayerAlive(client_index))
	SetEntProp(client_index, Prop_Send, "m_iHideHUD", ENT_RADAR);
}

public Action Timer_BuyMenu(Handle timer, any userid) {
	canBuy = false;
	CloseBuyMenus();
}

public Action StripWeapons(int client_index, int args) //Set a player defense less
{
	if (args < 1)
	{
		PrintToConsole(client_index, "Usage: cw_strip_weapons <name>");
		return Plugin_Handled;
	}
	
	char name[32];
	int target = -1;
	GetCmdArg(1, name, sizeof(name));
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i))
		{
			continue;
		}
		char other[32];
		GetClientName(i, other, sizeof(other));
		if (StrEqual(name, other))
		{
			target = i;
		}
	}
	
	if (target == -1)
	{
		PrintToConsole(client_index, "Could not find any player with the name: \"%s\"", name);
		return Plugin_Handled;
	}
	
	RemovePlayerWeapons(target);
	PrintToConsole(client_index, "%s no longer has weapons", name);
	
	return Plugin_Handled;
}

public Action SetChickenSkin(int client_index, int args) //Set player skin if authorized
{
	if (args < 1)
	{
		PrintToConsole(client_index, "Usage: cw_set_skin <skin_number> | Values: -1 = server selected, 0 = white, 1 = brown");
		return Plugin_Handled;
	}
	
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	
	int skin = StringToInt(arg);
	
	if (skin == 0 || skin == -1 || skin == 1)
	{
		playerSkin[client_index] = skin;
		PrintToConsole(client_index, "Skin will be changed on next spawn");
		return Plugin_Handled;
	}
	else
	return Plugin_Handled;
}

public Action SetChickenHat(int client_index, int args) //Set player hat if authorized
{
	if (args < 1)
	{
		PrintToConsole(client_index, "Usage: cw_set_hat <hat_number> | Values: -1 = server selected, 0 = no hat, 1 = Bday hat, 2 = ghost hat, 3 = Xmas sweater, 4 = bunny ears, 5 = pumpkin head");
		return Plugin_Handled;
	}
	
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	
	int hat = StringToInt(arg);
	
	if (hat == 0 || hat == -1 || hat == 1 || hat == 2 || hat == 3 || hat == 4 || hat == 5)
	{
		playerHat[client_index] = hat;
		PrintToConsole(client_index, "Hat will be changed on next spawn");
		return Plugin_Handled;
	}
	else
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client_index, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsPlayerAlive(client_index))
	return Plugin_Continue;
	
	// Disable non-forward movement :3
	if (vel[1] != 0)
	vel[1] = 0.0;
	if (vel[0] < 0)
	vel[0] = 0.0;
	
	//Change player's animations based on key pressed
	isWalking[client_index] = (buttons & IN_SPEED) || (buttons & IN_DUCK);
	isMoving[client_index] = vel[0] > 0.0;
	if (isMoving[client_index] || (buttons & IN_JUMP) || IsValidEntity(weapons[client_index]) || !(GetEntityFlags(client_index) & FL_ONGROUND))
	SetRotationLock(client_index, true);
	else
	SetRotationLock(client_index, false);
	
	if ((buttons & IN_JUMP) && !(GetEntityFlags(client_index) & FL_ONGROUND))
	{
		SlowPlayerFall(client_index);
	}
	
	//Block crouch but not crouch-jump
	if ((buttons & IN_DUCK) && (GetEntityFlags(client_index) & FL_ONGROUND))
	{
		buttons &= ~IN_DUCK;
		return Plugin_Continue;
	}
	
	//Disable knife cuts (client will see impact, but it won't do any damage)
	if (StrEqual(currentWeaponName[client_index], "knife", false))
	{
		float fUnlockTime = GetGameTime() + 1.0;
		
		SetEntPropFloat(client_index, Prop_Send, "m_flNextAttack", fUnlockTime);
		
		int knife = GetPlayerWeaponSlot(client_index, CS_SLOT_KNIFE)
		if (knife > 0)
		SetEntPropFloat(knife, Prop_Send, "m_flNextPrimaryAttack", fUnlockTime);
	}
	
	// Commands
	if ((buttons & IN_BACK) && canBuy)
	{
		Menu_Buy(client_index, 0);
	}
	else if (buttons & IN_MOVELEFT)
	{
		//TODO ??? free ???, cooldown
	}
	else if (buttons & IN_MOVERIGHT)
	{
		Menu_Taunt(client_index, 0);
	}
	
	return Plugin_Changed;
}

public void Hook_WeaponSwitchPost(int client_index, int weapon_index)
{
	if (GetEntityRenderMode(client_index) == RENDER_NONE)
	{
		//Hide the real weapon (which can't be moved because of the bonemerge attribute in the model) and creates a fake one, moved to the chicken's side
		SetWeaponVisibility(client_index, weapon_index, false);
		CreateFakeWeapon(client_index, weapon_index);
	}
	else
	{
		//If player is visible (not a chicken??) make his weapons visible and don't create a fake one
		SetWeaponVisibility(client_index, weapon_index, true);
	}
	GetCurrentWeaponName(client_index, weapon_index);
	DisplaySwitching(client_index); //Displayer weapon switching to warn players
	SDKHook(weapon_index, SDKHook_ReloadPost, Hook_WeaponReloadPost);
}

public void Hook_OnPostThinkPost(int entity_index)
{
	//Replace the grenade's model by eggs (thrown and dropped)
	for (int i = MAXPLAYERS; i <= GetMaxEntities(); i++)
	{
		if (IsValidEntity(i))
		{
			char buffer[128];
			GetEntityClassname(i, buffer, sizeof(buffer))
			if (StrEqual(buffer, "smokegrenade_projectile", false) || StrEqual(buffer, "weapon_smokegrenade", false))
			{
				SetEggGrenade(i, WHITE);
			}
			if (StrEqual(buffer, "decoy_projectile", false) || StrEqual(buffer, "weapon_decoy", false))
			{
				SetEggGrenade(i, YELLOW);
			}
			if (StrEqual(buffer, "tagrenade_projectile", false) || StrEqual(buffer, "weapon_tagrenade", false))
			{
				SetEggGrenade(i, PURPLE);
			}
		}
	}
	
	SetViewModel(entity_index, GetConVarBool(cvar_viewModel)); //Hide viewmodel based on cvar
	//Update convars for other files
	chickenHealth = GetConVarInt(cvar_health);
	canChooseStyle = GetConVarBool(cvar_player_styles);
	UpdateChickenCvars(cvar_hats, cvar_skin, cvar_chicken_number, cvar_spawnorigin);
}

public void Hook_OnGrenadeThinkPost(int entity_index)
{
	//Manage the grenades
	//When it stops moving, kill the entity and replace it by chickens!
	float fVelocity[3];
	GetEntPropVector(entity_index, Prop_Send, "m_vecVelocity", fVelocity);
	if (fVelocity[0] == 0.0 && fVelocity[1] == 0.0 && fVelocity[2] == 0.0)
	{
		int client_index = GetEntPropEnt(entity_index, Prop_Data, "m_hOwnerEntity")
		float fOrigin[3];
		GetEntPropVector(entity_index, Prop_Send, "m_vecOrigin", fOrigin);
		
		char buffer[64];
		GetEntityClassname(entity_index, buffer, sizeof(buffer));
		if (StrEqual(buffer, "smokegrenade_projectile"))
		ChickenSmoke(fOrigin);
		else if (StrEqual(buffer, "decoy_projectile"))
		ChickenDecoy(client_index, fOrigin, weapons[client_index]);
		else if (StrEqual(buffer, "incgrenade_projectile"))
		ZombieInc(fOrigin);
		AcceptEntityInput(entity_index, "Kill");
	}
}

public bool TRDontHitSelf(int entity, int mask, any data) //Trace hull filter
{
	if (entity == data)return false;
	return true;
}


public Action Hook_WeaponReloadPost(int weapon) //Bug: gets called if ammo is full and player pressing reload key
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	//EmitSoundToAll(chickenPanicSounds[0], owner); //Disabled to prevent spam
	PrintHintText(owner, "<font color='#ff0000' size='30'>RELOADING</font>");
}

public Action Hook_ChickenTakeDamage(int entity_index, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	//Detect if player killed a chicken
	//Add a kill to the counter and if reached limit, kill the player (also display in chat)
	if ((entity_index >= 1) && (attacker >= 1) && (attacker <= MaxClients) && (attacker == inflictor))
	{
		if (chickenKilledCounter[attacker] < GetConVarInt(cvar_chicken_kill_limit) && GetConVarInt(cvar_chicken_kill_limit) != 0)
		{
			chickenKilledCounter[attacker]++;
			PrintHintText(attacker, "<font color='#ff0000' size='30'>WARNING</font><br><font color='#ff0000' size='20'>Don't kill chicken civilians</font>");
		}
		
		else if (GetConVarInt(cvar_chicken_kill_limit) != 0)
		{
			chickenKilledCounter[attacker] = 0;
			ForcePlayerSuicide(attacker);
			
			char buffer[128];
			GetClientName(attacker, buffer, sizeof(buffer));
			int rdmChat = GetRandomInt(0, 5);
			
			switch (rdmChat)
			{
				case 0:CPrintToChatAll("{yellow}%s {darkred}gave up on life.", buffer);
				case 1:CPrintToChatAll("{yellow}%s {darkred}couldn't stand the casualties.", buffer);
				case 2:CPrintToChatAll("{yellow}%s {darkred}killed too many civilians.", buffer);
				case 3:CPrintToChatAll("{yellow}%s {darkred}was a monster. Nobody misses him.", buffer);
				case 4:CPrintToChatAll("{yellow}%s {darkred}lost his honour.", buffer);
				case 5:CPrintToChatAll("{yellow}%s {darkred}was kicked by the chicken gods.", buffer);
			}
		}
	}
}

public Action Hook_SetTransmit(int entity, int client)
{
	return Plugin_Handled;
}
