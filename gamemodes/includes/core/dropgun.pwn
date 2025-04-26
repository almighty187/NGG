/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	Developers:
		- Sixxy
        - Rav
		
	* Copyright (c) 2020, Next Generation Gaming, LLC
	*
	* All rights reserved.
	*
	* Redistribution and use in source and binary forms, with or without modification,
	* are not permitted in any case.
	*
	*
	* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
	
enum E_DROPPEDGUN_DATA
{
	bool:eWeaponDropped,
	eWeaponObject,
	eWeaponTimer,
	
	eWeaponWepID,
	
	Float:eWeaponPos[3],
	eWeaponInterior,
	eWeaponWorld,
	
	eWeaponDroppedBy[MAX_PLAYER_NAME]
}

new WeaponDropInfo[200][E_DROPPEDGUN_DATA];

CMD:dropweapon(playerid, params[])
{
	if(!IsACop(playerid))
	{
		new 
			weaponid, 
			idx,
			Float:x,
			Float:y,
			Float:z
		;

		weaponid = GetPlayerWeapon(playerid);
		
		if(weaponid < 1 || weaponid > 46 || weaponid == 35 || weaponid == 36 || weaponid == 37 || weaponid == 38 || weaponid == 39 || weaponid == 4)
		    return SendClientMessageEx(playerid, COLOR_GREY, "You can't drop this weapon.");
		if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, -1, "You cannot do this right now!");
		if(PlayerInfo[playerid][pAdmin] > 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Administrators cannot drop weapons.");
			
		for(new i = 0; i < sizeof(WeaponDropInfo); i++)
		{
			if(!WeaponDropInfo[i][eWeaponDropped])
			{
				idx = i;
				break;
			}
		}
		
		GetPlayerPos(playerid, x, y, z); 
		
		WeaponDropInfo[idx][eWeaponDropped] = true;
		WeaponDropInfo[idx][eWeaponDroppedBy] = GetPlayerNameEx(playerid);
		
		WeaponDropInfo[idx][eWeaponWepID] = weaponid;
		
		WeaponDropInfo[idx][eWeaponPos][0] = x;
		WeaponDropInfo[idx][eWeaponPos][1] = y;
		WeaponDropInfo[idx][eWeaponPos][2] = z;
		
		WeaponDropInfo[idx][eWeaponInterior] = GetPlayerInterior(playerid);
		WeaponDropInfo[idx][eWeaponWorld] = GetPlayerVirtualWorld(playerid); 
		
		RemovePlayerWeapon(playerid, weaponid);
		
		WeaponDropInfo[idx][eWeaponObject] = CreateDynamicObject(
			ReturnWeaponsModel(weaponid),
			x,
			y,
			z - 1,
			80.0,
			0.0,
			0.0,
			GetPlayerVirtualWorld(playerid),
			GetPlayerInterior(playerid)); 
		
		new str[128];
		format(str, sizeof(str), "* %s drops their %s on the ground.", GetPlayerNameEx(playerid), ReturnWeaponName(WeaponDropInfo[idx][eWeaponWepID]));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		WeaponDropInfo[idx][eWeaponTimer] = SetTimerEx("OnPlayerLeaveWeapon", 300000, false, "i", idx);
		SendClientMessageEx(playerid, COLOR_RED, "Your weapon will disappear in 5 minutes if it isn't picked up.");
	}
	else return SendClientMessageEx(playerid, COLOR_RED, "You cannot drop weapons as a LEO.");
	return 1;
}

CMD:grabweapon(playerid, params[])
{	
	new
		bool:foundWeapon = false,
		id,
		str[128]
	;

	for(new i = 0; i < sizeof(WeaponDropInfo); i++)
	{
		if(!WeaponDropInfo[i][eWeaponDropped])
			continue; 
	
		if(IsPlayerInRangeOfPoint(playerid, 3.0, WeaponDropInfo[i][eWeaponPos][0], WeaponDropInfo[i][eWeaponPos][1], WeaponDropInfo[i][eWeaponPos][2]))
		{
			if(GetPlayerVirtualWorld(playerid) == WeaponDropInfo[i][eWeaponWorld])
			{
				foundWeapon = true;
				id = i;
			}							
		}
	}
	
	if((PlayerInfo[playerid][pConnectHours] < 1 || PlayerInfo[playerid][pWRestricted] > 0) && WeaponDropInfo[id][eWeaponWepID] != 46 && WeaponDropInfo[id][eWeaponWepID] != 43) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are restricted from carrying weapons");
	if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot do this as your account is restricted!");
	if(foundWeapon)
	{
		GivePlayerValidWeapon(playerid, WeaponDropInfo[id][eWeaponWepID]);
		format(str, sizeof(str), "* %s picks up a %s off the ground.", GetPlayerNameEx(playerid), ReturnWeaponName(WeaponDropInfo[id][eWeaponWepID]));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		
		WeaponDropInfo[id][eWeaponDropped] = false; 
		WeaponDropInfo[id][eWeaponDroppedBy] = 0;
		
		WeaponDropInfo[id][eWeaponWepID] = 0;
		
		KillTimer(WeaponDropInfo[id][eWeaponTimer]); 
		DestroyDynamicObject(WeaponDropInfo[id][eWeaponObject]); 
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "You aren't near a dropped weapon.");
	return 1;
}

