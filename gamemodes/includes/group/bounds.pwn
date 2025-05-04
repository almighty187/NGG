/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

    	    		  Point Boundaries
    			        by Sixxy

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

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

#include <YSI\y_hooks>



new gangzone; //mp1
new gangzone1;

hook OnGameModeInit()
{
gangzone = GangZoneCreate(1366, -1396.1001586914062, 1452, -1247.1001586914062); // mp1
gangzone1 = GangZoneCreate(1429.9999389648438, -1431.1001586914062, 1451.9999389648438, -1390.1001586914062);
}




CMD:bounds(playerid, params[])
{
    if(PointWarsRadar[playerid] == 0) {
       SendClientMessageEx(playerid, COLOR_WHITE, "Point Boundaries are now visible in Black.");
       GangZoneShowForPlayer(playerid, gangzone, 0x000000000);
	   GangZoneShowForPlayer(playerid, gangzone1, 0x000000000);
	   PointWarsRadar[playerid] = 1;
    }
    else {
         SendClientMessageEx(playerid, COLOR_WHITE, "You will no longer see Point Boundaries");
         GangZoneHideForPlayer(playerid, gangzone);
         GangZoneHideForPlayer(playerid, gangzone1);
         PointWarsRadar[playerid] = 0;
    }
    return 1;
}