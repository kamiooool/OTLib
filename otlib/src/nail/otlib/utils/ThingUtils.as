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
	import flash.utils.describeType;
	
	import nail.errors.AbstractClassError;
	import nail.otlib.things.ThingType;
	
	public final class ThingUtils
	{
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function ThingUtils()
		{
			throw new AbstractClassError(ThingUtils);
		}
		
		//--------------------------------------------------------------------------
		//
		// STATIC
		//
		//--------------------------------------------------------------------------
		
		static public function copyThing(thing:ThingType) : ThingType
		{
			var newThing : ThingType;
			var description : XMLList;
			var property : XML;
			var name : String;
			
			if (!thing) { return null; }
			
			newThing = new ThingType();
			description = describeType(thing)..variable;
			for each (property in description)
			{
				name = property.@name;
				newThing[name] = thing[name];
			}
			
			if (thing.spriteIndex)
			{
				newThing.spriteIndex = thing.spriteIndex.concat();
			}
			return newThing;
		}
		
		static public function createThing() : ThingType
		{
			var thing : ThingType;
			thing = new ThingType();
			thing.width = 1;
			thing.height = 1;
			thing.layers = 1;
			thing.frames = 1;
			thing.patternX = 1;
			thing.patternY = 1;
			thing.patternZ = 1;
			thing.exactSize = 32;
			thing.spriteIndex = new Vector.<uint>();
			thing.spriteIndex[0] = 0;
			return thing;
		}
	}
}
