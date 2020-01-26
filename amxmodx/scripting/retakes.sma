/*
*	___________
*
*	R E T A K E S	v1.1
*	alghtryer.github.io/retakes
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*	
*
*	The plugin sets up a retake situation in a random site in the map. TT plant bomb and CT have 40 seconds to defuse. 
*	TT spawned on bombsite( A or B), CT on random spwan depending of where c4 plant(A or B). 
*		
*	Features:
*	- - - - -
*	- Warm Up for 30 seconds on map start.
*	- Auto plant Bomb.
*	- If CT win, team will be swap.
*	- If TT win 3(cvar) rounds in row, team well be swap.
*	- Playing 15(cvar) rounds and map change on nextmap.
*	- c4 Hud timer.
*	- Buy Time for 5seconds(cvar).
*	- Unlock/Remove buy zones.
*	- If bomb don't plant, round will be restarted. Rounds and player money/kill/deats be returned on same.
*
*	Spawn
*	- - - - -
*	Every map must have spawn for Site A and B. For now i crete 6 CT and 6 T spawn for this map:
*		- de_dust2, de_inferno, de_mirage, de_train, de_tuscan.
*
*	API:
*	- - -
*	isRetakes()	// Check if retakes start.
*	Rounds()	// Check round number.
*			
*	Cvars:
*	- - - - -
*	retakes_rounds "15"			// How much playing round for one map
*	retakes_rowwin "3"			// How much T Team can win round in row
*	retakes_prefix "!g[RETAKES]"		// Prefix in chat message
*	retakes_autoplant "1"			// Auto Plant Bomb is on/off
*	retakes_buyzone 1			// Unlock/remove buy zone
*	retakes_warmup_time "30"		// Warm Up time min=1
*	retakes_infohud "1"			// Info hud on/off
*	retakes_buytime "5"			// Buy Time
*	retakes_swapct "1"			// On/off Swap CT
*	retakes_swapt "1"			// On/off Swap T
*	retakes_hudc4timer "1"			// On/off c4 hud timer
*
*	Credits:
*	- - - - -
* 	- Map Spawns 			// jopmako
*	- Auto Plant Bomb		// xPaw/Arkashine
*	- c4 Countdown Timer		// SAMURAI16
*	- Disable Buy			// Exolent
*	- Unlock BuyZone		// VEN
*	
*	Changelog:
*	- - - - - -
*	v1.0 [09. Jan 2020]
*       	- First release.
*	v1.1 [22. Jan 2020]
*		- Added	eight new cvars.
*		- Added buy zone and disable buy.
*		- Small bug fixed.
*		- Added perment hud message for bombsite info.
*
*	License:
*	- - - - 
*  	Copyright (C) 2020, ALGHTRYER <alghtryer@gmail.com> 
*
*  	This program is free software; you can redistribute it and/or
*  	modify it under the terms of the GNU General Public License
*  	as published by the Free Software Foundation; either version 2
*  	of the License, or (at your option) any later version.
*
*  	This program is distributed in the hope that it will be useful,
*  	but WITHOUT ANY WARRANTY; without even the implied warranty of
*  	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  	GNU General Public License for more details.
*
*  	You should have received a copy of the GNU General Public License
*  	along with this program; if not, write to the Free Software
* 	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.	
*/

#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < hamsandwich >
#include < cstrike >
#include < fakemeta >


new PLUGIN[]	= "Retakes";		// <alghtryer.github.io/retakes>
new AUTHOR[]	= "ALGHTRYER"; 		// <alghtryer.github.io>
new VERSION[]	= "1.1";

#define m_iDeaths 444

new MpFreezetime;
new MpRoundtime;
new MpTimelimit;
new NextMap;
new RestartRound;
new MpLimitTeams;
new MpAutoTeamBalance;
new Mpc4timer;
new MpBuyTime

new CvarTTwins;
new CvarRounds;
new CvarBuyTime
new CvarAutoPlant
new CvarBuyZone
new CvarWarmUp
new CvarInfoHud
new CvarSwapCt
new CvarSwapT
new CvarHudc4Timer
new CvarPrefix;
new Prefix[ 32 ];

