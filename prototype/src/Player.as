package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	import playerio.*;
	public class Player extends FlxSprite
	{	
		public var id:int;
		protected var score:int;
		protected var isHoldingBox:Boolean;
		protected var boxHeld:Box;
		protected var spawn:FlxPoint;
		protected var colour:int;
		protected var throwStrength:FlxPoint;
		protected var connection:Connection;
		
		//Embed sounds we will use
		[Embed(source = "../mp3/jump_new.mp3")] protected var Jump:Class;
		[Embed(source = "../mp3/throw.mp3")] protected var Throw:Class;
		
		public function Player(x:Number, y:Number, id:int, color:int, connection:Connection) 
		{
			super(x, y);

			spawn = new FlxPoint(x, y); //shouldn't FlxSprite have something like this?... I can't find anything
			
			score = 0;
			
			this.maxVelocity.x = 120;
			this.maxVelocity.y = 210;
			this.acceleration.y = 200;
			this.drag.x = this.maxVelocity.x * 8;
			this.width = 10;
			this.height = 12;
			this.isHoldingBox = false;
			this.throwStrength = new FlxPoint(200, -25); //the velocity the box will have when thrown
			this.connection = connection;
			
			this.id = id;
			
			// TODO: Handle this better
			this.makeGraphic(width, height, color);
			this.colour = color;
		}
		
		public function getColour():int {
			return this.colour;
		}
		
		public function getSpawn():FlxPoint {
			return spawn;
		}
		
		public function hasBox():Boolean {
			return isHoldingBox;
		}
		
		public function pickupBox(box:Box):Boolean {
			if (this.isHoldingBox == true)
				return false; //can only hold one
			
			if (!box.pickUp()) //see if box is available for pickup
				return false;
			
			this.isHoldingBox = true;
			this.boxHeld = box;
			return true;
		}
		
		public function dropBox():Boolean {
			if (!isHoldingBox)
				return false;
			
			this.boxHeld.drop();
			this.boxHeld = null;
			this.isHoldingBox = false;
			
			return true;
		}
		
		public function throwBox():Boolean {
			if (!this.isHoldingBox)
				return false;
				
			this.boxHeld.drop();
			
			this.boxHeld.velocity.y = this.throwStrength.y;
			if (this.facing == FlxObject.LEFT)
				this.boxHeld.velocity.x = -this.throwStrength.x;
			else
				this.boxHeld.velocity.x = this.throwStrength.x;
				
			this.boxHeld = null;
			this.isHoldingBox = false;
			
			return true;
		}
		
		public function hitWithBox(box:Box):void {
			//figure out which direction to push player
			var dir:int = 1;
			if (this.x < box.x)
				dir = -1; //push to left
			this.velocity.y = -50;
			this.velocity.x = this.maxVelocity.x * dir;
			
			//also make the box fall to the floor
			box.velocity.x = 0;
		}
		
		public function incrementScore():void {
			score++;
		}
		
		public function getScore():int {
			return score;
		}
	}
}