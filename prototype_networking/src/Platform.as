package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	 
	public class Platform extends FlxSprite
	{
		
		public function Platform(x:Number, y:Number, plat_width:Number, plat_height:Number) {
			super(x, y);
			
			this.immovable = true; //objects on top won't weigh it down
			
			this.makeGraphic(plat_width, plat_height, 0xffaaaaaa);
		}
		
	}

}