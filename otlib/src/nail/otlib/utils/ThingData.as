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
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	import nail.otlib.assets.AssetsVersion;
	import nail.otlib.geom.Rect;
	import nail.otlib.sprites.Sprite;
	import nail.otlib.things.ThingCategory;
	import nail.otlib.things.ThingType;
	import nail.otlib.things.ThingTypeFlags1;
	import nail.otlib.things.ThingTypeFlags2;
	import nail.otlib.things.ThingTypeFlags3;
	import nail.otlib.things.ThingTypeStorage;
	import nail.utils.StringUtil;
	
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
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static private const RECTANGLE : Rectangle = new Rectangle(0, 0, 32, 32);
		
		static private const POINT : Point = new Point();
		
		static public function serialize(data:ThingData, version:AssetsVersion) : ByteArray
		{
			var bytes : ByteArray;
			var thing : ThingType;
			
			if (data == null)
			{
				throw new ArgumentError("Parameter data cannot be null.");
			}
			
			if (version == null)
			{
				throw new ArgumentError("Parameter version cannot be null.");
			}
			
			thing = data.thing;
			bytes = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeShort(version.value); // Write client version
			bytes.writeUTF(thing.category);  // Write thing category
			
			if (version.value <= 854)
			{
				if (!writeProperties1(bytes, thing))
				{
					return null;
				}
			}
			else if (version.value >= 1010)
			{
				if (!writeProperties3(bytes, thing))
				{
					return null;
				}
			}
			else
			{
				if (!writeProperties2(bytes, thing))
				{
					return null;
				}
			}	
			
			if (!writeSprites(data, bytes))
			{
				return null;
			}	
			
			bytes.compress(CompressionAlgorithm.LZMA);
			return bytes;
		}
		
		static public function unserialize(bytes:ByteArray) : ThingData
		{
			var version : AssetsVersion;
			var thing : ThingType;
			
			if (bytes == null)
			{
				throw new ArgumentError("Parameter bytes cannot be null.");
			}
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.uncompress(CompressionAlgorithm.LZMA);
			
			version = AssetsVersion.getVersionByValue( bytes.readUnsignedShort() );
			if (version == null)
			{
				throw new Error("Unsupported version.");
			}
			
			thing = new ThingType();
			thing.category = ThingCategory.getCategory( bytes.readUTF() );
			if (thing.category == null)
			{
				throw new Error("Invalid thing category.");
			}
			
			if (version.value <= 854)
			{
				if (!readThingType1(thing, bytes))
				{
					return null;
				}
			}
			else if (version.value >= 1010)
			{
				if (!readThingType3(thing, bytes))
				{
					return null;
				}
			}
			else 
			{
				if (!readThingType2(thing, bytes))
				{
					return null;
				}
			}
			
			return readThingSprites(thing, bytes);
		}
		
		static public function getSpriteSheet(data:ThingData, textureIndex:Vector.<Rect> = null) : BitmapData
		{
			var thing : ThingType;
			var width : uint;
			var height : uint;
			var layers : uint;
			var patternX : uint;
			var patternY : uint;
			var patternZ : uint;
			var frames : uint;
			var size : uint;
			var x : uint;
			var y : uint;
			var z : uint;
			var l : uint;
			var f : uint;
			var w : uint;
			var h : uint;
			var fx : int;
			var fy : int;
			var px : int;
			var py : int;
			var index : uint;
			var totalX : int;
			var totalY : int;
			var bitmapWidth : Number;
			var bitmapHeight : Number;
			var pixelsWidth : int;
			var pixelsHeight : int;
			var bitmap : BitmapData;
			
			if (data == null)
			{
				throw new ArgumentError("Parameter data cannot be null.");
			}
			
			thing = data.thing;
			width = thing.width;
			height = thing.height;
			layers = thing.layers;
			patternX = thing.patternX;
			patternY = thing.patternY;
			patternZ = thing.patternZ;
			frames = thing.frames;
			size = Sprite.SPRITE_PIXELS;
			
			// -----< Measure and create bitmap>-----
			totalX = patternZ * patternX * layers;
			totalY = frames * patternY;
			bitmapWidth = (totalX * width) * size;
			bitmapHeight = (totalY * height) * size;
			pixelsWidth  = width * size
			pixelsHeight = height * size;
			bitmap = new BitmapData(bitmapWidth, bitmapHeight, true, 0xFFFF00FF);
			
			if (textureIndex != null)
			{
				textureIndex.length = layers * patternX * patternY * patternZ * frames;
			}
			
			for (f = 0; f < frames; f++)
			{
				for (z = 0; z < patternZ; z++)
				{
					for (y = 0; y < patternY; y++)
					{
						for (x = 0; x < patternX; x++)
						{
							for (l = 0; l < layers; l++)
							{
								index = getTextureIndex(thing, f, x, y, z, l);
								fx = (index % totalX) * pixelsWidth;
								fy = Math.floor(index / totalX) * pixelsHeight;
								
								if (textureIndex != null)
								{
									textureIndex[index] = new Rect(fx, fy, pixelsWidth, pixelsHeight);
								}
								
								for (w = 0; w < width; w++)
								{
									for (h = 0; h < height; h++)
									{
										index = getSpriteIndex(thing, w, h, l, x, y, z, f);
										px = ((width - w - 1) * size);
										py = ((height - h - 1) * size);
										copyPixels(data, index, bitmap, px + fx, py + fy);
									}
								}
							}
						}
					}
				}
			}
			
			return bitmap;
		}
		
		static private function getTextureIndex(thing:ThingType, f:int, x:int, y:int, z:int, l:int) : int
		{
			return (((f % thing.frames * thing.patternZ + z) * thing.patternY + y) * thing.patternX + x) * thing.layers + l;
		}
		
		static private function getSpriteIndex(thing:ThingType, w:uint, h:uint, l:uint, x:uint, y:uint, z:uint, f:uint) : uint
		{
			return ((((((f % thing.frames)
				* thing.patternZ + z)
				* thing.patternY + y)
				* thing.patternX + x)
				* thing.layers + l)
				* thing.height + h)
				* thing.width + w;
		}
		
		static private function copyPixels(data:ThingData, index:uint, bitmap:BitmapData, x:uint, y:uint) : void
		{
			var spriteData : SpriteData;
			var bmp : BitmapData;
			
			if (index < data.length)
			{
				spriteData = data.sprites[index];
				if (spriteData != null && spriteData.pixels != null)
				{
					POINT.x = x;
					POINT.y = y;
					
					bmp = spriteData.getBitmap();
					if (bmp != null)
					{
						spriteData.pixels.position = 0;
						bitmap.copyPixels(bmp, RECTANGLE, POINT, null, null, true);
					}
				}
			}
		}
		
		/**
		 * Write versions 8.00 - 8.54
		 */
		static private function writeProperties1(bytes:ByteArray, thing:ThingType) : Boolean
		{
			if (thing.isGround)
			{
				bytes.writeByte(ThingTypeFlags1.GROUND);
				bytes.writeShort(thing.groundSpeed);
			}
			else if (thing.isGroundBorder)
			{ 
				bytes.writeByte(ThingTypeFlags1.GROUND_BORDER);
			}
			else if (thing.isOnBottom)
			{
				bytes.writeByte(ThingTypeFlags1.ON_BOTTOM);
			}
			else if (thing.isOnTop)
			{
				bytes.writeByte(ThingTypeFlags1.ON_TOP);
			}
			
			if (thing.isContainer) { bytes.writeByte(ThingTypeFlags1.CONTAINER); }
			if (thing.stackable) { bytes.writeByte(ThingTypeFlags1.STACKABLE); }
			if (thing.forceUse) { bytes.writeByte(ThingTypeFlags1.FORCE_USE); }
			if (thing.multiUse) { bytes.writeByte(ThingTypeFlags1.MULTI_USE); }
			if (thing.hasCharges) { bytes.writeByte(ThingTypeFlags1.HAS_CHARGES) };
			
			if (thing.writable)
			{
				bytes.writeByte(ThingTypeFlags1.WRITABLE);
				bytes.writeShort(thing.maxTextLength);
			}
			
			if (thing.writableOnce)
			{
				bytes.writeByte(ThingTypeFlags1.WRITABLE_ONCE);
				bytes.writeShort(thing.maxTextLength);
			}	
			
			if (thing.isFluidContainer) { bytes.writeByte(ThingTypeFlags1.FLUID_CONTAINER); }
			if (thing.isFluid) { bytes.writeByte(ThingTypeFlags1.FLUID); }
			if (thing.isUnpassable) { bytes.writeByte(ThingTypeFlags1.UNPASSABLE); }
			if (thing.isUnmoveable) { bytes.writeByte(ThingTypeFlags1.UNMOVEABLE); }
			if (thing.blockMissile) { bytes.writeByte(ThingTypeFlags1.BLOCK_MISSILE); }
			if (thing.blockPathfind) { bytes.writeByte(ThingTypeFlags1.BLOCK_PATHFIND); }
			if (thing.pickupable) { bytes.writeByte(ThingTypeFlags1.PICKUPABLE); }
			if (thing.hangable) { bytes.writeByte(ThingTypeFlags1.HANGABLE); }
			if (thing.isVertical) { bytes.writeByte(ThingTypeFlags1.VERTICAL); }
			if (thing.isHorizontal) { bytes.writeByte(ThingTypeFlags1.HORIZONTAL); }
			if (thing.rotatable) { bytes.writeByte(ThingTypeFlags1.ROTATABLE); }
			
			if (thing.hasLight)
			{
				bytes.writeByte(ThingTypeFlags1.HAS_LIGHT);
				bytes.writeShort(thing.lightLevel);
				bytes.writeShort(thing.lightColor);
			}
			
			if (thing.dontHide) { bytes.writeByte(ThingTypeFlags1.DONT_HIDE); }
			if (thing.floorChange) { bytes.writeByte(ThingTypeFlags1.FLOOR_CHANGE); }
			
			if (thing.hasOffset)
			{
				bytes.writeByte(ThingTypeFlags1.HAS_OFFSET);
				bytes.writeShort(thing.offsetX);
				bytes.writeShort(thing.offsetY);
			}
			
			if (thing.hasElevation)
			{
				bytes.writeByte(ThingTypeFlags1.HAS_ELEVATION);
				bytes.writeShort(thing.elevation);
			}
			
			if (thing.isLyingObject) { bytes.writeByte(ThingTypeFlags1.LYING_OBJECT); }
			if (thing.animateAlways) { bytes.writeByte(ThingTypeFlags1.ANIMATE_ALWAYS); }
			
			if (thing.miniMap)
			{
				bytes.writeByte(ThingTypeFlags1.MINI_MAP);
				bytes.writeShort(thing.miniMapColor);
			}
			if (thing.isLensHelp)
			{
				bytes.writeByte(ThingTypeFlags1.LENS_HELP);
				bytes.writeShort(thing.lensHelp);
			}
			if (thing.isFullGround) { bytes.writeByte(ThingTypeFlags1.FULL_GROUND); }
			if (thing.ignoreLook) { bytes.writeByte(ThingTypeFlags1.IGNORE_LOOK); }
			
			bytes.writeByte(ThingTypeFlags1.LAST_FLAG); // Close flags
			return true;
		}
		
		/**
		 * Write versions 8.60 - 9.86
		 */
		static private function writeProperties2(bytes:ByteArray, thing:ThingType) : Boolean
		{
			if (thing.isGround)
			{
				bytes.writeByte(ThingTypeFlags2.GROUND); 
				bytes.writeShort(thing.groundSpeed);
			}
			else if (thing.isGroundBorder)
			{ 
				bytes.writeByte(ThingTypeFlags2.GROUND_BORDER);
			}
			else if (thing.isOnBottom)
			{
				bytes.writeByte(ThingTypeFlags2.ON_BOTTOM);
			}
			else if (thing.isOnTop)
			{
				bytes.writeByte(ThingTypeFlags2.ON_TOP);
			}
			
			if (thing.isContainer) { bytes.writeByte(ThingTypeFlags2.CONTAINER); }
			if (thing.stackable) { bytes.writeByte(ThingTypeFlags2.STACKABLE); }
			if (thing.forceUse) { bytes.writeByte(ThingTypeFlags2.FORCE_USE); }
			if (thing.multiUse) { bytes.writeByte(ThingTypeFlags2.MULTI_USE); }
			
			if (thing.writable)
			{
				bytes.writeByte(ThingTypeFlags2.WRITABLE);
				bytes.writeShort(thing.maxTextLength);
			}
			
			if (thing.writableOnce)
			{
				bytes.writeByte(ThingTypeFlags2.WRITABLE_ONCE);
				bytes.writeShort(thing.maxTextLength);
			}	
			
			if (thing.isFluidContainer) { bytes.writeByte(ThingTypeFlags2.FLUID_CONTAINER); }
			if (thing.isFluid) { bytes.writeByte(ThingTypeFlags2.FLUID); }
			if (thing.isUnpassable) { bytes.writeByte(ThingTypeFlags2.UNPASSABLE); }
			if (thing.isUnmoveable) { bytes.writeByte(ThingTypeFlags2.UNMOVEABLE); }
			if (thing.blockMissile) { bytes.writeByte(ThingTypeFlags2.BLOCK_MISSILE); }
			if (thing.blockPathfind) { bytes.writeByte(ThingTypeFlags2.BLOCK_PATHFIND); }
			if (thing.pickupable) { bytes.writeByte(ThingTypeFlags2.PICKUPABLE); }
			if (thing.hangable) { bytes.writeByte(ThingTypeFlags2.HANGABLE); }
			if (thing.isVertical) { bytes.writeByte(ThingTypeFlags2.VERTICAL); }
			if (thing.isHorizontal) { bytes.writeByte(ThingTypeFlags2.HORIZONTAL); }
			if (thing.rotatable) { bytes.writeByte(ThingTypeFlags2.ROTATABLE); }
			
			if (thing.hasLight)
			{
				bytes.writeByte(ThingTypeFlags2.HAS_LIGHT);
				bytes.writeShort(thing.lightLevel);
				bytes.writeShort(thing.lightColor);
			}
			
			if (thing.dontHide) { bytes.writeByte(ThingTypeFlags2.DONT_HIDE); }
			if (thing.isTranslucent) { bytes.writeByte(ThingTypeFlags2.TRANSLUCENT); }
			
			if (thing.hasOffset)
			{
				bytes.writeByte(ThingTypeFlags2.HAS_OFFSET);
				bytes.writeShort(thing.offsetX);
				bytes.writeShort(thing.offsetY);
			}
			
			if (thing.hasElevation)
			{
				bytes.writeByte(ThingTypeFlags2.HAS_ELEVATION);
				bytes.writeShort(thing.elevation);
			}
			
			if (thing.isLyingObject) { bytes.writeByte(ThingTypeFlags2.LYING_OBJECT); }
			if (thing.animateAlways) { bytes.writeByte(ThingTypeFlags2.ANIMATE_ALWAYS); }
			
			if (thing.miniMap)
			{
				bytes.writeByte(ThingTypeFlags2.MINI_MAP);
				bytes.writeShort(thing.miniMapColor);
			}
			if (thing.isLensHelp)
			{
				bytes.writeByte(ThingTypeFlags2.LENS_HELP);
				bytes.writeShort(thing.lensHelp);
			}
			if (thing.isFullGround) { bytes.writeByte(ThingTypeFlags2.FULL_GROUND); }
			if (thing.ignoreLook) { bytes.writeByte(ThingTypeFlags2.IGNORE_LOOK); }
			if (thing.cloth)
			{
				bytes.writeByte(ThingTypeFlags2.CLOTH);
				bytes.writeShort(thing.clothSlot);
			}
			
			if (thing.isMarketItem)
			{
				bytes.writeByte(ThingTypeFlags2.MARKET_ITEM);
				bytes.writeShort(thing.marketCategory);
				bytes.writeShort(thing.marketTradeAs);
				bytes.writeShort(thing.marketShowAs);
				bytes.writeShort(thing.marketName.length);
				bytes.writeMultiByte(thing.marketName, ThingTypeStorage.STRING_CHARSET);
				bytes.writeShort(thing.marketRestrictProfession);
				bytes.writeShort(thing.marketRestrictLevel);
			}
			
			bytes.writeByte(ThingTypeFlags2.LAST_FLAG); // Close flags
			return true;
		}
		
		/**
		 * Write versions 10.10+
		 */
		static private function writeProperties3(bytes:ByteArray, thing:ThingType) : Boolean
		{
			if (thing.isGround)
			{
				bytes.writeByte(ThingTypeFlags3.GROUND);
				bytes.writeShort(thing.groundSpeed);
			}
			else if (thing.isGroundBorder)
			{ 
				bytes.writeByte(ThingTypeFlags3.GROUND_BORDER);
			}
			else if (thing.isOnBottom)
			{
				bytes.writeByte(ThingTypeFlags3.ON_BOTTOM);
			}
			else if (thing.isOnTop)
			{
				bytes.writeByte(ThingTypeFlags3.ON_TOP);
			}
			
			if (thing.isContainer) { bytes.writeByte(ThingTypeFlags3.CONTAINER); }
			if (thing.stackable) { bytes.writeByte(ThingTypeFlags3.STACKABLE); }
			if (thing.forceUse) { bytes.writeByte(ThingTypeFlags3.FORCE_USE); }
			if (thing.multiUse) { bytes.writeByte(ThingTypeFlags3.MULTI_USE); }
			
			if (thing.writable)
			{
				bytes.writeByte(ThingTypeFlags3.WRITABLE);
				bytes.writeShort(thing.maxTextLength);
			}
			
			if (thing.writableOnce)
			{
				bytes.writeByte(ThingTypeFlags3.WRITABLE_ONCE);
				bytes.writeShort(thing.maxTextLength);
			}
			
			if (thing.isFluidContainer) { bytes.writeByte(ThingTypeFlags3.FLUID_CONTAINER); }
			if (thing.isFluid) { bytes.writeByte(ThingTypeFlags3.FLUID); }
			if (thing.isUnpassable) { bytes.writeByte(ThingTypeFlags3.UNPASSABLE); }
			if (thing.isUnmoveable) { bytes.writeByte(ThingTypeFlags3.UNMOVEABLE); }
			if (thing.blockMissile) { bytes.writeByte(ThingTypeFlags3.BLOCK_MISSILE); }
			if (thing.blockPathfind) { bytes.writeByte(ThingTypeFlags3.BLOCK_PATHFIND); }
			if (thing.noMoveAnimation) {  bytes.writeByte(ThingTypeFlags3.NO_MOVE_ANIMATION); }
			if (thing.pickupable) { bytes.writeByte(ThingTypeFlags3.PICKUPABLE); }
			if (thing.hangable) { bytes.writeByte(ThingTypeFlags3.HANGABLE); }
			if (thing.isVertical) { bytes.writeByte(ThingTypeFlags3.VERTICAL); }
			if (thing.isHorizontal) { bytes.writeByte(ThingTypeFlags3.HORIZONTAL); }
			if (thing.rotatable) { bytes.writeByte(ThingTypeFlags3.ROTATABLE); }
			
			if (thing.hasLight)
			{
				bytes.writeByte(ThingTypeFlags3.HAS_LIGHT);
				bytes.writeShort(thing.lightLevel);
				bytes.writeShort(thing.lightColor);
			}
			
			if (thing.dontHide) { bytes.writeByte(ThingTypeFlags3.DONT_HIDE); }
			if (thing.isTranslucent) { bytes.writeByte(ThingTypeFlags3.TRANSLUCENT); }
			
			if (thing.hasOffset)
			{
				bytes.writeByte(ThingTypeFlags3.HAS_OFFSET);
				bytes.writeShort(thing.offsetX);
				bytes.writeShort(thing.offsetY);
			}
			
			if (thing.hasElevation)
			{
				bytes.writeByte(ThingTypeFlags3.HAS_ELEVATION);
				bytes.writeShort(thing.elevation);
			}
			
			if (thing.isLyingObject) { bytes.writeByte(ThingTypeFlags3.LYING_OBJECT); }
			
			if (thing.animateAlways) { bytes.writeByte(ThingTypeFlags3.ANIMATE_ALWAYS); }
			
			if (thing.miniMap)
			{
				bytes.writeByte(ThingTypeFlags3.MINI_MAP);
				bytes.writeShort(thing.miniMapColor);
			}
			if (thing.isLensHelp)
			{
				bytes.writeByte(ThingTypeFlags3.LENS_HELP);
				bytes.writeShort(thing.lensHelp);
			}
			if (thing.isFullGround) { bytes.writeByte(ThingTypeFlags3.FULL_GROUND); }
			if (thing.ignoreLook) { bytes.writeByte(ThingTypeFlags3.IGNORE_LOOK); }
			if (thing.cloth)
			{
				bytes.writeByte(ThingTypeFlags3.CLOTH);
				bytes.writeShort(thing.clothSlot);
			}
			
			if (thing.isMarketItem)
			{
				bytes.writeByte(ThingTypeFlags3.MARKET_ITEM);
				bytes.writeShort(thing.marketCategory);
				bytes.writeShort(thing.marketTradeAs);
				bytes.writeShort(thing.marketShowAs);
				bytes.writeShort(thing.marketName.length);
				bytes.writeMultiByte(thing.marketName, ThingTypeStorage.STRING_CHARSET);
				bytes.writeShort(thing.marketRestrictProfession);
				bytes.writeShort(thing.marketRestrictLevel);
			}
			
			if (thing.hasDefaultAction)
			{
				bytes.writeByte(ThingTypeFlags3.DEFAULT_ACTION);
				bytes.writeShort(thing.defaultAction); 
			}
			
			if (thing.usable)
			{
				bytes.writeByte(ThingTypeFlags3.USABLE);
			}
			
			bytes.writeByte(ThingTypeFlags3.LAST_FLAG); // Close flags
			return true;
		}
		
		static private function writeSprites(data:ThingData, bytes:ByteArray) : Boolean
		{ 
			var thing : ThingType;
			var length : uint; 
			var i : int;
			var spriteData : SpriteData;
			var spriteId : uint;
			var spriteList : Vector.<uint>;
			var pixels : ByteArray;
			
			thing = data.thing;
			bytes.writeByte(thing.width);  // Write width
			bytes.writeByte(thing.height); // Write height
			
			if (thing.width > 1 || thing.height > 1)
			{
				bytes.writeByte(thing.exactSize); // Write exact size
			}
			
			bytes.writeByte(thing.layers);   // Write layers
			bytes.writeByte(thing.patternX); // Write pattern X
			bytes.writeByte(thing.patternY); // Write pattern Y
			bytes.writeByte(thing.patternZ); // Write pattern Z
			bytes.writeByte(thing.frames);   // Write frames
			
			spriteList = thing.spriteIndex;
			length = spriteList.length;
			for (i = 0; i < length; i++)
			{
				spriteId = spriteList[i];
				
				spriteData = data.sprites[i];
				if (spriteData == null || spriteData.pixels == null)
				{
					throw new Error(StringUtil.substitute("Invalid sprite id.", spriteId));
				}
				
				pixels = spriteData.pixels;
				pixels.position = 0;
				bytes.writeUnsignedInt(spriteId);
				bytes.writeUnsignedInt(pixels.length);
				bytes.writeBytes(pixels, 0, pixels.bytesAvailable);
			}
			return true;
		}
		
		/**
		 * Read versions 8.0 - 8.54
		 */
		static private function readThingType1(thing:ThingType, bytes:ByteArray) : Boolean
		{
			var flag : uint;
			var index : uint; 
			var nameLength : uint;
			var totalSprites : uint;
			var previusFlag : uint; 
			
			while (flag < ThingTypeFlags1.LAST_FLAG)
			{
				previusFlag = flag;
				flag = bytes.readUnsignedByte();
				
				if (flag == ThingTypeFlags1.LAST_FLAG)
				{
					return true;
				}
				
				switch (flag)
				{
					case ThingTypeFlags1.GROUND:
						thing.isGround = true;
						thing.groundSpeed = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.GROUND_BORDER:
						thing.isGroundBorder = true;
						break;
					
					case ThingTypeFlags1.ON_BOTTOM:
						thing.isOnBottom = true;
						break;
					
					case ThingTypeFlags1.ON_TOP:
						thing.isOnTop = true;
						break;
					
					case ThingTypeFlags1.CONTAINER:
						thing.isContainer = true;
						break;
					
					case ThingTypeFlags1.STACKABLE:
						thing.stackable = true;
						break;
					
					case ThingTypeFlags1.FORCE_USE:
						thing.forceUse = true;
						break;
					
					case ThingTypeFlags1.MULTI_USE:
						thing.multiUse = true;
						break;
					
					case ThingTypeFlags1.HAS_CHARGES:
						thing.hasCharges = true;
						break;
					
					case ThingTypeFlags1.WRITABLE:
						thing.writable = true;
						thing.maxTextLength = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.WRITABLE_ONCE:
						thing.writableOnce = true;
						thing.maxTextLength = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.FLUID_CONTAINER:
						thing.isFluidContainer = true;
						break;
					
					case ThingTypeFlags1.FLUID:
						thing.isFluid = true;
						break;
					
					case ThingTypeFlags1.UNPASSABLE:
						thing.isUnpassable = true;
						break;
					
					case ThingTypeFlags1.UNMOVEABLE:
						thing.isUnmoveable = true;
						break;
					
					case ThingTypeFlags1.BLOCK_MISSILE:
						thing.blockMissile = true;
						break;
					
					case ThingTypeFlags1.BLOCK_PATHFIND:
						thing.blockPathfind = true;
						break;
					
					case ThingTypeFlags1.PICKUPABLE:
						thing.pickupable = true;
						break;
					
					case ThingTypeFlags1.HANGABLE:
						thing.hangable = true;
						break;
					
					case ThingTypeFlags1.VERTICAL:
						thing.isVertical = true;
						break;
					
					case ThingTypeFlags1.HORIZONTAL:
						thing.isHorizontal = true;
						break;
					
					case ThingTypeFlags1.ROTATABLE:
						thing.rotatable = true;
						break;
					
					case ThingTypeFlags1.HAS_LIGHT:
						thing.hasLight = true;
						thing.lightLevel = bytes.readUnsignedShort();
						thing.lightColor = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.DONT_HIDE:
						thing.dontHide = true;
						break;
					
					case ThingTypeFlags1.FLOOR_CHANGE:
						thing.floorChange = true;
						break;
					
					case ThingTypeFlags1.HAS_OFFSET:
						thing.hasOffset = true;
						thing.offsetX = bytes.readUnsignedShort();
						thing.offsetY = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.HAS_ELEVATION:
						thing.hasElevation = true;
						thing.elevation = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.LYING_OBJECT:
						thing.isLyingObject = true;
						break;
					
					case ThingTypeFlags1.ANIMATE_ALWAYS:
						thing.animateAlways = true;
						break;
					
					case ThingTypeFlags1.MINI_MAP:
						thing.miniMap = true;
						thing.miniMapColor = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.LENS_HELP:
						thing.isLensHelp = true;
						thing.lensHelp = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.FULL_GROUND:
						thing.isFullGround = true;
						break;
					
					case ThingTypeFlags1.IGNORE_LOOK:
						thing.ignoreLook = true;
						break;
					
					default:
						throw new Error(StringUtil.substitute("Unknown flag. flag=0x{0}, previous=0x{1}, category={2}, id={3}",
							flag.toString(16), previusFlag.toString(16), thing.category, thing.id));
						break;
				}
			}
			
			return true;
		}
		
		/**
		 * Read versions 8.60 - 9.86
		 */
		static private function readThingType2(thing:ThingType, bytes:ByteArray) : Boolean
		{
			var flag : uint;
			var index : uint; 
			var nameLength : uint;
			var totalSprites : uint;
			var previusFlag : uint; 
			
			while (flag < ThingTypeFlags2.LAST_FLAG)
			{
				previusFlag = flag;
				flag = bytes.readUnsignedByte();
				
				if (flag == ThingTypeFlags2.LAST_FLAG)
				{
					return true;
				}
				
				switch (flag)
				{
					case ThingTypeFlags2.GROUND:
						thing.isGround = true;
						thing.groundSpeed = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.GROUND_BORDER:
						thing.isGroundBorder = true;
						break;
					
					case ThingTypeFlags2.ON_BOTTOM:
						thing.isOnBottom = true;
						break;
					
					case ThingTypeFlags2.ON_TOP:
						thing.isOnTop = true;
						break;
					
					case ThingTypeFlags2.CONTAINER:
						thing.isContainer = true;
						break;
					
					case ThingTypeFlags2.STACKABLE:
						thing.stackable = true;
						break;
					
					case ThingTypeFlags2.FORCE_USE:
						thing.forceUse = true;
						break;
					
					case ThingTypeFlags2.MULTI_USE:
						thing.multiUse = true;
						break;
					
					case ThingTypeFlags2.WRITABLE:
						thing.writable = true;
						thing.maxTextLength = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.WRITABLE_ONCE:
						thing.writableOnce = true;
						thing.maxTextLength = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.FLUID_CONTAINER:
						thing.isFluidContainer = true;
						break;
					
					case ThingTypeFlags2.FLUID:
						thing.isFluid = true;
						break;
					
					case ThingTypeFlags2.UNPASSABLE:
						thing.isUnpassable = true;
						break;
					
					case ThingTypeFlags2.UNMOVEABLE:
						thing.isUnmoveable = true;
						break;
					
					case ThingTypeFlags2.BLOCK_MISSILE:
						thing.blockMissile = true;
						break;
					
					case ThingTypeFlags2.BLOCK_PATHFIND:
						thing.blockPathfind = true;
						break;
					
					case ThingTypeFlags2.PICKUPABLE:
						thing.pickupable = true;
						break;
					
					case ThingTypeFlags2.HANGABLE:
						thing.hangable = true;
						break;
					
					case ThingTypeFlags2.VERTICAL:
						thing.isVertical = true;
						break;
					
					case ThingTypeFlags2.HORIZONTAL:
						thing.isHorizontal = true;
						break;
					
					case ThingTypeFlags2.ROTATABLE:
						thing.rotatable = true;
						break;
					
					case ThingTypeFlags2.HAS_LIGHT:
						thing.hasLight = true;
						thing.lightLevel = bytes.readUnsignedShort();
						thing.lightColor = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.DONT_HIDE:
						thing.dontHide = true;
						break;
					
					case ThingTypeFlags2.TRANSLUCENT:
						thing.isTranslucent = true;
						break;
					
					case ThingTypeFlags2.HAS_OFFSET:
						thing.hasOffset = true;
						thing.offsetX = bytes.readUnsignedShort();
						thing.offsetY = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.HAS_ELEVATION:
						thing.hasElevation = true;
						thing.elevation = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.LYING_OBJECT:
						thing.isLyingObject = true;
						break;
					
					case ThingTypeFlags2.ANIMATE_ALWAYS:
						thing.animateAlways = true;
						break;
					
					case ThingTypeFlags2.MINI_MAP:
						thing.miniMap = true;
						thing.miniMapColor = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.LENS_HELP:
						thing.isLensHelp = true;
						thing.lensHelp   = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.FULL_GROUND:
						thing.isFullGround = true;
						break;
					
					case ThingTypeFlags2.IGNORE_LOOK:
						thing.ignoreLook = true;
						break;
					
					case ThingTypeFlags2.CLOTH:
						thing.cloth = true;
						thing.clothSlot = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.MARKET_ITEM:
						thing.isMarketItem = true;
						thing.marketCategory = bytes.readUnsignedShort();
						thing.marketTradeAs = bytes.readUnsignedShort();
						thing.marketShowAs = bytes.readUnsignedShort();
						nameLength = bytes.readUnsignedShort();
						thing.marketName = bytes.readMultiByte(nameLength, ThingTypeStorage.STRING_CHARSET);
						thing.marketRestrictProfession = bytes.readUnsignedShort();
						thing.marketRestrictLevel = bytes.readUnsignedShort();
						break;
					
					default:
						throw new Error(StringUtil.substitute("Unknown flag. flag=0x{0}, previous=0x{1}, category={2}, id={3}",
							flag.toString(16), previusFlag.toString(16), thing.category, thing.id));
						break;
				}
			}
			return true;
		}
		
		/**
		 * Read versions 10.10+
		 */
		static private function readThingType3(thing:ThingType, bytes:ByteArray) : Boolean
		{
			var flag : uint;
			var index : uint; 
			var nameLength : uint;
			var totalSprites : uint;
			var previusFlag : uint; 
			
			while (flag < ThingTypeFlags3.LAST_FLAG)
			{
				previusFlag = flag;
				flag = bytes.readUnsignedByte();
				
				if (flag == ThingTypeFlags3.LAST_FLAG)
				{
					return true;
				}
				
				switch (flag)
				{
					case ThingTypeFlags3.GROUND:
						thing.isGround = true;
						thing.groundSpeed = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.GROUND_BORDER:
						thing.isGroundBorder = true;
						break;
					
					case ThingTypeFlags3.ON_BOTTOM:
						thing.isOnBottom = true;
						break;
					
					case ThingTypeFlags3.ON_TOP:
						thing.isOnTop = true;
						break;
					
					case ThingTypeFlags3.CONTAINER:
						thing.isContainer = true;
						break;
					
					case ThingTypeFlags3.STACKABLE:
						thing.stackable = true;
						break;
					
					case ThingTypeFlags3.FORCE_USE:
						thing.forceUse = true;
						break;
					
					case ThingTypeFlags3.MULTI_USE:
						thing.multiUse = true;
						break;
					
					case ThingTypeFlags3.WRITABLE:
						thing.writable = true;
						thing.maxTextLength = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.WRITABLE_ONCE:
						thing.writableOnce = true;
						thing.maxTextLength = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.FLUID_CONTAINER:
						thing.isFluidContainer = true;
						break;
					
					case ThingTypeFlags3.FLUID:
						thing.isFluid = true;
						break;
					
					case ThingTypeFlags3.UNPASSABLE:
						thing.isUnpassable = true;
						break;
					
					case ThingTypeFlags3.UNMOVEABLE:
						thing.isUnmoveable = true;
						break;
					
					case ThingTypeFlags3.BLOCK_MISSILE:
						thing.blockMissile = true;
						break;
					
					case ThingTypeFlags3.BLOCK_PATHFIND:
						thing.blockPathfind = true;
						break;
					
					case ThingTypeFlags3.NO_MOVE_ANIMATION:
						thing.noMoveAnimation = true;
						break;
					
					case ThingTypeFlags3.PICKUPABLE:
						thing.pickupable = true;
						break;
					
					case ThingTypeFlags3.HANGABLE:
						thing.hangable = true;
						break;
					
					case ThingTypeFlags3.VERTICAL:
						thing.isVertical = true;
						break;
					
					case ThingTypeFlags3.HORIZONTAL:
						thing.isHorizontal = true;
						break;
					
					case ThingTypeFlags3.ROTATABLE:
						thing.rotatable = true;
						break;
					
					case ThingTypeFlags3.HAS_LIGHT:
						thing.hasLight = true;
						thing.lightLevel = bytes.readUnsignedShort();
						thing.lightColor = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.DONT_HIDE:
						thing.dontHide = true;
						break;
					
					case ThingTypeFlags3.TRANSLUCENT:
						thing.isTranslucent = true;
						break;
					
					case ThingTypeFlags3.HAS_OFFSET:
						thing.hasOffset = true;
						thing.offsetX = bytes.readUnsignedShort();
						thing.offsetY = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.HAS_ELEVATION:
						thing.hasElevation = true;
						thing.elevation = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.LYING_OBJECT:
						thing.isLyingObject = true;
						break;
					
					case ThingTypeFlags3.ANIMATE_ALWAYS:
						thing.animateAlways = true;
						break;
					
					case ThingTypeFlags3.MINI_MAP:
						thing.miniMap = true;
						thing.miniMapColor = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.LENS_HELP:
						thing.isLensHelp = true;
						thing.lensHelp = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.FULL_GROUND:
						thing.isFullGround = true;
						break;
					
					case ThingTypeFlags3.IGNORE_LOOK:
						thing.ignoreLook = true;
						break;
					
					case ThingTypeFlags3.CLOTH:
						thing.cloth = true;
						thing.clothSlot = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.MARKET_ITEM:
						thing.isMarketItem = true;
						thing.marketCategory = bytes.readUnsignedShort();
						thing.marketTradeAs = bytes.readUnsignedShort();
						thing.marketShowAs = bytes.readUnsignedShort();
						nameLength = bytes.readUnsignedShort();
						thing.marketName = bytes.readMultiByte(nameLength, ThingTypeStorage.STRING_CHARSET);
						thing.marketRestrictProfession = bytes.readUnsignedShort();
						thing.marketRestrictLevel = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.DEFAULT_ACTION:
						thing.hasDefaultAction = true;
						thing.defaultAction = bytes.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.USABLE:
						thing.usable = true;
						break;
					
					default:
						throw new Error(StringUtil.substitute("Unknown flag. flag=0x{0}, previous=0x{1}, category={2}, id={3}",
							flag.toString(16), previusFlag.toString(16), thing.category, thing.id));
						break;
				}
			}
			return true;
		}
		
		static private function readThingSprites(thing:ThingType, bytes:ByteArray) : ThingData
		{
			var totalSprites : uint;
			var i : int;
			var length : uint;
			var spriteId : uint;
			var sprites : Vector.<SpriteData>;
			var pixels : ByteArray;
			var bitmap : BitmapData;
			var spriteData : SpriteData;
			
			thing.width  = bytes.readUnsignedByte();
			thing.height = bytes.readUnsignedByte();
			
			if (thing.width > 1 || thing.height > 1)
			{
				thing.exactSize = bytes.readUnsignedByte();
			}
			else 
			{
				thing.exactSize = Sprite.SPRITE_PIXELS;
			}
			
			thing.layers = bytes.readUnsignedByte();
			thing.patternX = bytes.readUnsignedByte();
			thing.patternY = bytes.readUnsignedByte();
			thing.patternZ = bytes.readUnsignedByte();
			thing.frames = bytes.readUnsignedByte();
			
			totalSprites = thing.width * thing.height * thing.layers * thing.patternX * thing.patternY * thing.patternZ * thing.frames;
			if (totalSprites > 4096)
			{
				throw new Error("Thing has more than 4096 sprites.");
			}
			
			thing.spriteIndex = new Vector.<uint>(totalSprites);
			sprites = new Vector.<SpriteData>(totalSprites);
			
			for (i = 0; i < totalSprites; i++)
			{
				spriteId = bytes.readUnsignedInt();
				length = bytes.readUnsignedInt();
				if (length > bytes.bytesAvailable)
				{
					throw new Error("Not enough data.")
				}
				
				thing.spriteIndex[i] = spriteId;
				pixels = new ByteArray();
				pixels.endian = Endian.BIG_ENDIAN;
				bytes.readBytes(pixels, 0, length);
				pixels.position = 0;
				spriteData = new SpriteData();
				spriteData.id = spriteId;
				spriteData.pixels = pixels;
				sprites[i] = spriteData;
			}
			return new ThingData(thing, sprites);
		}
	}
}
