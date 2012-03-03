package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Jen
	 */
	public class Level
	{		
		[Embed(source = "sprites/hop_right_16x24_red.png")] protected static const AnimateWalkRed:Class;
		[Embed(source = "sprites/hop_right_16x24_blue.png")] protected static const AnimateWalkBlue:Class;
		[Embed(source = "levels/mapCSV_Basic_Map1.csv", mimeType = "application/octet-stream")] public static var BasicMap:Class;
		[Embed(source = "levels/Basic.png")] public static var BasicTiles:Class;
		
		public function Level() { }
		
		public static var levelData:Object = { startInfo: [ { x: FlxG.width / 10, y: 370, color:0xff11aa11, walkAnimation: AnimateWalkRed }, //player 1
															{ x: FlxG.width * 9 / 10, y: 370, color:0xffaa1111, walkAnimation: AnimateWalkBlue } ], //player 2
									
									maps: [ { layout: BasicMap, tilemap: BasicTiles  } ],			 
												 
									bg_color: 0xff66cdaa,
									
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
												   
									 powerUps:  {
												speedBoosts: [ { x: 40, y: 340 },
															   { x: FlxG.width - 50, y: 340 } ] 
									 }
		}
	}

}