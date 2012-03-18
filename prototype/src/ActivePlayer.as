package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	
	import playerio.*;
	import org.flixel.*;
	import flash.events.*;
	
	public class ActivePlayer extends Player 
	{
		private var intervalID:int; //ras
		
		//these will move to Player eventually, when the controls go there
		protected var jumpKeyHeld:Boolean;		
		protected var jumpTimer:Number;
		
		private var controlScheme:Controls;
		private var connection:Connection;

		public function ActivePlayer(x:Number, y:Number, id:int, color:int, connection:Connection, controlScheme:Controls, walkAnimation:Class) 
		{
			super(x, y, id, color, walkAnimation);
			this.connection = connection;
			this.controlScheme = controlScheme;
			
			jumpKeyHeld = false;
			jumpTimer = 0;
		}
	
		
		
		override public function update():void {
			super.update();
			this.acceleration.x = 0; //keep player from sliding if no button is currently pressed
			
			if ((isShoved || isSliding) && Math.abs(velocity.x) > MAX_SPEED)
				return;
			else if (isSliding && Math.abs(velocity.x) <= MAX_SPEED)
				stopSliding();
			else if (isShoved && Math.abs(velocity.x) <= MAX_SPEED) {
				isShoved = false;
				maxVelocity.x = MAX_SPEED;
			}
			
			//movement
			if (controlScheme.left()) {
				this.acceleration.x = -this.maxVelocity.x * 8;
				this.facing = FlxObject.LEFT;
			}
			else if (controlScheme.right()) {
				this.acceleration.x = this.maxVelocity.x * 8;
				this.facing = FlxObject.RIGHT;
			}
			
			//jumping -- handle in steps, for variable jump height
			if (controlScheme.jump() && this.isTouching(FlxObject.FLOOR)){
				this.velocity.y = -this.maxVelocity.y / 3;
				FlxG.play(Jump);
				jumpKeyHeld = true;
				jumpTimer = 0;
			}
			if (controlScheme.jump() && jumpKeyHeld && jumpTimer <= 0.35) {
				this.velocity.y = -this.maxVelocity.y / 3;
				jumpTimer += FlxG.elapsed;
			}
			if (!controlScheme.jump()) {
				jumpKeyHeld = false;
			}
			
			//box management
			if (controlScheme.drop()) {
				if (!isHoldingBox) {
					//pick up box in front of player... eventually? maybe we want to
					//keep it so you automatically pick up boxes you run into
					startSliding();	
					//velocity.x = -260;
				}
				else { //throw box
					FlxG.play(Throw);
					var boxId:int = boxHeld.id;
					throwBox();
					if (connection != null) {
						connection.send(MessageType.BOX_DROP, id, boxId, true);
					}
				}
			}
		}
	}
}