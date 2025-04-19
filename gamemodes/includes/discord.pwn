/*
    	 		 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
				| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
				| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
				| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
				| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
				| $$\  $$$| $$  \ $$        | $$  \ $$| $$
				| $$ \  $$|  $$$$$$/        | $$  | $$| $$
				|__/  \__/ \______/         |__/  |__/|__/

//--------------------------------[DISCORD.PWN]--------------------------------


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

//--------------------------------[ INITIATE/EXIT ]---------------------------


stock SendDiscordMessage(channel, message[]) {
    if(!discord) return 1;
    new DCC_Channel:ChannelId;
    switch (channel) {
        // admin-chat
        case 0:{
            ChannelId = DCC_FindChannelById("1360504707851747429");
            DCC_SendChannelMessage(ChannelId, message);
        }
        // admin-warnings
        case 1:{
            ChannelId = DCC_FindChannelById("1360504741741990029");
            DCC_SendChannelMessage(ChannelId, message);
        }
        // Head Admin
        case 2:{
            ChannelId = DCC_FindChannelById("1360504760041476217");
            DCC_SendChannelMessage(ChannelId, message);
        }
        // #server-errors
        case 3:{
            ChannelId = DCC_FindChannelById("1360504778718711870");
            DCC_SendChannelMessage(ChannelId, message);
        }
        //point timer stuff
        case 4:{
            ChannelId = DCC_FindChannelById("1360504778718711870");
            DCC_SendChannelMessage(ChannelId, message);
        }
    }
    return 1;
}

hook DCC_OnMessageCreate(DCC_Message:message) {
    new DCC_Channel:channel;
    new DCC_User:author;

    new channel_name[32], name[46], szMessage[128], msgContent[128];
    DCC_GetChannelName(channel, channel_name);
    DCC_GetUserName(author, name);
    DCC_GetMessageContent(message, msgContent);

    if(strfind(msgContent, "!", true) != -1) {
        new string[256];
        new DCC_Channel:logChannel = DCC_FindChannelByName("discord-cmd-logs");
        format(string, sizeof(string), "%s has executed the following command with args: %s", name, msgContent);
        DCC_SendChannelMessage(logChannel, string);
    }

    if(!discord) return 1;
    if(!author) return 1;

    if(!strcmp(channel_name, "admin-chat", true) && strcmp(name, "NGRP-Bot", true)) {
        format(szMessage, sizeof(szMessage), "* [Discord] %s: %s", name, msgContent);
        ABroadCast(COLOR_YELLOW, szMessage, 2);
    }

    return 1;
}
forward OnDCCommandPerformed(args[], success);
public OnDCCommandPerformed(args[], success) {
    new DCC_Channel:channel = DCC_FindChannelByName("NGRP-Bot");
    if(!success) return DCC_SendChannelMessage(channel, "```js\nInvalid command..!\n```");

    return 1;
}

DC_CMD:help(user[], args[]) {
    new DCC_Channel:channel = DCC_FindChannelByName("NGRP-Bot");
    new string[256];
    format(string, sizeof(string), "Available Help Cmds: ```- !players - lists players ig \n- !wip - whitelists an admin.\n- !adminsig - lists all admins ingame. \n- !pwip - whitelists a proxy```");
    DCC_SendChannelMessage(channel, string);
    return 1;
}

DC_CMD:players(user[], args[]) {
    new DCC_Channel:channel = DCC_FindChannelByName("NGRP-Bot");
    new count;
    for (new x = 0; x < MAX_PLAYERS; x++) { //x = MAX_PLAYERS
        if(IsPlayerConnected(x)) {
            count++;
        }
    }
    new string[128];
    format(string, sizeof(string), "%d/500 Players.", count);
    DCC_SendChannelMessage(channel, string);
    return 1;
}

DC_CMD:wip(user, args) {
    new DCC_Channel:channel = DCC_FindChannelByName("NGRP-Bot");

    new string[128], query[256], giveplayer[MAX_PLAYER_NAME], ip[16];
    if(sscanf(args, "s[24]s[16]", giveplayer, ip)) {
        DCC_SendChannelMessage(channel, "USAGE: !wip [admin name] [IP]");
        return 1;
    }

    new tmpName[24], tmpIP[16];
    mysql_escape_string(giveplayer, tmpName);
    mysql_escape_string(ip, tmpIP);

    mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `SecureIP`='%s' WHERE `Username`='%s'", tmpIP, tmpName);
    mysql_tquery(MainPipeline, query, "OnIPWhitelistDiscord", "ss", tmpName, tmpIP);

    format(string, sizeof(string), "Attempting to whitelist %s on %s's account...", tmpIP, tmpName);
    DCC_SendChannelMessage(channel, string);
    return 1;
}

DC_CMD:pwip(user, args) {
    new DCC_Channel:channel = DCC_FindChannelByName("NGRP-Bot");

    new string[128], query[256], giveplayer[MAX_PLAYER_NAME], ip[16];
    if(sscanf(args, "s[24]s[16]", giveplayer, ip)) {
        DCC_SendChannelMessage(channel, "USAGE: !pwip [player name] [IP]");
        return 1;
    }

    new tmpProxyName[24], tmpProxyIP[16];
    mysql_escape_string(giveplayer, tmpProxyName);
    mysql_escape_string(ip, tmpProxyIP);

    mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `ProxyIP`='%s' WHERE `Username`='%s'", tmpProxyIP, tmpProxyName);
    mysql_tquery(MainPipeline, query, "OnPIPWhitelistDiscord", "ss", tmpProxyIP, tmpProxyName);

    format(string, sizeof(string), "Attempting to proxy whitelist %s on %s's account...", tmpProxyIP, tmpProxyName);
    DCC_SendChannelMessage(channel, string);
    return 1;
}