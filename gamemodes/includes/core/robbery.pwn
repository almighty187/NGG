// edit account table and mysql to save c4
/*
CREATE TABLE IF NOT EXISTS `robbery_points` (
  `id` int(11) NOT NULL DEFAULT 1,
  `bank_x` float NOT NULL,
  `bank_y` float NOT NULL,
  `bank_z` float NOT NULL,
  `c4_x` float NOT NULL,
  `c4_y` float NOT NULL,
  `c4_z` float NOT NULL,
  `bag_x` float NOT NULL,
  `bag_y` float NOT NULL,
  `bag_z` float NOT NULL,
  `safe_x` float NOT NULL,
  `safe_y` float NOT NULL,
  `safe_z` float NOT NULL,
  `c4crate_x` float NOT NULL,
  `c4crate_y` float NOT NULL,
  `c4crate_z` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; */

#include <YSI\y_hooks>

	new VaultDoor;
	new bagsloaded;
	new c4placed;
	new bankrobbed;
	new LeoOnline;
	
	// New variables for dynamic points
	new Float:BankCounterPoint[3];
	new Float:C4Point[3];
	new Float:BagPoint[3];
	new Float:SafePoint[3];
	new Float:C4CratePoint[3];
	new C4CrateTimer[MAX_PLAYERS];

// hook OnGameModeInit() {
// 	LoadRobberyPoints();
// 	RehashVault();

// 	printf("ON GAME MODE LOADED FROM ROBBERY SYSTEM!!!!!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

// 	CreateDynamic3DTextLabel("Type /loadbag to start packing your duffel bag", COLOR_YELLOW, BagPoint[0], BagPoint[1], BagPoint[2]+ 1.0, 20.0);
// 	CreateDynamic3DTextLabel("Type /placec4 to place the C4 block against the vault door", COLOR_YELLOW, C4Point[0], C4Point[1], C4Point[2]+ 1.0, 20.0);
// 	CreateDynamic3DTextLabel("Type /robbank to initiate a bank robbery", COLOR_YELLOW, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2]+ 1.0, 20.0);
// 	CreateDynamic3DTextLabel("Type /unloadbag to unload your stolen cash", COLOR_YELLOW, SafePoint[0], SafePoint[1], SafePoint[2]+ 1.0, 20.0);
// 	CreateDynamic3DTextLabel("Type /stealc4 to steal a crate of C4", COLOR_YELLOW, C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]+ 1.0, 20.0);
// 	//CreateDynamicPickup(1550, 23, BagPoint[0], BagPoint[1], BagPoint[2], -1);
// 	//CreateDynamicPickup(1654, 23, C4Point[0], C4Point[1], C4Point[2], -1);
// 	//CreateDynamicPickup(1274, 23, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2], -1);
// 	//CreateDynamicPickup(1274, 23, SafePoint[0], SafePoint[1], SafePoint[2], -1);
	
// 	return 1;
// }

// New function to load robbery points from MySQL
stock LoadRobberyPoints() {
	if (mysql_tquery(MainPipeline, "SELECT * FROM robbery_points WHERE id = 1", "OnLoadRobberyPoints", "") != 1) {
		printf("ERROR: Failed to load robbery points from database");
	}

	return 1;
}

