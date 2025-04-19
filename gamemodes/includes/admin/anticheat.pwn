stock ExecuteNOPAction(playerid)
{
	new string[128];
	new newcar = GetPlayerVehicleID(playerid);
	if(NOPTrigger[playerid] >= MAX_NOP_WARNINGS) { return 1; }
	NOPTrigger[playerid]++;
	RemovePlayerFromVehicle(playerid);
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	SetPlayerPos(playerid, X, Y, Z+2);
	defer NOPCheck(playerid);
	if(NOPTrigger[playerid] > 1)
	{
		new sec = (NOPTrigger[playerid] * 5000)/1000-1;
		format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) may be NOP hacking - restricted vehicle (model %d) for %d seconds.", GetPlayerNameEx(playerid), playerid, GetVehicleModel(newcar),sec);
		ABroadCast(COLOR_YELLOW, string, 2);
	}
	return 1;
}

stock ExecuteHackerAction( playerid, weaponid )
{
	if(!gPlayerLogged{playerid}) { return 1; }
	if(PlayerInfo[playerid][pTut] == 0) { return 1; }
	if(playerTabbed[playerid] >= 1) { return 1; }
	if(GetPVarType(playerid, "IsInArena")) { return 1; }

	new String[ 128 ], WeaponName[ 128 ];
	GetWeaponName( weaponid, WeaponName, sizeof( WeaponName ) );

	format( String, sizeof( String ), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) may possibly be weapon hacking (%s).", GetPlayerNameEx(playerid), playerid, WeaponName );
	ABroadCast( COLOR_YELLOW, String, 2 );
	format(String, sizeof(String), "%s(%d) (ID %d) may possibly be weapon hacking (%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerid, WeaponName);
	Log("logs/hack.log", String);

	return 1;
}

// I have no idea if this will work, its a theory - Behemoth
#define MAX_VEHICLE_ENTRIES 3
#define VEHICLE_ENTRY_INTERVAL 1500 
#define NOP_WARNINGS 3
#define NOP_CHECK_INTERVAL 1
#define VEHICLE_SPEED_LIMIT 3.0
#define VEHICLE_SAFE_RADIUS 25.0

new g_VehicleEntryCount[MAX_PLAYERS];
new g_LastVehicleEntryTime[MAX_PLAYERS];

new
    nopWarnings[MAX_PLAYERS],
    nopLastCheck[MAX_PLAYERS],
    Float:nopLastX[MAX_PLAYERS],
    Float:nopLastY[MAX_PLAYERS],
    Float:nopLastZ[MAX_PLAYERS],
    flingWarnings[MAX_PLAYERS];

hook OnGameModeInit()
{
    SetTimer("CheckUnoccupiedVehicles", 1000, true);
    return 1;
}

new PlayerExplosionCount[MAX_PLAYERS];
new ExplosionTimer[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    g_VehicleEntryCount[playerid] = 0;
    g_LastVehicleEntryTime[playerid] = 0;
    nopWarnings[playerid] = 0;
    nopLastCheck[playerid] = gettime();
    flingWarnings[playerid] = 0;
    GetPlayerPos(playerid, nopLastX[playerid], nopLastY[playerid], nopLastZ[playerid]);
    return 1;
}

hook OnPlayerUpdate(playerid)
{
    new currentTime = gettime();

    if (currentTime - nopLastCheck[playerid] >= NOP_CHECK_INTERVAL)
    {
        nopLastCheck[playerid] = currentTime;

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        new Float:dist = floatsqroot(
            floatpower(x - nopLastX[playerid], 2) +
            floatpower(y - nopLastY[playerid], 2) +
            floatpower(z - nopLastZ[playerid], 2)
        );

        new keys, up, lr;
        GetPlayerKeys(playerid, keys, up, lr);

        if (gettime() >= g_NopCheckReadyTime[playerid] && dist > 5.0 && keys == 0 && up == 0 && lr == 0)
        {
            nopWarnings[playerid]++;
            if (nopWarnings[playerid] >= NOP_WARNINGS && PlayerInfo[playerid][pAdmin] < 2 && !InsideTut[playerid] && PlayerInfo[playerid][pHospital] == 0 && PlayerInfo[playerid][pLevel] < 3)
            {
                new String[128];
                format(String, sizeof(String), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) may possibly be warp hacking.", GetPlayerNameEx(playerid), playerid);
                ABroadCast(COLOR_YELLOW, String, 2);
                format(String, sizeof(String), "%s(%d) (ID %d) may possibly be warp hacking", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerid);
                Log("logs/hack.log", String);
                //KickEx(playerid);
            }
        }
        else
        {
            nopWarnings[playerid] = 0;
        }

        nopLastX[playerid] = x;
        nopLastY[playerid] = y;
        nopLastZ[playerid] = z;
    }

	if (GetTickCount() - ExplosionTimer[playerid] > 3000)
    {
        PlayerExplosionCount[playerid] = 0;
        ExplosionTimer[playerid] = GetTickCount();
    }

    return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        new currentTime = GetTickCount();

        if (currentTime - g_LastVehicleEntryTime[playerid] > VEHICLE_ENTRY_INTERVAL)
        {
            g_VehicleEntryCount[playerid] = 1;
        }
        else
        {
            g_VehicleEntryCount[playerid]++;
        }

        g_LastVehicleEntryTime[playerid] = currentTime;

        if (g_VehicleEntryCount[playerid] >= MAX_VEHICLE_ENTRIES && PlayerInfo[playerid][pAdmin] < 2 && !InsideTut[playerid] && PlayerInfo[playerid][pHospital] == 0 && PlayerInfo[playerid][pLevel] < 3)
        {
            new String[128];
            /*format(String, sizeof(String), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) may possibly be warp hacking.", GetPlayerNameEx(playerid), playerid);
            ABroadCast(COLOR_YELLOW, String, 2);*/
            format(String, sizeof(String), "%s(%d) (ID %d) may possibly be warp hacking", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerid);
            Log("logs/hack.log", String);
            //KickEx(playerid);
        }
    }
    return 1;
}