new RoundWin;
new round;

new c4timer
new iTime

new SyncMsg;
new c4SyncMsg;
new SyncInfoHud;

new bool:BombSite;
new bool:StartRetake;
new bool:roundrr;
new bool:isBombPlanted;
new bool:isRoundEnd;
new bool:isRoundRestart;
new bool:isOnCtWinRound;
new bool:isOnTeWinRound;
new bool:isBomb;

new Trie:tBuyCommands;
new Float:fRoundStart;

enum _:PlayerData
{
    Player_Kills,
    Player_Deaths,
    Player_Money
}

new ePlayerData[ 33 ][ PlayerData ]
new bool:SavePlayerData[ 33 ];

new msgStatusIcon;

public plugin_precache( ) 
{
	ReadSpawns( 1 );
}

public plugin_init( ) 
{

	register_plugin
	(
		PLUGIN,		//: RETAKES <alghtryer.github.io/retakes>
		VERSION,	//: 1.1
		AUTHOR		//: ALGHTRYER <alghtryer.github.io>
	);

	register_cvar( "retakes_version", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED );


	register_event( "SendAudio",	"EndRound",	"a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw" );
	register_event( "TextMsg", "RestartGame", "a", "2&#Game_C","2&#Game_w" );
	register_event( "SendAudio", "OnCtWinRound", "a", "2&%!MRAD_ctwin" );
	register_event( "SendAudio", "OnTeWinRound", "a", "2&%!MRAD_terwin" );
	register_event( "HLTV", "RoundStart", "a", "1=0", "2=0" );
	register_event( "ResetHUD", "DrawBuyZoneIcon", "be" )

	register_logevent( "MsgPlantBomb", 3, "2=Spawned_With_The_Bomb" )
	register_logevent( "bomb_planted" , 3, "2=Planted_The_Bomb" );
	register_logevent( "bomb_defused" , 3, "2=Defused_The_Bomb" );
	register_logevent( "bomb_explode" , 6, "3=Target_Bombed" );
	register_logevent( "WhenRoundStart", 2, "1=Round_Start" )

	register_message( get_user_msgid( "StatusIcon" ), "Message_StatusIcon" );

	RegisterHam( Ham_Spawn, "player", "OnPlayerSpawn", 1 ) 
	RegisterHam( Ham_CS_Item_CanDrop, "weapon_c4", "DisableC4Drop" );

	msgStatusIcon 			= get_user_msgid( "StatusIcon" ) 

	MpFreezetime			= get_cvar_pointer( "mp_freezetime" )
	MpRoundtime			= get_cvar_pointer( "mp_roundtime" );
	MpTimelimit			= get_cvar_pointer( "mp_timelimit" );
	MpLimitTeams			= get_cvar_pointer( "mp_limitteams" );
	MpAutoTeamBalance		= get_cvar_pointer( "mp_autoteambalance" );
	RestartRound 			= get_cvar_pointer( "sv_restartround" );
	MpBuyTime 			= get_cvar_pointer( "mp_buytime" );
	Mpc4timer			= get_cvar_pointer( "mp_c4timer" );
	NextMap				= get_cvar_pointer( "amx_nextmap" );

	CvarRounds			= register_cvar( "retakes_rounds","15" );
	CvarTTwins 			= register_cvar( "retakes_rowwin","3" );
	CvarPrefix 			= register_cvar( "retakes_prefix", "!g[RETAKES]" );
	CvarAutoPlant			= register_cvar( "retakes_autoplant","1" );
	CvarBuyZone			= register_cvar( "retakes_buyzone","1" );
	CvarWarmUp			= register_cvar( "retakes_warmup_time","30" );
	CvarInfoHud			= register_cvar( "retakes_infohud","1" );
	CvarBuyTime 			= register_cvar( "retakes_buytime", "5" );
	CvarSwapCt			= register_cvar( "retakes_swapct", "1" );
	CvarSwapT			= register_cvar( "retakes_swapt", "1" );
	CvarHudc4Timer			= register_cvar( "retakes_hudc4timer", "1" );

	get_pcvar_string( CvarPrefix, Prefix, charsmax( Prefix ) );

	SyncMsg				= CreateHudSyncObj( );
	c4SyncMsg			= CreateHudSyncObj( );
	SyncInfoHud			= CreateHudSyncObj( );

	register_clcmd("fullupdate", "clcmd_fullupdate")

	new const szBuyCommands[ ][ ] =
   	 {
		"usp", "glock", "deagle", "p228", "elites",
		"fn57", "m3", "xm1014", "mp5", "tmp", "p90",
		"mac10", "ump45", "ak47", "galil", "famas",
		"sg552", "m4a1", "aug", "scout", "awp", "g3sg1",
		"sg550", "m249", "vest", "vesthelm", "flash",
		"hegren", "sgren", "defuser", "nvgs", "shield",
		"primammo", "secammo", "km45", "9x19mm", "nighthawk",
		"228compact", "fiveseven", "12gauge", "autoshotgun",
		"mp", "c90", "cv47", "defender", "clarion", "krieg552",
		"bullpup", "magnum", "d3au1", "krieg550", 
		"buy", "buyammo1", "buyammo2", "buyequip", "cl_autobuy",
		"cl_rebuy", "cl_setautobuy", "cl_setrebuy"
    	}
    
	tBuyCommands = TrieCreate( );
    	for( new i = 0; i < sizeof( szBuyCommands ); i++ )
	{
		TrieSetCell( tBuyCommands, szBuyCommands[ i ], i );
	}

}
public plugin_cfg( ) 
{ 
	set_pcvar_float( MpRoundtime, 1.00 );
	set_pcvar_num( MpTimelimit, 0 );
	set_pcvar_num( MpLimitTeams, 5 );
	set_pcvar_num( MpAutoTeamBalance, 1 );
	set_pcvar_num( Mpc4timer, 40 );
	set_pcvar_float( MpBuyTime, 1.5 );


	if( get_pcvar_num( CvarBuyZone ) )
	{ 
		UnlockBuyZone( )
		set_pcvar_num( MpFreezetime, 5 );
	}
	else
		set_pcvar_num( MpFreezetime, 1 );

	if( get_pcvar_num( CvarInfoHud ) )
		set_task( 1.0, "InfoHud", _, _, _, "b" );

	iTime = get_pcvar_num( CvarWarmUp )
	set_task( 1.0, "ShowCountdown", .flags = "a", .repeat = iTime );
} 
public plugin_natives( )
{
	register_library( "retakes" );
	
	register_native( "isRetakes","_retakes" );
	register_native( "Rounds","_rounds" );
}
public bool:_retakes( plugin, params )
{
	return StartRetake;
}
public _rounds( plugin, params )
{
	return round;
}
public RoundStart( )
{
	c4timer = -1;
	remove_task( 652450 );
	isBombPlanted = false;
	
	if(StartRetake){
		new players[ 32 ] , num , numT, numCT, iPlayer;
		new szNextMap[ 64 ]; 
		get_players( players , num );

		set_hudmessage( 0, 212, 255, -1.0, 0.28, 0, 6.0, 6.0 );

		for( new i = 0 ; i < num ; i++ )
		{
			iPlayer = players[ i ];
			new CsTeams:iTeam = cs_get_user_team( iPlayer );


			switch ( iTeam )
			{
				case CS_TEAM_T: 
				{ 
					numT++; 
					ShowSyncHudMsg( iPlayer, SyncMsg, "Defend Bombsite: %s", BombSite ? "B" : "A" ); 
				}
				case CS_TEAM_CT: 
				{ 
					numCT++; 
					ShowSyncHudMsg( iPlayer, SyncMsg, "Retake Bombsite: %s", BombSite ? "B" : "A" ); 
				}
			}

		}
		
		fRoundStart = get_gametime( );
		
        	get_pcvar_string( NextMap, szNextMap, charsmax( szNextMap ) );

		round++
		roundrr = true;
		
		isRoundEnd = true;
		isRoundRestart = true;
		isOnCtWinRound = true;
		isOnTeWinRound = true;
		
		if( get_pcvar_num( CvarAutoPlant ) == 0 )
			isBomb = true;

		ClientPrintColor( 0, "%s Retake %s : %d Ts vs %d CTs", Prefix, BombSite ? "B" : "A", numT,numCT );
		ClientPrintColor( 0, "%s Round: %d/%d | Next Map: %s", Prefix, round, get_pcvar_num( CvarRounds ), szNextMap );

		if( get_pcvar_num( CvarBuyZone ) )
			ClientPrintColor( 0, "%s You have %d seconds for buy!", Prefix , get_pcvar_num( CvarBuyTime ) );

		if( round == get_pcvar_num( CvarRounds ) )
			server_cmd( "changelevel %s", szNextMap );
	}
} 
public WhenRoundStart( )
{
	if( StartRetake )
	{
		if( task_exists( 773 ) )
		{
			remove_task( 773 );
		}	
		set_task( 10.0, "BombNotPlant", 773 );
	}		
}
public InfoHud( )
{
	if( StartRetake )
	{
		set_hudmessage( 0, 212, 255, 0.57, 0.05, _, _, 1.0, _, _, 1 );
		ShowSyncHudMsg( 0, SyncInfoHud, "Bombsite : %s", BombSite ? "B" : "A" );
	}
}
public BombNotPlant( )
{
	if( !isBombPlanted )
		set_pcvar_num( RestartRound, 1 );

	if( task_exists( 773 ) )
	{
		remove_task( 773 );
	}
}	
public ShowCountdown( )
{
	client_print( 0, print_center, "Retake start for : %d", iTime-- );  

	if( iTime <= 0 )
    	{
		StartRetake = true;
		set_pcvar_num( RestartRound, 1 );
	}
}
public EndRound( )
{

	c4timer = -1;
	remove_task( 652450 );

	if( !isRoundEnd ) return;
	
	if( StartRetake )
	{
		if( BombSite )
			BombSite = false;
		else
			BombSite = true;
		
		ReadSpawns( 0 );
		
		isRoundEnd = false;
	}
} 

