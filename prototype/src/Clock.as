package  
{
	/**
	 * A clock class for simple game timing. Note, in multiplayer games, we need to keep this synchronized.
	 * @author Jeremy Johnson
	 */
	
	import playerio.*;
	public class Clock 
	{
		public var elapsed:int = 0;
		public function Clock(connection:Connection) 
		{
			if (connection != null) {
				connection.addMessageHandler("elapsed", handleElapsedMessage);
			}
		}
		
		private function handleElapsedMessage(m:Message) : void {
			// Synchronize the clock with the server.
			elapsed = m.getInt(0);
		}
		
		/**
		 * Add more elapsed time to the timer.
		 * @param	t The time in seconds
		 */
		public function addTime(t:Number) : void {
			// convert the time to milliseconds and add it to the elapsed time.
			elapsed += Math.round(t * 1000);
		}
	}
}