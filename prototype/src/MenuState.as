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
		
		override public function create():void
		{
			backgroundColor = new FlxSprite(0,0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0);
			add(backgroundColor);
			
			title = new FlxText(0, 30, FlxG.width, "SpringBox");
			title.setFormat (null, 25, 0xFFFFFFFF, "center");
			add(title);
			
			mode = new FlxText(0, FlxG.height - 105, FlxG.width, "PICK A MODE:");
			mode.setFormat (null, 14, 0xFFFFFFFF, "center");
			add(mode);
			
			playButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height - 80, "PLAY", goToBoxCollectPlayState);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height - 60, "TIMED", goToTimedPlayState);
			add(playButton);

			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 40, "MULTIPLAYER", goToConnectionState);
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
			FlxG.switchState(new PlayState(Level.levelData, PlayState.TIMED));
		} 
		
		public function goToBoxCollectPlayState():void
		{
			FlxG.switchState(new PlayState(Level.levelData, PlayState.BOX_COLLECT));
		}  
		
		public function goToConnectionState():void
		{
			FlxG.switchState(new ObtainConnectionState());
		} 
 
	}
}