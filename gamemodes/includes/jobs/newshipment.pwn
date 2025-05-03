/*
    [NOTE: OED approved revamp. Submitted to devcp via Bando. Documentation: https://docs.google.com/document/d/1nsrKfBYtC7BSN6Z36r1lkoi_ipjVjRBW3YlfHZdBpB4]
    
    TR - pending feedback.

    LSPD - pending feedback.
    AddPlayerClass(7,1535.3512,-1675.4783,13.3828,269.3415,0,0,0,0,0,0); // Bando

    Add Matthew's thing from <18:51:49> "Matthew": AddPlayerClass(172,999.1709,-1131.7074,23.8281,358.4189,0,0,0,0,0,0); // Cattle
                            <18:54:17> "Matthew": AddPlayerClass(172,1662.7423,-1563.4584,13.3906,356.6844,0,0,0,0,0,0); // Fertilizer
*/

#include <YSI\y_hooks>

#define MAX_SHIPMENTS 6

new Float:fTruckLoad[3] = {2250.0527,-2401.5366,13.5469};
new Float:fTrailerLoad[3] = {2209.4082,-2522.7646,13.5469};

// FF0000 - illegal
// 02CF09 - legals
new ShipmentContents[MAX_SHIPMENTS][4][] =
{
    {"{02CF09}Electronics", "Los Santos Electronics", "1", "50"},
    {"{02CF09}Alcohol", "Ten Green Bottles, Los Santos", "2", "300"},
    {"{02CF09}Groceries & Clothing", "Unity Station General Store", "2", "250"},
    {"{FF0000}Body Parts", "Zombotech Inc", "1", "400"},
    {"{02CF09}Police Medical Kits", "Los Santos Police", "1", "309"},
    {"{02CF09}Medical Equipment", "FDSA Headquarters", "2", "340"}
};

new Float:ShipmentLocations[MAX_SHIPMENTS][6] =
{
    {1041.9824,-946.1545,42.8108}, // Electronics UGG2
    {2304.0591,-1639.7516,14.5358, 2309.9607,-1643.7705,14.8270}, // Alcohol UGG2
    {1836.8259,-1856.6282,13.3897, 1832.3584,-1843.0067,13.5781}, // G & C UGG2
    {958.1761,-1186.6823,16.9453}, // Body Parts tbd
    {1544.5341,-1718.5969,13.1545}, // LS Police Meds tbd
    {1147.2482,-1353.2377,13.4165, 1171.8209,-1310.0959,13.9877} // Medical Equipment
};

/*new ShipmentPrices[MAX_SHIPMENTS] =
{
    100,
    720,
    400,
    800,
    650,
    750
};

new ShipmentTypes[MAX_SHIPMENTS] =
{
    1,
    2,
    2,
    1,
    1,
    1
};
*/

new ShipmentTrucks[13][3]; // 0 = id, 1 = model, 2 = cargo max amt.

stock IsATrucker(playerid)
{
    if(PlayerInfo[playerid][pJob] != 20 && PlayerInfo[playerid][pJob2] != 20 && PlayerInfo[playerid][pJob3] != 20) return 0;
    return 1;
}

stock IsATruck(vehicleid)
{
    new model = GetVehicleModel(vehicleid);
    switch(model)
    {
        case 403, 414, 440, 455, 456, 499, 515: return 1; // Mule, Yankee, Benson, Rumpo
        default: return 0;
    }
}

stock IsTrailer(vehicleid)
{
    new model = GetVehicleModel(vehicleid);
    switch(model)
    {
        case 584, 450, 435, 591: return 1;
        default: return 0;
    }
    return 0;
}

stock IsTruckingVehicle(vehicleid)
{
    for(new i = 0; i < sizeof ShipmentTrucks; i++)
    {
        if(vehicleid == ShipmentTrucks[i][0]) return 1;
    }
    return 0;
}

stock GetVehicleCargoSize(modelid)
{
    // This function takes a vehicle's model and returns the cargo size for that vehicle.
    switch(modelid)
    {
        case 403: return 60;
        case 414: return 30;
        case 440: return 15;
        case 455: return 80;
        case 456: return 35;
        case 499: return 25;
        case 515: return 60;
        default: return 20;
    }
    return 0;
}

stock GetVehicleCargo(vehicleid)
{
    format(szMiscArray, sizeof szMiscArray, "%s\n", ShipmentContents[TruckHolding[vehicleid]]);
    return szMiscArray;
}

stock ShowLoadTruckDialog(playerid)
{
    // Generate a random set of 10 values from the current ones.
    for(new i = 0; i < 10; i++)
    {
        new iRand = random(sizeof ShipmentContents);
        PlayerInfo[playerid][pShipmentOptions][i] = iRand;
    }

    szMiscArray[0] = 0; // Reset the string so we don't have any funky string bugs.
    format(szMiscArray, sizeof szMiscArray, "Contents\tLocation\tPrice Per Kilogram\n");
    new string[1024];
    for(new i = 0; i < 10; i++)
    {
        format(string, sizeof string, "%s\t%s\t$%s/kg\n", ShipmentContents[PlayerInfo[playerid][pShipmentOptions][i]][0], ShipmentContents[PlayerInfo[playerid][pShipmentOptions][i]][1], number_format(strval(ShipmentContents[PlayerInfo[playerid][pShipmentOptions][i]][3])));
        strcat(szMiscArray, string, sizeof szMiscArray);
    }

    ShowPlayerDialogEx(playerid, DIALOG_SHIPMENT_OPTIONS, DIALOG_STYLE_TABLIST_HEADERS, "Shipment Contractor - Loading", szMiscArray, "Select", "Cancel");
}

