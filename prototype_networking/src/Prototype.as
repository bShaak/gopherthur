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
	import flash.display.Stage;
	import flash.events.Event;
	
	[SWF(width = "640", height = "480", backgroundColor = "#000000")]
	
	public class Prototype extends FlxGame {
		public static var globalStage:Stage;
		
		public function Prototype() {
			super(320, 240, ObtainConnectionState, 2, 60, 30, true);
			Prototype.globalStage = stage;
			
			forceDebugger = true;
		}
		
		override protected function create(FlashEvent:Event):void
        {
            super.create(FlashEvent);
            stage.removeEventListener(Event.DEACTIVATE, onFocusLost);
            stage.removeEventListener(Event.ACTIVATE, onFocus);
        }
		
	}

}