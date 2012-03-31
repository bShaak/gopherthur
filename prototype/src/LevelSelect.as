package 
{
	
	/**
	 * ...
	 * @author Braden
	 */
	import PlayState;
	import org.flixel.*;
	import playerio.*;
	import flash.system.fscommand;
	import GameLobbyState;
	//import ImgButton;
	
	public class LevelSelect extends FlxState {
		private var backgroundColor:FlxSprite;
		private var title:FlxText;
		private var playButton:FlxButton;
		import flash.events.MouseEvent;
		private var gameMode:int;
		private var connect:Connection;
		private var pID:int;
		private var pCount:int;
		public var levelSelected:Object;
		public var images:FlxGroup;
		private var max_images:int = 3;
		private var roomName:String; //ras
		private var client:Client;  //ras
		
		[Embed (source = "sprites/basic.png")] protected var basic:Class;
		[Embed (source = "sprites/skyscraper.png")] protected var skyscraper:Class;
		[Embed (source = "sprites/skyscraper_highlight.png")] protected var skyHighlight:Class;
		[Embed (source = "sprites/basic_highlight.png")] protected var basicHighlight:Class;
		[Embed (source = "sprites/Volcano.png")] protected var volcano:Class;
		[Embed (source = "sprites/Volcano_highlight.png")] protected var volcanoHighlight:Class;
		[Embed (source = "sprites/laser.png")] protected var laser:Class;
		[Embed (source = "sprites/laser_highlight.png")] protected var laserHighlight:Class;
		//private var img:ImgButton;
 
		public function LevelSelect(mode:int, rmName:String, playerId:int, playerCount:int, cl:Client = null) // connection:Connection
		{
			gameMode = mode;
			//connect = connection;
			pID = playerId;
			pCount = playerCount;
			levelSelected = null; //set to basic map
			roomName = rmName;
			client = cl;
		}
		
		override public function create():void 
		{
			backgroundColor = new FlxSprite(0, 0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0); //should be the same colour as the original menu
			add(backgroundColor);
			images = new FlxGroup();
			
			title = new FlxText(0, 16, FlxG.width, "LEVEL SELECT");
			title.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(title);
			
			playButton = new FlxButton(FlxG.width / 2 - 320, FlxG.height - 420, "", chooseBasic);
			playButton.loadGraphic(basic);
			add(playButton);
			images.add(playButton);
			/*var mainBox:FlxSprite = new FlxSprite(FlxG.width/2 - 100, 70, MainBox);
			mainBox.loadGraphic(MainBox, false, false, 100, 120);
			mainBox.addEventListener(MouseEvent.MOUSE_DOWN, chooseBasic);
			add(mainBox);*/
			
			playButton = new FlxButton(FlxG.width / 2 - 103, FlxG.height - 420, "", chooseSkyscraper);
			playButton.loadGraphic(skyscraper);
			add(playButton);
			images.add(playButton);
			/*var mainBox:FlxSprite = new FlxSprite(220, 70, MainBox);
			mainBox.loadGraphic(MainBox, false, false, 100, 120);
			mainBox.addEventListener(MouseEvent.MOUSE_DOWN, chooseSkyscraper);
			add(mainBox);*/
			
			playButton = new FlxButton(FlxG.width / 2 + 115, FlxG.height - 420, "VOLCANO", chooseVolcano);
			playButton.loadGraphic(volcano);
			add(playButton);
			images.add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height - 240, "POWERPLANT", choosePowerplant);
			add(playButton);
			
			
			playButton = new FlxButton(FlxG.width / 2 - 320, FlxG.height - 240, "", chooseLasergrid);
			playButton.loadGraphic(laser);
			add(playButton);
			images.add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height - 160, "SPACE", chooseSpace);
			add(playButton);
			
			//img = new ImgButton(imageClass, 40, 30, "basic");
			// gonna make a new button class to show levels, that is real nice
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 80, "GO", play);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 -40, FlxG.height - 60, "MAIN MENU", gotoMenu);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 -40, FlxG.height - 40, "EXIT", exitGame);
			add(playButton);
			chooseBasic();
			if (GameLobbyState.testVersion)
				play(); //ras
		}

		override public function update():void
		{
			super.update();
		}
		
		public function chooseBasic():void {
			levelSelected = Level.levelData;
			cleanHighlights();
			images.members[0].loadGraphic(basicHighlight);
		}
		
		public function chooseSkyscraper():void {
			levelSelected = Level.skyscraper;
			cleanHighlights();
			images.members[1].loadGraphic(skyHighlight);
		}
		
		public function chooseVolcano():void {
			levelSelected = Level.volcano;
			cleanHighlights();
			images.members[2].loadGraphic(volcanoHighlight);
		}
		
		public function choosePowerplant():void {
			levelSelected = Level.powerplant;
		}
		
		public function chooseLasergrid():void {
			levelSelected = Level.lasergrid;
			cleanHighlights();
			images.members[3].loadGraphic(laserHighlight);
		}
		
		public function chooseSpace():void {
			levelSelected = Level.space;
		}
		
		public function play():void
		{
			if(pID == -1){
				FlxG.switchState(new PlayState(levelSelected, gameMode));
			}
			else {
				// collect
				if (gameMode == 0) {
					//FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.BOX_COLLECT, connect, pID, pCount));
					FlxG.switchState(new ObtainConnectionState(levelSelected, roomName, client));
				}
				// Timed
				else if (gameMode == 1) {
					//FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.TIMED, connect, pID, pCount));
					FlxG.switchState(new ObtainConnectionState(levelSelected, roomName, client));
				}
			}
		}
		
		public function gotoMenu():void {
			FlxG.switchState( new MenuState());
		}
		
		public function exitGame():void {
			fscommand("quit");
		}
		
		public function cleanHighlights():void {
			var index:int = 0;
			for each(var imageButton:FlxButton in images.members) {
				switch(index) {
					case 0:
						imageButton.loadGraphic(basic);
						break;
					case 1:
						imageButton.loadGraphic(skyscraper);
						break;
					case 2:
						imageButton.loadGraphic(volcano);
						break;
					case 3:
						imageButton.loadGraphic(laser);
						break;
					default:
						trace("error selecting level");
				}
				index++;
			}
		}
	}
}