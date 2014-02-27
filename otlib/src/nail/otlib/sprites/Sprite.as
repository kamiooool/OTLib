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

package nail.otlib.sprites
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Sprite
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _id : uint;
		private var _bytes : ByteArray;
		private var _size : uint;
		public var dummy : Boolean;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function Sprite(id:uint)
		{
			_id = id;
			_bytes = new ByteArray();
			_bytes.endian = Endian.LITTLE_ENDIAN;
			dummy = true;
		}

		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Public
		//--------------------------------------
		
		public function setBytes(pixels:ByteArray) : Boolean
		{
			var length : uint;
			var index : uint;
			var color : uint;
			var transparent : Boolean;
			var alphaCount : uint;
			var chunkSize : uint;
			var coloredPos : uint;
			var previousOffset : uint;
			var finishOffset : uint;
			
			pixels.position = 0;
			length = pixels.length / 4;
			transparent = true;
			
			if (length != 1024)
			{
				return false;
			}
			
			previousOffset = pixels.position;
			_bytes = new ByteArray();
			_bytes.endian = Endian.LITTLE_ENDIAN;
			
			while (index < length)
			{
				chunkSize = 0;
				while (index < length)
				{
					pixels.position = index * 4;
					color = pixels.readUnsignedInt();
					transparent = (color == 0)
					if (transparent == false)
					{
						break;
					}
					
					alphaCount++;
					chunkSize++;
					index++;
				}
				
				// Entire image is transparent
				if (alphaCount < length)
				{
					// Already at the end
					if(index < length)
					{
						_bytes.writeShort(chunkSize); // Write transparent pixels
						coloredPos = _bytes.position; // Save colored position 
						_bytes.position = _bytes.position + 2; // Skip colored short
						chunkSize = 0;
						
						while(index < length)
						{
							pixels.position = index * 4;
							color = pixels.readUnsignedInt();
							transparent = (color == 0)
							if (transparent == true)
							{
								break;
							}
							
							_bytes.writeByte(color >> 16 & 0xFF); // Write red
							_bytes.writeByte(color >> 8 & 0xFF);  // Write green
							_bytes.writeByte(color & 0xFF);       // Write blue
							
							chunkSize++;
							index++; 
						}
						
						finishOffset = _bytes.position;
						_bytes.position = coloredPos; // Go back to chunksize indicator
						_bytes.writeShort(chunkSize); // Write colored pixels
						_bytes.position = finishOffset;
					}
				}
			}
			
			dummy = false;
			_size = bytes.length;
			return true;
		}
		
		public function getPixels() : ByteArray
		{
			var read : uint;
			var write : uint;
			var transparentPixels : uint;
			var coloredPixels : uint;
			var i : int;
			var pixels : ByteArray;
			
			if (_bytes == null)
			{
				return null;
			}
			
			_bytes.position = 0;
			pixels = new ByteArray();
			
			for (read = 0; read < _size; read += 4 + (3 * coloredPixels)) 
			{
				transparentPixels = _bytes.readUnsignedShort();
				coloredPixels = _bytes.readUnsignedShort();
				
				if (write + (transparentPixels * 4) + (coloredPixels * 3) >= SPRITE_DATA_SIZE)
				{
					throw new Error("Corrupted sprite id=" + _id);
				}
				
				for (i = 0; i < transparentPixels; i++)
				{
					pixels[write++] = 0x00; // Alpha
					pixels[write++] = 0x00; // Red
					pixels[write++] = 0x00; // Green
					pixels[write++] = 0x00; // Blue
				}
					
				for (i = 0; i < coloredPixels; i++)
				{
					pixels[write++] = 0xFF;                      // Alpha
					pixels[write++] = _bytes.readUnsignedByte(); // Red
					pixels[write++] = _bytes.readUnsignedByte(); // Green
					pixels[write++] = _bytes.readUnsignedByte(); // Blue
				}
			}
			
			while(write < SPRITE_DATA_SIZE)
			{
				pixels[write++] = 0x00; // Alpha
				pixels[write++] = 0x00; // Red
				pixels[write++] = 0x00; // Green
				pixels[write++] = 0x00; // Blue	
			}
			
			return pixels;
		}
		
		public function isDummy() : Boolean
		{
			return dummy;
		}
		
		//--------------------------------------
		// Getters / Setters
		//--------------------------------------
		
		public function get bytes() : ByteArray
		{
			return _bytes;
		}
		
		public function get size() : uint
		{
			return _size;
		}
		
		public function set size(value:uint) : void
		{
			_size = value;
		}
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static public const SPRITE_PIXELS : uint = 32; 
		static public const SPRITE_DATA_SIZE : uint = 4096; // SPRITE_PIXELS * SPRITE_PIXELS * 4 bytes;
	}
}
