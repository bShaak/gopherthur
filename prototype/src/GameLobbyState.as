package 
{
	/**
	 * ...
	 * @author Ras
	*/
	
	import org.flixel.*;
	import playerio.*;
	import PlayState;
	import flash.utils.Timer;
	import flash.events.*;
		
	public class GameLobbyState extends FlxState  
	{
		private var roomName:FlxInputText;
		private var errorMsg:FlxText;
		private var client:Client;
		private var level:Object;
		private var timer:Timer;
		private var roomContainer:FlxGroup;
		private var usedRoomNames:Array;
		
		public function GameLobbyState() {
			timer = new Timer(1500, 0); 
			timer.addEventListener(TimerEvent.TIMER, refreshGameRooms);
			roomContainer = new FlxGroup();
			usedRoomNames = new Array();
		}
		
		override public function create():void
		{
			PlayerIO.connect(
				Prototype.globalStage,					//Referance to stage
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
			
			client.multiplayer.listRooms("BoxSpring", { }, 5, 0, gameLobbyScreen);
			
			timer.start();
		}
		
		private function handleError(error:PlayerIOError):void {
			trace(error);
		}
		
		private function gameLobbyScreen(rooms:Array):void {
			var backgroundColor:FlxSprite = new FlxSprite(0,0);
			backgroundColor.makeGraphic(FlxG.width, FlxG.height, 0xFF0080C0);
			add(backgroundColor);
			
			var title:FlxText = new FlxText(0, 20, FlxG.width, "Game Lobby");
			title.setFormat (null, 25, 0xFFFFFFFF, "center");
			add(title);
			
			var roomNameLabel:FlxText = new FlxText(5, 65, 100, "Room Name:");
			roomNameLabel.setFormat(null, 16, 0x111111, "center");
			add(roomNameLabel);
			
			roomName = new FlxInputText(100, 78, 120, 20, " ", 0x000000, null, 20);
			add(roomName);
			
			var createGameBtn:FlxButton = new FlxButtonBig(350, 70, null, goToLevelSelectMenu); 
			add(createGameBtn);
			var buttonLabel:FlxText = new FlxText(380, 78, 100, "Create");
			buttonLabel.setFormat(null, 16, 0x333333, "center");
			add(buttonLabel);
			
			errorMsg = new FlxText(15, 125, 250, "Room name has to be at least one character long.");
			errorMsg.setFormat(null, 15, 0xff4444);
		}
		
		public function listGameRooms(rooms:Array):void {
			//trace("Container length b4: " + roomContainer.length);
			//trace("Rooms: " + rooms.length);
			
			var i:int = 0;
			var cnt:int = 0;
			
			if (rooms.length == 0 && roomContainer.length == 0)
				return;
			
			for (i = 0; i < rooms.length; i++) {
				for (var j:int = 0; j < roomContainer.length; j += 3) {
					if (rooms[i].id == roomContainer.members[j].text) {
						cnt++;
						break;
					}
				}
			}
			
			if ((rooms.length == cnt) && (roomContainer.length / 3 == cnt))
				return;
			
			//trace("RoomList: " + rooms.length + " " + roomContainer.length + " " + cnt);
			
			var roomSize:int = rooms.length;
			var offset:int = 135;
			
			if (roomContainer.length > 0) {
				//roomContainer.destroy();
				roomContainer.clear();
				//roomContainer = new FlxGroup();
			}
			
			for (i = 0; i < roomSize; i++) {
				/*for (var j:int = 0; j < usedRoomNames.length; j++) {
					if (rooms[i] == usedRoomNames[j])
				}*/
				
				if (rooms[i].onlineUsers < 2) {
					var availableGames:FlxText = new FlxText(20, offset, 150, rooms[i].id);
					availableGames.setFormat(null, 15, 0xffffff);
					roomContainer.add(availableGames);
						
					var joinBtn:FlxButton = new FlxButtonBig(350, offset, null, joinRoom, rooms[i]); 
					roomContainer.add(joinBtn);
						
					var joinLabel:FlxText = new FlxText(405, offset + 8, 50, "Join");
					joinLabel.setFormat(null, 16, 0x000000, "center");
					roomContainer.add(joinLabel);
						
					offset += 50;
				}
			}
			
			if (roomContainer != null && roomContainer.length > 0)
				add(roomContainer);
		}
		
		public function refreshGameRooms(event:TimerEvent):void {
			client.multiplayer.listRooms("BoxSpring", { }, 5, 0, listGameRooms);
		}
		
		public function joinRoom(selectedRoom:Object):void {
			var roomInfo:RoomInfo = RoomInfo(selectedRoom);
			timer.stop();
			
			//trace("RoomID: " + roomInfo.id);
			//trace("Level: " + roomInfo.data.levelName);
			
			if (roomInfo.data.levelName == "Forest")
				level = Level.levelData;
			else if (roomInfo.data.levelName == "Skyscraper")
				level = Level.skyscraper;
			else if (roomInfo.data.levelName == "Volcano")
				level = Level.volcano;
			else if (roomInfo.data.levelName == "Powerplant")
				level = Level.powerplant;
			
			(new ObtainConnectionState(level, roomInfo.id, client)).joinRoom();
			
			roomName.remove();
		}
		
		public function goToLevelSelectMenu():void {
			var rmName:String = roomName.text;
			rmName = rmName.substr(rmName.indexOf(" ") + 1); // remove leading space
			
			//trace("Room: " + rmName + " " + rmName.length);
			
			if (rmName.length > 0) {
				FlxG.switchState( new LevelSelect(PlayState.BOX_COLLECT, rmName, 1, 1, client));
				roomName.remove();
				timer.stop();
			}
			else 
				add(errorMsg);
		}
	}
}