CMD:seizeweapon(playerid, params[])
{	
	if(!IsACop(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "You are not a law enforcement officer!");
	new
		bool:foundWeapon = false,
		id,
		str[128]
	;

	for(new i = 0; i < sizeof(WeaponDropInfo); i++)
	{
		if(!WeaponDropInfo[i][eWeaponDropped])
			continue; 
	
		if(IsPlayerInRangeOfPoint(playerid, 3.0, WeaponDropInfo[i][eWeaponPos][0], WeaponDropInfo[i][eWeaponPos][1], WeaponDropInfo[i][eWeaponPos][2]))
		{
			if(GetPlayerVirtualWorld(playerid) == WeaponDropInfo[i][eWeaponWorld])
			{
				foundWeapon = true;
				id = i;
			}							
		}
	}
	if(foundWeapon)
	{
		format(str, sizeof(str), "* %s picks up a %s off the ground and bags it up.", GetPlayerNameEx(playerid), ReturnWeaponName(WeaponDropInfo[id][eWeaponWepID]));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		
		foreach(new i: Player)
		{
			if(IsACop(i))
			{
				format(str, sizeof(str), "HQ: Officer %s has seized a %s.", GetPlayerNameEx(playerid), ReturnWeaponName(WeaponDropInfo[id][eWeaponWepID]));
				SendClientMessageEx(i, COLOR_DBLUE, str);
			}
		}

		WeaponDropInfo[id][eWeaponDropped] = false; 
		WeaponDropInfo[id][eWeaponDroppedBy] = 0;
		
		WeaponDropInfo[id][eWeaponWepID] = 0; 
		
		KillTimer(WeaponDropInfo[id][eWeaponTimer]); 
		DestroyDynamicObject(WeaponDropInfo[id][eWeaponObject]); 
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "You aren't near a dropped weapon.");
	return 1;
}

CMD:dropinfo(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1) 
	{
		
		for(new i = 0; i < sizeof(WeaponDropInfo); i++)
		{
			if(!WeaponDropInfo[i][eWeaponDropped])
				continue;
		
			if(IsPlayerInRangeOfPoint(playerid, 5.0, WeaponDropInfo[i][eWeaponPos][0], WeaponDropInfo[i][eWeaponPos][1], WeaponDropInfo[i][eWeaponPos][2]))
			{
				if(GetPlayerVirtualWorld(playerid) == WeaponDropInfo[i][eWeaponWorld])
				{
					SendClientMessageEx(playerid, COLOR_GREY, "This is a %s dropped by %s.", ReturnWeaponName(WeaponDropInfo[i][eWeaponWepID]), WeaponDropInfo[i][eWeaponDroppedBy]);
				}
			}
			return 1;
		}	
		SendClientMessageEx(playerid, COLOR_GREY, "You aren't near a dropped gun.");
	}
    else
    {
        SendClientMessageEx(playerid, COLOR_GREY, "You do not have permission to use this command.");
    }
    return 1;
}

ReturnWeaponsModel(weaponid)
{
    new WeaponModels[] =
    {
        0, 331, 333, 334, 335, 336, 337, 338, 339, 341, 321, 322, 323, 324,
        325, 326, 342, 343, 344, 0, 0, 0, 346, 347, 348, 349, 350, 351, 352,
        353, 355, 356, 372, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366,
        367, 368, 368, 371
    };
    return WeaponModels[weaponid];
}

forward OnPlayerLeaveWeapon(index);
public OnPlayerLeaveWeapon(index) 
{
	WeaponDropInfo[index][eWeaponDropped] = false;
	WeaponDropInfo[index][eWeaponDroppedBy] = 0;

	WeaponDropInfo[index][eWeaponWepID] = 0;
	
	for(new i = 0; i < 3; i++)
	{
		WeaponDropInfo[index][eWeaponPos][i] = 0.0;
	}
	
	if(IsValidDynamicObject(WeaponDropInfo[index][eWeaponObject]))
	{
		DestroyDynamicObject(WeaponDropInfo[index][eWeaponObject]);
	}
	
	return 1;
}