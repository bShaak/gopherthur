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
	//import ImgButton;
	
	public class LevelSelect extends FlxState {
		private var backgroundColor:FlxSprite;
		private var title:FlxText;
		private var playButton:FlxButton;
		private var gameMode:int;
		private var connect:Connection;
		private var pID:int;
		private var pCount:int;
		public var levelSelected:Object;
		//[Embed(source = "sprites/hop_right_16x24_red.png")] public var imageClass:Class;
		//private var img:ImgButton;
 
		public function LevelSelect(mode:int, connection:Connection, playerId:int, playerCount:int)
		{
			gameMode = mode;
			connect = connection;
			pID = playerId;
			pCount = playerCount;
			levelSelected = null;
			
		}
		
		override public function create():void 
		{
			backgroundColor = new FlxSprite(0, 0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0); //should be the same colour as the original menu
			add(backgroundColor);
			
			title = new FlxText(0, 16, FlxG.width, "LEVEL SELECT");
			title.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(title);
			
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 420, "BASIC MAP", chooseBasic);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 400, "FAKE MAP", chooseFake);
			add(playButton);
			
			//img = new ImgButton(imageClass, 40, 30, "basic");
			// gonna make a new button class to show levels, that is real nice
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 80, "GO", play);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 -40, FlxG.height - 60, "MAIN MENU", gotoMenu);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 -40, FlxG.height - 40, "EXIT", exitGame);
			add(playButton);
		}

		override public function update():void
		{
			super.update();
		}
		
		public function chooseBasic():void {
			levelSelected = Level.levelData;
		}
		
		public function chooseFake():void {
			levelSelected = null;
		}
		
		public function play():void
		{
			if(pID == -1){
				// collect
				if (gameMode == 0) {
					FlxG.switchState(new PlayState(levelSelected, PlayState.BOX_COLLECT));
				}
				// Timed
				else if (gameMode == 1) {
					FlxG.switchState( new PlayState(levelSelected, PlayState.TIMED));
				}
			}
			else {
				// collect
				if (gameMode == 0) {
					//FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.BOX_COLLECT, connect, pID, pCount));
					FlxG.switchState(new ObtainConnectionState(levelSelected));
				}
				// Timed
				else if (gameMode == 1) {
					//FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.TIMED, connect, pID, pCount));
					FlxG.switchState(new ObtainConnectionState(levelSelected));
				}
			}
		}
		
		public function gotoMenu():void {
			FlxG.switchState( new MenuState());
		}
		
		public function exitGame():void {
			fscommand("quit");
		}
	}
}