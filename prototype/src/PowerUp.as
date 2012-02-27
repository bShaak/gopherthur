package  
{
	import org.flixel.FlxSprite;
	
	/**
	 * A class representing a power up.
	 * @author Jeremy Johnson
	 */
	public class PowerUp extends FlxSprite 
	{
		public var id:int;
		
		public function PowerUp(x:int, y:int, id:int, color:int) 
		{
			super(x, y);
			
			this.width = 8;
			this.height = 8;
			
			this.id = id;
			this.makeGraphic(width, height, color);
		}
		
		public function trigger(player:Player, game:PlayState):void {
			this.visible = false;
		}
	}

}