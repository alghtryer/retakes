
![](https://img.shields.io/badge/version-1.0-green?style=for-the-badge)
![](https://img.shields.io/badge/alghtryer@gmail.com-black?logo=gmail&style=for-the-badge)


The plugin sets up a retake situation in a random site in the map. TT plant bomb and CT have 40 seconds to defuse. \
TT spawned on bombsite( A or B), CT on random spwan depending of where c4 plant(A or B). 

### Features: 
- Warm Up for 30 seconds on map start. 
- Auto plant Bomb. 
- If CT win, team will be swap.
- If TT win 3(cvar) rounds in row, team well be swap.
- Playing 15(cvar) rounds and map change on nextmap.
- c4 Hud timer.
- Remove buy zones.

### Weapon:
Give a round and random weapon. \
Free Armor for all player and defuse for ct team. 
	
***Weapon per Rounds:***  
	
|Round	| CT		| T		
| --- | --- | --- |
|1.   |   usp	|	glock |
|2.| usp/m5	|	glock/m5 |	
|3.	|usp/famas |	glock/galil |
|4.-7.	| usp/m4a1 |	glock/ak47 |
|other	| deagle/m4a1	| deagle/ak47 |

***Random Weapon:*** \
From third round one player get smoke, one flash(2x), one he and \
one player per team get awp and deagle.

***Spawn*** \
Every map must have spawn for Site A and B. For now i crete 6 CT and 6 T spawn for this map: \
	- de_dust2, de_inferno, de_mirage, de_train, de_tuscan.

### API:
isRetakes()	// Check if retakes start. \
Rounds()	// Check round number.	
		
### Cvars:
retakes_rounds "15"			// How much playing round for one map \
retakes_rowwin "3"			// How much T Team can win round in row \
retake_prefix "!g[RETAKES]"		// Prefix in chat message \
retakes_random_weapons "3"		// In which round start giving random weapon(granades and awp) 


### Important Notes :
***You must enable nextmap.amxx.*** \
***Don't work with ReGameDLL!!!*** \
***Edit mapcycle.txt with maps for retakes*** 

### Images: 
<blockquote class="imgur-embed-pub" lang="en" data-id="a/J8ev5N8" data-context="false"><a href="//imgur.com/a/J8ev5N8">RETAKES v1.0</a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>


#### Credits:
- Map Spawns 			// jopmako 
- Auto Plant Bomb		// xPaw/Arkashine
- c4 Countdown Timer		// SAMURAI16 
