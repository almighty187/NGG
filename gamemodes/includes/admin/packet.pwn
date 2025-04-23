#include <YSI\y_hooks>

const PLAYER_SYNC = 207;
const VEHICLE_SYNC = 200;
const PASSENGER_SYNC = 211;
const TRAILER_SYNC = 210;
const UNOCCUPIED_SYNC = 209;
const AIM_SYNC = 203;
const BULLET_SYNC = 206;
const SPECTATING_SYNC = 212;
const WEAPONS_UPDATE_SYNC = 204;
const STATS_UPDATE_SYNC = 205;
const RCON_COMMAND_SYNC = 201;

#define 			HACKTIMER_INTERVAL 			5000

#define 			BODY_PART_UNKNOWN 			0
#define 			WEAPON_UNARMED 				0
#define 			WEAPON_VEHICLE_M4 			19
#define 			WEAPON_VEHICLE_MINIGUN 		20
#define 			WEAPON_PISTOLWHIP 			48
#define 			WEAPON_HELIBLADES 			50
#define 			WEAPON_EXPLOSION 			51
#define 			WEAPON_CARPARK 				52
#define 			WEAPON_UNKNOWN 				55

#define 			AC_MAX_REJECTED_HITS 		15
#define 			AC_MAX_DAMAGE_RANGES 		5

// Holds the last sync data for the player
new activeBulletData[MAX_PLAYERS][PR_BulletSync];
new activeAimData[MAX_PLAYERS][PR_AimSync];
new activeOnFootData[MAX_PLAYERS][PR_OnFootSync];
new activeInCarData[MAX_PLAYERS][PR_InCarSync];

// Basic instanced event-based dmg tracking, useful to flag and track injected damage - RW

// Maximum number of shots supported in our 'detection instance' - unlikely to have someone shoot over 20 times in 1 second
#define SHOT_LIMIT  20
// This would be used to store damage values for individuals players in each 'detection instance', the variable you would be accessing would be the dmg value
static Float:dmg[SHOT_LIMIT][MAX_PLAYERS];
// Making use of epoch time we can nicely track time for our calculations so it isn't running on a heartbeat (which would be really inefficient when running on a server with hundreds of players!)
static dmg_timer[MAX_PLAYERS];

// dmg threshold to flag
new Float:dmgthreshold = 200.0;

IsShootingAnimation(playerid)
{
    switch(activeOnFootData[playerid][PR_animationId])
    {
        case 1159 .. 1162, 1330, 219, 1166, 362, 360, 1188:
        {
            return true;
        } 
    }
    return false;
}

IsReloading(playerid)
{
    switch(activeOnFootData[playerid][PR_animationId])
    {
        case 1134:
        {
            return true;
        }
    }
    return false;
}

stock IsWeaponPistol(weaponid)
{
    switch (GetWeaponSlot(weaponid)) 
    {
        case 2: return true;
    }
    return false;
}

