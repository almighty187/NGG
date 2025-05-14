/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

				Driving License System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)
	
	Developers:
		(*) Connor
	
	* Copyright (c) 2016, Next Generation Gaming, LLC
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

/*
    MODULE DESCRIPTION:
   		This module will control the driving school (LV), and any other's created afterwards.
        Module created by Connor.
*/
#include <YSI\y_hooks>
#define DIALOG_DSVEH_CAUTION 6941
#define DIALOG_DSVEH_RULES 6942
#define DIALOG_DSVEH_TESTBASE 6943
#define CHECKPOINT_DRIVINGSCHOOL 2539

forward checkTestVehicle(playerid);

new Float:dsPoints[][3] = {
{2084.1846,-1907.4309,13.0498}, // 50 MPH
{2084.0703,-1821.6171,13.0537},
{2137.7366,-1755.3545,13.0638},
{2289.9004,-1735.2811,13.0498},
{2589.9580,-1734.7122,13.0498},
{2645.0168,-1697.5225,10.4014},
{2762.8831,-1659.8486,11.8130},
{2845.6265,-1660.3617,10.3856},
{2881.7700,-1648.7932,10.5497}, // 100 MPH
{2918.7395,-1527.6384,10.5420},
{2920.7546,-1350.5934,10.5420},
{2890.3342,-1104.7865,10.5420},
{2897.6729,-827.7071,10.5421},
{2871.0146,-828.6498,10.5427},
{2867.4016,-979.4488,10.5420},
{2868.8892,-1175.8538,10.5459},
{2904.0886,-1456.5565,10.5420},
{2885.5835,-1559.7946,10.5420},
{2860.5613,-1639.3090,10.5420},
{2793.6809,-1654.9368,10.3689}, // 50 MPH
{2657.7048,-1654.7205,10.3699},
{2631.7339,-1729.7225,10.4650},
{2525.2722,-1754.5414,13.0498},
{2514.4834,-1856.8259,13.0225},
{2501.8081,-1929.6926,13.0097},
{2423.7559,-1929.6270,13.0671},
{2403.0857,-1968.9695,13.0549},
{2296.9937,-1969.3912,13.0778},
{2222.6948,-1969.1936,13.0770},
{2207.0857,-1890.9355,13.2365},
{2131.5068,-1906.9547,13.0498},
{2115.4441,-1937.7872,13.0498},
{2105.3123,-1901.6448,13.0041},
{2057.8728,-1910.4237,13.2139}
};

//player_get_speed
// PVARS: pDTest (Is the player testing), pTestMarker (The marker the player is on),  pTestZone (Roads, Highways), pTestVeh (The vehicle the player is testing with)
new pFindDrive[MAX_PLAYERS];
new pDriveTimer[MAX_PLAYERS];

DrivingTestFinish(playerid)
{
	new pTestVeh = GetPVarInt(playerid, "PTestVeh");
	DestroyVehicle(pTestVeh);
	DeletePVar(playerid, "pTestVeh");
	DeletePVar(playerid, "pDTest");
	DeletePVar(playerid, "pTestMarker");
	DisablePlayerCheckpoint(playerid);
	PlayerInfo[playerid][pCarLic] = gettime() + (86400*80);
	SendClientMessageEx(playerid, COLOR_WHITE, "Driving Instructor: You have successfully completed driving school and earned your license!");
	return 1;
}

