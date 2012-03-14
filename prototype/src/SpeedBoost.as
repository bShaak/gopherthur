package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	public class SpeedBoost extends PowerUp 
	{
		private const SPEED_FACTOR:Number = 1.7;
		
		private var player:Player;
		
		public function SpeedBoost(x:int, y:int, id:int, respawnTime:int, clock:Clock) 
		{
			super(x, y, id, respawnTime, 0xff00aaaa, clock);
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