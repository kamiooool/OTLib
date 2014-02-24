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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import nail.otlib.assets.AssetsVersion;
	import nail.otlib.sprites.Sprite;
	import nail.otlib.utils.ThingUtils;
	import nail.utils.StringUtil;
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="change", type="flash.events.Event")]
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class ThingTypeStorage extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _signature : uint;
		
		private var _items : Dictionary;
		
		private var _itemsCount : uint;
		
		private var _outfits : Dictionary;
		
		private var _outfitsCount : uint;
		
		private var _effects : Dictionary;
		
		private var _effectsCount : uint;
		
		private var _missiles : Dictionary;
		
		private var _missilesCount : uint;
		
		private var _thingsCount : uint;
		
		private var _progressCount : uint; 
		
		private var _loading : Boolean;
		
		private var _loaded : Boolean;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function ThingTypeStorage()
		{
			
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  Public
		//---------------------------------- 
		
		public function load(file:File, version:AssetsVersion) : void
		{
			var stream : FileStream;
			
			if (file == null) 
			{
				throw new ArgumentError("Parameter file cannot be null.");
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
			
			try
			{
				stream = new FileStream();
				stream.open(file, FileMode.READ);
				stream.endian = Endian.LITTLE_ENDIAN;
				readBytes(stream, version);
				stream.close();
			} 
			catch(error:Error)
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.getStackTrace(), error.errorID));
				return;
			}
			
			_loading = false;
			_loaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function createNew(version:AssetsVersion) : Boolean
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
			
			_items = new Dictionary();
			_outfits = new Dictionary();
			_effects = new Dictionary();
			_missiles = new Dictionary();
			_signature = version.datSignature;
			_itemsCount = MIN_ITEM_ID;
			_outfitsCount = MIN_OUTFIT_ID;
			_effectsCount = MIN_EFFECT_ID;
			_missilesCount = MIN_MISSILE_ID;
			
			_loading = false;
			_loaded = true;
			
			insert(ThingUtils.createThing(ThingCategory.ITEM));
			insert(ThingUtils.createThing(ThingCategory.OUTFIT));
			insert(ThingUtils.createThing(ThingCategory.EFFECT));
			insert(ThingUtils.createThing(ThingCategory.MISSILE));
			
			return true;
		}
		
		public function insert(thing:ThingType, index:int = -1) : Boolean
		{
			if (thing == null)
			{
				throw new ArgumentError("Parameter thing cannot be null.");
			}
			
			switch(thing.category)
			{
				case ThingCategory.ITEM:
				{	
					if (index == -1)
					{
						index = _itemsCount;
					}
					_items[index] = thing;
					break;
				}
				
				case ThingCategory.OUTFIT:
				{		
					if (index == -1)
					{
						index = _outfitsCount;
					}
					_outfits[index] = thing;
					break;
				}
				
				case ThingCategory.EFFECT:
				{
					if (index == -1)
					{
						index = _effectsCount;
					}
					_effects[index] = thing;
					break;
				}
				
				case ThingCategory.MISSILE:
				{
					if (index == -1)
					{
						index = _missilesCount;
					}
					_missiles[index] = thing;
					break;
				}
				
				default:
				{
					return false;
				}
			}
			
			thing.id = index;
			dispatchEvent(new Event(Event.CHANGE));
			return true;
		}
		
		public function replace(thing:ThingType, category:String, id:uint) : Boolean
		{
			if (thing == null || !hasThingType(category, id))
			{
				return false;
			}
			
			switch(category)
			{
				case ThingCategory.ITEM:
				{
					_items[id] = thing;
					break;
				}
				
				case ThingCategory.OUTFIT:
				{
					_outfits[id] = thing;
					break;
				}
				
				case ThingCategory.EFFECT:
				{
					_effects[id] = thing;
					break;
				}
				
				case ThingCategory.MISSILE:
				{
					_missiles[id] = thing;
					break;
				}
				
				default:
					return false;
			}
			
			thing.category = category;
			thing.id = id;
			
			dispatchEvent(new Event(Event.CHANGE));
			return true;
		}
		
		public function addThing(thing:ThingType, category:String) : Boolean
		{
			var id : int;
			
			if (thing == null || ThingCategory.getCategory(category) == null)
			{ 
				return false;
			}
			
			switch(category)
			{
				case ThingCategory.ITEM:
				{
					_itemsCount++;
					id = _itemsCount;
					_items[id] = thing;
					break;
				}
				
				case ThingCategory.OUTFIT:
				{
					_outfitsCount++;
					id = _outfitsCount;
					_outfits[id] = thing;
					break;
				}
				
				case ThingCategory.EFFECT:
				{		
					_effectsCount++;
					id = _effectsCount;
					_effects[id] = thing;
					break;
				}
				
				case ThingCategory.MISSILE:
				{
					_missilesCount++;
					id = _missilesCount;
					_missiles[id] = thing;
					break;
				}
				
				default:
					return false;
			}
			
			thing.category = category;
			thing.id = id;
			dispatchEvent(new Event(Event.CHANGE));
			return true;
		}
		
		public function removeThing(id:uint, category:String) : Boolean
		{
			var thing : ThingType;
			
			if (isNullOrEmpty(category))
			{
				throw new ArgumentError("Parameter category cannot be null or empty.");
			}
			
			if (ThingCategory.getCategory(category) == null)
			{
				throw new Error(StringUtil.substitute("Invalid category {0}.", category));
			}
			
			if (!hasThingType(category, id))
			{
				throw new Error(StringUtil.substitute("{0} id {1} not found.",
					StringUtil.capitaliseFirstLetter(category), id));
			}
			
			switch(category)
			{
				case ThingCategory.ITEM:
				{
					_itemsCount = onRemoveThing(id, category, _items, _itemsCount);
					break;
				}
					
				case ThingCategory.OUTFIT:
				{
					_outfitsCount = onRemoveThing(id, category, _outfits, _outfitsCount);
					break;
				}
					
				case ThingCategory.EFFECT:
				{
					_effectsCount = onRemoveThing(id, category, _effects, _effectsCount);
					break;
				}
					
				case ThingCategory.MISSILE:
				{
					_missilesCount = onRemoveThing(id, category, _missiles, _missilesCount);
					break;
				}
			}
			
			if (hasEventListener(Event.CHANGE))
			{
				dispatchEvent(new Event(Event.CHANGE))
			}
			
			return true;
		}
		
		public function compile(file:File, version:AssetsVersion) : Boolean
		{
			var stream : FileStream;
			
			if (file == null)
			{
				throw new ArgumentError("Parameter file cannot be null.");
			}
			
			if (version == null)
			{
				throw new ArgumentError("Parameter version cannot be null.");
			}
			
			if (!_loaded)
			{
				return false;
			}
			
			_thingsCount = _itemsCount + _outfitsCount + _effectsCount + _missilesCount;
			_progressCount = 0;
			
			stream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.endian = Endian.LITTLE_ENDIAN;
			stream.writeUnsignedInt(version.datSignature); // Write sprite signature
			stream.writeShort(_itemsCount); // Write items count
			stream.writeShort(_outfitsCount); // Write outfits count
			stream.writeShort(_effectsCount); // Write effects count
			stream.writeShort(_missilesCount); // Write missiles count
			writeThingList(stream, _items, MIN_ITEM_ID, _itemsCount, version, true);
			writeThingList(stream, _outfits, MIN_OUTFIT_ID, _outfitsCount, version);
			writeThingList(stream, _effects, MIN_EFFECT_ID, _effectsCount, version);
			writeThingList(stream, _missiles, MIN_MISSILE_ID, _missilesCount, version);
			stream.close();
			return true;
		}
		
		public function hasThingType(category:String, id:uint) : Boolean
		{
			return getThingType(id, category) != null;
		}
		
		public function getThingType(id:uint, category:String) : ThingType 
		{
			if (_loaded && category != null)
			{
				switch(category)
				{
					case ThingCategory.ITEM:
						return getItemType(id);
					case ThingCategory.OUTFIT:
						return getOutfitType(id);
					case ThingCategory.EFFECT:
						return getEffectType(id);
					case ThingCategory.MISSILE:
						return getMissileType(id);
				}	
			}
			return null;
		}
		
		public function getItemType(id:uint) : ThingType
		{
			if (loaded && id >= MIN_ITEM_ID && id <= _itemsCount && _items[id] !== undefined)
			{
				return ThingType(_items[id]);
			}
			return null;
		}
		
		public function getOutfitType(id:uint) : ThingType
		{
			if (loaded && id >= MIN_OUTFIT_ID && id <= _outfitsCount && _outfits[id] !== undefined)
			{
				return ThingType(_outfits[id]);
			}
			return null;
		}
		
		public function getEffectType(id:uint) : ThingType
		{
			if (loaded && id >= MIN_EFFECT_ID && id <= _effectsCount && _effects[id] !== undefined)
			{
				return ThingType(_effects[id]);
			}
			return null;
		}
		
		public function getMissileType(id:uint) : ThingType
		{
			if (loaded && id >= MIN_MISSILE_ID && id <= _missilesCount && _missiles[id] !== undefined)
			{
				return ThingType(_missiles[id]);
			}
			return null;
		}
		
		public function getCategoryCount(category:String) : uint
		{
			if (_loaded && ThingCategory.getCategory(category) != null)
			{
				switch(category)
				{
					case ThingCategory.ITEM:
						return _itemsCount;
					case ThingCategory.OUTFIT:
						return _outfitsCount;
					case ThingCategory.EFFECT:
						return _effectsCount;
					case ThingCategory.MISSILE:
						return _missilesCount;
				}	
			}
			return 0;
		}
		
		public function clear() : void
		{
			_items = null;
			_itemsCount = 0;
			_outfits = null;
			_outfitsCount = 0;
			_effects = null;
			_effectsCount = 0;
			_missiles = null;
			_missilesCount = 0;
			_signature = 0;
			_progressCount = 0;
			_thingsCount = 0;
			_loading = false;
			_loaded = false;
		}
		
		//--------------------------------------
		// Protected
		//--------------------------------------
		
		protected function readBytes(stream:FileStream, version:AssetsVersion) : void
		{
			if (stream.bytesAvailable < 12)
			{
				throw new ArgumentError("Não há dados suficientes.");
			}
			
			_items = new Dictionary();
			_outfits = new Dictionary();
			_effects = new Dictionary();
			_missiles = new Dictionary();
			_signature = stream.readUnsignedInt();
			_itemsCount = stream.readUnsignedShort();
			_outfitsCount = stream.readUnsignedShort();
			_effectsCount = stream.readUnsignedShort();
			_missilesCount = stream.readUnsignedShort();
			_thingsCount = _itemsCount + _outfitsCount + _effectsCount + _missilesCount;
			_progressCount = 0;
			
			// Load item list.
			if (loadThingTypeList(stream, version, _items, MIN_ITEM_ID, _itemsCount, ThingCategory.ITEM) == false)
			{
				throw new Error("Items list cannot be created.");
			}
			
			// Load outfit list.
			if (loadThingTypeList(stream, version, _outfits, MIN_OUTFIT_ID, _outfitsCount, ThingCategory.OUTFIT) == false)
			{
				throw new Error("Outfits list cannot be created.");
			}
			
			// Load effect list.
			if (loadThingTypeList(stream, version, _effects, MIN_EFFECT_ID, _effectsCount, ThingCategory.EFFECT) == false)
			{
				throw new Error("Effects list cannot be created.");
			}
			
			// Load missile list.
			if (loadThingTypeList(stream, version, _missiles, MIN_MISSILE_ID, _missilesCount, ThingCategory.MISSILE) == false)
			{
				throw new Error("Missiles list cannot be created.");
			}
			
			if (stream.bytesAvailable != 0)
			{
				throw new Error("An unknown error occurred while reading the file '*.dat'");
			}
		}
		
		protected function loadThingTypeList(stream:FileStream, version:AssetsVersion, list:Dictionary, minID:uint, maxID:uint, category:String) : Boolean
		{
			var thing : ThingType;
			var id : int;
			var oldVersions : Boolean;
			var newVersions : Boolean;
			var dispatchProgress : Boolean;
			var isU32 : Boolean;
			
			oldVersions = (version.value <= 854);
			newVersions = (version.value >= 1010);
			isU32 = (version.value >= 960);
			dispatchProgress = this.hasEventListener(ProgressEvent.PROGRESS);
			
			for (id = minID; id <= maxID; id++)
			{
				thing = new ThingType();
				thing.id = id;
				thing.category = category;
				
				if (newVersions)
				{
					if (!readThingType3(thing, stream))
					{
						return false;
					}
				}
				else if (oldVersions)
				{
					if (!readThingType1(thing, stream))
					{
						return false;
					}
				}
				else 
				{
					if (!readThingType2(thing, stream))
					{
						return false;
					}
				}
				
				if (!readThingSprites(thing, isU32, stream))
				{
					return false;
				}
				
				list[id] = thing;
				
				if (dispatchProgress)
				{
					dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _progressCount, _thingsCount));
					_progressCount++;
				}
			}
			
			return true;
		}
		
		/**
		 * Read versions 8.0 - 8.54
		 */
		protected function readThingType1(thing:ThingType, stream:FileStream) : Boolean
		{
			var flag : uint;
			var index : uint; 
			var nameLength : uint;
			var totalSprites : uint;
			var previusFlag : uint; 
			
			while (flag < ThingTypeFlags1.LAST_FLAG)
			{
				previusFlag = flag;
				flag = stream.readUnsignedByte();
				
				if (flag == ThingTypeFlags1.LAST_FLAG)
				{
					return true;
				}
				
				switch (flag)
				{
					case ThingTypeFlags1.GROUND:
						thing.isGround = true;
						thing.groundSpeed = stream.readUnsignedShort();
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
						thing.maxTextLength = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.WRITABLE_ONCE:
						thing.writableOnce = true;
						thing.maxTextLength = stream.readUnsignedShort();
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
						thing.lightLevel = stream.readUnsignedShort();
						thing.lightColor = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.DONT_HIDE:
						thing.dontHide = true;
						break;
					
					case ThingTypeFlags1.FLOOR_CHANGE:
						thing.floorChange = true;
						break;
					
					case ThingTypeFlags1.HAS_OFFSET:
						thing.hasOffset = true;
						thing.offsetX = stream.readUnsignedShort();
						thing.offsetY = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.HAS_ELEVATION:
						thing.hasElevation = true;
						thing.elevation = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.LYING_OBJECT:
						thing.isLyingObject = true;
						break;
					
					case ThingTypeFlags1.ANIMATE_ALWAYS:
						thing.animateAlways = true;
						break;
					
					case ThingTypeFlags1.MINI_MAP:
						thing.miniMap = true;
						thing.miniMapColor = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags1.LENS_HELP:
						thing.isLensHelp = true;
						thing.lensHelp = stream.readUnsignedShort();
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
		protected function readThingType2(thing:ThingType, stream:FileStream) : Boolean
		{
			var flag : uint;
			var index : uint; 
			var nameLength : uint;
			var totalSprites : uint;
			var previusFlag : uint; 
			
			while (flag < ThingTypeFlags2.LAST_FLAG)
			{
				previusFlag = flag;
				flag = stream.readUnsignedByte();
				
				if (flag == ThingTypeFlags2.LAST_FLAG)
				{
					return true;
				}
				
				switch (flag)
				{
					case ThingTypeFlags2.GROUND:
						thing.isGround    = true;
						thing.groundSpeed = stream.readUnsignedShort();
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
						thing.writable   = true;
						thing.maxTextLength = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.WRITABLE_ONCE:
						thing.writableOnce = true;
						thing.maxTextLength   = stream.readUnsignedShort();
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
						thing.hasLight   = true;
						thing.lightLevel = stream.readUnsignedShort();
						thing.lightColor = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.DONT_HIDE:
						thing.dontHide = true;
						break;
					
					case ThingTypeFlags2.TRANSLUCENT:
						thing.isTranslucent = true;
						break;
					
					case ThingTypeFlags2.HAS_OFFSET:
						thing.hasOffset = true;
						thing.offsetX   = stream.readUnsignedShort();
						thing.offsetY   = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.HAS_ELEVATION:
						thing.hasElevation = true;
						thing.elevation    = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.LYING_OBJECT:
						thing.isLyingObject = true;
						break;
					
					case ThingTypeFlags2.ANIMATE_ALWAYS:
						thing.animateAlways = true;
						break;
					
					case ThingTypeFlags2.MINI_MAP:
						thing.miniMap      = true;
						thing.miniMapColor = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.LENS_HELP:
						thing.isLensHelp = true;
						thing.lensHelp   = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.FULL_GROUND:
						thing.isFullGround = true;
						break;
					
					case ThingTypeFlags2.IGNORE_LOOK:
						thing.ignoreLook = true;
						break;
					
					case ThingTypeFlags2.CLOTH:
						thing.cloth     = true;
						thing.clothSlot = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags2.MARKET_ITEM:
						thing.isMarketItem = true;
						thing.marketCategory = stream.readUnsignedShort();
						thing.marketTradeAs = stream.readUnsignedShort();
						thing.marketShowAs = stream.readUnsignedShort();
						nameLength = stream.readUnsignedShort();
						thing.marketName = stream.readMultiByte(nameLength, STRING_CHARSET);
						thing.marketRestrictProfession = stream.readUnsignedShort();
						thing.marketRestrictLevel = stream.readUnsignedShort();
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
		protected function readThingType3(thing:ThingType, stream:FileStream) : Boolean
		{
			var flag : uint;
			var index : uint; 
			var nameLength : uint;
			var totalSprites : uint;
			var previusFlag : uint; 
			
			while (flag < ThingTypeFlags3.LAST_FLAG)
			{
				previusFlag = flag;
				flag = stream.readUnsignedByte();
				
				if (flag == ThingTypeFlags3.LAST_FLAG)
				{
					return true;
				}
				
				switch (flag)
				{
					case ThingTypeFlags3.GROUND:
						thing.isGround    = true;
						thing.groundSpeed = stream.readUnsignedShort();
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
						thing.writable   = true;
						thing.maxTextLength = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.WRITABLE_ONCE:
						thing.writableOnce = true;
						thing.maxTextLength   = stream.readUnsignedShort();
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
						thing.hasLight   = true;
						thing.lightLevel = stream.readUnsignedShort();
						thing.lightColor = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.DONT_HIDE:
						thing.dontHide = true;
						break;
					
					case ThingTypeFlags3.TRANSLUCENT:
						thing.isTranslucent = true;
						break;
					
					case ThingTypeFlags3.HAS_OFFSET:
						thing.hasOffset = true;
						thing.offsetX   = stream.readUnsignedShort();
						thing.offsetY   = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.HAS_ELEVATION:
						thing.hasElevation = true;
						thing.elevation    = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.LYING_OBJECT:
						thing.isLyingObject = true;
						break;
					
					case ThingTypeFlags3.ANIMATE_ALWAYS:
						thing.animateAlways = true;
						break;
					
					case ThingTypeFlags3.MINI_MAP:
						thing.miniMap      = true;
						thing.miniMapColor = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.LENS_HELP:
						thing.isLensHelp = true;
						thing.lensHelp   = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.FULL_GROUND:
						thing.isFullGround = true;
						break;
					
					case ThingTypeFlags3.IGNORE_LOOK:
						thing.ignoreLook = true;
						break;
					
					case ThingTypeFlags3.CLOTH:
						thing.cloth     = true;
						thing.clothSlot = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.MARKET_ITEM:	
						thing.isMarketItem = true;
						thing.marketCategory = stream.readUnsignedShort();
						thing.marketTradeAs = stream.readUnsignedShort();
						thing.marketShowAs = stream.readUnsignedShort();
						nameLength = stream.readUnsignedShort();
						thing.marketName = stream.readMultiByte(nameLength, STRING_CHARSET);
						thing.marketRestrictProfession = stream.readUnsignedShort();
						thing.marketRestrictLevel = stream.readUnsignedShort();
						break;
					
					case ThingTypeFlags3.DEFAULT_ACTION:
						thing.hasDefaultAction = true;
						thing.defaultAction = stream.readUnsignedShort();
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
		
		protected function readThingSprites(thing:ThingType, isU32:Boolean, stream:FileStream) : Boolean
		{
			var totalSprites : uint; 
			var i : int;
			
			thing.width  = stream.readUnsignedByte();
			thing.height = stream.readUnsignedByte();
			
			if (thing.width > 1 || thing.height > 1)
			{
				thing.exactSize = stream.readUnsignedByte();
			}
			else 
			{
				thing.exactSize = Sprite.SPRITE_PIXELS;
			}
			
			thing.layers   = stream.readUnsignedByte();
			thing.patternX = stream.readUnsignedByte();
			thing.patternY = stream.readUnsignedByte();
			thing.patternZ = stream.readUnsignedByte();
			thing.frames   = stream.readUnsignedByte();
			
			totalSprites = thing.width * thing.height * thing.layers * thing.patternX * thing.patternY * thing.patternZ * thing.frames;			
			if (totalSprites > 4096)
			{
				throw new Error("A thing type has more than 4096 sprites.");
			}
			
			thing.spriteIndex = new Vector.<uint>(totalSprites);
			
			for (i = 0; i < totalSprites; i++)
			{
				if (isU32)
				{
					thing.spriteIndex[i] = stream.readUnsignedInt();
				}
				else 
				{
					thing.spriteIndex[i] = stream.readUnsignedShort();
				}
			}	
			
			return true;
		}
		
		protected function writeThingList(stream:FileStream, list:Dictionary, minId:uint, maxId:uint, version:AssetsVersion, isItems:Boolean = false) : void
		{
			var i : int;
			var thing : ThingType;
			var oldVersions : Boolean;
			var newVersions : Boolean;
			var dispatchProgress : Boolean;
			var isU32 : Boolean;
			
			oldVersions = (version.value <= 854);
			newVersions = (version.value >= 1010);
			isU32 = (version.value >= 960);
			dispatchProgress = this.hasEventListener(ProgressEvent.PROGRESS);
			
			for (i = minId; i <= maxId; i++)
			{
				thing = list[i];
				if (thing)
				{
					if (newVersions)
					{
						writeProperties3(stream, thing);
					}
					else if (oldVersions)
					{
						writeProperties1(stream, thing);
					}
					else 
					{
						writeProperties2(stream, thing);
					}
						
					writeSprites(stream, thing, isU32);
				}
				else
				{
					stream.writeByte(ThingTypeFlags2.LAST_FLAG); // Close flags
				}
				
				if (dispatchProgress)
				{
					dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _progressCount, _thingsCount));
					_progressCount++;
				}
			}
		}
		
		/**
		 * Write versions 8.00 - 8.54
		 */
		protected function writeProperties1(stream:FileStream, thing:ThingType) : Boolean
		{
			if (thing.isGround)
			{
				stream.writeByte(ThingTypeFlags1.GROUND);
				stream.writeShort(thing.groundSpeed);
			}
			else if (thing.isGroundBorder)
			{ 
				stream.writeByte(ThingTypeFlags1.GROUND_BORDER);
			}
			else if (thing.isOnBottom)
			{
				stream.writeByte(ThingTypeFlags1.ON_BOTTOM);
			}
			else if (thing.isOnTop)
			{
				stream.writeByte(ThingTypeFlags1.ON_TOP);
			}
			
			if (thing.isContainer) { stream.writeByte(ThingTypeFlags1.CONTAINER); }
			if (thing.stackable) { stream.writeByte(ThingTypeFlags1.STACKABLE); }
			if (thing.forceUse) { stream.writeByte(ThingTypeFlags1.FORCE_USE); }
			if (thing.multiUse) { stream.writeByte(ThingTypeFlags1.MULTI_USE); }
			if (thing.hasCharges) { stream.writeByte(ThingTypeFlags1.HAS_CHARGES) };
			
			if (thing.writable)
			{
				stream.writeByte(ThingTypeFlags1.WRITABLE);
				stream.writeShort(thing.maxTextLength);
			}
			
			if (thing.writableOnce)
			{
				stream.writeByte(ThingTypeFlags1.WRITABLE_ONCE);
				stream.writeShort(thing.maxTextLength);
			}	
			
			if (thing.isFluidContainer) { stream.writeByte(ThingTypeFlags1.FLUID_CONTAINER); }
			if (thing.isFluid) { stream.writeByte(ThingTypeFlags1.FLUID); }
			if (thing.isUnpassable) { stream.writeByte(ThingTypeFlags1.UNPASSABLE); }
			if (thing.isUnmoveable) { stream.writeByte(ThingTypeFlags1.UNMOVEABLE); }
			if (thing.blockMissile) { stream.writeByte(ThingTypeFlags1.BLOCK_MISSILE); }
			if (thing.blockPathfind) { stream.writeByte(ThingTypeFlags1.BLOCK_PATHFIND); }
			if (thing.pickupable) { stream.writeByte(ThingTypeFlags1.PICKUPABLE); }
			if (thing.hangable) { stream.writeByte(ThingTypeFlags1.HANGABLE); }
			if (thing.isVertical) { stream.writeByte(ThingTypeFlags1.VERTICAL); }
			if (thing.isHorizontal) { stream.writeByte(ThingTypeFlags1.HORIZONTAL); }
			if (thing.rotatable) { stream.writeByte(ThingTypeFlags1.ROTATABLE); }
			
			if (thing.hasLight)
			{
				stream.writeByte(ThingTypeFlags1.HAS_LIGHT);
				stream.writeShort(thing.lightLevel);
				stream.writeShort(thing.lightColor);
			}
			
			if (thing.dontHide) { stream.writeByte(ThingTypeFlags1.DONT_HIDE); }
			if (thing.floorChange) { stream.writeByte(ThingTypeFlags1.FLOOR_CHANGE); }
			
			if (thing.hasOffset)
			{
				stream.writeByte(ThingTypeFlags1.HAS_OFFSET);
				stream.writeShort(thing.offsetX);
				stream.writeShort(thing.offsetY);
			}
			
			if (thing.hasElevation)
			{
				stream.writeByte(ThingTypeFlags1.HAS_ELEVATION);
				stream.writeShort(thing.elevation);
			}
			
			if (thing.isLyingObject) { stream.writeByte(ThingTypeFlags1.LYING_OBJECT); }
			if (thing.animateAlways) { stream.writeByte(ThingTypeFlags1.ANIMATE_ALWAYS); }
			
			if (thing.miniMap)
			{
				stream.writeByte(ThingTypeFlags1.MINI_MAP);
				stream.writeShort(thing.miniMapColor);
			}
			if (thing.isLensHelp)
			{
				stream.writeByte(ThingTypeFlags1.LENS_HELP);
				stream.writeShort(thing.lensHelp);
			}
			if (thing.isFullGround) { stream.writeByte(ThingTypeFlags1.FULL_GROUND); }
			if (thing.ignoreLook) { stream.writeByte(ThingTypeFlags1.IGNORE_LOOK); }
			
			stream.writeByte(ThingTypeFlags1.LAST_FLAG); // Close flags
			return true;
		}
		
		/**
		 * Write versions 8.60 - 9.86
		 */
		protected function writeProperties2(stream:FileStream, thing:ThingType) : Boolean
		{
			if (thing.isGround)
			{
				stream.writeByte(ThingTypeFlags2.GROUND); 
				stream.writeShort(thing.groundSpeed);
			}
			else if (thing.isGroundBorder)
			{ 
				stream.writeByte(ThingTypeFlags2.GROUND_BORDER);
			}
			else if (thing.isOnBottom)
			{
				stream.writeByte(ThingTypeFlags2.ON_BOTTOM);
			}
			else if (thing.isOnTop)
			{
				stream.writeByte(ThingTypeFlags2.ON_TOP);
			}
			
			if (thing.isContainer) { stream.writeByte(ThingTypeFlags2.CONTAINER); }
			if (thing.stackable) { stream.writeByte(ThingTypeFlags2.STACKABLE); }
			if (thing.forceUse) { stream.writeByte(ThingTypeFlags2.FORCE_USE); }
			if (thing.multiUse) { stream.writeByte(ThingTypeFlags2.MULTI_USE); }
			
			if (thing.writable)
			{
				stream.writeByte(ThingTypeFlags2.WRITABLE);
				stream.writeShort(thing.maxTextLength);
			}
			
			if (thing.writableOnce)
			{
				stream.writeByte(ThingTypeFlags2.WRITABLE_ONCE);
				stream.writeShort(thing.maxTextLength);
			}	
			
			if (thing.isFluidContainer) { stream.writeByte(ThingTypeFlags2.FLUID_CONTAINER); }
			if (thing.isFluid) { stream.writeByte(ThingTypeFlags2.FLUID); }
			if (thing.isUnpassable) { stream.writeByte(ThingTypeFlags2.UNPASSABLE); }
			if (thing.isUnmoveable) { stream.writeByte(ThingTypeFlags2.UNMOVEABLE); }
			if (thing.blockMissile) { stream.writeByte(ThingTypeFlags2.BLOCK_MISSILE); }
			if (thing.blockPathfind) { stream.writeByte(ThingTypeFlags2.BLOCK_PATHFIND); }
			if (thing.pickupable) { stream.writeByte(ThingTypeFlags2.PICKUPABLE); }
			if (thing.hangable) { stream.writeByte(ThingTypeFlags2.HANGABLE); }
			if (thing.isVertical) { stream.writeByte(ThingTypeFlags2.VERTICAL); }
			if (thing.isHorizontal) { stream.writeByte(ThingTypeFlags2.HORIZONTAL); }
			if (thing.rotatable) { stream.writeByte(ThingTypeFlags2.ROTATABLE); }
			
			if (thing.hasLight)
			{
				stream.writeByte(ThingTypeFlags2.HAS_LIGHT);
				stream.writeShort(thing.lightLevel);
				stream.writeShort(thing.lightColor);
			}
			
			if (thing.dontHide) { stream.writeByte(ThingTypeFlags2.DONT_HIDE); }
			if (thing.isTranslucent) { stream.writeByte(ThingTypeFlags2.TRANSLUCENT); }
			
			if (thing.hasOffset)
			{
				stream.writeByte(ThingTypeFlags2.HAS_OFFSET);
				stream.writeShort(thing.offsetX);
				stream.writeShort(thing.offsetY);
			}
			
			if (thing.hasElevation)
			{
				stream.writeByte(ThingTypeFlags2.HAS_ELEVATION);
				stream.writeShort(thing.elevation);
			}
			
			if (thing.isLyingObject) { stream.writeByte(ThingTypeFlags2.LYING_OBJECT); }
			if (thing.animateAlways) { stream.writeByte(ThingTypeFlags2.ANIMATE_ALWAYS); }
			
			if (thing.miniMap)
			{
				stream.writeByte(ThingTypeFlags2.MINI_MAP);
				stream.writeShort(thing.miniMapColor);
			}
			if (thing.isLensHelp)
			{
				stream.writeByte(ThingTypeFlags2.LENS_HELP);
				stream.writeShort(thing.lensHelp);
			}
			if (thing.isFullGround) { stream.writeByte(ThingTypeFlags2.FULL_GROUND); }
			if (thing.ignoreLook) { stream.writeByte(ThingTypeFlags2.IGNORE_LOOK); }
			if (thing.cloth)
			{
				stream.writeByte(ThingTypeFlags2.CLOTH);
				stream.writeShort(thing.clothSlot);
			}
			
			if (thing.isMarketItem)
			{
				stream.writeByte(ThingTypeFlags2.MARKET_ITEM);
				stream.writeShort(thing.marketCategory);
				stream.writeShort(thing.marketTradeAs);
				stream.writeShort(thing.marketShowAs);
				stream.writeShort(thing.marketName.length);
				stream.writeMultiByte(thing.marketName, STRING_CHARSET);
				stream.writeShort(thing.marketRestrictProfession);
				stream.writeShort(thing.marketRestrictLevel);
			}
			
			stream.writeByte(ThingTypeFlags2.LAST_FLAG); // Close flags
			return true;
		}
		
		/**
		 * Write versions 10.10+
		 */
		protected function writeProperties3(stream:FileStream, thing:ThingType) : Boolean
		{
			if (thing.isGround)
			{
				stream.writeByte(ThingTypeFlags3.GROUND);
				stream.writeShort(thing.groundSpeed);
			}
			else if (thing.isGroundBorder)
			{ 
				stream.writeByte(ThingTypeFlags3.GROUND_BORDER);
			}
			else if (thing.isOnBottom)
			{
				stream.writeByte(ThingTypeFlags3.ON_BOTTOM);
			}
			else if (thing.isOnTop)
			{
				stream.writeByte(ThingTypeFlags3.ON_TOP);
			}
			
			if (thing.isContainer) { stream.writeByte(ThingTypeFlags3.CONTAINER); }
			if (thing.stackable) { stream.writeByte(ThingTypeFlags3.STACKABLE); }
			if (thing.forceUse) { stream.writeByte(ThingTypeFlags3.FORCE_USE); }
			if (thing.multiUse) { stream.writeByte(ThingTypeFlags3.MULTI_USE); }
			
			if (thing.writable)
			{
				stream.writeByte(ThingTypeFlags3.WRITABLE);
				stream.writeShort(thing.maxTextLength);
			}
			
			if (thing.writableOnce)
			{
				stream.writeByte(ThingTypeFlags3.WRITABLE_ONCE);
				stream.writeShort(thing.maxTextLength);
			}
			
			if (thing.isFluidContainer) { stream.writeByte(ThingTypeFlags3.FLUID_CONTAINER); }
			if (thing.isFluid) { stream.writeByte(ThingTypeFlags3.FLUID); }
			if (thing.isUnpassable) { stream.writeByte(ThingTypeFlags3.UNPASSABLE); }
			if (thing.isUnmoveable) { stream.writeByte(ThingTypeFlags3.UNMOVEABLE); }
			if (thing.blockMissile) { stream.writeByte(ThingTypeFlags3.BLOCK_MISSILE); }
			if (thing.blockPathfind) { stream.writeByte(ThingTypeFlags3.BLOCK_PATHFIND); }
			if (thing.noMoveAnimation) {  stream.writeByte(ThingTypeFlags3.NO_MOVE_ANIMATION); }
			if (thing.pickupable) { stream.writeByte(ThingTypeFlags3.PICKUPABLE); }
			if (thing.hangable) { stream.writeByte(ThingTypeFlags3.HANGABLE); }
			if (thing.isVertical) { stream.writeByte(ThingTypeFlags3.VERTICAL); }
			if (thing.isHorizontal) { stream.writeByte(ThingTypeFlags3.HORIZONTAL); }
			if (thing.rotatable) { stream.writeByte(ThingTypeFlags3.ROTATABLE); }
			
			if (thing.hasLight)
			{
				stream.writeByte(ThingTypeFlags3.HAS_LIGHT);
				stream.writeShort(thing.lightLevel);
				stream.writeShort(thing.lightColor);
			}
			
			if (thing.dontHide) { stream.writeByte(ThingTypeFlags3.DONT_HIDE); }
			if (thing.isTranslucent) { stream.writeByte(ThingTypeFlags3.TRANSLUCENT); }	
			
			if (thing.hasOffset)
			{
				stream.writeByte(ThingTypeFlags3.HAS_OFFSET);
				stream.writeShort(thing.offsetX);
				stream.writeShort(thing.offsetY);
			}
			
			if (thing.hasElevation)
			{
				stream.writeByte(ThingTypeFlags3.HAS_ELEVATION);
				stream.writeShort(thing.elevation);
			}
			
			if (thing.isLyingObject) { stream.writeByte(ThingTypeFlags3.LYING_OBJECT); }
			
			if (thing.animateAlways) { stream.writeByte(ThingTypeFlags3.ANIMATE_ALWAYS); }
			
			if (thing.miniMap)
			{
				stream.writeByte(ThingTypeFlags3.MINI_MAP);
				stream.writeShort(thing.miniMapColor);
			}
			if (thing.isLensHelp)
			{
				stream.writeByte(ThingTypeFlags3.LENS_HELP);
				stream.writeShort(thing.lensHelp);
			}
			if (thing.isFullGround) { stream.writeByte(ThingTypeFlags3.FULL_GROUND); }
			if (thing.ignoreLook) { stream.writeByte(ThingTypeFlags3.IGNORE_LOOK); }
			if (thing.cloth)
			{
				stream.writeByte(ThingTypeFlags3.CLOTH);
				stream.writeShort(thing.clothSlot);
			}
			
			if (thing.isMarketItem)
			{
				stream.writeByte(ThingTypeFlags3.MARKET_ITEM);
				stream.writeShort(thing.marketCategory);
				stream.writeShort(thing.marketTradeAs);
				stream.writeShort(thing.marketShowAs);
				stream.writeShort(thing.marketName.length);
				stream.writeMultiByte(thing.marketName, STRING_CHARSET);
				stream.writeShort(thing.marketRestrictProfession);
				stream.writeShort(thing.marketRestrictLevel);
			}
			
			if (thing.hasDefaultAction)
			{
				stream.writeByte(ThingTypeFlags3.DEFAULT_ACTION);
				stream.writeShort(thing.defaultAction); 
			}
			
			if (thing.usable)
			{
				stream.writeByte(ThingTypeFlags3.USABLE);
			}
			
			stream.writeByte(ThingTypeFlags3.LAST_FLAG); // Close flags
			return true;
		}
		
		protected function writeSprites(stream:FileStream, thing:ThingType, isU32:Boolean) : Boolean
		{ 
			var length : uint;
			var i : int;
			var spriteIndex : Vector.<uint>;
			 
			stream.writeByte(thing.width);  // Write width	
			stream.writeByte(thing.height); // Write height	
			
			if (thing.width > 1 || thing.height > 1)
			{
				stream.writeByte(thing.exactSize); // Write exact size
			}
			
			stream.writeByte(thing.layers);   // Write layers
			stream.writeByte(thing.patternX); // Write pattern X
			stream.writeByte(thing.patternY); // Write pattern Y
			stream.writeByte(thing.patternZ); // Write pattern Z
			stream.writeByte(thing.frames);   // Write frames
			
			spriteIndex = thing.spriteIndex;
			length = spriteIndex.length;
			
			for (i = 0; i < length; i++)
			{
				// Write sprite index
				if (isU32)
				{
					stream.writeUnsignedInt(spriteIndex[i]); 
				}
				else
				{
					stream.writeShort(spriteIndex[i]);
				}
			}
			return true;
		}
		
		protected function onRemoveThing(id:uint, category:String, list:Dictionary, length:uint) : uint
		{
			var thing :ThingType;
			
			if (id == length)
			{
				delete list[id];
				length = Math.max(0, length - 1);
			}
			else 
			{
				thing = ThingUtils.createThing(category);
				thing.id = id;
				list[id] = thing;
			}
			return length;
		}
		
		//--------------------------------------
		// Getters / Setters
		//--------------------------------------
		
		public function get signature() : uint
		{
			return _signature;
		}
		
		public function get items() : Array
		{
			var list : Array;
			var thing : ThingType; 
			
			list = [];
			
			if (this.loaded)
			{
				for each (thing in _items)
				{
					list.push(thing);
				}
			}
			return list;
		}
		
		public function get outfits() : Array
		{
			var list : Array;
			var thing : ThingType; 
			
			list = [];
			
			if (this.loaded)
			{
				for each (thing in _outfits)
				{
					list.push(thing);
				}
			}
			return list;
		}
		
		public function get effects() : Array
		{
			var list : Array;
			var thing : ThingType; 
			
			list = [];
			
			if (this.loaded)
			{
				for each (thing in _effects)
				{
					list.push(thing);
				}
			}
			return list;
		}
		
		public function get missiles() : Array
		{
			var list : Array;
			var thing : ThingType; 
			
			list = [];
			
			if (this.loaded)
			{
				for each (thing in _missiles)
				{
					list.push(thing);
				}
			}
			return list;
		}
		
		public function get itemsCount() : uint
		{
			return _itemsCount;
		}
		
		public function get outfitsCount() : uint
		{
			return _outfitsCount;
		}		
		
		public function get effectsCount() : uint
		{
			return _effectsCount;
		}
		
		public function get missilesCount() : uint
		{
			return _missilesCount;
		}
		
		public function get loaded() : Boolean
		{
			return _loaded;
		}
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static public const MIN_ITEM_ID : uint = 100;
		
		static public const MIN_OUTFIT_ID : uint = 1;
		
		static public const MIN_EFFECT_ID : uint = 1;
		
		static public const MIN_MISSILE_ID : uint = 1;
		
		static public const STRING_CHARSET : String = "iso-8859-1";
	}
}
