package  
{
	/**
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class Laser extends SBSprite
	{
		protected var warmingUp:Boolean;
		public static var warmupColour:uint = 0x2266ffff;
		public static var beamingColour:uint = 0x9966ffff;
		
		public function Laser(x:int, y:int, width:int, height:int) 
		{
			super(x, y);
			
			this.makeGraphic(width, height, warmupColour);
			
			warmingUp = false;
		}
		
		public function isWarmingUp():Boolean {
			return warmingUp;
		}
		
		public function setWarmup(warmupState:Boolean):void {
			warmingUp = warmupState;
		}
		
	}

}