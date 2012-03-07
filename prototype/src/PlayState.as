package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	import playerio.Connection;
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
		public static var masterMap:FlxGroup;
		public var zones:FlxGroup;
		public var scoreboard:FlxText;
		public var roundTime:FlxText;
		protected var running:Boolean = false;
		protected var clock:Clock;
		protected var timer:Clock;
		protected var mode:int;
		public static const BOX_COLLECT:int = 0;
		public static const TIMED:int = 1;
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
			zones = new FlxGroup();
			createPlayers();
			add(zones);
			add(players);
			
			//create the goal boxes
			boxes = new FlxGroup();

			boxes.add(new Box(20, 300, 0));
			var index:int = 0 ;
			for each(var boxinfo:Object in levelData.boxes) {
				boxes.add(new Box(boxinfo.x, boxinfo.y, index));
				index++;
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
														clock);
				
				newPlatform.maxVelocity.x = platforminfo.maxVelocity_x;
				newPlatform.maxVelocity.y = platforminfo.maxVelocity_y;
				platforms.add(newPlatform);
			}
			add(platforms);
			
			FlxG.playMusic(Music);
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
			handleElevatorCollisions();
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
		
		private function handleElevatorCollisions():void 
		{
			for each (var platform:Platform in platforms.members) {
				for each (var player:Player in players.members) {
					if (FlxG.collide(platform, player)) {
						//Elevator collision detection is non-standard: if a sprite is standing on top of the elevator
						//then give it a downward velocity to keep it glued to the elevator.
						if (platform.maxVelocity.y != 0) {
							player.velocity.y = platform.maxVelocity.y; 
						}
						//Players get squished if stuck between moving platform and a wall
						if (FlxG.collide(player, masterMap) && !player.isTouching(FlxObject.FLOOR)) {
							respawnPlayer(player);
						}
					}
				}
				for each (var box:Box in boxes.members) {
					if (platform.maxVelocity.y != 0) {
						if (FlxG.collide(platform, box) && box.isTouching(FlxObject.FLOOR))
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
			FlxG.collide(platforms, players);
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
			
			//each player has a home zone that they're trying to fill up with blocks,
			//so add a zone centered on the player's spawn location (assumes players spawn in mid air)
			for each (var player:Player in players.members) {
				var zone:Zone = new Zone(player.getSpawn().x - 50, player.getSpawn().y - 53, 100, 100, player);
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
		
		protected function updateTimer():void {
			timer.addTime(FlxG.elapsed);
			if (timer.elapsed > TIMELIMIT) {
				roundTime.text = "Overtime!";
			} else {
				var numberOfMinsLeft:int = (TIMELIMIT / 60000) - (timer.elapsed / 60000);
				var numberOfSecondsLeft:int = 60 - (timer.elapsed / 1000) % 60;
				var secondsLeft:String;
				
				numberOfSecondsLeft < 10 ? secondsLeft = "0" + numberOfSecondsLeft.toString() : secondsLeft = numberOfSecondsLeft.toString();			 
				roundTime.text = numberOfMinsLeft + ":" + secondsLeft;
			}
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