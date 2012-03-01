package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Jen
	 */
	public class Level
	{
		[Embed(source = "levels/mapCSV_Basic_Map.csv", mimeType = "application/octet-stream")] public var CSV_Map:Class;
		[Embed(source = "levels/Basic.png")] public var Img_Map:Class;
		
		public var masterLevel:FlxGroup;
	
		public function Level(levelType:String) {
			masterLevel = new FlxGroup();
			
			switch (levelType) {
				case ("basic"):
					var layerMap1:FlxTilemap = new FlxTilemap();
					//var layerMap2:FlxTilemap = new FlxTilemap();
					layerMap1.loadMap(new CSV_Map, Img_Map, 16, 16, FlxTilemap.OFF, 0, 1, 1);
					//layerMap2.loadMap(new CSV_Map2, Img_Map2, 16, 16, FlxTilemap.OFF, 0, 1, 1);
					masterLevel.add(layerMap1);
					//masterLevel.add(layerMap2);
					break;
			}
		}

		public function initialize():void {
			FlxG.state.add(masterLevel);
		}
	}

}