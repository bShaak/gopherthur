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
		private var descr:String;
		
		public function FlxButtonBig(X:Number = 0, Y:Number = 0, Label:String = null, OnClick:Function = null, arg:Object = null, description:String = null)
		{
			super(X, Y);
			loadGraphic(ImgBigButton, true, false, 160, 40);
			
			callback = OnClick;
			argument = arg;
			label = new FlxText(X, Y, 160, Label);
			labelOffset = new FlxPoint(0, 9); 
			descr = description;
		}		
		
		override public function update():void {
			updateButton(); //Basic button logic

			//Default button appearance is to simply update
			// the label appearance based on animation frame.
			if(label == null)
				return;
			switch(frame)
			{
				case HIGHLIGHT:	//Extra behavior to accomodate checkbox logic.
					label.alpha = 1.0;
					if ( descr != null ) {
						// write description for button next to it
					}
					break;
				case PRESSED:
					label.alpha = 0.5;
					label.y++;
					break;
				case NORMAL:
				default:
					label.alpha = 0.8;
					break;
			}
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