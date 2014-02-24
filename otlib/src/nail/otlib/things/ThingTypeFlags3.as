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

package nail.otlib.things
{
	import nail.errors.AbstractClassError;

	/**
	 * The ThingTypeFlags3 class defines the valid constant values for the client versions 10.10+
	 */
	public final class ThingTypeFlags3
	{
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function ThingTypeFlags3()
		{
			throw new AbstractClassError(ThingTypeFlags3);
		}
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static public const GROUND : uint = 0x00;
		
		static public const GROUND_BORDER : uint = 0x01;
		
		static public const ON_BOTTOM : uint = 0x02;
		
		static public const ON_TOP : uint = 0x03;
		
		static public const CONTAINER : uint = 0x04;
		
		static public const STACKABLE : uint = 0x05;
		
		static public const FORCE_USE : uint = 0x06;
		
		static public const MULTI_USE : uint = 0x07;
		
		static public const WRITABLE : uint = 0x08;
		
		static public const WRITABLE_ONCE : uint = 0x09;
		
		static public const FLUID_CONTAINER : uint = 0x0A;
		
		static public const FLUID : uint = 0x0B;
		
		static public const UNPASSABLE : uint = 0x0C;
		
		static public const UNMOVEABLE : uint = 0x0D;
		
		static public const BLOCK_MISSILE : uint = 0x0E;
		
		static public const BLOCK_PATHFIND : uint  = 0x0F;
		
		static public const NO_MOVE_ANIMATION : uint = 0x10;
		
		static public const PICKUPABLE : uint = 0x11;
		
		static public const HANGABLE : uint = 0x12;
		
		static public const VERTICAL : uint = 0x13;
		
		static public const HORIZONTAL : uint = 0x14;
		
		static public const ROTATABLE : uint = 0x15;
		
		static public const HAS_LIGHT : uint = 0x16;
		
		static public const DONT_HIDE : uint = 0x17;
		
		static public const TRANSLUCENT : uint = 0x18;
		
		static public const HAS_OFFSET : uint = 0x19;
		
		static public const HAS_ELEVATION : uint = 0x1A;
		
		static public const LYING_OBJECT : uint = 0x1B;
		
		static public const ANIMATE_ALWAYS : uint = 0x1C;
		
		static public const MINI_MAP : uint = 0x1D;
		
		static public const LENS_HELP : uint = 0x1E;
		
		static public const FULL_GROUND : uint = 0x1F;
		
		static public const IGNORE_LOOK : uint = 0x20;  
		
		static public const CLOTH : uint = 0x21;
		
		static public const MARKET_ITEM : uint = 0x22;
		
		static public const DEFAULT_ACTION : uint = 0x23;
		
		static public const USABLE : uint = 0xFE;
		
		static public const LAST_FLAG : uint = 0xFF;
	}
}
