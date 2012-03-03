package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Jen
	 */
	public class Level
	{		
		[Embed(source = "sprites/hop_right_16x24_green.png")] protected static const AnimateWalkGreen:Class;
		[Embed(source = "sprites/hop_right_16x24_red.png")] protected static const AnimateWalkRed:Class;
		
		[Embed(source = "levels/mapCSV_Basic_Map1.csv", mimeType = "application/octet-stream")] public static var BasicMap:Class;
		[Embed(source = "levels/Basic.png")] public static var BasicTiles:Class;
		
		[Embed(source = "levels/mapCSV_Skyscraper_Map1.csv", mimeType = "application/octet-stream")] public static var SkyscraperTileMap:Class;
		[Embed(source = "levels/skyscraper_textures.png")] public static var SkyscraperTextures:Class;
		
		public function Level() { }
		
		public static var levelData:Object = { startInfo: [ { x: FlxG.width / 10, y: 370, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
															{ x: FlxG.width * 9 / 10, y: 370, color:0xffaa1111, walkAnimation: AnimateWalkRed } ], //player 2
									
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
		public static var skyscraper:Object = { 
									startInfo: [ { x: 6*16, y: 24*16, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
											     { x: 34*16, y: 24*16, color:0xffaa1111, walkAnimation: AnimateWalkRed } ], //player 2
									
									maps: [ { layout: SkyscraperTileMap, tilemap: SkyscraperTextures } ],			 
											 
									bg_color: 0xff8AA37B,
									
									boxes: [ { x: 7*16, y: 3*16 }, //initial box positions
											 { x: 13*16, y: 3*16 },
											 { x: 20*16, y: 3*16 },
											 { x: 26*16, y: 3*16 },
											 { x: 32*16, y: 3*16 },],
											 
									platforms: [ { start_x: 2*16, //lower left sweeper
												   start_y: 15*16,
												   end_x: 16*16,
												   end_y: 15*16,
												   circuitTime: 2500,
												   offset: 0,
												   width: 32,
												   height: 6*16,
												   maxVelocity_x: 120,
												   maxVelocity_y: 100 },
												 { start_x: 38*16, //lower right sweeper
												   start_y: 15*16,
												   end_x: 24*16,
												   end_y: 15*16,
												   circuitTime: 2500,
												   offset: 0,
												   width: 32,
												   height: 6*16,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0},
												{  start_x: 0, //upper sweeper
												   start_y: 7*16,
												   end_x: FlxG.width,
												   end_y: 7*16,
												   circuitTime: 3000,
												   offset: 0,
												   width: 32,
												   height: 32,
												   maxVelocity_x: 60,
												   maxVelocity_y: 0 } ],   
												 
									 powerUps:  {
												//speedBoosts: [ { x: 40, y: 340 },
															   //{ x: FlxG.width - 50, y: 340 } ] 
									 }
		}
	}

}