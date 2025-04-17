/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						FPS Limiter

				Next Generation Gaming
	(created by Next Generation Gaming Development Team)
					
	* Copyright (c) 2025, Next Generation Gaming
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

#define MAX_ALLOWED_FPS 100
#define FPS_CHECK_INTERVAL 6000 // milliseconds
#define FPS_WARNING_LIMIT 3   

new gPlayerFPSWarnings[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
    gPlayerFPSWarnings[playerid] = 0;
    SetTimerEx("FPSCheck", FPS_CHECK_INTERVAL, true, "i", playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
    gPlayerFPSWarnings[playerid] = 0;
    return 1;
}

forward FPSCheck(playerid);
public FPSCheck(playerid) {
    if(!IsPlayerConnected(playerid)) return 0;
    new fps = GetPlayerFPS(playerid);

    if(fps > MAX_ALLOWED_FPS) {
        gPlayerFPSWarnings[playerid]++;
        new msg[128];
        format(msg, sizeof msg, "Your FPS is too high (%d). Turn FPS Limiter on and use /fpslimit 90 or you'll be kicked!", fps);
        SendClientMessage(playerid, COLOR_RED, msg);

        if(gPlayerFPSWarnings[playerid] >= FPS_WARNING_LIMIT) {
            new string[128];
            format(string, sizeof(string), "AdmCmd: %s was kicked by the server, reason: Exceeding FPS limits.", GetPlayerNameEx(playerid));
            SendClientMessageToAllEx(COLOR_LIGHTRED, string);
            SetTimerEx("KickEx", 1000, 0, "i", playerid);
        }
    }
    else {
        gPlayerFPSWarnings[playerid] = 0; 
    }
    return 1;
}
