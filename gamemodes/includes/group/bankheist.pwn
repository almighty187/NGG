/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Bank Heist

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)
	(written by Sixxy)
					
	* Copyright (c) 2025, Next Generation Gaming, LLC
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

#include <YSI\y_hooks>

/* =================================================================================================================== */

new Float:bhv_vehicleLocation[1][4] = {
	{849.3085,-1174.9198,17.1008,179.7342}
};

new bhv_vehicleModel[1][1] = {
	{428}
};

new Float:bhv_actorLocation[1][4] = {
	{843.1835,-1176.2443,16.9835,271.3652}
};

new bhv_actorModel[1][1] = {
	{3}
};

new Float:bhv_depositboxLocations[8][3] = {
	{2143.0930,1629.2393,993.5761},
	{2143.1157,1633.1951,993.5761},
	{2143.0806,1637.0497,993.5761},
	{2143.0806,1641.1576,993.5761},
	{2145.3164,1641.2104,993.5761},
	{2145.2939,1637.3042,993.5761},
	{2145.2939,1633.1935,993.5761},
	{2145.2900,1629.3894,993.5761}
};

/*
	[0] heistCooldown
	... [0] Ready
	... [1] Cooling
	[1] heistGroup
	[3] heistActive
	[4] heistStage
	... [0] orderVehicle
	... [1] pickupVehicle
	... [2] goingBank
	... [3] arrivedBank
	... [4] insideBank
	... [5] breakingVault
	... [6] stealingDeposits
	... [7] enterVehicle
	... [8] escapeLEO
	... [9] dropoffVehicle
	[5] stageNotified
	... [0] No
	... [1] Yes
	[6] stageCooldown
	[7] heistVehicle
	[8] vehicleEntered
	[9] criminalsNotified
    [10] crackingSafe
	[11] safeCracked
	[12] safeObjectID
	[13] safeAutoShut
	[14] safeShut
	[15] safeDoor
	... [0] Open
	... [1] Closed
    [16] heistScore
	... $ Value
	[17] mainPlayerID
	... Primary player who started the heist.
	... This is used for arrest checks etc.
*/

new bhv_heistMain[18];
new bhv_depositBoxes[sizeof(bhv_depositboxLocations)];

/* Attributes: Labels */
new Text3D: l_depositboxLabels[MAX_VEHICLES];

/* Actors */
new heistActor[sizeof(bhv_actorModel)];

/* =================================================================================================================== */

hook OnGameModeInit() {
	new v_string[256];
	
	bhv_heistMain[0] = 1; // heistCooldown
	bhv_heistMain[17] = -1; // mainPlayerID
	
	for(new i = 0; i < sizeof(bhv_depositboxLocations); i++) {
		bhv_depositBoxes[i] = 0;
		 
	    format(v_string, sizeof(v_string), "{FFFF00}Deposit Box\n{FFFFFF}$%s", number_format(bhv_depositBoxes[i]));
		l_depositboxLabels[i] = CreateDynamic3DTextLabel(v_string, COLOR_WHITE, bhv_depositboxLocations[i][0], bhv_depositboxLocations[i][1], bhv_depositboxLocations[i][2] + 1.0, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);
		CreatePickup(1274, 23, bhv_depositboxLocations[i][0], bhv_depositboxLocations[i][1], bhv_depositboxLocations[i][2], -1);
	}
	
	/* Heist Actor */
	createHeistActors();
	
	/* Heist Door */
	bhv_heistMain[12] = CreateDynamicObject(19799, 2143.19336, 1626.69128, 994.25348,   0.00000, 0.00000, 180.00000);
	bhv_heistMain[15] = 1;
	
	/* Freezer Door */
	CreateDynamicObject(2963, 2144.29517, 1606.80042, 994.65112,   0.00000, 0.00000, 270.00000);
	
	/* Keypad */
	CreateDynamicObject(2922, 2142.21777, 1626.86560, 994.22504,   0.00000, 0.00000, -180.00000);
}

