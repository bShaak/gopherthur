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
		public static var TOLERANCE:int = 4; //pixels
		
		public function SBSprite(x:Number, y:Number)
		{
			super(x,y);
		}
		
		//returns ture if s is directly below this, within tolerance on all dimensions
		public function isBelow(s:FlxSprite):Boolean {
			if (this.y + TOLERANCE >= s.y + s.height &&
			    this.x + TOLERANCE  <= s.x + s.width &&
				this.x + this.width - TOLERANCE >= s.x)
				return true;
			
			return false;
		}
		
		public function isAbove(s:FlxSprite):Boolean {
			if (this.y + this.height - 2*TOLERANCE <= s.y &&
			    this.x + TOLERANCE <= s.x + s.width &&
				this.x + this.width - TOLERANCE >= s.x)
				return true;
			
			return false;
		}
		
		public function isLeftOf(s:FlxSprite):Boolean {
			if (this.x + this.width - TOLERANCE <= s.x &&
			    this.y + TOLERANCE <= s.y + s.height &&
				this.y + this.height - TOLERANCE >= s.y)
				return true;
			
			return false;
		}
		
		public function isRightOf(s:FlxSprite):Boolean {
			if (this.x + TOLERANCE >= s.x + s.width &&
			    this.y + TOLERANCE <= s.y + s.height &&
				this.y + this.height - TOLERANCE >= s.y)
				return true;
			
			return false;
		}
		
	}

}