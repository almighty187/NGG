#include <a_samp>
#include <a_http>

// === Global ===
forward OnVPNCheck(playerid, response_code, data[]);
forward CheckVPNWhitelist(playerid);

// === OnPlayerConnect: Call IP-API ===
hook OnPlayerConnect(playerid)
{
    new ip[16], url[128];
    GetPlayerIp(playerid, ip, sizeof ip);
    format(url, sizeof url, "http://ip-api.com/json/%s?fields=proxy,hosting", ip);
    HTTP(playerid, HTTP_GET, url, "", "OnVPNCheck");
    return 1;
}

// === HTTP Response: Check Proxy/Hosting Flags ===
public OnVPNCheck(playerid, response_code, data[])
{
    if (response_code != 200) return 1;

    // Check if it's a proxy or hosting provider
    if (strfind(data, "\"proxy\":true", true) != -1 || strfind(data, "\"hosting\":true", true) != -1)
    {
        new query[128];
        mysql_format(MainPipeline, query, sizeof(query), "SELECT VPNIP FROM accounts WHERE id=%d", PlayerInfo[playerid][pId]);
        mysql_tquery(MainPipeline, query, "CheckVPNWhitelist", "i", playerid);
    }
    return 1;
}

// === Callback: Check Against Whitelisted IP ===
public CheckVPNWhitelist(playerid)
{
    new ip[16], whitelisted[16];
    GetPlayerIp(playerid, ip, sizeof ip);

    if (cache_num_rows() == 0) return 1;
    cache_get_value_name(0, "VPNIP", whitelisted, sizeof whitelisted);

    // Kick if IP doesn't match the whitelisted one
    if (!strlen(whitelisted) || strcmp(ip, whitelisted, true) != 0)
    {
        SendClientMessage(playerid, COLOR_RED, "Disable your VPN or request a whitelist on Discord.");
        SetTimerEx("KickEx", 1000, 0, "i", playerid);
    }
    return 1;
}

// === Admin Command: Whitelist an IP ===
CMD:whitelistvpn(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
    {
        new string[128], query[256], target[MAX_PLAYER_NAME], ip[16];

        if (sscanf(params, "s[24]s[16]", target, ip))
        {
            SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /whitelistvpn [player name] [IP]");
            return 1;
        }

        new escName[24], escIP[16];
        mysql_escape_string(target, escName);
        mysql_escape_string(ip, escIP);
        SetPVarString(playerid, "OnIPWhitelist", escName);

        mysql_format(MainPipeline, query, sizeof(query), "UPDATE accounts SET VPNIP='%s' WHERE Username='%s'", escIP, escName);
        mysql_tquery(MainPipeline, query, "OnIPWhitelist", "i", playerid);

        format(string, sizeof string, "Attempting to whitelist %s for %s...", escIP, escName);
        SendClientMessageEx(playerid, COLOR_YELLOW, string);
    }
    return 1;
}