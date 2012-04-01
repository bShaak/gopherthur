package  
{
	/**
	 * ...
	 * @author Jen
	 */
	
	import org.flixel.*;
	 
	public class Acid extends SBSprite
	{
		[Embed(source = "/sprites/acid_96x400.png")] private var AcidAnimation:Class;
		
		public function Acid(x:int, y:int, width:int, height:int) 
		{
			super(x, y);
			
			//this.makeGraphic(width, height, 0x9900CC00);
			this.loadGraphic(AcidAnimation, true, true, 96, 400);
			
			this.addAnimation("acidfall", [0, 1, 2, 3, 4, 5], 8, true);
			this.play("acidfall");
		}
		
	}

}