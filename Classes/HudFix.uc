//-----------------------------------------------------------
//
//  Quick fix for OLTeamGames' HUD for v3374 by Piglet
//
//  piglet@miasma.rocks 
//
//  https://discord.gg/xjvMaNBh53
//
//-----------------------------------------------------------
class HudFix extends Mutator;

function PostBeginPlay()
{
	local string HudType;

	HudType = Level.Game.HUDType;

	if(HUDType ~= "OLTeamGames.HudOLCaptureTheFlag"){
		Level.Game.HUDType = string(class'FixHudOLCaptureTheFlag');
	}
	else if(HUDType ~= "OLTeamGames.HUDOLTeamDeathMatch"){
		Level.Game.HUDType = string(class'FixHudOLTeamDeathmatch');
	}
} 

DefaultProperties
{
    bAddToServerPackages=True
	GroupName="HUD"
    FriendlyName="Fix CTF4/DM4 HUD"
}