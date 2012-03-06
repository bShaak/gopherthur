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

		public function MultiplayerPlayState(data:Object, goal:int, connection:Connection, playerId:int, playerCount:int) {
			super(data, goal);

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
			connection.addMessageHandler(MessageType.ADD_PLAYER, addPlayer);
			connection.addMessageHandler(MessageType.START_GAME, startGame);
			connection.addMessageHandler(MessageType.POS, handlePositionMessage);
			connection.addMessageHandler(MessageType.BOX_PICKUP, handleBoxPickupMessage);
			connection.addMessageHandler(MessageType.BOX_DROP, handleBoxDropMessage);
			connection.addMessageHandler(MessageType.REJECT_PICKUP, handleRejectPickupMessage);
			connection.addMessageHandler(MessageType.REJECT_DROP, handleRejectDropMessage);
			connection.addMessageHandler(MessageType.BOX_POS, handleBoxPosMessage);
			connection.addMessageHandler(MessageType.GAME_OVER, handleGameOverMessage);
			connection.addMessageHandler(MessageType.RESPAWN_PLAYER, handleRepawnPlayerMessage);
			connection.addMessageHandler(MessageType.RESET, handleResetMessage);
			connection.send(MessageType.CONFIRM, MessageType.READY_TO_ADD_PLAYERS);
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
				if (box.holder != null) {
					trace("Held by " + box.holder.id);
				}
				if (player.hasBox()) {
					trace("Player holding " + player.boxHeld);
				}
			} else {
				trace("box picked up", box.isAvailable());
			}
			
			connection.send(MessageType.CONFIRM_BOX_MES, messageId, box.id);
		}
		
		private function handleBoxDropMessage(m:Message):void {
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			var shouldThrow:Boolean = m.getBoolean(3);
			
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
			if (shouldThrow) {
				player.throwBox();
			} else {
				player.dropBox();
			}
			
			connection.send(MessageType.CONFIRM_BOX_MES, messageId, box.id);
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
			
			if (player.hasBox()) {
				if (player.boxHeld.id != box.id) {
					trace("Error: Received reject pickup message for box not held");
				} else {
					player.dropBox();
				}
			}
		}
		
		private function handleRejectDropMessage(m:Message):void {
			trace("*****************Reject drop message*****************");
			var player:Player = getPlayer(m.getInt(0));
			var box:Box = getBox(m.getInt(1));
			var messageId:int = m.getInt(2);
			
			if (messageId < box.lastMessage) {
				trace("Ignoring less recent message");
				return;
			}
			box.lastMessage = messageId;
			
			box.drop();
			player.dropBox();
			player.pickupBox(box);
		}
		
		private function handleBoxPosMessage(m:Message):void {
			/*
			var box:Box = getBox(m.getInt(0));
			var x:int = m.getInt(1);
			var y:int = m.getInt(2);
			var vx:int = m.getInt(3);
			var vy:int = m.getInt(4);
			box.x = x;
			box.y = y;
			box.velocity.x = vx;
			box.velocity.y = vy;
			*/
		}
		
		override protected function boxPickedup(player:Player, box:Box):void {
			super.boxPickedup(player, box);
			connection.send(MessageType.BOX_PICKUP, player.id, box.id);
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
			
			var boxMask:int = m.getInt(5);
			var j:int = 6;
			for (var i:int = 0; i < boxes.members.length; i++) {
				var box:Box = boxes.members[i];
				if (box != null && (boxMask & 1 << i)) {
					x = m.getInt(j++);
					y = m.getInt(j++);
					vx = m.getInt(j++);
					vy = m.getInt(j++);
					box.x = x;
					box.y = y;
					box.velocity.x = vx;
					box.velocity.y = vy;
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
			var playerIndex:int = m.getInt(1);
			var activePlayer:Boolean = id == playerId;

			var x:int = levelData.startInfo[playerIndex].x;
			var y:int = levelData.startInfo[playerIndex].y;
			var color:int = levelData.startInfo[playerIndex].color;
			var walkAnimation:Class = levelData.startInfo[playerIndex].walkAnimation;
			
			// Create the new player.
			var player:Player;
			
			if (activePlayer) {
				player = new ActivePlayer(x, y, id, color, connection, wasdControls, walkAnimation);
				currentPlayer = player;
			} else {
				player = new Player(x, y, id, color, walkAnimation);
			}
			players.add(player);
			var zone:Zone = new Zone(player.getSpawn().x - 50, player.getSpawn().y - 53, 100, 100, player);
			zone.makeGraphic(zone.width, zone.height, player.getColour() - 0x55000000);
			zones.add(zone);
			
			// If we have added every player, we are ready to start.
			if (players.length == playerCount) {
				connection.send(MessageType.CONFIRM, MessageType.READY_TO_START);
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
				var info:Array = [MessageType.POS, int(currentPlayer.x), int(currentPlayer.y), int(currentPlayer.velocity.x), int(currentPlayer.velocity.y)];
				for (var i:int = 0; i < boxes.members.length; i++) {
					var box:Box = boxes.members[i];
						if (box != null) {
						info.push(int(box.x));
						info.push(int(box.y));
						info.push(int(box.velocity.x));
						info.push(int(box.velocity.y));
					}
				}
				connection.send.apply(connection, info);
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
			resetGame();
			if (winner is ActivePlayer) {
				connection.send(MessageType.GAME_OVER, winner.id, roundId);
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
			connection.send(MessageType.CONFIRM, MessageType.GAME_OVER);
		}
		
		private function handleResetMessage(m:Message):void {
			roundId++;
		}
		
		override protected function respawnPlayer(player:Player):void {
			if (player is ActivePlayer) {
				if (player.hasBox()) {
					connection.send(MessageType.RESPAWN_PLAYER, player.id, player.boxHeld.id);
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
			connection.send(MessageType.CONFIRM_BOX_MES, messageCount, boxId);
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
		
		override protected function dropBoxesOnCollision(player:Player):void 
		{
			if (player.hasBox()) {
				var boxId:int = player.boxHeld.id;
				player.dropBox();
				connection.send(MessageType.BOX_DROP, player.id, boxId, false);
			}
		}
	}

}