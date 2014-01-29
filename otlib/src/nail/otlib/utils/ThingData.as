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

package nail.otlib.utils
{
	import nail.otlib.things.ThingType;

	public class ThingData
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _thing : ThingType;
		
		private var _sprites : Vector.<SpriteData>;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function ThingData(thing:ThingType, sprites:Vector.<SpriteData>)
		{
			if (thing == null)
			{
				throw new ArgumentError("Parameter thing cannot be null.");
			}
			
			if (sprites == null)
			{
				throw new ArgumentError("Parameter sprites cannot be null.");
			}
			
			if (thing.spriteIndex.length != sprites.length)
			{
				throw new ArgumentError("Invalid sprite count.");
			}
			
			_thing = thing;
			_sprites = sprites;
		}

		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Getters / Setters 
		//--------------------------------------
		
		public function get id() : uint
		{
			return _thing.id;
		}
		
		public function get category() : String
		{
			return _thing.category;
		}
		
		public function get length() : uint
		{
			return _sprites.length;
		}
		
		public function get thing() : ThingType
		{
			return _thing;
		}

		public function get sprites() : Vector.<SpriteData>
		{
			return _sprites;
		}
	}
}
