#include <YSI\y_hooks>

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

new bool:pCBugging[MAX_PLAYERS];
new anticbug=1;
new ptmCBugFreezeOver[MAX_PLAYERS];
new ptsLastFiredWeapon[MAX_PLAYERS];


hook OnPlayerDisconnect(playerid, reason)
{
	ResetPlayerVariables(playerid);
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!pCBugging[playerid] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && anticbug)
	{
		if(GetPVarInt(playerid, "IsInArena") && PaintBallArena[GetPVarInt(playerid, "IsInArena")][pbExploitPerm] == 1) return 1;
		if(PRESSED(KEY_FIRE))
		{
			switch(GetPlayerWeapon(playerid))
			{
				case WEAPON_COLT45, WEAPON_SILENCED, WEAPON_DEAGLE, WEAPON_SHOTGUN, WEAPON_SAWEDOFF, WEAPON_SHOTGSPA, WEAPON_UZI, WEAPON_MP5, WEAPON_AK47, WEAPON_M4, WEAPON_TEC9, WEAPON_RIFLE, WEAPON_SNIPER:
				{
					ptsLastFiredWeapon[playerid] = gettime();
				}
			}
		}
		else if(PRESSED(KEY_CROUCH))
		{
			if((gettime() - ptsLastFiredWeapon[playerid]) < 1)
			{
				TogglePlayerControllable(playerid, false);

				pCBugging[playerid] = true;

				SendClientMessageEx(playerid, COLOR_LIGHTRED, "** Please do not abuse the C-Bug glitch. This action has been reported to the admins.");

				KillTimer(ptmCBugFreezeOver[playerid]);
				ptmCBugFreezeOver[playerid] = SetTimerEx("CBugFreezeOver", 1500, false, "i", playerid);
				format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID:%d) is possibly abusing C-Bug.", GetPlayerNameEx(playerid), playerid);
		        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
			}
		}
	}
	return 1;
}

CMD:anticbug(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337) switch(anticbug) {
		case 0: {

			new
				szMessage[64];

			anticbug = true;

			format(szMessage, sizeof szMessage, "AdmCmd: %s has enabled anti c-bug.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);
		}
		default: {

			new
				szMessage[64];

			format(szMessage, sizeof szMessage, "AdmCmd: %s has disabled anti c-bug.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);

			anticbug = false;
		}
	}
	return 1;
}
stock ResetPlayerVariables(playerid)
{
	pCBugging[playerid] = false;

	KillTimer(ptmCBugFreezeOver[playerid]);

	ptsLastFiredWeapon[playerid] = 0;
	return 1;
}

forward CBugFreezeOver(playerid);
public CBugFreezeOver(playerid)
{
	TogglePlayerControllable(playerid, true);

	pCBugging[playerid] = false;
	return 1;
}