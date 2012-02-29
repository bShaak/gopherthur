package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	
	import playerio.*;
	import org.flixel.*;
	import flash.utils.*;
	
	public class ActivePlayer extends Player 
	{
		
		private var controlScheme:int;
		private var intervalID:int; //ras
		
		//these will move to Player eventually, when the controls go there
		protected var jumpKeyHeld:Boolean;		
		protected var jumpTimer:Number;
		
		public function ActivePlayer(x:Number, y:Number, id:int, color:int, connection:Connection, controlScheme:int) 
		{
			super(x, y, id, color, connection);
			
			// Broadcast the position of the active player every 20ms
			if (connection != void) {
				startInterval();
			}
			this.controlScheme = controlScheme;
			activePlayer = true;  //ras
			
			jumpKeyHeld = false;
			jumpTimer = 0;
		}
	
		override public function update():void {
			super.update();
			this.acceleration.x = 0; //keep player from sliding if no button is currently pressed
			
			//TODO: define player controls when player object created. can't be bothered yet, so just check who we are with if statements
			//player1 controls
			if (controlScheme == 1) {
				//movement
				if (FlxG.keys.A) {
					this.acceleration.x = -this.maxVelocity.x * 8;
					this.facing = FlxObject.LEFT;
				}
				else if (FlxG.keys.D) {
					this.acceleration.x = this.maxVelocity.x * 8;
					this.facing = FlxObject.RIGHT;
				}
				
				//jumping -- handle in three steps, for variable jump height
				//NOTE i only have it set up for player 1 right now, to compare
				//with original jumping.
				if (FlxG.keys.W && this.isTouching(FlxObject.FLOOR)){
					this.velocity.y = -this.maxVelocity.y / 3;
					FlxG.play(Jump);
					jumpKeyHeld = true;
					jumpTimer = 0;
				}
				if (FlxG.keys.W && jumpKeyHeld && jumpTimer <= 0.3) {
					this.velocity.y = -this.maxVelocity.y / 3;
					jumpTimer += FlxG.elapsed;
				}
				if (!FlxG.keys.W) {
					jumpKeyHeld = false;
				}
				
				
				
				
				//box management
				if (FlxG.keys.S) {
					if (!isHoldingBox) {
						//pick up box in front of player... eventually? maybe we want to
						//keep it so you automatically pick up boxes you run into
					}
					else { //throw box
						FlxG.play(Throw);
						if (connection != void) {
							var vx:int;
							var vy:int;
							vy = this.throwStrength.y;
							if (this.facing == FlxObject.LEFT)
								vx = -this.throwStrength.x;
							else
								vx = this.throwStrength.x;
							trace("Throwing...");
							stopInterval();  // to avoid race conditions
							connection.send("throw", boxHeld.getBoxID(), vx, vy);  // this event needs to be sent ASAP
							startInterval();
						}
						throwBox();
					}
				}
			}
			
			//player2 controls
			else if (controlScheme == 2) { 
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

		override public function startInterval():void {   //ras 
			intervalID = setInterval(sendPosition, 20);
			trace("IntervalID: " + intervalID);
		}
		
		override public function stopInterval():void {  //ras
			clearInterval(intervalID);
		}
		
		override public function isActive():Boolean
		{
			return activePlayer;
		}
		
		/**
		 * Broadcast the position of the player
		 */
		private function sendPosition():void {
			if (!isHoldingBox) {
				//trace("Not holding");
				connection.send("pos", id, int(x), int(y), int(velocity.x), int(velocity.y), -1, -1, -1);
			}
			else {
				//trace("Holding");
				connection.send("pos", id, int(x), int(y), int(velocity.x), int(velocity.y), 
				boxHeld.getBoxID(), boxHeld.x, boxHeld.y);
			}
		}
	}

}