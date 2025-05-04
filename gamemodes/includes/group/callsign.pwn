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
		
	* Copyright (c) 20202025, Next Generation Gaming, LLC
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

new Text3D:veh3Dtext[MAX_DYNAMIC_VEHICLES];
new vehcallsign[MAX_DYNAMIC_VEHICLES];

stock IsACruiser(vehicleid)
{
	switch (GetVehicleModel(vehicleid)) {
	    case 427, 490, 523, 528, 596, 597, 598, 599, 601: return 1;
	}
	return 0;
}

hook OnVehicleDeath(vehicleid, killerid) 
{
	if(vehcallsign[vehicleid] == 1)
	{
 		Delete3DTextLabel(veh3Dtext[vehicleid]);
	    vehcallsign[vehicleid] = 0;
	    return 1;
	}
	
	return 1;
}

CMD:callsign(playerid, params[])
{
    new vehicleid;
    vehicleid = GetPlayerVehicleID(playerid);
	new string[32];

	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "You are not in a vehicle.");
	if(!IsACop(playerid) && !IsAGovernment(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "You are not a law enforcement officer.");
	if (!IsACruiser(GetPlayerVehicleID(playerid))) return SendClientMessageEx(playerid, COLOR_WHITE, "You are not in a patrol vehicle.");

	if(vehcallsign[GetPlayerVehicleID(playerid)] == 1)
	{
 		Delete3DTextLabel(veh3Dtext[vehicleid]);
	    vehcallsign[vehicleid] = 0;
	    SendClientMessageEx(playerid, COLOR_WHITE, "Callsign removed.");
	    return 1;
	}
	if(sscanf(params, "s[32]",string)) return SendClientMessageEx(playerid, COLOR_GREY, "You need to enter a callsign.");
	if(vehcallsign[GetPlayerVehicleID(playerid)] == 0)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Callsign added to vehicle!");
		SendClientMessageEx(playerid, COLOR_WHITE, "If you abuse this system it will be removed and you will face a faction ban.");
		veh3Dtext[vehicleid] = Create3DTextLabel(string, COLOR_callsign, 0.0, 0.0, 0.0, 10.0, 0, 1);
		Attach3DTextLabelToVehicle(veh3Dtext[vehicleid], vehicleid, 0.0, -2.8, 0.0);
		vehcallsign[vehicleid] = 1;
	}
	return 1;
}
