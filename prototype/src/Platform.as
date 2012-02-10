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
		
		//TODO: This function should take all the path points
		//just to make path assignment internal, rather than having
		//to create path objects when you make a new platform.
		public function addPath():void{
		
		}
	}

}