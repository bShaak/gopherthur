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
		private var roundId:int = 0;
		
		public function MultiplayerPlayState(goal:int, aLevel:String, connection:Connection, playerId:int, playerCount:int) {
			super(goal, aLevel);
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
			connection.addMessageHandler("gameover", handleGameOverMessage);
			connection.addMessageHandler("respawnplayer", handleRepawnPlayerMessage);
			connection.send("confirm", "readyToAddPlayers");
		}
		

		
		private function handleBoxPickupMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			
			if (messageId < box.lastMessage) {
				trace("Ignoring less recent message");
				return;
			}
			box.lastMessage = messageId;
			
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
			
			if (messageId < box.lastMessage) {
				trace("Ignoring less recent message");
				return;
			}
			box.lastMessage = messageId;
			trace("Received drop message for player", player.id, "and box", box.id);

			if (!player.hasBox()) {
				box.drop();
				player.pickupBox(box);
			} else if (player.boxHeld.id != box.id) {
				player.dropBox();
				box.drop();
				player.pickupBox(box);
			}
			player.throwBox();
			
			connection.send("confirmboxmes", messageId, box.id);
		}

		private function handleRejectPickupMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			
			if (messageId < box.lastMessage) {
				trace("Ignoring less recent message");
				return;
			}
			box.lastMessage = messageId;
			
			if (player.boxHeld.id != box.id) {
				trace("Error: Received reject pickup message for box not held");
			} else {
				player.dropBox();
			}
		}
		
		private function handleRejectDropMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			
			if (messageId < box.lastMessage) {
				trace("Ignoring less recent message");
				return;
			}
			box.lastMessage = messageId;
			
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
			var walkAnimation:Class = startInfo[playerIndex].walkAnimation;
			
			// Create the new player.
			var player:Player;
			
			if (activePlayer) {
				player = new ActivePlayer(x, y, id, color, connection, wasdControls, walkAnimation);
				currentPlayer = player;
			} else {
				player = new Player(x, y, id, color, walkAnimation);
			}
			players.add(player);
			var zone:Zone = new Zone(player.getSpawn().x - 50, player.getSpawn().y - 50, 100, 100, player);
			zone.makeGraphic(zone.width, zone.height, 0xffaa1111 - 0xbb000000);//player.getColour() - 0xbb000000);
			zones.add(zone);
			
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
			if (connection.connected) {
				connection.send("pos", currentPlayer.id, int(currentPlayer.x), int(currentPlayer.y), int(currentPlayer.velocity.x), int(currentPlayer.velocity.y));
				for each(var box:Box in boxes.members) {
					connection.send("boxpos", box.id, int(box.x), int(box.y), int(box.velocity.x), int(box.velocity.y));
				}
			}
		}
		
		override protected function triggerPowerUp(powerUp:PowerUp, player:Player):void {
			super.triggerPowerUp(powerUp, player);
			
			// Note: Right now, the only powerup is speed boost which doesn't need to be sent over the network.
			// In the future, we will probably have ones that require being sent. This is where that should happen.
		}
		
		/**
		 * Tell the server that a player has met the win conditions.
		 * @param	winner
		 */
		override protected function endGame(winner:Player):void {
			if (winner is ActivePlayer) {
				connection.send("gameover", winner.id, roundId);
			}
		}
		
		/**
		 * Reset the game upon receiving a game over message.
		 * @param	m
		 */
		private function handleGameOverMessage(m:Message):void {
			var winner:Player = getPlayer(m.getInt(0));
			winner.incrementScore();
			resetGame();
			roundId++;
		}
		
		override protected function respawnPlayer(player:Player):void {
			if (player is ActivePlayer) {
				if (player.hasBox()) {
					connection.send("respawnplayer", player.id, player.boxHeld.id);
				}
				super.respawnPlayer(player);
			}
		}
		
		/**
		 * Respawn a player from a message.
		 * @param	m
		 */
		protected function handleRepawnPlayerMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var boxId:int = m.getInt(1);
			var messageCount:int = m.getInt(2);
			if (player.boxHeld.id != boxId) {
				trace("Error, respawn message with incorrect box");
			}
			
			super.respawnPlayer(player);
			connection.send("confirmboxmes", messageCount, boxId);
		}
		
		override protected function checkGameOver():void {
			//for right now, just do nothing because this crashes the game in multiplayer
			/*
			for each (var player:Player in players.members) {
					if ( player.getScore() >= MAX_SCORE ) {
						
						FlxG.switchState( new GameOverState(mode, connection, playerId, playerCount));
					}
				}
			*/
			
		}
	}

}