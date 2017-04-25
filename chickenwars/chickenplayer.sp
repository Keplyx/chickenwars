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

char chickenModel[] = "models/chicken/chicken.mdl";
char chickenDeathSounds[][] =  { "ambient/creatures/chicken_death_01.wav", "ambient/creatures/chicken_death_02.wav", "ambient/creatures/chicken_death_03.wav" }
char chickenSec[][] =  { "ACT_WALK", "ACT_RUN", "ACT_IDLE", "ACT_JUMP", "ACT_GLIDE", "ACT_LAND", "ACT_HOP" }

//new const String:chickenAnim[][] =  { "ref", "walk01", "run01", "run01Flap", "idle01", "peck_idle2", "flap", "flap_falling", "bounce", "bunnyhop" }
//Use sequences (better than animations)

//fake models arrray
int chickens[MAXPLAYERS + 1];

//Timers
Handle animationsTimer[MAXPLAYERS + 1];
Handle feathersTimer[MAXPLAYERS + 1];

int feathersParticles[MAXPLAYERS + 1];
int lastFlags[MAXPLAYERS + 1];

//Animation related variables
bool wasIdle[MAXPLAYERS + 1] = false;
bool wasRunning[MAXPLAYERS + 1] = false;
bool isWalking[MAXPLAYERS + 1] = false;
bool wasWalking[MAXPLAYERS + 1] = false;
bool isMoving[MAXPLAYERS + 1] = false;
int flyCounter[MAXPLAYERS + 1];

//Skin/hat variables
int playerHat[MAXPLAYERS + 1] = -1;
int playerSkin[MAXPLAYERS + 1] = -1;
int serverHat[MAXPLAYERS + 1] = 0;
int serverSkin[MAXPLAYERS + 1] = 0;

//Chicken variables (change with convars)
int chickenHealth = 15;
bool canChooseStyle = true;

//Chicken constants
const float chickenRunSpeed = 0.36; //Match real chicken speed (kind of)  
const float chickenWalkSpeed = 0.12;
const float maxFallSpeed = -100.0;

void InitPlayersStyles() //Set skins/hats to server sided for everyone
{
	for (int i = 0; i <= MAXPLAYERS; i++)
	{
		playerHat[i] = -1;
		playerSkin[i] = -1;
	}
}

void ResetPlayerStyle(int client_index) //Set a player's skin/hat to server sided
{
	playerHat[client_index] = -1;
	playerSkin[client_index] = -1;
}

void SetChicken(int client_index)
{
	//Delete fake model to prevent glitches
	DisableFakeModel(client_index);
	
	//Only for hitbox -> Collision hull still the same
	SetEntityModel(client_index, chickenModel);
	//Little chicken is weak
	SetEntityHealth(client_index, chickenHealth);
	//Little chicken has little legs
	SetClientSpeed(client_index, chickenRunSpeed); //Changed based on animation
	//Hide the real player model (because animations won't play)
	//SDKHook(client_index, SDKHook_SetTransmit, Hook_SetTransmit); //Crash server
	SetEntityRenderMode(client_index, RENDER_NONE); //Make sure immunity alpha is set to 0 or it won't work
	//Create a fake chicken model with animation
	CreateFakeModel(client_index);
}