hook OnGameModeInit()
{
    printf("Loading revamped trucker data. JCurtis");

    ShipmentTrucks[0][0] = CreateVehicle(414, 2280.5588,-2353.1926,13.1464,222.1911, 0, 0, 300, 0);
    ShipmentTrucks[0][1] = GetVehicleModel(ShipmentTrucks[0][0]);
    ShipmentTrucks[0][2] = GetVehicleCargoSize(ShipmentTrucks[0][1]);

    ShipmentTrucks[1][0] = CreateVehicle(414, 2284.6365,-2349.4551,13.1467,224.6535, 0, 0, 300, 0);
    ShipmentTrucks[1][1] = GetVehicleModel(ShipmentTrucks[1][0]);
    ShipmentTrucks[1][2] = GetVehicleCargoSize(ShipmentTrucks[1][1]);

    ShipmentTrucks[2][0] = CreateVehicle(456, 2288.0559,-2345.4758,13.1467,225.7820, 0, 0, 300, 0);
    ShipmentTrucks[2][1] = GetVehicleModel(ShipmentTrucks[2][0]);
    ShipmentTrucks[2][2] = GetVehicleCargoSize(ShipmentTrucks[2][1]);

    ShipmentTrucks[3][0] = CreateVehicle(456, 2292.2180,-2342.4685,13.1467,220.1435, 0, 0, 300, 0);
    ShipmentTrucks[3][1] = GetVehicleModel(ShipmentTrucks[3][0]);
    ShipmentTrucks[3][2] = GetVehicleCargoSize(ShipmentTrucks[3][1]);

    ShipmentTrucks[4][0] = CreateVehicle(499, 2295.0288,-2338.5881,13.1465,226.5171, 0, 0, 300, 0);
    ShipmentTrucks[4][1] = GetVehicleModel(ShipmentTrucks[4][0]);
    ShipmentTrucks[4][2] = GetVehicleCargoSize(ShipmentTrucks[4][1]);

    ShipmentTrucks[5][0] = CreateVehicle(499, 2300.1235,-2335.1484,13.1466,222.2015, 0, 0, 300, 0);
    ShipmentTrucks[5][1] = GetVehicleModel(ShipmentTrucks[5][0]);
    ShipmentTrucks[5][2] = GetVehicleCargoSize(ShipmentTrucks[5][1]);

    //end street
    ShipmentTrucks[6][0] = CreateVehicle(440, 2318.2588,-2365.0520,13.1466,45.3862, 0, 0, 300, 0);
    ShipmentTrucks[6][1] = GetVehicleModel(ShipmentTrucks[6][0]);
    ShipmentTrucks[6][2] = GetVehicleCargoSize(ShipmentTrucks[6][1]);

    ShipmentTrucks[7][0] = CreateVehicle(455, 2310.6675,-2372.3391,13.1467,43.1313, 0, 0, 300, 0);
    ShipmentTrucks[7][1] = GetVehicleModel(ShipmentTrucks[7][0]);
    ShipmentTrucks[7][2] = GetVehicleCargoSize(ShipmentTrucks[7][1]);

    ShipmentTrucks[8][0] = CreateVehicle(455, 2314.9600,-2368.4136,13.1466,44.3823, 0, 0, 300, 0);
    ShipmentTrucks[8][1] = GetVehicleModel(ShipmentTrucks[8][0]);
    ShipmentTrucks[8][2] = GetVehicleCargoSize(ShipmentTrucks[8][1]);

    ShipmentTrucks[9][0] = CreateVehicle(455, 2306.7446,-2377.7888,13.1468,40.9241, 0, 0, 300, 0);
    ShipmentTrucks[9][1] = GetVehicleModel(ShipmentTrucks[9][0]);
    ShipmentTrucks[9][2] = GetVehicleCargoSize(ShipmentTrucks[9][1]);

    ShipmentTrucks[10][0] = CreateVehicle(455, 2300.9473,-2383.3306,15.1469,44.9525, 0, 0, 300, 0);
    ShipmentTrucks[10][1] = GetVehicleModel(ShipmentTrucks[10][0]);
    ShipmentTrucks[10][2] = GetVehicleCargoSize(ShipmentTrucks[10][1]);

    ShipmentTrucks[11][0] = CreateVehicle(455, 2295.1147,-2387.7336,15.1465,45.1914, 0, 0, 300, 0);
    ShipmentTrucks[11][1] = GetVehicleModel(ShipmentTrucks[11][0]);
    ShipmentTrucks[11][2] = GetVehicleCargoSize(ShipmentTrucks[11][1]);

    ShipmentTrucks[12][0] = CreateVehicle(455, 2289.1572,-2393.5269,13.1465,46.2744, 0, 0, 300, 0);
    ShipmentTrucks[12][1] = GetVehicleModel(ShipmentTrucks[12][0]);
    ShipmentTrucks[12][2] = GetVehicleCargoSize(ShipmentTrucks[12][1]);
    

    for(new i = 0; i < sizeof ShipmentTrucks; i++)
    {
        TruckUsedBy[ShipmentTrucks[i][0]] = -1;
        TruckHolding[ShipmentTrucks[i][0]] = -1;
    }

    printf("Trucker vehicles loaded.");

    CreateDynamic3DTextLabel("Truck Loading Location\n{33CCFF}/loadtruck", COLOR_YELLOW, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2], 25.0);
    CreateDynamicPickup(1239, 1, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2]);

}

