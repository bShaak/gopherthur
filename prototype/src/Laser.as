package  
{
	/**
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class Laser extends SBSprite
	{
		
		public function Laser(x:int, y:int, width:int, height:int) 
		{
			super(x, y);
			
			this.makeGraphic(width, height, 0x99001188);
		}
		
	}

}