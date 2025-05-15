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

/*new gangzone; //mp1
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
}*/

hook OnGameModeInit()
{
	// Pount boundaries with gang zones
	pointboundaries[0] = GangZoneCreate(2545.8984375 ,-2153.3203125, 2707.03125, -2062.5); // Flint Intersection // ffc
	pointboundaries[1] = GangZoneCreate(1361.328125,-1435.546875,1478.515625,-1236.328125); // MP1
	pointboundaries[2] = GangZoneCreate(2077.1484375, -2361.328125, 2285.15625, -2179.6875); // MF1
	pointboundaries[3] = GangZoneCreate(2298.828125,-2064.453125,2546.875,-1935.546875); // MP2
	pointboundaries[4] = GangZoneCreate(2156.25, -1151.3671875, 2320.3125, -1001.953125); // MF2
	pointboundaries[5] = GangZoneCreate(2581.0546875, -2586.9140625, 2862.3046875, -2329.1015625); // Heroin Lab // AEC
	pointboundaries[6] = GangZoneCreate(2105.46875,-1753.90625,2177.734375,-1626.953125); // Drug House
	pointboundaries[7] = GangZoneCreate(2304.6875,-1181.640625,2361.328125,-1160.15625); // Crack Lab
	pointboundaries[8] = GangZoneCreate(13.671875,-402.34375,167.96875,-208.984375); // Montgomery Materials // Drug Factory
}