stock IsMeleeWeapon(weaponid) {

	return (WEAPON_UNARMED <= weaponid <= WEAPON_KATANA) || (WEAPON_DILDO <= weaponid <= WEAPON_CANE) || weaponid == WEAPON_PISTOLWHIP;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    new Float:playerpos[3], Float:damagedpos[3];
    GetPlayerPos(playerid, playerpos[0], playerpos[1], playerpos[2]);
    GetPlayerPos(damagedid, damagedpos[0], damagedpos[1], damagedpos[2]);

    // Have they issued damage while not doing a 'normal' animation?
    if(!IsShootingAnimation(playerid) && IsWeaponPistol(weaponid) || !IsShootingAnimation(playerid) && IsWeaponPrimary(weaponid))
    {
        RpcAimbot[playerid]++;
        if(RpcAimbot[playerid] >= 15)
        {
            szMiscArray[0] = 0;
            format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just issued a damage RPC with a suspicious animation (potential aimbot)", GetPlayerNameEx(playerid), playerid);
            ABroadCast(COLOR_YELLOW, szMiscArray, 2);
            Log("logs/hack.log", szMiscArray);
            RpcAimbot[playerid] = 0;
            AddFlag(playerid, INVALID_PLAYER_ID, "Detected using aimbot - RPC");         
        }
    }


    // Have they issued damage while performing a reloading animation? (same as before but provides more clarity)
    if(IsReloading(playerid) && IsWeaponPistol(weaponid) || IsReloading(playerid) && IsWeaponPrimary(weaponid))
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just issued a damage RPC while reloading (potential cleo)", GetPlayerNameEx(playerid), playerid);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
    }

    new Float:fDistance = GetPlayerDistanceFromPoint(playerid, activeBulletData[playerid][PR_origin][0], activeBulletData[playerid][PR_origin][1], activeBulletData[playerid][PR_origin][2]);
    new Float:hitDistance = GetPlayerDistanceFromPoint(damagedid, activeBulletData[playerid][PR_hitPos][0], activeBulletData[playerid][PR_hitPos][1], activeBulletData[playerid][PR_hitPos][2]);

    // Does the distance between the BULLET_SYNC hit destination match the position of the player they're trying to hit?
    if(hitDistance >= 2.5 && !IsMeleeWeapon(weaponid))
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just issued bullet packets and the destination does not match %s's position (packet spoofing/aimbot)", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(damagedid));
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        // Invalidate hit
        return 0;
    }

    // Does the latest BULLET_SYNC data match the weaponid the player is trying to give damage for?
    if(activeBulletData[playerid][PR_weaponId] != weaponid && !IsMeleeWeapon(weaponid))
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just issued a damage RPC with a weapon different to their bullet packets (packet spoofing/aimbot)", GetPlayerNameEx(playerid), playerid);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        // Invalidate hit
        return 0;
    }

    // Does the latest BULLET_SYNC data bullet origin roughly match the players location?
    if(fDistance > 2.5 && !IsMeleeWeapon(weaponid))
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has issued bullet packets that do not match their location (packet spoofing/aimbot)", GetPlayerNameEx(playerid), playerid);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        // Invalidate hit
        return 0;
    } 

    // Is the latest AIM_SYNC data camMode the appropriate camMode for the weapon used? (this can be falsely triggered by just hitting someone by shooting without aiming but is unlikely)
    switch(weaponid)
    {
        // Sniper rifles
        case 34, 402, 150, 121, 387, 342:
        {
            if(activeAimData[playerid][PR_camMode] != 7)
            {
                RpcAimbot[playerid]++;
                if(RpcAimbot[playerid] >= 15)
                {
                    szMiscArray[0] = 0;
                    format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just inflicted damage with a dodgy camera mode (potential aimbot)", GetPlayerNameEx(playerid), playerid);
                    ABroadCast(COLOR_YELLOW, szMiscArray, 2);
                    Log("logs/hack.log", szMiscArray);
                    RpcAimbot[playerid] = 0;
                    AddFlag(playerid, INVALID_PLAYER_ID, "Detected using aimbot - RPC");
                }
            }
        }
    }

    if(weaponid != 34)
    {
        if(activeAimData[playerid][PR_camMode] != 53)
        {
            RpcAimbot[playerid]++;
            if(RpcAimbot[playerid] >= 15)
            {
                szMiscArray[0] = 0;
                format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just inflicted damage with a dodgy camera mode (potential aimbot)", GetPlayerNameEx(playerid), playerid);
                ABroadCast(COLOR_YELLOW, szMiscArray, 2);
                Log("logs/hack.log", szMiscArray);
                RpcAimbot[playerid] = 0;
                AddFlag(playerid, INVALID_PLAYER_ID, "Detected using aimbot - RPC");
            }
        }
    }

    // If the current time is greater than our players timer + 1 seconds then we'll reset their dmg_timer as we'll be starting a new 'detection instance' as for this example we'll be tracking in 1 second blocks.
    if(gettime() > dmg_timer[playerid]+1) 
    {
        ClearAC(playerid);
        dmg_timer[playerid] = gettime();
    }

    // Simply fill in the next available element of the array when damage is done
    for(new i=0; i < sizeof(dmg); i++)
    {
        // if the value hasnt been filled in yet
        if(dmg[i][playerid] == 0)
        {
            dmg[i][playerid] = amount;
            break;
        }
    }

    // Looping through again to get the total dmg done in the 1 (or less) second window
    new Float:total = 0;
    for(new i=0; i < sizeof(dmg); i++)
    {
        total += dmg[i][playerid];
    }

    // Finally flag if it exceeds a specified threshold
    if(total >= dmgthreshold)
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has just inflicted 200 damage in a single second.", GetPlayerNameEx(playerid), playerid);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);

        // Reset everything now theyve been flagged
        ClearAC(playerid);
    }

    return 1;
}