hook OnPlayerDisconnect(playerid, reason) 
{
    new vehicleid;
    vehicleid = GetPlayerVehicleID(playerid);
    if(PlayerInfo[playerid][pUsingTruck] == vehicleid)
    {
        PlayerInfo[playerid][pUsingTruck] = INVALID_VEHICLE_ID;
        PlayerInfo[playerid][pCurrentShipment] = -1;
        if(GetPVarInt(playerid, "DeliveryStage") > 0 || GetPVarInt(playerid, "FinishShipment"))
        {
            DisablePlayerCheckpoint(playerid);
            DeletePVar(playerid, "DeliveryStage");
            DeletePVar(playerid, "FinishShipment");
        }
    }
}

hook OnVehicleDeath(vehicleid, killerid)
{
    if(IsTruckingVehicle(vehicleid))
    {
        TruckHolding[vehicleid] = -1;
        TruckUsedBy[vehicleid] = -1;

        foreach(new i: Player)
        {
            if(PlayerInfo[i][pUsingTruck] == vehicleid)
            {
                PlayerInfo[i][pUsingTruck] = INVALID_VEHICLE_ID;
                PlayerInfo[i][pCurrentShipment] = -1;
                SendClientMessage(i, COLOR_LIGHTRED, "Your shipment was destroyed!");
                if(GetPVarInt(i, "DeliveryStage") > 0 || GetPVarInt(i, "FinishShipment"))
                {
                    DisablePlayerCheckpoint(i);
                    DeletePVar(i, "DeliveryStage");
                    DeletePVar(i, "FinishShipment");
                }
                break;
            }
        }
    }

    foreach(new i: Player)
    {
        if(GetPVarInt(i, "DeliveryTrailer") == vehicleid)
        {
            SendClientMessage(i, COLOR_LIGHTRED, "Your shipment trailer was destroyed! Your shipment has been cancelled.");
            PlayerInfo[i][pUsingTruck] = INVALID_VEHICLE_ID;
            PlayerInfo[i][pCurrentShipment] = -1;
            SendClientMessage(i, COLOR_LIGHTRED, "Your shipment was destroyed!");
                
            if(GetPVarInt(i, "DeliveryStage") > 0 || GetPVarInt(i, "FinishShipment"))
            {
                DisablePlayerCheckpoint(i);
                DeletePVar(i, "DeliveryStage");
                DeletePVar(i, "FinishShipment");
            }
        }
    }
}

hook OnPlayerEnterCheckpoint(playerid)
{
    if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
    
    new shipment = PlayerInfo[playerid][pCurrentShipment];
    if(GetPVarInt(playerid, "TruckingCPSet"))
    {
        DisablePlayerCheckpoint(playerid);
        DeletePVar(playerid, "TruckingCPSet");
    }

    else if(GetPVarInt(playerid, "DeliveryStage") == 1 && shipment != -1 && IsPlayerInRangeOfPoint(playerid, 10.0, ShipmentLocations[shipment][0], ShipmentLocations[shipment][1], ShipmentLocations[shipment][2]))
    {
        if(!IsPlayerInAnyVehicle(playerid)) return 1;

        if(IsPlayerInVehicle(playerid, PlayerInfo[playerid][pUsingTruck]))
        {
            DisablePlayerCheckpoint(playerid);
            if(/*ShipmentTypes[PlayerInfo[playerid][pCurrentShipment]] == 1*/strval(ShipmentContents[PlayerInfo[playerid][pCurrentShipment]][2]) == 1) // Their shipment is only 1 stage.
            {
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have delivered your shipment.");
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "Take your truck back to the loading bay and /finishshipment to receive your pay.");
                SetPVarInt(playerid, "FinishShipment", 1);
                DisablePlayerCheckpoint(playerid);
                SetPlayerCheckpoint(playerid, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2], 25.0);
                DeletePVar(playerid, "UnloadingCrates");
                DeletePVar(playerid, "TruckingCrates");
                DeletePVar(playerid, "DeliveryStage");
                TruckHolding[PlayerInfo[playerid][pUsingTruck]] = -1;
            }
            else if(strval(ShipmentContents[PlayerInfo[playerid][pCurrentShipment]][2]) == 2)
            {
                switch(shipment) // Now because some shipments are unique, we have to specify them here. There's probably a better way to do this but oh well.
                {
                    case 1, 2:
                    {
                        SendClientMessage(playerid, COLOR_LIGHTBLUE, "You must unload your truck to continue. Open the trunk and then use /unloadshipment.");
                        new crates = floatround(GetVehicleCargoSize(GetVehicleModel(GetPlayerVehicleID(playerid))) / 10, floatround_ceil) + 1; // Want a minimum of 2 crates.
                        format(szMiscArray, sizeof szMiscArray, "There are %d crates in the back of the truck. You must deliver them all to proceed.", crates);
                        SendClientMessage(playerid, COLOR_LIGHTBLUE, szMiscArray);
                        SetPVarInt(playerid, "TruckingCrates", crates);
                        SetPVarInt(playerid, "DeliveryStage", 2);
                    }
                    case 5:
                    {
                        SendClientMessage(playerid, COLOR_LIGHTBLUE, "You must unload your truck to continue. Open the trunk and then use /unloadshipment.");
                        new crates = floatround(GetVehicleCargoSize(GetVehicleModel(GetPlayerVehicleID(playerid))) / 10, floatround_ceil) + 1;
                        format(szMiscArray, sizeof szMiscArray, "There are %d crates of medical equipment in the back of the truck. You must deliver them all to proceed.", crates);
                        SendClientMessage(playerid, COLOR_LIGHTBLUE, szMiscArray);
                        SetPVarInt(playerid, "TruckingCrates", crates);
                        SetPVarInt(playerid, "DeliveryStage", 2);
                    }
                    default:
                    {
                        SendClientMessage(playerid, COLOR_GREY, "There was an error processing your shipment. The second stage was not defined.");
                    }
                }
            }
            else
            {
                // It's a fuel run.
                switch(shipment)
                {
                    case 8, 10, 22:
                    {
                        DisablePlayerCheckpoint(playerid);
                        TogglePlayerControllable(playerid, false);
                        new Float:X, Float:Y, Float:Z;
                        GetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
                        new Float:fAngle;
                        GetVehicleZAngle(GetPlayerVehicleID(playerid), fAngle);
                        new trailer = CreateVehicle(584, X, Y+3, Z, fAngle, 1, 1, 300, 0);
                        SetPVarInt(playerid, "DeliveryTrailer", trailer);
                        AttachTrailerToVehicle(trailer, GetPlayerVehicleID(playerid));
                        SendClientMessage(playerid, COLOR_LIGHTBLUE, "The fuel is being loaded into your tank...");
                        GameTextForPlayer(playerid, "~b~Loading Fuel...", 8000, 6);
                        SetTimerEx("DeliveryLoadingFuel", 8000, false, "d", playerid);
                    }

                    //Disabled fuel run for the time being :D

                    default:
                    {
                        SendClientMessage(playerid, COLOR_GREY, "There was an error processing your shipment. The fuel stage was not defined.");
                    }
                }
            }
        } else
        {
            SendClientMessage(playerid, COLOR_GREY, "You can only make deliveries in your shipment vehicle... nice try");
            cmd_finishshipment(playerid, "/finishshipment");            
            return 1;
        }
    }

    else if(GetPVarInt(playerid, "DeliveryStage") == 3 && IsPlayerInRangeOfPoint(playerid, 25.0, ShipmentLocations[shipment][3], ShipmentLocations[shipment][4], ShipmentLocations[shipment][5]))
    {
        switch(shipment)
        {
            case 8:
            {
                

                TogglePlayerControllable(playerid, false);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "The fuel is being unloaded from your tank...");
                SetTimerEx("DeliveryUnloadingFuel", 8000, false, "d", playerid);
            }
            default: SendClientMessage(playerid, COLOR_GREY, "There was an error processing your fuel run.");
        }
    }
    else printf("Error.");
    return 1;
}

