package  
{
	/**
	 * A clock class for simple game timing. Note, in multiplayer games, we need to keep this synchronized.
	 * @author Jeremy Johnson
	 */
	
	import flash.utils.Dictionary;
	import playerio.*;
	
	public class Clock 
	{

		public var elapsed:int = 0;
		
		private var timeouts:Array = new Array();
		
		public function Clock(connection:Connection) 
		{
			if (connection != null) {
				connection.addMessageHandler(MessageType.ELAPSED, handleElapsedMessage);
			}
		}
		
		private function handleElapsedMessage(m:Message) : void {
			// Synchronize the clock with the server.
			elapsed = m.getInt(0);
			checkTimeouts();
		}
		
		/**
		 * Add more elapsed time to the timer.
		 * @param	t The time in seconds
		 */
		public function addTime(t:Number) : void {
			// convert the time to milliseconds and add it to the elapsed time.
			elapsed += Math.round(t * 1000);
			
			checkTimeouts();
		}
		
		/**
		 * Set an event to trigger when elapsed > t.
		 * @param	t The time to trigger the callback.
		 * @param	callback The callback.
		 */
		public function setElapsedTimeout(t:Number, callback:Function):void {
			var cb:Object = new Object();
			cb.t = t;
			cb.callback = callback;
			
			timeouts.push(cb);
			timeouts.sortOn("t", Array.DESCENDING);
			checkTimeouts();
		}

		/**
		 * Set an event to trigger in t milliseconds.
		 * @param	t The delay before triggering.
		 * @param	callback The callback.
		 */
		public function setTimeout(t:Number, callback:Function):void {
			setElapsedTimeout(t + elapsed, callback);
		}
		
		private function checkTimeouts():void {
			while (timeouts.length > 0 && elapsed >= timeouts[timeouts.length - 1].t) {
				timeouts.pop().callback();
			}
		}
	}
}