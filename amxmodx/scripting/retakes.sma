/*
*	___________
*
*	R E T A K E S	v1.0
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
*	- Remove buy zones.
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
*
*	Credits:
*	- - - - -
*	- Map Spawns 			jopmako
*	- Auto Plant Bomb		xPaw/Arkashine
*	- c4 Countdown Timer		SAMURAI16
*
*	License:
*	- - - - 
*  	Copyright (C) 2019, ALGHTRYER <alghtryer@gmail.com> 
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

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>


new PLUGIN[]	= "Retakes";		// <alghtryer.github.io/retakes>
new AUTHOR[]	= "ALGHTRYER"; 		// <alghtryer.github.io>
new VERSION[]	= "1.0";


new iTime = 30;


new Freezetime;
new MpRoundtime;
new MpTimelimit;
new Rounds;
new NextMap;
new CvarTTwins;
new RestartRound;
new MpLimitTeams;
new MpAutoTeamBalance;
new Mpc4timer;
new CvarPrefix;
new Prefix[32];

new c4timer
new bool:isBombPlanted;

new RoundWin;
new round;

new SyncMsg;
new c4SyncMsg;

new bool:BombSite;
new bool:StartRetake;
new bool:roundrr;

new bool:isRoundEnd;
new bool:isRoundRestart;
new bool:isOnCtWinRound;
new bool:isOnTeWinRound;


public plugin_precache() {

	ReadSpawns(1);
}

public plugin_init( ) {

	register_plugin
	(
		PLUGIN,		//: RETAKES <alghtryer.github.io/retakes>
		VERSION,	//: 1.0
		AUTHOR		//: ALGHTRYER <alghtryer.github.io>
	);

	register_cvar("retakes_version", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED);

	 

	register_event("SendAudio",	"EndRound",	"a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw");
	register_event("TextMsg", "RestartGame", "a", "2&#Game_C","2&#Game_w");
	register_event("SendAudio", "OnCtWinRound", "a", "2&%!MRAD_ctwin");
	register_event( "SendAudio", "OnTeWinRound", "a", "2&%!MRAD_terwin" );
	register_event("HLTV", "RoundStart", "a", "1=0", "2=0");

	register_message(get_user_msgid("StatusIcon"), "Message_StatusIcon");

	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1) 
	RegisterHam( Ham_CS_Item_CanDrop, "weapon_c4", "DisableC4Drop" );

	Freezetime			= get_cvar_pointer("mp_freezetime")
	MpRoundtime			= get_cvar_pointer("mp_roundtime");
	MpTimelimit			= get_cvar_pointer("mp_timelimit");
	MpLimitTeams			= get_cvar_pointer("mp_limitteams");
	MpAutoTeamBalance		= get_cvar_pointer("mp_autoteambalance");
	RestartRound 			= get_cvar_pointer("sv_restartround");
	Mpc4timer			= get_cvar_pointer("mp_c4timer");
	NextMap				= get_cvar_pointer("amx_nextmap");
	Rounds				= register_cvar("retakes_rounds","15");
	CvarTTwins 			= register_cvar("retakes_rowwin","3");
	CvarPrefix 			= register_cvar( "retakes_prefix", "!g[RETAKES]" );

	get_pcvar_string( CvarPrefix, Prefix, charsmax( Prefix ) );


	SyncMsg					= CreateHudSyncObj();
	c4SyncMsg				= CreateHudSyncObj();


	set_task(1.0, "ShowCountdown", .flags = "a", .repeat = iTime);

}
public plugin_cfg() { 
	set_pcvar_num(Freezetime, 1);
	set_pcvar_float(MpRoundtime, 1.00);
	set_pcvar_num(MpTimelimit, 0 );
	set_pcvar_num(MpLimitTeams, 5 );
	set_pcvar_num(MpAutoTeamBalance, 1 );
	set_pcvar_num(Mpc4timer, 40 );
} 
public plugin_natives()
{
	register_library("retakes");
	
	register_native("isRetakes","_retakes");
	register_native("Rounds","_rounds");
}
public bool:_retakes(plugin, params)
{
	return StartRetake;
}
public _rounds(plugin, params)
{
	return round;
}
public RoundStart( )
{
	c4timer = -1;
	remove_task(652450);
	isBombPlanted = false;
	
	if(StartRetake){
		new players[32] , num , numT, numCT, iPlayer;
		new szNextMap[64]; 
		get_players( players , num );

		set_hudmessage(0, 212, 255, -1.0, 0.28, 0, 6.0, 6.0);

		for( new i = 0 ; i < num ; i++ )
		{
			iPlayer = players[ i ];
			new CsTeams:iTeam = cs_get_user_team(iPlayer);

			switch ( iTeam )
			{
				case CS_TEAM_T: 
				{ 
					numT++; 
					ShowSyncHudMsg(iPlayer, SyncMsg, "Defend Bombsite: %s", BombSite ? "B" : "A"); 
				}
				case CS_TEAM_CT: 
				{ 
					numCT++; 
					ShowSyncHudMsg(iPlayer, SyncMsg, "Retake Bombsite: %s", BombSite ? "B" : "A"); 
				}
			}

		}
		
		set_task(10.0, "BombNotPlant", 773);
		
        	get_pcvar_string(NextMap, szNextMap, charsmax(szNextMap));

		round++
		roundrr = true;
		
		isRoundEnd = true;
		isRoundRestart = true;
		isOnCtWinRound = true;
		isOnTeWinRound = true;

		ClientPrintColor(0, "%s Retake %s : %d Ts vs %d CTs", Prefix, BombSite ? "B" : "A", numT,numCT );
		ClientPrintColor(0, "%s Round: %d/%d | Next Map: %s", Prefix, round, get_pcvar_num(Rounds), szNextMap );

		if(round == get_pcvar_num(Rounds))
			server_cmd("changelevel %s", szNextMap );
	}
} 
public BombNotPlant(){
	if(!isBombPlanted)
		set_pcvar_num(RestartRound, 1);

	if( task_exists( 773 ) )
	{
		remove_task( 773 );
	}
}	
public ShowCountdown()
{
	client_print(0, print_center, "Retake start for : %d", iTime--);  

	if(iTime <= 0)
    	{
		StartRetake = true;
		set_pcvar_num(RestartRound, 1);
	}
}
public EndRound( )
{

	c4timer = -1;
	remove_task(652450);

	if( !isRoundEnd ) return;
	
	if(StartRetake){
		if(BombSite)
			BombSite = false;
		else
			BombSite = true;
		
		ReadSpawns(0)
		
		isRoundEnd = false;
	}
} 

public RestartGame()
{

	c4timer = -1;
	remove_task(652450);

	if( !isRoundRestart ) return;

	if(StartRetake){
		if(roundrr){
			round--
			roundrr = false;
		}
		
		isRoundRestart = false;
	}
	
}
public OnCtWinRound()
{
	if( !isOnCtWinRound ) return;

	if(StartRetake){
		RoundWin = 0;
		SwapTeams()
		ClientPrintColor(0, "%s CT win. Swapping Teams!", Prefix);

		isOnCtWinRound = false;
	}
}
public OnTeWinRound()
{
	if( !isOnTeWinRound ) return;

	if(StartRetake){
		RoundWin++
		if(RoundWin == get_pcvar_num(CvarTTwins))
		{
			SwapTeams()
			ClientPrintColor(0, "%s TT win %d in a row. Swapping Teams!", Prefix, RoundWin);
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
stock ReadSpawns(type){
	new szMap[32], szConfigdir[128], szMapFile[256];

	get_configsdir(szConfigdir, charsmax(szConfigdir)); 
	get_mapname( szMap, charsmax( szMap ) );
	
	if(BombSite)
		formatex(szMapFile, charsmax(szMapFile), "%s/retakes/%s.spawns_b.cfg", szConfigdir, szMap);
	else
		formatex(szMapFile, charsmax(szMapFile), "%s/retakes/%s.spawns_a.cfg", szConfigdir, szMap);
	
	if (file_exists(szMapFile))
	{
		
		new ent_T, ent_CT
		new Data[128], len, line = 0
		new team[8], p_origin[3][8], p_angles[3][8]
		new Float:origin[3], Float:angles[3]
		
		while((line = read_file(szMapFile, line , Data , 127 , len) ) != 0 ) 
		{
			if (strlen(Data)<2) continue
			
			parse(Data, team,7, p_origin[0],7, p_origin[1],7, p_origin[2],7, p_angles[0],7, p_angles[1],7, p_angles[2],7)
			
			origin[0] = str_to_float(p_origin[0]); origin[1] = str_to_float(p_origin[1]); origin[2] = str_to_float(p_origin[2]);
			angles[0] = str_to_float(p_angles[0]); angles[1] = str_to_float(p_angles[1]); angles[2] = str_to_float(p_angles[2]);
			
			if (equali(team,"T")){
				if (type==1) ent_T = create_entity("info_player_deathmatch")
				else ent_T = find_ent_by_class(ent_T, "info_player_deathmatch")
				if (ent_T>0){
					entity_set_int(ent_T,EV_INT_iuser1,1) 
					entity_set_origin(ent_T,origin)
					entity_set_vector(ent_T, EV_VEC_angles, angles)
				}
			}
			else if (equali(team,"CT")){
				if (type==1) ent_CT = create_entity("info_player_start")
				else ent_CT = find_ent_by_class(ent_CT, "info_player_start")
				if (ent_CT>0){
					entity_set_int(ent_CT,EV_INT_iuser1,1) 
					entity_set_origin(ent_CT,origin)
					entity_set_vector(ent_CT, EV_VEC_angles, angles)
				}
			}
		}
		return 1
	}
	return 0
}
public pfn_keyvalue(entid)
{  
	new classname[32], key[32], value[32]
	copy_keyvalue(classname, 31, key, 31, value, 31)
		
	if (equal(classname, "info_player_deathmatch") || equal(classname, "info_player_start")){
		if (is_valid_ent(entid) && entity_get_int(entid,EV_INT_iuser1)!=1) 
			remove_entity(entid)
	}

	return PLUGIN_CONTINUE
}
public OnPlayerSpawn(id) {
	if (is_user_alive(id)) {
		if(StartRetake)
			set_task(1.0,"c4strip",id)
	}
} 
public c4strip(id) {
	if (is_user_alive(id)) {
		if( user_has_weapon( id, CSW_C4 ))
		{
			cs_set_user_plant(id,0,0);
			cs_set_user_bpammo(id,CSW_C4,0);
			BombPlant(id)
		}
	}
}
public BombPlant(player) {
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
	client_cmd(0, "spk sound/radio/bombpl.wav");

	force_use( iEntity, iEntity ); 

	message_begin( MSG_SPEC, SVC_DIRECTOR );
        write_byte( 9 );    
        write_byte( DRC_CMD_EVENT ); 
        write_short( player );
        write_short( 0 );
        write_long( 11 | DRC_FLAG_FACEPLAYER );  
        message_end();
	
	static msgBombDrop;

	if ( msgBombDrop ||( msgBombDrop = get_user_msgid ( "BombDrop" ) ) )
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
	c4timer = get_pcvar_num(Mpc4timer);
	dispTime()
	set_task(1.0, "dispTime", 652450, "", 0, "b");

} 
public bomb_defused()
{
	if(isBombPlanted)
	{
		remove_task(652450);
		isBombPlanted = false;
	}
	
}
public bomb_explode()
{
	if(isBombPlanted)
	{
		remove_task(652450);
		isBombPlanted = false;
	}
	
}
public dispTime()
{   
	if(!isBombPlanted)
	{
		remove_task(652450);
		return;
	}
	
	
	if(c4timer >= 0)
	{
		if(c4timer > 13) set_hudmessage(0, 150, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1);
		else if(c4timer > 7) set_hudmessage(150, 150, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1);
			else set_hudmessage(150, 0, 0, -1.0, 0.80, 0, 1.0, 1.0, 0.01, 0.01, -1);
		
		ShowSyncHudMsg(0, c4SyncMsg, "C4: %d", c4timer);
		
		--c4timer;
	}
	
}  
public client_disconnect(id){
	if( task_exists( id ) )
	{
		remove_task( id );
	}
}
public DisableC4Drop( const iEntity ) {
        
	SetHamReturnInteger( 0 );
        return HAM_SUPERCEDE;
}
public Message_StatusIcon(iMsgId, iMsgDest, usr)  {
	static szIcon[8];  
	get_msg_arg_string(2, szIcon, charsmax(szIcon));  
	if( equal(szIcon, "buyzone") ) 
	{  
		if( get_msg_arg_int(1) )  
		{
			set_pdata_int(usr, 235, get_pdata_int(usr, 235) & ~(1<<0)); 
			return PLUGIN_HANDLED;  
		}  
	}
	return PLUGIN_CONTINUE;  
}
ClientPrintColor( id, String[ ], any:... ){
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
