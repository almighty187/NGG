CMD:startquest(playerid, params[])
{
    // Clean up any existing pickups
    CleanupQuestPickups(playerid);

    // Generate new quest pickups
    GenerateQuestPickups(playerid);

	if(gettime() - QuestLastTime[playerid] < 86400) { // 86400 seconds = 24 hours
		SendClientMessageEx(playerid, COLOR_RED, "You must wait 24 hours before starting a new quest.");
        return 1; // Don't generate pickups if on cooldown
    }
    // Inform player
    SendClientMessageEx(playerid, COLOR_YELLOW2, "Quest started! Collect all 10 pickup points around the city.");
    SendClientMessageEx(playerid, COLOR_YELLOW2, "Follow the yellow markers on your map.");

    return 1;
}

// Add these functions instead:
stock InitPlayerQuest(playerid) {
    QuestLastTime[playerid] = 0;
    PlayerInfo[playerid][pObjectsAcquired] = 0;
    CleanupQuestPickups(playerid); // Make sure any existing pickups are cleaned
    return 1;
}