ClearAC(playerid)
{
    for(new i=0; i < sizeof(dmg); i++)
    {
        dmg[i][playerid] = 0;
    }
}

IPacket:AIM_SYNC(playerid, BitStream:bs)
{
    new aimData[PR_AimSync];

    BS_IgnoreBits(bs, 8);
    BS_ReadAimSync(bs, aimData);

    // Have they sent a NaN aimZ position?
    if (aimData[PR_aimZ] != aimData[PR_aimZ]) 
    {
        return 0;
    }

    activeAimData[playerid] = aimData;

    return 1;
}

IPacket:BULLET_SYNC(playerid, BitStream:bs)
{
    new bulletData[PR_BulletSync];

    BS_IgnoreBits(bs, 8);
    BS_ReadBulletSync(bs, bulletData);

    activeBulletData[playerid] = bulletData;

    // Flood protection
    new Float:distance;
    distance = GetPlayerDistanceFromPoint(playerid, bulletData[PR_origin][0], bulletData[PR_origin][1], bulletData[PR_origin][2]);

    if(distance == 0)
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) is flooding bullet packets.", GetPlayerNameEx(playerid), playerid);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        floodWarnings[playerid]++;
        if(floodWarnings[playerid] > 2)
        {
            new string[128];
            format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was banned, reason: Packet Flooding.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
            Log("logs/ban.log", string);
            CreateBan(INVALID_PLAYER_ID, PlayerInfo[playerid][pId], playerid, PlayerInfo[playerid][pIP], "SYSTEM: Packet Flooding", 180);
            TotalAutoBan++;
            return 0;
        }
        return 0;
    }

    return 1;
}

IPacket:PLAYER_SYNC(playerid, BitStream:bs)
{
    new onFootData[PR_OnFootSync];

    BS_IgnoreBits(bs, 8);
    BS_ReadOnFootSync(bs, onFootData);

    activeOnFootData[playerid] = onFootData;

    // Have they gone from a 'normal' on-foot velocity to a suspiciously high/low one?
    if(-2 <= activeOnFootData[playerid][PR_velocity][1] < 2 && onFootData[PR_velocity][1] < -10 || -2 <= activeOnFootData[playerid][PR_velocity][1] < 2 && onFootData[PR_velocity][1] > 10)
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has a suspicious velocity change on-foot (potential warp hacker)", GetPlayerNameEx(playerid), playerid);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        packetWarpWarnings[playerid]++;
        if(packetWarpWarnings[playerid] > 2)
        {
            new string[128];
            format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was banned, reason: Warp Hacking.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
            Log("logs/ban.log", string);
            CreateBan(INVALID_PLAYER_ID, PlayerInfo[playerid][pId], playerid, PlayerInfo[playerid][pIP], "SYSTEM: Warp Hacking", 180);
            TotalAutoBan++;
        }
        return 0;
    }

    return 1;
}

