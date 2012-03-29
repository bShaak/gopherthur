package 
{
	
	/**
	 * Overloading FlxButton class in order to increase the size of buttons.
	 * @author Ras
	 */
	
	import flash.events.MouseEvent;
	import org.flixel.*;
	 
	public class FlxButtonBig extends FlxButton
	{
		[Embed(source = "sprites/buttonLarge.png")] protected var ImgBigButton:Class;
		
		private var argument:Object;
		private var callback:Function;
		
		public function FlxButtonBig(X:Number = 0, Y:Number = 0, Label:String = null, OnClick:Function = null, arg:Object = null)
		{
			super(X, Y);
			loadGraphic(ImgBigButton, true, false, 160, 40);
			
			callback = OnClick;
			argument = arg;
			label = new FlxText(X, Y, 160, Label);
			labelOffset = new FlxPoint(0, 9); 
		}		
		
		override protected function onMouseUp(event:MouseEvent):void
		{
			if(callback == null || !exists || !visible || !active || (status != PRESSED))
				return;
			if(argument == null)
				callback();
			else
				callback(argument);
		}
	}
	
}