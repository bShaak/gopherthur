package
{
	import org.flixel.*;
	import PlayState;
	import GameLobbyState;
	
	public class MenuState extends FlxState
	{
		private var backgroundColor:FlxSprite;
		private var title:FlxText;
		private var playButton:FlxButton;
		private var mode:FlxText;
		private var buttonLabel:FlxText;
		
		[Embed (source="sprites/springbox_main.png")] protected var MainBox:Class;
		[Embed (source="sprites/springbox_mainBG.png")] protected var MainBoxBG:Class;

		override public function create():void
		{
			//goToConnectionState();
			if (GameLobbyState.testVersion)
				goToConnectionState(); //ras
			//goToBoxCollectPlayState();
			backgroundColor = new FlxSprite(0,0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0);
			add(backgroundColor);
			
			var mainBoxBG:FlxSprite = new FlxSprite(0, 0, MainBoxBG);
			mainBoxBG.loadGraphic(MainBoxBG, false, false, 640, 480);
			add(mainBoxBG);
			
			var mainBox:FlxSprite = new FlxSprite(100, 35, MainBox);
			mainBox.loadGraphic(MainBox, false, false, 450, 300);
			add(mainBox);
			
			title = new FlxText(0, 20, FlxG.width, "SpringBox");
			title.setFormat (null, 25, 0xFFFFFFFF, "center");
			add(title);
			
			mode = new FlxText(0, FlxG.height - 170, FlxG.width, "PICK A MODE:");
			mode.setFormat (null, 14, 0xFFFFFFFF, "center");
			add(mode);
			
			playButton = new FlxButtonBig(FlxG.width / 2 - 150, FlxG.height - 140, "CLASSIC", goToBoxCollectPlayState); //null
			playButton.label.setFormat(null, 16, 0x111111, "center");
			add(playButton);
			
			playButton = new FlxButtonBig(FlxG.width / 2 + 10, FlxG.height - 140, "KEEP AWAY", goToRabbitPlayState); 
			playButton.label.setFormat(null, 16, 0x111111, "center");
			add(playButton);
			
			playButton = new FlxButtonBig(FlxG.width / 2 - 150, FlxG.height - 100, "TIMED", goToTimedPlayState); 
			playButton.label.setFormat(null, 16, 0x111111, "center");
			add(playButton);
			
			playButton = new FlxButtonBig(FlxG.width / 2 + 10, FlxG.height - 100, "ONLINE", goToConnectionState);
			playButton.label.setFormat(null, 16, 0x111111, "center");
			add(playButton);
			
			playButton = new FlxButtonBig(FlxG.width / 2 - 75, FlxG.height - 50, "TUTORIAL", goToTutorial);
			playButton.label.setFormat(null, 16, 0x111111, "center");
			add(playButton);
		} 
 
		override public function update():void
		{
			super.update(); 
 
			if (FlxG.keys.justPressed("SPACE"))
			{
				//goToPlayState();
			}
 
		}
		
		public function goToTimedPlayState():void
		{
			//FlxG.switchState(new PlayState(PlayState.TIMED));
			FlxG.switchState( new LevelSelect(PlayState.TIMED, null, -1, -1));

		} 
		
		public function goToBoxCollectPlayState():void
		{
			//FlxG.switchState(new PlayState(PlayState.BOX_COLLECT));
			FlxG.switchState( new LevelSelect(PlayState.BOX_COLLECT, null, -1, -1));
			//FlxG.switchState(new PlayState(Level.levelData, PlayState.BOX_COLLECT));
			//FlxG.switchState(new PlayState(Level.skyscraper, PlayState.BOX_COLLECT));
		} 
		
		public function goToRabbitPlayState():void
		{
			FlxG.switchState( new LevelSelect(PlayState.RABBIT, null, -1, -1));
		}
		
		public function goToConnectionState():void
		{
			//FlxG.switchState( new LevelSelect(PlayState.BOX_COLLECT, null, 1, 1));
			FlxG.switchState( new GameLobbyState());//LevelSelect(PlayState.BOX_COLLECT, null, 1, 1));
		} 
		
		public function goToTutorial():void {
			FlxG.switchState( new Tutorial() );
		}
 
	}
}