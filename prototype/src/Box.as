package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	import flash.utils.Timer;
	import flash.events.*;
	
	public class Box extends SBSprite
	{	
		[Embed(source = "/sprites/juicebox.png")] private var JuiceBoxImage:Class;
		public static const JUICEBOX_STRAW_WIDTH:int = 4; // The extra width (in pixels) that the straw has on the actual collision size.
		public static const JUICEBOX_STRAW_HEIGHT:int = 4;
		
		private var inFlight:Boolean; //Thrown boxes are "in flight" until they slow down. They can not be picked up.
									  //This is required for players to hit one another with boxes, rather than
									  //just play catch with the box.
		private var isHeld:Boolean;
		public var holder:Player;
		public var lastMessage:int = -1;
		
		private var spawn:FlxPoint;
		public var id:int;       // for identifying which box is picked up when sending over network
		private var timer:Timer;  // for handling of boxes getting stuck in walls 
		
		public function Box(x:Number, y:Number, id:int) 
		{
			super(x, y);
			
			this.spawn = new FlxPoint(x, y);
			
			this.maxVelocity.x = 480;
			this.maxVelocity.y = 480;
			this.acceleration.y = 720;
			this.drag.x = 480;
			//this.width = 12;
			//this.height = 18;
			this.isHeld = false;
			this.inFlight = false;
			
			this.id = id; 
			this.timer = null;
			
			//set appearance
			this.loadGraphic(JuiceBoxImage, false, true);//, 16, 22);
			this.width = 12; //set width/height after, because they're smaller than the graphic
			this.height = 18;
			this.setDirection(FlxObject.RIGHT);
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
			if (!isHeld && timer == null) {
				if (isInsideWall()) {
					timer = new Timer(1000, 1); 
					timer.addEventListener(TimerEvent.TIMER, checkOverlap);
					timer.start();
				}				
			}
			if (this.velocity.x > 0)
				this.setDirection(FlxObject.RIGHT);
			else if (this.velocity.x < 0)
				this.setDirection(FlxObject.LEFT);
		}
		
		/**
		 * Checks whether box is stuck inside the wall of the level.
		 * @return true if box overlaps with the level, false otherwise
		 */
		private function isInsideWall():Boolean {
			if (this.y < 0)
				return false;
			var padding:int = 3;  // makes sure the box is fairly deep in the wall to avoid edge cases
			try {
				if (PlayState.layerMap.overlapsPoint(new FlxPoint(this.x + padding, this.y))) {
					return true;
				}
				else if (PlayState.layerMap.overlapsPoint(new FlxPoint(this.x + this.width - padding, this.y))) {
					return true;
				}
				else 
					return false;
			}
			catch (errObject:Error) {
				// if box leaves the boundaries of the level, reset it
				this.reset(spawn.x, spawn.y);
				return false;
			}
			return false;
		}
		
		/**
		 * If box still overlaps with the level after 1s, respawn it.
		 * @param event
		 */
		private function checkOverlap(event:TimerEvent):void {
			//trace("checkOverlap(): " + this.x + " " + this.y);
			if (isInsideWall()) 
				this.reset(spawn.x, spawn.y);
			
			timer = null;
		}
		
		public function setDirection(dir:uint):void {
			this.facing = dir;
			
			// Update the graphic offset, which depends on the direction (because we don't want to collide with the part
			// of the graphic that is the juice box's straw)
			if (dir == FlxObject.LEFT)
				this.offset = new FlxPoint(0, JUICEBOX_STRAW_HEIGHT);
			else if (dir == FlxObject.RIGHT)
				this.offset = new FlxPoint(JUICEBOX_STRAW_WIDTH, JUICEBOX_STRAW_HEIGHT);
		}
	}

}