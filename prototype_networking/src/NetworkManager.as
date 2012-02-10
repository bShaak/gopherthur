package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	
	import playerio.*;
	 
	public class NetworkManager 
	{
		private var connection:Connection;
		private var position
		
		public function NetworkManager(connection:Connection) 
		{
			this.connection = connection;
		}
		
		public function sendPosition(player:Player):void {
			connection.send("pos", player.ID, int(player.x), int(player.y));
		}
		
		public function subscribePositionUpdates():void {
			connection.add
		}
	}

}