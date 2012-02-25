package  
{
	/**
	 * ...
	 * @author Jeremy Johnson
	 */
	import playerio.*;
	import org.flixel.*;
	
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
			connection.addMessageHandler("pickUp", handlePickUpMessage); //ras
			connection.addMessageHandler("throw", handleThrowMessage); //ras
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
			var boxID:int = m.getInt(5); //ras
			var boxX:int = m.getInt(6); //ras
			var boxY:int = m.getInt(7); //ras

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
					if (boxID != -1) {
						boxes.members[boxID].x = boxX;
						boxes.members[boxID].y = boxY;
						boxes.members[boxID].velocity.x = vx;
						boxes.members[boxID].velocity.y = vy;
					}
				}
			}
		}
		
		/**
		 * Another player picked up a box, the screen needs to be updated.
		 * @param	m message with box index
		 */
		private function handlePickUpMessage(m:Message):void { //ras
			var id:int = m.getInt(0);
			var x:int = m.getInt(1);
			var y:int = m.getInt(2);
			var vx:int = m.getInt(3);
			var vy:int = m.getInt(4);
			var facing:int = m.getInt(5);
			var boxID:int = m.getInt(6);
						
			var p:Player;
			for each(p in players.members) {
				if (p.id == id) {
					p.x = x;
					p.y = y;
					p.velocity.x = vx;
					p.velocity.y = vy;
					
					if (p.pickupBox(boxes.members[boxID])) {
						boxes.members[boxID].velocity.x = vx;
						boxes.members[boxID].velocity.y = vy;
						
						if (facing == FlxObject.LEFT)
							boxes.members[boxID].x = p.getMidpoint().x - p.width;
						else
							boxes.members[boxID].x = p.getMidpoint().x + p.width/2;
				
						boxes.members[boxID].y = p.getMidpoint().y - p.height;
						
						trace("HandlePickUp");
					}
				}
			}
		}
		
		/**
		 * Another player threw a box, the screen needs to be updated.
		 * @param	m message with throw parameters
		 */
		private function handleThrowMessage(m:Message):void {  //ras
			trace("***Here throw");
			var id:int = m.getInt(0);
			var boxID:int = m.getInt(1);
			var vx:int = m.getInt(2);
			var vy:int = m.getInt(3);
					
			var p:Player;
			for each(p in players.members) {
				if (p.id == id) {
					p.dropBox();
					
					boxes.members[boxID].velocity.x = vx;
					boxes.members[boxID].velocity.y = vy;
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