package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import flash.display.Sprite;
	import org.flixel.*;
	
	public class PlayState extends FlxState {
		
		public var level:FlxTilemap;
		public var player1:FlxSprite;
		public var player2:FlxSprite;
		public var goal:FlxSprite;
		public var elevator:FlxSprite;
		public var plat1:FlxSprite;
		public var plat2:FlxSprite;
		public var box:FlxSprite;
		public var carryingBox:Boolean;
		
		override public function create():void {
			FlxG.bgColor = 0xff666666;
			
			var data:Array = new Array(
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 );
			level = new FlxTilemap();
			level.loadMap(FlxTilemap.arrayToCSV(data, 40), FlxTilemap.ImgAuto, 0, 0, FlxTilemap.AUTO);
			add(level);
			
			carryingBox = false;
			
			player1 = new FlxSprite();
			player1.makeGraphic(10, 12, 0xff11aa11);
			player1.maxVelocity.x = 80;
			player1.maxVelocity.y = 200;
			player1.acceleration.y = 200;
			player1.drag.x = player1.maxVelocity.x * 4;
			add(player1);
			
			player2 = new FlxSprite();
			player2.makeGraphic(10, 12, 0xffaa1111);
			player2.maxVelocity.x = 80;
			player2.maxVelocity.y = 200;
			player2.acceleration.y = 200;
			player2.drag.x = player2.maxVelocity.x * 4;
			//player2.drag.y = player2.maxVelocity.y * 8;
			add(player2);
			
			// create a collectable box
			box = new FlxSprite();
			box.makeGraphic(5, 5, 0xff1111aa);
			box.maxVelocity.y = 10;
			add(box);
			
			goal = new FlxSprite();
			goal.makeGraphic(4, 5, 0xffffd700);
			//goal.maxVelocity.x = 60;
			//goal.maxVelocity.y = 250;
			//goal.acceleration.y = 250;
			goal.immovable = true;
			//goal.drag.x = goal.maxVelocity.x * 4;
			add(goal);
			
			//initialize player and goal positions
			restartPlayerPositions();
			
			//add an elevator
			elevator = new FlxSprite(FlxG.width/2 - 25, FlxG.height - 80);
			elevator.makeGraphic(50, 10, 0xffffffff);
			elevator.maxVelocity.y = 5;
			elevator.immovable = true; //so the objects on top of it don't weigh it down
			var elevator_path:FlxPath = new FlxPath();
			elevator_path.add(FlxG.width/2, FlxG.height - 80);
			elevator_path.add(FlxG.width/2, 125);
			elevator.followPath(elevator_path, 50, FlxObject.PATH_YOYO);
			add(elevator);
			
			
			//add some moving platforms (these should be a class...)
			
			var plat_y:int = 115; //height of these platforms
			
			plat1 = new FlxSprite(25, plat_y);
			plat1.makeGraphic(50, 10, 0xffffffff);
			plat1.maxVelocity.x = 20;
			plat1.immovable = true;
			var plat1_path:FlxPath = new FlxPath();
			plat1_path.add(50, plat_y);
			plat1_path.add(FlxG.width/2 - 60, plat_y);
			plat1.followPath(plat1_path, 50, FlxObject.PATH_YOYO);
			
			plat2 = new FlxSprite(FlxG.width/2 + 35, plat_y);
			plat2.makeGraphic(50, 10, 0xffffffff);
			plat2.maxVelocity.x = 20;
			plat2.immovable = true;
			var plat2_path:FlxPath = new FlxPath();
			plat2_path.add(FlxG.width/2 + 60, plat_y);
			plat2_path.add(FlxG.width - 50, plat_y);
			plat2.followPath(plat2_path, 50, FlxObject.PATH_YOYO);
			
			add(plat1);
			add(plat2);
			
			
		}
		
		public function distanceBetweenPlayers():int {
			return FlxU.getDistance(player1.getMidpoint(), player2.getMidpoint());
		}
		
		override public function update():void {
			{ //player1 controls
				player1.acceleration.x = 0;
				
				//movement
				if (FlxG.keys.A)
					player1.acceleration.x = -player1.maxVelocity.x * 8;
				else if (FlxG.keys.D) {
					player1.acceleration.x = player1.maxVelocity.x * 8;
					//player1.velocity.y = -10;
				}
				
				//jumping
				if (FlxG.keys.W && player1.isTouching(FlxObject.FLOOR))
					player1.velocity.y = -player1.maxVelocity.y / 2;
				
				//pushing
				if (FlxG.keys.S && distanceBetweenPlayers() < 15) {
					//figure out which direction to push
					var dir:int = 1;
					if (player1.x > player2.x)
						dir = -1; //push to left
					player2.velocity.y = -10;
					player2.velocity.x = 500 * dir;
				}
			}
			
			
			{ //player2 controls
				player2.acceleration.x = 0;
				
				//movement
				if (FlxG.keys.LEFT)
					player2.acceleration.x = -player2.maxVelocity.x * 8;
				else if (FlxG.keys.RIGHT)
					player2.acceleration.x = player2.maxVelocity.x * 8;
				
				//jumping
				if (FlxG.keys.UP && player2.isTouching(FlxObject.FLOOR))
					player2.velocity.y = -player2.maxVelocity.y / 2;
					
				//pushing
				if (FlxG.keys.DOWN && distanceBetweenPlayers() < 15) {
					//figure out which direction to push
					var dir:int = 1;
					if (player2.x > player1.x)
						dir = -1; //push to left
					player1.velocity.y = -10;
					player1.velocity.x = 500 * dir;
				}
				
				if (carryingBox) {
					goal.x = player2.x + 3;
					goal.y = player2.y - 5;
				}
			}
			
			//change player1 colour when clicked with mouse
			if (FlxG.mouse.justPressed()) {
				var currentCursorLocation:FlxPoint;
				currentCursorLocation = new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY);
				if (player1.overlapsPoint(currentCursorLocation)) {
					var colour:uint = 0xff000000;
					colour += FlxG.random() * 16777215;
					player1.makeGraphic(10, 12, colour);
				}
			}
			
			if (FlxG.collide(player1, goal))
				pickUpBox1();
			else if (FlxG.overlap(player2, goal)) {
				goal.x = player2.x + 3;
				goal.y = player2.y - 5;
				//player2.kill();
				/*goal.kill();
				goal = new FlxSprite(FlxG.width * 1 / 2, 167);
				goal.makeGraphic(4, 5, 0xffffd700);
				goal.acceleration.y = 250;
				goal.acceleration.x = 200;*/
				/*player2 = new FlxSprite(FlxG.width * 1 / 2 - 2, 175);
				player2.makeGraphic(10, 12, 0xffaa1111);
				player2.maxVelocity.x = 40;
				player2.maxVelocity.y = 200;
				player2.acceleration.y = 200;
				player2.drag.x = player2.maxVelocity.x * 4;*/
				/*add(player2);
				add(goal);*/
				carryingBox = true;
				FlxG.collide(goal, player2);
				
				/*FlxG.collide(level, player2);
				FlxG.collide(level, player2);*/
				
			}
				//pickUpBox2();
				
			super.update();
			
			//check for dead players
			if (player1.y > 255 || player2.y > 255)
				restartPlayerPositions();
			
			//collision detection
			//level
			FlxG.collide(level, player1);
			FlxG.collide(level, player2);
			FlxG.collide(level, goal);
			
			//elevator
			FlxG.collide(elevator, player1);
			FlxG.collide(elevator, player2)
			FlxG.collide(elevator, goal);
			
			//platforms
			FlxG.collide(plat1, player1);
			FlxG.collide(plat1, player2);
			FlxG.collide(plat2, player1);
			FlxG.collide(plat2, player2);
			
			//players
			FlxG.collide(player1, player2);
		}
		
		public function pickUpBox2():void {
			player2 = new FlxSprite();
			player2.makeGraphic(10, 12, 0xff1111aa);
			player2.maxVelocity.x = 40;
			player2.maxVelocity.y = 200;
			player2.acceleration.y = 200;
			player2.drag.x = player2.maxVelocity.x * 4;
			//player2.drag.y = player2.maxVelocity.y * 8;
			add(player2);
		}
		
		public function pickUpBox1():void {
			
		}
		
		public function throwBox():void {
			
		}
		
		//sends players to their spawn locations
		public function restartPlayerPositions():void {
			player1.velocity.y = 0; //reset fall speed
			player1.x = FlxG.width * 1 / 10;
			player1.y = 175;
			
			player2.velocity.y = 0;
			player2.x = FlxG.width * 9 / 10;
			player2.y = 175;
			
			goal.x = FlxG.width * 1 / 2 - 2;
			goal.y = 179;
			//box.x = FlxG.width * 1 / 2 - 2;
			//box.y = 10;
			
		}
	}

}