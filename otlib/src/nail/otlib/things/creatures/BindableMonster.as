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

package nail.otlib.things.creatures
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	import nail.otlib.things.items.LootItem;
	import nail.utils.BooleanUtils;
	
	public class BindableMonster extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		// -------------- Look --------------------
		
		[Bindable]
		public var lookType : uint;
		
		[Bindable]
		public var lookHead : uint;
		
		[Bindable]
		public var lookBody : uint;
		
		[Bindable]
		public var lookLegs : uint;
		
		[Bindable]
		public var lookFeet : uint;
		
		[Bindable]
		public var lookCorpse : uint;
		
		// -------------- Status --------------------
		
		[Bindable]
		public var name : String;
		
		[Bindable]
		public var description : String;
		
		[Bindable]
		public var race : String;
		
		[Bindable]
		public var experience : uint;
		
		[Bindable]
		public var speed : uint;
		
		[Bindable]
		public var manaConst : uint;
		
		[Bindable]
		public var healthMax : uint;
		
		[Bindable]
		public var healthNow : uint;
		
		// -------------- Flags --------------------
		
		[Bindable]
		public var summonable : Boolean;
		
		[Bindable]
		public var attackable : Boolean;
		
		[Bindable]
		public var hostile : Boolean;
		
		[Bindable]
		public var illusionable : Boolean;
		
		[Bindable]
		public var convinceable : Boolean;
		
		[Bindable]
		public var pushable : Boolean;
		
		[Bindable]
		public var canPushItems : Boolean;
		
		[Bindable]
		public var canPushCreatures : Boolean;
		
		[Bindable]
		public var targetDistance : uint;
		
		[Bindable]
		public var staticAttack : uint;
		
		[Bindable]
		public var runOnHealth : uint;
		
		// -------------- Loot --------------------
		
		[Bindable]
		public var lootItems : ArrayCollection;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function BindableMonster()
		{
			this.lootItems = new ArrayCollection();
			this.clear();
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Public
		//--------------------------------------
		
		public function serialize() : XML
		{
			var xml : XML;
			var health : XML;
			var look : XML;
			var flags : XML;
			var flag : XML;
			
			xml = <monster/>;
			xml.@name = this.name;
			xml.@nameDescription = this.description;
			xml.@race = this.race;
			xml.@experience = this.experience;
			xml.@speed = this.speed;
			xml.@manacost = this.manaConst;
			
			// -----< Health >-----
			health = <health/>;
			health.@now = this.healthNow;
			health.@max = this.healthMax;
			xml.appendChild(health);
			
			// -----< Look >-----
			look = <look/>;
			look.@type = this.lookType;
			look.@head = this.lookHead;
			look.@body = this.lookBody;
			look.@legs = this.lookLegs;
			look.@feet = this.lookFeet;
			look.@corpse = this.lookCorpse;
			xml.appendChild(look);
			
			// -----< Flags >-----
			flags = <flags/>;			
			flag = <flag/>;
			flag.@summonable = this.summonable == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@attackable = this.attackable == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@hostile = this.hostile == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@illusionable = this.illusionable == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@convinceable = this.convinceable == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@pushable = this.pushable == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@canpushitems = this.canPushItems == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@canpushcreatures = this.canPushCreatures == true ? 1 : 0;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@targetdistance = this.targetDistance;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@staticattack = this.staticAttack;
			flags.appendChild(flag);
			flag = <flag/>;
			flag.@runonhealth = this.runOnHealth;
			flags.appendChild(flag);
			xml.appendChild(flags);
			
			// -----< Loot >-----
			serializeLoot(xml);
			
			return xml;
		}
		
		public function unserialize(xml:XML) : void
		{
			if (xml.hasOwnProperty("@name") == false)
			{
				trace("xml.hasOwnProperty('name') == false")
				return;
			}
			
			this.name = xml.@name;
			this.description = xml.@nameDescription;
			this.race = xml.@race;
			this.experience = xml.@experience;
			this.speed = xml.@speed;
			this.manaConst = xml.@manacost;
			
			// -----< Health >-----
			if (xml.hasOwnProperty("health") == false)
			{
				trace("xml.hasOwnProperty('health') == false")
				return;
			}
			
			this.healthMax = uint(xml.health[0].@max);
			this.healthNow = uint(xml.health[0].@now);
			
			// -----< Look >-----
			if (xml.hasOwnProperty("look") == false)
			{
				trace("xml.hasOwnProperty('look') == false")
				return;
			}
			
			this.lookType = uint(xml.look[0].@type);
			this.lookHead = uint(xml.look[0].@head);
			this.lookBody = uint(xml.look[0].@body);
			this.lookLegs = uint(xml.look[0].@legs);
			this.lookFeet = uint(xml.look[0].@feet);
			this.lookCorpse = uint(xml.look[0].@corpse);
			
			// -----< Flags >-----
			if (xml.hasOwnProperty("flags") == true)
			{
				this.unserializeFlags(xml.flags[0]); 
			}
			
			// -----< Loot >-----
			if (xml.hasOwnProperty("loot") == true)
			{
				this.unserializeLoot(xml.loot[0]);
			}
		}
		
		public function getIndexOfItem(sid:uint) : int
		{
			var length : uint;
			var i : int;
			var item : LootItem;
			
			length = lootItems.length;
			if (length > 0)
			{
				for (i = 0; i < length; i++)
				{
					item = lootItems.getItemAt(i) as LootItem;
					if (item.sid == sid)
					{
						return i;
					}
				}
			}
			
			return -1;
		}
		
		public function clear() : void
		{
			this.name = "Monster";
			this.description = "a monster";
			this.race = "blood";
			this.experience = 0;
			this.speed = 0;
			this.manaConst = 0;
			this.healthMax = 0;
			this.healthNow = 0;
			this.summonable = false;
			this.attackable = false;
			this.hostile = false;
			this.illusionable = false;
			this.convinceable = false;
			this.pushable = false;
			this.canPushItems = false;
			this.canPushCreatures = false;
			this.targetDistance = 0;
			this.staticAttack = 0;
			this.runOnHealth = 0;
			this.lookType = 0;
			this.lookHead = 0;
			this.lookBody = 0;
			this.lookLegs = 0;
			this.lookFeet = 0;
			this.lookCorpse = 0;
			
			lootItems.removeAll();
		}
		
		public function invalidateItemsName() : void
		{
			/*var length : uint;
			var i : int;
			var itemLoot : LootItem;
			var item : Item;
			
			length = lootItems.length;
			if (length > 0)
			{
				for (i = 0; i < length; i++)
				{
					itemLoot = lootItems.getItemAt(i) as LootItem;
					itemLoot.name = Main.application.getItemName(itemLoot.sid);
				}
			}*/
		}
		
		//--------------------------------------
		// Private
		//--------------------------------------
		
		private function unserializeFlags(xml:XML) : void
		{
			var flag : XML;
			
			for each (flag in xml.flag)
			{
				if (flag.hasOwnProperty("@summonable") == true) { this.summonable = BooleanUtils.getBoolean(flag.@summonable); }
				if (flag.hasOwnProperty("@attackable") == true) { this.attackable = BooleanUtils.getBoolean(flag.@attackable); }
				if (flag.hasOwnProperty("@hostile") == true) { this.hostile = BooleanUtils.getBoolean(flag.@hostile); }
				if (flag.hasOwnProperty("@illusionable") == true) { this.illusionable = BooleanUtils.getBoolean(flag.@illusionable); }
				if (flag.hasOwnProperty("@convinceable") == true) { this.convinceable = BooleanUtils.getBoolean(flag.@convinceable); }
				if (flag.hasOwnProperty("@pushable") == true) { this.pushable = BooleanUtils.getBoolean(flag.@pushable); }
				if (flag.hasOwnProperty("@canpushitems") == true) { this.canPushItems = BooleanUtils.getBoolean(flag.@canpushitems); }
				if (flag.hasOwnProperty("@canpushcreatures") == true) { this.canPushCreatures = BooleanUtils.getBoolean(flag.@canpushcreatures); }
				if (flag.hasOwnProperty("@targetdistance") == true) { this.targetDistance = uint(flag.@targetdistance); }
				if (flag.hasOwnProperty("@staticattack") == true) { this.staticAttack = uint(flag.@staticattack); }
				if (flag.hasOwnProperty("@runonhealth") == true) { this.runOnHealth = uint(flag.@runonhealth); } 
			}
		}
		
		private function unserializeLoot(xml:XML) : void
		{
			/*var itemXML : XML;
			var sid : uint;
			var name : String;
			var countMax : uint;
			var chance : uint;
			
			for each (itemXML in xml.item)
			{
				sid = uint(itemXML.@id);
				name = Main.application.getItemName(sid);
				
				if (itemXML.hasOwnProperty("@countmax") == true)
				{
					countMax = uint(itemXML.@countmax);
				}
				else 
				{
					countMax = 1;
				}
				chance = uint(itemXML.@chance);
				lootItems.addItem(new LootItem(sid, name, countMax, chance));
			}*/
		}
		
		private function serializeLoot(xml:XML) : void
		{
			var loot : XML;
			var itemXML : XML;
			var length : uint;
			var i : int;
			var item : LootItem;
			
			length = lootItems.length;
			if (length > 0)
			{
				loot = <loot/>;
				
				for (i = 0; i < length; i++)
				{
					item = lootItems.getItemAt(i) as LootItem;
					itemXML = <item/>;
					itemXML.@id = item.sid;
					
					if (item.count > 1)
					{
						itemXML.@countmax = item.count;
					}
					
					itemXML.@chance = item.chance;
					
					// Add item name as comment
					if (item.name != "" && item.name != null)
					{
						loot.appendChild(XML(StringUtil.substitute("<!-- {0} -->", item.name)));
					}
					
					loot.appendChild(itemXML);
				}
				
				xml.appendChild(loot);
			}
		}
	}
}
