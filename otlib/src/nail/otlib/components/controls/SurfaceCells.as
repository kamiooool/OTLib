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
	import flash.display.BlendMode;
	
	import mx.core.UIComponent;
	
	[ExcludeClass]
	
	public class SurfaceCells extends UIComponent
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _columns : uint;
		private var _rows : uint;
		private var _cellWidth : uint;
		private var _cellHeight : uint;
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		public function SurfaceCells()
		{
			super();
			
			blendMode = BlendMode.INVERT;
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Override Protected
		//--------------------------------------
		
		override protected function measure() : void
		{
			super.measure();
			
			measuredWidth  = _cellWidth * _columns;
			measuredHeight = _cellHeight * _rows;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			var c : int;
			var r : int;
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			
			for (c = 0; c < _columns; c++)
			{
				for (r = 0; r < _rows; r++)
				{
					graphics.lineStyle(0.1, 0);
					graphics.beginFill(0, 0);
					graphics.drawRect(c * _cellWidth, r * _cellHeight, _cellWidth, _cellHeight);
				}
			}
			
			graphics.endFill();
		}
		
		//--------------------------------------
		// Getters / Setters 
		//--------------------------------------
		
		public function get cellWidth() : uint
		{
			return _cellWidth;
		}
		
		public function set cellWidth(value:uint) : void
		{
			if (_cellWidth != value)
			{
				_cellWidth = value;
				invalidateDisplayList();
				invalidateSize();
			}
		}
		
		public function get cellHeight() : uint
		{
			return _cellHeight;
		}

		public function set cellHeight(value:uint) : void
		{
			if (_cellHeight != value)
			{
				_cellHeight = value;
				invalidateDisplayList();
				invalidateSize();
			}
		}

		public function get columns() : uint
		{
			return _columns;
		}
		
		public function set columns(value:uint) : void
		{
			if (_columns != value)
			{
				_columns = value;
				invalidateDisplayList();
				invalidateSize();
			}
		}

		public function get rows() : uint
		{
			return _rows;
		}

		public function set rows(value:uint) : void
		{
			if (_rows != value)
			{
				_rows = value;
				invalidateDisplayList();
				invalidateSize();
			}
		}
	}
}
