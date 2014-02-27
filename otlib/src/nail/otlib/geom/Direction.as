///////////////////////////////////////////////////////////////////////////////////
// 
//  Copyright (c) 2014 <nailsonnego@gmail.com>
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////////

package nail.otlib.geom
{
	import nail.errors.AbstractClassError;

	public class Direction
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _value : uint;
		private var _type : String;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function Direction(value:uint, type:String)
		{
			if (created)
			{
				throw new AbstractClassError(Direction);
			}
			
			_value = value;
			_type  = type;
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Public
		//--------------------------------------
		
		public function toString() : String
		{
			return _type;
		}
		
		//--------------------------------------
		// Getters / Setters
		//--------------------------------------
		
		public function get value() : uint
		{
			return _value ;
		}
		
		public function get type() : String
		{
			return _type;
		}
		
		//----------------------------------------------------
		//
		// STATIC
		//
		//----------------------------------------------------
		
		static private var created : Boolean;
		
		static public const NORTH : Direction = new Direction(0, "north");
		static public const EAST : Direction = new Direction(1, "east"); 
		static public const SOUTH : Direction = new Direction(2, "south");
		static public const WEST : Direction = new Direction(3, "west");
		static public const SOUTHWEST : Direction = new Direction(4, "southwest");
		static public const SOUTHEAST : Direction = new Direction(5, "southeast");
		static public const NORTHWEST : Direction = new Direction(6, "northwest");
		static public const NORTHEAST : Direction = new Direction(7, "northeast");
		
		// lock class
		{
			created = true;
		}
		
		//--------------------------------------
		// Static Public
		//--------------------------------------
		
		static public function toDirection(value:uint) : Direction
		{
			switch (value)
			{
				case 0:
					return NORTH;
					
				case 1:
					return EAST;
					
				case 2:
					return SOUTH;
					
				case 3:
					return WEST;
					
				case 4:
					return SOUTHWEST;
					
				case 5:
					return SOUTHEAST;
					
				case 6:
					return NORTHWEST;
					
				case 7:
					return NORTHEAST;
			}
			return null;
		}
	}
}
