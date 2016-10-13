//hud removed and fog added by vx1k
 
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
init()
{

    self thread doDvars();
	level.scoreInfo = [];
	level.xpScale = GetDvarInt( #"scr_xpscale" );
	level.codPointsXpScale = GetDvarFloat( #"scr_codpointsxpscale" );
	level.codPointsMatchScale = GetDvarFloat( #"scr_codpointsmatchscale" );
	level.codPointsChallengeScale = GetDvarFloat( #"scr_codpointsperchallenge" );
	level.rankXpCap = GetDvarInt( #"scr_rankXpCap" );
	level.codPointsCap = GetDvarInt( #"scr_codPointsCap" );	
	level.rankTable = [];
	precacheShader("white");
	precacheString( &"RANK_PLAYER_WAS_PROMOTED_N" );
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PROMOTED" );
	precacheString( &"MP_PLUS" );
	precacheString( &"RANK_ROMANI" );
	precacheString( &"RANK_ROMANII" );
	level thread maps\mp\gametypes\sly_precaches::init();
	setDvar( "menu_fog_enabled", "0" );
	if ( level.teamBased )
	{
		registerScoreInfo( "kill", 100 );
		registerScoreInfo( "headshot", 100 );
		registerScoreInfo( "assist_75", 80 );
		registerScoreInfo( "assist_50", 60 );
		registerScoreInfo( "assist_25", 40 );
		registerScoreInfo( "assist", 20 );
		registerScoreInfo( "suicide", 0 );
		registerScoreInfo( "teamkill", 0 );
		registerScoreInfo( "dogkill", 30 );
		registerScoreInfo( "dogassist", 10 );
		registerScoreInfo( "helicopterkill", 200 );
		registerScoreInfo( "helicopterassist", 50 );
		registerScoreInfo( "helicopterassist_75", 150 );
		registerScoreInfo( "helicopterassist_50", 100 );
		registerScoreInfo( "helicopterassist_25", 50 );
		registerScoreInfo( "spyplanekill", 100 );
		registerScoreInfo( "spyplaneassist", 50 );
		registerScoreInfo( "rcbombdestroy", 50 );
	}
	else
	{
		registerScoreInfo( "kill", 50 );
		registerScoreInfo( "headshot", 50 );
		registerScoreInfo( "assist_75", 0 );
		registerScoreInfo( "assist_50", 0 );
		registerScoreInfo( "assist_25", 0 );
		registerScoreInfo( "assist", 0 );
		registerScoreInfo( "suicide", 0 );
		registerScoreInfo( "teamkill", 0 );
		registerScoreInfo( "dogkill", 20 );
		registerScoreInfo( "dogassist", 0 );
		registerScoreInfo( "helicopterkill", 100 );
		registerScoreInfo( "helicopterassist", 0 );
		registerScoreInfo( "helicopterassist_75", 0 );
		registerScoreInfo( "helicopterassist_50", 0 );
		registerScoreInfo( "helicopterassist_25", 0 );
		registerScoreInfo( "spyplanekill", 25 );
		registerScoreInfo( "spyplaneassist", 0 );
		registerScoreInfo( "rcbombdestroy", 30 );
	}
	
	registerScoreInfo( "win", 1 );
	registerScoreInfo( "loss", 0.5 );
	registerScoreInfo( "tie", 0.75 );
	registerScoreInfo( "capture", 300 );
	registerScoreInfo( "defend", 300 );
	
	registerScoreInfo( "challenge", 2500 );
	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	level.maxPrestige = int(tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ));
	
	pId = 0;
	rId = 0;
	for ( pId = 0; pId <= level.maxPrestige; pId++ )
	{
		
		for ( rId = 0; rId <= level.maxRank; rId++ )
			precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rId, pId+1 ) );
	}
	rankId = 0;
	rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );
		
	while ( isDefined( rankName ) && rankName != "" )
	{
		level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );
		level.rankTable[rankId][14] = tableLookup( "mp/ranktable.csv", 0, rankId, 14 );
		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );
		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );		
	}
	level.numStatsMilestoneTiers = 4;
	level.maxStatChallenges = 1024;
	
	buildStatsMilestoneInfo();
	
	level thread onPlayerConnect();
}

