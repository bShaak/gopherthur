package  
{
	/**
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	
	
	public class Asteroid extends SBSprite
	{
		[Embed(source = "/sprites/asteroid_strip_40px.png")] private var AsteroidAnimation:Class;
		public static const ASTEROID_EXTRA_WIDTH:int = 8; // pixels
		public static const ASTEROID_EXTRA_HEIGHT:int = 8;
		
		private var speed:Number;
		private var clock:Clock;
		private var startTime:Number;
		private var startX:int;
		private var startY:int;
		private var pAngle:Number;
		public function Asteroid(x:int, y:int, speed:Number, angle:Number, startTime:Number, clock:Clock) 
		{
			super(x, y);
			this.makeGraphic(40, 40, 0xff00ff00);
			
			this.loadGraphic(AsteroidAnimation, true, true, 40, 40);
			
			this.addAnimation("rotate", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
										33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64], 12, true);
			
			this.play("rotate");
			
			this.immovable = true;
			this.clock = clock;
			this.startTime = startTime;
			this.startX = x;
			this.startY = y;
			this.speed = speed / 1000.0;
			this.pAngle = angle;
		}
		
		override public function update():void {
			var d:Number = (clock.elapsed - startTime) * speed;
			x = startX + d * Math.cos(pAngle);
			y = startY + d * Math.sin(pAngle);
			
			if (x < -width || y < -height || x > FlxG.width || y > FlxG.height) {
				alive = false;
				active = false;
			}
		}
	}

}