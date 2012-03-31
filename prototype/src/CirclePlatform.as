package  
{
	/**
	 * A platform the moves in a circle.
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	 
	public class CirclePlatform extends Platform
	{
		//[Embed(source = "/textures/space_platform_48x16.png")] private var MetalTexture:Class;
		[Embed(source = "/textures/metal.png")] private var MetalTexture:Class;
		
		private var clock:Clock;
		private var middle:FlxPoint;
		private var radius:Number;
		private var initialRotation:Number;
		private var rotateTime:Number;
		private var reverse:Number = 1;
		private var drawArea:FlxSprite;
		private var reverseTime:int;
		/**
		 * Create a moving platform.
		 * @param	middle The middle of the path.
		 * @param	radius The radius of the circle
		 * @param	rotateTime The time in milliseconds for a complete circuit of the path (back and forth)
		 * @param	initialRotation A number between 0 and 2pi, representing where in the path the platform should start.
		 * @param	reverse True if the direction of rotation should be reversed.
		 * @param	plat_width The width of the platform.
		 * @param	plat_height The height of the platform.
		 * @param	clock The clock to time platform movement.
		 * @param	oneWay True if the platform is one way.
		 */
		public function CirclePlatform(middle:FlxPoint, radius:Number, rotateTime:Number, initialRotation:Number,
										reverse:Boolean, plat_width:Number, plat_height:Number, clock:Clock, oneWay:Boolean,
										drawArea:FlxSprite, rotationsPerReverse:int) {
			super(middle.x + radius, middle.y);
			
			this.rotateTime = rotateTime;
			this.clock = clock;
			this.immovable = true; //objects on top won't weigh it down
			this.initialRotation = initialRotation;
			this.drawArea = drawArea;
			this.reverseTime = rotationsPerReverse * rotateTime;
			
			oneWay ? this.oneWay=true : this.oneWay=false;			
			if (reverse) {
				this.reverse = -1;
			}
			
			this.loadGraphic(MetalTexture, false, false, plat_width, plat_height);
						
			this.middle = new FlxPoint(middle.x, middle.y);
			this.radius = radius;
			
			//calculate max y velocity for helping keep sprites glued to platforms when they shift from up to down trajectories.
			this.maxVelocity.y = Math.abs(2 * Math.PI * radius / (rotateTime / 1000));
		}
		
		override public function update():void {
			var timedReverse:int = 1;
			if (reverseTime > 0 && int(clock.elapsed / reverseTime) % 2) {
				timedReverse = -1;
			}
			
			var angle:Number = 2 * Math.PI * (clock.elapsed % rotateTime) / rotateTime;
			x = middle.x + radius * Math.cos(timedReverse * reverse * (angle + initialRotation)) - width/2;
			y = middle.y + radius * Math.sin(timedReverse * reverse * (angle + initialRotation)) - height / 2;
			drawArea.drawLine(middle.x, middle.y, x + width / 2, y + height / 2, 0xffffffff, 7);
			drawArea.drawLine(middle.x, middle.y, x + width / 2, y + height / 2, 0xff000000, 3);
		}
	}
}