public RestartGame( )
{
	if( task_exists( 773 ) )
	{
		remove_task( 773 );
	}

	c4timer = -1;
	remove_task( 652450 );

	if( !isRoundRestart ) return;

	if( StartRetake )
	{
		if( roundrr )
		{
			round--
			roundrr = false;
		}
		
		new iPlayers[ 32 ], iNum, i, Players;
		get_players( iPlayers, iNum );

		for( i = 0; i < iNum; i++ )
		{
			Players = iPlayers[ i ];

			SavePlayerData[ Players ] = true;
		}

		isRoundRestart = false;
	}
	
}
public OnCtWinRound( )
{
	if( !isOnCtWinRound ) return;

	if( StartRetake && get_pcvar_num( CvarSwapCt ) )
	{
		RoundWin = 0;
		SwapTeams( )
		ClientPrintColor( 0, "%s CT win. Swapping Teams!", Prefix );

		isOnCtWinRound = false;
	}
}
public OnTeWinRound( )
{
	if( !isOnTeWinRound ) return;

	if( StartRetake && get_pcvar_num( CvarSwapT ) )
	{
		RoundWin++
		if( RoundWin == get_pcvar_num( CvarTTwins ) )
		{
			SwapTeams( )
			ClientPrintColor( 0, "%s TT win %d in a row. Swapping Teams!", Prefix, RoundWin );
			RoundWin = 0;
		}
		
		isOnTeWinRound = false;
	}
}
stock SwapTeams()
{
	new iPlayers[ 32 ], iNum, iPlayer;
	get_players( iPlayers, iNum );
		
	for ( new a = 0; a < iNum; a++ )
	{
		iPlayer = iPlayers[ a ];
			
		switch ( cs_get_user_team( iPlayer ) )
		{
			case CS_TEAM_T: cs_set_user_team( iPlayer, CS_TEAM_CT );
			case CS_TEAM_CT: cs_set_user_team( iPlayer, CS_TEAM_T );
		}
	}
}
stock ReadSpawns( type )
{
	new szMap[ 32 ], szConfigdir[ 128 ], szMapFile[ 256 ];

	get_configsdir( szConfigdir, charsmax( szConfigdir ) ); 
	get_mapname( szMap, charsmax( szMap ) );
	
	if( BombSite )
		formatex( szMapFile, charsmax( szMapFile ), "%s/retakes/%s.spawns_b.cfg", szConfigdir, szMap );
	else
		formatex( szMapFile, charsmax( szMapFile ), "%s/retakes/%s.spawns_a.cfg", szConfigdir, szMap );
	
	if ( file_exists( szMapFile ) )
	{
		
		new ent_T, ent_CT;
		new Data[ 128 ], len, line = 0;
		new team[ 8 ], p_origin[ 3 ][ 8 ], p_angles[ 3 ][ 8 ];
		new Float:origin[ 3 ], Float:angles[ 3 ];
		
		while( ( line = read_file( szMapFile, line , Data , 127 , len) ) != 0 ) 
		{
			if ( strlen( Data ) <2 ) continue;
			
			parse( Data, team, 7, p_origin[ 0 ], 7, p_origin[ 1 ], 7, p_origin[ 2 ], 7, p_angles[ 0 ], 7, p_angles[ 1 ], 7, p_angles[ 2 ], 7 );
			
			origin[ 0 ] = str_to_float(p_origin[ 0 ]); origin[ 1 ] = str_to_float(p_origin[ 1 ] ); origin[ 2 ] = str_to_float( p_origin[ 2 ] );
			angles[ 0 ] = str_to_float(p_angles[ 0 ]); angles[ 1 ] = str_to_float(p_angles[ 1 ] ); angles[ 2 ] = str_to_float(p_angles[ 2 ] );
			
			if ( equali( team, "T" ) )
			{
				if ( type==1 ) ent_T = create_entity( "info_player_deathmatch" );
				else ent_T = find_ent_by_class( ent_T, "info_player_deathmatch" );
				if ( ent_T > 0 )
				{
					entity_set_int( ent_T, EV_INT_iuser1, 1 ); 
					entity_set_origin( ent_T, origin );
					entity_set_vector( ent_T, EV_VEC_angles, angles );
				}
			}
			else if (equali( team, "CT" ) )
			{
				if ( type==1 ) ent_CT = create_entity( "info_player_start" );
				else ent_CT = find_ent_by_class( ent_CT, "info_player_start" );
				if ( ent_CT > 0 )
				{
					entity_set_int( ent_CT, EV_INT_iuser1,1 ); 
					entity_set_origin( ent_CT, origin );
					entity_set_vector( ent_CT, EV_VEC_angles, angles );
				}
			}
		}
		return 1;
	}
	return 0;
}
public pfn_keyvalue( entid )
{  
	new classname[ 32 ], key[ 32 ], value[ 32 ]
	copy_keyvalue( classname, 31, key, 31, value, 31 )
		
	if ( equal ( classname, "info_player_deathmatch" ) || equal( classname, "info_player_start" ) )
	{
		if ( is_valid_ent ( entid ) && entity_get_int ( entid,EV_INT_iuser1 ) !=1 ) 
			remove_entity( entid )
	}

	return PLUGIN_CONTINUE
}
public OnPlayerSpawn( id ) 
{
	if ( is_user_alive( id ) ) 
	{
		if( StartRetake )
		{
			if( task_exists( id ) )
			{
				remove_task( id );
			}

			if( get_pcvar_num( CvarAutoPlant ) )
				set_task( get_pcvar_float(MpFreezetime), "c4strip", id )
			

			if( SavePlayerData[ id ] )
			{
				ExecuteHam(Ham_AddPoints, id, ePlayerData[ id ][ Player_Kills ], true )
				set_pdata_int(id, m_iDeaths, ePlayerData[ id ][ Player_Deaths ] )
				cs_set_user_money(id, ePlayerData[ id ][ Player_Money ] )
				SavePlayerData[ id ] = false;
			}
			else
			{
				ePlayerData[ id ][ Player_Kills ] = get_user_frags( id );
				ePlayerData[ id ][ Player_Deaths ] = get_user_deaths( id );
				ePlayerData[ id ][ Player_Money ] = cs_get_user_money( id );
			}
		
		}
		
	}
} 
public DrawBuyZoneIcon( id )
{
	if ( is_user_alive( id ) && get_pcvar_num( CvarBuyZone ) ) 
	{
		message_begin( MSG_ONE, msgStatusIcon, _, id )
		write_byte( 1<<0 )
		write_string( "buyzone" )
		write_byte( 0 )
		write_byte( 160 )
		write_byte( 0 )
		message_end( )
	}
} 
public clcmd_fullupdate( ) 
{
	return PLUGIN_HANDLED
}
public c4strip( id ) 
{
	if (is_user_alive( id ) ) 
	{
		if( user_has_weapon( id, CSW_C4 ) )
		{
			cs_set_user_plant( id,0,0 );
			cs_set_user_bpammo( id, CSW_C4,0 );
			BombPlant( id );
		}
	}
}
public BombPlant( player ) {
	new iEntity = create_entity( "weapon_c4" );
	
	if( !iEntity )
		return;
	
	DispatchKeyValue( iEntity, "detonatedelay", "0" );
	DispatchSpawn( iEntity );
	
	new Float:origin[ 3 ];
	pev( player, pev_origin, origin );

	origin[ 0 ] += 30.0 
	
	engfunc( EngFunc_SetOrigin, iEntity, origin );
	
	client_print( 0, print_center, "#Cstrike_TitlesTXT_Bomb_Planted" );
	client_cmd( 0, "spk sound/radio/bombpl.wav" );

	force_use( iEntity, iEntity ); 

	message_begin( MSG_SPEC, SVC_DIRECTOR );
        write_byte( 9 );    
        write_byte( DRC_CMD_EVENT ); 
        write_short( player );
        write_short( 0 );
        write_long( 11 | DRC_FLAG_FACEPLAYER );  
        message_end();
	
	static msgBombDrop;

	if ( msgBombDrop || ( msgBombDrop = get_user_msgid( "BombDrop" ) ) )
	{   
		#define write_coord_f(%0)  ( engfunc( EngFunc_WriteCoord, %0 ) )
		
		message_begin( MSG_ALL, msgBombDrop );
		write_coord_f( origin[ 0 ] );
		write_coord_f( origin[ 1 ] );
		write_coord_f( origin[ 2 ] );
		write_byte( 1 );
		message_end();
	}
	
	isBombPlanted= true;

	if( get_pcvar_num( CvarHudc4Timer ) )
	{
		c4timer = get_pcvar_num( Mpc4timer );
		dispTime( )
		set_task( 1.0, "dispTime", 652450, "", 0, "b" );
	} 
} 
public MsgPlantBomb( )
{
	if( get_pcvar_num( CvarAutoPlant ) ) return;

	if( StartRetake )
	{
		new szLogUser[80], szName[32]
		read_logargv(0, szLogUser, charsmax(szLogUser))
		parse_loguser(szLogUser, szName, charsmax(szName))

		new id = get_user_index(szName)

		if( user_has_weapon( id, CSW_C4 ) )
		{
			engclient_cmd( id, "weapon_c4" );
			client_print( id, print_center, "PLANT A BOMB!!!^rPLANT A BOMB!!!^rPLANT A BOMB!!!" );
			ClientPrintColor( id, "%s PLANT A BOMB!!!", Prefix ); 
			ClientPrintColor( id, "%s PLANT A BOMB!!!", Prefix ) 
			ClientPrintColor( id, "%s PLANT A BOMB!!!", Prefix ) 
		}
	}
}
public bomb_planted( )
{
	if( !isBomb ) return;

	isBombPlanted= true;
	if( get_pcvar_num( CvarHudc4Timer ) )
	{
		c4timer = get_pcvar_num( Mpc4timer );
		dispTime()
		set_task(1.0, "dispTime", 652450, "", 0, "b");
	}
	isBomb = false;
}
public bomb_defused()
{
	if(isBombPlanted)
	{
		remove_task( 652450 );
		isBombPlanted = false;
	}
	
}
public bomb_explode()
{
	if(isBombPlanted)
	{
		remove_task( 652450 );
		isBombPlanted = false;
	}
	
}
public dispTime()
{   
	if( !isBombPlanted )
	{
		remove_task( 652450 );
		return;
	}
	
	
	if( c4timer >= 0 )
	{
		if( c4timer > 13 ) set_hudmessage( 0, 150, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1 );
		else if( c4timer > 7 ) set_hudmessage( 150, 150, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1 );
			else set_hudmessage( 150, 0, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1 );
		
		ShowSyncHudMsg( 0, c4SyncMsg, "C4: %d", c4timer );
		
		--c4timer;
	}
	
} 
public plugin_end( )
{
    TrieDestroy( tBuyCommands );
}

