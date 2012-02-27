package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	public class SpeedBoost extends PowerUp 
	{
		private const SPEED_FACTOR:Number = 1.7;
		
		private var clock:Clock;
		private var player:Player;
		
		public function SpeedBoost(x:int, y:int, id:int, clock:Clock) 
		{
			super(x, y, id, 0xff00aaaa);
			this.clock = clock;
			immovable = false;
		}
	
		override public function trigger(player:Player, game:PlayState):void {
			super.trigger(player, game);
			
			this.player = player;
			
			trace("Speed boost for player", player.id);
			
			player.maxVelocity.x *= SPEED_FACTOR;
			player.drag.x *= SPEED_FACTOR;
		
			clock.setTimeout(5000, untrigger);
		}
		
		private function untrigger():void {
			trace("Speed boost ended");
			player.maxVelocity.x /= SPEED_FACTOR;
			player.drag.x /= SPEED_FACTOR;
		}
	}
}