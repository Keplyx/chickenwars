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

char zombieModel[] = "models/chicken/chicken_zombie.mdl";

public void ChickenDecoy(int client_index, float pos[3], int currentWeapon) //Change grenade into an armed chicken!!!!!!!
{
	int entity = CreateEntityByName("chicken");
	if (IsValidEntity(entity))
	{
		SetChickenStyle(entity); //Hats!
		//Random orientation
		float rot[3];
		rot[1] = GetRandomFloat(0.0, 360.0);
		TeleportEntity(entity, pos, rot, NULL_VECTOR);
		DispatchSpawn(entity);
		ActivateEntity(entity);
		
		int weapon = CreateEntityByName("prop_dynamic_override");
		if (IsValidEntity(weapon) && currentWeapon > MAXPLAYERS)
		{
			//Get the player's current gun
			char m_ModelName[PLATFORM_MAX_PATH];
			GetEntPropString(currentWeapon, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
			SetEntityModel(weapon, m_ModelName);
			
			SetVariantString("!activator");
			AcceptEntityInput(weapon, "SetParent", entity, weapon, 0);
			//Put the gun at the chicken's side
			float gunPos[] =  { -17.0, -2.0, 15.0 };
			float gunRot[3];
			TeleportEntity(weapon, gunPos, gunRot, NULL_VECTOR);
			//Make sure the gun is not solid
			DispatchKeyValue(weapon, "solid", "0");
			//Spawn it!
			DispatchSpawn(weapon);
			ActivateEntity(weapon);
		}
	}
}

public void ChickenSmoke(float pos[3]) //Change grenade into a lot of chickens!!!!!!!
{
	//Approximate chicken hull size
	float boxMin[3] =  { -16.0, -16.0, -16.0 };
	float boxMax[3] =  { 16.0, 16.0, 16.0 };
	//Try to spawn 20 chickens
	for (int i = 0; i < 20; i++)
	{
		int entity = CreateEntityByName("chicken");
		if (IsValidEntity(entity))
		{
			SetChickenStyle(entity); //Hats!
			//Random pos around the smoke
			float newPos[3];
			newPos[0] = pos[0] + GetRandomFloat(-100.0, 100.0);
			newPos[1] = pos[1] + GetRandomFloat(-100.0, 100.0);
			newPos[2] = pos[2] + 20.0;
			//newPos[2] = pos[2] + GetRandomFloat(20.0, 100.0); //Can get stuck in other while falling
			//Random orientation
			float rot[3];
			rot[1] = GetRandomFloat(0.0, 360.0);
			TeleportEntity(entity, newPos, rot, NULL_VECTOR);
			//Spawn it!
			DispatchSpawn(entity);
			ActivateEntity(entity);
			//If chicken stuck, remove it
			TR_TraceHullFilter(newPos, newPos, boxMin, boxMax, MASK_SOLID, TRDontHitSelf, entity);
			if (TR_DidHit())
				RemoveEdict(entity);
		}
	}
}

public void ZombieInc(float pos[3]) // Turns nearby non-player chickens into zombies
{
	//Area effect size
	float area[3] =  { 120.0, 120.0, 50.0 };
	for (int i = MAXPLAYERS; i <= GetMaxEntities(); i++)
	{
		if (IsValidEntity(i))
		{
			char buffer[128];
			GetEntityClassname(i, buffer, sizeof(buffer))
			//PrintToChatAll("%s", buffer);
			if (StrEqual(buffer, "chicken", false))
			{
				float fOrigin[3];
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", fOrigin);
				// If chicken is outside of the area, do nothing
				bool inside = false;
				for (int j = 0; j < sizeof(area); j++)
				{
					inside = fOrigin[j] < pos[j] + area[j] && fOrigin[j] > pos[j] - area[j];
					if (!inside)
						break;
				}
				if (inside)
					SetEntityModel(i, zombieModel);
			}
		}
	}
}
public void ExplosiveChicken(float pos[3], int client_index) //Creates a chicken wich will explode when an enemy goes near it
{
	int entity = CreateEntityByName("chicken");
	if (IsValidEntity(entity))
	{
		SetChickenStyle(entity); //Hats!
		//Random orientation
		float rot[3];
		rot[1] = GetRandomFloat(0.0, 360.0);
		TeleportEntity(entity, pos, rot, NULL_VECTOR);
		DispatchSpawn(entity);
		ActivateEntity(entity);
		//SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client_index);
		SDKHook(entity, SDKHook_ThinkPost, Hook_OnChickenThinkPost);
	}
}
