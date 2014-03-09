///////////////////////////////////////////////////////////////////////////////////
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
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import nail.otlib.sprites.Sprite;

	public class SpriteData
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		public var id : uint;
		public var pixels : ByteArray;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function SpriteData()
		{
			
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Public
		//--------------------------------------
		
		/**
		 * @param backgroundColor A 32-bit ARGB color value.
		 */
		public function getBitmap(backgroundColor:uint = 0x00000000) : BitmapData
		{
			var bitmap : BitmapData;
			
			if (pixels != null)
			{
				try
				{
					pixels.position = 0;
					BITMAP.setPixels(RECTANGLE, pixels);
					bitmap = new BitmapData(Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS, true, backgroundColor);
					bitmap.copyPixels(BITMAP, RECTANGLE, POINT, null, null, true);
				} 
				catch(error:Error)
				{
					return null;
				}
				return bitmap;
			}
			return null;
		}
		
		public function isEmpty() : Boolean
		{
			if (pixels != null)
			{
				BITMAP.setPixels(RECTANGLE, pixels);
				return SpriteUtils.isEmpty(BITMAP);
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static private const RECTANGLE : Rectangle = new Rectangle(0, 0, Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS);
		static private const POINT : Point = new Point();
		static private const BITMAP : BitmapData = new BitmapData(Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS, true, 0xFFFF00FF);
		
		static public function createSpriteData() : SpriteData
		{
			var data : SpriteData;
			data = new SpriteData();
			data.id = 0;
			data.pixels = BITMAP.getPixels(RECTANGLE);
			return data;
		}
	}
}
