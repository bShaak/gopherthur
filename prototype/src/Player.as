package  
{
	/**
	 * ...
	 * @author rayk
	 */
	
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		private static const max_velocity_x:Number	= 120;
		private static const drag_x:Number 			= max_velocity_x * 8;
		private static const max_velocity_y:Number 	= 210;					//max fall speed
		private static const player_gravity:Number 	= 200; 					//constant acceleration in y direction
		
		private static const player_width:int = 10;
		private static const player_height:int = 12;
		
		private static var count:int = 0;
		
		private var id:int;
		
		private var isHoldingBox:Boolean;
		private var boxHeld:Box;
		
		private var spawn:FlxPoint;
		
		private var colour:int;
		
		public function Player(x:Number, y:Number) 
		{
			super(x, y);
			
			spawn = new FlxPoint(x, y);
			
			this.maxVelocity.x = max_velocity_x;
			this.maxVelocity.y = max_velocity_y;
			this.acceleration.y = player_gravity;
			this.drag.x = drag_x;
			this.width = player_width;
			this.height = player_height;
			this.isHoldingBox = false;
			
			count++;
			id = count;
			
			//for now only expect 2 players, set player-specific attributes accordingly
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
			
			if (!box.pickUp()) //try to pick it up
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
			
			this.boxHeld.velocity.y = -25;
			if (this.facing == FlxObject.LEFT)
				this.boxHeld.velocity.x = -200;
			else
				this.boxHeld.velocity.x = 200;
				
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
			this.drag.x = drag_x; //testing to see if i can get these blocks to be more effective by reducing drag while in contact with a block
			
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
				if (FlxG.keys.W && this.isTouching(FlxObject.FLOOR))
					this.velocity.y = -this.maxVelocity.y / 2;
				
				//box management
				if (FlxG.keys.S) {
					if (!isHoldingBox) {
						//pick up box in front of player
					}
					else { //throw box
						throwBox();
					}
				}
					
				/* relic from first game implementation
				//pushing
				if (FlxG.keys.S && distanceBetweenPlayers() < 15) {
					//figure out which direction to push
					var dir:int = 1;
					if (player1.x > player2.x)
						dir = -1; //push to left
					player2.velocity.y = -10;
					player2.velocity.x = 500 * dir;
				}
				*/
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
				if (FlxG.keys.UP && this.isTouching(FlxObject.FLOOR))
					this.velocity.y = -this.maxVelocity.y / 2;
				
				//box management
				if (FlxG.keys.DOWN) {
					if (!isHoldingBox) {
						//pick up box in front of player
					}
					else { //throw box
						throwBox();
					}
				}
			}
			
			//update held box
			if (isHoldingBox) {
				if (this.facing == FlxObject.LEFT) {
					boxHeld.x = this.getMidpoint().x - this.width;
				}
				else {
					boxHeld.x = this.getMidpoint().x + this.width/2;
				}
				
				boxHeld.y = this.getMidpoint().y - this.height;
				
			}
		}
		
	}

}