CMD:unloadfuel(playerid, params[])
{
    if(!IsPlayerInVehicle(playerid, PlayerInfo[playerid][pUsingTruck]) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_GRAD2, "You must be driving your shipment vehicle to use this command.");

    if(PlayerInfo[playerid][pUsingTruck] == INVALID_VEHICLE_ID || PlayerInfo[playerid][pCurrentShipment] == -1 || !GetPVarInt(playerid, "DeliveryStage")) return SendClientMessage(playerid, COLOR_GRAD2, "You do not have an active shipment.");

    if(!IsTrailerAttachedToVehicle(PlayerInfo[playerid][pUsingTruck])) return SendClientMessage(playerid, COLOR_GREY, "You do not have your fuel trailer attached.");
    if(GetVehicleTrailer(PlayerInfo[playerid][pUsingTruck]) != GetPVarInt(playerid, "DeliveryTrailer")) return SendClientMessage(playerid, COLOR_GREY, "You are carrying the wrong trailer.");

    new iShipment = PlayerInfo[playerid][pCurrentShipment];
    if(!IsPlayerInRangeOfPoint(playerid, 10.0, ShipmentLocations[iShipment][3], ShipmentLocations[iShipment][4], ShipmentLocations[iShipment][5])) return SendClientMessage(playerid, COLOR_GREY, "You're not close enough to the unload point.");

    if(strval(ShipmentContents[iShipment][2]) != 3) return SendClientMessage(playerid, COLOR_GREY, "Your shipment type does not support fuel.");

    if(GetPVarInt(playerid, "DeliveryStage") != 3) return SendClientMessage(playerid, COLOR_GREY, "You cannot unload your fuel yet.");

    TogglePlayerControllable(playerid, false);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, "The fuel is being unloaded from your tank...");
    GameTextForPlayer(playerid, "~b~Unloading fuel...", 8000, 6);
    SetTimerEx("DeliveryUnloadingFuel", 8000, false, "d", playerid);

    return 1;
}

forward DeliveryUnloadingFuel(playerid);
public DeliveryUnloadingFuel(playerid)
{
    DisablePlayerCheckpoint(playerid);
    TogglePlayerControllable(playerid, true);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Your fuel has been unloaded and your trailer has been detatched. Drive back to the loading bay and /finishshipment.");
    DetachTrailerFromVehicle(PlayerInfo[playerid][pUsingTruck]);
    DestroyVehicle(GetPVarInt(playerid, "DeliveryTrailer"));
    DeletePVar(playerid, "DeliveryTrailer");
    DeletePVar(playerid, "DeliveryStage");
    SetPVarInt(playerid, "FinishShipment", 1);
    SetPlayerCheckpoint(playerid, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2], 25.0);
    return 1;
}

forward DeliveryLoadingFuel(playerid);
public DeliveryLoadingFuel(playerid)
{
    TogglePlayerControllable(playerid, true);
    new iShipment = PlayerInfo[playerid][pCurrentShipment];
    TruckHolding[GetPVarInt(playerid, "DeliveryTrailer")] = iShipment;
    format(szMiscArray, sizeof szMiscArray, "%s{33CCFF} has been loaded into the tank. You must deliver this to %s to continue with your delivery.", ShipmentContents[iShipment][0], ShipmentContents[iShipment][1]);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, szMiscArray);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Drive to the checkpoint on your map and /unloadfuel to continue.");
    SetPlayerCheckpoint(playerid, ShipmentLocations[iShipment][3], ShipmentLocations[iShipment][4], ShipmentLocations[iShipment][4], 10.0);
    SetPVarInt(playerid, "DeliveryStage", 3);
    return 1;
}

