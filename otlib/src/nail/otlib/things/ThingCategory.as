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
	import nail.errors.AbstractClassError;
	import nail.utils.StringUtil;

	public final class ThingCategory
	{
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function ThingCategory(value:String)
		{
			throw new AbstractClassError(ThingCategory);
		}
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static public const ITEM : String = "item";
		
		static public const OUTFIT : String = "outfit";
		
		static public const EFFECT : String = "effect";
		
		static public const MISSILE : String = "missile";
		
		static public function getCategory(value:String) : String
		{
			if (!StringUtil.isEmptyOrNull(value))
			{
				value = StringUtil.toKeyString(value);
				switch (value)
				{
					case "item":
						return ITEM;
					case "outfit":
						return OUTFIT;
					case "effect":
						return EFFECT;
					case "missile":
						return MISSILE;
				}
			}
			return null;
		}
	}
}
