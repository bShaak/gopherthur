package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	
	public class Box extends FlxSprite
	{		
		private var inFlight:Boolean; //Thrown boxes are "in flight" until they slow down. They can not be picked up.
									  //This is required for players to hit one another with boxes, rather than
									  //just play catch with the box.
		private var isHeld:Boolean;
		
		private var spawn:FlxPoint;
		
		public function Box(x:Number, y:Number) 
		{
			super(x, y);
			
			spawn = new FlxPoint(x, y);
			
			this.maxVelocity.x = 200;
			this.maxVelocity.y = 200;
			this.acceleration.y = 200;
			this.drag.x = 200;
			this.width = 8;
			this.height = 8;
			this.isHeld = false;
			this.inFlight = false;
			
			//set appearance
			this.makeGraphic(width, height, 0xffffd700);
		}
		
		public function getSpawn():FlxPoint {
			return this.spawn;
		}
		
		public function isAvailable():Boolean {
			return (!isHeld && !inFlight);
		}
		
		public function isInFlight():Boolean {
			return this.inFlight;
		}
		
		public function pickUp():Boolean {
			if (!isAvailable())
				return false;
			
			isHeld = true;
			return true;
		}
		
		public function drop():Boolean {
			if (!isHeld)
				return false;
			
			isHeld = false;
			inFlight = true;
			return true;
		}
		
		override public function update():void {
			if (FlxU.abs(this.velocity.x) < 20 && this.inFlight)
				inFlight = false;
		}
	}

}