DrivingSchoolSpeedMeter(playerid, Float:speed)
{
	new 
		pTestMarker = GetPVarInt(playerid, "pTestMarker"),
		maxspeed = 0; 

	/*if(pTestMarker < 20 || pTestMarker >= 29)
	{
		if(speed > 50)
		{
			SetPlayerCheckpoint(playerid, 814.0655,-600.5410,16.0355, 4.0);
			SendClientMessageEx(playerid, COLOR_GREY, "You have exceeded the resdiental speed limit of 50MPH, you have failed the test.");
			SetPVarInt(playerid, "pDTest", 2);
		}
	}
	else if(speed >= 100)
	{
		SetPlayerCheckpoint(playerid, 814.0655,-600.5410,16.0355, 4.0);
		SendClientMessageEx(playerid, COLOR_GREY, "You have exceeded the freeway speed limit of 100MPH, you have failed the test.");
		SetPVarInt(playerid, "pDTest", 2);
	}*/

	switch(pTestMarker) {
		case 0 .. 7: maxspeed = 50;
		case 8 .. 19: maxspeed = 75;
		case 20 .. 36: maxspeed = 50; 
	}

	if(speed > (maxspeed + 5) && GetPVarInt(playerid, "pDTest") != 2) {
		format(szMiscArray, sizeof(szMiscArray), "You have exceeded the max speed limit of %d MPH.", maxspeed);
		SendClientMessageEx(playerid, COLOR_GREY, szMiscArray);
		SetPlayerCheckpoint(playerid, 1802.5708, -1891.2285, 13.4059, 4.0);
		SetPVarInt(playerid, "pDTest", 2);
	}
	return 1;
}

hook OnGameModeInit()
{
	//CreateDynamicPickup(1239, 1, 1173.0698,1348.4688,10.9219);
	//CreateDynamic3DTextLabel("/drivingtest to begin the driving test.", 0xFF0000FF, 1173.0698,1348.4688,10.9219,4.0);
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(GetPVarType(playerid, "pDTest") > 0)
	{
		new pTestVeh = GetPVarInt(playerid, "pTestVeh");
		if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
		{
			pDriveTimer[playerid] = SetTimerEx("checkTestVehicle", 60000, false, "i", playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, "You have 60 seconds to get back in your vehicle or it will be taken back.");
		}
		else if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == pTestVeh)
		{
			KillTimer(pDriveTimer[playerid]);
		}
	}
	else if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
		if(PlayerInfo[playerid][pCarLic] < gettime())
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "Warning: Your drivers license has expired. Head to the DMV to renew it.");
		}
	}
	return 1;
}

public checkTestVehicle(playerid)
{
	if(GetPVarType(playerid, "pDTest") > 0)
	{
		if(GetPlayerVehicleID(playerid) > 0) return 1;
		new pTestVeh = GetPVarInt(playerid, "PTestVeh");
		DestroyVehicle(pTestVeh);
		DeletePVar(playerid, "pTestVeh");
		DeletePVar(playerid, "pDTest");
		DeletePVar(playerid, "pTestMarker");
		DisablePlayerCheckpoint(playerid);
		SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: You have failed your driving test. , Sender: Driving Instructor (555)");
	}
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if(GetPVarType(playerid, "PTestVeh"))
	{
		new pTestVeh = GetPVarInt(playerid, "PTestVeh");
		DestroyVehicle(pTestVeh);
	}
	pFindDrive[playerid] = 0;
	pDriveTimer[playerid] = 0;
}