stock bool:IsVehicleOccupied_AntiCheat(vehicleid)
{
    foreach (new i : Player)
    {
        if (GetPlayerVehicleID(i) == vehicleid) return true;
    }
    return false;
}

forward CheckUnoccupiedVehicles();
public CheckUnoccupiedVehicles()
{
    new bool:someoneKicked = false;

    for (new veh = 1; veh < MAX_VEHICLES; veh++)
    {
        if (!IsVehicleOccupied_AntiCheat(veh))
        {
            new Float:vx, Float:vy, Float:vz;
            GetVehicleVelocity(veh, vx, vy, vz);

            new Float:speed = floatsqroot(vx*vx + vy*vy + vz*vz);
            if (speed < VEHICLE_SPEED_LIMIT) continue;

            new Float:vxpos, Float:vypos, Float:vzpos;
            GetVehiclePos(veh, vxpos, vypos, vzpos);

            new suspect = INVALID_PLAYER_ID;
            new Float:closestDist = 99999.0;

            foreach (new playerid : Player)
            {
                if (!IsPlayerConnected(playerid)) continue;

                new Float:px, Float:py, Float:pz;
                GetPlayerPos(playerid, px, py, pz);

                new Float:dx = vxpos - px;
                new Float:dy = vypos - py;
                new Float:dz = vzpos - pz;

                new Float:dist = floatsqroot(dx*dx + dy*dy + dz*dz);
                if (dist < 25.0 && dist < closestDist)
                {
                    suspect = playerid;
                    closestDist = dist;
                }
            }

            if (suspect != INVALID_PLAYER_ID)
            {
                flingWarnings[suspect]++;

                if (flingWarnings[suspect] >= 2)
                {
                    new string[128];
                    format(string, sizeof(string), "%s(%d) (ID %d) may be using a vehicle fling hack.", GetPlayerNameEx(suspect), GetPlayerSQLId(suspect), suspect);
                    Log("logs/hack.log", string);
                    format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s was kicked for vehicle flinging.", GetPlayerNameEx(suspect));
                    ABroadCast(COLOR_YELLOW, string, 2);

                    KickEx(suspect);
                    someoneKicked = true;
                    break; // stop checking other vehicles this cycle
                }
            }
        }
    }

    if (someoneKicked)
    {
        // Reset all player fling warnings
        for (new i = 0; i < MAX_PLAYERS; i++) flingWarnings[i] = 0;

        // Respawn all unoccupied vehicles
        for (new veh = 1; veh < MAX_VEHICLES; veh++)
        {
            if (!IsVehicleOccupied_AntiCheat(veh)) SetVehicleToRespawn(veh);
        }
    }

    return 1;
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    // Explosion damage = weaponid 51
    if (weaponid == 51)
    {
        // Check if no attacker or attacker not using explosive weapon
        if (
            issuerid == INVALID_PLAYER_ID ||
            (
                GetPlayerWeapon(issuerid) != 16 &&  // Grenade
                GetPlayerWeapon(issuerid) != 35 &&  // RPG
                GetPlayerWeapon(issuerid) != 36 &&  // Heat-seeking RPG
                GetPlayerWeapon(issuerid) != 39     // Satchel
            )
        )
        {
            PlayerExplosionCount[playerid]++;

            if (PlayerExplosionCount[playerid] >= 3)
            {
                new string[128];
                format(string, sizeof(string), "%s(%d) (ID %d) may be using an explosion hack.", GetPlayerNameEx(issuerid), GetPlayerSQLId(issuerid), issuerid);
                Log("logs/hack.log", string);
                format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s was kicked for suspect explosion CLEOs.", GetPlayerNameEx(issuerid));
                ABroadCast(COLOR_YELLOW, string, 2);
				//KickEx(issuerid);
            }
        }
    }
    return 1;
}

