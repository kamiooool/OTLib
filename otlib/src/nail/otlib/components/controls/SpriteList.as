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

package nail.otlib.components.controls
{
	import mx.core.ClassFactory;
	
	import spark.components.List;
	
	import nail.otlib.components.renders.SpriteListRenderer;
	import nail.otlib.core.otlib_internal;
	import nail.otlib.events.SpriteListEvent;
	import nail.otlib.utils.SpriteData;
	
	[Event(name="copy", type="nail.otlib.events.SpriteListEvent")]
	
	[Event(name="paste", type="nail.otlib.events.SpriteListEvent")]
	
	[Event(name="replace", type="nail.otlib.events.SpriteListEvent")]
	
	[Event(name="export", type="nail.otlib.events.SpriteListEvent")]
	
	[Event(name="remove", type="nail.otlib.events.SpriteListEvent")]
	
	public class SpriteList extends List
	{
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function SpriteList()
		{
			super();
			
			this.itemRenderer = new ClassFactory(SpriteListRenderer);
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Internal
		//--------------------------------------
		
		otlib_internal function onContextMenuSelect(index:int, type:String) : void
		{
			var spriteData : SpriteData;
			var event : SpriteListEvent;
			
			if (index != -1 && this.dataProvider != null)
			{
				spriteData = this.dataProvider.getItemAt(index) as SpriteData;
				
				if (spriteData != null)
				{
					switch(type)
					{
						case SpriteListEvent.COPY:
							event = new SpriteListEvent(SpriteListEvent.COPY, spriteData);
							break;
						
						case SpriteListEvent.PASTE:
							event = new SpriteListEvent(SpriteListEvent.PASTE, spriteData);
							break;
						
						case SpriteListEvent.REPLACE:
							event = new SpriteListEvent(SpriteListEvent.REPLACE, spriteData);
							break;
						
						case SpriteListEvent.EXPORT:
							event = new SpriteListEvent(SpriteListEvent.EXPORT, spriteData);
							break;
						
						case SpriteListEvent.REMOVE:
							event = new SpriteListEvent(SpriteListEvent.REMOVE, spriteData);
							break;
					}
					
					if (event != null)
					{
						dispatchEvent(event);
					}
				}
			}
		}
		
		//--------------------------------------
		// Getters / Setters 
		//--------------------------------------
		
		public function get selectedSprite() : SpriteData
		{
			if (this.selectedItem !== undefined)
			{
				return this.selectedItem as SpriteData;
			}
			return null;
		}
		
		public function get selectedSprites() : Vector.<SpriteData>
		{
			var result : Vector.<SpriteData>;
			var length : uint;
			var i : uint;
			
			result = new Vector.<SpriteData>();
			
			if (this.selectedIndices != null)
			{
				length = selectedIndices.length;
				for (i = 0; i < length; i++)
				{
					result[i] = dataProvider.getItemAt(selectedIndices[i]) as SpriteData;
				}
			}
			return result;
		}
		
		public function get selectedSpriteId() : uint
		{
			if (this.selectedSprite != null)
			{
				return this.selectedSprite.id;
			}
			return 0;
		}
	}
}
