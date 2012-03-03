package
{
	import org.flixel.*;
	import PlayState;
 
	public class MenuState extends FlxState
	{
		private var backgroundColor:FlxSprite;
		private var title:FlxText;
		private var playButton:FlxButton;
		private var mode:FlxText;
		private var buttonLabel:FlxText;
		
		[Embed (source="sprites/mainBox.png")] protected var MainBox:Class;
		
		override public function create():void
		{
			backgroundColor = new FlxSprite(0,0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0);
			add(backgroundColor);
			
			
			
			var mainBox:FlxSprite = new FlxSprite(220, 70, MainBox);
			mainBox.loadGraphic(MainBox, false, false, 215, 238);
			add(mainBox);
			
			title = new FlxText(0, 20, FlxG.width, "SpringBox");
			title.setFormat (null, 25, 0xFFFFFFFF, "center");
			add(title);
			
			mode = new FlxText(0, FlxG.height - 165, FlxG.width, "PICK A MODE:");
			mode.setFormat (null, 14, 0xFFFFFFFF, "center");
			add(mode);
			
			playButton = new FlxButtonBig(FlxG.width / 2 - 80, FlxG.height - 140, null, goToBoxCollectPlayState); 
			add(playButton);
			buttonLabel = new FlxText(FlxG.width / 2 - 50, FlxG.height - 132, 100, "PLAY");
			buttonLabel.setFormat(null, 16, 0x333333, "center");
			add(buttonLabel);
			
			playButton = new FlxButtonBig(FlxG.width / 2 - 80, FlxG.height - 100, null, goToTimedPlayState); 
			add(playButton);
			buttonLabel = new FlxText(FlxG.width / 2 - 52, FlxG.height - 92, 100, "TIMED");
			buttonLabel.setFormat(null, 16, 0x333333, "center");
			add(buttonLabel);

			playButton = new FlxButtonBig(FlxG.width/2 - 80, FlxG.height - 60, null, goToConnectionState);
			add(playButton);
			buttonLabel = new FlxText(FlxG.width / 2 - 80, FlxG.height - 52, 160, "MULTIPLAYER");
			buttonLabel.setFormat(null, 16, 0x333333, "center");
			add(buttonLabel); 
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
		
		public function goToConnectionState():void
		{
			FlxG.switchState( new LevelSelect(PlayState.BOX_COLLECT, null, 1, 1));
		} 
 
	}
}