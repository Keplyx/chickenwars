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
ConVar cvar_customhe = null;
ConVar cvar_custombuymenu = null;
ConVar cvar_prices[sizeof(itemNames)];
ConVar cvar_ffa = null;

public void CreateConVars(char[] version)
{
	CreateConVar("chickenwars_version", version, "Chicken Strike", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
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
	cvar_customhe = CreateConVar("cw_customhe", "1", "Set whether to enable custom HE grenades. 0 = disabled, 1 = enabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_custombuymenu = CreateConVar("cw_custombuymenu", "20", "Set how much time the custom buy menu should be displayed after player spawn. 0 = disabled, x = x seconds", FCVAR_NOTIFY, true, 0.0, true, 3600.0);
	
	float max_price = 30000.0;
	cvar_prices[0] = CreateConVar("cw_usp_price", "2500", "Set usp-s price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[1] = CreateConVar("cw_ssg_price", "5000", "Set ssg price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[2] = CreateConVar("cw_spawner_price", "500", "Set chicken spawner price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[3] = CreateConVar("cw_bait_price", "1000", "Set bait price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[4] = CreateConVar("cw_detector_price", "3000", "Set detector price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[5] = CreateConVar("cw_zombie_price", "1000", "Set zombie egg price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[6] = CreateConVar("cw_kamikaze_price", "1500", "Set kamikaze chicken price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	cvar_prices[7] = CreateConVar("cw_health_price", "3000", "Set health shot price in custom buy menu.", FCVAR_NOTIFY, true, 0.0, true, max_price);
	
	cvar_ffa = CreateConVar("cw_ffa", "0", "Set whether to enable Free For All mode.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_ffa.AddChangeHook(SetFFA);
	AutoExecConfig(true, "chickenwars");
}

public void IntiCvars()
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
	// Prevents players from being kicked for killing chickens
	SetConVarBool(FindConVar("mp_autokick"), false);
}

public void SetFFA(ConVar convar, char[] oldValue, char[] newValue)
{
	bool isFFA = StringToInt(newValue) == 1;
	if (isFFA)
	{
		SetConVarBool(FindConVar("mp_teammates_are_enemies"), true);
		SetConVarInt(FindConVar("mp_dm_time_between_bonus_max"), 9999); //Stop bonus weapons
		SetConVarInt(FindConVar("mp_dm_time_between_bonus_min"), 9999); //Stop bonus weapons
		SetConVarInt(FindConVar("sv_infinite_ammo"), 0);
	}
	else
	{
		ResetConVar(FindConVar("mp_dm_time_between_bonus_max"));
		ResetConVar(FindConVar("mp_dm_time_between_bonus_min"));
		SetConVarBool(FindConVar("mp_teammates_are_enemies"), false);
	}
	ServerCommand("mp_restartgame 1");
}


public void RegisterCommands()
{
	RegConsoleCmd("cw_set_skin", SetChickenSkin);
	RegConsoleCmd("cw_set_hat", SetChickenHat);
	RegAdminCmd("cw_strip_weapons", StripWeapons, ADMFLAG_GENERIC);
}