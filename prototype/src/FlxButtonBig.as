package 
{
	
	/**
	 * ...
	 * @author Ras
	 */
	
	import org.flixel.*;
	 
	public class FlxButtonBig extends FlxButton
	{
		[Embed(source="sprites/buttonLarge.png")] protected var ImgBigButton:Class;
		
		public function FlxButtonBig(X:Number = 0, Y:Number = 0, Label:String = null, OnClick:Function = null)
		{
			super(X, Y, Label, OnClick);
			loadGraphic(ImgBigButton,true,false,160,40);
		}		
	}
	
}