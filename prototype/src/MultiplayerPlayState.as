package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	import playerio.*;
	import org.flixel.*;
	import flash.utils.*;
	
	public class MultiplayerPlayState extends PlayState 
	{
		private var connection:Connection;
		private var playerId:int;
		private var playerCount:int;
		private var currentPlayer:Player;
		private var intervalId:int;
		
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
			connection.addMessageHandler("boxpickup", handleBoxPickupMessage);
			connection.addMessageHandler("boxdrop", handleBoxDropMessage);
			connection.addMessageHandler("rejectpickup", handleRejectPickupMessage);
			connection.addMessageHandler("rejectdrop", handleRejectDropMessage);
			connection.addMessageHandler("boxpos", handleBoxPosMessage);

			connection.send("confirm", "readyToAddPlayers");
		}
		

		
		private function handleBoxPickupMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			
			trace("Received pickup message for player", player.id, "and box", box.id);

			box.drop();
			player.dropBox();
			if (!player.pickupBox(box)) {
				trace("Error: Failed to pickup box from message");
			} else {
				trace("box picked up", box.isAvailable());
			}
			
			connection.send("confirmboxmes", messageId, box.id);
		}
		
		private function handleBoxDropMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			
			trace("Received drop message for player", player.id, "and box", box.id);

			if (player.boxHeld.id != box.id) {
				trace("Error: Received drop message for box not held");
			} else {
				player.throwBox();
			}
			connection.send("confirmboxmes", messageId, box.id);
		}

		private function handleRejectPickupMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			
			if (player.boxHeld.id != box.id) {
				trace("Error: Received reject pickup message for box not held");
			} else {
				player.dropBox();
			}
		}
		
		private function handleRejectDropMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			
			box.drop();
			player.pickupBox(box);
		}
		
		private function handleBoxPosMessage(m:Message):void {
			var box:Box = getBox(m.getInt(0));
			var x:int = m.getInt(1);
			var y:int = m.getInt(2);
			var vx:int = m.getInt(3);
			var vy:int = m.getInt(4);
			box.x = x;
			box.y = y;
			box.velocity.x = vx;
			box.velocity.y = vy;
		}
		
		override protected function boxPickedup(player:Player, box:Box):void {
			super.boxPickedup(player, box);
			connection.send("boxpickup", player.id, box.id);
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

			var p:Player = getPlayer(id);
			p.x = x;
			p.y = y;
			p.velocity.x = vx;
			p.velocity.y = vy;
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
			var playerIndex:int = m.getInt(1);
			var activePlayer:Boolean = id == playerId;
			var x:int = startInfo[playerIndex].x;
			var y:int = startInfo[playerIndex].y;
			var color:int = startInfo[playerIndex].color;
			
			// Create the new player.
			var player:Player;
			
			if (activePlayer) {
				player = new ActivePlayer(x, y, id, color, connection, wasdControls);
				currentPlayer = player;
			} else {
				player = new Player(x, y, id, color);
			}
			players.add(player);
			var zone:Zone = new Zone(player.getSpawn().x - 50, player.getSpawn().y - 50, 100, 100);
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
			intervalId = setInterval(sendInfo, 20);
		}
		
		/**
		 * Broadcast all necessary info.
		 */
		private function sendInfo():void {
			connection.send("pos", currentPlayer.id, int(currentPlayer.x), int(currentPlayer.y), int(currentPlayer.velocity.x), int(currentPlayer.velocity.y));
			for each(var box:Box in boxes.members) {
				connection.send("boxpos", box.id, int(box.x), int(box.y), int(box.velocity.x), int(box.velocity.y));
			}
		}
		
		override protected function triggerPowerUp(powerUp:PowerUp, player:Player):void {
			super.triggerPowerUp(powerUp, player);
			
			// Note: Right now, the only powerup is speed boost which doesn't need to be sent over the network.
			// In the future, we will probably have ones that require being sent. This is where that should happen.
		}
	}

}