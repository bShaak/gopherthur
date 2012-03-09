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
		
		private static const TW:int = 16; //Tile widths. Basically when you set up anything in the level, you want to align it to the grid, which is 
										  //composed of 16x16 tiles, so just do your desired tile number multiplied by TW to specify the location, to
										  //make it easier to read and update. e.g. something with width=2*TW is two tiles wide.
		
		public function Level() { }
		
		public static var levelData:Object = { startInfo: [ { x: FlxG.width / 10, y: 370, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
															{ x: FlxG.width * 9 / 10, y: 370, color:0xffaa1111, walkAnimation: AnimateWalkRed } ], //player 2
									
									maps: [ { layout: BasicMap, texture: BasicTiles  } ],	//layout: csv file 
																							//texture: image file containing the tile textures
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
												   maxVelocity_y: 100,
												   oneWay: true},
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
									startInfo: [ { x: 6*TW, y: 24*TW, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
											     { x: 34*TW, y: 24*TW, color:0xffaa1111, walkAnimation: AnimateWalkRed } ], //player 2
									
									maps: [ { layout: SkyscraperTileMap, texture: SkyscraperTextures } ],			 
											 
									bg_color: 0xff8AA37B,
									
									boxes: [ { x: 5*TW, y: 3*TW }, //initial box positions
											 { x: 13*TW, y: 3*TW },
											 { x: 20*TW, y: 3*TW },
											 { x: 26*TW, y: 3*TW },
											 { x: 34*TW, y: 3*TW },],
											 
									platforms: [ { start_x: 2*TW, //lower left sweeper
												   start_y: 15*TW,
												   end_x: 16*TW,
												   end_y: 15*TW,
												   circuitTime: 2500,
												   offset: 0,
												   width: 2*TW,
												   height: 6*TW,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0 },
												 { start_x: 38*TW, //lower right sweeper
												   start_y: 15*TW,
												   end_x: 24*TW,
												   end_y: 15*TW,
												   circuitTime: 2500,
												   offset: 0,
												   width: 2*TW,
												   height: 6*TW,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0},
												{  start_x: 0, //upper sweeper
												   start_y: 7*TW,
												   end_x: FlxG.width,
												   end_y: 7*TW,
												   circuitTime: 3000,
												   offset: 0,
												   width: 2*TW,
												   height: 2*TW,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0 } ],   
												 
									 powerUps:  {}
		}
	}

}