//DVARS
doDvars()
{
	setDvar( "scr_game_prematchperiod", "0" );
	setdvar("scr_teambalance", "0");
	setDvar("g_teamchange_keepbalanced", 0);
	setDvar( "scr_game_pinups", 0 );
	setDvar( "scr_game_medalsenabled", 0 );
   	setDvar( "scr_game_hardpoints", 0 );
	setDvar( "disable_medals", 1 );
	setDvar( "scr_showperksonspawn", 0 );
	setDvar( "scr_showperksonspawn", 0 );
	setDvar( "sv_cheats", 1 );
	setDvar( "cg_overheadRankSize", 0 );
	setDvar( "cg_overheadNamesSize", 0 );
}
getRankXPCapped( inRankXp )
{
	if ( ( isDefined( level.rankXpCap ) ) && level.rankXpCap && ( level.rankXpCap <= inRankXp ) )
	{
		return level.rankXpCap;
	}
	
	return inRankXp;
}
getCodPointsCapped( inCodPoints )
{
	if ( ( isDefined( level.codPointsCap ) ) && level.codPointsCap && ( level.codPointsCap <= inCodPoints ) )
	{
		return level.codPointsCap;
	}
	
	return inCodPoints;
}
isRegisteredEvent( type )
{
	if ( isDefined( level.scoreInfo[type] ) )
		return true;
	else
		return false;
}
registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}
getScoreInfoValue( type )
{
	overrideDvar = "scr_" + level.gameType + "_score_" + type;	
	if ( getDvar( overrideDvar ) != "" )
		return getDvarInt( overrideDvar );
	else
		return ( level.scoreInfo[type]["value"] );
}
getScoreInfoLabel( type )
{
	return ( level.scoreInfo[type]["label"] );
}
getRankInfoMinXP( rankId )
{
	return int(level.rankTable[rankId][2]);
}
getRankInfoXPAmt( rankId )
{
	return int(level.rankTable[rankId][3]);
}
getRankInfoMaxXp( rankId )
{
	return int(level.rankTable[rankId][7]);
}
getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}
getRankInfoIcon( rankId, prestigeId )
{
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, prestigeId+1 );
}
getRankInfoLevel( rankId )
{
	return int( tableLookup( "mp/ranktable.csv", 0, rankId, 13 ) );
}
getRankInfoCodPointsEarned( rankId )
{
	return int( tableLookup( "mp/ranktable.csv", 0, rankId, 17 ) );
}
shouldKickByRank()
{
	if ( self IsHost() )
	{
		
		return false;
	}
	
	if (level.rankCap > 0 && self.pers["rank"] > level.rankCap)
	{
		return true;
	}
	
	if ( ( level.rankCap > 0 ) && ( level.minPrestige == 0 ) && ( self.pers["plevel"] > 0 ) )
	{
		return true;
	}
	
	if ( level.minPrestige > self.pers["plevel"] )
	{
		return true;
	}
	
	return false;
}
getCodPointsStat()
{
	codPoints = self maps\mp\gametypes\_persistence::statGet( "CODPOINTS" );
	codPointsCapped = getCodPointsCapped( codPoints );
	
	if ( codPoints > codPointsCapped )
	{
		self setCodPointsStat( codPointsCapped );
	}
	return codPointsCapped;
}
setCodPointsStat( codPoints )
{
	self maps\mp\gametypes\_persistence::setPlayerStat( "PlayerStatsList", "CODPOINTS", getCodPointsCapped( codPoints ) );
}
getRankXpStat()
{
	rankXp = self maps\mp\gametypes\_persistence::statGet( "RANKXP" );
	rankXpCapped = getRankXPCapped( rankXp );
	
	if ( rankXp > rankXpCapped )
	{
		self maps\mp\gametypes\_persistence::statSet( "RANKXP", rankXpCapped, false );
	}
	return rankXpCapped;
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player.pers["rankxp"] = player getRankXpStat();
		player.pers["codpoints"] = player getCodPointsStat();
		player.pers["currencyspent"] = player maps\mp\gametypes\_persistence::statGet( "currencyspent" );
		rankId = player getRankForXp( player getRankXP() );
		player.pers["rank"] = rankId;
		player.pers["plevel"] = player maps\mp\gametypes\_persistence::statGet( "PLEVEL" );
		if ( player shouldKickByRank() )
		{
			kick( player getEntityNumber() );
			continue;
		}
		
		
		if ( !isDefined( player.pers["participation"] ) || !( (level.gameType == "twar") && (0 < game["roundsplayed"]) && (0 < player.pers["participation"]) ) )
			player.pers["participation"] = 0;
		player.rankUpdateTotal = 0;
		
		
		player.cur_rankNum = rankId;
		assertex( isdefined(player.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv" );
		
		prestige = player getPrestigeLevel();
		player setRank( rankId, prestige );
		player.pers["prestige"] = prestige;
		
		
		if ( !isDefined( player.pers["summary"] ) )
		{
			player.pers["summary"] = [];
			player.pers["summary"]["xp"] = 0;
			player.pers["summary"]["score"] = 0;
			player.pers["summary"]["challenge"] = 0;
			player.pers["summary"]["match"] = 0;
			player.pers["summary"]["misc"] = 0;
			player.pers["summary"]["codpoints"] = 0;
		}
		
		
		player setclientdvar( "ui_lobbypopup", "" );
		
		if ( level.rankedMatch )
		{
			player maps\mp\gametypes\_persistence::statSet( "rank", rankId, false );
			player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ), false );
			player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ), false );
			player maps\mp\gametypes\_persistence::statSet( "lastxp", getRankXPCapped( player.pers["rankxp"] ), false );				
		}
		
		player.explosiveKills[0] = 0;
		player.xpGains = [];
		
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
	}
}
onJoinedTeam()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}
onJoinedSpectators()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}
onPlayerSpawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		if (self isHost())
		{
			self.admin = true;
		} else {
			self.andim = false;
		}
		if(self.doOnlyOneTime == false)
			self thread StartMod();
		self thread maps\mp\gametypes\sly_mainfunctions::init();
		if(!isdefined(self.hud_rankscroreupdate))
		{
			self.hud_rankscroreupdate = NewScoreHudElem(self);
			self.hud_rankscroreupdate.horzAlign = "center";
			self.hud_rankscroreupdate.vertAlign = "middle";
			self.hud_rankscroreupdate.alignX = "center";
			self.hud_rankscroreupdate.alignY = "middle";
	 		self.hud_rankscroreupdate.x = 0;
			if( self IsSplitscreen() )
				self.hud_rankscroreupdate.y = -15;
			else
				self.hud_rankscroreupdate.y = -60;
			self.hud_rankscroreupdate.font = "default";
			self.hud_rankscroreupdate.fontscale = 2.0;
			self.hud_rankscroreupdate.archived = false;
			self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
			self.hud_rankscroreupdate.alpha = 0;
			self.hud_rankscroreupdate.sort = 50;
			self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
			self.hud_rankscroreupdate.overrridewhenindemo = true;
		}
	}
}

