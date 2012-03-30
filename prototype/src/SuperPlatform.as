package  
{
	/**
	 * A platform that rotates around a point that moves along a track.
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class SuperPlatform extends Platform
	{
		[Embed(source = "/textures/metal.png")] private var MetalTexture:Class;
		
		private var clock:Clock;

		private var startMiddle:FlxPoint;
		private var endMiddle:FlxPoint;
		private var radius:Number;
		private var circuitTime:Number;
		private var rotateTime:Number;
		private var initialPosition:Number;
		private var initialRotation:Number;
		private var reverse:Number = 1;
		private var middle:FlxPoint;
		private var drawArea:FlxSprite;
		
		/**
		 * Create a moving platform.
		 * @param	startMiddle The starting position of the middle of the path.
		 * @param	endMiddle The ending position of the middle of the path.
		 * @param	radius The radius of the circle
		 * @param	circuitTime The time in milliseconds for the middle to make a complete circuit.
		 * @param	rotateTime The time taken to rotate in a circle once.
		 * @param	initialPosition A number between -1 and 1, representing where in the path the platform should start (0 for ix, iy)
		 * @param	initialRotation A number between 0 and 2pi, representing where in the path the platform should start.
		 * @param	reverse True if the direction of rotation should be reversed.
		 * @param	plat_width The width of the platform.
		 * @param	plat_height The height of the platform.
		 * @param	clock The clock to time platform movement.
		 * @param	oneWay True if the platform is oneWay.
		 */
		public function SuperPlatform(startMiddle:FlxPoint, endMiddle:FlxPoint, radius:Number, circuitTime:Number,
										rotateTime:Number, initialPosition:Number, initialRotation:Number, reverse:Boolean,
										plat_width:Number, plat_height:Number, clock:Clock, oneWay:Boolean,
										drawArea: FlxSprite) {
			super(startMiddle.x + radius, startMiddle.y);
			
			this.clock = clock;
			this.immovable = true; //objects on top won't weigh it down
			
			this.startMiddle = startMiddle;
			this.middle = new FlxPoint(0, 0);
			this.endMiddle = endMiddle;
			this.radius = radius;
			this.circuitTime = circuitTime;
			this.rotateTime = rotateTime;
			this.initialPosition = initialPosition;
			this.initialRotation = initialRotation;
			this.drawArea = drawArea;
			
			if (reverse) {
				this.reverse = -1;
			}
			
			oneWay ? this.oneWay=true : this.oneWay=false;			

			this.loadGraphic(MetalTexture, false, false, plat_width, plat_height);
			
			//calculate max y velocity for helping keep sprites glued to platforms when they shift from up to down trajectories.
			this.maxVelocity.y = Math.abs(2 * Math.PI * radius / (circuitTime / 1000)) +
								Math.abs((this.endMiddle.y - this.startMiddle.y) / (circuitTime / 1000) * 2);
			}
		
		override public function update():void {
			// Move the middle
			var timeInCircuit:Number = (clock.elapsed + circuitTime * (1 + initialPosition / 2)) % circuitTime;
			var stage:Number = Math.abs(timeInCircuit * 2 / circuitTime - 1);
			
			// Now follow a linear path between the start and end positions.
			middle.x = startMiddle.x + (endMiddle.x - startMiddle.x) * stage;
			middle.y = startMiddle.y + (endMiddle.y - startMiddle.y) * stage;

			// rotate around the middle.
			var angle:Number = 2 * Math.PI * (clock.elapsed % rotateTime) / rotateTime;
			x = middle.x + radius * Math.cos(reverse * (angle + initialRotation)) - width/2;
			y = middle.y + radius * Math.sin(reverse * (angle + initialRotation)) - height / 2;
			
			drawArea.drawLine(startMiddle.x, startMiddle.y, endMiddle.x, endMiddle.y, 0xff000000);
			drawArea.drawLine(middle.x, middle.y, x + width / 2, y + height / 2, 0xff000000);
		}
	}
}
