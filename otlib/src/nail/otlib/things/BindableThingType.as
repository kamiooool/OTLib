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
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	
	import mx.events.PropertyChangeEvent;
	
	import nail.otlib.utils.SpriteData;
	import nail.otlib.utils.ThingData;

	public class BindableThingType extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		[Bindable]
		public var id : uint;
		
		[Bindable]
		public var category : String;
		
		[Bindable]
		public var width : uint;
		
		[Bindable]
		public var height : uint;
		
		[Bindable]
		public var exactSize : uint;
		
		[Bindable]
		public var layers : uint;
		
		[Bindable]
		public var patternX : uint;
		
		[Bindable]
		public var patternY : uint;
		
		[Bindable]
		public var patternZ : uint;
		
		[Bindable]
		public var frames : uint;
		
		public var spriteIndex : Vector.<uint>;
		
		[Bindable]
		public var isGround : Boolean;
		
		[Bindable]
		public var groundSpeed : uint;
		
		[Bindable]
		public var isGroundBorder : Boolean;
		
		[Bindable]
		public var isOnBottom : Boolean;
		
		[Bindable]
		public var isOnTop : Boolean;
		
		[Bindable]
		public var isContainer : Boolean;
		
		[Bindable]
		public var stackable : Boolean;
		
		[Bindable]
		public var forceUse : Boolean;
		
		[Bindable]
		public var multiUse : Boolean;
		
		[Bindable]
		public var writable : Boolean;
		
		[Bindable]
		public var writableOnce : Boolean;
		
		[Bindable]
		public var maxTextLength : uint;
		
		[Bindable]
		public var isFluidContainer : Boolean;
		
		[Bindable]
		public var isFluid : Boolean;
		
		[Bindable]
		public var isUnpassable : Boolean;
		
		[Bindable]
		public var isUnmoveable : Boolean;
		
		[Bindable]
		public var blockMissile : Boolean;
		
		[Bindable]
		public var blockPathfind : Boolean;
		
		[Bindable]
		public var noMoveAnimation : Boolean; // Version 10.10+
		
		[Bindable]
		public var pickupable : Boolean;
		
		[Bindable]
		public var hangable : Boolean;
		
		[Bindable]
		public var isVertical : Boolean;
		
		[Bindable]
		public var isHorizontal : Boolean;
		
		[Bindable]
		public var rotatable : Boolean;
		
		[Bindable]
		public var hasOffset : Boolean;
		
		[Bindable]
		public var offsetX : uint;
		
		[Bindable]
		public var offsetY : uint;
		
		[Bindable]
		public var dontHide : Boolean;
		
		[Bindable]
		public var isTranslucent : Boolean;
		
		[Bindable]
		public var hasLight : Boolean;
		
		[Bindable]
		public var lightLevel : uint;
		
		[Bindable]
		public var lightColor : uint;
		
		[Bindable]
		public var hasElevation : Boolean;
		
		[Bindable]
		public var elevation : uint;
		
		[Bindable]
		public var isLyingObject : Boolean;
		
		[Bindable]
		public var animateAlways : Boolean;
		
		[Bindable]
		public var miniMap : Boolean;
		
		[Bindable]
		public var miniMapColor : uint;
		
		[Bindable]
		public var isLensHelp : Boolean;
		
		[Bindable]
		public var lensHelp : uint;
		
		[Bindable]
		public var isFullGround : Boolean;
		
		[Bindable]
		public var ignoreLook : Boolean;
		
		[Bindable]
		public var cloth : Boolean;
		
		[Bindable]
		public var clothSlot : uint;
		
		[Bindable]
		public var isMarketItem : Boolean;
		
		[Bindable]
		public var marketName : String;
		
		[Bindable]
		public var marketCategory : uint;
		
		[Bindable]
		public var marketTradeAs : uint;
		
		[Bindable]
		public var marketShowAs : uint;
		
		[Bindable]
		public var marketRestrictProfession : uint;
		
		[Bindable]
		public var marketRestrictLevel : uint;
		
		[Bindable]
		public var hasDefaultAction : Boolean;
		
		[Bindable]
		public var defaultAction : uint;
		
		[Bindable]
		public var usable : Boolean;
		
		public var sprites : Vector.<SpriteData>;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function BindableThingType()
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
		
		public function setSprite(index:uint, sprite:SpriteData) : void
		{
			this.spriteIndex[index] = sprite.id;
			this.sprites[index] = sprite;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
		}
		
		public function setSpritesCount(length:uint) : void
		{
			this.spriteIndex.length = length;
			this.sprites.length = length;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
		}
		
		public function getSpriteBitmap(index:uint) : BitmapData
		{
			if (sprites != null && index < sprites.length && sprites[index] != null)
			{
				return sprites[index].bitmap;
			}
			return null;
		}
		
		public function reset() : void
		{
			var description : XMLList;
			var property : XML;
			var name : String;
			var type : String;
			
			description = describeType(this)..accessor;	
			for each (property in description)
			{
				name = property.@name;
				type = property.@type;
				
				if (type == "Boolean")
				{
					this[name] = false;
				}
				else if (type == "uint")
				{
					this[name] = 0;
				}
				else
				{
					this[name] = null;
				}
			}
		}
		
		public function copyFrom(data:ThingData) : Boolean
		{
			var description : XMLList;
			var property : XML;
			var name : String;
			var thing : ThingType;
			
			if (data == null)
			{
				return false;
			}
			
			thing = data.thing;
			description = describeType(thing)..variable;
			for each (property in description)
			{
				name = property.@name;
				if (this.hasOwnProperty(name))
				{
					this[name] = thing[name];
				}
				else
				{
					trace("ThingTypeBind no has property " + name);
				}
			}	
			
			if (thing.spriteIndex)
			{
				this.spriteIndex = thing.spriteIndex.concat();
			}
			
			if (data.sprites != null)
			{
				this.sprites = data.sprites.concat();
			}
			return true;
		}
		
		public function copyTo(thing:ThingType) : Boolean
		{
			var description : XMLList;
			var property : XML;
			var name : String;
			
			if (!thing)
			{
				return false;
			}
			
			description = describeType(thing)..variable;
			for each (property in description)
			{
				name = property.@name;
				if (this.hasOwnProperty(name))
				{
					thing[name] = this[name];
				}
			}
			
			if (this.spriteIndex)
			{
				thing.spriteIndex = this.spriteIndex.concat();
			}
			return true;
		}
	}
}
