package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	import playerio.Connection;
	import flash.utils.Dictionary;
	import flash.events.*;
	
	public class PlayState extends FlxState {
		
		protected static const wasdControls:Controls = new Controls("W", "A", "S", "D");
		protected static const arrowControls:Controls = new Controls("UP", "LEFT", "DOWN", "RIGHT");
	
		//public var level:Level;
		public var levelData:Object;
		//Group together objects
		public var players:FlxGroup;
		public var boxes:FlxGroup;
		public var powerUps:FlxGroup;
		public var platforms:FlxGroup;
		public var masterMap:FlxGroup;
		public var zones:FlxGroup;
		public var scoreboard:FlxText;
		public var roundTime:FlxText;	//visible countdown for a timed game
		protected var running:Boolean = false;
		protected var clock:Clock;
		protected var timer:Clock;	//timer for a timed game
		
		protected var mode:int;
		public static const BOX_COLLECT:int = 0;
		public static const TIMED:int = 1;
		public static const RABBIT:int = 2;
		
		protected var rabbitInfo:Dictionary;
		
		protected var rabbitBox:Box;	//the rabbit box - player's must fight for this box
		
		public var RABBIT_TIMELIMIT:int = 60000;
		public var TIMELIMIT:int = 60000; //if the game is a TIMED game, the time limit per round; note that currently only pure mins are handled
		protected var MAX_SCORE:int = 1; //define a score at which the game ends
		
		//embed sounds
		[Embed(source = "../mp3/push_new.mp3")] private var Push:Class;
		[Embed(source = "../mp3/Bustabuss.mp3")] private var Music:Class;
		
		public function PlayState(data:Object, goal:int)
		{
			levelData = data;
			mode = goal;
		}
		
		override public function create():void {
			FlxG.bgColor = levelData.bg_color;
						
			clock = createClock();
			
			if (mode == TIMED) {
				timer = createClock();
				roundTime = new FlxText(-25, 25, FlxG.width, "0:00");
				roundTime.setFormat(null, 14, 0xFFFFFFFF, "right");
				add(roundTime);
			}
			
			scoreboard = new FlxText(0, FlxG.height - 25, FlxG.width, "SpringBox");
			scoreboard.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(scoreboard);
			
			players = new FlxGroup();
			createPlayers();
			
			
			zones = new FlxGroup();
			if (mode != RABBIT) { createZones(); }	//don't create zones if mode is rabbit
			add(zones);
			add(players);	
			
			if (mode == RABBIT) {
				rabbitInfo = new Dictionary();
				
				var player1clock:Clock = createClock();
				var player1timer:FlxText = new FlxText( 25, 25, FlxG.width, "0:00"); //text indicating how much time the player1 must hold the rabbit
				player1timer.setFormat(null, 14, 0xFFFFFFFF, "left");
				rabbitInfo[players.members[0]] = { clock: player1clock, countdownTime: player1timer };
				
				var player2clock:Clock = createClock();
				var player2timer:FlxText = new FlxText( -25, 25, FlxG.width, "0:00"); //text for player2
				player2timer.setFormat(null, 14, 0xFFFFFFFF, "right");
				rabbitInfo[players.members[1]] = { clock: player2clock, countdownTime: player2timer };
								
				add(player1timer);
				add(player2timer);
				add(rabbitBox);
			}
			
			//create the goal boxes
			boxes = new FlxGroup();

			var index:int = 0 ;
			if (mode == RABBIT) { 
				var x:int;
				var y:int;
				if (!levelData.rabbit_box) {
					trace ("Undefined rabbit box position values. Using default rabbit box but you may want to specify your own");
					x = FlxG.width * 1 / 2 - 5;
					y = 10 * 16;
				}
				else {
					x  = levelData.rabbit_box.x; 
					y  = levelData.rabbit_box.y;
				}
				rabbitBox = new Box(x, y, index);
				boxes.add(rabbitBox);
				index++;
			}
			else {
				for each(var boxinfo:Object in levelData.boxes) {
					boxes.add(new Box(boxinfo.x, boxinfo.y, index));
					index++;
				}
			}
			add(boxes);
			
			powerUps = new FlxGroup();
			createPowerUps();
			add(powerUps);
			
			masterMap = new FlxGroup();
			
			for each (var map:Object in levelData.maps) {
				var layerMap:FlxTilemap = new FlxTilemap();
				layerMap.loadMap(new map.layout, map.texture, 16, 16, FlxTilemap.OFF, 0, 1, 1);
				masterMap.add(layerMap);
			}
			add(masterMap);
			
			//add the moving platforms 
			//TODO: all this platform code needs to be cleaned up.
			//First step: move the path creation to an addPath() function
			platforms = new FlxGroup();

			for each(var platforminfo:Object in levelData.platforms) {
				var newPlatform:Platform = new Platform(new FlxPoint(platforminfo.start_x, platforminfo.start_y), // start
														new FlxPoint(platforminfo.end_x, platforminfo.end_y), // end
														platforminfo.circuitTime, // circuitTime
														platforminfo.offset, // offset
														platforminfo.width, // width
														platforminfo.height, // height
														clock,
														platforminfo.oneWay);
				platforms.add(newPlatform);
			}
			add(platforms);
			
			//FlxG.playMusic(Music);
			this.afterCreate();
		}
		
		override public function update():void {
			if (!running) {
				return;
			}
			
			super.update();
			clock.addTime(FlxG.elapsed);
			
			handlePowerUpTriggering();
			handleBoxCollisions();
			handlePlatformCollisions();
			handlePlayerCollisions();
			
			respawnPlayers();
			respawnBoxes();
			
			var winner:Player = checkForWinner();
			if (winner != null) {
				endGame(winner);
			}
			
			//update scoreboard
			scoreboard.text = "SCORE: " + players.members[0].getScore() + " - " + players.members[1].getScore();
			checkGameOver();
		}
		
		/**
		 * End the game with the specified winner.
		 * @param	winner
		 */
		protected function endGame(winner:Player):void {
			winner.incrementScore();
			resetGame();
		}
		
		/**
		 * Check if a player has won the game.
		 * @return The player if there is a winner, null if not.
		 */
		private function checkForWinner():Player {
			
			var player:Player;
			var box:Box;
			
			switch (mode) {
				case BOX_COLLECT:
					for each (var zone:Zone in zones.members) {
						var count:int = 0;
						for each (box in boxes.members) {
							if ((FlxU.abs(zone.getMidpoint().x - box.getMidpoint().x) <= zone.width / 2) &&
								(FlxU.abs(zone.getMidpoint().y - box.getMidpoint().y) <= zone.height / 2))
								count++;
						}					
						if (count >= 3) {
							return zone.player;
						}
					}
					break;
				
				case TIMED:	
					updateTimer();
					
					if (timer.elapsed > TIMELIMIT) {
						var zoneWithMostBoxes:Zone;
						var maxBoxNum:int = -1;
						var tie:Boolean = false;
						
						for each (var zone1:Zone in zones.members) {
							var numBoxes:int = getNumBoxesInZone(zone1);
							if (numBoxes > maxBoxNum) {
								tie = false;
								zoneWithMostBoxes = zone1;
								maxBoxNum = numBoxes;
							}
							else if (numBoxes == maxBoxNum) {
								tie = true;
							}
						}
						if (!tie) {
							return zoneWithMostBoxes.player;
						}
					}
					break;	
				
				case RABBIT:
					updateRabbitTimers();
					
					for each (player in players.members) {
						if (rabbitInfo[player].clock.elapsed > RABBIT_TIMELIMIT) {
							return player;
						}
					}
					break;
					
				default:
					trace ("Invalid game mode was inputted");
			}
			return null;
		}
		
		protected function boxPickedup(player:Player, box:Box):void {
			trace (player.id + "box picked up");
		}
		
		private function handleBoxCollisions():void 
		{
			for each (var box:Box in boxes.members) {
				if (box.isAvailable()) {
					for each (var player:Player in players.members) {
						if (FlxG.collide(player, box)) {
							// This may not be the best solution. Currently, a player can only determine if *they* have picked up a box, not another player.
							if (player is ActivePlayer) {
								if (player.pickupBox(box)) {
									boxPickedup(player, box);
								}
							}
						}
					}
				}
				else if (box.isInFlight()) {
					for each (player in players.members) {
						if (FlxG.collide(box, player))
							player.hitWithBox(box);
					}
				}
			}
			
			FlxG.collide(masterMap, boxes);
			FlxG.collide(platforms, boxes);
			FlxG.collide(boxes, boxes);
		}
		
		private function respawnPlayers():void 
		{
			for each (var player:Player in players.members) {
				if (player.y > FlxG.height) {
					respawnPlayer(player);
				}
			}
		}
		
		protected function respawnPlayer(player:Player):void {
			if (player.hasBox()) {
				var box:Box = player.boxHeld;
				player.dropBox();
				box.reset(box.getSpawn().x, box.getSpawn().y);
			}
			
			player.reset(player.getSpawn().x, player.getSpawn().y);
		}
		
		private function respawnBoxes():void 
		{
			for each (var box:Box in boxes.members) {
				if (box.y > FlxG.height)
					box.reset(box.getSpawn().x, box.getSpawn().y);
			}
		}
		
		private function handlePlatformCollisions():void 
		{
			for each (var platform:Platform in platforms.members) {
				for each (var player:Player in players.members) {
					//handle one-way platforms first
					if (platform.isOneWay()) {
						//Players should only collide with the top edge of the platform, and only from above.
						if (player.isAbove(platform)) { 
							if (FlxG.collide(platform, player)) {
								player.velocity.y = platform.maxVelocity.y;
							}
						}
					}
					else if (FlxG.collide(platform, player)) {
						//If a player collides with an elevator (platform with y velocity), give the player
						//the platform's max y velocity for two reasons: (1) keeps the player glued to the top
						//surface, and (2) keeps the player from sticking to the bottom of an elevator on it's down cycle.
						if (player.isAbove(platform) || player.isBelow(platform)) {
							player.velocity.y = platform.maxVelocity.y;
						}
						//Players get squished if stuck between moving platform and any wall
						if (FlxG.collide(player, masterMap) 
							&&
							((player.isAbove(platform) && player.isTouching(FlxObject.CEILING)) ||
							 (player.isBelow(platform) && player.isTouching(FlxObject.FLOOR)) ||
							 (player.isLeftOf(platform) && player.isTouching(FlxObject.LEFT)) ||
							 (player.isRightOf(platform) && player.isTouching(FlxObject.RIGHT)))) {
							respawnPlayer(player);
							trace("squish");
						}
					}
				}
				for each (var box:Box in boxes.members) {
					if (FlxG.collide(box, platform)) {
						if (box.isAbove(platform))
							box.velocity.y = platform.maxVelocity.y;
					}
				}
			}
		}
		
		private function handlePlayerCollisions():void 
		{
			//player collisions (bumping one another) -> consider all player pairs
			for each (var player:Player in players.members) {
				for each (var player2:Player in players.members) {
					if (FlxG.collide(player, player2)) {
						//players who hold boxes drop them when bumped
						FlxG.play(Push);
						dropBoxesOnCollision(player);
						dropBoxesOnCollision(player2);
						
						//determine orientation
						var dir:int = 1;
						if (player.x < player2.x)
							dir = -1;
						
						player.velocity.x = dir * player.maxVelocity.x;
						player2.velocity.x = -dir * player2.maxVelocity.x;
					}
				}
			}
			
			FlxG.collide(masterMap, players);
		}
		
		protected function dropBoxesOnCollision(player:Player):void 
		{
			player.dropBox();
		}
		
		/**
		 * Create each of the players and the zones.
		 */
		protected function createPlayers():void 
		{
			//add two players for now
			players.add(new ActivePlayer(levelData.startInfo[0].x, levelData.startInfo[0].y, 1, levelData.startInfo[0].color, null, wasdControls, levelData.startInfo[0].walkAnimation));
			players.add(new ActivePlayer(levelData.startInfo[1].x, levelData.startInfo[1].y, 2, levelData.startInfo[1].color, null, arrowControls, levelData.startInfo[1].walkAnimation));
		}
		
		//each player has a home zone that they're trying to fill up with blocks,
		//so add a zone centered on the player's spawn location (assumes players spawn in mid air)
		protected function createZones():void {
			for each (var player:Player in players.members) {
				var zone:Zone = new Zone(player.getSpawn().x - 48, player.getSpawn().y - 48, 96, 96, player); //dimensions multiples of 16
				zone.makeGraphic(zone.width, zone.height, player.getColour() - 0x55000000); 
				zones.add(zone);
			}			
		}

		/**
		 * Run any logic necessary after the create function is called.
		 */
		protected function afterCreate():void 
		{
			running = true;
			return;
		}
	
		protected function createClock() : Clock {
			return new Clock(null);
		}
		
		protected function getNumBoxesInZone(zone:Zone) : int {
			var numBoxes:int = 0;
			
			for each (var box:Box in boxes.members) {
				if ((FlxU.abs(zone.getMidpoint().x - box.getMidpoint().x) <= zone.width / 2) &&
					(FlxU.abs(zone.getMidpoint().y - box.getMidpoint().y) <= zone.height / 2))
					numBoxes++;
			}
			return numBoxes;
		}
		
		/*
		 * Update the timer for timed mode
		 */
		protected function updateTimer():void {
			timer.addTime(FlxG.elapsed);
			if (timer.elapsed > TIMELIMIT) {
				roundTime.text = "Overtime!";
			} else {		 
				roundTime.text = getCountdownString(TIMELIMIT, timer.elapsed);
			}
		}
		
		/*
		 * Update the player's timers for rabbit mode
		 */ 
		protected function updateRabbitTimers():void {
			for each (var player:Player in players.members) {
				var timer:Clock = rabbitInfo[player].clock;
				if (player.boxHeld != null) {
					if (player.boxHeld.id == rabbitBox.id) {
						timer.addTime(FlxG.elapsed);
					}
				}			 
				rabbitInfo[player].countdownTime.text = getCountdownString(RABBIT_TIMELIMIT, timer.elapsed);
			}
		}
		
		/*
		 * Get the time remaining
		 * @param timelimit: the time limit of the countdown
		 * @param timeElapsed: the total time passed for the countdown
		 * @return time remaining as a string in the format "min:seconds"
		 */
		protected function getCountdownString(timelimit:int, timeElapsed:int) : String{
			var numberOfMinsLeft:int = (timelimit / 60000) - (timeElapsed / 60000);
			var numberOfSecondsLeft:int = (60 - (timeElapsed / 1000)%60) % 60;
			var secondsLeft:String;
				
			numberOfSecondsLeft < 10 ? secondsLeft = "0" + numberOfSecondsLeft.toString() : secondsLeft = numberOfSecondsLeft.toString();
			return numberOfMinsLeft + ":" + secondsLeft
		}
		
		/**
		 * Create all the powerups at the start of the game.
		 */
		protected function createPowerUps():void {
			var index:int = 0;
			for each (var speedBoost:Object in levelData.powerUps.speedBoosts) {
				powerUps.add(new SpeedBoost(speedBoost.x, speedBoost.y, index, clock));
			}	
		}
		
		/**
		 * Collide each of the players with the powerups and trigger them.
		 */
		protected function handlePowerUpTriggering():void {
			for each (var player:Player in players.members) {
				for each (var powerUp:PowerUp in powerUps.members) {
					if (FlxG.collide(player, powerUp)) {
						triggerPowerUp(powerUp, player);
						powerUps.remove(powerUp);
					}
				}
			}
		}
		
		/**
		 * Trigger a powerUp. This is overridden for multiplayer games.
		 * @param	powerUp
		 * @param	player
		 */
		protected function triggerPowerUp(powerUp:PowerUp, player:Player):void {
			powerUp.trigger(player, this);
		}
		
		/**
		 * @param	id The id of the box.
		 * @return The box.
		 */
		protected function getBox(id:int):Box {
			return boxes.members[id];
		}
		
		/**
		 * @param	id The id of the player.
		 * @return The player.
		 */
		protected function getPlayer(id:int):Player {
			for each (var player:Player in players.members) {
				if (player.id == id) {
					return player;
				}
			}
			return null;
		}
		
		/**
		 * Reset the player and box locations and the timer.
		 */
		protected function resetGame():void 
		{
			trace("Game over!");
			for each (var player:Player in players.members) {
				player.dropBox();
				player.reset(player.getSpawn().x, player.getSpawn().y);
			}
			
			for each (var box:Box in boxes.members) {
				box.reset(box.getSpawn().x, box.getSpawn().y);
			}
			if (timer != null) {
				timer.elapsed = 0;
			}
		}
		
		protected function checkGameOver():void {
		
			for each (var player:Player in players.members) {
				if ( player.getScore() >= MAX_SCORE ) {
					FlxG.pauseSounds();
					FlxG.switchState( new GameOverState(levelData, mode, null, -1, -1));
				}
			}
			
		}
	}
}