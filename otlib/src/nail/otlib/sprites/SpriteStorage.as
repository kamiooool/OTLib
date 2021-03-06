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
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nail.otlib.assets.AssetsVersion;

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="change", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class SpriteStorage extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _version : AssetsVersion;
		private var _signature : uint;
		private var _rawBytes : ByteArray;
		private var _spritesCount : uint;
		private var _sprites : Dictionary;
		private var _loading : Boolean;
		private var _loaded : Boolean;
		private var _rect : Rectangle;
		private var _point : Point;
		private var _bitmap : BitmapData;
		private var _blankSprite : Sprite;
		private var _headSize : uint;
		private var _changed : Boolean;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function SpriteStorage()
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

		public function load(file:File, version:AssetsVersion, enableSpritesU32:Boolean = false) : void
		{
			var loader : URLLoader;
			
			if (file == null)
			{
				throw new ArgumentError("Parameter type cannot be null.");
			}
			
			if (version == null)
			{
				throw new ArgumentError("Parameter version cannot be null.");
			}
			
			if (_loading)
			{
				return;
			}
			
			if (this.loaded)
			{
				this.clear();
			}
			
			_loading = true;
			_version = version;
			
			if (file.exists == false)
			{
				dispatchError("File not found: " + file.nativePath);
				return;
			}
			
			loader = new URLLoader();
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest(file.nativePath));
			
			function progressHandler(event:ProgressEvent) : void
			{
				dispatchEvent(event);
			}
			
			function completeHandler(event:Event) : void
			{
				_rawBytes = ByteArray(loader.data);
				_rawBytes.endian = Endian.LITTLE_ENDIAN;
				_signature = _rawBytes.readUnsignedInt();
				
				if (enableSpritesU32 || version.value >= 960)
				{
					_spritesCount = _rawBytes.readUnsignedInt();
					_headSize = HEAD_SIZE_U32;
				}
				else 
				{
					_spritesCount = _rawBytes.readUnsignedShort();
					_headSize = HEAD_SIZE_U16;
				}
				
				_blankSprite = new Sprite(0);
				_sprites = new Dictionary();
				_sprites[0] = _blankSprite;
				_rect = new Rectangle(0, 0, Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS);
				_point = new Point();
				_bitmap = new BitmapData(_rect.width, _rect.height, true, 0xFFFF00FF);
				_loading = false;
				_loaded = true;
				_changed = false;
				
				dispatchEvent(event);
			}
		}
		
		public function createNew(version:AssetsVersion, enableSpritesU32:Boolean = false) : Boolean
		{
			if (version == null)
			{
				throw new ArgumentError("Parameter version cannot be null.");
			}
			
			if (_loading)
			{
				return false;
			}
			
			if (this.loaded)
			{
				this.clear();
			}
			
			_version = version;
			_rawBytes = new ByteArray();
			_rawBytes.endian = Endian.LITTLE_ENDIAN;
			_signature = version.sprSignature;
			_spritesCount = 0;
			_headSize = (enableSpritesU32 || version.value >= 960) ? HEAD_SIZE_U32 : HEAD_SIZE_U16;
			_blankSprite = new Sprite(0);	
			_sprites = new Dictionary();
			_sprites[0] = _blankSprite;
			_rect = new Rectangle(0, 0, Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS);
			_point = new Point();
			_bitmap = new BitmapData(_rect.width, _rect.height, true, 0xFFFF00FF);
			_changed = true;
			_loaded = true;
			_loading = false;
			
			return true;
		}
		
		public function addSprite(pixels:ByteArray) : Boolean
		{
			var sprite : Sprite;
			var id : uint;
			
			if (pixels == null)
			{
				throw new ArgumentError("Parameter pixels cannot be null.");
			}
			
			if (pixels.length != Sprite.SPRITE_DATA_SIZE)
			{
				throw new ArgumentError("Parameter pixels has an invalid length.");
			}
			
			id = _spritesCount + 1;
			sprite = new Sprite(id);
			if (!sprite.setBytes(pixels))
			{
				return false;
			}
			
			// Add sprite to list.
			_sprites[id] = sprite;
			_spritesCount = id;
			_changed = true;
			
			// Return ByteArray point.
			pixels.position = 0; 
			
			// Dispatch change event.
			if (hasEventListener(Event.CHANGE))
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			return true;
		}
		
		public function replaceSprite(index:uint, pixels:ByteArray) : Boolean
		{
			var sprite : Sprite;
			
			if (index == 0 || index > _spritesCount)
			{
				throw new ArgumentError("Parameter index is out of range.");
			}
			
			if (pixels == null) 
			{
				throw new ArgumentError("Parameter pixels cannot be null.");
			}
			
			if (pixels.length != Sprite.SPRITE_DATA_SIZE) 
			{
				throw new ArgumentError("Parameter pixels has an invalid length.");
			}
			
			sprite = new Sprite(index);
			if (!sprite.setBytes(pixels))
			{
				return false;
			}
			
			// Add sprite to list.
			_sprites[index] = sprite;
			_changed = true;
			
			// Return ByteArray point.
			pixels.position = 0; 
			
			// Dispatch change event.
			if (hasEventListener(Event.CHANGE))
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			return true;
		}
		
		public function removeSprite(index:uint) : Boolean
		{
			if (index == 0 || index > _spritesCount)
			{
				throw new ArgumentError("Parameter index is out of range.");
			}
			
			// Add a blank sprite at index.
			_sprites[index] = new Sprite(index);
			_changed = true;
			
			if (index == _spritesCount)
			{
				_spritesCount--;
			}
			
			// Dispatch change event.
			if (hasEventListener(Event.CHANGE))
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			return true;
		}
		
		public function getSprite(id:uint) : Sprite
		{
			var sprite : Sprite;
			
			if (_loaded == true && id <= _spritesCount)
			{
				if (_sprites[id] !== undefined)
				{
					sprite = Sprite(_sprites[id]);
				}
				else 
				{
					sprite = readSprite(id, _rawBytes); 
				}
				
				if (!sprite)
				{
					sprite = _blankSprite;
				}
				return sprite;
			}
			return null;
		}
		
		public function getPixels(id:uint) : ByteArray
		{
			var sprite : Sprite;
			var pixels : ByteArray;
			
			if (loaded)
			{
				sprite = getSprite(id);
				if (sprite != null)
				{
					try
					{
						pixels =  sprite.getPixels();
					}
					catch (error:Error)
					{
						dispatchError(error.getStackTrace(), error.errorID);
						return _blankSprite.getPixels();
					}
					return pixels;
				}
			}
			return null;
		}
		
		public function copyPixels(index:int, bitmap:BitmapData, x:int, y:int) : void
		{
			var pixels : ByteArray;
			
			if (!_loaded || !bitmap) { return; }
			
			pixels = getPixels(index);
			if (pixels == null) { return; }
			
			_point.setTo(x, y);
			_bitmap.setPixels(_rect, pixels);
			bitmap.copyPixels(_bitmap, _rect, _point, null, null, true);
		}
		
		public function hasSpriteId(id:uint) : Boolean
		{
			if (_loaded == true && id <= _spritesCount)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * Checks if a sprite id and a sprite pixels are equal.
		 * 
		 * @param id The id of the sprite to compare.
		 * @param pixels Sprite pixels to compare.
		 */
		public function compare(id:uint, pixels:ByteArray) : Boolean
		{
			var bmp1 : BitmapData;
			var bmp2 : BitmapData;
			var otherPixels : ByteArray;
			
			if (pixels == null) 
			{
				throw new ArgumentError("Parameter pixels cannot be null.");
			}
			
			if (pixels.length != Sprite.SPRITE_DATA_SIZE) 
			{
				throw new ArgumentError("Parameter pixels has an invalid length.");
			}
			
			if (hasSpriteId(id))
			{
				pixels.position = 0;
				bmp1 = new BitmapData(Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS, true, 0xFFFF00FF);
				bmp1.setPixels(bmp1.rect, pixels);
				
				otherPixels = this.getPixels(id);
				otherPixels.position = 0
				bmp2 = new BitmapData(Sprite.SPRITE_PIXELS, Sprite.SPRITE_PIXELS, true, 0xFFFF00FF);
				bmp2.setPixels(bmp2.rect, otherPixels);
				
				return (bmp1.compare(bmp2) == 0);
			}
			return false;
		}
		
		//--------------------------------------
		// Private
		//--------------------------------------
		
		private function readSprite(index:uint, bytes:ByteArray) : Sprite
		{
			var sprite : Sprite;
			var spriteAddress : uint;
			var pixelDataSize : uint;
			
			bytes.position = ((index - 1) * 4) + _headSize;
			spriteAddress  = bytes.readUnsignedInt();
			if (spriteAddress == 0)
			{
				return null;
			}
			
			sprite = new Sprite(index);
			bytes.position = spriteAddress;
			bytes.readUnsignedByte(); // Skip red
			bytes.readUnsignedByte(); // Skip green
			bytes.readUnsignedByte(); // Skip blue
			
			pixelDataSize = bytes.readUnsignedShort();	
			sprite.size = pixelDataSize;
			bytes.readBytes(sprite.bytes, 0, pixelDataSize);
			sprite.dummy = (sprite.bytes.length == 0);
			return sprite;
		}
		
		public function compile(file:File,
								version:AssetsVersion,
								enableSpritesU32:Boolean = false,
								forceCompile:Boolean = false) : Boolean
		{
			var stream : FileStream;
			var currentSprite : uint;
			var offset : uint;
			var addressPosition : uint; 
			var sprite : Sprite;
			var dispatchProgess : Boolean;
			var headSize : uint;
			var count : uint;
			
			if (!file)
			{
				throw new ArgumentError("Parameter file cannot be null.");
			}
			
			if (!version)
			{
				throw new ArgumentError("Parameter version cannot be null.");
			}
			
			if (!_loaded)
			{
				return false;
			}
			
			try
			{
				stream = new FileStream();
				stream.open(file, FileMode.WRITE);
			} 
			catch(error:Error) 
			{
				return false;
			}
			
			_rawBytes.position = 0;
			stream.endian = Endian.LITTLE_ENDIAN;
			
			// If is unmodified and the version is equal only save raw bytes.
			if (!_changed && !forceCompile && version.value == _version.value)
			{
				stream.writeBytes(_rawBytes, 0, _rawBytes.bytesAvailable);
				stream.close();
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _spritesCount, _spritesCount));
				return true;
			}
			
			stream.writeUnsignedInt(version.sprSignature); // Write spr signature.
			
			// Write sprites count.
			if (enableSpritesU32 || version.value >= 960)
			{
				count = _spritesCount;
				headSize = HEAD_SIZE_U32;
				stream.writeUnsignedInt(count);
			}
			else 
			{
				count = _spritesCount >= 0xFFFF ? 0xFFFE : _spritesCount;
				headSize = HEAD_SIZE_U16;
				stream.writeShort(count);
			}
			
			addressPosition = stream.position;
			offset = (count * 4) + headSize;
			dispatchProgess = this.hasEventListener(ProgressEvent.PROGRESS);
			
			currentSprite = 1;
			while (currentSprite <= count)
			{
				stream.position = addressPosition;
				sprite = getSprite(currentSprite);
				if(sprite == null || sprite.isDummy() == true)
				{
					stream.writeUnsignedInt(0);
					addressPosition += 4;
					currentSprite++;
					continue;
				}
				
				stream.writeUnsignedInt(offset); // Write address
				stream.position = offset;
				offset = writeSprite(stream, sprite, offset);
				addressPosition += 4;
				currentSprite++;	
				
				if (dispatchProgess)
				{
					dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, currentSprite, count));
				}
			}
			stream.close();
			return true;
		}
		
		public function clear() : void
		{
			if (_bitmap != null)
			{
				_bitmap.dispose();
			}
			
			if (_rawBytes != null)
			{
				_rawBytes.clear();
			}
			
			_bitmap = null;
			_loaded = false;
			_spritesCount = 0;
			_point = null;
			_rawBytes = null;
			_rect = null;
			_signature = 0;
		}
		
		//--------------------------------------
		// Private
		//--------------------------------------
		
		private function writeSprite(stream:FileStream, sprite:Sprite, dumpOffset:uint) : uint
		{
			sprite.bytes.position = 0;
			stream.writeByte(0xFF);
			stream.writeByte(0x00);
			stream.writeByte(0xFF);
			stream.writeShort(sprite.size);
			if (sprite.size > 0)
			{
				stream.writeBytes(sprite.bytes, 0, sprite.size);
			}
			return stream.position;
		}
		
		private function dispatchError(message:String, id:uint = 0) : void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message, id));
		}
		
		//--------------------------------------
		// Getters / Setters
		//--------------------------------------
		
		public function get signature() : uint
		{
			return _signature;
		}
		
		public function get spritesCount() : uint
		{
			return _spritesCount;
		}	

		public function get loaded() : Boolean
		{
			return _loaded;
		}
		
		public function get isFull() : Boolean
		{
			if (_loaded && _version.value < 960 && _spritesCount == 0xFFFF)
			{
				return true;
			}
			return false;
		}
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static private const HEAD_SIZE_U16 : uint = 6;
		static private const HEAD_SIZE_U32 : uint = 8;
	}
}
