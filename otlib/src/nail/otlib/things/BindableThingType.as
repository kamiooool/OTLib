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
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import nail.otlib.utils.SpriteData;
	import nail.otlib.utils.ThingData;

	[ResourceBundle("otlibControls")]
	
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
		
		static private function startPropertyLabels() : void
		{
			var resource : IResourceManager = ResourceManager.getInstance();
			
			PROPERTY_LABEL["width"] = resource.getString("otlibControls", "thing.width");
			PROPERTY_LABEL["height"] = resource.getString("otlibControls", "thing.height");
			PROPERTY_LABEL["exactSize"] = resource.getString("otlibControls", "thing.crop-size");
			PROPERTY_LABEL["layers"] = resource.getString("otlibControls", "thing.layers");
			PROPERTY_LABEL["patternX"] = resource.getString("otlibControls", "thing.pattern-x");
			PROPERTY_LABEL["patternY"] = resource.getString("otlibControls", "thing.pattern-y");
			PROPERTY_LABEL["patternZ"] = resource.getString("otlibControls", "thing.pattern-z");
			PROPERTY_LABEL["frames"] = resource.getString("otlibControls", "thing.frames");
			PROPERTY_LABEL["isGround"] = resource.getString("otlibControls", "thing.is-ground");
			PROPERTY_LABEL["groundSpeed"] = resource.getString("otlibControls", "thing.ground-speed");
			PROPERTY_LABEL["isGroundBorder"] = resource.getString("otlibControls", "thing.is-on-clip");
			PROPERTY_LABEL["isOnBottom"] = resource.getString("otlibControls", "thing.is-on-bottom");
			PROPERTY_LABEL["isOnTop"] = resource.getString("otlibControls", "thing.is-on-top");
			PROPERTY_LABEL["isContainer"] = resource.getString("otlibControls", "thing.container");
			PROPERTY_LABEL["stackable"] = resource.getString("otlibControls", "thing.stackable");
			PROPERTY_LABEL["forceUse"] = resource.getString("otlibControls", "thing.force-use");
			PROPERTY_LABEL["multiUse"] = resource.getString("otlibControls", "thing.multi-use");
			PROPERTY_LABEL["writable"] = resource.getString("otlibControls", "thing.writable");
			PROPERTY_LABEL["writableOnce"] = resource.getString("otlibControls", "thing.writable-once");
			PROPERTY_LABEL["maxTextLength"] = resource.getString("otlibControls", "thing.max-length");
			PROPERTY_LABEL["isFluidContainer"] = resource.getString("otlibControls", "thing.fluid-container");
			PROPERTY_LABEL["isFluid"] = resource.getString("otlibControls", "thing.fluid");
			PROPERTY_LABEL["isUnpassable"] = resource.getString("otlibControls", "thing.unpassable");
			PROPERTY_LABEL["isUnmoveable"] = resource.getString("otlibControls", "thing.unmoveable");
			PROPERTY_LABEL["blockMissile"] = resource.getString("otlibControls", "thing.block-missile");
			PROPERTY_LABEL["blockPathfind"] = resource.getString("otlibControls", "thing.block-pathfinder");
			PROPERTY_LABEL["noMoveAnimation"] = resource.getString("otlibControls", "thing.no-move-animation");
			PROPERTY_LABEL["pickupable"] = resource.getString("otlibControls", "thing.pickupable");
			PROPERTY_LABEL["hangable"] = resource.getString("otlibControls", "thing.hangable");
			PROPERTY_LABEL["isVertical"] = resource.getString("otlibControls", "thing.vertical-wall");
			PROPERTY_LABEL["isHorizontal"] = resource.getString("otlibControls", "thing.horizontal-wall");
			PROPERTY_LABEL["rotatable"] = resource.getString("otlibControls", "thing.rotatable");
			PROPERTY_LABEL["hasOffset"] = resource.getString("otlibControls", "thing.has-offset");
			PROPERTY_LABEL["offsetX"] = resource.getString("otlibControls", "thing.offset-x");
			PROPERTY_LABEL["offsetY"] = resource.getString("otlibControls", "thing.offset-y");
			PROPERTY_LABEL["dontHide"] = resource.getString("otlibControls", "thing.dont-hide");
			PROPERTY_LABEL["isTranslucent"] = resource.getString("otlibControls", "thing.translucent");
			PROPERTY_LABEL["hasLight"] = resource.getString("otlibControls", "thing.has-light");
			PROPERTY_LABEL["lightLevel"] = resource.getString("otlibControls", "thing.light-level");
			PROPERTY_LABEL["lightColor"] = resource.getString("otlibControls", "thing.light-color");
			PROPERTY_LABEL["hasElevation"] = resource.getString("otlibControls", "thing.has-elevation");
			PROPERTY_LABEL["elevation"] = resource.getString("otlibControls", "thing.elevation-height");
			PROPERTY_LABEL["isLyingObject"] = resource.getString("otlibControls", "thing.lying-object");
			PROPERTY_LABEL["animateAlways"] = resource.getString("otlibControls", "thing.animate-always");
			PROPERTY_LABEL["miniMap"] = resource.getString("otlibControls", "thing.automap");
			PROPERTY_LABEL["miniMapColor"] = resource.getString("otlibControls", "thing.automap-color");
			PROPERTY_LABEL["isLensHelp"] = resource.getString("otlibControls", "thing.lens-help");
			PROPERTY_LABEL["lensHelp"] = resource.getString("otlibControls", "thing.lens-help-value");
			PROPERTY_LABEL["isFullGround"] = resource.getString("otlibControls", "thing.full-ground");
			PROPERTY_LABEL["ignoreLook"] = resource.getString("otlibControls", "thing.ignore-look");
			PROPERTY_LABEL["cloth"] = resource.getString("otlibControls", "thing.cloth");
			PROPERTY_LABEL["clothSlot"] = resource.getString("otlibControls", "thing.cloth-slot");
			PROPERTY_LABEL["isMarketItem"] = resource.getString("otlibControls", "thing.market");
			PROPERTY_LABEL["marketName"] = resource.getString("otlibControls", "thing.market-name");
			PROPERTY_LABEL["marketCategory"] = resource.getString("otlibControls", "thing.market-category");
			PROPERTY_LABEL["marketTradeAs"] = resource.getString("otlibControls", "thing.trade-as");
			PROPERTY_LABEL["marketShowAs"] = resource.getString("otlibControls", "thing.show-as");
			PROPERTY_LABEL["marketRestrictProfession"] = resource.getString("otlibControls", "thing.vocation");
			PROPERTY_LABEL["marketRestrictLevel"] = resource.getString("otlibControls", "thing.level");
			PROPERTY_LABEL["hasDefaultAction"] = resource.getString("otlibControls", "thing.has-action");
			PROPERTY_LABEL["defaultAction"] = resource.getString("otlibControls", "thing.action-type");
			PROPERTY_LABEL["usable"] = resource.getString("otlibControls", "thing.usable");
			PROPERTY_LABEL["spriteIndex"] = resource.getString("otlibControls", "thing.sprite-id");
			PROPERTY_LABEL["hasCharges"] = resource.getString("otlibControls", "thing.has-charges");
			PROPERTY_LABEL["floorChange"] = resource.getString("otlibControls", "thing.floor-change");
		}
		startPropertyLabels();
		
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
