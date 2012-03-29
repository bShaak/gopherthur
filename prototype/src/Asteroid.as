package  
{
	/**
	 * @author Jeremy Johnson
	 */
	
	import org.flixel.*;
	
	
	public class Asteroid extends SBSprite
	{
		
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