/* =================================================================================================================== */
/* OnPlayerEnterVehicle Hook */
/* =================================================================================================================== */

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if(bhv_heistMain[3]) {
		if(bhv_heistMain[4] == 1) {
			if(vehicleid == bhv_heistMain[7]) {
				if(PlayerInfo[playerid][pMember] != bhv_heistMain[1]) {
					// Eject the player.
					RemovePlayerFromVehicle(playerid);
					
					// Boot them properly.
					new Float:x, Float:y, Float:z;
					GetPlayerPos(playerid, x, y, z);
					SetPlayerPos(playerid, x, y + 3, z + 1);
					
					SendClientMessageEx(playerid, COLOR_GREY, "You cannot use this vehicle.");
					return 1;
				}
				bhv_heistMain[8] = 1;
			}
		}
	}
	return 1;
}

/* =================================================================================================================== */

stock createHeistActors() {
	new v_string[256];
	
	for(new i = 0; i < sizeof(bhv_actorModel); i++) {
		format(v_string, sizeof(v_string), "{AFAFAF}Press {FFFFFF}Y {AFAFAF}to chat");
		CreateDynamic3DTextLabel(v_string, COLOR_WHITE, bhv_actorLocation[i][0], bhv_actorLocation[i][1], bhv_actorLocation[i][2] + 0.5, 20.0);
		
		heistActor[i] = CreateActor(bhv_actorModel[i][0], bhv_actorLocation[i][0], bhv_actorLocation[i][1], bhv_actorLocation[i][2], bhv_actorLocation[i][3]); 
		ApplyActorAnimation(heistActor[i], "DEALER", "DEALER_IDLE", 4.1, 1, 0, 0, 1, 0);
	}
}

/* ======================================================================================================================================= */

stock isNearHeistActor(playerid) {
    for(new i = 0; i < sizeof(bhv_actorLocation); i++) {
	    if(IsPlayerInRangeOfPoint(playerid, 8.0, bhv_actorLocation[i][0], bhv_actorLocation[i][1], bhv_actorLocation[i][2])) {
		    return 1;
		}
	}
	return 0;
}

/* ======================================================================================================================================= */

stock isNearSafeKeypad(playerid) {
    for(new i = 0; i < sizeof(bhv_actorLocation); i++) {
	    if(IsPlayerInRangeOfPoint(playerid, 8.0, 2142.21777, 1626.86560, 994.22504)) {
		    return 1;
		}
	}
	return 0;
}

/* =================================================================================================================== */
/* OnObjectMoved Hook */
/* =================================================================================================================== */

hook OnDynamicObjectMoved(objectid) {
	if(objectid == bhv_heistMain[12] && bhv_heistMain[10] && !bhv_heistMain[11] && bhv_heistMain[3]) {
		bhv_heistMain[10] = 0; // crackingSafe
	    bhv_heistMain[11] = 1; // safeCracked
		bhv_heistMain[5] = 1; // stageNotified
		bhv_heistMain[13] = (gettime() + 30); // safeAutoShut
		sendLesterSMSMessage("You have 30 seconds before the auto-lock system engages");
	}
}

