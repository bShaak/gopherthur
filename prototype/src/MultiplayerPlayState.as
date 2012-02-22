package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	import playerio.*;
	public class MultiplayerPlayState extends PlayState 
	{
		private var connection:Connection;
		private var playerId:int;
		private var playerCount:int;
		private var currentPlayer:Player;
		
		public function MultiplayerPlayState(goal:int, connection:Connection, playerId:int, playerCount:int) {
			super(goal);
			this.connection = connection;
			this.playerId = playerId;
			this.playerCount = playerCount;
		}
		
		override protected function createPlayers():void {
			// Creation of players is done through event handlers in a multiplayer game.
			return;
		}

		override protected function afterCreate():void {
			// Set up the message handlers and confirm that we are ready to add players.
			connection.addMessageHandler("addPlayer", addPlayer);
			connection.addMessageHandler("startGame", startGame);
			connection.addMessageHandler("pos", handlePositionMessage);
			connection.send("confirm", "readyToAddPlayers");
		}
		
		/**
		 * Update a players position from a position message.
		 * @param	m The position message
		 */
		private function handlePositionMessage(m:Message):void {
			var id:int = m.getInt(0);
			var x:int = m.getInt(1);
			var y:int = m.getInt(2);
			var vx:int = m.getInt(3);
			var vy:int = m.getInt(4);


			// This is an awful way of finding the player by id and should be fixed.
			for (var i:int = 0; i < players.members.length; i++) {
				var p:Player = players.members[i];
				
				// Update the position of the correct player.
				// This needs to be done in a much more intellegent way.
				if (p.id == id) {
					p.x = x;
					p.y = y;
					p.velocity.x = vx;
					p.velocity.y = vy;
				}
			}
		}
		
		override protected function createClock() : Clock {
			return new Clock(connection);
		}
		
		/**
		 * Add a player to the game based on a add message
		 * @param	m The message
		 */
		private function addPlayer(m:Message):void {
			var id:int = m.getInt(0);
			var x:int = m.getInt(1);
			var y:int = m.getInt(2);
			var color:int = m.getUInt(3);
			var activePlayer:Boolean = id == playerId;
			
			// Create the new player.
			var player:Player;
			
			if (activePlayer) {
				player = new ActivePlayer(x, y, id, color, connection, 1);
			} else {
				player = new Player(x, y, id, color, connection);
			}
			players.add(player);
			var zone:Zone = new Zone(player.getSpawn().x - 25, player.getSpawn().y - 25, 50, 50);
			zone.makeGraphic(zone.width, zone.height, player.getColour() - 0xbb000000);
			zones.add(zone);
			add(zone);
			
			// If we have added every player, we are ready to start.
			if (players.length == playerCount) {
				connection.send("confirm", "readyToStart");
			}
		}
		
		/**
		 * Begin the game after receiving a start message.
		 * @param	m
		 */
		private function startGame(m:Message):void {
			running = true;
		}
	}

}