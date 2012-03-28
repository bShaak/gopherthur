package  
{
	/**
	 * Simple seeded pseudorandom number generator. Implements XOR shift.
	 * @author Jeremy Johnson
	 */
	public class PseudoRandom 
	{
		private var seed:int;
		public function PseudoRandom(seed:int) 
		{
			this.seed = seed;
		}
		
		public function random():Number
		{
		   seed ^= (seed << 21);
		   seed ^= (seed >>> 35);
		   seed ^= (seed << 4);
		   if (seed < 0) return -seed / int.MAX_VALUE;
		   return seed / int.MAX_VALUE;
		}
	}
}