CMD:loadtruck(playerid, params[])
{
    if(!IsATrucker(playerid)) return SendClientMessage(playerid, COLOR_GRAD2, "You must be a shipment contractor to use this command.");

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_GRAD2, "You must be driving a vehicle to use this command.");

    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsTruckingVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_GRAD2, "You must be in a shipment vehicle to use this command.");

    if(PlayerInfo[playerid][pUsingTruck] == INVALID_VEHICLE_ID || !IsValidVehicle(PlayerInfo[playerid][pUsingTruck]))
    {
        if(!IsPlayerInRangeOfPoint(playerid, 15.0, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2]))
        {
            SendClientMessage(playerid, COLOR_GRAD3, "A checkpoint has been set to the loading bay.");
            SetPlayerCheckpoint(playerid, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2], 25.0);
            SetPVarInt(playerid, "TruckingCPSet", 1);
        }
        else if(!GetPVarInt(playerid, "DeliveryStage"))
        {
            SendClientMessage(playerid, COLOR_LIGHTBLUE, "Select an option to load your truck.");
            ShowLoadTruckDialog(playerid);
        }
        else SendClientMessage(playerid, COLOR_GRAD2, "You already have an active shipment.");
    }
    else SendClientMessage(playerid, COLOR_GRAD2, "You already have a truck. Complete your delivery to continue.");
    return 1;
}

stock GetTrunkPos(vehicleid, &Float:fX, &Float:fY, &Float:fZ)
{
    new model = GetVehicleModel(vehicleid);
    new Float:X, Float:Y, Float:Z;
    GetVehicleModelInfo(model, VEHICLE_MODEL_INFO_SIZE, X, Y, Z);

    new Float:X2, Float:Y2, Float:Z2;
    GetVehiclePos(vehicleid, X2, Y2, Z2);

    fX = X2;
    fY = Y2 + Y / 2;
    fZ = Z2;
}

CMD:cancelshipment(playerid, params[])
{
    if(IsATrucker(playerid))
    {
        if(PlayerInfo[playerid][pUsingTruck] == INVALID_VEHICLE_ID || PlayerInfo[playerid][pCurrentShipment] == -1 || !GetPVarInt(playerid, "DeliveryStage")) return SendClientMessage(playerid, COLOR_GRAD2, "You do not have an active shipment.");
        new vehicleid;
        vehicleid = GetPlayerVehicleID(playerid);
        if(PlayerInfo[playerid][pUsingTruck] == vehicleid)
        {
            PlayerInfo[playerid][pUsingTruck] = INVALID_VEHICLE_ID;
            PlayerInfo[playerid][pCurrentShipment] = -1;
            if(GetPVarInt(playerid, "DeliveryStage") > 0 || GetPVarInt(playerid, "FinishShipment"))
            {
                DisablePlayerCheckpoint(playerid);
                DeletePVar(playerid, "DeliveryStage");
                DeletePVar(playerid, "FinishShipment");
                SendClientMessageEx(playerid, COLOR_WHITE, "You have cancelled your shipment run.");
            }
        }
    }
    else SendClientMessage(playerid, COLOR_GRAD2, "You must be a shipment contractor to use this command.");
    return 1;
}

CMD:unloadshipment(playerid, params[])
{
    if(IsATrucker(playerid))
    {
        if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAD2, "You must be on foot to use this command.");

        if(PlayerInfo[playerid][pUsingTruck] == INVALID_VEHICLE_ID || PlayerInfo[playerid][pCurrentShipment] == -1 || !GetPVarInt(playerid, "DeliveryStage")) return SendClientMessage(playerid, COLOR_GRAD2, "You do not have an active shipment.");

        new Float:X, Float:Y, Float:Z;
        GetVehiclePos(PlayerInfo[playerid][pUsingTruck], X, Y, Z);

        if(!IsPlayerInRangeOfPoint(playerid, 6.0, X, Y, Z)) return SendClientMessage(playerid, COLOR_GRAD2, "You're not close enough to your shipment vehicle to do this.");

        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(PlayerInfo[playerid][pUsingTruck], engine, lights, alarm, doors, bonnet, boot, objective);

        if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)
        {
            SendClientMessageEx(playerid, COLOR_GRAD2, "The vehicle's trunk must be opened to unload crates.");
            return 1;
        }

        if(GetPVarInt(playerid, "DeliveryStage") == 2)
        {
            if(!GetPVarInt(playerid, "TruckingCrates")) return SendClientMessage(playerid, COLOR_GRAD2, "You do not have any more crates to unload.");

            TogglePlayerControllable(playerid, false);
            ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.0, 1, 0, 0, 0, 0, 1);

            new iShipment = PlayerInfo[playerid][pCurrentShipment];
            if(iShipment == 15) SetTimerEx("UnloadingDeliveryCrate", 1000, false, "dd", playerid, 1454);
            else if(iShipment == 16) SetTimerEx("UnloadingDeliveryCrate", 1000, false, "dd", playerid, 19944);
            else SetTimerEx("UnloadingDeliveryCrate", 1000, false, "dd", playerid, 2912);
        }
        else SendClientMessage(playerid, COLOR_GREY, "You do not need to unload crates right now.");
    }
    else SendClientMessage(playerid, COLOR_GRAD2, "You must be a shipment contractor to use this command.");
    return 1;
}

