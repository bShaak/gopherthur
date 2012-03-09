package  
{
	import org.flixel.*;
	
	/**
	 * This is the basic sprite class for Springbox. I just needed to add some general methods
	 * for more specific collisions and orientations.
	 * 
	 * @author rayk
	 */
	public class SBSprite extends FlxSprite
	{
		protected static const TOLERANCE:int = 4; //pixels
		
		public function SBSprite(x:Number, y:Number)
		{
			super(x,y);
		}
		
		//returns ture if s is directly above this, within tolerance on all dimensions
		public function isBelow(s:FlxSprite):Boolean {
			if (this.y + TOLERANCE >= s.y + s.height &&
			    this.x + TOLERANCE  <= s.x + s.width &&
				this.x + this.width - TOLERANCE >= s.x)
				return true;
			
			return false;
		}
		
		public function isAbove(s:FlxSprite):Boolean {
			if (this.y - TOLERANCE <= s.y &&
			    this.x + TOLERANCE <= s.x + s.width&&
				this.x + this.width - TOLERANCE >= s.x)
				return true;
			
			return false;
		}
		
	}

}