hook OnPlayerEnterCheckpoint(playerid){
	if(pFindDrive[playerid] == 1)
	{
		pFindDrive[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
		SendClientMessageEx(playerid, COLOR_GREY, "You have arrived at the driving school!");
	}
	else if(gPlayerCheckpointStatus[playerid] == CHECKPOINT_DRIVINGSCHOOL)
	{
		new pDTest = GetPVarInt(playerid, "pDTest");
		if(pDTest == 1)
		{
			new pTestMarker = GetPVarInt(playerid, "pTestMarker");
			pTestMarker += 1;
			if(pTestMarker >= sizeof(dsPoints)) return DrivingTestFinish(playerid);
			SetPlayerCheckpoint(playerid, dsPoints[pTestMarker][0], dsPoints[pTestMarker][1], dsPoints[pTestMarker][2], 4.0);
			SetPVarInt(playerid, "pTestMarker", pTestMarker);
		}
		else if(pDTest == 2)
		{
			new pTestVeh = GetPVarInt(playerid, "PTestVeh");
			DestroyVehicle(pTestVeh);
			DeletePVar(playerid, "pTestVeh");
			DeletePVar(playerid, "pDTest");
			DeletePVar(playerid, "pTestMarker");
			DisablePlayerCheckpoint(playerid);
		}
	}
	return 1;
}
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_DSVEH_CAUTION:
		{
			if(response)
			{
				//1138.3353,1375.6553,10.4057
				ShowPlayerDialogEx(playerid, 
				DIALOG_DSVEH_RULES,
				DIALOG_STYLE_MSGBOX,
				"Driving Rules", 
				"The rules of the road are as follows..\n1. You must drive on the right side of the road.\n2. You must follow speed limits at all times.\n3. Your seatbelt must be on at all times.\n4. Your vehicle lights must be on at night.\n5. If you get in an accident, you must report it.\n6. You must park correctly at all times.",
				"Next",
				"Cancel");
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "You have cancelled the driving test.");
		}
		case DIALOG_DSVEH_RULES:
		{
			if(response)
			{
				ShowPlayerDialogEx(playerid, 
				DIALOG_DSVEH_TESTBASE,
				DIALOG_STYLE_LIST,
				"{FF0000}If you crash into a vehicle, you must...",
				"Run away\nDrive away\nReport the accident to your insurance and police.", "Choose", "Cancel");
			}
		}
		case DIALOG_DSVEH_TESTBASE:
		{
			if(response)
			{
				if(listitem == 2)
				{
					ShowPlayerDialogEx(playerid, 
					DIALOG_DSVEH_TESTBASE+1,
					DIALOG_STYLE_LIST,
					"{FF0000}You must drive on the LEFT side of the road..",
					"True\nFalse", "Choose", "Cancel");
				}
				else
				{
					return SendClientMessageEx(playerid, COLOR_GREY, "You have failed the test. Incorrect answer.");
				}
			}
		}
		case DIALOG_DSVEH_TESTBASE+1:
		{
			if(response)
			{
				if(listitem == 1)
				{
					ShowPlayerDialogEx(playerid, 
					DIALOG_DSVEH_TESTBASE+2,
					DIALOG_STYLE_LIST,
					"{FF0000}If the speed limit is 50mph, you must go..",
					"650mph\n120mph\n100mph\n50mph\n300mph\n430mph", "Choose", "Cancel");
				}
				else
				{
					return SendClientMessageEx(playerid, COLOR_GREY, "You have failed the test. Incorrect answer.");
				}
			}
		}
		case DIALOG_DSVEH_TESTBASE+2:
		{
			if(response)
			{
				if(listitem == 3)
				{
					ShowPlayerDialogEx(playerid, 
					DIALOG_DSVEH_TESTBASE+3,
					DIALOG_STYLE_LIST,
					"{FF0000}Your seatbelt must always be on.",
					"True\nFalse", "Choose", "Cancel");
				}
				else
				{
					return SendClientMessageEx(playerid, COLOR_GREY, "You have failed the test. Incorrect answer.");
				}
			}
		}
		case DIALOG_DSVEH_TESTBASE+3:
		{
			if(response)
			{
				if(listitem == 0)
				{
					SetPlayerVirtualWorld(playerid, 0);
					SetPlayerInterior(playerid, 0);
					SetPVarInt(playerid, "PTestVeh", CreateVehicle(404, 1802.9083, -1930.9276, 13.3872, 360.0000, 3, 3, -1));
					new pTestVeh = GetPVarInt(playerid, "PTestVeh");
					PutPlayerInVehicle(playerid, pTestVeh, 0);
					SendClientMessageEx(playerid, COLOR_WHITE, "Driving Instructor: Please make sure you go a max of 50mph in the residential areas. You may now begin.");
					if(!PlayerInfo[playerid][pSpeedo])
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "Your speedometer has been enabled for you.");
						PlayerInfo[playerid][pSpeedo] = 1;
						ShowVehicleHUDForPlayer(playerid);
					}
					SetPVarInt(playerid, "PDTest", 1);
					DisablePlayerCheckpoint(playerid);
					SetPlayerCheckpoint(playerid, dsPoints[0][0], dsPoints[0][1], dsPoints[0][2], 4.0);
					SetPVarInt(playerid, "pTestMarker", 0);
					gPlayerCheckpointStatus[playerid] = CHECKPOINT_DRIVINGSCHOOL;
				}
				else
				{
					return SendClientMessageEx(playerid, COLOR_GREY, "You have failed the test. Incorrect answer.");
				}
			}
		}
		
		
	}
	return 0;
}