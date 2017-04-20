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

int chickenHats[6];
int chickenSkin = 0;
int chickenNumber = 0;
bool spawnOrigin = true;

public void UpdateChickenCvars(Handle hats[6], Handle skins, Handle chickenNum, Handle spawn)
{
	//get cvars from main file
	for (int i = 0; i < sizeof(hats); i++)
	{
		chickenHats[i] = GetConVarInt(hats[i]);
	}
	
	chickenSkin = GetConVarInt(skins);
	chickenNumber = GetConVarInt(chickenNum);
	spawnOrigin = GetConVarBool(spawn);
}


public void SpawnChickens()
{
	//Reset the number of chickens in the map (stop server crash)
	RemoveChickens();
	
	int entitySpawnCounter = 0;
	float worldOrigin[3];
	
	//Creates some chickens around the world origin
	if (spawnOrigin)
	{
		while (entitySpawnCounter < chickenNumber)
		{
			entitySpawnCounter += CreateChickenRandom(worldOrigin); //If entity has been created, add 1 to the chicken counter
		}
	}
	//Creates some chickens both sides around spawn
	else
	{
		float fOrigin[3];
		int spawn = FindEntityByClassname(MAXPLAYERS, "info_player_terrorist");
		GetEntPropVector(spawn, Prop_Send, "m_vecOrigin", fOrigin);
		while (entitySpawnCounter < (chickenNumber / 2))
		{
			entitySpawnCounter += CreateChickenRandom(fOrigin); //If entity has been created, add 1 to the chicken counter
		}
		spawn = FindEntityByClassname(MAXPLAYERS, "info_player_counterterrorist");
		GetEntPropVector(spawn, Prop_Send, "m_vecOrigin", fOrigin);
		while (entitySpawnCounter < chickenNumber)
		{
			entitySpawnCounter += CreateChickenRandom(fOrigin);
		}
	}
	
	
	//PrintToChatAll("chickens : %i", entitySpawnCounter);
}

public int CreateChickenRandom(float origin[3])
{
	//Approximate chicken hull size
	float boxMin[3] =  { -16.0, -16.0, -16.0 };
	float boxMax[3] =  { 16.0, 16.0, 16.0 };
	//PrintToChatAll("Trying to create chicken%i", entitySpawnCounter);
	
	int entity = CreateEntityByName("chicken");
	if (IsValidEntity(entity))
	{
		SetChickenStyle(entity); //Set the hat/skin
		//Random pos around the origin (if too big, can crash)
		float newPos[3];
		newPos[0] = origin[0] + GetRandomFloat(-2500.0, 2500.0);
		newPos[1] = origin[1] + GetRandomFloat(-2500.0, 2500.0);
		newPos[2] = origin[2] + GetRandomFloat(-1000.0, 1000.0);
		
		float rot[3];
		rot[1] = GetRandomFloat(0.0, 360.0);
		
		TeleportEntity(entity, newPos, rot, NULL_VECTOR);
		DispatchSpawn(entity);
		ActivateEntity(entity);
		
		//Check if entity is stuck
		TR_TraceHullFilter(newPos, newPos, boxMin, boxMax, MASK_SOLID, TRDontHitSelf, entity);
		if (TR_DidHit())
		{
			RemoveEdict(entity);
			return 0;
		}
		else
			return 1;
	}
	else
		return 0;
}

public void RemoveChickens()
{
	char className[64];
	for (int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if (IsValidEntity(i) && IsValidEdict(i))
		{
			GetEdictClassname(i, className, sizeof(className));
			if (StrEqual(className, "chicken") && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == -1)
				RemoveEdict(i);
		}
	}
}

public void SetChickenStyle(int chicken)
{
	SetEntProp(chicken, Prop_Send, "m_nSkin", GetChickenSkin()); //0=normal 1=brown chicken
	SetEntProp(chicken, Prop_Send, "m_nBody", GetChickenHat()); //0=normal 1=BdayHat 2=ghost 3=XmasSweater 4=bunnyEars 5=pumpkinHead
}

public int GetChickenSkin()
{
	if (chickenSkin == 2)
	{
		return GetRandomInt(0, 1);
	}
	else
		return chickenSkin;
}

public int GetChickenHat()
{
	int enabled[sizeof(chickenHats)];
	int total = 0;
	for (int i = 0; i < sizeof(chickenHats); i++)
	{
		if (chickenHats[i] == 1)
		{
			enabled[total] = i;
			total++;
		}
	}
	if (total == 0) //Set chicken to no hat if every cvar is at 0
	{
		return 0;
	}
	else //Select a random hat between the enabled ones
	{
		return enabled[GetRandomInt(0, (total - 1))];
	}
} 