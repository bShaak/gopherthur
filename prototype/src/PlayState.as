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
		//animations
		[Embed(source = "sprites/hop_right_16x24_red.png")] protected static const AnimateWalkRed:Class;
		[Embed(source = "sprites/hop_right_16x24_blue.png")] protected static const AnimateWalkBlue:Class;
		
		protected static const wasdControls:Controls = new Controls("W", "A", "S", "D");
		protected static const arrowControls:Controls = new Controls("UP", "LEFT", "DOWN", "RIGHT");
		protected static const startInfo:Array = [ { x: FlxG.width / 10, y: 370, color:0xaa22dc22, walkAnimation: AnimateWalkRed},
												   { x: FlxG.width * 9 / 10, y: 370, color:0xaadc2222, walkAnimation: AnimateWalkBlue} ];

		
		public var level:Level;
		
		//Group together objects
		public var players:FlxGroup;
		public var boxes:FlxGroup;
		public var powerUps:FlxGroup;
		public var platforms:FlxGroup;
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
		protected var MAX_SCORE:int = 3; //define a score at which the game ends
		
		//embed sounds
		[Embed(source = "../mp3/push_new.mp3")] private var Push:Class;
		[Embed(source = "../mp3/Bustabuss.mp3")] private var Music:Class;
		
		//tiles
		//[Embed(source = "textures/default_tiles.png")] private var DefaultTiles:Class;
		
		public function PlayState(goal:int)
		{
			mode = goal;
		}
		
		override public function create():void {
			FlxG.bgColor = 0xff66cdaa;
						
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
			
			//TODO: add menu to handle level selection
			level = new Level("basic");
			//level = new Level("ray_test_map");
			level.initialize();
			
			players = new FlxGroup();
			zones = new FlxGroup();
			createPlayers();
			add(zones);
			add(players);
			
			//create the goal boxes
			boxes = new FlxGroup();

			boxes.add(new Box(20, 300, 0));
			boxes.add(new Box(35, 300, 1));
			boxes.add(new Box(230, 300, 2));
			//boxes.add(new Box(FlxG.width * 1 / 2 - 25, 40, 0));
			//boxes.add(new Box(FlxG.width * 1 / 2 - 15, 10, 1)); 
			//boxes.add(new Box(FlxG.width * 1 / 2 - 5, 40, 2));
			boxes.add(new Box(FlxG.width * 1 / 2 + 5, 10, 3));
			boxes.add(new Box(FlxG.width * 1 / 2 + 15, 40, 4));
			add(boxes);
			
			powerUps = new FlxGroup();
			createPowerUps();
			add(powerUps);
			
			//add the moving platforms 
			//TODO: all this platform code needs to be cleaned up.
			//First step: move the path creation to an addPath() function
			platforms = new FlxGroup();
			//first add an elevator
			var elevator:Platform
			
			// This has way too many parameters. In the future though, this should all be contained in a map file I think.
			elevator = new Platform(new FlxPoint(FlxG.width / 2, FlxG.height - 160), // start
									new FlxPoint(FlxG.width / 2, 250), // end
									2500, // circuitTime
									0, // initialPosition
									80, // width
									16, // height
									clock); //TODO: ugh, not so many heuristic numbers floating around here
									
			elevator.maxVelocity.x = 120;
			elevator.maxVelocity.y = 100;
			
			platforms.add(elevator);
			
			//we also want some moving platforms
			var plat_y:int = 225; //height of these platforms... god this code is ugly
			
			var plat1:Platform;
			plat1 = new Platform(new FlxPoint(100, plat_y), // start
								new FlxPoint(FlxG.width / 2 - 120, plat_y), // end
								2500, // circuitTime
								0, // offset
								80, //width
								16, // height
								clock);
			plat1.maxVelocity.x = 60;
			platforms.add(plat1);
			
			var plat2:Platform;
			plat2 = new Platform(new FlxPoint(FlxG.width / 2 + 120, plat_y), // start
								new FlxPoint(FlxG.width - 100, plat_y), // end
								2500, // circuitTime
								1, // offset
								80, // width
								16, // height
								clock);
			plat2.maxVelocity.x = 60;
			platforms.add(plat2);
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
			
			FlxG.collide(level.masterLevel, boxes);
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
			//Elevator collision detection is non-standard: if a sprite is standing on top of the elevator
			//then give it a downward velocity to keep it glued to the elevator.
			
			// TODO: We need to fix the elevator handling.
			var elevator:Platform = platforms.members[0]; //yeah that's a hardcoded index...
			for each (var player:Player in players.members) {
				if (FlxG.collide(elevator, player) && player.isTouching(FlxObject.FLOOR))
					player.velocity.y = elevator.maxVelocity.y;
			}
			for each (var box:Box in boxes.members) {
				if (FlxG.collide(elevator, box) && box.isTouching(FlxObject.FLOOR))
					box.velocity.y = elevator.maxVelocity.y;
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
						player.dropBox();
						player2.dropBox();
						
						//determine orientation
						var dir:int = 1;
						if (player.x < player2.x)
							dir = -1;
						
						player.velocity.x = dir * player.maxVelocity.x;
						player2.velocity.x = -dir * player2.maxVelocity.x;
					}
				}
			}
			
			FlxG.collide(level.masterLevel, players);
			FlxG.collide(platforms, players);
		}
		
		/**
		 * Create each of the players and the zones.
		 */
		protected function createPlayers():void 
		{
			//add two players for now
			players.add(new ActivePlayer(startInfo[0].x, startInfo[0].y, 1, startInfo[0].color, null, wasdControls, startInfo[0].walkAnimation));
			players.add(new ActivePlayer(startInfo[1].x, startInfo[1].y, 2, startInfo[1].color, null, arrowControls, startInfo[1].walkAnimation));
						
			//each player has a home zone that they're trying to fill up with blocks,
			//so add a zone centered on the player's spawn location (assumes players spawn in mid air)
			for each (var player:Player in players.members) {
				var zone:Zone = new Zone(player.getSpawn().x - 50, player.getSpawn().y - 53, 100, 100, player);
				zone.makeGraphic(zone.width, zone.height, player.getColour()); 
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
			powerUps.add(new SpeedBoost(40, 340, 1, clock));
			powerUps.add(new SpeedBoost(FlxG.width - 50, 340, 2, clock));
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
					//FlxG.pauseSounds();
					FlxG.switchState( new GameOverState(mode, null, -1, -1));
				}
			}
			
		}
	}
}