package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	
	import playerio.*;
	import org.flixel.*;
	
	public class ActivePlayer extends Player 
	{
		private var controlScheme:int;
		private var intervalID:int; //ras
		
		//these will move to Player eventually, when the controls go there
		protected var jumpKeyHeld:Boolean;		
		protected var jumpTimer:Number;
		
		//private var connection:Connection;
				
		public function ActivePlayer(x:Number, y:Number, id:int, color:int, connection:Connection, controlScheme:int) 
		{
			super(x, y, id, color);
			this.connection = connection;
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
						var boxId:int = boxHeld.id;
						throwBox();
						if (connection != null) {
							connection.send("boxdrop", id, boxId);
						}
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
			
			positionBox();
		}
	}
}