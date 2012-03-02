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
		
		public function PowerUp(x:int, y:int, id:int, color:int) 
		{
			super(x, y);
			
			this.width = 12;
			this.height = 12;
			this.cnt = 0;
			this.id = id;
			this.makeGraphic(width, height, color);
		}
		
		override public function update():void {
			if (cnt < 30)
				this.visible = false;
			else if (cnt < 90)
				this.visible = true;
			else 
				cnt = 0;
			cnt++;
		}
		
		public function trigger(player:Player, game:PlayState):void {
			this.visible = false;
		}
	}

}