CMD:pbounds(playerid, params[])
{
	if(isnull(params))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "USAGE: /pbounds [point]");
		SendClientMessageEx(playerid, COLOR_WHITE, "HINT: This will indicate the point boundaries for a point.");
		SendClientMessageEx(playerid, COLOR_GRAD3, "Points: FLINT (Flint Intersection) | MP1 (Materials Pickup 1) | Montgomery (Montgomery Materials)");
		SendClientMessageEx(playerid, COLOR_GRAD3, "Points: MF1 (Materials Factory 1) | DH (Drug House) | MP2 (Materials Pickup 2)");
		SendClientMessageEx(playerid, COLOR_GRAD3, "Points: CL (Crack Lab) | MF2 (Materials Factory 2) | HL50 is f (Heroin Lab)");
		return true;
	}

	if(strcmp(params,"flint",true) == 0)
	{
	    if(IsBoundsShowingFFC[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[0], 0xFF00008C); // FFC
			IsBoundsShowingFFC[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Flint Intersection are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[0]); // FFC
			IsBoundsShowingFFC[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Flint Intersection are now removed from your radar and map.");
		}
	}
	else if(strcmp(params,"mp1",true) == 0)
	{
	    if(IsBoundsShowingMP1[playerid] == 0)
		{
			GangZoneShowForPlayer(playerid, pointboundaries[1], 0xFF00008C); // MP1
			IsBoundsShowingMP1[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Pickup 1 are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[1]); // MP1
			IsBoundsShowingMP1[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Pickup 1 are now removed from your radar and map.");
		}
	}
	else if(strcmp(params,"montgomery",true) == 0)
	{
	    if(IsBoundsShowingDF[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[8], 0xFF00008C); // Montgomery Materials
			IsBoundsShowingDF[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Montgomery Materials are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[8]); // Montgomery Materials
			IsBoundsShowingDF[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Montgomery Materials are now removed from your radar and map.");
		}
	}
	else if(strcmp(params,"mf1",true) == 0)
	{
	    if(IsBoundsShowingMF1[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[2], 0xFF00008C); // MF1
			IsBoundsShowingMF1[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Factory 1 are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[2]); // MF1
			IsBoundsShowingMF1[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Factory 1 are now removed from your radar and map.");
		}
	}
	else if(strcmp(params,"dh",true) == 0)
	{
	    if(IsBoundsShowingDH[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[6], 0xFF00008C); // DH
			IsBoundsShowingDH[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Drug House are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[6]); // DH
			IsBoundsShowingDH[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Drug House are now removed from your radar and map.");
		}
	}
	else if(strcmp(params,"mp2",true) == 0)
	{
	    if(IsBoundsShowingMP2[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[3], 0xFF00008C); // MP2
			IsBoundsShowingMP2[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Pickup 2 are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[3]); // MP2
			IsBoundsShowingMP2[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Pickup 2 are now from your radar and map.");
		}
	}
	else if(strcmp(params,"cl",true) == 0)
	{
	    if(IsBoundsShowingCL[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[7], 0xFF00008C); // CL
			IsBoundsShowingCL[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Crack Lab are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[7]); // CL
			IsBoundsShowingCL[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Crack Lab are now removed from your radar and map.");
		}
	}
	else if(strcmp(params,"mf2",true) == 0)
	{
	    if(IsBoundsShowingMF2[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[4], 0xFF00008C); // MF2
			IsBoundsShowingMF2[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Factory 2 are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[4]); // MF2
			IsBoundsShowingMF2[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Materials Factory 2 are now indicated on your radar and map in red.");
		}
	}
	else if(strcmp(params,"hl",true) == 0)
	{
	    if(IsBoundsShowingAEC[playerid] == 0)
	    {
			GangZoneShowForPlayer(playerid, pointboundaries[5], 0xFF00008C); // Heroin Lab
			IsBoundsShowingAEC[playerid] = 1;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Heroin Lab are now indicated on your radar and map in red.");
		}
		else
		{
			GangZoneHideForPlayer(playerid, pointboundaries[5]); // Heroin Lab
			IsBoundsShowingAEC[playerid] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "The point boundaries for Heroin Lab are now removed from your radar and map");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Invalid point entered.");
		SendClientMessageEx(playerid, COLOR_WHITE, "USAGE: /pbounds [point]");
		SendClientMessageEx(playerid, COLOR_WHITE, "HINT: This will indicate the point boundaries for a point.");
		SendClientMessageEx(playerid, COLOR_GRAD3, "Points: FLINT (Flint Intersection) | MP1 (Materials Pickup 1) | Montgomery (Montgomery Materials)");
		SendClientMessageEx(playerid, COLOR_GRAD3, "Points: MF1 (Materials Factory 1) | DH (Drug House) | MP2 (Materials Pickup 2)");
		SendClientMessageEx(playerid, COLOR_GRAD3, "Points: CL (Crack Lab) | MF2 (Materials Factory 2) | HL (Heroin Lab)");
	}
	return true;
}

CMD:pboundsoff(playerid, params[])
{
	GangZoneHideForPlayer(playerid, pointboundaries[0]); // FLINT // FFC
	GangZoneHideForPlayer(playerid, pointboundaries[1]); // MP1
	GangZoneHideForPlayer(playerid, pointboundaries[2]); // MF1
	GangZoneHideForPlayer(playerid, pointboundaries[3]); // MP2
	GangZoneHideForPlayer(playerid, pointboundaries[4]); // MF2
	GangZoneHideForPlayer(playerid, pointboundaries[5]); // MONTGOMERY // AEC
	GangZoneHideForPlayer(playerid, pointboundaries[6]); // DH
	GangZoneHideForPlayer(playerid, pointboundaries[7]); // CL
	GangZoneHideForPlayer(playerid, pointboundaries[8]); // HL // DF
	IsBoundsShowingFFC[playerid] = 0;
	IsBoundsShowingMP1[playerid] = 0;
	IsBoundsShowingMF1[playerid] = 0;
	IsBoundsShowingMP2[playerid] = 0;
	IsBoundsShowingMF2[playerid] = 0;
	IsBoundsShowingAEC[playerid] = 0;
	IsBoundsShowingDH[playerid] = 0;
	IsBoundsShowingCL[playerid] = 0;
	IsBoundsShowingDF[playerid] = 0;
 	SendClientMessageEx(playerid, COLOR_WHITE, "All point boundaries removed from your radar and map.");
	return true;
}
