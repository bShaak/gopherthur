package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Jen
	 */
	public class Level
	{
		[Embed(source = "levels/mapCSV_Basic_Map1.csv", mimeType = "application/octet-stream")] public var BasicMap:Class;
		//[Embed(source = "levels/mapCSV_TestMap_Map1.csv", mimeType = "application/octet-stream")] public var RayTestMap:Class;
		[Embed(source = "levels/Basic.png")] public var BasicTiles:Class;
		
		public var masterLevel:FlxGroup;
	
		public function Level(levelType:String) {
			masterLevel = new FlxGroup();
			
			switch (levelType) {
				case ("basic"):					
					var layerMap1:FlxTilemap = new FlxTilemap();
					//var layerMap2:FlxTilemap = new FlxTilemap();
					layerMap1.loadMap(new BasicMap, BasicTiles, 16, 16, FlxTilemap.OFF, 0, 1, 1);
					//layerMap2.loadMap(new CSV_Map2, Img_Map2, 16, 16, FlxTilemap.OFF, 0, 1, 1);
					masterLevel.add(layerMap1);
					//masterLevel.add(layerMap2);
					break;
				/*	
				case ("ray_test_map"):
					var tileMap:FlxTilemap = new FlxTilemap();
					tileMap.loadMap(new RayTestMap, BasicTiles, 16, 16, FlxTilemap.OFF, 0, 1, 1);
					masterLevel.add(tileMap);
					break;
				*/

			}
		}

		public function initialize():void {
			FlxG.state.add(masterLevel);
		}
	}

}