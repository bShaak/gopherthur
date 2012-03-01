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
		public var holder:Player;
		
		private var spawn:FlxPoint;
		public var id:int;       // ras: for identifying which box is picked up when sending over network
		
		public function Box(x:Number, y:Number, id:int) 
		{
			super(x, y);
			
			spawn = new FlxPoint(x, y);
			
			this.maxVelocity.x = 400;
			this.maxVelocity.y = 400;
			this.acceleration.y = 400;
			this.drag.x = 400;
			this.width = 12;
			this.height = 18;
			this.isHeld = false;
			this.inFlight = false;
			
			this.id = id; // ras
			
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
		
		public function pickUp(p:Player):Boolean {
			if (!isAvailable())
				return false;
			
			isHeld = true;
			holder = p;
			return true;
		}
		
		public function dropThrow():Boolean {
			if (!isHeld) 
				return false;
				
			isHeld = false;
			holder = null;
			inFlight = true;
			return true;
		}
		
		public function drop():Boolean {
			if (!isHeld)
				return false;
			
			isHeld = false;
			holder.dropBox(); // Note, this will not infinitely recurse as isHeld is set false before call.
			holder = null;
			return true;
		}
		
		override public function update():void {			
			if (FlxU.abs(this.velocity.x) < 20 && this.inFlight)
				inFlight = false;
		}
	}

}