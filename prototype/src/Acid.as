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
		
		private const ACID_GRAPHIC_WIDTH:int = 96;
			
		public function Acid(x:int, y:int, width:int, height:int, acidFlows:FlxGroup) 
		{
			super(x, y);
			
			this.makeGraphic(width, height, 0x0000CC00); //see through, just sets up the collision bounds as a rectangle
			
			//add the graphic, which is bigger than the actual collision area
			var acidFlow:FlxSprite = new FlxSprite(x - (ACID_GRAPHIC_WIDTH - width)/2, y); //centre the acid flow graphic
			acidFlow.loadGraphic(AcidAnimation, true, true, 96, 400);
			acidFlow.addAnimation("acidfall", [0, 1, 2, 3, 4, 5], 8, true);
			acidFlow.play("acidfall");
			acidFlows.add(acidFlow);
		}
		
	}

}