CMD:dropshipment(playerid, params[])
{
    if(IsATrucker(playerid))
    {
        if(!GetPVarInt(playerid, "UnloadingCrates")) return SendClientMessage(playerid, COLOR_GREY, "You are not currently unloading a crate.");

        new iShipment = PlayerInfo[playerid][pCurrentShipment];
        if(!IsPlayerInRangeOfPoint(playerid, 1.5, ShipmentLocations[iShipment][3], ShipmentLocations[iShipment][4], ShipmentLocations[iShipment][5])) return SendClientMessage(playerid, COLOR_GRAD2, "You're not close enough to the unload point.");

        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0, 1);
        RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "CrateSlot"));

        SetPVarInt(playerid, "TruckingCrates", GetPVarInt(playerid, "TruckingCrates") - 1);

        new crates = GetPVarInt(playerid, "TruckingCrates");
        DisablePlayerCheckpoint(playerid);
        TogglePlayerControllable(playerid, false);
        SetTimerEx("DropCrateUnfreeze", 1600, false, "d", playerid);
        if(crates > 1)
        {
            format(szMiscArray, sizeof szMiscArray, "Run completed. There are %d remaining.", GetPVarInt(playerid, "TruckingCrates"));
            SendClientMessage(playerid, COLOR_LIGHTBLUE, szMiscArray);
        }
        else if(crates == 1)
        {
            SendClientMessage(playerid, COLOR_LIGHTBLUE, "There is 1 remaining.");
        }
        else if(crates == 0)
        {
            SendClientMessage(playerid, COLOR_LIGHTBLUE, "You have unloaded your truck. It is now empty.");
            SendClientMessage(playerid, COLOR_LIGHTBLUE, "Take your truck back to the loading bay and /finishshipment to receive your pay.");
            SetPVarInt(playerid, "FinishShipment", 1);
            DisablePlayerCheckpoint(playerid);
           // SetPlayerCheckpoint(playerid, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2], 25.0);
            DeletePVar(playerid, "UnloadingCrates");
            DeletePVar(playerid, "TruckingCrates");
            DeletePVar(playerid, "DeliveryStage");
            TruckHolding[PlayerInfo[playerid][pUsingTruck]] = -1;
        }
        
    }
    else SendClientMessage(playerid, COLOR_GRAD2, "You must be a shipment contractor to use this command.");
    return 1;
}

forward DropCrateUnfreeze(playerid);
public DropCrateUnfreeze(playerid)
{
    TogglePlayerControllable(playerid, true);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    ClearAnimationsEx(playerid);
    return 1;
}

CMD:respawntrucks(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 2)
    {
        for(new i = 0; i < sizeof ShipmentTrucks; i++)
        {
            DynVeh_Spawn(ShipmentTrucks[i][0]);
            TruckUsedBy[ShipmentTrucks[i][0]] = -1;
            TruckHolding[ShipmentTrucks[i][0]] = -1;
        }
        SendClientMessageEx(playerid, COLOR_GRAD2, "Trucks respawned");
    } else {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You aren't authorized to use this command!");
    }
    return 1;
}

CMD:finishshipment(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
    if(IsATrucker(playerid))
    {
        if(IsPlayerInVehicle(playerid, PlayerInfo[playerid][pUsingTruck]))
        {
            if(!IsTruckingVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_GRAD2, "You must be in a shipment vehicle to use this command.");

            if(!GetPVarInt(playerid, "FinishShipment")) return SendClientMessage(playerid, COLOR_GRAD2, "You haven't completed your shipment run yet.");

            if(!IsPlayerInRangeOfPoint(playerid, 10.0, fTruckLoad[0], fTruckLoad[1], fTruckLoad[2])) return SendClientMessage(playerid, COLOR_GRAD2, "You're not close enough to the loading bay to do this.");

            GameTextForPlayer(playerid, "~g~Shipment Completed!", 4, 2000);

            new shipment = PlayerInfo[playerid][pCurrentShipment];
            new ppk = strval(ShipmentContents[shipment][3]);

            new cargo = GetVehicleCargoSize(GetVehicleModel(PlayerInfo[playerid][pUsingTruck]));

            new pay = cargo * ppk;

            format(szMiscArray, sizeof szMiscArray, "You have completed your shipment and have been paid $%s.", number_format(pay));
            SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
            SaveTruckerTime(playerid);
            DeletePVar(playerid, "DeliveryStage");
            DeletePVar(playerid, "FinishShipment");

            GivePlayerCash(playerid, pay);
            PlayerInfo[playerid][pTruckSkill]++;

            TruckUsedBy[PlayerInfo[playerid][pUsingTruck]] = -1;
            SetVehicleToRespawn(PlayerInfo[playerid][pUsingTruck]);
            PlayerInfo[playerid][pUsingTruck] = INVALID_VEHICLE_ID;
            PlayerInfo[playerid][pCurrentShipment] = -1;
            DisablePlayerCheckpoint(playerid);
        } else {
            SendClientMessage(playerid, COLOR_GREY, "You can only make deliveries in your shipment vehicle.");
            cmd_finishshipment(playerid, "");
            return 1;       
        }
    }
    return 1;
}