forward sobeitCheck(playerid);
public sobeitCheck(playerid)
{
	if(GetPVarInt(playerid, "JailDelay") == 0)
	{
	    if(PlayerInfo[playerid][pJailTime] > 0)
		{
	        SetTimerEx("sobeitCheck", 1000, 0, "i", playerid);
	        SetPVarInt(playerid, "JailDelay", 1);
	        return 1;
	    }
	}

	DeletePVar(playerid, "JailDelay");
    if(IsPlayerFrozen[playerid] == 1)
	{
        new Float:hX, Float:hY, Float:hZ, Float:pX, Float:pY, Float:pZ, Float:cX, Float:cY, Float:cZ, Float:cX1, Float:cY1, Float:cZ1;
        GetPlayerCameraFrontVector(playerid, cX1, cY1, cZ1);
		GetPlayerPos(playerid, cX, cY, cZ);
        hX = GetPVarFloat(playerid, "FrontVectorX");
        hY = GetPVarFloat(playerid, "FrontVectorY");
        hZ = GetPVarFloat(playerid, "FrontVectorZ");
        pX = GetPVarFloat(playerid, "PlayerPositionX");
        pY = GetPVarFloat(playerid, "PlayerPositionY");
        pZ = GetPVarFloat(playerid, "PlayerPositionZ");

        if(pX != cX && pY != cY && pZ != cZ && hX != cX1 && hY != cY1 && hZ != cZ1)
        {
            SendClientMessageEx(playerid, COLOR_RED, "You have failed the player account check, please relog and try again!");
            IsPlayerFrozen[playerid] = 0;
            DeletePVar(playerid,"FrontVectorX");
            DeletePVar(playerid,"FrontVectorY");
            DeletePVar(playerid,"FrontVectorZ");
            DeletePVar(playerid,"PlayerPositionX");
            DeletePVar(playerid,"PlayerPositionY");
            DeletePVar(playerid,"PlayerPositionZ");
            SetTimerEx("KickEx", 1000, 0, "i", playerid);
            return 1;
        }
	}

	new Float:aX, Float:aY, Float:aZ, szString[128];
	GetPlayerCameraFrontVector(playerid, aX, aY, aZ);
	#pragma unused aX
	#pragma unused aY

	if(aZ < -0.7)
	{
		new IP[32];
		GetPlayerIp(playerid, IP, sizeof(IP));
		TogglePlayerControllable(playerid, true);

	 	if(PlayerInfo[playerid][pSMod] == 1 || PlayerInfo[playerid][pAdmin] == 1)
 		{
 		    mysql_format(MainPipeline, szString, sizeof(szString), "SELECT `Username` FROM `accounts` WHERE `AdminLevel` > 1 AND `Disabled` = 0 AND `IP` = '%s'", GetPlayerIpEx(playerid));
 		    mysql_tquery(MainPipeline, szString, "CheckAccounts", "i", playerid);
       	}
		else {
		    mysql_format(MainPipeline, szString, sizeof(szString), "INSERT INTO `sobeitkicks` (sqlID, Kicks) VALUES (%d, 1) ON DUPLICATE KEY UPDATE Kicks = Kicks + 1", GetPlayerSQLId(playerid));
			mysql_tquery(MainPipeline, szString, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);

			SendClientMessageEx(playerid, COLOR_RED, "The hacking tool 's0beit' is not allowed on this server, please uninstall it.");
   			format(szString, sizeof(szString), "%s(%d) (IP: %s) has logged into the server with s0beit installed.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), IP);
   			Log("logs/sobeit.log", szString);
   			IsPlayerFrozen[playerid] = 0;
    		SetTimerEx("KickEx", 1000, 0, "i", playerid);
     	}

	}
	
	if(playerTabbed[playerid] > 2) { SendClientMessageEx(playerid, COLOR_RED, "You have failed the account check, please relog."), SetTimerEx("KickEx", 1000, 0, "i", playerid); }

	if(PlayerInfo[playerid][pVW] > 0 || PlayerInfo[playerid][pInt] > 0) HideNoticeGUIFrame(playerid);
	sobeitCheckvar[playerid] = 1;
	sobeitCheckIsDone[playerid] = 1;
	IsPlayerFrozen[playerid] = 0;
	TogglePlayerControllable(playerid, true);
 	return 1;
}

//Dom - Adjusted to account for latest rapid fire exploits - Rothschild. 
ptask Anti_Rapidfire[1000](i)
{
	new weaponid = GetPlayerWeapon(i);
	if(((weaponid == 24 || weaponid == 25 || weaponid == 26) && PlayerShots[i] > 10) || ((weaponid == 34) && PlayerSniperShots[i] > 10)) // Updated to a higher value due to high rate of false positives.
	{
		format(szMiscArray, sizeof(szMiscArray), "%s(%d) (%d): %d shots in 1 second -- Weapon ID: %d", GetPlayerNameEx(i), i, GetPVarInt(i, "pSQLID"), PlayerShots[i], weaponid);
		Log("logs/rapid.log", szMiscArray);

		SetPVarInt(i, "MaxRFWarn", GetPVarInt(i, "MaxRFWarn")+1);
		format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may be rapidfire hacking. %d/%d warnings", GetPlayerNameEx(i), i, GetPVarInt(i, "MaxRFWarn"), MAX_RF_WARNS);
		ABroadCast(COLOR_YELLOW, szMiscArray, 2);
		if(GetPVarInt(i, "MaxRFWarn") >= MAX_RF_WARNS)
		{
			if(GetPVarType(i, "Autoban")) return 1;
			SetPVarInt(i, "Autoban", 1); 
			DeletePVar(i, "MaxRFWarn");
			CreateBan(INVALID_PLAYER_ID, PlayerInfo[i][pId], i, PlayerInfo[i][pIP], "Anti-Cheat: RapidFire Hacking", 180);
			TotalAutoBan++;
		}
	} 
	PlayerShots[i] = 0;
	PlayerSniperShots[i] = 0;
	return 1;
}

ptask Anti_Invisibility[5000](i)
{
	if(GetPlayerState(i) == PLAYER_STATE_SPECTATING && Spectating[i] == INVALID_PLAYER_ID && PlayerInfo[i][pAdmin] < 2)
	{
		format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) is using Invisibility CLEOs.", GetPlayerNameEx(i), i);
		ABroadCast(COLOR_YELLOW, szMiscArray, 2);
	}
}

