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

hook OnGameModeInit() {
	LoadRobberyPoints();
	RehashVault();

	CreateDynamic3DTextLabel("Type /loadbag to start packing your duffel bag", COLOR_YELLOW, BagPoint[0], BagPoint[1], BagPoint[2], 10);
	CreateDynamic3DTextLabel("Type /placec4 to place the C4 block against the vault door", COLOR_YELLOW, C4Point[0], C4Point[1], C4Point[2], 10);
	CreateDynamic3DTextLabel("Type /robbank to initiate a bank robbery", COLOR_YELLOW, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2], 10);
	CreateDynamicPickup(1550, 23, BagPoint[0], BagPoint[1], BagPoint[2], -1);
	CreateDynamicPickup(1654, 23, C4Point[0], C4Point[1], C4Point[2], -1);
	CreateDynamicPickup(1274, 23, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2], -1);
	
	return 1;
}

// New function to load robbery points from MySQL
stock LoadRobberyPoints() {
	new query[256];
	mysql_format(MainPipeline, query, sizeof(query), "SELECT * FROM robbery_points WHERE id = 1");
	mysql_tquery(MainPipeline, query, "OnLoadRobberyPoints", "");
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
	}
	else {
		// If no points exist, create default points
		BankCounterPoint[0] = 1430.1919;
		BankCounterPoint[1] = -986.1155;
		BankCounterPoint[2] = 996.1050;
		
		C4Point[0] = 1435.4530;
		C4Point[1] = -981.7479;
		C4Point[2] = 983.6462;
		
		BagPoint[0] = 1438.0367;
		BagPoint[1] = -969.9433;
		BagPoint[2] = 983.5342;
		
		// Save default points to database
		SaveRobberyPoints();
	}
	return 1;
}

// New function to save robbery points to MySQL
stock SaveRobberyPoints() {
	new query[512];
	mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO robbery_points (id, bank_x, bank_y, bank_z, c4_x, c4_y, c4_z, bag_x, bag_y, bag_z) VALUES (1, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f) ON DUPLICATE KEY UPDATE bank_x = VALUES(bank_x), bank_y = VALUES(bank_y), bank_z = VALUES(bank_z), c4_x = VALUES(c4_x), c4_y = VALUES(c4_y), c4_z = VALUES(c4_z), bag_x = VALUES(bag_x), bag_y = VALUES(bag_y), bag_z = VALUES(bag_z)",
		BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2],
		C4Point[0], C4Point[1], C4Point[2],
		BagPoint[0], BagPoint[1], BagPoint[2]
	);
	mysql_tquery(MainPipeline, query, "", "");
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

CMD:robbank(playerid, params[])
{
	if(GetPVarInt(playerid, "Injured") || PlayerCuffed[playerid] > 0 || GetPVarInt(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken") != 0 || PlayerInfo[playerid][pHospital] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot do this right now!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, BankCounterPoint[0], BankCounterPoint[1], BankCounterPoint[2])) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be near the bank counter to initiate a bank robbery.");
	if(bankrobbed == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "There is already someone else robbing the bank.");
	if(bankrobbed == 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "The bank has been robbed recently. (( The bank can only be robbed once an hour ))");
	//if(admins < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "There are no administrators in-game at this time.");

	foreach(new i: Player)
	{
		if(PlayerInfo[i][pAdmin] >= 2) 
		{
			if(i < 2)  return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot initiate a bank robbery with less than two admins in-game.");
		}
	}

	format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s has initiated a bank robbery .", GetPlayerNameEx(playerid));
	ABroadCast(COLOR_YELLOW, szMiscArray, 2);

	new string[128];
	foreach(new i: Player)
		{
			if(IsACop(i))
			{
				LeoOnline ++;
				if(LeoOnline < 3)  return SendClientMessageEx(playerid, COLOR_GRAD1, "You cannot initiate a bank robbery with less than three law enforcement officers in-game.");
			}
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
	if (PlayerInfo[playerid][pC4] >= 1){	
		SetTimerEx("C4Robbery", 30000, false, "i", playerid);
		new str[128];
		format(str, sizeof(str), "* %s places the block of C4 against the vault and sets it for 30 seconds.", GetPlayerNameEx(playerid));
		ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SendClientMessageEx(playerid, COLOR_GREEN, "You have placed the C4, you have 30 seconds to get away from the bomb before it explodes");
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
	
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be in a vehicle before you can unload the cash"); // Check to make sure the player is inside of a vehicle 
	if(PlayerInfo[playerid][pDuffel] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not carrying a duffel bag");

	new rand = Random(90000, 200000);
	PlayerInfo[playerid][pCash] += rand;
	PlayerInfo[playerid][pDuffel] = 0;
	RemovePlayerAttachedObject(playerid, 9);
	new str[128];
	format(str, sizeof(str), "* %s unzips their duffel bag full of cash.", GetPlayerNameEx(playerid));
	ProxDetector(4.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	format(str, sizeof(str), "You recieved $%d from your share of the bank robbery .",rand);
    SendClientMessageEx(playerid, COLOR_GRAD1, str);
	return 1;
}

CMD:givec4(playerid, params[])
{
	PlayerInfo[playerid][pC4] = 1;	
	SendClientMessageEx(playerid, COLOR_GRAD1, "You have given yourself a block of C4");
	return 1;
}

forward C4Robbery(playerid);
public C4Robbery(playerid)
{
	CreateExplosion(1435.35193, -980.29688, 984.21887, 0, 5);
	DestroyVault();
	SendClientMessageEx(playerid, COLOR_GREEN, "You have blown the vault. Start loading the duffelbags");
	bankrobbed = 2;
	DestroyDynamicObject(VaultDoor); // just in case it dont remove the 1st time./
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
	RehashVault();
	DestroyVault();
	printf("Vaults rehashed");
	return 1;	
}
// Make players with duffelbags slower than usual

// We'll use OnPlayerUpdate to check if a player is carrying a duffel bag and adjust their speed accordingly.
// Since this is a stock/core include, we will define a hookable public function.


