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

package nail.otlib.loaders
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import nail.otlib.utils.OTFormat;
	import nail.otlib.utils.ThingData;
	import nail.utils.FileUtils;
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class ThingDataLoader extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		// PROPERTIES
		//
		//--------------------------------------------------------------------------
		
		private var _browseFrom : File;
		
		private var _thingDataList : Vector.<ThingData>;
		
		private var _files : Array;
		
		private var _index : int;
		
		private var _directory : File;
		
		//--------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
		
		public function ThingDataLoader(browseFrom:File = null)
		{
			if (browseFrom != null)
			{
				_browseFrom = FileUtils.getDirectory(browseFrom);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		// METHODS
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------
		// Public
		//--------------------------------------
		
		public function load(file:File) : void
		{
			if (file == null) 
			{
				throw new ArgumentError("Parameter file cannot be null.");
			}
			
			this.onLoad([file]);
		}
		
		public function loadFiles(files:Array) : void
		{
			if (files == null) 
			{
				throw new ArgumentError("Parameter files cannot be null.");
			}
			
			if (files.length > 0)
			{
				this.onLoad(files);
			}
		}
		
		public function browseForOpen(title:String, filter:FileFilter = null) : void
		{
			var filter : FileFilter;
			var file : File;
			
			title = title != null ? title : "";
			filter = filter != null ? filter : new FileFilter("Object Builder Files", "*.obd");
			file = _browseFrom != null ? _browseFrom : File.documentsDirectory;
			file.addEventListener(Event.SELECT, fileSelectHandler);
			file.browseForOpen(title, [filter]);
			
			function fileSelectHandler(event:Event) : void
			{
				onLoad([file]);
			}
		}
		
		public function browseForOpenMultiple(title:String, filter:FileFilter = null) : void
		{
			var filter : FileFilter;
			var file : File;
			
			title = title != null ? title : "";
			filter = filter != null ? filter : new FileFilter("Object Builder Files", "*.obd");
			file = _browseFrom != null ? _browseFrom : File.documentsDirectory;
			file.addEventListener(FileListEvent.SELECT_MULTIPLE, fileSelectHandler);
			file.browseForOpenMultiple(title, [filter]);
			
			function fileSelectHandler(event:FileListEvent) : void
			{
				onLoad(event.files);
			}
		}
		
		//--------------------------------------
		// Private
		//--------------------------------------
		
		private function onLoad(files:Array) : void
		{
			_files = files;
			_thingDataList = new Vector.<ThingData>();
			_index = -1;
			_directory = FileUtils.getDirectory(files[0]);
			
			loadNext();
		}
		
		private function loadNext() : void
		{
			var file : File;
			
			_index++;
			
			if (_index >= _files.length)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			file = _files[_index];
			
			if (file.extension == OTFormat.OBD)
			{
				loadOBD(file);
			}
			else 
			{
				loadNext();
			}
		}
		
		private function loadOBD(file:File) : void
		{
			var request : URLRequest;
			var loader : URLLoader;
			
			request = new URLRequest(file.nativePath);
			loader  = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.load(request);
			
			function completeHandler(event:Event) : void
			{
				var data : ThingData;
				
				try
				{
					data = ThingData.unserialize(ByteArray(loader.data));
					_thingDataList.push(data);
				} 
				catch(error:Error) 
				{
					_thingDataList = null;
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message, error.errorID));
					return;
				}
				
				loadNext();
			}
		}
		
		//--------------------------------------
		// Getters / Setters 
		//--------------------------------------
		
		public function get thingData() : ThingData
		{
			if (_thingDataList != null && _thingDataList.length == 1)
			{
				return _thingDataList[0];
			}
			return null;
		}
		
		public function get thingDataList() : Vector.<ThingData>
		{
			return _thingDataList;
		}
		
		public function get directory() : File
		{
			return _directory;
		}
		
		public function get length() : uint
		{
			return _files != null ? _files.length : 0;
		}
	}
}
