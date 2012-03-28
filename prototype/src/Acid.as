package  
{
	/**
	 * ...
	 * @author Jen
	 */
	
	import org.flixel.*;
	 
	public class Acid extends SBSprite
	{
		
		public function Acid(x:int, y:int, width:int, height:int) 
		{
			super(x, y);
			
			this.makeGraphic(width, height, 0x9900CC00);
		}
		
	}

}