ptask Anti_RapidKill[5000](i)
{
	if(PlayerKills[i] >= 5 && PlayerInfo[i][pAdmin] < 2)
	{
		CreateBan(INVALID_PLAYER_ID, PlayerInfo[i][pId], i, PlayerInfo[i][pIP], "Anti-Cheat: Ghost Hacking", 180);
	}
	PlayerKills[i] = 0;
	return 1;
}

forward LoginCheckEx(i);
public LoginCheckEx(i)
{
	new Float: pos[3], string[128];
	if(gPlayerLogged{i} == 0 && IsPlayerConnected(i))
	{
		/* INFORMATION REGARDING COORDS
			1093.000000 | -2036.000000 | 90.000000 // Start view of beach (Sometimes triggers via delay)
			0.000000 | 0.000000 | 0.000000 // Default location normally triggered first if above doesn't
			50.000000 | 50.000000 | 50.000000 // 2-3 timer check your at these coords unsure why you move to all 50.
		*/
		GetPlayerPos(i, pos[0], pos[1], pos[2]);
		if((pos[0] != 1093.000000 && pos[0] != 0.000000 && pos[0] != 50.000000) && (pos[1] != -2036.000000 && pos[1] != 0.000000 && pos[1] != 50.000000) && (pos[2] != 90.000000 && pos[2] != 0.000000 && pos[2] != 50.000000))
		{
			format(string, sizeof(string), "%s(%d) [%s] has moved from the login screen position.", GetPlayerNameEx(i), GetPlayerSQLId(i), GetPlayerIpEx(i));
			Log("logs/security.log", string);
			SendClientMessage(i, COLOR_WHITE, "SERVER: You have moved while being in the login screen!");
			ShowPlayerDialogEx(i, -1, DIALOG_STYLE_MSGBOX, "", "", "", "");
			SetTimerEx("KickEx", 1000, 0, "i", i);
		}
		SetTimerEx("LoginCheckEx", 5000, 0, "i", i);
	}
	return true;
}

