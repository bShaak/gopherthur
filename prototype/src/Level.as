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
		[Embed(source = "sprites/hop_right_16x24_blue.png")] protected static const AnimateWalkBlue:Class;
		
		[Embed(source = "levels/mapCSV_Basic_Map1.csv", mimeType = "application/octet-stream")] public static var BasicMap:Class;
		[Embed(source = "levels/Basic.png")] public static var BasicTiles:Class;
		[Embed(source = "levels/backgrounds/forest_bg.png")] public static var ForestBG:Class;
		
		[Embed(source = "levels/mapCSV_Skyscraper_Map1.csv", mimeType = "application/octet-stream")] public static var SkyscraperTileMap:Class;
		[Embed(source = "levels/skyscraper_textures.png")] public static var SkyscraperTextures:Class;
		[Embed(source = "levels/backgrounds/skyscraper_bg.png")] public static var SkyscraperBG:Class;
		
		[Embed(source = "levels/mapCSV_Volcano_Map1.csv", mimeType = "application/octet-stream")] public static var VolcanoTileMap:Class;
		[Embed(source = "levels/backgrounds/volcano_bg.png")] public static var VolcanoBG:Class;
		
		private static const TW:int = 16; //Tile widths. Basically when you set up anything in the level, you want to align it to the grid, which is 
										  //composed of 16x16 tiles, so just do your desired tile number multiplied by TW to specify the location, to
										  //make it easier to read and update. e.g. something with width=2*TW is two tiles wide.
		
		/*
		 * startInfo: contains information about initial sprite positions
		 * 		- x: x-coordinate of start position of player
		 * 		- y: y-coordinate of start position of player
		 * 		- color: color of player
		 * 		- walkAnimation: animation of player
		 * 
		 * maps: the layout of the level as well as the tile textures that go with each map 
		 * 		- layout: a csv file containing a tilemap of the level
		 * 		- texture: tile texture that goes with the layout
		 * 
		 * bg_color: background color of the level
		 * 
		 * rabbit_box: position of the box for rabbit mode
		 * 		- x: x-coord of start position
		 * 		- y: y-coord of start position
		 * 
		 * boxes: start positions of the boxes in the level
		 *  	- x: x-coordinate of the start position
		 * 		- y: y-coordinate of the start position
		 * 	
		 * platforms: moving platform information
		 *		- start_x: x-coord of the start position
		 * 		- start_y: y-coord of the start position
		 * 		- end_x: x-coord of the end point of the platform
		 * 		- end_y: y-coord of the end point of the platform
		 * 		- circuitTime: time in milliseconds for a complete circuit of the path (back and forth)
		 * 		- offset: number between -1 and 1, representing where in the path the platform should start
		 * 		- width: width of the platform in pixels
		 * 		- height of playtform in pixels
		 * 		- oneWay: true or defaults to false if value not present. If true, platform is a one-way platform
		 *		
		 * circlePlatforms: circular moving platform information
		 * 		-x: The x-coord of centre of the circle
		 * 		-y: The y-coord of centre of the circle.
		 * 		-radius: The radius of the circle.
		 * 		-rotateTime: The time for one rotation.
		 * 		-reverse: True if the platform should rotate in the reverse direction.
		 * 		-initialRotation: The position in the circle originially (between 0 and 2pi)
		 * 		-width: The width of the platform.
		 * 		-height: The height of the platform.
		 * 		-oneWay: See platforms.
		 *
		 * superPlatform: spining and moving platform information
		 * 		-startMiddleX: The initial x position of the centre of rotation.
		 * 		-startMiddleY: The initial y position of the centre of rotation.
		 *		-endMiddleX: The final x position of the centre of rotation.
		 * 		-endMiddleY: The final y position of the centre of rotation.
		 *		-radius: The radius of rotation.
		 *		-circuitTime: The time taken for the middle to make a circuit.
		 *		-rotateTime: The time taken for a rotation.
		 *		-initialPosition: A number between -1 and 1 representing the position of the centre in the circuit.
		 *		-initialRotation: A number between 0 and 2pi representing the initial rotation.
		 *		-reverse: True if the rotation should be reversed.
		 *		-width: The width of the platform.
		 *		-height: The height of the platform.
		 *		-oneWay: See platforms.
		*/		
		
		public static var levelData:Object = { startInfo: [ { x: FlxG.width / 10, y: 370, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
															{ x: FlxG.width * 9 / 10, y: 370, color:0xffaa1111, walkAnimation: AnimateWalkRed } ], //player 2
									
									maps: [ { layout: BasicMap, texture: BasicTiles  } ],	//layout: csv file 
																							//texture: image file containing the tile textures
									bg_color: 0xff66cdaa,
									
									background: ForestBG,
									
									rabbit_box: { x:FlxG.width * 1 / 2 - 5, y:5*TW },
									
									boxes: [ { x:FlxG.width * 1 / 2 - 25, y:40 }, //initial box positions
											 { x:FlxG.width * 1 / 2 - 15, y: 10 },
											 { x:FlxG.width * 1 / 2 - 5, y:40 },
											 { x:FlxG.width * 1 / 2 + 5, y:10 },
											 { x:FlxG.width * 1 / 2 + 15, y:40 } ],
		
									platforms: [ { start_x: 17*TW, //elevator
										   start_y: 20*TW,
										   end_x: 17*TW,
										   end_y: 14*TW,
										   circuitTime: 3000,
										   offset: 0,
										   width: 6*TW,
										   height: 1*TW,
										   oneWay: true},
										 { start_x: 4*TW, //platform 1
										   start_y: 13*TW,
										   end_x: 12*TW,
										   end_y: 13*TW,
										   circuitTime: 3000,
										   offset: 0,
										   width: 4*TW,
										   height: 1*TW},
										 { start_x: 24*TW, //platform 2
										   start_y: 13*TW,
										   end_x: 32*TW,
										   end_y: 13*TW,
										   circuitTime: 3000,
										   offset: 1,
										   width: 4*TW,
										   height: 1 * TW } ],
									circlePlatforms: [],
									superPlatforms: []
		}
		public static var skyscraper:Object = { 
									startInfo: [ { x: 6*TW, y: 24*TW, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
											     { x: 34*TW, y: 24*TW, color:0xffaa1111, walkAnimation: AnimateWalkRed } ], //player 2
									
									maps: [ { layout: SkyscraperTileMap, texture: SkyscraperTextures } ],			 
											 
									bg_color: 0xff8AA37B,
									
									background: SkyscraperBG,
									
									boxes: [ { x: 5*TW,  y: 3*TW }, //initial box positions
											 { x: 13*TW, y: 3*TW },
											 { x: 20*TW, y: 3*TW },
											 { x: 26*TW, y: 3*TW },
											 { x: 34*TW, y: 3*TW },],
											 
									platforms: [ { start_x: 1*TW, //mid left sweeper
												   start_y: 12*TW,
												   end_x: 15*TW,
												   end_y: 12*TW,
												   circuitTime: 2500,
												   offset: 0,
												   width: 2*TW,
												   height: 6*TW,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0 },
												 { start_x: 37*TW, //mid right sweeper
												   start_y: 12*TW,
												   end_x: 23*TW,
												   end_y: 12*TW,
												   circuitTime: 2500,
												   offset: 0,
												   width: 2*TW,
												   height: 6*TW,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0},
												{  start_x: 0, //upper sweeper
												   start_y: 6*TW,
												   end_x: 39*TW,
												   end_y: 6*TW,
												   circuitTime: 3000,
												   offset: 0,
												   width: 2*TW,
												   height: 2*TW,
												   maxVelocity_x: 0,
												   maxVelocity_y: 0 } ],   
									 circlePlatforms: [],	
									 superPlatforms: []
		}
		public static var volcano:Object = { 
			startInfo: [ { x: 5*TW, y: 3*TW, color:0xff11aa11, walkAnimation: AnimateWalkGreen }, //player 1
						 { x: 35*TW, y: 3*TW, color:0xff1111aa, walkAnimation: AnimateWalkBlue } ], //player 2
			
			maps: [ { layout: VolcanoTileMap, texture: SkyscraperTextures } ],			 
					 
			bg_color: 0xffCD8C95,
			
			background: VolcanoBG,
			
			boxes: [ { x: 18*TW, y: 24*TW }, //initial box positions
					 { x: 19*TW, y: 24*TW },
					 { x: 20*TW, y: 24*TW },
					 { x: 21*TW, y: 24*TW },
					 { x: 22*TW, y: 24*TW },],
					 
			platforms: [ { start_x: 9*TW, //left elevator
						   start_y: 10*TW,
						   end_x: 9*TW,
						   end_y: 18*TW,
						   circuitTime: 5000,
						   offset: 0,
						   width: 4*TW,
						   height: 1*TW },
						 { start_x: 27*TW, //right elevator
						   start_y: 10*TW,
						   end_x: 27*TW,
						   end_y: 18*TW,
						   circuitTime: 5000,
						   offset: 0,
						   width: 4*TW,
						   height: 1*TW },
						{  start_x: 17*TW, //bottom one-way plat
						   start_y: 22*TW,
						   end_x: 17*TW,
						   end_y: 22*TW,
						   circuitTime: 1000,
						   offset: 0,
						   width: 6*TW,
						   height: 1*TW,
						   oneWay: true },
						{  start_x: 13*TW, //left mid one-way plat
						   start_y: 18*TW,
						   end_x: 13*TW,
						   end_y: 18*TW,
						   circuitTime: 1000,
						   offset: 0,
						   width: 6*TW,
						   height: 1*TW,
						   oneWay: true },
						{  start_x: 21*TW, //right mid one-way plat
						   start_y: 18*TW,
						   end_x: 21*TW,
						   end_y: 18*TW,
						   circuitTime: 1000,
						   offset: 0,
						   width: 6*TW,
						   height: 1*TW,
						   oneWay: true}],   
			lava: [ { x: 0*TW, 
					  y: 28*TW,
					  start_x: 0*TW,
					  start_y: 10*TW,
					  end_x: 0*TW,
					  end_y: 28*TW,
					  circuitTime: 6000,
					  downTime: 12000,
					  warningTime: 2000,
					  offset: 0 } ],
			circlePlatforms: [],
			superPlatforms: []
		}
	}

}