// Callback for loading robbery points
forward OnLoadRobberyPoints();
public OnLoadRobberyPoints() {
	if(cache_num_rows() > 0) {
		cache_get_value_name_float(0, "bank_x", BankCounterPoint[0]);
		cache_get_value_name_float(0, "bank_y", BankCounterPoint[1]);
		cache_get_value_name_float(0, "bank_z", BankCounterPoint[2]);
		
		cache_get_value_name_float(0, "c4_x", C4Point[0]);
		cache_get_value_name_float(0, "c4_y", C4Point[1]);
		cache_get_value_name_float(0, "c4_z", C4Point[2]);
		
		cache_get_value_name_float(0, "bag_x", BagPoint[0]);
		cache_get_value_name_float(0, "bag_y", BagPoint[1]);
		cache_get_value_name_float(0, "bag_z", BagPoint[2]);

		cache_get_value_name_float(0, "safe_x", SafePoint[0]);
		cache_get_value_name_float(0, "safe_y", SafePoint[1]);
		cache_get_value_name_float(0, "safe_z", SafePoint[2]);

		cache_get_value_name_float(0, "c4crate_x", C4CratePoint[0]);
		cache_get_value_name_float(0, "c4crate_y", C4CratePoint[1]);
		cache_get_value_name_float(0, "c4crate_z", C4CratePoint[2]);

		printf("LOADED: Bank Counter Point: %.4f, %.4f, %.4f", BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2]);
		printf("LOADED: C4 Point: %.4f, %.4f, %.4f", C4Point[0], C4Point[1], C4Point[2]);
		printf("LOADED: Bag Point: %.4f, %.4f, %.4f", BagPoint[0], BagPoint[1], BagPoint[2]);
		printf("LOADED: Safe Point: %.4f, %.4f, %.4f", SafePoint[0], SafePoint[1], SafePoint[2]);
		printf("LOADED: C4 Crate Point: %.4f, %.4f, %.4f", C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]);

		//CreateDynamic3DTextLabel("Type /robbank to initiate a bank robbery", COLOR_TWDBLUE, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2] + 0.6, 4.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1);

		CreateDynamic3DTextLabel("Type /loadbag to start packing your duffel bag", COLOR_YELLOW, BagPoint[0], BagPoint[1], BagPoint[2]+ 1.0, 5.0);
		CreateDynamic3DTextLabel("Type /placec4 to place the C4 block against the vault door", COLOR_YELLOW, C4Point[0], C4Point[1], C4Point[2]+ 1.0, 5.0);
		CreateDynamic3DTextLabel("Type /robbank to initiate a bank robbery", COLOR_YELLOW, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2]+ 1.0, 5.0);
		CreateDynamic3DTextLabel("Type /unloadbag to unload your stolen cash", COLOR_YELLOW, SafePoint[0], SafePoint[1], SafePoint[2]+ 1.0, 5.0);
		CreateDynamic3DTextLabel("Type /stealc4 to steal a crate of C4", COLOR_YELLOW, C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]+ 1.0, 5.0);
	}
	else {
		// If no points exist, create default points

		printf("NO POINTS FOUND, CREATING DEFAULT POINTS");
		BankCounterPoint[0] = 1430.1919;
		BankCounterPoint[1] = -986.1155;
		BankCounterPoint[2] = 996.1050;
		
		C4Point[0] = 1435.4530;
		C4Point[1] = -981.7479;
		C4Point[2] = 983.6462;
		
		BagPoint[0] = 1438.0367;
		BagPoint[1] = -969.9433;
		BagPoint[2] = 983.5342;

		SafePoint[0] = 1450.0;
		SafePoint[1] = -980.0;
		SafePoint[2] = 980.0;

		C4CratePoint[0] = 1470.0;
		C4CratePoint[1] = -990.0;
		C4CratePoint[2] = 990.0;
		
		// Save default points to database
		SaveRobberyPoints();
	}
	return 1;
}

// New function to save robbery points to MySQL
stock SaveRobberyPoints() {
	new query[1024];
	mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO robbery_points (id, bank_x, bank_y, bank_z, c4_x, c4_y, c4_z, bag_x, bag_y, bag_z, safe_x, safe_y, safe_z, c4crate_x, c4crate_y, c4crate_z) VALUES (1, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f) ON DUPLICATE KEY UPDATE bank_x = VALUES(bank_x), bank_y = VALUES(bank_y), bank_z = VALUES(bank_z), c4_x = VALUES(c4_x), c4_y = VALUES(c4_y), c4_z = VALUES(c4_z), bag_x = VALUES(bag_x), bag_y = VALUES(bag_y), bag_z = VALUES(bag_z), safe_x = VALUES(safe_x), safe_y = VALUES(safe_y), safe_z = VALUES(safe_z), c4crate_x = VALUES(c4crate_x), c4crate_y = VALUES(c4crate_y), c4crate_z = VALUES(c4crate_z)",
		BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2],
		C4Point[0], C4Point[1], C4Point[2],
		BagPoint[0], BagPoint[1], BagPoint[2],
		SafePoint[0], SafePoint[1], SafePoint[2],
		C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]
	);

	printf("Bank Counter Point: %.4f, %.4f, %.4f", BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2]);
	printf("C4 Point: %.4f, %.4f, %.4f", C4Point[0], C4Point[1], C4Point[2]);
	printf("Bag Point: %.4f, %.4f, %.4f", BagPoint[0], BagPoint[1], BagPoint[2]);
	printf("Safe Point: %.4f, %.4f, %.4f", SafePoint[0], SafePoint[1], SafePoint[2]);
	printf("C4 Crate Point: %.4f, %.4f, %.4f", C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]);
	printf("Saving robbery points to database: %s", query);

	mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
	return 1;
}