void CreateFakeModel(int client_index)
{
	chickens[client_index] = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(chickens[client_index])) {
		SetEntityModel(chickens[client_index], chickenModel);
		
		//Set skin/hat
		if (playerSkin[client_index] != -1 && canChooseStyle)
			SetEntProp(chickens[client_index], Prop_Send, "m_nSkin", playerSkin[client_index]); //0=normal 1=brown chicken
		else
			SetEntProp(chickens[client_index], Prop_Send, "m_nSkin", serverSkin[client_index]);
		
		if (playerHat[client_index] != -1 && canChooseStyle)
			SetEntProp(chickens[client_index], Prop_Send, "m_nBody", playerHat[client_index]); //0=normal 1=BdayHat 2=ghost 3=XmasSweater 4=bunnyEars 5=pumpkinHead
		else
			SetEntProp(chickens[client_index], Prop_Send, "m_nBody", serverHat[client_index]);
		//Teleports the chicken at the player's feet
		float pos[3];
		GetClientAbsOrigin(client_index, pos);
		TeleportEntity(chickens[client_index], pos, NULL_VECTOR, NULL_VECTOR);
		//Parents the chicken to the player and attaches it
		SetVariantString("!activator"); AcceptEntityInput(chickens[client_index], "SetParent", client_index, chickens[client_index], 0);
		//Reset rotation
		float nullRot[3];
		TeleportEntity(chickens[client_index], NULL_VECTOR, nullRot, NULL_VECTOR);
		//Keep player's hitbox, disable collisions for the fake chicken
		DispatchKeyValue(chickens[client_index], "solid", "0");
		//Spawn the chicken!
		DispatchSpawn(chickens[client_index]);
		ActivateEntity(chickens[client_index]);
		//Sets the base animation (to spawn with)
		SetVariantString(chickenSec[2]); AcceptEntityInput(chickens[client_index], "SetAnimation");
		//Plays the animation
		animationsTimer[client_index] = CreateTimer(0.1, Timer_ChickenAnim, GetClientUserId(client_index), TIMER_REPEAT);
	}
}

void DisableChicken(int client_index)
{
	//Reset player's properties, stop animations
	SetClientSpeed(client_index, 1.0);
	SetEntityRenderMode(client_index, RENDER_NORMAL);
	if (animationsTimer[client_index] != INVALID_HANDLE)
	{
		CloseHandle(animationsTimer[client_index]);
		animationsTimer[client_index] = INVALID_HANDLE;
	}
	
	lastFlags[client_index] = 0;
	flyCounter[client_index] = 0;
	wasRunning[client_index] = false;
	wasIdle[client_index] = false;
	wasWalking[client_index] = false;
	DisableFakeModel(client_index);
	DeleteFakeWeapon(client_index);
	ChickenDeath(client_index);
}

void DisableFakeModel(int client_index)
{
	if (chickens[client_index] != 0 && IsValidEdict(chickens[client_index]))
	{
		RemoveEdict(chickens[client_index]);
		chickens[client_index] = 0;
	}
}

