Class FixHudOLCaptureTheFlag extends HudOLCaptureTheFlag;

var bool bWSD;		// Is widescreen support default in the game code?
function PostBeginPlay()
{
	SetTimer(0.1, true);
	Super.PostBeginPlay();
}

function Timer()	// Allows LevelInfo enough time to set up. In practice it shouldn't actually loop
{
    if (PlayerOwner != None && PlayerOwner.Level != None && PlayerOwner.Level.EngineVersion != "")
    {
		if (int(PlayerOwner.Level.EngineVersion) >= 3374)
		{
			bWSD = True;
		}
	
        SetTimer(0.0, false);
        return;
    }
}

simulated function DrawWeaponBar( Canvas C )
{
    local int i, Pos;
	local float HudMinScale;
    local Weapon Weapons[WEAPON_BAR_SIZE];
    local byte ExtraWeapon[WEAPON_BAR_SIZE];
    local Weapon W, PendingWeapon;

	if (!bWSD)
	{
		Super.DrawWeaponBar( C );
		return;
	}

	HudMinScale=0.5;
	// CurHudScale = HudScale;
    //no weaponbar for vehicles
    if (Vehicle(PawnOwner) != None)
		return;

    if (PawnOwner.PendingWeapon != None)
        PendingWeapon = PawnOwner.PendingWeapon;
    else
        PendingWeapon = PawnOwner.Weapon;

	// fill:
	foreach PawnOwner.AllInventory(class'Weapon',W)
    {
        if( W.IconMaterial == None )
            continue;

		if ( W.InventoryGroup == 0 )
			Pos = 8;
		else if ( W.InventoryGroup < 10 )
			Pos = W.InventoryGroup-1;
		else
			continue;

		if ( Weapons[Pos] != None )
			ExtraWeapon[Pos] = 1;
		else
			Weapons[Pos] = W;
    }

	if ( PendingWeapon != None )
	{
		if ( PendingWeapon.InventoryGroup == 0 )
			Weapons[8] = PendingWeapon;
		else if ( PendingWeapon.InventoryGroup < 10 )
			Weapons[PendingWeapon.InventoryGroup-1] = PendingWeapon;
	}

    // Draw:
    for( i=0; i<WEAPON_BAR_SIZE; i++ )
    {
        W = Weapons[i];

        BarBorder[i].Tints[0] = OLHudColorTeam[OLTeamIndex];
        BarBorder[i].Tints[1] = OLHudColorTeam[OLTeamIndex];
        BarBorder[i].OffsetY = 0;
		BarWeaponIcon[i].OffsetY = default.BarWeaponIcon[i].OffsetY;

		if( W == none )
        {
			BarWeaponStates[i].HasWeapon = false;
			if ( bShowMissingWeaponInfo )
			{
				if ( BarWeaponIcon[i].Tints[0] != HudColorBlack )
				{
					BarWeaponIcon[i].WidgetTexture = default.BarWeaponIcon[i].WidgetTexture;
					BarWeaponIcon[i].TextureCoords = default.BarWeaponIcon[i].TextureCoords;
					BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale;
					BarWeaponIcon[i].Tints[0] = HudColorBlack;
					BarWeaponIcon[i].Tints[1] = HudColorBlack;
					BarWeaponIconAnim[i] = 0;
				}
				DrawSpriteWidget( C, BarBorder[i] );
				DrawSpriteWidget( C, BarWeaponIcon[i] ); // FIXME- have combined version
			}
       }
        else
        {
			if( !BarWeaponStates[i].HasWeapon )
			{
				// just picked this weapon up!
				BarWeaponStates[i].PickupTimer = Level.TimeSeconds;
				BarWeaponStates[i].HasWeapon = true;
			}

	    	BarBorderAmmoIndicator[i].PosX = BarBorder[i].PosX;
			BarBorderAmmoIndicator[i].OffsetY = 0;
			BarWeaponIcon[i].WidgetTexture = W.IconMaterial;
			BarWeaponIcon[i].TextureCoords = W.IconCoords;

            BarBorderAmmoIndicator[i].Scale = W.AmmoStatus();
            BarWeaponIcon[i].Tints[0] = HudColorNormal;
			BarWeaponIcon[i].Tints[1] = HudColorNormal;

			if( BarWeaponIconAnim[i] == 0 )
            {
                if ( BarWeaponStates[i].PickupTimer > Level.TimeSeconds - 0.6 )
	            {
		           if ( BarWeaponStates[i].PickupTimer > Level.TimeSeconds - 0.3 )
	               {
					   	BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale * (1 + 1.3 * (Level.TimeSeconds - BarWeaponStates[i].PickupTimer));
                   }
                   else
                   {
					    BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale * (1 + 1.3 * (BarWeaponStates[i].PickupTimer + 0.6 - Level.TimeSeconds));
                   }
					BarWeaponIcon[i].OffsetX = Round(default.BarWeaponIcon[i].OffsetX * default.BarWeaponIcon[i].TextureScale / BarWeaponIcon[i].TextureScale);
                }
                else
                {
                    BarWeaponIconAnim[i] = 1;
                    BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale;
					BarWeaponIcon[i].OffsetX = default.BarWeaponIcon[i].OffsetX;
				}
			}

            if (W == PendingWeapon)
            {
				// Change color to highlight and possibly changeTexture or animate it
				BarBorder[i].Tints[0] = HudColorHighLight;
				BarBorder[i].Tints[1] = HudColorHighLight;
				BarBorder[i].OffsetY = -10;
				BarBorderAmmoIndicator[i].OffsetY = -10;
				BarWeaponIcon[i].OffsetY += -10;
			}
		    if ( ExtraWeapon[i] == 1 )
		    {
			    if ( W == PendingWeapon )
			    {
                    BarBorder[i].Tints[0] = HudColorTeam[OLTeamIndex];
                    BarBorder[i].Tints[1] = HudColorTeam[OLTeamIndex];
				    BarBorder[i].OffsetY = 0;
				    BarBorder[i].TextureCoords.Y1 = 80;
				    DrawSpriteWidget( C, BarBorder[i] );
				    BarBorder[i].TextureCoords.Y1 = 39;
				    BarBorder[i].OffsetY = -10;
				    BarBorder[i].Tints[0] = HudColorHighLight;
				    BarBorder[i].Tints[1] = HudColorHighLight;
			    }
			    else
			    {
				    BarBorder[i].OffsetY = -52;
				    BarBorder[i].TextureCoords.Y2 = 48;
		            DrawSpriteWidget( C, BarBorder[i] );
				    BarBorder[i].TextureCoords.Y2 = 93;
				    BarBorder[i].OffsetY = 0;
			    }
		    }
	        DrawSpriteWidget( C, BarBorder[i] );
            DrawSpriteWidget( C, BarBorderAmmoIndicator[i] );
            DrawSpriteWidget( C, BarWeaponIcon[i] );
       }
    }
}