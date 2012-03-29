package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	import org.flixel.system.FlxAnim;
	import playerio.*;
	
	public class Player extends SBSprite
	{	
		public var id:int;
		protected var score:int;
		protected var isHoldingBox:Boolean;
		public var boxHeld:Box;
		protected var spawn:FlxPoint;
		protected var colour:int;
		protected var throwStrength:FlxPoint;
		
		protected var charging:Boolean; //ras
		protected var shoved:Boolean; //ras
		protected const MAX_SPEED:int = 160;  
		protected const SHOVE_STRENGTH:Array = [400, 500, 600]; //ras 
		protected var numBoxesInZone:int = 0; //ras
		public var shoveMsgSent:Boolean = false;  // makes sure the CHARGE msg is only sent once per charge
		
		public static const IDLE_THRESH:Number = 20; //player will appear idle if below this speed

		//Embed sounds we will use
		[Embed(source = "../mp3/jump_new.mp3")] protected var Jump:Class;
		[Embed(source = "../mp3/throw.mp3")] protected var Throw:Class;
		
		public function Player(x:Number, y:Number, id:int, color:int, walkAnimation:Class) 
		{
			super(x, y);

			spawn = new FlxPoint(x, y); //shouldn't FlxSprite have something like this?... I can't find anything
			
			score = 0;
			
			this.maxVelocity.x = MAX_SPEED;
			this.maxVelocity.y = 480;
			this.acceleration.y = 720;
			this.drag.x = this.maxVelocity.x * 8;
			this.width = 16;
			this.height = 24;
			this.isHoldingBox = false;
			this.charging = false; //ras
			this.shoved = false;
			this.throwStrength = new FlxPoint(400, -50); //the velocity the box will have when thrown
			this.id = id;

			// TODO: Handle this better
			//this.makeGraphic(width, height, color);
			this.colour = color;
			
		
			this.loadGraphic(walkAnimation, true, true, 16, 24);
				
			this.addAnimation("walk_right", [1, 2, 3, 4, 0], 12, true);
			this.addAnimation("idle_right", [0], 1, true);
			this.addAnimation("jumping_right", [2], 1, true);
			this.addAnimation("falling_right", [3], 1, true);
			
			//set default graphic
			if (this.x < FlxG.width / 2)
				this.facing = FlxObject.RIGHT;
			else
				this.facing = FlxObject.LEFT;
			play("idle_right");
		}
		
		override public function update():void {
			//update the sprite's appearance based on their movement.
			//We tie animations to movement rather than key input due to multiplayer restraints.
			
			if (shoved && Math.abs(velocity.x) <= MAX_SPEED) {
				shoved = false;
				maxVelocity.x = MAX_SPEED;
			}
			
			if (this.velocity.x < 0) {
				this.facing = FlxObject.LEFT;
				if (this.hasBox())
					this.boxHeld.setDirection(FlxObject.LEFT);
			}
			else if (this.velocity.x > 0) {
				this.facing = FlxObject.RIGHT;
				if (this.hasBox())
					this.boxHeld.setDirection(FlxObject.RIGHT);
			}
			if (this.isTouching(FlxObject.FLOOR)) {
				if (Math.abs(this.velocity.x) > IDLE_THRESH) {
					this.play("walk_right");
				}
				else {
					this.play("idle_right");
				}
			}
			else { //player is in the air
				if (this.velocity.y > 0) {
					this.play("falling_right");
				}
				else if (this.velocity.y < 0) {
					this.play("jumping_right");
				}
				
			}
			
			positionBox();
		}
		
		public function getColour():int {
			return this.colour;
		}
		
		public function getSpawn():FlxPoint {
			return spawn;
		}
		
		public function getConnection():Connection {
			//trace("Player");
			return null;
		}
		
		public function hasBox():Boolean {
			return isHoldingBox;
		}
		
		public function pickupBox(box:Box):Boolean {
			if (this.isHoldingBox == true)
				return false; //can only hold one
			
			if (!box.pickUp(this)) //see if box is available for pickup
				return false;
			
			this.isHoldingBox = true;
			this.boxHeld = box;
			
			return true;
		}
		
		public function dropBox():Boolean {
			if (!isHoldingBox)
				return false;
				
			this.boxHeld.y -= this.boxHeld.height; // ras
			this.isHoldingBox = false;
			this.boxHeld.drop();
			this.boxHeld = null;
			
			return true;
		}
		
		public function throwBox():Boolean {
			if (!this.isHoldingBox)
				return false;
				
			this.boxHeld.dropThrow();
			
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
		
		public function setNumBoxesInZone(num:int):void {
			if (num > 2) {
				trace("Player:setShoveStrength(): idx needs to be less than 3");
				return;
			}
			numBoxesInZone = num;
		}
		
		public function getShoved(player:Player):void {
			this.maxVelocity.x = player.SHOVE_STRENGTH[player.numBoxesInZone];
			this.shoved = true;
			
			var dir:int = 1;
			if (this.x < player.x)
				dir = -1;
			this.velocity.x = player.SHOVE_STRENGTH[player.numBoxesInZone]*dir;
		}
		
		public function incrementScore():void {
			score++;
		}
		
		public function getScore():int {
			return score;
		}

		public function isCharging():Boolean {
			return charging;
		}
		
		public function isShoved():Boolean {
			return shoved;
		}
		
		protected function startCharging():void {
			//trace("START SLIDE");
			charging = true;
			maxVelocity.x = SHOVE_STRENGTH[numBoxesInZone];
			if (this.facing == FlxObject.LEFT) {
				//trace("Left");
				velocity.x = -SHOVE_STRENGTH[numBoxesInZone];
			}
			else {
				//trace("Right");
				velocity.x = SHOVE_STRENGTH[numBoxesInZone];
			}
				
			//trace(velocity.x);
		}
		
		protected function stopCharging():void {
			//trace("STOP SLIDE");
			 charging = false;
			 shoveMsgSent = false;
			 maxVelocity.x = MAX_SPEED;
		}
		
		protected function stopShove():void {
			shoved = false;
			shoveMsgSent = false;
			maxVelocity.x = MAX_SPEED;
		}
		
		public function positionBox():void // ras: protected
		{
			if (!isHoldingBox) 
				return;
				
			var boxX:Number;
			var boxY:Number;
			var numPixels:int = 2;
			
			//update held box position
			if (this.facing == FlxObject.LEFT) {
				boxHeld.x = this.getMidpoint().x - this.width - Box.JUICEBOX_STRAW_WIDTH;
			}
			else if (this.facing == FlxObject.RIGHT) {
				boxHeld.x = this.getMidpoint().x + this.width/2;
			}
				
			boxHeld.y = this.getMidpoint().y - this.height;
				
		}
	}
}