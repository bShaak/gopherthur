package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	 
	public class Platform extends FlxSprite
	{
		private var clock:Clock;
		private var ix:Number;
		private var iy:Number;
		private var fx:Number;
		private var fy:Number;
		private var initialPosition:Number;
		private var circuitTime:Number;
		
		/**
		 * Create a moving platform.
		 * @param	ix The x value at the start of the path for the middle of the platform.
		 * @param	iy The y value at the start of the path.
		 * @param	fx The x value at the end of the path.
		 * @param	fy The y value at the end of the path.
		 * @param	circuitTime The time in milliseconds for a complete circuit of the path (back and forth)
		 * @param	initialPosition A number between -1 and 1, representing where in the path the platform should start (0 for ix, iy)
		 * @param	plat_width The width of the platform.
		 * @param	plat_height The height of the platform.
		 * @param	clock The clock to time platform movement.
		 */
		public function Platform(ix:Number, iy:Number, fx:Number, fy:Number, circuitTime:Number, initialPosition:Number, plat_width:Number, plat_height:Number, clock:Clock) {
			super(ix, iy);
			
			this.circuitTime = circuitTime;
			this.clock = clock;
			this.immovable = true; //objects on top won't weigh it down
			this.initialPosition = initialPosition;
			
			this.makeGraphic(plat_width, plat_height, 0xffaaaaaa);
			
			// note, width and height are not set properly until after makeGraphic
			this.ix = ix - width/2;
			this.iy = iy - height/2;
			this.fx = fx - width/2;
			this.fy = fy - height / 2;
		}
		
		override public function update():void {
			// This looks complicated, but it's actually really simple.
			// First, we find how long we are into the current circuit. 
			// We need to add one to the initial position offset because % takes the sign of the divident,
			// so we need to force it to be positive.
			var timeInCircuit:Number = (clock.elapsed + circuitTime * (1 + initialPosition / 2)) % circuitTime;
			
			// Now we find out the position within the circuit as a number between 0 and 1. That is,
			// 0 for ix, iy and 1 for fx, fy. Since we want the movement to reverse, we just normalize time
			// to 2 and then find the distance from 1 (so we get something like .7, .8, .9, 1, .9, .8, .7)
			var stage:Number = Math.abs(timeInCircuit * 2 / circuitTime - 1);
			
			// Now follow a linear path between the start and end positions.
			x = ix + (fx - ix) * stage;
			y = iy + (fy - iy) * stage;
		}
	}

}