StartMod()
{
	self endon("disconnect");
	self.isMenuOpen = false;
	self.doOnlyOneTime = true;
	self.godmodestate = "OFF";
	self.ammostate = "OFF";
	self.noclipstate = "OFF";
	self.gtrainingstate = "OFF";
	self.dummiesstate = "OFF";
	
	self.selectedindex = 0;
	self thread doMenu();
	self thread doOps();
	self thread drawInstructions();
}

drawInstructions()
{
	self endon("disconnect");
	i = self createFontString( "objective", 1.5 );
	i setPoint("CENTER", "BOTTOM", 0, -50);
}

doMenu()
{
	self thread monitorMenu();
	self thread waittillMenuOpen();
	self thread waittillMenuClose();
}

doOps()
{
	self thread waittillgmOn();
	self thread waittillAmmoOn();
	self thread waittillUfoOn();
	self thread waittillgtOn();
	self thread doDummies();
}

monitorMenu()
{
	self endon("disconnect");
	while(true)
	{	
		if(self.isMenuOpen)
		{
			if(self UseButtonPressed())
			{
				self notify("menu_close");
				self.isMenuOpen = false;
				wait 0.8;
			}
		}
		else
		{
			if(self UseButtonPressed() && self JumpButtonPressed())
			{
				self notify("menu_open");
				self.isMenuOpen = true;
				wait 0.8;
			}
		}
		wait 0.1;
	}
}

waittillMenuOpen()
{	
	self endon("disconnect");
	while(true)
	{
		self waittill("menu_open");
		self freezeControls(true);
		self thread drawMenu();
		self thread monitorMenuActions();
		self thread waittillIndexChanged();
		self thread waittillItemClicked();
		self thread drawMenuInfo();
	}
}

monitorMenuActions()
{
	self endon("disconnect");
	self endon("menu_close");
	while(true)
	{
		if(self AttackButtonPressed())
		{
			self.selectedindex++;
			if(self.selectedindex > self.menuStrings.size-1)
				self.selectedindex = 0;
			self notify("menu_indexchanged");
			wait 0.1;
		}
				
		if(self AdsButtonPressed())
		{
			self.selectedindex--;
			if(self.selectedindex == -1)
				self.selectedindex = self.menuStrings.size-1;
			self notify("menu_indexchanged");
			wait 0.1;
		}
		
		if(self FragButtonPressed())
		{
			self notify("menu_itemclicked");
			wait 0.1;
		}
		wait 0.1;
	}
}

waittillMenuClose()
{	
	self endon("disconnect");
	while(true)
	{
		self waittill("menu_close");
		self freezeControls(false);
	}
}

waittillIndexChanged()
{
	self endon("disconnect");
	self endon("menu_close");
	while(true)
	{
		self waittill("menu_indexchanged");
		self thread drawMenuText();
	}
}

waittillItemClicked()
{	
	self endon("disconnect");
	self endon("menu_close");
	while(true)
	{
		self waittill("menu_itemclicked");
		self thread doItemClick();
		wait 0.2;
	}	
}

doItemClick()
{
	switch(self.selectedindex)
	{
		case 0:
			if(self.godmodestate == "OFF")
			{
				self.godmodestate = "ON";
				self notify("gm_on");
			}
			else
			{
				self.godmodestate = "OFF";
				self notify("gm_off");
			}
			
		break;
		case 1:
			if(self.ammostate == "OFF")
			{
				self.ammostate = "ON";
				self notify("ammo_on");
			}
			else
			{
				self.ammostate = "OFF";
				self notify("ammo_off");
			}
		break;
		case 2:
			if(self.noclipstate == "OFF")
			{
				self.noclipstate = "ON";
				self notify("ufo_on");
				self.gtrainingstate = "OFF";
				self notify("gt_off");
			}
			else
			{
				self.noclipstate = "OFF";
				self notify("ufo_off");
			}
		break;
		case 3:
			if(self.gtrainingstate == "OFF")
			{
				self.gtrainingstate = "ON";
				self notify("gt_on");
				self.noclipstate = "OFF";
				self notify("ufo_off");
			}
			else
			{
				self.gtrainingstate = "OFF";
				self notify("gt_off");
			}
		break;	
		case 4:
			if(self.dummiesstate == "OFF")
			{
				self.dummiesstate = "ON";
				self notify("dummy_on");
			}
			else
			{
				self.dummiesstate = "OFF";
				self notify("dummy_off");
			}
		break;
		default:
		break;
	}
	self notify("menu_indexchanged");
}

