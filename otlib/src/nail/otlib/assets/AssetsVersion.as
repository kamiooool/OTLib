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

package nail.otlib.assets
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;
	
	import nail.utils.StringUtil;

	public final class AssetsVersion
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _value : uint;
		
		private var _valueStr : String;
		
		private var _datSignature : uint;
		
		private var _sprSignature : uint;
		
		private var _otbVersion : uint;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function AssetsVersion(versionValue:uint, versionString:String, datSignature:uint, sprSignature:uint, otbVersion:uint)
		{
			_value = versionValue;
			_valueStr = versionString;
			_datSignature = datSignature;
			_sprSignature = sprSignature;
			_otbVersion = otbVersion;
		}
		
		//----------------------------------------------------
		//
		// METHODS
		//
		//----------------------------------------------------
		
		//--------------------------------------
		// Public
		//--------------------------------------
		
		public function toString() : String
		{
			return _valueStr;
		}
		
		//--------------------------------------
		// Getters / Setters
		//--------------------------------------
		
		public function get value() : uint
		{
			return _value;
		}
		
		public function get valueStr() : String
		{
			return _valueStr;
		}
		 
		public function get sprSignature() : uint
		{
			return _sprSignature;
		}
		
		public function get datSignature() : uint
		{
			return _datSignature;
		}
		
		public function get otbVersion() : uint
		{
			return _otbVersion;
		}
		
		//----------------------------------------------------
		//
		// STATIC
		//
		//----------------------------------------------------
		
		static private const VERSION_LIST : Dictionary = new Dictionary();
		
		static public function load() : void
		{
			var file : File;
			var stream : FileStream;
			var xml : XML;
			var versionXML : XML;
			var version : AssetsVersion;
			var value : uint;
			var string : String;
			var dat : uint;
			var spr : uint;
			var otb : uint;
			var key : String;
			
			file = File.applicationDirectory.resolvePath("versions.xml");
			if (!file.exists)
			{
				return;
			}
			
			stream = new FileStream();
			
			try
			{
				stream.open(file, FileMode.READ);
				xml = XML( stream.readUTFBytes(stream.bytesAvailable) );
				stream.close();
			} 
			catch(error:Error)
			{
				return;
			}
			
			if (xml.localName() != "versions")
			{
				return;
			}
			
			for each (versionXML in xml.version)
			{
				if (versionXML.hasOwnProperty("@value") &&
					versionXML.hasOwnProperty("@string") &&
					versionXML.hasOwnProperty("@dat") &&
					versionXML.hasOwnProperty("@spr") &&
					versionXML.hasOwnProperty("@otb"))
				{
					value = uint(versionXML.@value);
					string = String(versionXML.@string);
					dat = uint(StringUtil.substitute("0x{0}", versionXML.@dat));
					spr = uint(StringUtil.substitute("0x{0}", versionXML.@spr));
					otb = uint(versionXML.@otb);
					version = new AssetsVersion(value, string, dat, spr, otb);
					key = "$" + value;
					VERSION_LIST[key] = version;
				}
			}
		}
		load();
		
		static public function getList() : Array
		{
			var list : Array;
			var version : AssetsVersion;
			
			list = [];
			
			for each (version in VERSION_LIST)
			{
				list.push(version);
			}
			return list;
		}
		
		static public function getVersionByValue(value:uint) : AssetsVersion
		{
			var version : AssetsVersion;
			var key : String;
			
			key = "$" + value;
			if (VERSION_LIST[key] !== undefined)
			{
				return AssetsVersion(VERSION_LIST[key]);
			}
			return null;
		}
		
		static public function getVersionBySignatures(sprSignature:uint, datSignature:uint) : AssetsVersion
		{
			var version : AssetsVersion;
			
			for each (version in VERSION_LIST)
			{
				if (version.sprSignature == sprSignature && version.datSignature == datSignature)
				{
					return version;
				}
			}
			return null;
		}
		
		static public function getVersionByOtb(otb:uint) : AssetsVersion
		{
			var version : AssetsVersion;
			
			for each (version in VERSION_LIST)
			{
				if (version.otbVersion == otb)
				{
					return version;
				}
			}
			return null;
		}
	}
}
