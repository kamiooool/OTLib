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
	import flash.utils.Dictionary;
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
		public var hasCharges : Boolean;
		
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
		public var floorChange : Boolean;
		
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
		
		public var spriteIndex : Vector.<uint>;
		
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
			var event : PropertyChangeEvent;
			var oldValue : uint;
			
			oldValue = spriteIndex[index];
			this.spriteIndex[index] = sprite.id;
			this.sprites[index] = sprite;
			
			event = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			event.property = "spriteIndex";
			event.oldValue = oldValue;
			event.newValue = sprite.id;
			dispatchEvent(event);
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
				return sprites[index].getBitmap();
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
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static private const PROPERTY_LABEL : Dictionary = new Dictionary();
		
		PROPERTY_LABEL["id"] = "Id";
		PROPERTY_LABEL["category"] = "Category";
		PROPERTY_LABEL["width"] = "Width";
		PROPERTY_LABEL["height"] = "Height";
		PROPERTY_LABEL["exactSize"] = "Crop Size";
		PROPERTY_LABEL["layers"] = "Layers";
		PROPERTY_LABEL["patternX"] = "Pattern X";
		PROPERTY_LABEL["patternY"] = "Pattern Y";
		PROPERTY_LABEL["patternZ"] = "Pattern Z";
		PROPERTY_LABEL["frames"] = "Frames";
		PROPERTY_LABEL["isGround"] = "Ground";
		PROPERTY_LABEL["groundSpeed"] = "Ground Speed";
		PROPERTY_LABEL["isGroundBorder"] = "Clip";
		PROPERTY_LABEL["isOnBottom"] = "Bottom";
		PROPERTY_LABEL["isOnTop"] = "Top";
		PROPERTY_LABEL["isContainer"] = "Container";
		PROPERTY_LABEL["stackable"] = "Stackable";
		PROPERTY_LABEL["forceUse"] = "Force Use";
		PROPERTY_LABEL["multiUse"] = "Multi Use";
		PROPERTY_LABEL["writable"] = "Writable";
		PROPERTY_LABEL["writableOnce"] = "Writable Once";
		PROPERTY_LABEL["maxTextLength"] = "Max Length";
		PROPERTY_LABEL["isFluidContainer"] = "Fluid Container";
		PROPERTY_LABEL["isFluid"] = "Fluid";
		PROPERTY_LABEL["isUnpassable"] = "Unpassable";
		PROPERTY_LABEL["isUnmoveable"] = "Unmoveable";
		PROPERTY_LABEL["blockMissile"] = "Block Missile";
		PROPERTY_LABEL["blockPathfind"] = "Block Pathfind";
		PROPERTY_LABEL["noMoveAnimation"] = "No Move Animation";
		PROPERTY_LABEL["pickupable"] = "Pickupable";
		PROPERTY_LABEL["hangable"] = "Hangable";
		PROPERTY_LABEL["isVertical"] = "Vertical";
		PROPERTY_LABEL["isHorizontal"] = "Horizontal";
		PROPERTY_LABEL["rotatable"] = "Rotatable";
		PROPERTY_LABEL["hasOffset"] = "Has Offset";
		PROPERTY_LABEL["offsetX"] = "Offset X";
		PROPERTY_LABEL["offsetY"] = "Offset Y";
		PROPERTY_LABEL["dontHide"] = "Don't Hide";
		PROPERTY_LABEL["isTranslucent"] = "Translucent";
		PROPERTY_LABEL["hasLight"] = "Has Light";
		PROPERTY_LABEL["lightLevel"] = "Light Level";
		PROPERTY_LABEL["lightColor"] = "Light Color";
		PROPERTY_LABEL["hasElevation"] = "Has Elevation";
		PROPERTY_LABEL["elevation"] = "Elevation Height";
		PROPERTY_LABEL["isLyingObject"] = "Lying Object";
		PROPERTY_LABEL["animateAlways"] = "Animate Always";
		PROPERTY_LABEL["miniMap"] = "Automap";
		PROPERTY_LABEL["miniMapColor"] = "Automap Color";
		PROPERTY_LABEL["isLensHelp"] = "Lens Help";
		PROPERTY_LABEL["lensHelp"] = "Lens Help Value";
		PROPERTY_LABEL["isFullGround"] = "Full Ground";
		PROPERTY_LABEL["ignoreLook"] = "Ignore Look";
		PROPERTY_LABEL["cloth"] = "Equip";
		PROPERTY_LABEL["clothSlot"] = "Slot";
		PROPERTY_LABEL["isMarketItem"] = "Market";
		PROPERTY_LABEL["marketName"] = "Name";
		PROPERTY_LABEL["marketCategory"] = "Market Category";
		PROPERTY_LABEL["marketTradeAs"] = "Trade As";
		PROPERTY_LABEL["marketShowAs"] = "Show As";
		PROPERTY_LABEL["marketRestrictProfession"] = "Vocation";
		PROPERTY_LABEL["marketRestrictLevel"] = "Level";
		PROPERTY_LABEL["hasDefaultAction"] = "Action";
		PROPERTY_LABEL["defaultAction"] = "Action Type";
		PROPERTY_LABEL["usable"] = "Usable";
		PROPERTY_LABEL["spriteIndex"] = "Sprite Id";
		
		static public function toLabel(property:String) : String
		{
			if (!isNullOrEmpty(property) && PROPERTY_LABEL[property] !== undefined)
			{
				return PROPERTY_LABEL[property];
			}
			return "";
		}
	}
}
