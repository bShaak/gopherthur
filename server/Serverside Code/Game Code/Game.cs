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
        public bool charging;
        public bool shoved;
        public const int MAX_SPEED = 160;

		public Player() {
            x = 0;
            y = 0;
            vx = 0;
            vy = 0;
            charging = false;
            shoved = false;
		}
	}

    public class Box {
        public Player holder;

        // The player who locked the block.
        public Player controller;
        // The last message received for the block.
        public int messageId;
        // Is the block locked until a message is confirmed?
        public Boolean heldForPlayer = false;
        // Is the position for the block held for the controller?
        // If so, controller gets priority for position.
        public Boolean positionHeld = false;
        public Box()
        {
        }
    }

	[RoomType("BoxSpring")]
	public class GameCode : Game<Player> {
        private const String READY_TO_SETUP = "a";
        private const String JOINED = "b";
        private const String CONFIRM_BOX_MES = "c";
        private const String BOX_DROP = "d";
        private const String REJECT_DROP = "e";
        private const String BOX_PICKUP = "f";
        private const String REJECT_PICKUP = "g";
        private const String BOX_POS = "h";
        private const String POS = "i";
        private const String CONFIRM = "j";
        private const String ELAPSED = "k";
        private const String START_GAME = "l";
        private const String READY_TO_START = "m";
        private const String ADD_PLAYER = "n";
        private const String RESET = "o";
        private const String READY_TO_ADD_PLAYERS = "p";
        private const String SETUP_GAME = "q";
        private const String GAME_OVER = "r";
        private const String RESPAWN_PLAYER = "s";
        private const String CHARGE = "t";
        private const String SHOVE = "u";

        private int playerCount = 2; // Number of players in the game. Hardcoded for now.
        private int boxCount = 5; // Hardcoded for now. This will be fixed.

        // Dictionaries for counting confirmations and triggering events upon confirmation
        private Dictionary<String, int> counts = new Dictionary<string, int>();
        private Dictionary<String, UponConfirm> actions = new Dictionary<string, UponConfirm>();
        private long startTime;

        private Box[] boxes;
        private Player masterController;

        private int messageCount = 0;
        private int roundId = 0;
        private long seed = DateTime.Now.Ticks;

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
            // Don't switch if disabled.
            if (masterController == null)
            {
                return;
            }

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
            allConfirm(READY_TO_SETUP, new UponConfirm(SetupGame));
		}

		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		public override void UserJoined(Player player) {
            Console.WriteLine("Player " + player.Id + " joined the room");
            // Notify the new player of their id
            player.Send(JOINED, player.Id);
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
            // This is dumb, but the player iterator seems to work strangely.
            foreach (Player p in Players)
            {
                masterController = p;
                break;
            }
            AddTimer(delegate {
                SwitchMasterController();
            }, 1000);
            Console.WriteLine("Starting setup");

            Broadcast(SETUP_GAME, playerCount);

            boxes = new Box[boxCount];
            for (int i = 0; i < boxCount; i++)
            {
                boxes[i] = new Box();
            }

            // Confirm that all players are ready to start adding the other players to the level
            allConfirm(READY_TO_ADD_PLAYERS, new UponConfirm(AddPlayers));

        }

        private void RestartGame()
        {
            // This is dumb, but the player iterator seems to work strangely.
            foreach (Player p in Players)
            {
                masterController = p;
                break;
            }
            Broadcast(RESET);
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
                Broadcast(ADD_PLAYER, p.Id, i);
                i++;
            }
            
            // Confirm that every player has added every other player and start the game.
            allConfirm(READY_TO_START, new UponConfirm(StartGame));
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
                Broadcast(ELAPSED, (int) ((DateTime.Now.Ticks - startTime) / 10000));
            }, 100);

            Broadcast(START_GAME, (int) seed);
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

        public void timedUnlock(Box b, int message)
        {
            Timer t = null;
            t = AddTimer(delegate {
                t.Stop();
                Console.WriteLine("Unlock");
                if (message == b.messageId)
                {
                    Console.WriteLine("Triggered");
                    b.positionHeld = false;
                    b.controller = null;
                }
            }, 500);
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
                case CONFIRM:
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
                case POS:
                    {
                        // Upon receiving a position message, update the game state and broadcast it.
                        int x = message.GetInt(0);
                        int y = message.GetInt(1);
                        int vx = message.GetInt(2);
                        int vy = message.GetInt(3);

                        if (player.charging && Math.Abs(vx) <= Player.MAX_SPEED)
                            player.charging = false;
                        else if (player.shoved && Math.Abs(vx) <= Player.MAX_SPEED)
                            player.shoved = false;

                        int avCount = 0;
                        int boxMask = 0;

                        // Count the boxes for which the message should be sent.
                        for (int i = 0; i < boxCount; i++)
                        {
                            Box b = GetBox(i);

                            if ((b.positionHeld && player == b.controller) ||
                                (!b.positionHeld && player == masterController))
                            {
                                avCount++;
                                boxMask = boxMask | 1 << i;
                            }
                        }
                        object[] info = new object[6 + 4 * avCount];
                        info[0] = player.Id;
                        info[1] = x;
                        info[2] = y;
                        info[3] = vx;
                        info[4] = vy;
                        info[5] = boxMask;

                        int j = 6;
                        for (int i = 0; i < boxCount; i++)
                        {
                            Box b = GetBox(i);

                            if ((b.positionHeld && player == b.controller) ||
                                (!b.positionHeld && player == masterController))
                            {
                                uint os = 4 + 4 * checked((uint)i);
                                x = message.GetInt(0 + os);
                                y = message.GetInt(1 + os);
                                vx = message.GetInt(2 + os);
                                vy = message.GetInt(3 + os);

                                info[j++] = x;
                                info[j++] = y;
                                info[j++] = vx;
                                info[j++] = vy;

                            }
                        }

                        foreach (Player p in Players)
                        {
                            if (p != player)
                                p.Send(POS, info);
                        }
                        break;
                    }
                case BOX_POS:
                    {
                        /*
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
                                    p.Send(BOX_POS, id, x, y, vx, vy);
                            }
                        }
                         */
                        break;
                    }
                case BOX_PICKUP:
                    {
                        int playerId = message.GetInt(0);
                        int boxId = message.GetInt(1);

                        Box b = boxes[boxId];
                        Player p = GetPlayer(playerId);

                        if (b.heldForPlayer && b.controller != p)
                        {
                            Console.WriteLine("Pickup action for box ignored");
                            p.Send(REJECT_PICKUP, playerId, boxId, messageCount);
                            return;
                        }

                        if (b.holder != null)
                        {
                            Console.WriteLine("Error, pickup message for box already held");
                            return;
                        }

                        b.holder = p;
                        b.heldForPlayer = true;
                        b.positionHeld = true;
                        b.controller = p;
                        b.messageId = messageCount;
                        timedUnlock(b, messageCount);

                        Console.WriteLine("Player " + playerId + " picks up " + boxId);
                        foreach (Player o in Players)
                        {
                            o.Send(BOX_PICKUP, playerId, boxId, messageCount);
                        }
                        break;
                    }
                case BOX_DROP:
                    {
                        int playerId = message.GetInt(0);
                        int boxId = message.GetInt(1);
                        Boolean shouldThrow = message.GetBoolean(2);

                        Box b = boxes[boxId];
                        Player p = GetPlayer(playerId);

                        if (b.heldForPlayer && b.controller != p)
                        {
                            Console.WriteLine("Pickup action for box ignored. player: " + playerId + "box " + boxId);
                            p.Send(REJECT_DROP, playerId, boxId, messageCount);
                            return;
                        }

                        if (b.holder == null)
                        {
                            Console.WriteLine("Error, drop message for box not held");
                            return;
                        }

                        b.holder = null;
                        b.heldForPlayer = true;
                        b.positionHeld = true;
                        b.controller = p;
                        b.messageId = messageCount;
                        timedUnlock(b, messageCount);

                        Console.WriteLine("Player " + playerId + " drops " + boxId);
                        foreach (Player o in Players)
                        {
                            o.Send(BOX_DROP, playerId, boxId, messageCount, shouldThrow);
                        }
                        break;
                    }

                case CONFIRM_BOX_MES:
                    {
                        int messageId = message.GetInt(0);
                        int boxId = message.GetInt(1);
                        Box b = boxes[boxId];

                        // Successfully confirm the message.
                        if (messageId >= b.messageId && b.heldForPlayer && player != b.controller)
                        {
                            Console.WriteLine("Player " + player.Id + " sucessfully confirms for box " + boxId);
                            b.messageId = -1;
                            b.heldForPlayer = false;
                            //b.controller = null;
                        }
                        break;
                    }
                case GAME_OVER:
                    {
                        int winner = message.GetInt(0);
                        int round = message.GetInt(1);
                        Console.WriteLine("Gameover " + round + ", " + roundId);
                        if (round == roundId)
                        {
                            roundId++;
                            foreach (Box b in boxes)
                            {
                                b.heldForPlayer = false;
                                b.positionHeld = false;
                                b.controller = null;
                            }
                            masterController = null;
                            Broadcast(GAME_OVER, winner);
                            allConfirm(GAME_OVER, new UponConfirm(RestartGame));
                        }
                        break;
                    }
                case RESPAWN_PLAYER:
                    {
                        int id = message.GetInt(0);
                        int boxId = message.GetInt(1);
                        Player p = GetPlayer(id);
                        Box b = GetBox(boxId);

                        foreach (Player o in Players)
                        {
                            if (o != p)
                            {
                                o.Send(RESPAWN_PLAYER, id, boxId, messageCount);
                            }
                        }
                        b.holder = null;
                        b.heldForPlayer = true;
                        b.positionHeld = true;
                        b.messageId = messageCount;
                        b.controller = p;
                        timedUnlock(b, messageCount);

                        break;
                    }
                case CHARGE:
                    {
                        Console.WriteLine("Charge msg");

                        int velocity1 = message.GetInt(0);
                        Player player2 = GetPlayer(message.GetInt(1));
                        
                        if (player.shoved || player2.shoved)
                            return;
                        //timer.Enabled=true;

                        int velocity2 = message.GetInt(2);

                        if (Math.Abs(velocity1) > Math.Abs(velocity2))
                        {
                            player2.shoved = true;
                            Broadcast(SHOVE, player.Id, player2.Id);
                        }
                        else
                        {
                            player.shoved = true;
                            Broadcast(SHOVE, player2.Id, player.Id);
                        }
                        
                        //player2.vx = message.GetInt(2);
                        
                        //Broadcast(SHOVE, player.Id, player2.Id);

                        Console.WriteLine(player.Id + " " + velocity1 + " " + player2.Id + " " + velocity2);

                        //player.charging = true;
                        //player.vx = velocity1;

                        /*

                        if (player2.charging)
                        {
                            if (Math.Abs(player.vx) > Math.Abs(player2.vx))
                                Broadcast(SHOVE, player.Id, player2.Id);
                            else
                                Broadcast(SHOVE, player2.Id, player.Id);
                            
                            player.charging = false;
                            player2.charging = false;
                        }*/

                        /*ScheduleCallback(delegate
                        {
                            Console.WriteLine("Firing event");
                            if (player.charging)
                                Broadcast(SHOVE, player.Id, player2.Id);
                            else if (player2.charging)
                                Broadcast(SHOVE, player2.Id, player.Id);

                            player.charging = false;
                            player2.charging = false;
                        }, 25);*/

                        break;   
                    }
            }
        }

        // This timer allows for a small time gap between arrival of CHARGE messages from both players
        /*private static void OnTimedEvent(Player p1, Player p2, GameCode gc)
        {
            Console.WriteLine("Firing event");
            if (p1.charging)
                gc.Broadcast(SHOVE, p1.Id, p2.Id);
            else if (p2.charging)
                gc.Broadcast(SHOVE, p2.Id, p1.Id);

            p1.charging = false;
            p2.charging = false;
            gc.timer.Enabled = false;
        }*/

        private Box GetBox(int boxId)
        {
            return boxes[boxId];
        }
	}
}
        
