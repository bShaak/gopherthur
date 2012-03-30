package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	
	
	public class Lava extends SBSprite
	{
		/* TODO: this and other classes are all cycling through a path
		 * just by following the clock. There should be a common parent class.
		 * Something like WaypointSprite. I'll wait to get the group's thoughts.
		 */
		private var clock:Clock;
		private var pathStart:FlxPoint;
		private var pathEnd:FlxPoint;
		private var initialPosition:Number;
		private var circuitTime:Number;
		private var downTimeWaitPeriod:Number;
		private var warningTime:Number;
		private var downStartTime:Number;
		private var isInDownTime:Boolean;
		private var prevTimeInCircuit:Number;
		private var rumbleOn:Boolean;
		
		[Embed(source = "../mp3/earth_rumble.mp3")] private var Rumble:Class;
		
		public function Lava(x:int, y:int, start:FlxPoint, end:FlxPoint, circuitTime:Number,
							 downTime:Number, warningTime:Number, initialPosition:Number, clock:Clock) {
			super(x, y);
			
			this.pathStart = start;
			this.pathEnd = end;
			this.circuitTime = circuitTime;
			this.downTimeWaitPeriod = downTime;
			this.warningTime = warningTime;
			this.downStartTime = 0;
			this.isInDownTime = true;
			this.prevTimeInCircuit = 0;
			this.clock = clock;
			this.initialPosition = initialPosition;
			this.makeGraphic(FlxG.width, FlxG.height, 0x99CC0000);
			rumbleOn = false;
		}
		
		override public function update():void {
			// At the end of every cycle lava should pause, so it's not constantly moving
			// up and down, tracing it's path.
			if (isInDownTime) {
				var elapsedDownTime:Number = clock.elapsed - downStartTime;
				
				if (elapsedDownTime >= downTimeWaitPeriod) {
					isInDownTime = false;
					if (rumbleOn) {
						rumbleOn = false;
					}
				}
				else if (downTimeWaitPeriod - elapsedDownTime <= warningTime){
					if (!rumbleOn) {
						FlxG.play(Rumble);
						rumbleOn = true;
					}
					FlxG.shake(0.002, circuitTime / 1000);
				}
				return;
			}
			
			// This looks complicated, but it's actually really simple.
			// First, we find how long we are into the current circuit. 
			// We need to add one to the initial position offset because % takes the sign of the divident,
			// so we need to force it to be positive.
			var timeInCircuit:Number = ((clock.elapsed-downStartTime-downTimeWaitPeriod) + circuitTime * (1 + initialPosition / 2)) % circuitTime;
			// Now we find out the position within the circuit as a number between 0 and 1. That is,
			// 0 for ix, iy and 1 for fx, fy. Since we want the movement to reverse, we just normalize time
			// to 2 and then find the distance from 1 (so we get something like .7, .8, .9, 1, .9, .8, .7)
			var stage:Number = Math.abs(timeInCircuit * 2 / circuitTime - 1);
			
			// Now follow a linear path between the start and end positions.
			x = pathStart.x + (pathEnd.x - pathStart.x) * stage;
			y = pathStart.y + (pathEnd.y - pathStart.y) * stage;
			
			// We need to use a tolerance because the clock is not necessarily strictly increasing in multiplayer 
			if (timeInCircuit < prevTimeInCircuit - circuitTime / 4) { //indicates we've looped around to start of path
				isInDownTime = true;
				downStartTime = clock.elapsed;
			}
			prevTimeInCircuit = timeInCircuit;
			
		}
	}

}