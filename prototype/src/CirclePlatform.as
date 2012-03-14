package  
{
	/**
	 * A platform the moves in a circle.
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class CirclePlatform extends Platform
	{
		[Embed(source = "/textures/metal.png")] private var MetalTexture:Class;
		
		private var clock:Clock;
		private var middle:FlxPoint;
		private var radius:Number;
		private var initialPosition:Number;
		private var circuitTime:Number;
		
		/**
		 * Create a moving platform.
		 * @param	middle The middle of the path.
		 * @param	radius The radius of the circle
		 * @param	circuitTime The time in milliseconds for a complete circuit of the path (back and forth)
		 * @param	initialPosition A number between 0 and 2pi, representing where in the path the platform should start.
		 * @param	plat_width The width of the platform.
		 * @param	plat_height The height of the platform.
		 * @param	clock The clock to time platform movement.
		 */
		public function CirclePlatform(middle:FlxPoint, radius:Number, circuitTime:Number, initialPosition:Number, plat_width:Number, plat_height:Number, clock:Clock, oneWay:Boolean) {
			super(middle.x + radius, middle.y);
			
			this.circuitTime = circuitTime;
			this.clock = clock;
			this.immovable = true; //objects on top won't weigh it down
			this.initialPosition = initialPosition;
			oneWay ? this.oneWay=true : this.oneWay=false;			
			
			this.loadGraphic(MetalTexture, false, false, plat_width, plat_height);
						
			this.middle = new FlxPoint(middle.x - plat_width / 2, middle.y - plat_height / 2);
			this.radius = radius;
			
			//calculate max y velocity for helping keep sprites glued to platforms when they shift from up to down trajectories.
			this.maxVelocity.y = Math.abs(2 * Math.PI * radius / (circuitTime / 1000));
		}
		
		override public function update():void {
			var angle:Number = 2 * Math.PI * (clock.elapsed % circuitTime) / circuitTime;
			x = middle.x + radius * Math.sin(angle + initialPosition);
			y = middle.y + radius * Math.cos(angle + initialPosition);
		}
	}
}