/* =================================================================================================================== */
/* OnPlayerKeyStateChange Hook */
/* =================================================================================================================== */

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_YES) {
		if(isNearHeistActor(playerid)) {
			if(!IsACriminal(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "{FFFFFF}Lester says:{AFAFAF} I don't talk to narks, come back when you're serious.");
			if(bhv_heistMain[3]) return SendClientMessageEx(playerid, COLOR_GREY, "{FFFFFF}Lester says:{AFAFAF} There's already an active job right now, come back later.");
			if(bhv_heistMain[0]) return SendClientMessageEx(playerid, COLOR_GREY, "{FFFFFF}Lester says:{AFAFAF} We're not ready yet, come back later.");
			if(GetPlayerCash(playerid) < 50000) return SendClientMessageEx(playerid, COLOR_GREY, "{FFFFFF}Lester says:{AFAFAF} You at least $50,000 to get started, come back later.");
			
			bhv_heistMain[3] = 1; // heistActive
			bhv_heistMain[0] = 1; // heistCooldown
			bhv_heistMain[1] = PlayerInfo[playerid][pMember]; // heistGroup
			bhv_heistMain[4] = 0; // heistStage
			bhv_heistMain[5] = 0; // stageNotified
			
			// Deduct the starting cash.
			GivePlayerCash(playerid, -50000);
			
			bhv_heistMain[17] = playerid;
			
			return SendClientMessageEx(playerid, COLOR_GREY, "{FFFFFF}Lester says:{AFAFAF} You'll be contacted shortly.");
		}
		else if(isNearSafeKeypad(playerid)) {
			if(IsDynamicObjectMoving(bhv_heistMain[12])) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait until the safe door has stopped moving.");
			
			if(IsACriminal(playerid) && PlayerInfo[playerid][pMember] == bhv_heistMain[1]) {
				if(!bhv_heistMain[15]) return SendClientMessageEx(playerid, COLOR_GREY, "The safe door is not closed.");
				if(bhv_heistMain[14]) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot open the safe door now that it has been auto-shut.");
				
				if(!bhv_heistMain[10] && !bhv_heistMain[11]) {
					bhv_heistMain[10] = 1; // crackingSafe
					MoveDynamicObject(bhv_heistMain[12], 2145.19092, 1626.69910, 994.25348, 0.1, 0.00000, 0.00000, 180.00000);
				}
			}
			if(IsACop(playerid)) {
				if(bhv_heistMain[3]) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot trigger the safe door right now.");
				
				new v_string[256];
				
				if(bhv_heistMain[15]) {
					MoveDynamicObject(bhv_heistMain[12], 2145.19092, 1626.69910, 994.25348, 0.1, 0.00000, 0.00000, 180.00000);
					bhv_heistMain[15] = 0;
					
					format(v_string, sizeof(v_string), "* %s has used their remote to open the safe door.", GetPlayerNameEx(playerid));
					ProxDetector(30.0, playerid, v_string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
				else {
					MoveDynamicObject(bhv_heistMain[12], 2143.19336, 1626.69128, 994.25348, 0.1, 0.00000, 0.00000, 180.00000);
					bhv_heistMain[15] = 1;
					
					format(v_string, sizeof(v_string), "* %s has used their remote to close the safe door.", GetPlayerNameEx(playerid));
					ProxDetector(30.0, playerid, v_string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
			}
		}
	}
	return 1;
}

/* =================================================================================================================== */

task heistActorCheck[10000]() {
	for(new i = 0; i < sizeof(bhv_actorModel); i++) {
		new Float:aPos[3];
		
		GetActorPos(heistActor[i], aPos[0], aPos[1], aPos[2]);
		
		if(aPos[0] != bhv_actorLocation[i][0] || aPos[1] != bhv_actorLocation[i][1] || aPos[2] != bhv_actorLocation[i][2]) {
			DestroyActor(heistActor[i]);
			heistActor[i] = CreateActor(bhv_actorModel[i][0], bhv_actorLocation[i][0], bhv_actorLocation[i][1], bhv_actorLocation[i][2], bhv_actorLocation[i][3]); 
			ApplyActorAnimation(heistActor[i], "DEALER", "DEALER_IDLE", 4.1, 1, 0, 0, 1, 0);
		}
	}
}

/* =================================================================================================================== */
/* OnPlayerDisconnect Hook */
/* =================================================================================================================== */

hook OnPlayerDisconnect(playerid, reason) {
}

/* =================================================================================================================== */
/* OnPlayerConnect Hook */
/* =================================================================================================================== */

hook OnPlayerConnect(playerid) {
}

/* =================================================================================================================== */

stock increaseDeposits() {
	if(!bhv_heistMain[0]) return;
	
	for(new i = 0; i < sizeof(bhv_depositboxLocations); i++) {
		if(bhv_depositBoxes[i] == 31250) {
			if(bhv_heistMain[9] == 0) {
				sendCriminalMessage("I got word on a possible bank job - come see me");
				sendCriminalMessage("... make sure to bring at least $50,000 for the setup costs");
				bhv_heistMain[9] = 1;
				bhv_heistMain[0] = 0;
			}
			break;
		}
			
		bhv_depositBoxes[i] += 6250;
		 
		new v_string[256];
	    format(v_string, sizeof(v_string), "{FFFF00}Deposit Box\n{FFFFFF}$%s", number_format(bhv_depositBoxes[i]));
		UpdateDynamic3DTextLabelText(l_depositboxLabels[i], COLOR_WHITE, v_string);
	}
}

/* =================================================================================================================== */

task depositboxTick[3600000]() {
	increaseDeposits();
}

/* ======================================================================================================================================= */

CMD:bdbincrease(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] >= 99998) {
		if(!bhv_heistMain[0]) return SendClientMessageEx(playerid, COLOR_GRAD2, "The heist is now pending a group to enable it.");
		
        increaseDeposits();
		
		if(!bhv_heistMain[0]) return SendClientMessageEx(playerid, COLOR_GRAD2, "The heist is now pending a group to enable it.");
		
		new string[128];
		format(string, sizeof(string), "AdmCmd: %s has forced a bank deposit box increase", GetPlayerNameEx(playerid));
		ABroadCast(COLOR_LIGHTRED, string, 2);
    } 
	else {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You aren't authorized to use this command!");
    }
    return 1;
}

/*
	[0] heistCooldown
	... [0] Ready
	... [1] Cooling
	[1] heistGroup
	[3] heistActive
	[4] heistStage
	... [0] orderVehicle
	... [1] pickupVehicle
	... [2] goingBank
	... [3] arrivedBank
	... [4] insideBank
	... [5] breakingVault
	... [6] stealingDeposits
	... [7] enterVehicle
	... [8] escapeLEO
	... [9] dropoffVehicle
	[5] stageNotified
	... [0] No
	... [1] Yes
	[6] stageCooldown
	[7] heistVehicle
	[8] vehicleEntered
	[9] criminalsNotified
    [10] crackingSafe
	[11] safeCracked
	[12] safeObjectID
	[13] safeAutoShut
	[14] safeShut
	[15] safeDoor
	... [0] Open
	... [1] Closed
    [16] heistScore
	... $ Value
	[17] mainPlayerID
	... Primary player who started the heist.
	... This is used for arrest checks etc.
*/

/* =================================================================================================================== */

stock terminateHeist() {
	sendLesterSMSMessage("The heist is off - something went wrong.");
	
	bhv_heistMain[0] = 1; // heistCooldown
	bhv_heistMain[1] = -1; // heistGroup
	bhv_heistMain[3] = 0; // heistActive
	bhv_heistMain[4] = 0; // heistStage
	bhv_heistMain[5] = 0; // stageNotified
	bhv_heistMain[6] = 0; // stageCooldown
	
	if(bhv_heistMain[7] != INVALID_VEHICLE_ID) {
		Internal_DestroyVehicle(bhv_heistMain[7]);
		bhv_heistMain[7] = INVALID_VEHICLE_ID; // heistVehicle
	}
	
	bhv_heistMain[8] = 0; // vehicleEntered
	bhv_heistMain[9] = 0; // criminalsNotified
	bhv_heistMain[10] = 0; // crackingSafe
	bhv_heistMain[11] = 0; // safeCracked
	bhv_heistMain[13] = 0; // safeAutoShut
	bhv_heistMain[14] = 0; // safeShut
	bhv_heistMain[16] = 0; //  heistScore
	bhv_heistMain[17] = INVALID_PLAYER_ID; //  mainPlayerID
}

/* =================================================================================================================== */

task heistTick[5000]() {
	// Check if the heist is active.
	if(bhv_heistMain[3]) {
		// Check if our primary heister is in trouble.
		if(PlayerTied[bhv_heistMain[17]] != 0 || GetPVarType(bhv_heistMain[17], "PlayerCuffed") || GetPVarType(bhv_heistMain[17], "Injured") || GetPVarType(bhv_heistMain[17], "IsFrozen") || PlayerInfo[bhv_heistMain[17]][pHospital] || PlayerInfo[bhv_heistMain[17]][pJailTime] > 0) {
			terminateHeist();
		}
	}
	
	// Check if the heist is active.
	if(bhv_heistMain[3]) {
		// safeAutoShut
		if(gettime() > bhv_heistMain[13] && bhv_heistMain[13] != 0) {
			sendLesterSMSMessage("THE AUTO-LOCK SYSTEM HAS BEEN ENGAGED - GET OUT OF THE SAFE NOW");
			MoveDynamicObject(bhv_heistMain[12], 2143.19336, 1626.69128, 994.25348, 0.1, 0.00000, 0.00000, 180.00000);
			bhv_heistMain[13] = 0;
			bhv_heistMain[14] = 1;
		}
		// Stage: orderVehicle
		if(bhv_heistMain[4] == 0) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("I'll let you know when the vehicle is ready");
				bhv_heistMain[5] = 1;
				bhv_heistMain[6] = gettime() + 10; // defaultTime: 600
			}
			// stageNotified: Yes
			else {
				// Check if the cooldown has been reached to pickup the vehicle.
				if(gettime() > bhv_heistMain[6]) {
					bhv_heistMain[4] = 1;
					bhv_heistMain[5] = 0;
				}
			}
		}
		// Stage: pickupVehicle
		else if(bhv_heistMain[4] == 1) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("The vehicle is good to go - come back");
				bhv_heistMain[5] = 1;
				
				// Create the heist vehicle.
				bhv_heistMain[7] = Internal_CreateVehicle(bhv_vehicleModel[0][0], bhv_vehicleLocation[0][0], bhv_vehicleLocation[0][1], bhv_vehicleLocation[0][2], bhv_vehicleLocation[0][3], 23, 23, -1);
				SetVehicleHealth(bhv_heistMain[7], 10000);
			}
			// stageNotified: Yes
			else {
				// They have entered the vehicle.
				if(bhv_heistMain[8]) {
					bhv_heistMain[4] = 2;
					bhv_heistMain[5] = 0;
				}
			}
		}
		// Stage: goingBank
		else if(bhv_heistMain[4] == 2) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("We upgraded the armor, she's slow but she's strong - good luck");
				sendLesterSMSMessage("Head to the Mulholland Bank - be descrete and don't draw attention");
				bhv_heistMain[5] = 1;
			}
			// stageNotified: Yes
			else {
				foreach(new i: Player) {
					if(PlayerInfo[i][pMember] == bhv_heistMain[1]) {
						if(IsPlayerInRangeOfPoint(i, 30.0, 1462.1510,-1033.9423,23.6616)) {
							bhv_heistMain[4] = 3;
							bhv_heistMain[5] = 0;
							break;
						}
					}
				}
			}
		}
		// Stage: arrivedBank
		else if(bhv_heistMain[4] == 3) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("Get out of the car and get in to the bank");
				sendLesterSMSMessage("Hide the car or have one of you stay as the driver and lookout");
				bhv_heistMain[5] = 1;
			}
			// stageNotified: Yes
			else {
				foreach(new i: Player) {
					if(PlayerInfo[i][pMember] == bhv_heistMain[1]) {
						if(IsPlayerInRangeOfPoint(i, 30.0, 2310.0447,-15.0340,26.7422)) {
							bhv_heistMain[4] = 4;
							bhv_heistMain[5] = 0;
							break;
						}
					}
				}
			}
		}
		// Stage: insideBank
		else if(bhv_heistMain[4] == 4) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("Get to the vault - there's not much time before the cops arrive");
				bhv_heistMain[5] = 1;
			}
			// stageNotified: Yes
			else {
				foreach(new i: Player) {
					if(PlayerInfo[i][pMember] == bhv_heistMain[1]) {
						if(IsPlayerInRangeOfPoint(i, 30.0, 2144.2607,1618.2844,993.6882)) {
							bhv_heistMain[4] = 5;
							bhv_heistMain[5] = 0;
							break;
						}
					}
				}
			}
		}
		// Stage: breakingVault
		else if(bhv_heistMain[4] == 5) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("That's a sechGroupe 9000 - they're not easy to crack");
				
				if(bhv_heistMain[15]) {
					sendLesterSMSMessage("There should be a keypad next to it. Interact with it and I'll guide you");
					bhv_heistMain[5] = 1;
				}
				else {
					sendLesterSMSMessage("But it looks like the door was left open! - Just our luck");
					bhv_heistMain[4] = 6;
					bhv_heistMain[5] = 0;
				}
			}
			// stageNotified: Yes
			else {
				if(bhv_heistMain[11]) {
					sendLesterSMSMessage("YEEEEEEEES! You got it! Yeee-hah!");
					bhv_heistMain[4] = 6;
					bhv_heistMain[5] = 0;
				}
			}
		}
		// Stage: stealingDeposits
		else if(bhv_heistMain[4] == 6) {
			// stageNotified: No
			if(bhv_heistMain[5] == 0) {
				sendLesterSMSMessage("Get in there and get the cash - quick");
				sendLesterSMSMessage("You can use {FFFFFF}/heist steal{AFAFAF} to take the cash");
				sendLesterSMSMessage("When you're done get back in the vehicle for the next instructions");
				bhv_heistMain[5] = 1;
			}
			// stageNotified: Yes
			else {
			}
		}
	}
}