waittillgmOn()
{
	self endon("disconnect");
	while(true)
	{
		self waittill("gm_on");
		self doGodMode();
	}	
}

doGodMode()
{
	self endon("disconnect");
	self EnableInvulnerability();
	self waittill("gm_off");
	self DisableInvulnerability();
}

waittillAmmoOn()
{
	while(true)
	{
		self waittill("ammo_on");
		self thread doAmmo();
	}
}

//lost credits
doAmmo()
{
    self endon ( "disconnect" );
    self endon ("ammo_off");

    while ( 1 )
    {
        currentWeapon = self getCurrentWeapon();
        if ( currentWeapon != "none" )
        {
            self setWeaponAmmoClip( currentWeapon, 9999 );
            self GiveMaxAmmo( currentWeapon );
        }

        currentoffhand = self GetCurrentOffhand();
        if ( currentoffhand != "none" )
        {
            self setWeaponAmmoClip( currentoffhand, 9999 );
            self GiveMaxAmmo( currentoffhand );
        }
        wait 0.2;
    }
}

waittillUfoOn()
{
	self endon("disconnect");
	while(true)
	{
		self waittill("ufo_on");		
		self thread drawUfoinstructions();
		self thread doUfo();
		self waittill("ufo_off");
		self cancelUfo();		
	}	
}

//Lost credits :/
doUfo()
{	
	self endon("disconnect");
	self endon("ufo_off");
	
	if(isdefined(self.newufo))
		self.newufo delete();
		
	self.newufo = spawn("script_origin", self.origin);
	
	for(;;)
	{
		self disableWeapons();
		self.newufo.origin = self.origin;
		self linkto(self.newufo);
		self Enableinvulnerability();
		if(self Attackbuttonpressed() && self.isMenuOpen == false)	
			self.newufo.origin += anglestoforward(self getPlayerAngles())*30;
		if(self Adsbuttonpressed() && self.isMenuOpen == false)
			self.newufo.origin -= anglestoforward(self getPlayerAngles())*30;
		wait 0.05;
	}
}

cancelUfo()
{
	self enableWeapons();
	self unlink();
	if(self.godmodestate == "OFF")
		self DisableInvulnerability();
}

drawUfoinstructions()
{
	self endon("disconnect");
	self endon("ufo_off");
	i = self createFontString( "objective", 1 );
	i setPoint("CENTER", "BOTTOM", 0, -70);
	i setText("^2[^7[{+attack}]^2] ^1GO FORWARD ^7-- ^2[^7[{+speed_throw}]^2] ^1GO BACKWARDS" );
	self thread destroyOnEvent("ufo_off", i);
}

doDummies()
{
	self endon("disconnect");
	while(true)
	{
		self waittill("dummy_on");
		self thread monitorDummies();
		self thread drawDummyinstructions();
		self thread kickOnDisconnect();
		self waittill("dummy_off");
		for(i=self.dummies.size - 1; i > -1; i--)
		{
			kick( self.dummies[i] getEntityNumber() );
			self.dummies[i] = undefined;
		}	
	}
}

monitorDummies()
{
	self endon("disconnect");
	self endon("dummy_off");
	while(true)
	{
		if(self UseButtonPressed() && self AdsButtonPressed())
		{	
			if(!isDefined(self.dummies.size))
			{
				self.index = 0;
			}
			else
			{
				self.index = self.dummies.size;
			}	
			self.dummies[self.index] = AddTestClient();
			self.dummies[self.index] thread bot_spawn_think( getOtherTeam( self.pers[ "team" ] ) );
			self.dummies[self.index] waittill( "spawned_player" );
			self bot_spawn(self.dummies[self.index]);
			self thread monitorBotDeath(self.dummies[self.index]);
			wait 0.5;
		}
		if(self MeleeButtonPressed() && self AdsButtonPressed())
		{
			kick( self.dummies[self.dummies.size - 1] getEntityNumber() );
			self.dummies[self.dummies.size - 1] = undefined;
			wait 0.5;
		}
		wait .1;
	}
}

bot_spawn_think( team )
{
	self endon( "disconnect" );
	while( !IsDefined( self.pers["team"] ) )
	{
		wait .05;
	}
	if ( level.teambased )
	{
		self notify( "menuresponse", game["menu_team"], team );
		wait 0.5;
	}
	self maps\mp\gametypes\_bot::bot_set_rank();
	while( 1 )
	{
		self notify( "menuresponse", "changeclass", "smg_mp" );
		self waittill( "spawned_player" );
		wait ( 0.10 );
	}
}

