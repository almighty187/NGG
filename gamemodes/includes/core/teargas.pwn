#include <YSI\y_hooks>
new TGThrower[MAX_PLAYERS];

forward RemoveTGEffect();
public RemoveTGEffect() {
    for(new i = 0; i < MAX_PLAYERS; i ++ ) {
		SyncPlayerTime(i);
	    SetPlayerDrunkLevel(i, 0);
		SetPlayerWeather(i, gWeather);
	}
	return 1;
}

forward InitTGEffect(playerid);
public InitTGEffect(playerid) {
	new weaponid = GetPlayerWeapon(playerid);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
	for(new i = 0; i < MAX_PLAYERS; i++) 
    {
	    if(weaponid == 17)
	    {
	     	if(IsPlayerInRangeOfPoint(i,23.0, x, y, z) && !playerid)
        	{
        		if(TGThrower[i] == 0){
	        		new Float:health;
					GetPlayerHealth(i, health); 
					SetPlayerHealth(i, health - 10);
					ApplyAnimation(i, "ped", "gas_cwr", 1.0, 0, 0, 0, 0, 0);
					SetPlayerDrunkLevel(i, 50000);
					SetPlayerWeather(i, 111);
					SetPlayerTime(i, 0, 0);
					SendClientMessageEx(i, COLOR_RED, " You have been affected by tear gas!");
				}
		   	}
	  	}
	}
	TGThrower[playerid] = 0;
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

    if(PRESSED(KEY_FIRE))
    {    
        TGThrower[playerid] = 1;
        SetTimer("RemoveTGEffect", 15000, 0);
        SetTimerEx("InitTGEffect", 2000, 0, "d");
           
      }
}