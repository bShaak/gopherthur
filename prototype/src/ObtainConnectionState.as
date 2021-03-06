package  
{
	/**
	 * A game state for when the player is connecting to player.io and finding another player.
	 * @author Jeremy Johnson
	 */
	import org.flixel.*;
	import playerio.*;
	import GameLobbyState;
	
	public class ObtainConnectionState extends FlxState {
		private static const MAX_ATTEMPTS:int = 10;
		private var playerId:int;
		private var connection:Connection;
		private var client:Client;
		private var gameJoined:Boolean;
		private var attemptCount:int;
		private var consolePos:int = 10; 
		private var ip:FlxInputText;
		private var startButton:FlxButton;
		private var connectMsg:FlxText;
		private var levelSelected:Object;
		private var roomName:String;
		private var seed:int;
		
		public function ObtainConnectionState(data:Object, rmName:String, cl:Client) {
			levelSelected = data;
			roomName = rmName;
			client = cl;
		}
		
		override public function create():void
		{
			this.gameJoined = false;
			this.attemptCount = 0;
			var backgroundColor:FlxSprite = new FlxSprite(0, 0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0x000000);
			add(backgroundColor);
			
			getRoom();
		}
		
		private function printMes(mes:String):void {
			connectMsg = new FlxText(10, consolePos, 300, mes);
			connectMsg.setFormat(null, 14);
			consolePos += 20;
			add(connectMsg);
		}
		
		/**
		 * Proceed with setting up a match after joining a room.
		 * @param	connection
		 */
		private function handleJoin(connection:Connection):void {
			trace("Sucessfully connected to the multiplayer server. Waiting for second player.");
			printMes("Waiting for a second player . . .");
			this.connection = connection;
			connection.addDisconnectHandler(handleDisconnect);
			connection.addMessageHandler(MessageType.JOINED, registerId);
			connection.addMessageHandler(MessageType.SETUP_GAME, setupGame);
		}
		
		/**
		 * Register the active player's id from the server.
		 * @param	m The id message.
		 */
		private function registerId(m:Message):void {
			playerId = m.getInt(0);
			seed = m.getInt(1);
			trace("Ready to start");
			connection.send(MessageType.CONFIRM, MessageType.READY_TO_SETUP);
		}
		
		/**
		 * Switch to the game state to start playing
		 * @param	m The message to start the game with the number of players.
		 */
		private function setupGame(m:Message):void {
			trace("Game setting up");
			gameJoined = true;

			FlxG.switchState(new MultiplayerPlayState(levelSelected, PlayState.BOX_COLLECT, connection, playerId, seed, m.getInt(0)));
		}
		
		/**
		 * Handle a disconnect from the server.
		 */
		private function handleDisconnect():void {
			trace("disconnect", gameJoined);
			if (gameJoined) {
				FlxG.switchState(new MultiplayerErrorState("Sorry, you got disconnected from the game."));
			} else {
				if (attemptCount < MAX_ATTEMPTS) {
					getRoom();
				} else {
					FlxG.switchState(new MultiplayerErrorState("Sorry, something went wrong finding you a game."));
				}
			}
		}
		
		/**
		 * Handle an error from player.io
		 * TODO: Add error handling.
		 * @param	error The error.
		 */
		private function handleError(error:PlayerIOError):void{
			trace(error);
		}
		
		/**
		 * Begin the process of finding the user a room.
		 */
		private function getRoom():void 
		{
			attemptCount++;
			
			if (GameLobbyState.testVersion) {
				client.multiplayer.listRooms("BoxSpring", { }, 10, 0, joinAvailableRoom, function(e:PlayerIOError):void {
					trace("Error finding rooms.");
					joinCreateRoom();
				});
			}
			else	
				joinCreateRoom();
		}
		
		/**
		 * Try to join a room from an array of rooms. If it fails, try to join the next in the array.
		 * If none of the rooms work, create a new room.
		 * @param	rooms
		 */
		private function joinAvailableRoom(rooms:Array) : void {
			if (gameJoined) {
				return;
			}
			
			if (rooms.length == 0) {
				joinCreateRoom();
				return;
			}
			
			var room:RoomInfo = rooms.pop();
			
			// Only try to join rooms with space.
			if (room.onlineUsers < 2) {
				trace("Attempting to join room" + room.id);
				//client.multiplayer.joinRoom(room.id, { }, handleJoin, function(e:PlayerIOError):void {
				// If we fail in joining, try to join one of the other rooms.
				if (GameLobbyState.testVersion) {
					roomName = room.id;
					joinCreateRoom();
				}
				else {
					joinCreateRoom();
				}
			}
		}
		
		/**
		 * Create a new room and join it.
		 */
		public function joinCreateRoom() : void {
			if (gameJoined) {
				return;
			}
			printMes("Creating room \"" + roomName + "\"");
			//Create or join the room test
			client.multiplayer.createJoinRoom(
				roomName,							//Room id. If set to null a random roomid is used
				"BoxSpring",						//The game type started on the server
				true,								//Should the room be visible in the lobby?
				{levelName: levelSelected.name},	//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{},									//User join data
				handleJoin,							//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
	}
}