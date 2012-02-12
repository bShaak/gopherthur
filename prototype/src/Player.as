package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{		
		private static var count:int = 0; //player id counter
		
		private var id:int;
		private var isHoldingBox:Boolean;
		private var boxHeld:Box;
		private var spawn:FlxPoint;
		private var colour:int;
		private var throwStrength:FlxPoint;
		//Embed sounds we will use
		[Embed(source = "../mp3/jump_new.mp3")] private var Jump:Class;
		[Embed(source = "../mp3/throw.mp3")] private var Throw:Class;
		
		public function Player(x:Number, y:Number) 
		{
			super(x, y);
			
			spawn = new FlxPoint(x, y); //shouldn't FlxSprite have something like this?... I can't find anything
			
			this.maxVelocity.x = 120;
			this.maxVelocity.y = 210;
			this.acceleration.y = 200;
			this.drag.x = this.maxVelocity.x * 8;
			this.width = 10;
			this.height = 12;
			this.isHoldingBox = false;
			this.throwStrength = new FlxPoint(200, -25); //the velocity the box will have when thrown
			
			id = ++count;
			
			//for now only expect 2 players, so we can cheat a little here
			if (id == 1) {
				this.makeGraphic(width, height, 0xff11aa11);
				this.colour = 0xff11aa11;
			}
			else {
				this.makeGraphic(width, height, 0xffaa1111);
				this.colour = 0xffaa1111;
			}
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
		
		override public function update():void {
			this.acceleration.x = 0; //keep player from sliding if no button is currently pressed
			
			//TODO: define player controls when player object created. can't be bothered yet, so just check who we are with if statements
			//player1 controls
			if (id == 1) {
				//movement
				if (FlxG.keys.A) {
					this.acceleration.x = -this.maxVelocity.x * 8;
					this.facing = FlxObject.LEFT;
				}
				else if (FlxG.keys.D) {
					this.acceleration.x = this.maxVelocity.x * 8;
					this.facing = FlxObject.RIGHT;
				}
				//jumping
				if (FlxG.keys.W && this.isTouching(FlxObject.FLOOR)){
					this.velocity.y = -this.maxVelocity.y / 2;
					FlxG.play(Jump);
				}
				
				//box management
				if (FlxG.keys.S) {
					if (!isHoldingBox) {
						//pick up box in front of player... eventually? maybe we want to
						//keep it so you automatically pick up boxes you run into
					}
					else { //throw box
						FlxG.play(Throw);
						throwBox();
					}
				}
			}
			
			//player2 controls
			else if (id == 2) { 
				//movement
				if (FlxG.keys.LEFT) {
					this.acceleration.x = -this.maxVelocity.x * 8;
					this.facing = FlxObject.LEFT;
				}
				else if (FlxG.keys.RIGHT) {
					this.acceleration.x = this.maxVelocity.x * 8;
					this.facing = FlxObject.RIGHT;
				}
				
				//jumping
				if (FlxG.keys.UP && this.isTouching(FlxObject.FLOOR)){
					FlxG.play(Jump);
					this.velocity.y = -this.maxVelocity.y / 2;
				}
				
				//box management
				if (FlxG.keys.DOWN) {
					if (!isHoldingBox) {
						//...
					}
					else { //throw box
						FlxG.play(Throw);
						throwBox();
					}
				}
			}
			
			//update held box position
			if (isHoldingBox) {
				if (this.facing == FlxObject.LEFT)
					boxHeld.x = this.getMidpoint().x - this.width;
				else
					boxHeld.x = this.getMidpoint().x + this.width/2;
				
				boxHeld.y = this.getMidpoint().y - this.height;
				
			}
		}
		
	}

}