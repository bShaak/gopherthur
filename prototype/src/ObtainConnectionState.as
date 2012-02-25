package  
{
	/**
	 * A game state for when the player is connecting to player.io and finding another player.
	 * @author Jeremy Johnson
	 */
	import org.flixel.*;
	import playerio.*;
	
	public class ObtainConnectionState extends FlxState {
		
		private var playerId:int;
		private var connection:Connection;
		private var client:Client;
		
		override public function create():void
		{
			add(new FlxText(0, 0, 100, "Obtaining connection"));
			
			trace("Attempting to connect to player.io");
			PlayerIO.connect(
				Prototype.globalStage,								//Referance to stage
				"spring-box-subs29zgv0uqr24vblklca",	//Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")
				"public",							//Connection id, default is public
				"GuestUser",						//Username
				"",									//User auth. Can be left blank if authentication is disabled on connection
				null,								//Current PartnerPay partner.
				handleConnect,						//Function executed on successful connect
				handleError							//Function executed if we recive an error
			);
		}
		
		/**
		 * Join a room after connecting to player.io.
		 * @param	client
		 */
		private function handleConnect(client:Client):void {
			this.client = client;
			trace("Sucessfully connected to player.io");
				
			//Set developmentsever (Comment out to connect to your server online)
			client.multiplayer.developmentServer = "127.0.0.1:8184";
				
			getRoom();
		}
		
		/**
		 * Proceed with setting up a match after joining a room.
		 * @param	connection
		 */
		private function handleJoin(connection:Connection):void {
			trace("Sucessfully connected to the multiplayer server. Waiting for second player.");
			this.connection = connection;
			connection.addDisconnectHandler(handleDisconnect);
			connection.addMessageHandler("joined", registerId);
			connection.addMessageHandler("setupGame", setupGame);
			
		}
		
		/**
		 * Register the active player's id from the server.
		 * @param	m The id message.
		 */
		private function registerId(m:Message):void {
			playerId = m.getInt(0);
			trace("Ready to start");
			connection.send("confirm", "readyToSetup");
		}
		
		/**
		 * Switch to the game state to start playing
		 * @param	m The message to start the game with the number of players.
		 */
		private function setupGame(m:Message):void {
			trace("Game setting up");
			FlxG.switchState(new MultiplayerPlayState(PlayState.BOX_COLLECT, connection, playerId, m.getInt(0)));
		}
		
		/**
		 * Handle a disconnect from the server.
		 * TODO: Add error handling.
		 */
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		
		/**
		 * Handle an error from player.io
		 * TODO: Add error handling.
		 * @param	error The error.
		 */
		private function handleError(error:PlayerIOError):void{
			trace("Got", error);
		}
		
		/**
		 * Begin the process of finding the user a room.
		 */
		private function getRoom():void 
		{
			client.multiplayer.listRooms("BoxSpring", { }, 10, 0, joinRoom, function(e:PlayerIOError):void {
				trace("error");
				createRoom();
			});
		}
		
		/**
		 * Try to join a room from an array of rooms. If it fails, try to join the next in the array.
		 * If none of the rooms work, create a new room.
		 * @param	rooms
		 */
		private function joinRoom(rooms:Array) : void {
			if (rooms.length == 0) {
				createRoom();
				return;
			}
			
			var room:RoomInfo = rooms.pop();
			
			// Only try to join rooms with space.
			if (room.onlineUsers < 2) {
				trace("Attempting to join room" + room.id);
				client.multiplayer.joinRoom(room.id, { }, handleJoin, function(e:PlayerIOError):void {
					// If we fail in joining, try to join one of the other rooms.
					joinRoom(rooms);
				});
			} else {
				joinRoom(rooms);
			}
		}
		
		/**
		 * Create a new room and join it.
		 */
		private function createRoom() : void {
			trace("Creating room");
			//Create or join the room test
			client.multiplayer.createJoinRoom(
				null,								//Room id. If set to null a random roomid is used
				"BoxSpring",						//The game type started on the server
				true,								//Should the room be visible in the lobby?
				{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server
				{},									//User join data
				handleJoin,							//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
			trace("Here");
		}
	}

}