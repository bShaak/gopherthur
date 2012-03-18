package  
{
	/**
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class Platform extends SBSprite
	{
		protected var oneWay:Boolean // one-way platforms can be jumped through from below
		
		public function Platform(x:int, y:int) {
			super(x, y);
		}
		
		public function isOneWay():Boolean {
			return this.oneWay;
		}
	}

}