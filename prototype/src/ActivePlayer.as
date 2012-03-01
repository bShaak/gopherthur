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
		[Embed(source = "sprites/hop_right_225x15.png")] private var AnimateWalkRight:Class;
		[Embed(source = "sprites/jump_10x12.png")] private var AnimateJump:Class;
		[Embed(source = "sprites/idle_yellow_9x12.png")] private var AnimateIdleYellow:Class;
		[Embed(source = "sprites/idle_red_9x12.png")] private var AnimateIdleRed:Class;
		
		private var controlScheme:Controls;
		private var connection:Connection;
				
		public function ActivePlayer(x:Number, y:Number, id:int, color:int, connection:Connection, controlScheme:Controls) 
		{
			super(x, y, id, color);
			this.connection = connection;
			this.controlScheme = controlScheme;
		}
	
		override public function update():void {
			this.acceleration.x = 0; //keep player from sliding if no button is currently pressed
			
			//movement
			if (controlScheme.left()) {
				this.acceleration.x = -this.maxVelocity.x * 8;
				this.facing = FlxObject.LEFT;
				if ((!this._curAnim || this._curAnim.name != "hop_left") && this.isTouching(FlxObject.FLOOR)) {
					this.loadGraphic(AnimateWalkRight, true, true, 15, 15); //just reverse the one for moving to the right
					this.addAnimation("hop_left", [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, true);
					this.play("hop_left");
				}
			}
			else if (controlScheme.right()) {
				this.acceleration.x = this.maxVelocity.x * 8;
				this.facing = FlxObject.RIGHT;
				
				if ((!this._curAnim || this._curAnim.name != "hop_right") && this.isTouching(FlxObject.FLOOR)){ //load hopping animation
					this.loadGraphic(AnimateWalkRight, true, false, 15, 15);
					this.addAnimation("hop_right", [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, true); //remove first few frames to get smooth animation? not sure why
					//this.addAnimation("hop_right", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 8, true);
					this.play("hop_right");
				}
			}
			else { //player is not holding a directional movement key
				//TODO: have a slowing down/direction change animation (like mario sliding), which runs when the player is moving without hiting directional buttons
				if ((!this._curAnim || this._curAnim.name != "animated_idle_yellow") && this.isTouching(FlxObject.FLOOR))  {
					this.loadGraphic(AnimateIdleYellow, true, true, 9, 12);
					this.addAnimation("animated_idle_yellow", [0], 1, true); //it's just a 1 frame animation for now
					this.play("animated_idle_yellow");
				}
			}
			
			//handle in-air animations
			if (!this.isTouching(FlxObject.FLOOR)){ //&& (!this._curAnim || this._curAnim.name != "animate_jump")) {
				this.loadGraphic(AnimateJump, true, false, 10, 12);
				this.addAnimation("animate_jump", [0], 1, true); //it's just a 1 frame animation for now
				this.play("animate_jump");
			}
			
			//jumping
			if (controlScheme.jump() && this.isTouching(FlxObject.FLOOR)){
				this.velocity.y = -this.maxVelocity.y / 2;
				FlxG.play(Jump);
			}
			
			//box management
			if (controlScheme.drop()) {
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
			
			positionBox();
		}
	}
}