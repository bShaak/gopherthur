package 
{
	
	/**
	 * ...
	 * @author Braden
	 */
	
	 import org.flixel.*;
	import playerio.Connection;
	import flash.utils.Dictionary;
	import flash.events.*;
	
	public class Tutorial extends PlayState 
	{
		private var text:FlxText;
		private var bgColor:FlxSprite;
		private var index:int = 0;
		
		public function Tutorial() {
			super(Level.levelData , 0);
			index = 1;

		}
		
		override public function create():void {
			super.create();
			
			FlxG.pauseSounds();
			bgColor = new FlxSprite(0, 0)
			bgColor.makeGraphic(FlxG.width, FlxG.height, 0x99999999);
			add(bgColor);
			text = new FlxText(0, FlxG.height - 375, FlxG.width, "Welcome to SpringBox Tutorial. When you're ready, press ENTER");
			text.setFormat(null, 16, 0xFFFFFFFF, "center");
			add(text);
			
		}
		
		override public function update():void {
			super.update();
			
			//if user pressed enter, go to next stage of tutorial, otherwise do nothing
			if (FlxG.keys.justReleased("ENTER")) {
				index++;
				trace(index);
			
				switch(index) {
						case 2:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "The basic controls are W=jump, A=left, D=right, S=dash/throw. Try these out now. When you're done press ENTER");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 4:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "If you have a second player at the same computer, they can play with the arrow keys. Press Enter");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 6:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "Great, you can also jump higher if you hold down W. Try this out now");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 8:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "Dashing increases your speed briefly and also increases your pushing power. Press S or down to dash");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 10:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "Great, now that you know the controls, lets try collecting some juice boxes");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 12:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "You can throw juice boxes with S or down");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 14:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "In the classic game mode, collecting 3 juice boxes and bringing them back to your base wins the game");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 16:
							remove(text);
							text = new FlxText(0, FlxG.height - 375, FlxG.width, "Bring 3 juice boxes back to your base");
							text.setFormat(null, 16, 0xFFFFFFFF, "center");
							add(text);
							index++;
							break;
							
						case 18:
							remove(text);
							remove(bgColor);
							index++;
							break;
							
						default:
							trace("End of tutorial");
							trace(index);
					}
			}
			
		}
	}
	
	
}