#include <YSI\y_hooks>

hook OnGameModeInit() {

	print("[Streamer] Loading 3D Text Labels...");
	
	// General
	CreateDynamic3DTextLabel("{FFFFFF}[{F1BB05}Boat Shop{FFFFFF}]", 0x0080FFFF, 723.2262, -1494.0607, 1.9343+0.50, 25.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100.0);
	//CreateDynamic3DTextLabel("/boatshop", COLOR_YELLOW, 723.2262, -1494.0607, 1.9343, 4); // Marina docks
	CreateDynamic3DTextLabel("Paintball Rooms\n\nType /joinarena to choose rooms",COLOR_TWGREEN,1294.5062,-1445.0599,0.4403+0.5,6.0); // Paintball Arena
	CreateDynamic3DTextLabel("Name Change Point \nType /changename to change your name",COLOR_TWGREEN,1154.7295,-1440.2323,15.7969+0.6,18.0); // Namechange at mall
	CreateDynamic3DTextLabel("Press F to access to the DOC control panel", COLOR_TWGREEN, 569.0477, 1448.6146, 6000.475+10.6,4.0); // DOC Interior Control Panel

	// VIP Dedicated Famed aka perk related
    CreateDynamic3DTextLabel("To change your number type /vipnum",COLOR_TWPURPLE,2549.548095, 1404.047729, 7699.584472+0.6,4.0); // LS VIP Lounge
    CreateDynamic3DTextLabel("Type /travel\nTo exit the VIP garage with your vehicle",COLOR_TWPURPLE,-4429.944824, 905.032470, 987.078186+0.5,13.0);// LS VIP Lounge garage travel
    CreateDynamic3DTextLabel("/viplocker\nTo open the VIP locker.",COLOR_TWPURPLE,2555.747314, 1404.106079, 7699.584472+0.6,4.0);/// LS VIP Lounge locker
	CreateDynamic3DTextLabel("/getgift\nTo reach inside.",COLOR_TWPURPLE,2546.611572, 1403.323608, 7700.768066,8.0);/// LS VIP Lounge
	CreateDynamic3DTextLabel("/dplocker\nTo open the Dedicated locker.",COLOR_TWPURPLE,166.6540, -2001.0413, 3499.6482+0.6,4.0);/// Dedicated Locker
	CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWPURPLE,2561.3562,1404.1563,7699.5845+0.6,4.0); // LS VIP Lounge
	CreateDynamic3DTextLabel("Famed Locker \nType /famedlocker to access the locker", COLOR_FAMED,901.4825,1429.7404,-82.3235+0.6,4.0); // Famed Locker
	//CreateDynamic3DTextLabel("Famed Locker \nType /famedlocker to access the locker", COLOR_FAMED,901.3110,1430.1034,-82.3256+0.6,4.0); // Famed Locker
	CreateDynamic3DTextLabel("Famed Locker \nType /famedlocker to access the locker",COLOR_FAMED,901.3110,1430.1034,-82.3256,15.0); // Famed Locker

	
	// Business & Job related
	CreateDynamic3DTextLabel("{FFFFFF}[{F1BB05}Fish Shop{FFFFFF}]", 0x0080FFFF, 723.3507, -1485.1478, 1.9687+0.50, 25.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100.0);
	//CreateDynamic3DTextLabel("Type /sellfish [amount] to sell your fish to the vendor.", COLOR_YELLOW, 723.3507, -1485.1478, 1.9687, 10); // Marina docks
    CreateDynamic3DTextLabel("Type /getpizza from a Pizzaboy \nto get pizzas for delivery!",COLOR_TWGREEN,2103.6714,-1785.5222,12.9849, 4.0); //getpizza Idlewood
	//CreateDynamic3DTextLabel("/train\n To change your fightstyle.",COLOR_TWGREEN,757.1866,5.6019,1000.7007,8.0); // Gym /train
    CreateDynamic3DTextLabel("/buyclothes or Press N\n To change your skin.",COLOR_TWGREEN,208.8970,-100.3289,1005.2578,8.0);
    CreateDynamic3DTextLabel("/buyclothes or Press N\n To change your skin.",COLOR_TWGREEN,206.5429,-41.2313,1001.8047,8.0);
    CreateDynamic3DTextLabel("/buyclothes or Press N\n To change your skin.",COLOR_TWGREEN,209.3064,-8.3033,1005.2109,8.0);
    CreateDynamic3DTextLabel("/buyclothes or Press N\n To change your skin.",COLOR_TWGREEN,159.6771,-83.2866,1001.8120,8.0);
    CreateDynamic3DTextLabel("/buyclothes or Press N\n To change your skin.",COLOR_TWGREEN,206.4552,-163.0903,1000.5234,8.0);
    CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,206.3253,-100.3268,1005.2578,8.0);
    CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,201.0413,-40.1616,1001.8047,8.0);
    CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,206.3963,-8.2122,1001.2109,8.0);
    CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,162.7706,-83.2726,1001.8047,8.0);
    CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,202.6777,-163.0623,1000.5306,8.0);
	CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,1774.7533, 1422.6665, 2013.4979,8.0);
	CreateDynamic3DTextLabel("/buytoys\n To buy some accessories.",COLOR_TWGREEN,775.0900, 1742.4900, 1938.3800,8.0);
	CreateDynamic3DTextLabel("/buy\n To buy items.",COLOR_TWGREEN,-29.0583,-185.1300,1003.5469,10.0); // 24/7 Store
	//CreateDynamic3DTextLabel("/buyfood\n To buy food.",COLOR_TWGREEN,377.5905,-67.5464,1001.5151,15.0); // Burger shot
	//CreateDynamic3DTextLabel("/buyfood\n To buy food.",COLOR_TWGREEN,375.3864,-119.3041,1001.4995,15.0); // Pizza
	//CreateDynamic3DTextLabel("/buyfood\n To buy food.",COLOR_TWGREEN,369.6987,-6.3779,1001.8589,15.0); // Cluckin Bell
	CreateDynamic3DTextLabel("/buyfood\n To buy food.",COLOR_TWGREEN,451.9016,-107.2225,999.5477,15.0); // Gant Bridge Diner
	CreateDynamic3DTextLabel("/buyfood\n To buy food.",COLOR_TWGREEN,451.9016,-107.2225,999.5477,15.0); // Unkown for now

	// RG-RP Shop
	//CreateDynamic3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer = INVALID_PLAYER_ID, attachedvehicle = INVALID_VEHICLE_ID, testlos = 0, worldid = -1, interiorid = -1, playerid = -1, Float:distance = 100.0); 
	CreateDynamic3DTextLabel("Car Shop\n/carshop", COLOR_TWGREEN, 2958.2200, -1339.2900, 5.2100+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("Plane Shop\n/planeshop", COLOR_TWGREEN, 2950.4014, -1283.0776, 4.6875+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("Boat Shop\n/boatshop", COLOR_TWGREEN, 2974.7520, -1462.9265, 2.8184+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("VIP Shop\n/vipshop", COLOR_TWGREEN, 2939.0134, -1401.2946, 11.0000+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("Toy Shop\n/toyshop", COLOR_TWGREEN, 2927.5244, -1549.1826, 11.0000+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("Gift Reset\n/buygiftreset", COLOR_TWGREEN, 2937.2878, -1357.2294, 11.0000+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("House Shop\n/houseshop", COLOR_TWGREEN, 2938.2734, -1391.0596, 11.0000+0.6, 10.0, .worldid = 1);
	CreateDynamic3DTextLabel("Misc Shop\n/miscshop", COLOR_TWGREEN, 2939.8442, -1411.2906, 11.0000+0.6, 10.0,.worldid = 1);
	CreateDynamic3DTextLabel("HealthCare Shop\n/buyhealthcare", COLOR_TWGREEN, 2946.8672, -1484.9561, 11.0000+0.6, 10.0, .worldid = 1);
		
	CreateDynamic3DTextLabel("Prisoner Delivery Point\n/deliverinmates", COLOR_TWGREEN, -2053.6279,-198.0207,15.0703, 10.0);

	
	for(new i = 0; i < MAX_DELIVERY_POINTS; i++)
	{
		CreateDynamic3DTextLabel("EMS Delivery Point\n/deliverpt", COLOR_TWGREEN, HospitalDeliveryPoints[i][0], HospitalDeliveryPoints[i][1], HospitalDeliveryPoints[i][2], 10);
		CreateDynamicPickup(1240, 23, HospitalDeliveryPoints[i][0], HospitalDeliveryPoints[i][1], HospitalDeliveryPoints[i][2], -1);
	}
	
	print("[Streamer] Dynamic 3D Text Labels has been loaded.");
	return 1;
}
