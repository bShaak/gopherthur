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
		[Embed(source = "sprites/hop_right_225x15.png")] private var AnimateWalkRight:Class;
		[Embed(source = "sprites/jump_10x12.png")] private var AnimateJump:Class;
		[Embed(source = "sprites/idle_yellow_9x12.png")] private var AnimateIdleYellow:Class;
		[Embed(source = "sprites/idle_red_9x12.png")] private var AnimateIdleRed:Class;
		
		private var controlScheme:int;
		private var intervalID:int; //ras
				
		public function ActivePlayer(x:Number, y:Number, id:int, color:int, connection:Connection, controlScheme:int) 
		{
			super(x, y, id, color, connection);
			
			// Broadcast the position of the active player every 20ms
			if (connection != void) {
				startInterval();
			}
			this.controlScheme = controlScheme;
			activePlayer = true;  //ras
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
					if ((!this._curAnim || this._curAnim.name != "hop_left") && this.isTouching(FlxObject.FLOOR)) {
						this.loadGraphic(AnimateWalkRight, true, true, 15, 15); //just reverse the one for moving to the right
						this.addAnimation("hop_left", [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, true);
						this.play("hop_left");
					}
				}
				else if (FlxG.keys.D) {
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
					if (!this._curAnim || this._curAnim.name != "hop_left") {
						this.loadGraphic(AnimateWalkRight, true, true, 15, 15);
						this.addAnimation("hop_left", [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, true);
						this.play("hop_left");
					}
				}
				else if (FlxG.keys.RIGHT) {
					this.acceleration.x = this.maxVelocity.x * 8;
					this.facing = FlxObject.RIGHT;
					if (!this._curAnim || this._curAnim.name != "hop_right") { //load hopping animation
						this.loadGraphic(AnimateWalkRight, true, false, 15, 15);
						this.addAnimation("hop_right", [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, true);
						this.play("hop_right");
					}
				}
				else { //player is not holding a directional movement key
					//TODO: have a slowing down/direction change animation (like mario sliding), which runs when the player is moving without hiting directional buttons
					if (!this._curAnim || this._curAnim.name != "animated_idle_red") {
						this.loadGraphic(AnimateIdleRed, true, true, 9, 12);
						this.addAnimation("animated_idle_red", [0], 24, true); //it's just a 1 frame animation for now
						this.play("animated_idle_red");
					}
				}
				
				//handle in-air animations
				if (!this.isTouching(FlxObject.FLOOR)){ //&& (!this._curAnim || this._curAnim.name != "animate_jump")) {
					this.loadGraphic(AnimateJump, true, false, 10, 12);
					this.addAnimation("animate_jump", [0], 1, true); //it's just a 1 frame animation for now
					this.play("animate_jump");
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