stock CheckServerAd(szInput[]) {

	new
		iCount,
		iPeriod,
		iPos,
		iChar,
		iColon;

	while((iChar = szInput[iPos++])) {
		if('0' <= iChar <= '9') iCount++;
		else if(iChar == '.') iPeriod++;
		else if(iChar == ':') iColon++;
	}
	if(iCount >= 7 && iPeriod >= 3 && iColon >= 1) {
		return 1;
	}

	return 0;
}

CMD:hackwarnings(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return 1;
	new Float: health,
		Float: rhealth,
		Float: armor,
		Float: rarmor;
	
	szMiscArray[0] = 0;

	foreach(Player, i)
	{
		if(playerTabbed[i] != 0) continue;
		GetPlayerHealth(i, health);
		GetHealth(i, rhealth);
		GetPlayerArmour(i, armor);
		GetArmour(i, rarmor);
		if(health > rhealth)
		{
			format(szMiscArray, sizeof(szMiscArray), "%s (ID: %i, Level: %d) - Health - Recorded: %f - Current: %f", GetPlayerNameEx(i), i, PlayerInfo[i][pLevel], rhealth, health);
			SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
		}
		if(armor > rarmor)
		{
			format(szMiscArray, sizeof(szMiscArray), "%s (ID: %i, Level: %d) - Armor - Recorded: %f - Current: %f", GetPlayerNameEx(i), i, PlayerInfo[i][pLevel], rarmor, armor);
			SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
		}
	}
	return 1;
}