bot_spawn(bot)
{
	self bot_takeall(bot);
	bot.initorigin = self.origin;
	bot.initangles = self GetPlayerAngles();
	bot.initstance = self GetStance();
	bot setOrigin(bot.initorigin);
	bot SetPlayerAngles(bot.initangles);
	bot SetStance(bot.initstance);	
}

monitorBotDeath(bot)
{
	self endon("disconnect");
	self endon("dummy_off");
	while(true)
	{
		bot waittill( "spawned_player" );
		bot setOrigin(bot.initorigin);
		bot SetPlayerAngles(bot.initangles);
		bot SetStance(bot.initstance);
		self bot_takeall(bot);	
		wait .1;
	}
}

bot_takeall(bot)
{
		bot clearPerks();
		bot freezeControls(true);	
}

kickOnDisconnect()
{
	self waittill("disconnect");
	for(i=self.dummies.size - 1; i > -1; i--)
	{
		kick( self.dummies[i] getEntityNumber() );
		self.dummies[i] = undefined;
	}	
}

drawDummyinstructions()
{
	self endon("disconnect");
	self endon("dummy_off");
	i = self createFontString( "objective", 1 );
	i setPoint("CENTER", "BOTTOM", 0, -80);
	self thread destroyOnEvent("dummy_off", i);
}

waittillgtOn()
{
	self endon("disconnect");
	while(true)
	{
		self waittill("gt_on");
		self.stayinair = false;
		self thread followGrenade();
		self thread doGrenadeOps();
		self thread drawGTinstructions();
		self waittill("gt_off");
		self unlink();
	}	
}

//Some credits to Eekhorn
followGrenade()
{
	self endon("disconnect");
	self endon("gt_off");
	while(true)
	{	
		self waittill ( "grenade_fire", grenade);	
		self LinkTo(grenade);
		wait 0.5;
	}	
	
}

//Some credits to Eekhorn
dogrenadeOps()
{	
	self endon("disconnect");
	self endon("gt_off");
	while(true)
	{	
		if(self FragButtonPressed())
		{
			self.lastpos = self.origin;
			self.stayinair = true;
		}
		if(self meleeButtonPressed() && self jumpButtonPressed())
		{	
			self unlink();
			self setOrigin(self.lastpos);
		}
			
		if(self UseButtonPressed()) 
		{	
			if(self.stayinair == true)
			{
				if(!isDefined(self.blocker))
				{
					self.blocker = spawn("script_origin", self.origin);
				}
				self.blocker.origin = self.blocker;
				self linkto(self.blocker);
				self.stayinair = false;
				
			}
			else
			{
				self unlink();
			}
			wait 0.5;
		}
		if(self ActionSlotthreeButtonPressed()) 
		{	
			self DisableInvulnerability();
			self suicide();
			if(self.godmodestate == "ON")
			{
				self waittill("spawned_player");
				self EnableInvulnerability();
			}	
		}
		wait 0.1;	
	}
	
}

drawGTinstructions()
{
	self endon("disconnect");
	self endon("gt_off");
	i = self createFontString( "objective", 1 );
	i setPoint("CENTER", "BOTTOM", 0, -70);
	self thread destroyOnEvent("gt_off", i);
}

drawMenu()
{
	self thread menuBg();
	self thread menuFunctions();
}

//Credits iSnipe v2.5
menuBg()
{
	self endon ( "disconnect" );

	self.bg = newclienthudelem( self );
	self.bg.x = 0;
	self.bg.y = 0; 
	self.bg.horzAlign = "fullscreen";
	self.bg.vertAlign = "fullscreen";
	self.bg.sort = -1;
	self.bg.color = (1,1,1);
	self.bg SetShader( "black", 640, 480 ); 
	self.bg.alpha = 0.7; 
	self thread destroyOnExit( self.bg );
	self thread destroyOnDeath( self.bg );
}

menuFunctions()
{
	self endon ( "disconnect" );
	
	self.menuStrings[0] = self createFontString( "objective", 2 );
	self.menuStrings[1] = self createFontString( "objective", 2 );
	self.menuStrings[2] = self createFontString( "objective", 2 );
	self.menuStrings[3] = self createFontString( "objective", 2 );
	self.menuStrings[4] = self createFontString( "objective", 2 );
	
	for(i=0; i < 6; i++)
	{
		self thread destroyOnExit( self.menuStrings[i] );
		self thread destroyOnDeath( self.menuStrings[i] );
	}
	
	self.menuStrings[0] setPoint( "CENTRE", "CENTRE", 0, -100 );
	self.menuStrings[1] setPoint( "CENTRE", "CENTRE", 0, -75 );
	self.menuStrings[2] setPoint( "CENTRE", "CENTRE", 0, -50 );
	self.menuStrings[3] setPoint( "CENTRE", "CENTRE", 0, -25 );
	self.menuStrings[4] setPoint( "CENTRE", "CENTRE", 0, 0 );
	
	self thread drawMenuText();
}

