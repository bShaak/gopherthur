package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	
	import playerio.*;
	import org.flixel.*;
	import flash.utils.setInterval;
	
	public class ActivePlayer extends Player 
	{
		private var controlScheme:int;
		public function ActivePlayer(x:Number, y:Number, id:int, color:int, connection:Connection, controlScheme:int) 
		{
			super(x, y, id, color, connection);
			
			// Broadcast the position of the active player every 20ms
			if (connection != void) {
				setInterval(sendPosition, 20);
			}
			this.controlScheme = controlScheme;
		}
	
		override public function update():void {
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

		/**
		 * Broadcast the position of the player
		 */
		private function sendPosition():void {
			connection.send("pos", id, int(x), int(y));
		}
	}

}