void ChickenDeath(int client_index) //Fake a chicken's death
{
	//Sound
	int rdmSound = GetRandomInt(0, 2);
	EmitSoundToAll(chickenDeathSounds[rdmSound], client_index);
	
	//Particles
	float pos[3];
	feathersParticles[client_index] = CreateEntityByName("info_particle_system");
	DispatchKeyValue(feathersParticles[client_index], "effect_name", "chicken_gone_feathers");
	DispatchKeyValue(feathersParticles[client_index], "angles", "-90 0 0");
	GetClientAbsOrigin(client_index, pos);
	TeleportEntity(feathersParticles[client_index], pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(feathersParticles[client_index]);
	ActivateEntity(feathersParticles[client_index]);
	AcceptEntityInput(feathersParticles[client_index], "Start");
	//Prepare deletion of the particles
	feathersTimer[client_index] = CreateTimer(3.0, Timer_DestroyParticles, client_index);
}

void SetRotationLock(int client_index, bool enabled)
{
    float nullRot[3];
    float pos[3];
    if (enabled)
    {
        SetVariantString("!activator");
        AcceptEntityInput(chickens[client_index], "SetParent", client_index, chickens[client_index], 0);
        GetClientAbsOrigin(client_index, pos);
        TeleportEntity(chickens[client_index], NULL_VECTOR, nullRot, NULL_VECTOR);
    }
    else
    {
        AcceptEntityInput(chickens[client_index], "SetParent");
        GetClientAbsOrigin(client_index, pos);
        TeleportEntity(chickens[client_index], pos, NULL_VECTOR, NULL_VECTOR);
    }
} 

void SetClientSpeed(int client_index, float speed)
{
	SetEntPropFloat(client_index, Prop_Send, "m_flLaggedMovementValue", speed); //reduce player's speed (including falling speed)
}

public void SlowPlayerFall(int client_index)
{
	float vel[3];
	GetEntPropVector(client_index, Prop_Data, "m_vecVelocity", vel);
	if (vel[2] < 0.0)
	{
		float oldSpeed = vel[2];
		
		// Player is falling to fast, lets slow him to maxFallSpeed
		if(vel[2] < maxFallSpeed)
			vel[2] = maxFallSpeed;
		
		// Fallspeed changed
		if(oldSpeed != vel[2])
			TeleportEntity(client_index, NULL_VECTOR, NULL_VECTOR, vel);
	}
}


public Action Timer_ChickenAnim(Handle timer, int userid) //Must reset falling anim each 1s (doesn't loop)
{
	int client_index = GetClientOfUserId(userid);
	if (client_index && IsClientInGame(client_index))
	{
		int currentFlags = GetEntityFlags(client_index);
		
		//If client started fly, change his animation (falling), or set it back if 1s passed
		if (!(currentFlags & FL_ONGROUND) && flyCounter[client_index] == 0)
		{
			SetVariantString(chickenSec[4]); AcceptEntityInput(chickens[client_index], "SetAnimation");
			wasRunning[client_index] = false;
			wasIdle[client_index] = false;
			wasWalking[client_index] = false;
			flyCounter[client_index]++;
			SetClientSpeed(client_index, chickenRunSpeed);
			//PrintToChat(client_index, "Falling");
		}
		//If flying, count time passed
		else if (!(currentFlags & FL_ONGROUND))
		{
			flyCounter[client_index]++;
			if (flyCounter[client_index] == 9)
				flyCounter[client_index] = 0;
		}
		//If grounded
		else if (currentFlags & FL_ONGROUND)
		{
			flyCounter[client_index] = 0;
			//If client is not moving, not already idle, set him idle
			if (!isMoving[client_index] && !wasIdle[client_index])
			{
				SetVariantString(chickenSec[2]); AcceptEntityInput(chickens[client_index], "SetAnimation");
				wasRunning[client_index] = false;
				wasIdle[client_index] = true;
				wasWalking[client_index] = false;
				SetClientSpeed(client_index, chickenRunSpeed);
				//PrintToChat(client_index, "Idle");
			}
			//if pressing the walk key, is not already walking, is moving, set him walking   
			else if (isWalking[client_index] && !wasWalking[client_index] && isMoving[client_index])
			{
				SetVariantString(chickenSec[0]); AcceptEntityInput(chickens[client_index], "SetAnimation");
				wasRunning[client_index] = false;
				wasIdle[client_index] = false;
				wasWalking[client_index] = true;
				SetClientSpeed(client_index, chickenWalkSpeed);
				//PrintToChat(client_index, "Walking");
			}
			//if is not pressing walk, not already running, is moving, set him running     
			else if (!isWalking[client_index] && !wasRunning[client_index] && isMoving[client_index])
			{
				SetVariantString(chickenSec[1]); AcceptEntityInput(chickens[client_index], "SetAnimation");
				wasRunning[client_index] = true;
				wasIdle[client_index] = false;
				wasWalking[client_index] = false;
				SetClientSpeed(client_index, chickenRunSpeed);
				//PrintToChat(client_index, "Running");
			}
		}
		lastFlags[client_index] = currentFlags;
	}
}

public Action Timer_DestroyParticles(Handle timer, int client_index)
{
	if (feathersTimer[client_index] == timer && IsValidEdict(feathersParticles[client_index]))
		RemoveEdict(feathersParticles[client_index]);
	
	return Plugin_Handled;
} 