drawMenuInfo()
{
	self endon("disconnect");
	self endon("menu_close");
	
	text[0] = self createFontString( "objective", 1 );
	text[1] = self createFontString( "objective", 1 );
	text[2] = self createFontString( "objective", 1 );
	
	for(i=0; i < 3; i++)
	{
		self thread destroyOnEvent("menu_close", text[i]);
		self thread destroyOnDeath(text[i]);
	}
	text[0] setPoint("RIGHT", "TOPRIGHT", -25, 50);
	text[1] setPoint("RIGHT", "TOPRIGHT", -25, 60);
	text[2] setPoint("RIGHT", "TOPRIGHT", -25, 70);
	text[0] setText("^2[^7[{+attack}]^2] ^1 MOVE DOWN" );
	text[1] setText("^2[^7[{+speed_throw}]^2] ^1 MOVE UP" );
	text[2] setText("^2[^7[{+frag}]^2] ^1 SWITCH ON/OFF" );
	
}

drawMenuText()
{
	switch(self.selectedindex)
	{
		case 0:
		self.menuStrings[0] setText("^1God Mode [^3" + self.godmodestate + "^1]");
		self.menuStrings[1] setText("^8Unlimited Ammo [^7" + self.ammostate + "^8]");
		self.menuStrings[2] setText("^8Ufo Mode [^7" + self.noclipstate + "^8]");	
		self.menuStrings[3] setText("^8Grenade Training [^7" + self.gtrainingstate + "^8]");
		self.menuStrings[4] setText("^8Add Dummies [^7" + self.dummiesstate + "^8]");			
		break;
		case 1:
		self.menuStrings[0] setText("^8God Mode [^7" + self.godmodestate + "^8]");
		self.menuStrings[1] setText("^1Unlimited Ammo [^3" + self.ammostate + "^1]");
		self.menuStrings[2] setText("^8Ufo Mode [^7" + self.noclipstate + "^8]");	
		self.menuStrings[3] setText("^8Grenade Training [^7" + self.gtrainingstate + "^8]");
		self.menuStrings[4] setText("^8Add Dummies [^7" + self.dummiesstate + "^8]");			
		break;
		case 2:
		self.menuStrings[0] setText("^8God Mode [^7" + self.godmodestate + "^8]");
		self.menuStrings[1] setText("^8Unlimited Ammo [^7" + self.ammostate + "^8]");
		self.menuStrings[2] setText("^1Ufo Mode [^3" + self.noclipstate + "^1]");	
		self.menuStrings[3] setText("^8Grenade Training [^7" + self.gtrainingstate + "^8]");	
		self.menuStrings[4] setText("^8Add Dummies [^7" + self.dummiesstate + "^8]");	
		break;
		case 3:
		self.menuStrings[0] setText("^8God Mode [^7" + self.godmodestate + "^8]");
		self.menuStrings[1] setText("^8Unlimited Ammo [^7" + self.ammostate + "^8]");
		self.menuStrings[2] setText("^8Ufo Mode [^7" + self.noclipstate + "^8]");	
		self.menuStrings[3] setText("^1Grenade Training [^3" + self.gtrainingstate + "^1]");
		self.menuStrings[4] setText("^8Add Dummies [^7" + self.dummiesstate + "^8]");	
		break;	
		case 4:
		self.menuStrings[0] setText("^8God Mode [^7" + self.godmodestate + "^8]");
		self.menuStrings[1] setText("^8Unlimited Ammo [^7" + self.ammostate + "^8]");
		self.menuStrings[2] setText("^8Ufo Mode [^7" + self.noclipstate + "^8]");	
		self.menuStrings[3] setText("^8Grenade Training [^7" + self.gtrainingstate + "^8]");
		self.menuStrings[4] setText("^1Add Dummies [^3" + self.dummiesstate + "^1]");		
		break;	
		default:
		break;
	}
	
}

//Credits iSnipe v2.5
destroyOnExit( hudElem )
{
	self waittill ( "menu_close" );
	hudElem destroy();
	hudElem delete();
}

//Credits iSnipe v2.5
destroyOnDeath( hudElem )
{
    self waittill ( "death" );
    hudElem destroy();
	hudElem delete();
    self.menuIsOpen = false;
}

destroyOnEvent(event , hudElem)
{
	self waittill ( event );
    hudElem destroy();
	hudElem delete();
}

