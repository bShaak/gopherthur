package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	
	public class Box extends FlxSprite
	{
		private static const max_velocity_x:int 	= 200;
		private static const drag_x:int 			= 200//max_velocity_x * 4;
		private static const max_velocity_y:int 	= 200;					//max fall speed
		private static const player_gravity:int 	= 200; 					//constant acceleration in y direction
		
		private static const box_width:int = 8;
		private static const box_height:int = 8;
		
		private var isHeld:Boolean;
		private var inFlight:Boolean;
		
		private var spawn:FlxPoint;
		
		public function Box(x:Number, y:Number) 
		{
			super(x, y);
			
			spawn = new FlxPoint(x, y);
			
			this.maxVelocity.x = max_velocity_x;
			this.maxVelocity.y = max_velocity_y;
			this.acceleration.y = player_gravity;
			this.drag.x = drag_x;
			this.width = box_width;
			this.height = box_height;
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
			if (isHeld)
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