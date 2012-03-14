package  
{
	import org.flixel.FlxSprite;
	
	/**
	 * A class representing a power up.
	 * @author Jeremy Johnson
	 */
	public class PowerUp extends FlxSprite 
	{
		public var id:int;
		private var cnt:int;
		protected var clock:Clock;
		protected var respawnTime:int;
		public var used:Boolean;
		
		public function PowerUp(x:int, y:int, id:int, respawnTime:int, color:int, clock:Clock) 
		{
			super(x, y);
			
			this.clock = clock;
			this.width = 12;
			this.height = 12;
			this.cnt = 0;
			this.id = id;
			this.makeGraphic(width, height, color);
			this.respawnTime = respawnTime;
			
			used = false;
			immovable = true;
		}
		
		override public function update():void {
			if (!used) {
				if (cnt < 30)
					this.visible = false;
				else if (cnt < 90)
					this.visible = true;
				else 
					cnt = 0;
				cnt++;
			}
		}
		
		public function trigger(player:Player, game:PlayState):void {
			visible = false;
			used = true;
			if (respawnTime > 0) {
				clock.setTimeout(respawnTime, respawn);
			}
		}
		
		public function respawn():void {
			used = false;
			visible = true;
			cnt = 30;
		}
	}

}