package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	import playerio.Connection;
	public class PlayState extends FlxState {
		
		public var level:FlxTilemap;
		
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
		
		//embed sounds
		[Embed(source = "../mp3/push_new.mp3")] private var Push:Class;
		[Embed(source = "../mp3/Chingy_right_thurr.mp3")] private var Music:Class;
	
		public function PlayState(goal:int)
		{
			mode = goal;
		}
		
		override public function create():void {
			FlxG.bgColor = 0xff666666;
			
			/**/
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
			/**/
				
			/*simple empty level
			var data:Array = new Array(
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
				1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 );
			*/
				
			clock = createClock();
			
			if (mode == TIMED) {
				timer = createClock();
				roundTime = new FlxText(-10, 10, FlxG.width, "0:00");
				roundTime.setFormat(null, 12, 0xFFFFFFFF, "right");
				add(roundTime);
			}
			
			scoreboard = new FlxText(0, FlxG.height - 20, FlxG.width, "SpringBox");
			scoreboard.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(scoreboard);
			
			level = new FlxTilemap();
			level.loadMap(FlxTilemap.arrayToCSV(data, 40), FlxTilemap.ImgAuto, 0, 0, FlxTilemap.AUTO);
			add(level);
			
			players = new FlxGroup();
			zones = new FlxGroup();
			createPlayers();
			add(players);
			
			//create the goal boxes
			boxes = new FlxGroup();
			boxes.add(new Box(FlxG.width * 1 / 2 - 10, 20, 0));
			boxes.add(new Box(FlxG.width * 1 / 2 -  5, 10, 1)); 
			boxes.add(new Box(FlxG.width * 1 / 2	 , 20, 2));
			boxes.add(new Box(FlxG.width * 1 / 2 +  5, 10, 3));
			boxes.add(new Box(FlxG.width * 1 / 2 + 10, 20, 4));
			boxes.add(new Box(FlxG.width * 1 / 10 - 10, 185, 5));  // ras

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
			elevator = new Platform(FlxG.width / 2, // ix
									FlxG.height - 80, // iy
									FlxG.width / 2, // fx
									125, // fy
									2500, // circuitTime
									0, // initialPosition
									50, // width
									10, // height
									clock); //TODO: ugh, not so many heuristic numbers floating around here
									
			elevator.maxVelocity.x = 60;
			elevator.maxVelocity.y = 50;
			
			platforms.add(elevator);
			
			//we also want some moving platforms
			var plat_y:int = 115; //height of these platforms... god this code is ugly
			
			var plat1:Platform;
			plat1 = new Platform(50, // ix
								plat_y, // iy
								FlxG.width / 2 - 60, // fx
								plat_y, // fy
								2500, // circuitTime
								0, // offset
								50, //width
								10, // height
								clock);;
			plat1.maxVelocity.x = 30;
			platforms.add(plat1);
			
			var plat2:Platform;
			plat2 = new Platform(FlxG.width / 2 + 60, // ix
								plat_y, // iy
								FlxG.width - 50, // fx
								plat_y, // fy
								2500, // circuitTime
								1, // offset
								50, // width
								10, // height
								clock);
			plat2.maxVelocity.x = 30;
			platforms.add(plat2);
			add(platforms);
			
			//FlxG.playMusic(Music);
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
			
			//check for victory condition (currently it's just checking if someone has 3 blocks in their zone)
			checkGoals();
			
			//update scoreboard
			scoreboard.text = "SCORE: " + players.members[0].getScore() + " - " + players.members[1].getScore();
		}
		
		private function checkGoals():Boolean {
			
			var goalsMet:Boolean = false;
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
						trace("Game over!");
						for each (player in players.members) {
							if (player.getSpawn().x == zone.getMidpoint().x && player.getSpawn().y == zone.getMidpoint().y) {
								player.incrementScore();
							}
							player.dropBox();
							player.reset(player.getSpawn().x, player.getSpawn().y);
						}
						
						for each (box in boxes.members)
							box.reset(box.getSpawn().x, box.getSpawn().y);
						}
						goalsMet = true;
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
								zoneWithMostBoxes = zone1;
								maxBoxNum = numBoxes;
							}
							else if (numBoxes == maxBoxNum) {
								tie = true;
							}
						}
						if (!tie) {
							for each (player in players.members)  { //this is ugly... for future: should be a hash of players to zones (each player has a zone)
								if (player.getSpawn().x == zoneWithMostBoxes.getMidpoint().x && player.getSpawn().y == zoneWithMostBoxes.getMidpoint().y) {
										player.incrementScore();
								}
								player.dropBox();
								player.reset(player.getSpawn().x, player.getSpawn().y);
							}
							for each (box in boxes.members)
								box.reset(box.getSpawn().x, box.getSpawn().y);
						}
						timer.elapsed = 0;
						trace ("Game Over!");
						goalsMet = true;
					}
					break;	
					
				default:
					trace ("Invalid game mode was inputted");
			}
			return goalsMet;
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
			
			FlxG.collide(level, boxes);
			FlxG.collide(platforms, boxes);
			FlxG.collide(boxes, boxes);
		}
		
		private function respawnPlayers():void 
		{
			for each (var player:Player in players.members) {
				if (player.y > FlxG.height) {
					if (player.hasBox())
						player.dropBox();
						
					player.reset(player.getSpawn().x, player.getSpawn().y);
				}
			}
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
			
			FlxG.collide(level, players);
			FlxG.collide(platforms, players);
		}
		
		/**
		 * Create each of the players and the zones.
		 */
		protected function createPlayers():void 
		{
			//add two players for now
			players.add(new ActivePlayer(FlxG.width * 1 / 10, 185, 1, 0xff11aa11, null, 1));
			players.add(new ActivePlayer(FlxG.width * 9 / 10, 185, 2, 0xffaa1111, null, 2));
			
			//each player has a home zone that they're trying to fill up with blocks,
			//so add a zone centered on the player's spawn location (assumes players spawn in mid air)
			for each (var player:Player in players.members) {
				var zone:Zone = new Zone(player.getSpawn().x - 25, player.getSpawn().y - 25, 50, 50);
				zone.makeGraphic(zone.width, zone.height, player.getColour() - 0xbb000000);
				zones.add(zone);
				add(zone);
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
			var numberOfMinsLeft:int = (TIMELIMIT / 60000) - (timer.elapsed / 60000);
			var numberOfSecondsLeft:int = 60 - (timer.elapsed / 1000) % 60;
			var secondsLeft:String;
			
			numberOfSecondsLeft < 10 ? secondsLeft = "0" + numberOfSecondsLeft.toString() : secondsLeft = numberOfSecondsLeft.toString();			 
			roundTime.text = numberOfMinsLeft + ":" + secondsLeft;
		}
		
		/**
		 * Create all the powerups at the start of the game.
		 */
		protected function createPowerUps():void {
			powerUps.add(new SpeedBoost(30, 170, 1, clock));
			powerUps.add(new SpeedBoost(FlxG.width - 30, 170, 2, clock));
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
		
		protected function getBox(id:int):Box {
			return boxes.members[id];
		}
		
		protected function getPlayer(id:int):Player {
			for each (var player:Player in players.members) {
				if (player.id == id) {
					return player;
				}
			}
			return null;
		}
	}

}