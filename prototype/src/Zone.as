package  
{
	/**
	 * For now this will just identify the areas that the player has to
	 * bring their blocks to in order to win.
	 * 
	 * 
	 * @author rayk
	 */
	
	import org.flixel.*;
	 
	public class Zone extends FlxSprite
	{
		public var player:Player;
		public function Zone(x:int, y:int, width:int, height:int, player:Player) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.player = player;
			this.makeGraphic(width, height, 0xff11aa11);
		}
		
	}

}