// Commands to to set bank robbery points 
CMD:setbankpoint(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	
	GetPlayerPos(playerid, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2]);
	SaveRobberyPoints();
	SendClientMessageEx(playerid, COLOR_GREEN, "Bank counter point has been set to your current position.");
	return 1;
}

CMD:setc4point(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	
	GetPlayerPos(playerid, C4Point[0], C4Point[1], C4Point[2]);
	SaveRobberyPoints();
	SendClientMessageEx(playerid, COLOR_GREEN, "C4 placement point has been set to your current position.");
	return 1;
}

CMD:setbagpoint(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	
	GetPlayerPos(playerid, BagPoint[0], BagPoint[1], BagPoint[2]);
	SaveRobberyPoints();
	SendClientMessageEx(playerid, COLOR_GREEN, "Bag loading point has been set to your current position.");
	return 1;
}

CMD:setsafepoint(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	
	GetPlayerPos(playerid, SafePoint[0], SafePoint[1], SafePoint[2]);
	SaveRobberyPoints();
	SendClientMessageEx(playerid, COLOR_GREEN, "Safe unloading point has been set to your current position.");
	return 1;
}

CMD:setc4cratepoint(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	
	GetPlayerPos(playerid, C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]);
	SaveRobberyPoints();
	SendClientMessageEx(playerid, COLOR_GREEN, "C4 crate location has been set to your current position.");
	return 1;
}

CMD:robbank(playerid, params[])
{
	if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this right now!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2])) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be near the bank counter to initiate a bank robbery.");
	if(bankrobbed == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "There is already someone else robbing the bank.");
	if(bankrobbed == 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "The bank has been robbed recently. (( The bank can only be robbed once an hour ))");
	//if(admins < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "There are no administrators in-game at this time.");

	new AdminCount = 0;
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pAdmin] >= 2) 
		{
			AdminCount++;
		}
	}

	//if (AdminCount < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot initiate a bank robbery with less than two administrators in-game.");


	new string[128];


	//check amount of players online

	foreach(new i: Player)
	{
		if(IsACop(i))
		{
			LeoOnline++;
		}
	}

	//if (LeoOnline < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot initiate a bank robbery with less than three law enforcement officers in-game.");

	format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s has initiated a bank robbery .", GetPlayerNameEx(playerid));
	ABroadCast(COLOR_YELLOW, szMiscArray, 2);
	
	//alert the cops if the robbery is succesffully started
	foreach(new i: Player)
	{
		if(IsACop(i))
		{
			format(string, sizeof(string), "HQ: All units, The Mulholland Bank is being robbed!");
			SendClientMessageEx(i, COLOR_DBLUE, string);
		}
	}
	
	
	bankrobbed = 1;
	new str[128];
	format(str, sizeof(str), "* One of the bankers trips the alarm.");
	format(str, sizeof(str), "* Civilians start to scream and hit the floor.");
	ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	SendClientMessageEx(playerid, COLOR_GREEN, "You have initiated a bank robbery! The local police department have been notifed");
	SendClientMessageEx(playerid, COLOR_GREEN, "Make your way to the vault and place the C4 (/placec4)");
	return 1;
}

