/*
*	___________
*
*	R E T A K E S   W e a p o n   v1.0
*	alghtryer.github.io/retakes
*		
*	Author: ALGHTRYER
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*	 
*	Give a round and random weapon.
*	Free Armor for all player and defuse for ct team.
*	
*	Weapon per Rounds:
*	
*	Round	| CT		| T		
*	- - - 	  - - -		  - - -
*	1.      usp		glock
*	2.	usp/m5		glock/m5		
*	3.	usp/famas	glock/galil	
*	4.-7.	usp/m4a1	glock/ak47	
*	other	deagle/m4a1	deagle/ak47
*
*	Random Weapon: 
*	From third round one player get smoke, one flash(2x) and one he.
*	From fourth round one player per team get awp and deagle.
*
*	Cvars:
*	- - - - -
*	retakes_random_weapons "3"		// In which round start giving random weapon(granades and awp)
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
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <retakes>


new PLUGIN[]	= "Retakes Weapon";
new AUTHOR[]	= "ALGHTRYER"; 		// <alghtryer.github.io>
new VERSION[]	= "1.0";


new WeaponBPAmmo[] ={
	0, 52, 0, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30,	120, 200, 32, 90, 120, 90, 2, 35, 90, 90, 0, 100
};
new RndWeapon;


public plugin_init() { 
	
	register_plugin
	(
		PLUGIN,		//: Retakes Weapon
		VERSION,	//: 1.0
		AUTHOR		//: ALGHTRYER <alghtryer.github.io>
	);

	register_cvar("retakes_weapon_version", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED);
	
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn", 1);
	register_logevent("RoundStart", 2, "1=Round_Start");
	
	RndWeapon			= register_cvar("retakes_random_weapons","3");
} 
public OnPlayerSpawn(id) 
{
	if (is_user_alive(id)) 
	{
		if(isRetakes()){
			strip_user_weapons(id);
			give_item(id,"weapon_knife");
			cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
			
			new CsTeams:iTeam = cs_get_user_team(id);
			
			switch(iTeam) { 
				case CS_TEAM_T: { 
					switch ( Rounds() ){
						case 1: {
							GiveWeapons(id, "weapon_glock18"); 
						}
						case 2: {
							GiveWeapons(id, "weapon_glock18");
							GiveWeapons(id, "weapon_mp5navy");
						}
						case 3: {
							GiveWeapons(id, "weapon_glock18");
							GiveWeapons(id, "weapon_galil");
						}
						case 4,5,6,7: {
							GiveWeapons(id, "weapon_glock18");
							GiveWeapons(id, "weapon_ak47");
						}
						default:{
							GiveWeapons(id, "weapon_deagle");
							GiveWeapons(id, "weapon_ak47");
						}
					}
				} 
				case CS_TEAM_CT: {  
					cs_set_user_defuse(id, 1);
					switch ( Rounds() ){
						case 1: {
							GiveWeapons(id, "weapon_usp"); 
						}
						case 2: {
							GiveWeapons(id, "weapon_usp");
							GiveWeapons(id, "weapon_mp5navy");
						}
						case 3: {
							GiveWeapons(id, "weapon_usp");
							GiveWeapons(id, "weapon_famas");
						}
						case 4,5,6,7: {
							GiveWeapons(id, "weapon_usp");
							GiveWeapons(id, "weapon_m4a1");
						}
						default:{
							GiveWeapons(id, "weapon_deagle");
							GiveWeapons(id, "weapon_m4a1");
						}
					}
				} 
			} 
			
		}
	}
}
public RoundStart(){
	if(isRetakes()){
		if(Rounds() >= get_pcvar_num(RndWeapon)){
			RandomPlayersCT();
			RandomPlayersT();
		}
	}
}
public RandomPlayersCT(){
	new players[32], total;
	get_players(players, total, "aeh", "CT");
	
	new retrieve = 4;
	
	if(total == 0)
		return PLUGIN_HANDLED;
	
	if( retrieve > total ) 
		retrieve = total;
	
	new selected[32], count, rand;
	do{
		rand = random(total);
		selected[count++] = players[rand];
		
		new id = players[rand];
		
		if(count == 1){
			give_item(id, "weapon_smokegrenade");
		}
		else if(count == 2){
			give_item(id, "weapon_hegrenade");
		}
		else if(count == 3){
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
		}
		else if(count == 4){
			strip_user_weapons(id);
			give_item(id,"weapon_knife");
			GiveWeapons(id, "weapon_awp");
		}
		
		players[rand] = players[--total];
	}
	while( count < retrieve );
	
	return PLUGIN_CONTINUE
}
public RandomPlayersT(){
	new players[32], total;
	get_players(players, total, "aeh", "TERRORIST");
	
	new retrieve = 4;
	
	if(total == 0)
		return PLUGIN_HANDLED;
	
	if( retrieve > total ) 
		retrieve = total;
	
	new selected[32], count, rand;
	do{
		rand = random(total);
		selected[count++] = players[rand];
		
		new id = players[rand];
		
		if(count == 1){
			give_item(id, "weapon_smokegrenade");
		}
		else if(count == 2){
			give_item(id, "weapon_hegrenade");
		}
		else if(count == 3){
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
		}
		else if(count == 4){
			strip_user_weapons(id);
			give_item(id,"weapon_knife");
			GiveWeapons(id, "weapon_awp");
		}
		
		players[rand] = players[--total];
	}
	while( count < retrieve );
	
	return PLUGIN_CONTINUE;
}
stock GiveWeapons(id, szFlags[]) { 
	if (is_user_alive(id)) { 
		new iWeaponId = get_weaponid(szFlags);
		if(!user_has_weapon(id, iWeaponId))
		{ 
			give_item(id, szFlags); 
		}
		cs_set_user_bpammo(id, iWeaponId, WeaponBPAmmo[iWeaponId]);
	}		
}
/* 
	MADE BY ALGHTRYER.
*/

