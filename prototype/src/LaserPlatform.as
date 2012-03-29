package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	public class LaserPlatform extends BackForthPlatform
	{
		public static const UP:int = 1;
		public static const DOWN:int = 2;
		public static const LEFT:int = 3;
		public static const RIGHT:int = 4;

				
		protected var dir:int;
		protected var laserGroup:FlxGroup;
		protected var laser:FlxSprite;
		protected var onTime:int;
		protected var offTime:int;
		protected var lastTime:int = 0;
		
		public function LaserPlatform(start:FlxPoint, end:FlxPoint, circuitTime:Number, initialPosition:Number,
										plat_width:Number, plat_height:Number, clock:Clock, oneWay:Boolean,
										dir:int, laserGroup:FlxGroup, onTime:int, offTime:int)
		{
			super(start, end, circuitTime, initialPosition, plat_width, plat_height, clock, oneWay);
			this.dir = dir;
			this.laserGroup = laserGroup;
			this.onTime = onTime;
			this.offTime = offTime;
			
			if (dir == UP || dir == DOWN) {
				laser = new Laser(0, 0, width, FlxG.height);
			} else {
				laser = new Laser(0, 0, FlxG.width, height);
			}
			laserGroup.add(laser);
			this.removeLaser();
		}
		
		protected function removeLaser():void {
			laser.visible = false;
			clock.setElapsedTimeout(lastTime + offTime, this.addLaser);
			lastTime = lastTime + offTime;
		}
		
		protected function addLaser():void {
			laser.visible = true;
			clock.setElapsedTimeout(lastTime + onTime, this.removeLaser);
			lastTime = lastTime + onTime;
		}
		
		override public function update():void {
			super.update();
			if (dir == UP) {
				laser.y = y - laser.height;
				laser.x = x;
			} else if (dir == DOWN) {
				laser.y = y + height;
				laser.x = x;
			} else if (dir == LEFT) {
				laser.x = x - FlxG.width;
				laser.y = y;
			} else {
				laser.x = x + width;
				laser.y = y;
			}
		}
	}

}