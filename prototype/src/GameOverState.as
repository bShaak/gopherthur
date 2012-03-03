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
	
	public class  GameOverState extends FlxState
	{
		private var backgroundColor:FlxSprite;
		private var title:FlxText;
		private var playButton:FlxButton;
		private var gameMode:int;
		private var connect:Connection;
		private var pID:int;
		private var pCount:int;
		private var levelSelected:Object;
 
		public function GameOverState(data:Object, mode:int, connection:Connection, playerId:int, playerCount:int)
		{
			gameMode = mode;
			connect = connection;
			pID = playerId;
			pCount = playerCount;
			levelSelected = data;
			
		}
		
		override public function create():void 
		{
			backgroundColor = new FlxSprite(0, 0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0); //should be the same colour as the original menu
			add(backgroundColor);
			
			title = new FlxText(0, 16, FlxG.width, "SpringBox");
			title.setFormat (null, 16, 0xFFFFFFFF, "center");
			add(title);
			
			playButton = new FlxButton(FlxG.width/2 - 40, FlxG.height - 80, "PLAY AGAIN", playAgain);
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
		
		public function playAgain():void
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
					FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.BOX_COLLECT, connect, pID, pCount));
				}
				// Timed
				else if (gameMode == 1) {
					FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.TIMED, connect, pID, pCount));
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