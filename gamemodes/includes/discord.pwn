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

//--------------------------------[DISCORD.PWN]--------------------------------
#include <YSI\y_hooks>

// Global channel IDs (cached after bot connects)
new DCC_Channel:g_AdminChannelId = DCC_INVALID_CHANNEL;
new DCC_Channel:g_AdminWarningsChannelId = DCC_INVALID_CHANNEL;
new DCC_Channel:g_HeadAdminChannelId = DCC_INVALID_CHANNEL;
new DCC_Channel:g_ServerErrorsChannelId = DCC_INVALID_CHANNEL;

new CountingPlayer;

hook OnGameModeInit()
{
    print("[DCC] Connecting to Discord...");
    SetTimer("BotStatus", 1000, true);
    SetTimer("InitDiscordChannels", 3000, false); // Delay to allow bot to connect
    return 1;
}

forward InitDiscordChannels();
public InitDiscordChannels()
{
    g_AdminChannelId = DCC_FindChannelById("1360504707851747429");
    g_AdminWarningsChannelId = DCC_FindChannelById("1360504741741990029");
    g_HeadAdminChannelId = DCC_FindChannelById("1360504760041476217");
    g_ServerErrorsChannelId = DCC_FindChannelById("1360504778718711870");
    print("[DCC] Discord channel IDs initialized.");
}

hook OnPlayerConnect(playerid)
{
    CountingPlayer++;
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    CountingPlayer--;
    return 1;
}

forward BotStatus();
public BotStatus()
{
    new string[256];
    format(string, sizeof(string), "with %d players!", CountingPlayer);
    DCC_SetBotActivity(string);
}

// Discord Message Sender
stock SendDiscordMessage(channel, message[])
{
    switch (channel)
    {
        case 0: // #admin
        {
            if (g_AdminChannelId != DCC_INVALID_CHANNEL)
                DCC_SendChannelMessage(g_AdminChannelId, message);
            else
                print("[DCC] Failed to send message to #admin (channel ID invalid).");
        }
        case 1: // #admin-warnings
        {
            if (g_AdminWarningsChannelId != DCC_INVALID_CHANNEL)
                DCC_SendChannelMessage(g_AdminWarningsChannelId, message);
            else
                print("[DCC] Failed to send message to #admin-warnings (channel ID invalid).");
        }
        case 2: // #headadmin
        {
            if (g_HeadAdminChannelId != DCC_INVALID_CHANNEL)
                DCC_SendChannelMessage(g_HeadAdminChannelId, message);
            else
                print("[DCC] Failed to send message to #headadmin (channel ID invalid).");
        }
        case 3: // #server-errors
        {
            if (g_ServerErrorsChannelId != DCC_INVALID_CHANNEL)
                DCC_SendChannelMessage(g_ServerErrorsChannelId, message);
            else
                print("[DCC] Failed to send message to #server-errors (channel ID invalid).");
        }
    }
    return 1;
}

public DCC_OnMessageCreate(DCC_Message:message)
{
    new realMsg[100], DCC_Channel:channel, DCC_User:author;
    new channel_name[32], user_name[33], szMessage[128], author_id[21];
    new bool:IsBot;

    DCC_GetMessageChannel(message, channel);
    DCC_GetMessageAuthor(message, author);
    DCC_IsUserBot(author, IsBot); // must come AFTER author is assigned

    if (IsBot) return 1; // Ignore bot messages

    DCC_GetMessageContent(message, realMsg);
    DCC_GetChannelName(channel, channel_name);
    DCC_GetUserName(author, user_name);
    DCC_GetUserId(author, author_id);

    printf("[DCC] OnChannelMessage (Channel %s): Author %s sent message: %s", channel_name, user_name, realMsg);

    if (channel == g_AdminChannelId && strcmp(user_name, "NGRP-Bot", true))
    {
        format(szMessage, sizeof(szMessage), "* [Discord] Administrator %s: %s", user_name, realMsg);
        ABroadCast(COLOR_YELLOW, szMessage, 2, true);
    }
    else if (channel == g_HeadAdminChannelId && strcmp(user_name, "NGRP-Bot", true))
    {
        format(szMessage, sizeof(szMessage), "(PRIVATE) [Discord] Administrator %s: %s", user_name, realMsg);
        ABroadCast(COLOR_GREEN, szMessage, 1337, true);
    }

    return 1;
}
