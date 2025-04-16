#include <YSI\y_hooks>

hook OnGameModeInit() {

	print("[Streamer] Loading Dynamic Pickups...");
	
    // Pickups
	CreateDynamicPickup(1239, 23, -4429.944824, 905.032470, 987.078186, -1); // VIP Garage Travel
  	CreateDynamicPickup(1239, 23, 701.7953,-519.8322,16.3348, -1); //Rental Icon
	CreateDynamicPickup(1239, 23, 757.3734,5.7227,1000.7012, -1); // Train Pos
	CreateDynamicPickup(1239, 23, 758.43,-78.0,1000.65, -1); // Train Pos (MALL GYM)
	CreateDynamicPickup(1239, 23, 2903.371826, -2254.517333, 7.244657, -1); // Train Pos (New GYM)
	CreateDynamicPickup(1239, 23, 293.6505,188.3670,1007.1719, -1); //FBI
    CreateDynamicPickup(1210, 23, 63.973995, 1973.618774, -68.786064, -1); //Hitman Pickup
	CreateDynamicPickup(371, 23, 1544.2,-1353.4,329.4); //LS towertop
	CreateDynamicPickup(1239, 23, -1713.961425, 1348.545166, 7.180452, -1); //Pier 69 /getpizza
	CreateDynamicPickup(1239, 23, 2103.6714,-1785.5222,12.9849, -1); // Idlewood /getpizza
	CreateDynamicPickup(371, 23, 1536.0, -1360.0, 1150.0); //LS towertop
	CreateDynamicPickup(2485, 23, 2958.2200, -1339.2900, 5.2100, 1);// NGGShop - Car Shop
	CreateDynamicPickup(1239, 23, 2950.4014, -1283.0776, 4.6875, 1);// NGGShop - Plane Shop
	CreateDynamicPickup(1239, 23, 2974.7520, -1462.9265, 2.8184, 1);// NGGShop - Boat Shop
	CreateDynamicPickup(1314, 23, 2939.0134, -1401.2946, 11.0000, 1);// NGGShop - VIP Shop
	CreateDynamicPickup(1272, 23, 2938.2734, -1391.0596, 11.0000, 1);// NGGShop - House Shop
	CreateDynamicPickup(1239, 23, 2939.8442, -1411.2906, 11.0000, 1);// NGGShop - Misc Shop
	CreateDynamicPickup(1239, 23, 2927.5000, -1530.0601, 11.0000, 1);// NGGShop - ATM
	CreateDynamicPickup(1241, 23, 2946.8672, -1484.9561, 11.0000, 1);// NGGShop - Healthcare
	CreateDynamicPickup(1239, 23, 2937.2878, -1357.2294, 11.0000, 1);// NGGShop - Gift Reset
	print("[Streamer] Dynamic Pickups have been loaded.");	
	return 1;
}