forward UnloadingDeliveryCrate(playerid, crate);
public UnloadingDeliveryCrate(playerid, crate)
{
    TogglePlayerControllable(playerid, true);
    new Float:X, Float:Y, Float:Z;
    GetPlayerPos(playerid, X, Y, Z);
    printf("crate %d", crate);

    // Assigning the objects correctly.
    new slot = -1;
    for(new i = 0; i < 10; i++)
    {
        if(!IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            slot = i;
            break;
        }
    }

    if(slot == -1)
    {
        RemovePlayerAttachedObject(playerid, 9);
        slot = 9;
    }

    SetPVarInt(playerid, "CrateSlot", slot);


    if(crate == 1454) // Hay bale.
    {
        SetPlayerAttachedObject(playerid, slot, 1454, 1, 0.3, 0.6, 0, 90, 0, 0, 0.5, 0.5, 0.5, 0, 0); 
    }
    else if(crate == 19944) // Corpses.
    {
        SetPlayerAttachedObject(playerid, slot, 19944, 1, -0.05, 0.55, 0, 90, 90, 0, 0.65, 0.65, 0.65, 0, 0); 
    }
    else // Other.
    {
        SetPlayerAttachedObject(playerid, slot, crate, 1, 0.23, 0.6, -0.28, 0, 0.0, 0.0, 0.8, 0.8, 0.8, 0, 0);
    }

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    SendClientMessage(playerid, COLOR_WHITE, "You have unloaded an item. Take it to the checkpoint on your map and /dropshipment.");

    new iShipment = PlayerInfo[playerid][pCurrentShipment];
    SetPlayerCheckpoint(playerid, ShipmentLocations[iShipment][3], ShipmentLocations[iShipment][4], ShipmentLocations[iShipment][5], 1.5);
    SetPVarInt(playerid, "UnloadingCrates", 1);
    return 1;
}

CMD:cleartruck(playerid, params[])
{
    if(IsACop(playerid) || IsAGovernment(playerid) || IsATrucker(playerid))
    {
        new carid = GetPlayerVehicleID(playerid);
        new closestcar = GetClosestCar(playerid, carid);

        if(!IsTruckingVehicle(closestcar) && !IsTrailer(closestcar)) return SendClientMessage(playerid, COLOR_GREY, "That vehicle is not a valid shipment vehicle.");

        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(closestcar, engine, lights, alarm, doors, bonnet, boot, objective);

        if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET && !IsTrailer(closestcar))
        {
            SendClientMessageEx(playerid, COLOR_GRAD1, "The vehicle's trunk must be opened to search it.");
            return 1;
        }

        if(TruckHolding[closestcar] != -1) // The truck has some cargo.
        {
            format(szMiscArray, sizeof szMiscArray, "You have confiscated the truck's %s.", ShipmentContents[TruckHolding[closestcar]][0]);
            SendClientMessage(playerid, COLOR_GRAD1, szMiscArray);

            TruckHolding[closestcar] = -1;

            foreach(new i: Player) 
            {
                if(PlayerInfo[i][pUsingTruck] == closestcar) 
                {
                    PlayerInfo[i][pCurrentShipment] = -1; 
                    PlayerInfo[i][pUsingTruck] = INVALID_VEHICLE_ID;
                }
            }
            format(szMiscArray, sizeof szMiscArray, "%s has confiscated the contents of the truck.", GetPlayerNameEx(playerid));
            ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
        }
        else
        {
            SendClientMessage(playerid, COLOR_GREY, "You cannot remove this truck's cargo as it is empty.");
        }
    }
    else SendClientMessage(playerid, COLOR_GREY, "You must be a law enforcement officer or shipment contractor to use this command.");
    return 1;
}

CMD:searchtruck(playerid, params[])
{
    if(IsACop(playerid) || IsAGovernment(playerid) || IsATrucker(playerid))
    {
        new carid = GetPlayerVehicleID(playerid);
        new closestcar = GetClosestCar(playerid, carid);

        if(!IsTruckingVehicle(closestcar) && !IsTrailer(closestcar)) return SendClientMessage(playerid, COLOR_GREY, "That vehicle is not a valid shipment vehicle.");

        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(closestcar, engine, lights, alarm, doors, bonnet, boot, objective);

        if(boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET && !IsTrailer(closestcar))
        {
            SendClientMessageEx(playerid, COLOR_GRAD1, "The vehicle's trunk must be opened to search it.");
            return 1;
        }

        SendClientMessage(playerid, COLOR_GREEN, "________________________________");
        SendClientMessage(playerid, COLOR_GRAD3, "Vehicle Cargo:");
        
        if(TruckHolding[closestcar] != -1) // The truck has some cargo.
        {
            format(szMiscArray, sizeof szMiscArray, "This vehicle is holding %s.", ShipmentContents[TruckHolding[closestcar]][0]);
            SendClientMessage(playerid, COLOR_WHITE, szMiscArray);

            format(szMiscArray, sizeof szMiscArray, "The manifesto shows the destination as {A9C4E4}%s{FFFFFF}.", ShipmentContents[TruckHolding[closestcar]][1]);
            SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
        }
        else
        {
            SendClientMessage(playerid, COLOR_GREY, "This vehicle is empty. It has not been loaded or its cargo has already been delivered.");
        }

        SendClientMessage(playerid, COLOR_GREEN, "________________________________");
    }
    else SendClientMessage(playerid, COLOR_GRAD2, "You are not a shipment contractor or a Law Enforcement Officer.");
    return 1;
}