CMD:placec4(playerid, params[])
{
	if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this right now!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, C4Point[0], C4Point[1], C4Point[2]))
        return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be near the bank counter to initiate a bank robbery.");
	if(c4placed == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Someone has already placed a block of C4.");
	if(bankrobbed == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to initiate a bank robbery before C4 can be placed (/robbank).");
	if(PlayerInfo[playerid][pC4] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "You do not have enough C4 to blow this vault");
	if (PlayerInfo[playerid][pC4] >= 1){	
		SetTimerEx("C4Robbery", 30000, false, "i", playerid);
		SetTimerEx("C4Countdown", 1000, false, "ii", playerid, 30); // Start countdown timer on screen - can't do with above timer or will have issues
		new str[128];
		format(str, sizeof(str), "* %s places the block of C4 against the vault door and sets it for 30 seconds.", GetPlayerNameEx(playerid));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SendClientMessageEx(playerid, COLOR_GREEN, "You have placed the C4, you have 30 seconds to get out of the blast radius before it explodes.");
		PlayerInfo[playerid][pC4] =- 1;
		c4placed = 1;
		PlayAnimEx(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0, 1);
	}
	return 1;
}

CMD:loadbag(playerid, params[])
{
	if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this right now!");
	
	if(IsPlayerInRangeOfPoint(playerid, 3.0, BagPoint[0], BagPoint[1], BagPoint[2]))
	{
		if(bagsloaded == 10) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ten bags of cash has already been packed. Get out of the bank!");
		if(PlayerInfo[playerid][pDuffel] == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "You have already loaded a duffel bag full of cash!");
		if(bankrobbed == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to initiate a bank robbery before loading a duffle bag(/robbank).");
		new str[128];
		format(str, sizeof(str), "* %s puts their duffel bag on the floor, unzips it and starts loading it with cash.", GetPlayerNameEx(playerid));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SetTimerEx("DuffelRobbery", 30000, false, "i", playerid);
		TogglePlayerControllable(playerid,0);
		PlayAnimEx(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0, 1);
		bagsloaded ++; //the global variable making sure only 10 players bag money
	}
	return 1;
}

CMD:unloadbag(playerid, params[])
{
	if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this right now!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 10, SafePoint[0], SafePoint[1], SafePoint[2])) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be at the dropsite to unload your stolen cash!");
	if(!IsPlayerInAnyVehicle(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be in a vehicle before you can unload your stolen cash!");
	if(PlayerInfo[playerid][pDuffel] < 1) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not carrying a duffel bag");

	new rand = Random(90000, 200000);
	PlayerInfo[playerid][pCash] += rand;
	PlayerInfo[playerid][pDuffel] = 0;
	RemovePlayerAttachedObject(playerid, 9);
	new str[128];
	format(str, sizeof(str), "* %s unzips their duffel bag full of cash.", GetPlayerNameEx(playerid));
	ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	format(str, sizeof(str), "You received $%d from your share of the bank robbery.", rand);
    SendClientMessageEx(playerid, COLOR_GRAD1, str);
	bankrobbed = 2;
	return 1;
}

CMD:givec4(playerid, params[])
{
	PlayerInfo[playerid][pC4] = 1;	
	SendClientMessageEx(playerid, COLOR_GRAD1, "You have given yourself a block of C4");
	return 1;
}

CMD:stealc4(playerid, params[]) {
	if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this right now!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, C4CratePoint[0], C4CratePoint[1], C4CratePoint[2]))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be near the C4 crate to steal it!");
	
	if(C4CrateTimer[playerid] > 0)
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to wait before stealing another C4 crate!");
	
	if(PlayerInfo[playerid][pC4] >= 3)
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You can't carry more than 3 C4 blocks!");
	
	new str[128];
	format(str, sizeof(str), "* %s starts breaking into the C4 crate...", GetPlayerNameEx(playerid));
	ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	
	TogglePlayerControllable(playerid, 0);
	PlayAnimEx(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0, 1);
	
	SetTimerEx("OnC4Steal", 10000, false, "i", playerid);
	SetTimerEx("C4StealCountdown", 10000, false, "ii", playerid, 10); // Start on screen timer
	C4CrateTimer[playerid] = 300; // 5 minutes cooldown
	SetTimerEx("ResetC4Timer", 300000, false, "i", playerid);
	
	return 1;
}

