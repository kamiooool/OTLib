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
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.graphics.SolidColor;
	
	import spark.components.PopUpAnchor;
	import spark.components.SkinnableContainer;
	
	import nail.otlib.utils.ColorUtils;
	
	[Event(name="change", type="flash.events.Event")]
	
	public class HSIColorPicker extends SkinnableContainer
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="true", type="park.components.PopUpAnchor")]
		public var popUpArchor : PopUpAnchor;
		
		[SkinPart(required="true", type="nail.otlib.components.controls.HSIColorPanel")]
		public var colorPanel : HSIColorPanel;
		
		[SkinPart(required="true", type="mx.graphics.SolidColor")]
		public var fillColor : SolidColor;
		
		private var _color : uint;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function HSIColorPicker()
		{
			super();
			
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Override Protected
		//--------------------------------------
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if (instance === colorPanel)
			{
				trace("HSIColorPicker.partAdded(partName, instance)");
				
				colorPanel.addEventListener(Event.CHANGE, colorPanelChangeHandler);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			fillColor.color = ColorUtils.HSItoRGB(this.color);
		}
		
		//--------------------------------------
		// Event Handlers
		//--------------------------------------
		
		protected function mouseClickHandler(event:MouseEvent) : void
		{
			if (colorPanel != null)
			{
				colorPanel.selectedIndex = this.color;
			}
			popUpArchor.displayPopUp = true;
			systemManager.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		}
		
		protected function colorPanelChangeHandler(event:Event) : void
		{
			this.color = event.target.selectedIndex;
			popUpArchor.displayPopUp = false;
		}
		
		protected function stageMouseUpHandler(event:MouseEvent) : void
		{
			systemManager.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			popUpArchor.displayPopUp = false;
		}

		//--------------------------------------
		// Getters / Setters 
		//--------------------------------------
		
		[Bindable]
		public function get color() : uint
		{
			return _color;
		}

		public function set color(value:uint) : void
		{
			if (_color != value)
			{
				_color = value;
				invalidateDisplayList();
				
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
	}
}