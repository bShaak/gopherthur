package  
{
	import org.flixel.*;
	
	/**
	 * State for when a player has an error with multiplayer.
	 * @author Jeremy Johnson
	 */
	public class MultiplayerErrorState extends FlxState 
	{
		private var mes:String;
		public function MultiplayerErrorState(mes:String) {
			this.mes = mes;
		}
		override public function create():void {
			var mesText:FlxText = new FlxText(0, 16, FlxG.width, mes);
			add(mesText);
			
			var backButton:FlxButton = new FlxButton(20, 40, "Back", goToMenuState);
			add(backButton);
			FlxG.pauseSounds();
		}
		
		public function goToMenuState():void {
			FlxG.switchState(new MenuState());
		}
		
	}

}