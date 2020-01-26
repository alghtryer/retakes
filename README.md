# RETAKES v1.0

![](https://img.shields.io/badge/version-1.0-green?style=for-the-badge)
![](https://img.shields.io/badge/alghtryer@gmail.com-black?logo=gmail&style=for-the-badge)

```
v1.1 [22. Jan 2020]
	- Added	eight new cvars.
	- Added buy zone and disable buy.
	- Small bug fixed.
	- Added perment hud message for bombsite info.
```
The plugin sets up a retake situation in a random site in the map. TT plant bomb and CT have 40 seconds to defuse. \
TT spawned on bombsite( A or B), CT on random spwan depending of where c4 plant(A or B). 

#### Features: 
- Warm Up for 30 seconds on map start. 
- Auto plant Bomb. 
- If CT win, team will be swap.
- If TT win 3(cvar) rounds in row, team well be swap.
- Playing 15(cvar) rounds and map change on nextmap.
- c4 Hud timer.
- Buy Time for 5seconds(cvar).
- Unlock/Remove buy zones.
- If bomb don't plant, round will be restarted. Rounds and player money/kill/deats be returned on same.


***Spawn*** \
Every map must have spawn for Site A and B. For now i crete 6 CT and 6 T spawn for this map: \
	- de_dust2, de_inferno, de_mirage, de_train, de_tuscan.

#### API:
isRetakes()	// Check if retakes start. \
Rounds()	// Check round number.	
		
#### Cvars:
retakes_rounds "15"			// How much playing round for one map \
retakes_rowwin "3"			// How much T Team can win round in row \
retake_prefix "!g[RETAKES]"		// Prefix in chat message \
retakes_autoplant "1"			// Auto Plant Bomb is on/off
retakes_buyzone 1			// Unlock/remove buy zone
retakes_warmup_time "30"		// Warm Up time min=1
retakes_infohud "1"			// Info hud on/off
retakes_buytime "5"			// Buy Time
retakes_swapct "1"			// On/off Swap CT
retakes_swapt "1"			// On/off Swap T
retakes_hudc4timer "1"			// On/off c4 hud timer


#### Important Notes :
***You must enable nextmap.amxx.*** \
***Auto Plant Bomb don't work with ReGameDLL!!!*** \
***Edit mapcycle.txt with maps for retakes*** 

#### Images: https://imgur.com/a/J8ev5N8


#### Credits:
- Map Spawns 			// jopmako 
- Auto Plant Bomb		// xPaw/Arkashine
- c4 Countdown Timer		// SAMURAI16 
- Disable Buy			// Exolent
- Unlock BuyZone		// VEN
