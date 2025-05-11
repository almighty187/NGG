
hook OnPlayerDisconnect(playerid, reason) {
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pDiceOffer] == playerid)
		{
			PlayerInfo[i][pDiceOffer] = INVALID_PLAYER_ID;
		}
	}
	return 1;
}

CMD:dicebet(playerid, params[])
{
	new targetid, amount;
	if(!IsPlayerInRangeOfPoint(playerid, 100.0,1802.1423,-1593.6298,1215.1792)) return SendClientMessageEx(playerid, COLOR_GREY, "You are not in a Casino.");
	//if(!IsAtCasino(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "You are not in a Casino.");
	if(PlayerInfo[playerid][pLevel] < 3)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You need to be at least level 3+ in order to dice bet.");
	}
	if(sscanf(params, "ui", targetid, amount))
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /dicebet [playerid] [amount]");
	}
    if(!IsPlayerConnected(targetid) || !IsPlayerInRangeOfPlayer(playerid, targetid, 5.0))
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "The player specified is disconnected or out of range.");
	}
	if(targetid == playerid)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You can't use this command on yourself.");
	}
	/*if(PlayerInfo[targetid][pLevel] < 3)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "That player must be at least level 3+ to bet with them.");
	}*/
	if(amount < 1)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "The amount can't be below $1.");
	}
	if(PlayerInfo[playerid][pCash] < amount)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You don't have that much money to bet.");
	}
	if(gettime() - PlayerInfo[playerid][pLastBet] < 10)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You can only use this command every 10 seconds. Please wait %i more seconds.", 10 - (gettime() - PlayerInfo[playerid][pLastBet]));
	}
	if(!PlayerInfo[playerid][pDice])
	{
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You don't have a dice.");
	}
	if(!PlayerInfo[targetid][pDice])
	{
		return SendClientMessageEx(playerid, COLOR_GRAD2, "That player doesn't have a dice.");
	}
	
	PlayerInfo[targetid][pDiceOffer] = playerid;
	PlayerInfo[targetid][pDiceBet] = amount;
	PlayerInfo[targetid][pDiceRigged] = 0;
	PlayerInfo[playerid][pLastBet] = gettime();

	SendClientMessageEx(targetid, COLOR_LIGHTBLUE, "** %s has initiated a dice bet with you for $%i (/acceptdicebet).", GetPlayerNameEx(playerid), amount);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "** You have initiated a dice bet against %s for $%i.", GetPlayerNameEx(targetid), amount);
	return 1;
}

CMD:uldicebet(playerid, params[]) // Added to keep the economy in control. And to make people qq when they lose all their cash.
{
	new targetid, amount;

	if(PlayerInfo[playerid][pAdmin] < 8)
	{
	    return -1;
	}
	if(!IsPlayerInRangeOfPoint(playerid, 100.0,1802.1423,-1593.6298,1215.1792)) return SendClientMessageEx(playerid, COLOR_GREY, "You are not in a Casino.");
	//if(!IsAtCasino(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "You are not in a Casino.");
	/*
	if(!IsPlayerInRangeOfPoint(playerid, 50.0, 1275.71, -963.28, 1084.96))
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You are not in range of the casino.");
	}*/
	if(sscanf(params, "ui", targetid, amount))
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /uldicebet [playerid] [amount]");
	}
    if(!IsPlayerConnected(targetid) || !ProxDetectorS(5.0, playerid, targetid))
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "The player specified is disconnected or out of range.");
	}
	if(targetid == playerid)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You can't use this command on yourself.");
	}
	if(PlayerInfo[targetid][pLevel] < 3)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "That player must be at least level 3+ to bet with them.");
	}
	if(amount < 1)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "The amount can't be below $1.");
	}
	if(PlayerInfo[playerid][pCash] < amount)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You don't have that much money to bet.");
	}
	if(gettime() - PlayerInfo[playerid][pLastBet] < 10)
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "You can only use this command every 10 seconds. Please wait %i more seconds.", 10 - (gettime() - PlayerInfo[playerid][pLastBet]));
	}

	PlayerInfo[targetid][pDiceOffer] = playerid;
	PlayerInfo[targetid][pDiceBet] = amount;
	PlayerInfo[targetid][pDiceRigged] = 1;
	PlayerInfo[playerid][pLastBet] = gettime();

	SendClientMessageEx(targetid, COLOR_LIGHTBLUE, "** %s has initiated a dice bet with you for $%i (/acceptdicebet).", GetPlayerNameEx(playerid), amount);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "** You have initiated a dice bet against %s for $%i.", GetPlayerNameEx(targetid), amount);
	return 1;
}

