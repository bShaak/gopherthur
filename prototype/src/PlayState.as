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
		public var singleAnimations:FlxGroup; //holds death animations, and any other one-off animated sprites
		public var boxes:FlxGroup;
		public var powerUps:FlxGroup;
		public var platforms:FlxGroup;
		public static var layerMap:FlxTilemap;
		public static var masterMap:FlxGroup;
		public var zones:FlxGroup;
		public var lava:FlxGroup; //maybe you'll want more than one lava pit?
		public var acid:FlxGroup;
		public var acidFlows:FlxGroup;
		public var lasers:FlxGroup;
		public var asteroids:FlxGroup;
		public var asteroidTime:Number = 0;
		public var drawArea:FlxSprite;
		
		public var random:PseudoRandom;
		public var randomSeed:int;
		public var scoreboard:FlxText;
		public var roundTime:FlxText;	//visible countdown for a timed game
		protected var running:Boolean = false;
		protected var clock:Clock;
		protected var timer:Clock;	//timer for a timed game
		protected var lastTime:int = 0;
		
		protected var mode:int;
		public static const BOX_COLLECT:int = 0;
		public static const TIMED:int = 1;
		public static const RABBIT:int = 2;
		
		protected var rabbitInfo:Dictionary;
		
		protected var rabbitBox:Box;	//the rabbit box - player's must fight for this box
		
		public var RABBIT_TIMELIMIT:int = 60000;
		public var TIMELIMIT:int = 60000; //if the game is a TIMED game, the time limit per round; note that currently only pure mins are handled
		protected var MAX_SCORE:int = 2; //define a score at which the game ends
		private var Music:Class;
		
		//embed sounds
		[Embed(source = "../mp3/push_new.mp3")] protected var Push:Class;
		//[Embed(source = "../mp3/Bustabuss.mp3")] private var Music:Class;
		[Embed(source = "../mp3/splatter.mp3")] private var splatter:Class;
		
		//player death animation
		[Embed(source = "/sprites/death_animation_128x96.png")] private var PlayerDeathAnimation:Class;
		
		
		//MIN JI'S PAUSE CODE START
		FlxG.paused = false;
		
		private var pauseBgColor:FlxSprite;

		private var pauseMenuButton:FlxButton;
		private var pauseGameButton:FlxButton;
		private var pauseMuteButton:FlxButton;
		//MIN JI'S PAUSE CODE END
		
		
		public function PlayState(data:Object, goal:int)
		{
			levelData = data;
			mode = goal;
			SBSprite.TOLERANCE = 4;
			randomSeed = (new Date()).getTime();
		}
		
		override public function create():void {
			FlxG.bgColor = levelData.bg_color;
			
			if (levelData.background) {
				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(levelData.background);
				add(bg);
			}
			
			Music = levelData.music;
			clock = createClock();
			random = new PseudoRandom(randomSeed);
			drawArea = new FlxSprite(0, 0);
			drawArea.makeGraphic(FlxG.width, FlxG.height, 0x00000000);
			add(drawArea);
			
			players = new FlxGroup();
			createPlayers();
			
			zones = new FlxGroup();
			if (mode != RABBIT) { createZones(); }	//don't create zones if mode is rabbit
			add(zones);
			add(players);
			
			powerUps = new FlxGroup();
			//createPowerUps();
			//add(powerUps);
			
			masterMap = new FlxGroup();
			
			for each (var map:Object in levelData.maps) {
				layerMap = new FlxTilemap();
				layerMap.loadMap(new map.layout, map.texture, 16, 16, FlxTilemap.OFF, 0, 1, 1);
				masterMap.add(layerMap);
			}
			add(masterMap);
			
			if (mode == TIMED) {
				timer = createClock();
				roundTime = new FlxText(0, 25, FlxG.width, "0:00");
				roundTime.setFormat(null, 14, 0xFFFFFFFF, "center");
				add(roundTime);
			}
			
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
					y = 3 * 16;
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
			
			platforms = new FlxGroup();
			
			for each(var platforminfo:Object in levelData.platforms) {
				var newPlatform:Platform = new BackForthPlatform(new FlxPoint(platforminfo.start_x, platforminfo.start_y), // start
														new FlxPoint(platforminfo.end_x, platforminfo.end_y), // end
														platforminfo.circuitTime, // circuitTime
														platforminfo.offset, // offset
														platforminfo.width, // width
														platforminfo.height, // height
														clock,
														platforminfo.oneWay);
				platforms.add(newPlatform);
			}
			
			for each(var info:Object in levelData.circlePlatforms) {
				platforms.add(new CirclePlatform(new FlxPoint(info.x, info.y), info.radius, info.rotateTime,
					info.initialRotation, info.reverse, info.width, info.height, clock, info.oneWay, drawArea,
					info.rotationsPerReverse));
			}
			
			for each(info in levelData.superPlatforms) {
				var p:SuperPlatform = new SuperPlatform(new FlxPoint(info.startMiddleX, info.startMiddleY),
												new FlxPoint(info.endMiddleX, info.endMiddleY),
												info.radius,
												info.circuitTime,
												info.rotateTime,
												info.initialPosition,
												info.initialRotation,
												info.reverse,
												info.width,
												info.height,
												clock,
												info.oneWay,
												drawArea);
				platforms.add(p);
				trace ("making super platform: " + info.startMiddleX );
			}
			add(platforms);
			
			singleAnimations = new FlxGroup();
			add(singleAnimations);
			
			lava = new FlxGroup();
			for each(var lavaInfo:Object in levelData.lava) {
				var lavaPit:Lava = new Lava(lavaInfo.x, lavaInfo.y,
											new FlxPoint(lavaInfo.start_x, lavaInfo.start_y),
											new FlxPoint(lavaInfo.end_x, lavaInfo.end_y),
											lavaInfo.circuitTime,
											lavaInfo.downTime,
											lavaInfo.warningTime,
											lavaInfo.offset,
											clock);
				lava.add(lavaPit);
			}
			add(lava);
			
			acidFlows = new FlxGroup();
			add(acidFlows);
			
			acid = new FlxGroup();
			for each (var acidInfo:Object in levelData.acid) {
				var acidPool:Acid = new Acid(acidInfo.x, acidInfo.y, acidInfo.width, acidInfo.height, acidFlows);
				acid.add(acidPool);
			}
			add(acid);

			scoreboard = new FlxText(0, FlxG.height - 25, FlxG.width, "SpringBox");
			scoreboard.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(scoreboard);
			
			asteroids = new FlxGroup();
			add(asteroids);
			
			lasers = new FlxGroup();
			add(lasers);
			
			for each(info in levelData.laserPlatforms) {
				var laserPlat:Platform = new LaserPlatform(new FlxPoint(info.start_x, info.start_y), // start
														new FlxPoint(info.end_x, info.end_y), // end
														info.circuitTime, // circuitTime
														info.offset, // offset
														info.width, // width
														info.height, // height
														clock,
														info.oneWay,
														info.dir,
														lasers,
														info.onTime,
														info.offTime,
														info.warmupTime,
														new PseudoRandom(randomSeed + int.MAX_VALUE * random.random()));
				platforms.add(laserPlat);
			}
			
			//MIN JI'S PAUSE CODE START
			pauseBgColor = new FlxSprite(0, 0);
			pauseBgColor.makeGraphic(FlxG.width, FlxG.height, 0x55000000);
			pauseBgColor.visible = false;
			add(pauseBgColor);
			
			pauseGameButton = new FlxButtonBig(FlxG.width / 2 - 60, FlxG.height / 2 - 80, "PLAY", dePause);
			pauseGameButton.label.setFormat(null, 16, 0x333333, "center");
			pauseGameButton.visible = false;
			add(pauseGameButton);
			
			pauseMenuButton = new FlxButtonBig(FlxG.width / 2 - 60, FlxG.height / 2 - 40, "MAIN MENU", pauseAndMenu);
			pauseMenuButton.label.setFormat(null, 16, 0x333333, "center");
			pauseMenuButton.visible = false;
			add(pauseMenuButton);

			pauseMuteButton = new FlxButtonBig(FlxG.width / 2 - 60, FlxG.height / 2, "MUTE", mute);
			
			if (FlxG.mute && FlxG.volume == 0) {
				pauseMuteButton.label = new FlxText(0, 0, 160, "UNMUTE");
			}
			pauseMuteButton.label.setFormat(null, 16, 0x333333, "center");
			pauseMuteButton.visible = false;
			add(pauseMuteButton);
			//MIN JI'S PAUSE CODE END
			
			FlxG.playMusic(Music);
			this.afterCreate();
		}
		
		override public function update():void {
			if (!running) {
				return;
			}
			
			players.active = true;
			platforms.active = true;
			
			pauseBgColor.visible = false;
			
			pauseMenuButton.visible = false;
			pauseGameButton.visible = false;
			pauseMuteButton.visible = false;

			
			//MIN JI'S PAUSE CODE START
			if (FlxG.keys.justPressed("P") && 
			(players.members[0] is ActivePlayer && players.members[1] is ActivePlayer)) {
					FlxG.paused = !FlxG.paused;
				}
				
			if (FlxG.paused) {
				players.active = false;
				platforms.active = false;
				
				pauseBgColor.visible = true;
				
				pauseMenuButton.visible = true;
				pauseGameButton.visible = true;
				pauseMuteButton.visible = true;
			
				pauseMenuButton.active = true;
				pauseGameButton.active = true;
				pauseMuteButton.active = true;
				
				pauseMenuButton.update();
				pauseGameButton.update();
				pauseMuteButton.update();
			}
			//MIN JI'S PAUSE CODE END
			
			if (!FlxG.paused) {
				drawArea.fill(0x00000000);
				super.update();
				clock.addTime(FlxG.elapsed);
			
				handlePowerUpTriggering();
				handlePlatformCollisions();
				handleBoxCollisions();
				handlePlayerCollisions();
				handleLavaCollisions();
				handleAcidCollisions();
				handleLaserCollisions();
				handleAsteroidCollisions();
				handleSingleAnimations();
				
				respawnDeadPlayers();
			}
			
			var winner:Player = checkForWinner();
			if (winner != null) {
				endGame(winner);
			}
			
			//update scoreboard
			scoreboard.text = "SCORE: " + players.members[0].getScore() + " - " + players.members[1].getScore();
			checkGameOver();
			
			for each (var player:Player in players.members) {
				player.updateRealVelocity((clock.elapsed - lastTime) / 1000.0);
			}
			lastTime = clock.elapsed;
		}
		
		
		//MIN JI'S PAUSE CODE START
		public function pauseAndMenu():void {			
			
			FlxG.pauseSounds();
				
			dePause();
			
			FlxG.switchState( new MenuState());
			
			resetGame();
		}
		
		public function dePause():void {					
			FlxG.paused = false;

			players.active = true;
			platforms.active = true;
			
			pauseMenuButton.visible = false;
			pauseGameButton.visible = false;
			pauseMuteButton.visible = false;
			
			pauseMenuButton.active = false;
			pauseGameButton.active = false;
			pauseMuteButton.active = false;
			
			pauseMenuButton.update();
			pauseGameButton.update();
			pauseMuteButton.update();
		}
		
		
		public function mute():void {
			FlxG.mute = !FlxG.mute;
			
			if(FlxG.mute) {
				FlxG.volume = 0;
				pauseMuteButton.label = new FlxText(0, 0, 160, "UNMUTE");
				pauseMuteButton.label.setFormat(null, 16, 0x333333, "center");
				pauseMuteButton.update();
			}
				
			if(!FlxG.mute) {
				FlxG.volume = 1;
				pauseMuteButton.label = new FlxText(0, 0, 160, "MUTE");
				pauseMuteButton.label.setFormat(null, 16, 0x333333, "center");
				pauseMuteButton.update();

			}
			
			dePause();
		}
		//MIN JI'S PAUSE CODE END

		
		

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
			var numBoxes:int;
			
			switch (mode) {
				case BOX_COLLECT:
					for each (var zone:Zone in zones.members) {
						numBoxes = getNumBoxesInZone(zone); 
						
						if (numBoxes >= 3) {
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
							numBoxes = getNumBoxesInZone(zone1);
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
							if (player is ActivePlayer && !player.isShoved()) {
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
		
		private function respawnDeadPlayers():void 
		{
			for each (var player:Player in players.members) {
				if (player.y > FlxG.height) {
					killAndRespawnPlayer(player);
				}
			}
		}
		
		protected function killAndRespawnPlayer(player:Player):void {
			player.visible = false;
			playDeathAnimation(player.x, player.y);
			
			respawnPlayer(player);
		}
		
		protected function respawnPlayer(player:Player):void {
			if (player.hasBox()) {
				var box:Box = player.boxHeld;
				player.dropBox();
				//box.reset(box.getSpawn().x, box.getSpawn().y); // Do we really want this? Taking it out for now. Can't remember if it had a good reason.
			}
			player.velocity.x = 0;
			player.velocity.y = 0;
			player.reset(player.getSpawn().x, player.getSpawn().y);
			player.visible = true;
		}
		
		//kill all animations once they're done (so like death animations cycle through once, then disappear
		protected function handleSingleAnimations():void {
			for each (var anim:FlxSprite in singleAnimations.members) {
				if (anim.finished)
					anim.kill();
			}
		}
		
		private function handlePlatformCollisions():void 
		{
			for each (var player:Player in players.members) {
				player.onPlat = -1;
			}
			for each (var box:Box in boxes.members) {
				box.onPlat = -1;
			}
			for each (var platform:Platform in platforms.members) {
				for each (player in players.members) {				
					//handle one-way platforms first
					if (platform.isOneWay()) {
						//Players should only collide with the top edge of the platform, and only from above.
						if (player.isAbove(platform)) { 
							if (FlxG.collide(platform, player)) {
								player.onPlat = platforms.members.indexOf(platform);
								player.velocity.y = platform.maxVelocity.y;
							}
						}
					}
					else if (FlxG.collide(platform, player)) {
						//If a player collides with an elevator (platform with y velocity), give the player
						//the platform's max y velocity for two reasons: (1) keeps the player glued to the top
						//surface, and (2) keeps the player from sticking to the bottom of an elevator on it's down cycle.
						if (player.isAbove(platform)) {
							player.onPlat = platforms.members.indexOf(platform);
						}
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
							killAndRespawnPlayer(player);
							trace("squish");
						}
					}
				}
				for each (box in boxes.members) {
					if (FlxG.collide(box, platform)) {
						if (box.isAbove(platform)) {
							box.onPlat = platforms.members.indexOf(platform);
							box.velocity.y = platform.maxVelocity.y;
						}
					}
				}
			}
		}
		
		private function handlePlayerCollisions():void 
		{
			//player collisions (bumping one another) -> consider all player pairs
			for each (var player:Player in players.members) {
				for each (var player2:Player in players.members) {
					if (!player.isShoved() && !player2.isShoved())
					{
						FlxG.overlap(player, player2, shovePlayer);
					}
				}
			}
			
			FlxG.collide(masterMap, players);
		}
		
		protected function shovePlayer(player:Player, player2:Player):void 
		{
			/*if (player.isShoved() || player2.isShoved())
				return;
			//trace("B4: " + player.velocity.x + " " + player2.velocity.x);
			if (player.isCharging() || player2.isCharging()) {
				FlxG.play(Push);
				if (Math.abs(player.velocity.x) > Math.abs(player2.velocity.x)) {
					dropBoxesOnCollision(player2);
					player2.getShoved(player);
					player.velocity.x = 0;
				}
				else {
					dropBoxesOnCollision(player);
					player.getShoved(player2);
					player2.velocity.x = 0;
				}
			}
			else {*/
				//players who hold boxes drop them when bumped
				FlxG.play(Push);
				dropBoxesOnCollision(player);
				dropBoxesOnCollision(player2);
					
				player.getBumped(player2);
				player2.getBumped(player);
				
				//determine orientation
				var dir:int = 1;
				var dir_y:int = 1;
				if (player.x < player2.x)
					dir = -1;
				if (player.y < player2.y)
					dir_y = -1;
						
				player.velocity.x = dir * player.maxVelocity.x;
				player2.velocity.x = -dir * player2.maxVelocity.x;
				player.velocity.y = dir_y * 100;
				player2.velocity.y = -dir_y * 100;
			//}
			//trace("After: " + player.velocity.x + " " + player2.velocity.x);s
		}
		
		private function handleLavaCollisions():void {
			for each (var player:Player in players.members) {
				if (FlxG.overlap(player, lava)) {
					// We don't want the box to respawn, so have to drop it here manually rather than
					// just calling respawnPlayer
					player.dropBox();
					killAndRespawnPlayer(player);
				}
			}
		}
		
		private function handleAcidCollisions():void {
			for each (var player:Player in players.members) {
				if (FlxG.overlap(player, acid)) {
					player.dropBox();
					killAndRespawnPlayer(player);
				}
			}
		}
		
		private function handleLaserCollisions():void {
			for each (var player:Player in players.members) {
				for each (var laser:Laser in lasers.members) {
					if (laser.visible && !laser.isWarmingUp() && FlxG.overlap(player, laser)) {
						player.dropBox();
						killAndRespawnPlayer(player);
					}
				}
			}
		}
		
		protected function playDeathAnimation(x:int, y:int):void 
		{
			var deathAnim:FlxSprite = new FlxSprite(x-64, y-48);
			deathAnim.loadGraphic(PlayerDeathAnimation, true, false, 128, 96);
			FlxG.play(splatter);
			deathAnim.addAnimation("exploding_death", [0, 1, 2, 3, 4, 5, 6, 7], 24, false);
			deathAnim.play("exploding_death");
			singleAnimations.add(deathAnim);
		}
		
		protected function startAsteroids():void 
		{
			if (levelData.asteroids) {
				clock.setTimeout(levelData.asteroids.fixedDelay, this.createAsteroid);
				asteroidTime = levelData.asteroids.fixedDelay;
			}
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
			startAsteroids();
			running = true;
			return;
		}
		
		/**
		 * Create an asteroid and queue up the next asteroid.
		 */
		protected function createAsteroid():void {
			var time:Number = levelData.asteroids.fixedDelay + Math.floor(random.random() * levelData.asteroids.randomDelay);
			var angle:Number = random.random() * Math.PI/4 - Math.PI/8;
			
			var x:int;
			if (random.random() >= 0.5) {
				x = -40;
			} else {
				x = FlxG.width;
				angle = Math.PI + angle;
			}
			
			var y:int = random.random() * (levelData.asteroids.regionBottom - levelData.asteroids.regionTop) + levelData.asteroids.regionTop;
			var speed:Number = levelData.asteroids.fixedSpeed + random.random() * levelData.asteroids.randomSpeed;
			asteroids.add(new Asteroid(x, y, speed, angle, asteroidTime, clock));
			
			clock.setElapsedTimeout(time + asteroidTime, this.createAsteroid);
			asteroidTime += time;
		}
	
		protected function handleAsteroidCollisions():void {
			for each (var player:Player in players.members) {
				for each (var asteroid:Asteroid in asteroids.members) {
					if (asteroid == null) {
						continue;
					}
					if (FlxG.collide(asteroid, player)) {
						//Players get squished if stuck between asteroid and any wall
						if (FlxG.collide(player, masterMap) 
							&&
							((player.isAbove(asteroid) && player.isTouching(FlxObject.CEILING)) ||
							 (player.isBelow(asteroid) && player.isTouching(FlxObject.FLOOR)) ||
							 (player.isLeftOf(asteroid) && player.isTouching(FlxObject.LEFT)) ||
							 (player.isRightOf(asteroid) && player.isTouching(FlxObject.RIGHT)))) {
							killAndRespawnPlayer(player);
						}
					}
				}
			}
			
			// Remove asteroids that have travelled off the level.
			for (var i:int = asteroids.members.length - 1; i >= 0; i--) {
				asteroid = asteroids.members[i];
				if (asteroid != null && !asteroid.alive) {
					asteroids.remove(asteroid);
				}
			}
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
			var player:Player = zone.player;  //ras
			player.setNumBoxesInZone(numBoxes);
			
			return numBoxes;
		}
		
		/*
		 * Update the timer for timed mode
		 */
		protected function updateTimer():void {
			if (!FlxG.paused) {		 
				timer.addTime(FlxG.elapsed);
			}
			
			if (timer.elapsed > TIMELIMIT) {
				roundTime.text = "Overtime!";
			}
			
			else {		 
				roundTime.text = getCountdownString(TIMELIMIT, timer.elapsed);
			}
		}
		
		/*
		 * Update the player's timers for rabbit mode
		 */ 
		protected function updateRabbitTimers():void {
			for each (var player:Player in players.members) {
				var timer:Clock = rabbitInfo[player].clock;
				if (player.boxHeld != null && !FlxG.paused) {
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
				powerUps.add(new SpeedBoost(speedBoost.x, speedBoost.y, index, speedBoost.respawnTime, clock));
			}	
		}
		
		/**
		 * Collide each of the players with the powerups and trigger them.
		 */
		protected function handlePowerUpTriggering():void {
			for each (var player:Player in players.members) {
				for each (var powerUp:PowerUp in powerUps.members) {
					if (!powerUp.used && FlxG.collide(player, powerUp)) {
						triggerPowerUp(powerUp, player);
						//powerUps.remove(powerUp);
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
			var index:int = 1;
			for each (var player:Player in players.members) {
				if ( player.getScore() >= MAX_SCORE ) {
					FlxG.pauseSounds();
					FlxG.switchState( new GameOverState(levelData, mode, null, -1, index));
				}
				index++;
			}
			
		}
	}
}