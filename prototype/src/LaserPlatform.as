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
		protected var laser:Laser;
		protected var onTime:int;
		protected var offTime:int;
		protected var warmupTime:int;
		protected var random:PseudoRandom;
		
		private var lastTime:int = 0;
		private var numShots:int = 0;
		
		public function LaserPlatform(start:FlxPoint, end:FlxPoint, circuitTime:Number, initialPosition:Number,
										plat_width:Number, plat_height:Number, clock:Clock, oneWay:Boolean,
										dir:int, laserGroup:FlxGroup, onTime:int, offTime:int, warmupTime:int,
										random:PseudoRandom)
		{
			super(start, end, circuitTime, initialPosition, plat_width, plat_height, clock, oneWay);
			this.dir = dir;
			this.laserGroup = laserGroup;
			this.onTime = onTime;
			this.random = random;
			//this.offTime = offTime;
			/******** IMPORTANT ********
			 * The offTime specified by the user (level declaration) isn't used at all right now. The offTime is completely 
			 * randomized internally. I just thought it worked better for now. I'm still leaving the old offTime declarations
			 * in though, in case we want to go back. So yeah, beware! --Ray
			 */
			this.offTime = random.random() * 5000;
			this.warmupTime = warmupTime;
			
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
			laser.makeGraphic(laser.width, laser.height, Laser.warmupColour);
			clock.setElapsedTimeout(lastTime + offTime, this.warmupLaser);
			lastTime = lastTime + offTime;
			randomizeOffTime();
		}
		
		protected function addLaser():void {
			laser.visible = true;
			laser.setWarmup(false);
			laser.makeGraphic(laser.width, laser.height, Laser.beamingColour);
			clock.setElapsedTimeout(lastTime + onTime, this.removeLaser);
			lastTime = lastTime + onTime;
		}
		
		protected function warmupLaser():void {
			numShots++;
			laser.visible = true;
			laser.setWarmup(true);
			laser.flicker(warmupTime / 1000);
			clock.setElapsedTimeout(lastTime + warmupTime, this.addLaser);
			lastTime = lastTime + warmupTime;
		}
		
		protected function randomizeOffTime():void {
			offTime = random.random() * 5000 + 1000; //random between 1 and 6 seconds.
		}
		
		override public function update():void {
			//don't move if laser is warming up or shooting
			if (laser.visible)
				return;
				
			var timeInCircuit:Number = ((clock.elapsed - numShots*(warmupTime+onTime)) + circuitTime * (1 + initialPosition / 2)) % circuitTime;
			
			var stage:Number = Math.abs(timeInCircuit * 2 / circuitTime - 1);
			
			x = pathStart.x + (pathEnd.x - pathStart.x) * stage;
			y = pathStart.y + (pathEnd.y - pathStart.y) * stage;
		
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