public client_command( client )
{
	if( !is_user_alive( client ) )
    	{
        	return PLUGIN_CONTINUE;
    	}
    
    	static szArg[ 15 ];
    
    	if( read_argv( 0, szArg, 14 ) > 13 ) // cl_setautobuy = 1234567890123 = 13
    	{
        	return PLUGIN_CONTINUE;
    	}
    
    	strtolower( szArg );
    	if( TrieKeyExists( tBuyCommands, szArg )
    	&& ( 1 << ( _:cs_get_user_team( client ) ) & ( ( 1 << ( _:CS_TEAM_T ) ) | ( 1 << ( _:CS_TEAM_CT ) ) ) ) )
    	{
        	new iCvar = get_pcvar_num( CvarBuyTime )
        
        	if( get_gametime() - fRoundStart > iCvar )
        	{
            		engclient_print( client, engprint_center, "%d seconds have passed.^nYou can't buy anything now!", iCvar );
            
            		return PLUGIN_HANDLED;
        	}
    	}
    
    	return PLUGIN_CONTINUE;
} 
public client_disconnect( id )
{
	if( task_exists( id ) )
	{
		remove_task( id );
	}
}
public DisableC4Drop( const iEntity ) 
{
        
	SetHamReturnInteger( 0 );
        return HAM_SUPERCEDE;
}
public UnlockBuyZone()
{
	new Float:bMin[3] = { -8191.0, -8191.0, -8191.0 };
	new Float:bMax[3] = { 8191.0, 8191.0, 8191.0 };


	new BuyZone = create_entity( "func_buyzone" )

	DispatchKeyValue(BuyZone, "team", "0" );
	DispatchSpawn( BuyZone );
	entity_set_size( BuyZone, bMin, bMax );

}
public Message_StatusIcon( iMsgId, iMsgDest, usr )  
{
	if( get_pcvar_num( CvarBuyZone ) == 0 )
	{
		static szIcon[ 8 ];  
		get_msg_arg_string( 2, szIcon, charsmax( szIcon ) );  
		if( equal( szIcon, "buyzone" ) ) 
		{  
			if( get_msg_arg_int(1) )  
			{
				set_pdata_int( usr, 235, get_pdata_int( usr, 235 ) & ~( 1<<0 ) ); 
				return PLUGIN_HANDLED;  
			}  
		}
		return PLUGIN_CONTINUE; 
	}
	return PLUGIN_CONTINUE;
}
stock ClientPrintColor( id, String[ ], any:... ){
	new szMsg[ 190 ];
	vformat( szMsg, charsmax( szMsg ), String, 3 );
	
	replace_all( szMsg, charsmax( szMsg ), "!n", "^1" );
	replace_all( szMsg, charsmax( szMsg ), "!t", "^3" );
	replace_all( szMsg, charsmax( szMsg ), "!g", "^4" );
	
	static msgSayText = 0;
	static fake_user;
	
	if( !msgSayText )
	{
		msgSayText = get_user_msgid( "SayText" );
		fake_user = get_maxplayers( ) + 1;
	}
	
	message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgSayText, _, id );
	write_byte( id ? id : fake_user );
	write_string( szMsg );
	message_end( );
}
/* 
	MADE BY ALGHTRYER.
*/
