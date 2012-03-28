package 
{
	
	/**
	 * ...
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
			super(X, Y, Label, OnClick);
			loadGraphic(ImgBigButton, true, false, 160, 40);
			
			callback = OnClick;
			argument = arg;
		}		
		
		override protected function onMouseUp(event:MouseEvent):void
		{
			//trace("Here");
			if(callback == null || !exists || !visible || !active || (status != PRESSED))
				return;
			//trace("Here2");
			if(argument == null)
				onUp();
			else
				onUp(argument);
		}
	}
	
}