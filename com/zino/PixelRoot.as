package com.zino
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	
	import com.hurlant.util.*;
	
	public class PixelRoot extends Sprite
	{
		var pixels:Vector.<PixelObject>;
		var lineCount:int = 0;
		var editMode:Boolean = false;
		var file:FileReference;
		var defcolor:uint = 0;
		var time:int;
		var dispRect:Rectangle;
		var loadedImg:BitmapData;
		var pos:Point;
		var tobj:uint;
		var idxlist:Array;

		public function PixelRoot()
		{
			init();
		}

		private function init():void
		{
			var _dot:Shape = new Shape();
			_dot.graphics.beginFill(defcolor);
			_dot.graphics.drawRect(0,0,2,2);
			_dot.graphics.endFill();
			var _bm:BitmapData = new BitmapData(2,2);
			_bm.draw(_dot);
			var end:Boolean = false;
			var curX:int = 1;
			var curY:int = 1;
			dispRect = new Rectangle();
			dispRect.width = Math.floor(stage.stageWidth / 3);
			dispRect.height = Math.floor((stage.stageHeight - 40) / 3);

			pixels = new Vector.<PixelObject>();
			while (!end)
			{
				var p:PixelObject = new PixelObject(_bm,defcolor);
				addChildAt(p,0);
				p.x = curX;
				p.y = curY;
				pixels.push(p);
				curX +=  2 + 1;
				if (curX >= stage.stageWidth)
				{
					curX = 1;
					curY +=  2 + 1;
					if (lineCount == 0)
					{
						lineCount = pixels.length;
					}
				}
				if (curY >= stage.stageHeight - 40)
				{
					end = true;
				}
			}
			idxlist = new Array(pixels.length);
			for (var idx in pixels)
			{
				idxlist[idx] = idx;
			}
			
			//txtInfo.text = lineCount + "x" + (pixels.length / lineCount);
			file = new FileReference();
			file.addEventListener(Event.SELECT,getFile);
			file.addEventListener(Event.COMPLETE,showFile);

			btnShuffle.addEventListener(MouseEvent.CLICK,goShuffle);
			btnOpen.addEventListener(MouseEvent.CLICK,goFile);
			btnClear.addEventListener(MouseEvent.CLICK,resetAll);
			btnEdit.addEventListener(MouseEvent.CLICK,startEdit);
			btnPlay.addEventListener(MouseEvent.CLICK,toggleMotion);
			btnBlink.addEventListener(MouseEvent.CLICK,goBlink);
		}

		private function resetAll(e:MouseEvent=null):void
		{
			clearTimeout(tobj);
			for each(var p in pixels)
			{
				if (!p.isDefaultColor)
				{
					p.reset();
				}
			}
			//txtInfo.text = "0/" + Utility.addCommas(pixels.length);
		}

		private function countPixels(e:MouseEvent=null):void
		{
			var count:int = 0;
			for (var idx in pixels)
			{
				if (! pixels[idx].isDefaultColor)
				{
					count++;
				}
			}
			//txtInfo.text = Utility.addCommas(count) + "/" + Utility.addCommas(pixels.length);
		}

		private function startEdit(e:MouseEvent):void
		{
			if (editMode)
			{
				btnEdit.label = "Edit";
				btnShuffle.enabled = true;
				btnOpen.label = "Open...";
				if (loadedImg != null)
					btnPlay.enabled = true;
				removeEventListener(MouseEvent.MOUSE_MOVE,dragMouse);
				removeEventListener(MouseEvent.MOUSE_DOWN,dragMouse);
				removeEventListener(MouseEvent.MOUSE_UP,countPixels);
			}
			else
			{
				btnEdit.label = "Done";
				btnShuffle.enabled = false;
				btnOpen.label = "Save...";
				btnPlay.label = "Play";
				btnPlay.enabled = false;
				clearTimeout(tobj);
				addEventListener(MouseEvent.MOUSE_MOVE,dragMouse);
				addEventListener(MouseEvent.MOUSE_DOWN,dragMouse);
				addEventListener(MouseEvent.MOUSE_UP,countPixels);
			}
			editMode = ! editMode;
		}

		private function dragMouse(e:MouseEvent):void
		{
			if (e.buttonDown)
			{
				if (e.target is PixelObject)
				{
					e.target.red();
				}
			}
			e.stopPropagation();
		}

		private function goShuffle(e:MouseEvent):void
		{
			time = getTimer();
			var seed:Number = .75;
			var count:int = 0;
			for (var idx in pixels)
			{
				/*if (Math.random() < seed)
				{
					if (Math.random() < .33)
					{
						pixels[idx].setColor(0xFFFFFF);
					}
					else
					{
						if (Math.random() < .33)
						{
							pixels[idx].setColor(0xFFFFFF,.6);
						}
						else
						{
							pixels[idx].setColor(0xFFFFFF,.3);
						}
					}
					count++;
				}
				else
				{
					pixels[idx].reset();
				}*/
				if (idx % 9 == 0)
				{
					pixels[idx].red();
					count++;
				}
				else if (idx%9==1)
				{
					pixels[idx].green();
					count++;
				}
				else if (idx%9==2)
				{
					pixels[idx].blue();
					count++;
				}
				else
				{
					pixels[idx].reset();
				}
			}
			txtTime.text = (getTimer()-time)/1000+"sec";
			//txtInfo.text = Utility.addCommas(count) + "/" + Utility.addCommas(pixels.length);
		}

		private function fromCoordinate(posX:int,posY:int):PixelObject
		{
			if (posX >= lineCount || posX < 0)
			{
				return null;
			}
			if (posY >= pixels.length / lineCount || posY < 0)
			{
				return null;
			}
			var idx = lineCount * posY + posX;
			return pixels[idx];
		}
		
		private function getCoordinate(p:PixelObject):Point
		{
			var idx:int = pixels.indexOf(p);
			var row:Number = Math.floor(idx / lineCount);
			var col:Number = idx % lineCount;
			return new Point(col,row);
		}

		private function goFile(e:MouseEvent):void
		{
			if (editMode)
			{
				saveAsTiff();
				/*var str:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><pixeldoc>";
				for each(var p in pixels)
				{
					if (!p.isDefaultColor)
					{
						var pos:Point = getCoordinate(p);
						var it:String = "<pixel x=\"" + pos.x + "\" y=\"" + pos.y + "\" c=\"0x" + p.getColor.toString(16) + "\" a=\"" + p.getAlpha + "\" />";
						str += it;
					}
				}
				str += "</pixeldoc>";
				//var xml:XML = XML(str);
				var d:ByteArray = new ByteArray();
				//d.writeObject(xml);
				d.writeMultiByte(str,"utf-8");
				d.compress();
				var fs:FileReference = new FileReference();
				fs.addEventListener(Event.COMPLETE,saved);
				fs.save(d,".xdi");*/
			}
			else
			{
				file.browse([new FileFilter("Image File","*.bmp;*.jpg;*png;*.gif"),new FileFilter("XML Description File","*.xml;*.xdi")]);
			}
		}
		
		private function saveAsTiff():void
		{
			var d:ByteArray = new ByteArray();
			d.endian = Endian.LITTLE_ENDIAN;
			d.writeShort(0x4949)
			d.writeShort(0x002a);
			d.writeUnsignedInt(0x8);
			d.writeShort(0xe);//Number of Interoperability
			
			d.writeShort(0xfe);
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0);
			
			d.writeShort(0x100);
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(lineCount);
			
			d.writeShort(0x101)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(pixels.length/lineCount);
			
			d.writeShort(0x102)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x3);
			d.writeUnsignedInt(0xb6);//BitsPerSample

			d.writeShort(0x103)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x1);

			d.writeShort(0x106)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x2);

			d.writeShort(0x111)
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0xcc);//StripOffsets

			d.writeShort(0x115)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x3);

			d.writeShort(0x116)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(pixels.length/lineCount);//RowsPerStrip

			d.writeShort(0x117)
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(pixels.length * 3);

			d.writeShort(0x11a)
			d.writeShort(0x5);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0xbc);//XResolution

			d.writeShort(0x11b)
			d.writeShort(0x5);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0xc4);//YResolution

			d.writeShort(0x128)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x2);
			
			d.writeShort(0x8769)
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x11e05);//Exif IFD Pointer

			d.writeUnsignedInt(0);
			
			d.writeShort(0x8);
			d.writeShort(0x8);
			d.writeShort(0x8);
			
			d.writeUnsignedInt(72);
			d.writeUnsignedInt(1);

			d.writeUnsignedInt(72);
			d.writeUnsignedInt(1);
			
			for each(var p:PixelObject in pixels)
			{
				var c:uint = p.getColor;
				d.writeByte(c>>16);
				d.writeByte(c>>8);
				d.writeByte(c);
			}
			
			d.writeShort(0x1)
			
			d.writeShort(0x9000)
			d.writeShort(0x7);
			d.writeUnsignedInt(0x4);
			d.writeMultiByte("0221","gb2312");
			
			d.writeUnsignedInt(0);
			
			trace((d.length-1).toString(16));
			trace((pixels.length * 3).toString(16));
			
			var fs:FileReference = new FileReference();
			fs.addEventListener(Event.COMPLETE,saved);
			fs.save(d,".tif");
		}
		
		private function saved(e:Event):void
		{
			txtTime.text = "Saved!";
		}
		
		private function getFile(e:Event):void
		{
			file.load();
		}

		private function showFile(e:Event):void
		{
			time = getTimer();
			var dc:int = 0;
			var d:ByteArray = e.target.data;
			if (file.type == ".xdi"){
				try
				{
					d.uncompress();
				}
				catch(err)
				{
					txtTime.text = "Invaild XDI file!";
					return;
				}
			}
			else if (file.type != ".xml")
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,error);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,showImage);
				loader.loadBytes(d);
				return;
			}
			var xml:XML = XML(d);
			if (xml.name() != "pixeldoc") {
				txtTime.text = "Invaild file!";
				return;
			}
			for each(var item in xml.pixel)
			{
				var fx:int = Number(item.@x);
				var fy:int = Number(item.@y);
				var p:PixelObject = fromCoordinate(fx,fy);
				if (p != null)
				{
					if(item.@a!=null)
						p.setColor(Number(item.@c),Number(item.@a));
					else{
						p.setColor(Number(item.@c));
					}
				}
			}
			txtTime.text = (getTimer() - time) / 1000 + "sec";
			//txtInfo.text = Utility.addCommas(xml.pixel.length()) + "/" + Utility.addCommas(pixels.length);
		}
		
		private function showImage(e:Event):void
		{
			clearTimeout(tobj);
			resetAll();
			var loader:LoaderInfo = LoaderInfo(e.target);
			var bmp:Bitmap = loader.content as Bitmap;
			var bmd:BitmapData;
			if (bmp.width > dispRect.width || bmp.height > dispRect.height)
			{
				var r1:Number = bmp.width / bmp.height;
				var r2:Number = dispRect.width / dispRect.height;
				var ratio:Number;
				if (r1 < r2)
					ratio = dispRect.height / bmp.height;
				else
					ratio = dispRect.width / bmp.width;
				var nw:Number = Math.round(bmp.width*ratio);
				var nh:Number = Math.round(bmp.height*ratio);
				var matrix:Matrix = new Matrix();
				matrix.scale(ratio,ratio);
				bmd = new BitmapData(nw,nh,true,0);
				bmd.draw(bmp.bitmapData, matrix, null, null, null, true);
			}
			else
			{
				bmd = bmp.bitmapData;
			}
			if (cbCrop.selected)
			{
				var s:Number = Math.min(bmd.width,bmd.height);
				loadedImg = new BitmapData(s,s,true,0);
				var b:Bitmap = new Bitmap(bmd);
				var m:Shape = new Shape();
				m.graphics.beginFill(0x00FF00);
				m.graphics.drawCircle(s/2,s/2,s/2);
				m.graphics.endFill();
				b.mask = m;
				loadedImg.draw(b);
			}
			else
			{
				loadedImg = bmd;
			}
			
			pos = new Point(Math.round((dispRect.width - loadedImg.width) / 2),Math.round((dispRect.height - loadedImg.height) / 2));
			
			//loop(loadedImg);
			var count:int = drawImage(loadedImg,pos);
			txtTime.text = (getTimer() - time) / 1000 + "sec";
			btnPlay.enabled = true;
		}
		
		private function loop(source:BitmapData):void
		{
			resetAll();
			if (pos.x < -source.width)
				pos.x = dispRect.width + 1;
			var count:int = drawImage(source,pos);
			pos.x-=5;
			txtTime.text = (getTimer() - time) / 1000 + "sec";
			//txtInfo.text = Utility.addCommas(count) + "/" + Utility.addCommas(pixels.length);
			tobj = setTimeout(loop,100,source);
			time = getTimer();
		}
		
		private function drawImage(source:BitmapData,offset:Point=null):int
		{
			if (offset == null)
			{
				offset = new Point();
				offset.x = Math.floor((dispRect.width - source.width) / 2);
				offset.y = Math.floor((dispRect.height - source.height) / 2);
			}
			var count:int = 0;
			for (var i:int = 0;i<source.height;i++)
			{
				for (var j:int = 0;j<source.width;j++)
				{
					var p:PixelObject = fromCoordinate(j + offset.x,i + offset.y);
					if (p != null)
					{
						var argb:uint = source.getPixel32(j,i);
						var a:Number = Math.floor(argb / 0x1000000) / 0xff;
						if (a == 0)
							continue;
						var c:uint = argb % 0x1000000;
						p.setColor(c,a);
						count++;
					}
				}
			}
			return count;
		}
		
		private function toggleMotion(e:MouseEvent):void
		{
			if (btnPlay.label == "Play")
			{
				loop(loadedImg);
				btnPlay.label = "Pause";
			}
			else
			{
				clearTimeout(tobj);
				btnPlay.label = "Play";
			}
		}
		
		private function goBlink(e:MouseEvent):void
		{
			clearTimeout(tobj);
			showBlink();
		}
		
		private function showBlink():void
		{
			var seed:Array = idxlist.slice();
			seed = shuffle(seed,500);
			for each(var idx in seed)
			{
				pixels[idx].setColor(0xFFFFFF);
				setTimeout(pixels[idx].reset,150);
			}
			tobj = setTimeout(showBlink,50);
		}
		
		private function error(e:IOErrorEvent):void
		{
			txtTime.text = "Invaild image file!";
		}
		
		private function getRandNumber(min:int,max:int=0):int
		{
			if (max == 0)
			{
				max = min;
				min = 0;
			}
			return Math.floor(Math.random() * (max - min) + min);
		}
		
		public static function shuffle(arr:Array,len:int=0):Array
		{
			var arr2:Array = [];

			while (arr.length > 0)
			{
				arr2.push(arr.splice(Math.round(Math.random() * (arr.length - 1)), 1)[0]);
				if (len > 0 && arr2.length >= len)
				{
					arr2.concat(arr);
					break;
				}
			}
			return arr2;
		}
		
	}

}