package  
{
	/**
	 * A simple platform that moves back and forth.
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class BackForthPlatform extends Platform
	{
		[Embed(source = "/textures/metal.png")] private var MetalTexture:Class;
		[Embed(source = "/textures/oneway_platform.png")] private var OnewayPlatformTexture:Class;
		
		protected var clock:Clock;
		protected var pathStart:FlxPoint;
		protected var pathEnd:FlxPoint;
		protected var initialPosition:Number;
		protected var circuitTime:Number;
		
		/**
		 * Create a moving platform.
		 * @param	start The start of the path.
		 * @param	end The end of the path.
		 * @param	circuitTime The time in milliseconds for a complete circuit of the path (back and forth)
		 * @param	initialPosition A number between -1 and 1, representing where in the path the platform should start (0 for ix, iy)
		 * @param	plat_width The width of the platform.
		 * @param	plat_height The height of the platform.
		 * @param	clock The clock to time platform movement.
		 */
		public function BackForthPlatform(start:FlxPoint, end:FlxPoint, circuitTime:Number, initialPosition:Number, plat_width:Number, plat_height:Number, clock:Clock, oneWay:Boolean) {
			super(start.x, start.y);
			
			this.circuitTime = circuitTime;
			this.clock = clock;
			this.immovable = true; //objects on top won't weigh it down
			this.initialPosition = initialPosition;
			if (oneWay) {
				this.oneWay = true;
				this.loadGraphic(OnewayPlatformTexture, false, false, plat_width, plat_height);
			}
			else {
				this.oneWay = false;
				this.loadGraphic(MetalTexture, false, false, plat_width, plat_height);
			}
			
			this.pathStart = start;
			this.pathEnd = end;
			
			//calculate max y velocity for helping keep sprites glued to platforms when they shift from up to down trajectories.
			this.maxVelocity.y = Math.abs((this.pathEnd.y - this.pathStart.y) / (circuitTime / 1000) * 2); //the 2 is because we want the time of half a cycle
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
			x = pathStart.x + (pathEnd.x - pathStart.x) * stage;
			y = pathStart.y + (pathEnd.y - pathStart.y) * stage;
		}
	}

}