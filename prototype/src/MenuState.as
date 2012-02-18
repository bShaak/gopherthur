package
{
	import org.flixel.*;
	import PlayState;
 
	public class MenuState extends FlxState
	{
		private var backgroundColor:FlxSprite;
		private var title:FlxText;
		private var playButton:FlxButton;
		
		override public function create():void
		{
			backgroundColor = new FlxSprite(0,0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0);
			add(backgroundColor);
			
			title = new FlxText(0, 16, FlxG.width, "SpringBox");
			title.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(title);
			
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 80, "PLAY", goToPlayState);
			add(playButton);
			
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 60, "MULTIPLAYER", goToConnectionState);
			add(playButton);
 
			var instructions:FlxText = instructions = new FlxText(0, FlxG.height - 32, FlxG.width, "or Press Space To Play");
			instructions.setFormat (null, 8, 0xFFFFFFFF, "center");
			add(instructions);
 
		} 
 
		override public function update():void
		{
			super.update(); 
 
			if (FlxG.keys.justPressed("SPACE"))
			{
				goToPlayState();
			}
 
		}
		
		public function goToPlayState():void
		{
			FlxG.switchState(new PlayState(PlayState.BOX_COLLECT));
		} 
		
		public function goToConnectionState():void
		{
			FlxG.switchState(new ObtainConnectionState());
		} 
 
	}
}