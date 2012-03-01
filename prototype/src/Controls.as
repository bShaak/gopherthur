package  
{
	/**
	 * Simple class for abstracting over the control scheme.
	 * @author Jeremy Johnson
	 */
	import org.flixel.FlxG;
	
	public class Controls 
	{
		private var jumpK:String;
		private var dropK:String;
		private var leftK:String;
		private var rightK:String;

		private var map:Object = new Object();
		public function Controls(up:String, left:String, down:String, right:String) 
		{
			this.jumpK = up;
			this.dropK = down;
			this.leftK = left;
			this.rightK = right;
		}
		
		/**
		 * @return True if the key representing jump is pressed.
		 */
		public function jump():Boolean {
			return FlxG.keys[jumpK];
		}
		
		/**
		 * @return True if the key representing drop is pressed.
		 */
		public function drop():Boolean {
			return FlxG.keys[dropK];
		}
		
		/**
		 * @return True if the key representing left is pressed.
		 */
		public function left():Boolean {
			return FlxG.keys[leftK];
		}
		
		/**
		 * @return True if the key representing right is pressed.
		 */
		public function right():Boolean {
			return FlxG.keys[rightK];
		}
	}

}