/* ======================================================================================================================================= */

CMD:heist(playerid, params[]) {
    new s_params[256];
	
	if(sscanf(params, "s[60]", s_params)) {
		SendClientMessage(playerid, COLOR_GREY, "USAGE: /heist [option]");
		SendClientMessage(playerid, COLOR_GRAD4, "Option(s): {FFFFFF}steal");
		return 1;
	}
	
	if(strcmp(s_params, "steal", true) == 0) {
		return 1;
	}
	SendClientMessage(playerid, COLOR_GREY, "That is not a valid choice.");
	return 1;
}

/* =================================================================================================================== */

stock sendLesterMessage(heistMessage[]) {
	foreach(new i: Player) {
		if(PlayerInfo[i][pMember] == bhv_heistMain[1]) {
			SendClientMessageEx(i, COLOR_GRAY, "{FFFFFF}Lester says: {AFAFAF}%s", heistMessage);
		}
	}
}

/* =================================================================================================================== */

stock sendLesterSMSMessage(heistMessage[]) {
	foreach(new i: Player) {
		if(PlayerInfo[i][pMember] == bhv_heistMain[1]) {
			SendClientMessageEx(i, COLOR_YELLOW, "SMS: %s, Sender: Lester (555)", heistMessage);
		}
	}
}

/* =================================================================================================================== */

stock sendHeistMessage(heistMessage[]) {
	foreach(new i: Player) {
		if(PlayerInfo[i][pMember] == bhv_heistMain[1]) {
			SendClientMessageEx(i, COLOR_YELLOW, "SMS: %s, Sender: MOLE (555)", heistMessage);
		}
	}
}

/* =================================================================================================================== */

stock sendCriminalMessage(heistMessage[]) {
	foreach(new i: Player) {
		if(IsACriminal(i)) {
			SendClientMessageEx(i, COLOR_YELLOW, "SMS: %s, Sender: MOLE (555)", heistMessage);
		}
	}
}

/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */
/* ======================================================================================================================================= */