IPacket:VEHICLE_SYNC(playerid, BitStream:bs)
{
    new inCarData[PR_InCarSync];

    BS_IgnoreBits(bs, 8);
    BS_ReadInCarSync(bs, inCarData);

    activeInCarData[playerid] = inCarData;

    if(activeOnFootData[playerid][PR_specialAction] != 3276)
    {
        // We'll set this here to easily identify the first onfoot > invehicle sync packet, should assist with identifying warp hackers, the number has no relevance but is unique
        activeOnFootData[playerid][PR_specialAction] = 3276;

        new Float:vehPos[3];

        GetVehiclePos(inCarData[PR_vehicleId], vehPos[0], vehPos[1], vehPos[2]);

        new Float:fDistance = GetPlayerDistanceFromPoint(playerid, vehPos[0], vehPos[1], vehPos[2]);

        // Have they entered a vehicle from a distance considered unreasonably far to enter from?
        if(fDistance >= 20)
        {
            szMiscArray[0] = 0;
            format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has entered a vehicle (ID: %d) from a far distance (potential warp hacking)", GetPlayerNameEx(playerid), playerid, inCarData[PR_vehicleId]);
            ABroadCast(COLOR_YELLOW, szMiscArray, 2);
            Log("logs/hack.log", szMiscArray);
            return 0;
        }
    }

    // Have they gone from a 'normal' in-car velocity to a suspiciously high/low one?
    if(-5 <= activeInCarData[playerid][PR_velocity][1] < 5 && inCarData[PR_velocity][1] < -10 || -5 <= activeInCarData[playerid][PR_velocity][1] < 5 && inCarData[PR_velocity][1] > 10)
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has a suspicious velocity change in a vehicle (ID: %d) (potential warp hacker)", GetPlayerNameEx(playerid), playerid, inCarData[PR_vehicleId]);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        packetWarpWarnings[playerid]++;
        if(packetWarpWarnings[playerid] > 2)
        {
            new string[128];
            format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was banned, reason: Warp Hacking.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
            Log("logs/ban.log", string);
            CreateBan(INVALID_PLAYER_ID, PlayerInfo[playerid][pId], playerid, PlayerInfo[playerid][pIP], "SYSTEM: Warp Hacking", 180);
            TotalAutoBan++;
        }
        return 0;
    }

    // Have they entered multiple vehicles within the same second?
    if(activeInCarData[playerid][PR_vehicleId] != inCarData[PR_vehicleId] && activeInCarData[playerid][PR_timeStamp] == inCarData[PR_timeStamp])
    {
        szMiscArray[0] = 0;
        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has entered multiple vehicles (%d and %d) within the same second (potential warp hacker)", GetPlayerNameEx(playerid), playerid, inCarData[PR_vehicleId], activeInCarData[playerid][PR_vehicleId]);
        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
        Log("logs/hack.log", szMiscArray);
        packetWarpWarnings[playerid]++;
        if(packetWarpWarnings[playerid] > 2)
        {
            new string[128];
            format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was banned, reason: Warp Hacking.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
            Log("logs/ban.log", string);
            CreateBan(INVALID_PLAYER_ID, PlayerInfo[playerid][pId], playerid, PlayerInfo[playerid][pIP], "SYSTEM: Warp Hacking", 180);
            TotalAutoBan++;
        }
        return 0;
    }

    return 1;
}

const ID_RPC = 20;
const RPC_UpdateScoresAndPings = 155;

IRawPacket:ID_RPC(playerid, BitStream:bs)
{
    new rpcid, numberOfBitsOfData;

    BS_ReadValue(bs,
        PR_IGNORE_BITS, 8,
        PR_UINT8, rpcid,
        PR_CUINT32, numberOfBitsOfData
    );

    if(rpcid == RPC_UpdateScoresAndPings)
    {
        // Have they triggered an UpdateScoreAndPing RPC within the same second as finalising the server connection?
        if(joinTimestamp[playerid] == gettime()-3)
        {
            format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has triggered a suspicious RPC upon joining (potential rakSAMP user)", GetPlayerNameEx(playerid), playerid);
            ABroadCast(COLOR_YELLOW, szMiscArray, 2);
            Log("logs/hack.log", szMiscArray);
        }
    }

    return 1;
}