CMD:acceptdicebet(playerid, params[])
{
		new
			offeredby = PlayerInfo[playerid][pDiceOffer],
			amount = PlayerInfo[playerid][pDiceBet];
			
		szMiscArray[0] = 0;
		
	    if(offeredby == INVALID_PLAYER_ID)
	    {
	        return SendClientMessageEx(playerid, COLOR_GREY, "You haven't received any offers for dice betting.");
	    }
	    if(!ProxDetectorS(5.0, playerid, offeredby))
		{
	        return SendClientMessageEx(playerid, COLOR_GREY, "The player who initiated the offer is out of range.");
	    }
	    if(PlayerInfo[playerid][pCash] < amount)
	    {
	        return SendClientMessageEx(playerid, COLOR_GREY, "You can't afford to accept this bet.");
	    }
	    if(PlayerInfo[offeredby][pCash] < amount)
	    {
	        return SendClientMessageEx(playerid, COLOR_GREY, "That player can't afford to accept this bet.");
	    }

		new
			rand[2];

		if(PlayerInfo[playerid][pDiceRigged])
		{
		    rand[0] = 4 + random(3);
		    rand[1] = random(3) + 1;
		}
		else
		{
			for(new x = 0; x < random(50)*random(50)+30; x++)
			{
				rand[0] = random(6) + 1;
			}
			for(new x = 0; x < random(50)*random(50)+30; x++)
			{
				rand[1] = random(6) + 1;
			}
		}
		format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s rolls a dice that lands on %i on a bet for %s.", GetPlayerNameEx(offeredby), rand[0], number_format(amount));
		ProxDetector(10.0, offeredby, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s rolls a dice that lands on %i on a bet for %s.", GetPlayerNameEx(playerid), rand[1], number_format(amount));
		ProxDetector(10.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		
		
		//SendProximityMessage(offeredby, 20.0, COLOR_WHITE, "** %s rolls a dice which lands on the number %i.", GetPlayerNameEx(offeredby), rand[0]);
		//SendProximityMessage(playerid, 20.0, COLOR_WHITE, "** %s rolls a dice which lands on the number %i.", GetPlayerNameEx(playerid), rand[1]);

		if(rand[0] > rand[1])
		{
           // new tax = (amount / 200) * gTax;
            //AddToTaxVault(tax);
			GivePlayerCashEx(offeredby, TYPE_ONHAND, amount);
		    //GivePlayerCash(offeredby, amount - tax);
			GivePlayerCashEx(playerid, TYPE_ONHAND, -amount);
		    //GivePlayerCash(playerid, -amount);

		    SendClientMessageEx(offeredby, COLOR_LIGHTBLUE, "** You have won %s from your dice bet with %s.", number_format(amount), GetPlayerNameEx(playerid));
		    SendClientMessageEx(playerid, COLOR_RED, "** You have lost %s from your dice bet with %s.", number_format(amount), GetPlayerNameEx(offeredby));
		    //SendClientMessageEx(offeredby, COLOR_GREY, "You paid %s in taxes & fees.", number_format(tax));

			if(amount > 10000 && !strcmp(GetPlayerIpEx(offeredby), GetPlayerIpEx(playerid)))
			{
				format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (IP: %s) won a $%i dice bet against %s (IP: %s).", GetPlayerNameEx(offeredby), GetPlayerIpEx(offeredby), amount, GetPlayerNameEx(playerid), GetPlayerIpEx(playerid));
		        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
			}
			format(szMiscArray, sizeof(szMiscArray), "%s (uid: %i) won a dice bet against %s (uid: %i) for $%i.", GetPlayerNameEx(offeredby), GetPlayerSQLId(offeredby), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), amount);
			Log("logs/dicebet.log", szMiscArray);
		}
		else if(rand[0] == rand[1])
		{
			SendClientMessageEx(offeredby, COLOR_LIGHTBLUE, "** The bet of %s was a tie. You kept your money as a result!", number_format(amount));
		    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "** The bet of %s was a tie. You kept your money as a result!", number_format(amount));
		}
		else
		{
		    //new tax = (amount / 200) * gTax;
      		//AddToTaxVault(tax);
			GivePlayerCashEx(offeredby, TYPE_ONHAND, -amount);
		    //GivePlayerCash(offeredby, -amount);
			GivePlayerCashEx(playerid, TYPE_ONHAND, amount);
		    //GivePlayerCash(playerid, amount - tax);

		    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "** You have won %s from your dice bet with %s.", number_format(amount), GetPlayerNameEx(offeredby));
		    SendClientMessageEx(offeredby, COLOR_RED, "** You have lost %s from your dice bet with %s.", number_format(amount), GetPlayerNameEx(playerid));
		    //SendClientMessageEx(playerid, COLOR_GREY, "You paid %s in taxes & fees.", number_format(tax));

			if(amount > 10000 && !strcmp(GetPlayerIpEx(offeredby), GetPlayerIpEx(playerid)))
			{
				format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (IP: %s) won a $%i dice bet against %s (IP: %s).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), amount, GetPlayerNameEx(offeredby), GetPlayerIpEx(offeredby));
		        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
			}
			format(szMiscArray, sizeof(szMiscArray), "%s (uid: %i) won a dice bet against %s (uid: %i) for $%i.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(offeredby), GetPlayerSQLId(offeredby), amount);
			Log("logs/dicebet.log", szMiscArray);
		}

	    PlayerInfo[playerid][pDiceOffer] = INVALID_PLAYER_ID;
		return 1;
}