forward TruckAbuseCheck(playerid, vehicleid);
public TruckAbuseCheck(playerid, vehicleid)
{
    if(GetPVarInt(playerid, "TruckAbuse"))
    {
        SetVehicleToRespawn(vehicleid);
        SendClientMessage(playerid, COLOR_LIGHTRED, "Your shipment vehicle has been respawned! You did not load a shipment within 2 minutes.");
    }
    return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT && IsTruckingVehicle(GetPlayerVehicleID(playerid)))
    {
        if(!IsATrucker(playerid))
        {
            SendClientMessage(playerid, COLOR_GREY, "You must be a shipment contractor to drive this vehicle.");
            RemovePlayerFromVehicle(playerid);
            return 1;
        }

        new vehicleid = GetPlayerVehicleID(playerid);

        
        if(TruckUsedBy[vehicleid] == -1)
        {
            // Truck abuse should only trigger on non-owned trucks, as this would open up the doors for an exploit.
            SetTimerEx("TruckAbuseCheck", 120000, false, "dd", playerid, GetPlayerVehicleID(playerid)); // To stop people using a truck and driving it around in lieu of buying a car.
            SetPVarInt(playerid, "TruckAbuse", 1);
            SendClientMessage(playerid, COLOR_YELLOW, "NOTE: You are driving an unused shipment vehicle. To start a shipment, use /loadtruck.");
        }
        else
        {
            if(TruckHolding[vehicleid] == -1)
            {
                if(vehicleid == PlayerInfo[playerid][pUsingTruck]) 
                {
                    SendClientMessage(playerid, COLOR_GRAD2, "This is your shipment vehicle. It is currently empty.");
                }
                else
                {
                    SendClientMessage(playerid, COLOR_YELLOW, "NOTE: You are driving a used shipment vehicle. It is currently empty.");
                    SendClientMessage(playerid, COLOR_YELLOW, "NOTE: To claim it, drive it back to the shipment location at Blueberry.");
                }
                
            }
            else
            {
                if(vehicleid == PlayerInfo[playerid][pUsingTruck])
                {
                    format(szMiscArray, sizeof szMiscArray, "This is your shipment vehicle. It is currently carrying %s{BFC0C2}.", ShipmentContents[TruckHolding[vehicleid]][0]);
                    SendClientMessage(playerid, COLOR_GRAD2, szMiscArray);
                }
                else
                {
                    format(szMiscArray, sizeof szMiscArray, "NOTE: You are driving a used shipment vehicle. It is currently carrying %s{FFFF00}.", ShipmentContents[TruckHolding[vehicleid]][0]);
                    SendClientMessage(playerid, COLOR_YELLOW, szMiscArray);

                    if(PlayerInfo[playerid][pUsingTruck] == INVALID_VEHICLE_ID || !IsValidVehicle(PlayerInfo[playerid][pUsingTruck]))
                    {
                        SendClientMessage(playerid, COLOR_YELLOW, "NOTE: To claim it, use /claimtruck.");
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_YELLOW, "NOTE: You are already on a delivery and therefore unable to claim this truck's cargo.");
                    }
                }
                
            }
        }
    }
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_SHIPMENT_OPTIONS)
    {
        if(!response) return SendClientMessage(playerid, COLOR_GRAD2, "You have stopped loading your shipment.");
        // The listitem is the index of the player's pShipmentOptions.
        // Which in turn is the corresponding value of the ShipmentOptions.
        new ShipmentID = PlayerInfo[playerid][pShipmentOptions][listitem];

        // The below ensures they cannot do fuel shipments using a mule, and vice versa.
        new type = strval(ShipmentContents[ShipmentID][2]);
        new model = GetVehicleModel(GetPlayerVehicleID(playerid));
        if(type == 1 || type == 2)
        {
            switch(model)
            {
                case 403, 515: return SendClientMessage(playerid, COLOR_GREY, "Your vehicle is incompatible for this delivery type.");
            }
        }
        if(type == 3)
        {
            switch(model)
            {
                case 414, 456, 499, 440, 455: return SendClientMessage(playerid, COLOR_GREY, "Your vehicle is incompatible for this delivery type.");
                default:
                {
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Drive to the fuel depot in Las Venturas to get a trailer.");
                    SetPlayerCheckpoint(playerid, fTrailerLoad[0], fTrailerLoad[1], fTrailerLoad[2], 10.0);
                    SetPVarInt(playerid, "DeliveryStage", 1);
                    PlayerInfo[playerid][pUsingTruck] = GetPlayerVehicleID(playerid);
                    TruckUsedBy[GetPlayerVehicleID(playerid)] = playerid;
                    PlayerInfo[playerid][pCurrentShipment] = ShipmentID;
                    DeletePVar(playerid, "TruckAbuse");
                    return 1;
                }
            }
        }

        PlayerInfo[playerid][pUsingTruck] = GetPlayerVehicleID(playerid);
        TruckUsedBy[GetPlayerVehicleID(playerid)] = playerid;

        // Freeze the player for X seconds, tell them their vehicle is being loaded with Y.
        // The time should be calculated by the size of their cargo.
        new time = 5000 + floatround(GetVehicleCargoSize(GetVehicleModel(GetPlayerVehicleID(playerid))) / 10);
        TogglePlayerControllable(playerid, false);
        SetPVarInt(playerid, "DeliveryStartTime", gettime());
        format(szMiscArray, sizeof szMiscArray, "Your vehicle is now being loaded with %s{FFFFFF}.", ShipmentContents[ShipmentID][0]);
        SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
        GameTextForPlayer(playerid, "~g~Loading shipment...", time, 6);
        SetTimerEx("LoadPlayerShipment", time, false, "dd", playerid, ShipmentID);
    }
    return 1;
}

forward LoadPlayerShipment(playerid, shipment);
public LoadPlayerShipment(playerid, shipment)
{
    TogglePlayerControllable(playerid, true);
    DisablePlayerCheckpoint(playerid);
    format(szMiscArray, sizeof szMiscArray, "Your truck has been loaded. Drive to %s to proceed with your delivery.", ShipmentContents[shipment][1]);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, szMiscArray);
    SetPVarInt(playerid, "DeliveryStage", 1);
    PlayerInfo[playerid][pCurrentShipment] = shipment;
    TruckHolding[GetPlayerVehicleID(playerid)] = shipment;
    PlayerInfo[playerid][pUsingTruck] = GetPlayerVehicleID(playerid);
    SetPlayerCheckpoint(playerid, ShipmentLocations[shipment][0], ShipmentLocations[shipment][1], ShipmentLocations[shipment][2], 10.0);
    DeletePVar(playerid, "TruckAbuse");
    return 1;
}