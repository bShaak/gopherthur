package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Jen
	 */
	public class Level
	{		
		public function Level() { }
			//boxes.add(new Box(20, 300, 0));
			//boxes.add(new Box(35, 300, 1));
			/*boxes.add(new Box(FlxG.width * 1 / 2 - 25, 40, 0));
			boxes.add(new Box(FlxG.width * 1 / 2 - 15, 10, 1)); 
			boxes.add(new Box(FlxG.width * 1 / 2 - 5, 40, 2));
			boxes.add(new Box(FlxG.width * 1 / 2 + 5, 10, 3));
			boxes.add(new Box(FlxG.width * 1 / 2 + 15, 40, 4));
			
			*/
//Platform(start:FlxPoint, end:FlxPoint, circuitTime:Number, initialPosition:Number, plat_width:Number, plat_height:Number, clock:Clock)		
		/*var plat_y:int = 225; //height of these platforms... god this code is ugly
			
			/*var plat1:Platform;
			plat1 = new Platform(new FlxPoint(100, plat_y), // start
								new FlxPoint(FlxG.width / 2 - 120, plat_y), // end
								2500, // circuitTime
								0, // offset
								80, //width
								16, // height
								clock);
			plat1.maxVelocity.x = 60;

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
			*/
			/*elevator = new Platform(new FlxPoint(FlxG.width / 2, FlxG.height - 160), // start
									new FlxPoint(FlxG.width / 2, 250), // end
									2500, // circuitTime
									0, // initialPosition
									80, // width
									16, // height
									clock); //TODO: ugh, not so many heuristic numbers floating around here
									
			elevator.maxVelocity.x = 120;
			elevator.maxVelocity.y = 100;*/
			public static var levelData:Object = { startInfo: [ { x: FlxG.width / 10, y: 370, color:0xff11aa11 }, //player 1
												     { x: FlxG.width * 9 / 10, y: 370, color:0xffaa1111 } ], //player 2
										
										maps: [ { map_type: 0} ],			 
													 
										boxes: [ { x:FlxG.width * 1 / 2 - 25, y:40 }, //initial box positions
												 { x:FlxG.width * 1 / 2 - 15, y: 10 },
												 { x:FlxG.width * 1 / 2 - 5, y:40 },
												 { x:FlxG.width * 1 / 2 + 5, y:10 },
												 { x:FlxG.width * 1 / 2 + 15, y:40 } ],
			
										platforms: [ { start_x: FlxG.width / 2, //elevator
													   start_y: FlxG.height - 160,
													   end_x: FlxG.width / 2,
													   end_y: 250,
													   circuitTime: 2500,
													   offset: 0,
													   width: 80,
													   height: 16,
													   maxVelocity_x: 120,
													   maxVelocity_y: 100},
													 { start_x: 100, //platform 1
													   start_y: 225,
													   end_x: FlxG.width / 2 - 120,
													   end_y: 225,
													   circuitTime: 2500,
													   offset: 0,
													   width: 80,
													   height: 16,
													   maxVelocity_x: 60,
													   maxVelocity_y: 0 },
													 { start_x: FlxG.width / 2 + 120, //platform 2
													   start_y: 225,
													   end_x: FlxG.width - 100,
													   end_y: 225,
													   circuitTime: 2500,
													   offset: 1,
													   width: 80,
													   height: 16,
													   maxVelocity_x: 60,
													   maxVelocity_y: 0 } ],
										/*powerUps.add(new SpeedBoost(40, 340, 1, clock));
										powerUps.add(new SpeedBoost(FlxG.width - 50, 340, 2, clock));*/
										 powerUps:  {
													speedBoosts: [ { x: 40, y: 340 },
																   { x: FlxG.width - 50, y: 340 } ] 
										 }
		}
	}

}