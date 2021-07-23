// Wrapper for official XML confloader plugin
// ------------------------------------------------------- //

// @param {string} Path - path to server.conf file | default: "server.conf"
// @param {bool} LogInfo - whether to display loading information or not | default: true

function _ConfLoader(Path = "server.conf", LogInfo = true)
{
    local Doc = SqXml.Document();
    Doc.LoadFile(Path);

    local Info =
    {
        Settings    = false,
        VehCount    = 0,
        PickupCount = 0,
        ClassCount  = 0
    };

    // ------------------------------------------------------- //
    // Settings block

    local Settings = Doc.Node.Name == "Settings" ? Doc.Node : Doc.Node.GetNextSibling("Settings");
    if(!Settings.Empty)
    {
        Info.Settings = true;

        // ------------------------------------------------------- //
        // Main settings

        local Current = Settings.GetChild("ServerName");
        if(!Current.Empty) SqServer.SetServerName(Current.Text.Value);

        Current = Settings.GetChild("MaxPlayers");
        if(!Current.Empty) SqServer.SetMaxPlayers(Current.Text.Value);  

        Current = Settings.GetChild("Password");
        if(!Current.Empty) SqServer.SetPassword(Current.Text.Value);     

        Current = Settings.GetChild("GameModeName");
        if(!Current.Empty) SqServer.SetGameMode(Current.Text.Value);   

        // ------------------------------------------------------- //
        // Spawn Camera & Position

        Current = Settings.GetChild("PlayerPos");
        if(!Current.Empty) 
        {
            local   PosX = Current.GetAttribute("x").Float,
                    PosY = Current.GetAttribute("y").Float,
                    PosZ = Current.GetAttribute("z").Float;

            SqServer.SetSpawnPlayerPositionEx(PosX, PosY, PosZ);
        }

        Current = Settings.GetChild("CamPos");
        if(!Current.Empty) 
        {
            local   PosX = Current.GetAttribute("x").Float,
                    PosY = Current.GetAttribute("y").Float,
                    PosZ = Current.GetAttribute("z").Float;

            SqServer.SetSpawnCameraPositionEx(PosX, PosY, PosZ);
        }

        Current = Settings.GetChild("CamLook");
        if(!Current.Empty) 
        {
            local   PosX = Current.GetAttribute("x").Float,
                    PosY = Current.GetAttribute("y").Float,
                    PosZ = Current.GetAttribute("z").Float;

            SqServer.SetSpawnCameraLookAtEx(PosX, PosY, PosZ);
        }

        // ------------------------------------------------------- //
        // Server options

        Current = Settings.GetChild("FriendlyFire");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.FriendlyFire, Current.Text.Bool);

        Current = Settings.GetChild("ShowOnRadar");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.ShowMarkers, Current.Text.Bool);

        Current = Settings.GetChild("SyncFrameLimiter");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.SyncFrameLimiter, Current.Text.Bool);

        Current = Settings.GetChild("FrameLimiter");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.FrameLimiter, Current.Text.Bool);

        Current = Settings.GetChild("TaxiBoostJump");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.TaxiBoostJump, Current.Text.Bool);

        Current = Settings.GetChild("DriveOnWater");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.DriveOnWater, Current.Text.Bool);

        Current = Settings.GetChild("FastSwitch");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.FastSwitch, Current.Text.Bool);

        Current = Settings.GetChild("DisableDriveBy");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.DisableDriveBy, Current.Text.Bool);

        Current = Settings.GetChild("PerfectHandling");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.PerfectHandling, Current.Text.Bool);

        Current = Settings.GetChild("FlyingCars");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.FlyingCars, Current.Text.Bool);

        Current = Settings.GetChild("JumpSwitch");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.JumpSwitch, Current.Text.Bool);

        Current = Settings.GetChild("DeathMessages");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.DeathMessages, Current.Text.Bool);

        // 0.4 Settings
        Current = Settings.GetChild("ShootInAir");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.ShootInAir, Current.Text.Bool);

        Current = Settings.GetChild("JoinMessages");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.JoinMessages, Current.Text.Bool);

        Current = Settings.GetChild("ShowNameTags");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.ShowNameTags, Current.Text.Bool);

        Current = Settings.GetChild("StuntBike");
        if(!Current.Empty) SqServer.SetOption(SqServerOption.StuntBike, Current.Text.Bool);

        // ------------------------------------------------------- //
        // Time settings

        Current = Settings.GetChild("WeatherDefault");
        if(!Current.Empty) SqServer.SetWeather(Current.Text.Int);

        Current = Settings.GetChild("HourDefault");
        if(!Current.Empty) SqServer.SetHour(Current.Text.Int);

        Current = Settings.GetChild("MinuteDefault");
        if(!Current.Empty) SqServer.SetMinute(Current.Text.Int);

        Current = Settings.GetChild("TimeRate");
        if(!Current.Empty) SqServer.SetTimeRate(Current.Text.Int);

        // ------------------------------------------------------- //
        // Other server settings

        Current = Settings.GetChild("WorldBoundaries");
        if(!Current.Empty) 
        {
            local   MinX = Current.GetAttribute("MinX").Float,
                    MinY = Current.GetAttribute("MinY").Float,
                    MaxX = Current.GetAttribute("MaxX").Float,
                    MaxY = Current.GetAttribute("MaxY").Float;

            SqServer.SetWorldBoundsEx(MaxX, MinX, MaxY, MinY);
        }

        Current = Settings.GetChild("Gravity");
        if(!Current.Empty) SqServer.SetGravity(Current.Text.Float); 

        Current = Settings.GetChild("GameSpeed");
        if(!Current.Empty) SqServer.SetGameSpeed(Current.Text.Float); 

        Current = Settings.GetChild("WaterLevel");
        if(!Current.Empty) SqServer.SetWaterLevel(Current.Text.Float); 

        Current = Settings.GetChild("Gravity");
        if(!Current.Empty) SqServer.SetGravity(Current.Text.Float); 
    }

    // ------------------------------------------------------- //
    // Vehicles

    local VehNode = Doc.Node.Name == "Vehicle" ? Doc.Node : Doc.Node.GetNextSibling("Vehicle");
    while(!VehNode.Empty)
    {
        local   Model   = VehNode.GetAttribute("model").Int,
                World   = VehNode.GetAttribute("world").Int,
                PosX    = VehNode.GetAttribute("x").Float,
                PosY    = VehNode.GetAttribute("y").Float,
                PosZ    = VehNode.GetAttribute("z").Float,
                Angle   = VehNode.GetAttribute("angle").Float,
                Col1    = VehNode.GetAttribute("col1").Int,
                Col2    = VehNode.GetAttribute("col2").Int;
                    
        SqVehicle.CreateEx(Model, World, PosX, PosY, PosZ, Angle, Col1, Col2);

        Info.VehCount++;
        VehNode = VehNode.GetNextSibling("Vehicle");
    }

    // ------------------------------------------------------- //
    // Vehicles

    local PickNode = Doc.Node.Name == "Pickup" ? Doc.Node : Doc.Node.GetNextSibling("Pickup");
    while(!PickNode.Empty)
    {
        local   Model   = PickNode.GetAttribute("model").Int,
                World   = PickNode.GetAttribute("world").Int,
                PosX    = PickNode.GetAttribute("x").Float,
                PosY    = PickNode.GetAttribute("y").Float,
                PosZ    = PickNode.GetAttribute("z").Float;
                    
        SqPickup.CreateEx(Model, World, 1, PosX, PosY, PosZ, 255, true);

        PickNode = PickNode.GetNextSibling("Pickup");
        Info.PickupCount++;
    }

    // ------------------------------------------------------- //
    // Classes

    local ClassNode = Doc.Node.Name == "Class" ? Doc.Node : Doc.Node.GetNextSibling("Class");
    while(!ClassNode.Empty)
    {
        local   Team    = ClassNode.GetAttribute("team").Int,
                Skin    = ClassNode.GetAttribute("skin").Int,

                PosX    = ClassNode.GetAttribute("x").Float,
                PosY    = ClassNode.GetAttribute("y").Float,
                PosZ    = ClassNode.GetAttribute("z").Float,
                Angle   = ClassNode.GetAttribute("angle").Float,

                Wep1    = ClassNode.GetAttribute("wep1").Int,
                Ammo1   = ClassNode.GetAttribute("ammo1").Int,
                Wep2    = ClassNode.GetAttribute("wep2").Int,
                Ammo2   = ClassNode.GetAttribute("ammo2").Int,
                Wep3    = ClassNode.GetAttribute("wep3").Int,
                Ammo3   = ClassNode.GetAttribute("ammo3").Int,

                R       = ClassNode.GetAttribute("r").Int,
                G       = ClassNode.GetAttribute("g").Int,
                B       = ClassNode.GetAttribute("b").Int;
                    
        SqServer.AddPlayerClass(Team, Color3(R, G, B), Skin, Vector3(PosX, PosY, PosZ), Angle,
                        Wep1, Ammo1, Wep2, Ammo2, Wep3, Ammo3);

        Info.ClassCount++;
        ClassNode = ClassNode.GetNextSibling("Class");
    }

    // ------------------------------------------------------- //
    // Display information

    if(LogInfo)
    {
        SqLog.Scs("[CONF] Loaded '{}'", Path);

        if(Info.Settings)           SqLog.Inf("  > Applied settings.")
        if(Info.VehCount > 0)       SqLog.Inf("  > Loaded {} vehicles.", Info.VehCount);
        if(Info.ClassCount > 0)     SqLog.Inf("  > Loaded {} spawn classes.", Info.ClassCount);
        if(Info.PickupCount > 0)    SqLog.Inf("  > Loaded {} pickups.", Info.PickupCount);
    }
}