forward OnC4Steal(playerid);
public OnC4Steal(playerid) {
	TogglePlayerControllable(playerid, 1);
	
	// 60% chance of failure
	if(random(100) < 60) {
		new str[128];
		format(str, sizeof(str), "* %s fails to steal the C4", GetPlayerNameEx(playerid));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SendClientMessageEx(playerid, COLOR_RED, "You failed to steal the C4, in the process you left DNA evidence behind!");
		
		// Add crime for attempted C4 theft
		AddCrime(playerid, 0, "Attempted Theft");
		PlayerInfo[playerid][pWantedLevel] += 2;
		SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pWantedLevel]);
		
		// Alert nearby police
		foreach(new i: Player) {
			if(IsACop(i)) {
				format(str, sizeof(str), "HQ: All units, reports of an attempted theft at LV quarry.");
				SendClientMessageEx(i, COLOR_DBLUE, str);
			}
		}
		return 1;
	}
	
	PlayerInfo[playerid][pC4]++;
	
	new str[128];
	format(str, sizeof(str), "* %s successfully steals a block of C4 from the crate.", GetPlayerNameEx(playerid));
	ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	SendClientMessageEx(playerid, COLOR_GREEN, "You have stolen a block of C4. You can now use it to blow the bank vault.");
	return 1;
}

forward ResetC4Timer(playerid);
public ResetC4Timer(playerid) {
	C4CrateTimer[playerid] = 0;
	SendClientMessageEx(playerid, COLOR_GREEN, "You can now attempt too steal another crate of C4.");
	return 1;
}

forward C4Robbery(playerid);
public C4Robbery(playerid)
{
	CreateExplosion(C4Point[0], C4Point[1], C4Point[2], 0, 5);
	DestroyVault();
	SendClientMessageEx(playerid, COLOR_GREEN, "You have blown the vault door, Start loading the duffelbags");
	DestroyDynamicObject(VaultDoor); // just in case it dont remove the 1st time.
	return 1;
}

forward DuffelRobbery(playerid);
public DuffelRobbery(playerid)
{
	TogglePlayerControllable(playerid,1);
	SetPlayerAttachedObject(playerid, 9, 1550, 1, 0.1, -0.2, 0, 0, 90, 0.5, 0.8, 0.8, 0.8);
	SendClientMessageEx(playerid, COLOR_GREEN, "You have loaded the duffel bag full of cash. Escape the bank!");
	SendClientMessageEx(playerid, COLOR_GREEN, "Make it to a vehicle and unload the cash (/unloadbag)");
	PlayerInfo[playerid][pDuffel] = 1;
	return 1;
}

stock DestroyVault()
{
	DestroyDynamicObject(VaultDoor);
	return 1;
}

stock RehashVault()
{
    VaultDoor = CreateDynamicObject(2634, 1435.35193, -980.29688, 984.21887, 0.00000, 0.00000, 179.04001); // Vault Door
    bagsloaded = 0;
	c4placed = 0;
	bankrobbed = 0;
    return 1;
}

CMD:rehash(playerid)
{
	SaveRobberyPoints();
	RehashVault();
	DestroyVault();
	printf("Vaults rehashed");
	return 1;	
}


forward C4Countdown(playerid, timeleft);
public C4Countdown(playerid, timeleft)
{
	
	new string[6];
	if(--SystemUpdate == 0) KillTimer(SystemTimer), Maintenance();
	if(SystemUpdate == 15) GameTextForAll("~n~~n~~n~~n~~w~Please ~r~log out ~w~now to ensure ~y~account data ~w~has been ~g~saved~w~!", 2000, 3);
	if(SystemUpdate < 0) SystemUpdate = 0;
	format(string, sizeof(string), "%s", STimeConvert(SystemUpdate));
	TextDrawSetString(UpdateIn[1], string);
	TextDrawShowForAll(UpdateIn[1]);




    // if(timeleft > 0)
    // {
    //     new str[32];
    //     format(str, sizeof(str), "~r~Detonation in: %d seconds", timeleft);
    //     GameTextForPlayer(playerid, str, 30000, 3);
    //     SetTimerEx("C4Countdown", 30000, false, "ii", playerid, timeleft - 1);
    // }
    return 1;
}

forward C4StealCountdown(playerid, timeleft);
public C4StealCountdown(playerid, timeleft)
{
    if(timeleft > 0)
    {
        new str[32];
        format(str, sizeof(str), "~r~Breaking into crate: %d seconds", timeleft);
        GameTextForPlayer(playerid, str, 10000, 3);
        SetTimerEx("C4StealCountdown", 10000, false, "ii", playerid, timeleft - 1);
    }
    return 1;
}


