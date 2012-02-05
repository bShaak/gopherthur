package  
{
	/**
	 * TODO: 
	 * - group platforms
	 * - I use both box/block to refer to the blocks. Should change that
	 * - inconsistent use of 'this' keyword
	 * - The whole pickup/drop system could be a lot cleaner I think.
	 * - Pretty much everything could be cleaned up.
	 * 
	 * @author rayk
	 */
	
	import org.flixel.*;
	[SWF(width = "640", height = "480", backgroundColor = "#000000")]
	
	public class Prototype extends FlxGame {	
		public function Prototype() {
			super(320, 240, PlayState, 2, 60, 30, true);
			forceDebugger = true;
		}
		
	}

}