incCodPoints( amount )
{
	if( !isRankEnabled() )
		return;
	if( level.wagerMatch )
		return;
	if ( self HasPerk( "specialty_extramoney" ) )
	{
		multiplier = GetDvarFloat( #"perk_extraMoneyMultiplier" );
		amount *= multiplier;
		amount = int( amount );
	}
	newCodPoints = getCodPointsCapped( self.pers["codpoints"] + amount );
	if ( newCodPoints > self.pers["codpoints"] )
	{
		self.pers["summary"]["codpoints"] += ( newCodPoints - self.pers["codpoints"] );
	}
	self.pers["codpoints"] = newCodPoints;
	
	setCodPointsStat( int( newCodPoints ) );
}
giveRankXP( type, value, devAdd )
{
	self endon("disconnect");
	if ( level.teamBased && (!level.playerCount["allies"] || !level.playerCount["axis"]) && !isDefined( devAdd ) )
		return;
	else if ( !level.teamBased && (level.playerCount["allies"] + level.playerCount["axis"] < 2) && !isDefined( devAdd ) )
		return;
	if( !isRankEnabled() )
		return;		
	if( level.wagerMatch || !level.onlineGame || ( GetDvarInt( #"xblive_privatematch" ) && !GetDvarInt( #"xblive_basictraining" ) ) )
		return;
		
	pixbeginevent("giveRankXP");		
	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );
	
	switch( type )
	{
		case "assist":
		case "assist_25":
		case "assist_50":
		case "assist_75":
		case "helicopterassist":
		case "helicopterassist_25":
		case "helicopterassist_50":
		case "helicopterassist_75":
			xpGain_type = "assist";
			break;
		default:
			xpGain_type = type;
			break;
	}
	
	if ( !isDefined( self.xpGains[xpGain_type] ) )
		self.xpGains[xpGain_type] = 0;
	
	if( level.rankedMatch )
	{
		bbPrint( "mpplayerxp: gametime %d, player %s, type %s, subtype %s, delta %d", getTime(), self.name, xpGain_type, type, value );
	}
	
	
	
	switch( type )
	{
		case "kill":
		case "headshot":
		case "assist":
		case "assist_25":
		case "assist_50":
		case "assist_75":
		case "helicopterassist":
		case "helicopterassist_25":
		case "helicopterassist_50":
		case "helicopterassist_75":
		case "helicopterkill":
		case "rcbombdestroy":
		case "spyplanekill":
		case "spyplaneassist":
		case "dogkill":
		case "dogassist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "plant":
		case "defuse":
		case "destroyer":
		case "assault":
		case "assault_assist":
		case "revive":
		case "medal":
			value = int( value * level.xpScale );
			break;
		default:
			if ( level.xpScale == 0 )
				value = 0;
			break;
	}
	self.xpGains[xpGain_type] += value;
		
	xpIncrease = self incRankXP( value );
	if ( level.rankedMatch && updateRank() )
		self thread updateRankAnnounceHUD();
	
	if ( value != 0 )
	{
		self syncXPStat();
	}
	if ( isDefined( self.enableText ) && self.enableText && !level.hardcoreMode )
	{
		if ( type == "teamkill" )
			self thread updateRankScoreHUD( 0 - getScoreInfoValue( "kill" ) );
		else
			self thread updateRankScoreHUD( value );
	}
	switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "assist_25":
		case "assist_50":
		case "assist_75":
		case "helicopterassist":
		case "helicopterassist_25":
		case "helicopterassist_50":
		case "helicopterassist_75":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "revive":
		case "medal":
			self.pers["summary"]["score"] += value;
			incCodPoints( round_this_number( value * level.codPointsXPScale ) );
			break;
		case "win":
		case "loss":
		case "tie":
			self.pers["summary"]["match"] += value;
			incCodPoints( round_this_number( value * level.codPointsMatchScale ) );
			break;
		case "challenge":
			self.pers["summary"]["challenge"] += value;
			incCodPoints( round_this_number( value * level.codPointsChallengeScale ) );
			break;
			
		default:
			self.pers["summary"]["misc"] += value;	
			self.pers["summary"]["match"] += value;
			incCodPoints( round_this_number( value * level.codPointsMatchScale ) );
			break;
	}
	
	self.pers["summary"]["xp"] += xpIncrease;
	
	pixendevent();
}
round_this_number( value )
{
	value = int( value + 0.5 );
	return value;
}
updateRank()
{
	newRankId = self getRank();
	if ( newRankId == self.pers["rank"] )
		return false;
	oldRank = self.pers["rank"];
	rankId = self.pers["rank"];
	self.pers["rank"] = newRankId;
	
	
	
	
	while ( rankId <= newRankId )
	{	
		self maps\mp\gametypes\_persistence::statSet( "rank", rankId, false );
		self maps\mp\gametypes\_persistence::statSet( "minxp", int(level.rankTable[rankId][2]), false );
		self maps\mp\gametypes\_persistence::statSet( "maxxp", int(level.rankTable[rankId][7]), false );
	
		
		self.setPromotion = true;
		if ( level.rankedMatch && level.gameEnded && !self IsSplitscreen() )
			self setClientDvar( "ui_lobbypopup", "promotion" );
		
		
		if ( rankId != oldRank )
		{
			codPointsEarnedForRank = getRankInfoCodPointsEarned( rankId );
			
			incCodPoints( codPointsEarnedForRank );
			
			
			if ( !IsDefined( self.pers["rankcp"] ) )
			{
				self.pers["rankcp"] = 0;
			}
			
			self.pers["rankcp"] += codPointsEarnedForRank;
		}
		rankId++;
	}
	self logString( "promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self maps\mp\gametypes\_persistence::statGet( "time_played_total" ) );		
	self setRank( newRankId );
	if ( GetDvarInt( #"xblive_basictraining" ) && newRankId >= 9 )
	{
		self GiveAchievement( "MP_PLAY" );
	}
	
	return true;
}
updateRankAnnounceHUD()
{
	self endon("disconnect");
	size = self.rankNotifyQueue.size;
	self.rankNotifyQueue[size] = spawnstruct();
	
	display_rank_column = 14;
	self.rankNotifyQueue[size].rank = int( level.rankTable[ self.pers["rank"] ][ display_rank_column ] );
	self.rankNotifyQueue[size].prestige = self.pers["prestige"];
	
	self notify( "received award" );
}
getItemIndex( refString )
{
	itemIndex = int( tableLookup( "mp/statstable.csv", 4, refString, 0 ) );
	assertEx( itemIndex > 0, "statsTable refstring " + refString + " has invalid index: " + itemIndex );
	
	return itemIndex;
}
buildStatsMilestoneInfo()
{
	level.statsMilestoneInfo = [];
	
	for ( tierNum = 1; tierNum <= level.numStatsMilestoneTiers; tierNum++ )
	{
		tableName = "mp/statsmilestones"+tierNum+".csv";
		
		moveToNextTable = false;
		for( idx = 0; idx < level.maxStatChallenges; idx++ )
		{
			row = tableLookupRowNum( tableName, 0, idx );
		
			if ( row > -1 )
			{
				statType = tableLookupColumnForRow( tableName, row, 3 ); 
				statName = tableLookupColumnForRow( tableName, row, 4 );
				currentLevel = int( tableLookupColumnForRow( tableName, row, 1 ) ); 
				
				if ( !isDefined( level.statsMilestoneInfo[statType] ) )
				{
					level.statsMilestoneInfo[statType] = [];
				}
				
				if ( !isDefined( level.statsMilestoneInfo[statType][statName] ) )
				{
					level.statsMilestoneInfo[statType][statName] = [];
				}
				level.statsMilestoneInfo[statType][statName][currentLevel] = [];
				level.statsMilestoneInfo[statType][statName][currentLevel]["index"] = idx;
				level.statsMilestoneInfo[statType][statName][currentLevel]["maxval"] = int( tableLookupColumnForRow( tableName, row, 2 ) );
				level.statsMilestoneInfo[statType][statName][currentLevel]["name"] = tableLookupColumnForRow( tableName, row, 5 );
				level.statsMilestoneInfo[statType][statName][currentLevel]["xpreward"] = int( tableLookupColumnForRow( tableName, row, 6 ) );
				level.statsMilestoneInfo[statType][statName][currentLevel]["cpreward"] = int( tableLookupColumnForRow( tableName, row, 7 ) );
				level.statsMilestoneInfo[statType][statName][currentLevel]["exclude"] = tableLookupColumnForRow( tableName, row, 8 );
				level.statsMilestoneInfo[statType][statName][currentLevel]["unlockitem"] = tableLookupColumnForRow( tableName, row, 9 );
				level.statsMilestoneInfo[statType][statName][currentLevel]["unlocklvl"] = int( tableLookupColumnForRow( tableName, row, 11 ) );				
			}
		}
	}
}
endGameUpdate()
{
	player = self;			
}
updateRankScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	if ( amount == 0 )
		return;
	self notify( "update_score" );
	self endon( "update_score" );
	self.rankUpdateTotal += amount;
	wait ( 0.05 );
	if( isDefined( self.hud_rankscroreupdate ) )
	{			
		if ( self.rankUpdateTotal < 0 )
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (0.73,0.19,0.19);
		}
		else
		{
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,0.5);
		}
		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 0.85;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );
		wait 1;
		self.hud_rankscroreupdate fadeOverTime( 0.75 );
		self.hud_rankscroreupdate.alpha = 0;
		
		self.rankUpdateTotal = 0;
	}
}
removeRankHUD()
{
	if(isDefined(self.hud_rankscroreupdate))
		self.hud_rankscroreupdate.alpha = 0;
}
getRank()
{	
	rankXp = getRankXPCapped( self.pers["rankxp"] );
	rankId = self.pers["rank"];
	
	if ( rankXp < (getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId )) )
		return rankId;
	else
		return self getRankForXp( rankXp );
}
getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );
	
	while ( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;
		rankId++;
		if ( isDefined( level.rankTable[rankId] ) )
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	rankId--;
	return rankId;
}
getSPM()
{
	rankLevel = self getRank() + 1;
	return (3 + (rankLevel * 0.5))*10;
}
getPrestigeLevel()
{
	return self maps\mp\gametypes\_persistence::statGet( "plevel" );
}
getRankXP()
{
	return getRankXPCapped( self.pers["rankxp"] );
}
incRankXP( amount )
{
	if ( !level.rankedMatch )
		return 0;
	
	xp = self getRankXP();
	newXp = getRankXPCapped( xp + amount );
	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );
		
	xpIncrease = getRankXPCapped( newXp ) - self.pers["rankxp"];
	
	if ( xpIncrease < 0 )
	{
		xpIncrease = 0;
	}
	self.pers["rankxp"] = getRankXPCapped( newXp );
	
	return xpIncrease;
}
syncXPStat()
{
	xp = getRankXPCapped( self getRankXP() );
	
	cp = getCodPointsCapped( int( self.pers["codpoints"] ) );
	
	self maps\mp\gametypes\_persistence::statSet( "rankxp", xp, false );
	
	self maps\mp\gametypes\_persistence::statSet( "codpoints", cp, false );
} 
