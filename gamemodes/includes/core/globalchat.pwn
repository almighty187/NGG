new enabledGlobal = 1;

stock gcOOCOff(color,string[])
{
	foreach(new i: Player)
	{
		if(!gcOoc[i]) {
			SendClientMessageEx(i, color, string);
		}
	}	
}

CMD:gmute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pVIPMod])
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gmute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot mute admins from global Chat!");
			if(PlayerInfo[giveplayerid][pVMuted] == 0)
			{
				PlayerInfo[giveplayerid][pVMuted] = 1;
				format(string, sizeof(string), "AdmCmd: %s has indefinitely blocked %s from using global Chat.",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				format(string, sizeof(string), "You have been indefinitely muted from global Chat for abuse by %s. You may appeal this on the forums (admin complaint)", GetPlayerNameEx(playerid));
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, string);
				format(string, sizeof(string), "AdmCmd: %s(%d) was blocked from /g by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
				Log("logs/mute.log", string);
			}
			else
			{
				PlayerInfo[giveplayerid][pVMuted] = 0;
				format(string, sizeof(string), "AdmCmd: %s has been re-allowed to use global Chat by %s.",GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				format(string, sizeof(string), "You have been re-allowed to use global Chat by %s.", GetPlayerNameEx(playerid));
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, string);
				format(string, sizeof(string), "AdmCmd: %s(%d) was unblocked from /g by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
				Log("logs/mute.log", string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
	}
	return 1;
}

// This code below requires some database changes
/*CMD:gmute(playerid, params[])
{
	new targetid, string[128];

	if(PlayerInfo[playerid][pAdmin] < 1 && PlayerInfo[playerid][pHelper] < 2)
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use this command.");

	if(!strcmp(params, "global", true))
	{
	    if(!PlayerInfo[playerid][pGlobalMuted])
	        return SendClientMessage(playerid, COLOR_GREY, "You are not muted from the global chat.");

		if(PlayerInfo[playerid][pGlobalMuteTime] > gettime())
		{
		    return SendClientMessageEx(playerid, COLOR_GREY, "You need to wait at least %i minutes before requesting an unmute.", (PlayerInfo[playerid][pGlobalMuteTime] - gettime()) / 60);
		}

		format(string, sizeof(string), "Fine ($%i)\n10 Minute Jail", percent(PlayerInfo[playerid][pCash]+PlayerInfo[playerid][pBank], 5));
		ShowPlayerDialog(playerid, DIALOG_GLOBALUNMUTE, DIALOG_STYLE_LIST, "Choose your punishment for this unmute.", string, "Select", "Cancel");
		return 1;
	}

	if(sscanf(params, "u", targetid))
		return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /gmute [playerid] or /gmute global");

	if(!IsPlayerConnected(targetid))
		return SendClientMessageEx(playerid, COLOR_GREY, "The player specified is disconnected.");

	if(!PlayerInfo[targetid][pGlobalMuted])
	{
	    PlayerInfo[targetid][pGlobalMuted] = 1;
	    PlayerInfo[targetid][pGlobalMuteTime] = gettime() + 14400; // 4 hours

	    format(string, sizeof(string), "AdmCmd: %s was muted from global chat by %s.", GetPlayerRPName(targetid), GetPlayerRPName(playerid));
	    SendStaffMessage(COLOR_LIGHTRED, string);
	    
	    format(string, sizeof(string), "You have been muted from global chat by %s.", GetPlayerRPName(playerid));
	    SendClientMessageEx(targetid, COLOR_LIGHTRED, string);
	}
	else
	{
	    PlayerInfo[targetid][pGlobalMuted] = 0;
	    PlayerInfo[targetid][pGlobalMuteTime] = 0;

	    format(string, sizeof(string), "AdmCmd: %s was unmuted from global chat by %s.", GetPlayerRPName(targetid), GetPlayerRPName(playerid));
	    SendStaffMessage(COLOR_LIGHTRED, string);
	    
	    format(string, sizeof(string), "You have been unmuted from global chat by %s.", GetPlayerRPName(playerid));
	    SendClientMessageEx(targetid, COLOR_WHITE, string);
	}
	return 1;
}*/

CMD:toggc(playerid, params[])
{
	if (!gcOoc[playerid])
	{
		gcOoc[playerid] = 1;
		SendClientMessageEx(playerid, COLOR_GRAD2, "You have disabled global chat.");
	}
	else
	{
		gcOoc[playerid] = 0;
		SendClientMessageEx(playerid, COLOR_GRAD2, "You have enabled global chat.");
	}
	return 1;
}

CMD:nogc(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to use this command.");

	if(!enabledGlobal)
	{
	    enabledGlobal = 1;
	    SendClientMessageToAllEx(COLOR_VIP, "(( Global channel enabled by an Admin! ))");
	}
	else
	{
	    enabledGlobal = 0;
	    SendClientMessageToAllEx(COLOR_VIP, "(( Global channel disabled by an Admin! ))");
	}
	return 1;
}

CMD:g(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "You're not logged in.");
	if (enabledGlobal == 0 && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "The global channel is disabled at the moment.");
	if(gcOoc[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You have disabled global Chat, re-enable with /toggc!");
	if(PlayerInfo[playerid][pVMuted] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "You are muted from the global chat channel.");

	//if(PlayerInfo[playerid][pGlobalMuted]) return SendClientMessageEx(playerid, COLOR_GREY, "You are muted from speaking in this channel.");
	//if(gettime() - PlayerInfo[playerid][pLastGlobal] < 5) return SendClientMessageEx(playerid, COLOR_GREY, 
	//"You must wait  %i seconds before speaking again in this channel.", 5 - (gettime() - PlayerInfo[playerid][pLastGlobal]));

	
	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /g [global chat]");
	

	if(PlayerInfo[playerid][pAdmin] >= 2 && !GetPVarType(playerid, "Undercover")){
		new string[128];
		format(string, sizeof(string), "(( %s %s: %s ))", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00,string);
	}
	else if(PlayerInfo[playerid][pAdmin] == 1 || PlayerInfo[playerid][pSMod] == 1)
	{
		new string[128], rank[20];
		
		if(PlayerInfo[playerid][pSMod] == 1)
			rank = "Senior Moderator";
		else
			rank = "Moderator";

		format(string, sizeof(string), "(( %s %s: %s ))", rank, GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00, string);
	}
	else if(PlayerInfo[playerid][pHelper] >= 1){
		new string[128];
		format(string, sizeof(string), "(( %s %s: %s ))", GetAdvisorRankName(PlayerInfo[playerid][pHelper]), GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00,string);
	}
	else if(PlayerInfo[playerid][pDonateRank] > 0 || GetPVarType(playerid, "Undercover")) {
		new string[128];
	    format(string, sizeof(string), "(( %s %s: %s ))", GetVIPRankName(PlayerInfo[playerid][pDonateRank]), GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00,string);
	}
	else if(PlayerInfo[playerid][pFamed] > 0 || GetPVarType(playerid, "Undercover")) {
		new string[128];
	    format(string, sizeof(string), "(( %s %s: %s ))", GetFamedRankName(PlayerInfo[playerid][pFamed]), GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00,string);
	}
	else if(PlayerInfo[playerid][pLevel] >= 1) {
		new string[128];
	    format(string, sizeof(string), "(( Level %i Player %s: %s ))", PlayerInfo[playerid][pLevel], GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00,string);
	}
	/*else {
	    new string[128];
	    format(string, sizeof(string), "(( Newbie %s: %s ))", GetPlayerNameEx(playerid), params);
		gcOOCOff(0x3399FF00,string);
	}*/
	/*if(PlayerInfo[playerid][pAdmin] < 2)
 	{
 		PlayerInfo[playerid][pLastGlobal] = gettime();
 	}*/
	return 1;
}