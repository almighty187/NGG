#include <YSI\y_hooks>

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys){

    if(PRESSED(KEY_YES))
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, 736.1448,1728.9884,1940.2688))
        {
            ShowSetStation(playerid);
        }
    }
    return 1;
}