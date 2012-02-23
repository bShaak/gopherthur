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

	[RoomType("BoxSpring")]
	public class GameCode : Game<Player> {
        private int playerCount = 2; // Number of players in the game. Hardcoded for now.

        // Dictionaries for counting confirmations and triggering events upon confirmation
        private Dictionary<String, int> counts = new Dictionary<string, int>();
        private Dictionary<String, UponConfirm> actions = new Dictionary<string, UponConfirm>();
        private long startTime;

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
			Console.WriteLine("Player " + player.Id + " left the room");
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
            Console.WriteLine("Starting setup");
            Broadcast("setupGame", playerCount);

            // Confirm that all players are ready to start adding the other players to the level
            allConfirm("readyToAddPlayers", new UponConfirm(AddPlayers));

        }

        /// <summary>
        /// Send a message for each player in the game with their start position and color.
        /// </summary>
        private void AddPlayers()
        {
            // Start positions and colors for levels. This should be in the level data, not hardcoded here.
            int[] startX = new int[] { 32 * 9, 32 * 1 };
            int[] startY = new int[] { 185, 185 };
            uint[] colors = new uint[] { 0xff11aa11, 0xffaa1111 };
            int i = 0;
            foreach (Player p in Players)
            {
                Console.WriteLine("Broadcasting add player " + p.Id);
                Broadcast("addPlayer", p.Id, startX[i], startY[i], colors[i]);
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
		/// General message handler.
		/// </summary>
		/// <param name="player">The player who sent the message</param>
		/// <param name="message">The message</param>
        public override void GotMessage(Player player, Message message)
        {
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
                        int x = message.GetInt(1);
                        int y = message.GetInt(2);
                        int vx = message.GetInt(3);
                        int vy = message.GetInt(4);
                        player.x = x;
                        player.y = y;
                        player.vx = vx;
                        player.vy = vy;
                        Broadcast("pos", player.Id, x, y, vx, vy);
                        break;
                    }
            }
        }
	}
}
