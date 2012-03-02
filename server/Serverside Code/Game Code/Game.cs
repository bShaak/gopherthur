using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace BoxSpring {
	//Player class. each player that join the game will have these attributes.
	public class Player : BasePlayer {
		public int x;
		public int y;
        public int vx;
        public int vy;
		public Player() {
            x = 0;
            y = 0;
            vx = 0;
            vy = 0;
		}
	}

    public class Box {
        public Player holder;

        public Player controller;
        public int messageId;
        public Boolean heldForPlayer = false;
        public Box()
        {
        }
    }

	[RoomType("BoxSpring")]
	public class GameCode : Game<Player> {
        private int playerCount = 2; // Number of players in the game. Hardcoded for now.
        private int boxCount = 5; // Hardcoded for now. This will be fixed.

        // Dictionaries for counting confirmations and triggering events upon confirmation
        private Dictionary<String, int> counts = new Dictionary<string, int>();
        private Dictionary<String, UponConfirm> actions = new Dictionary<string, UponConfirm>();
        private long startTime;

        private Box[] boxes;
        private Player masterController;

        private int messageCount = 0;

        private Boolean gameDone = false;

        // A function to be triggered when all players have confirmed a message
        private delegate void UponConfirm();

        /// <summary>
        /// Waits for every player to confirm a specified message
        /// </summary>
        /// <param name="message">The message to be confirmed</param>
        /// <param name="func">The function to trigger once all players have confirmed</param>
        private void allConfirm(String message, UponConfirm func) {
            //Broadcast("confirm", message);
            counts[message] = 0;
            actions[message] = func;

        }

        /// <summary>
        /// Switch the master controller. Note, right now this only works for 2 players.
        /// </summary>
        public void SwitchMasterController()
        {
            foreach (Player p in Players)
            {
                if (p != masterController)
                {
                    masterController = p;
                    return;
                }
            }
        }

		public override void GameStarted() {
			Console.WriteLine("Game is started");
            // Get all players to confirm that they have received their id and are ready to begin setup.
            allConfirm("readyToSetup", new UponConfirm(SetupGame));
		}

		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		public override void UserJoined(Player player) {
            Console.WriteLine("Player " + player.Id + " joined the room");
            // Notify the new player of their id
            player.Send("joined", player.Id);
		}

        public override void UserLeft(Player player) {
            Console.WriteLine("Player " + player.Id + " left the room. Ending game");
            foreach (Player p in Players)
            {
                p.Disconnect();
            }
        }

        public override bool AllowUserJoin(Player player) {
            int count = 0;
            foreach (Player p in Players) {
                count++;
            }
            if (count < playerCount)
            {
                return true;
            }
            return false;
        }


        private void SetupGame()
        {
            AddTimer(delegate {
                SwitchMasterController();
            }, 1000);
            Console.WriteLine("Starting setup");
            masterController = Players.GetEnumerator().Current;

            Broadcast("setupGame", playerCount);

            boxes = new Box[boxCount];
            for (int i = 0; i < boxCount; i++)
            {
                boxes[i] = new Box();
            }

            // Confirm that all players are ready to start adding the other players to the level
            allConfirm("readyToAddPlayers", new UponConfirm(AddPlayers));

        }

        /// <summary>
        /// Send a message for each player in the game with their start position and color.
        /// </summary>
        private void AddPlayers()
        {
            int i = 0;
            foreach (Player p in Players)
            {
                Console.WriteLine("Broadcasting add player " + p.Id);
                Broadcast("addPlayer", p.Id, i);
                i++;
            }
            
            // Confirm that every player has added every other player and start the game.
            allConfirm("readyToStart", new UponConfirm(StartGame));
        }

        /// <summary>
        /// Tells the players to begin playing
        /// </summary>
        private void StartGame()
        {
            startTime = DateTime.Now.Ticks;
            AddTimer(delegate
            {
                // Send the elapsed time in milliseconds.
                Broadcast("elapsed", (int) ((DateTime.Now.Ticks - startTime) / 10000));
            }, 100);

            Broadcast("startGame");
        }

        private void AddTimer(Action action)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Lookup a player by id
        /// </summary>
        /// <param name="id">The player's id</param>
        /// <returns></returns>
        public Player GetPlayer(int id)
        {
            foreach (Player p in Players)
            {
                if (p.Id == id)
                {
                    return p;
                }
            }
            return null;
        }

        private void RestartGame()
        {
            gameDone = false;
        }

		/// <summary>
		/// General message handler.
		/// </summary>
		/// <param name="player">The player who sent the message</param>
		/// <param name="message">The message</param>
        public override void GotMessage(Player player, Message message)
        {
            messageCount++;

            switch (message.Type)
            {
                case "confirm":
                    {
                        // TODO: Add error handling for invalid message being confirmed.
                        // Possibly make this solution more robust (ensure that each player can only confirm once).

                        String mes = message.GetString(0);
                        Console.WriteLine("Player " + player.Id + " confirming " + mes);

                        // Add another confirmation. If there are enough, trigger the action
                        if (++counts[mes] >= playerCount)
                        {
                            Console.WriteLine("All confirmation received for " + mes);
                            actions[mes]();
                        }
                        break;
                    }
                case "pos":
                    {
                        // Upon receiving a position message, update the game state and broadcast it.
                        int id = message.GetInt(0);
                        int x = message.GetInt(1);
                        int y = message.GetInt(2);
                        int vx = message.GetInt(3);
                        int vy = message.GetInt(4);

                        //Console.WriteLine(boxID + " " + boxX + " " + boxY);

                        /*player.x = x;
                        player.y = y;
                        player.vx = vx;
                        player.vy = vy;*/

                        foreach (Player p in Players)
                        {
                            if (p.Id != id)
                                p.Send("pos", id, x, y, vx, vy);
                        }
                        //Broadcast("pos", player.Id, x, y, vx, vy);
                        break;
                    }
                case "boxpos":
                    {
                        int id = message.GetInt(0);
                        int x = message.GetInt(1);
                        int y = message.GetInt(2);
                        int vx = message.GetInt(3);
                        int vy = message.GetInt(4);

                        Box b = boxes[id];

                        if ((b.heldForPlayer && player == b.controller) ||
                            (!b.heldForPlayer && player == masterController))
                        {
                            foreach (Player p in Players)
                            {
                                if (p != player)
                                    p.Send("boxpos", id, x, y, vx, vy);
                            }
                        }
                        break;
                    }
                case "boxpickup":
                    {
                        int playerId = message.GetInt(0);
                        int boxId = message.GetInt(1);

                        Box b = boxes[boxId];
                        Player p = GetPlayer(playerId);

                        if (b.heldForPlayer)
                        {
                            Console.WriteLine("Pickup action for box ignored");
                            p.Send("rejectpickup", playerId, boxId, messageCount);
                            return;
                        }

                        if (b.holder != null)
                        {
                            Console.WriteLine("Error, pickup message for box already held");
                            return;
                        }

                        b.holder = p;
                        b.heldForPlayer = true;
                        b.controller = p;
                        b.messageId = messageCount;

                        Console.WriteLine("Player " + playerId + " picks up " + boxId);
                        foreach (Player o in Players)
                        {
                            if (p != o)
                            {
                                o.Send("boxpickup", playerId, boxId, messageCount);
                            }
                        }
                        break;
                    }
                case "boxdrop":
                    {
                        int playerId = message.GetInt(0);
                        int boxId = message.GetInt(1);

                        Box b = boxes[boxId];
                        Player p = GetPlayer(playerId);

                        if (b.heldForPlayer)
                        {
                            Console.WriteLine("Pickup action for box ignored");
                            p.Send("rejectdrop", playerId, boxId, messageCount);
                            return;
                        }

                        if (b.holder == null)
                        {
                            Console.WriteLine("Error, drop message for box not held");
                            return;
                        }

                        b.holder = null;
                        b.heldForPlayer = true;
                        b.controller = p;
                        b.messageId = messageCount;

                        Console.WriteLine("Player " + playerId + " drops " + boxId);
                        foreach (Player o in Players)
                        {
                            if (p != o)
                            {
                                o.Send("boxdrop", playerId, boxId, messageCount);
                            }
                        }
                        break;
                    }

                case "confirmboxmes":
                    {
                        int messageId = message.GetInt(0);
                        int boxId = message.GetInt(1);
                        Box b = boxes[boxId];

                        // Successfully confirm the message.
                        if (messageId >= b.messageId)
                        {
                            Console.WriteLine("Player " + player.Id + " sucessfully confirms for box " + boxId);
                            b.messageId = -1;
                            b.heldForPlayer = false;
                            b.controller = null;
                        }
                        else
                        {
                            Console.WriteLine("Confirmation failed due to newer message");
                        }
                        break;
                    }
                case "gameover":
                    {
                        int winner = message.GetInt(0);
                        if (!gameDone)
                        {
                            gameDone = true;
                            Broadcast("gameover", winner);
                            allConfirm("gameover", new UponConfirm(RestartGame));
                        }
                        break;
                    }
                case "respawnplayer":
                    {
                        int id = message.GetInt(0);
                        int boxId = message.GetInt(1);
                        Player p = GetPlayer(id);
                        Box b = GetBox(boxId);

                        foreach (Player o in Players)
                        {
                            if (o != p)
                            {
                                o.Send("respawnplayer", id, boxId, messageCount);
                            }
                        }
                        b.holder = null;
                        b.heldForPlayer = true;
                        b.messageId = messageCount;
                        b.controller = p;

                        break;
                    }
            }
        }

        private Box GetBox(int boxId)
        {
            return boxes[boxId];
        }
	}
}
        
