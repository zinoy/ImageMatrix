package com.zino
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	
	import com.probertson.utils.GZIPBytesEncoder;

	public class PixelRootWorker extends Sprite
	{
		var pixels:Vector.<PixelObject>;
		var lineCount:int = 0;
		var editMode:Boolean = false;
		var file:FileReference;
		var defcolor:uint = 0;
		var time:int;
		var dispRect:Rectangle;

		public function PixelRootWorker()
		{
			init();
		}

		private function init():void
		{
			registerClassAlias("com.zino.PixelObject",PixelObject);
			
			removeChild(pMask);
			pBar.mode = "manual";
			pBar.setProgress(50,100);
			removeChild(pBar);
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
			dispRect.width = Math.floor((stage.stageWidth - 1) / 3);
			dispRect.height = Math.floor(((stage.stageHeight - 1) - 40) / 3);

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
			txtInfo.text = lineCount + "x" + (pixels.length / lineCount);
			file = new FileReference();
			file.addEventListener(Event.SELECT,getFile);
			file.addEventListener(Event.COMPLETE,showFile);

			btnShuffle.addEventListener(MouseEvent.CLICK,goShuffle);
			btnOpen.addEventListener(MouseEvent.CLICK,goFile);
			btnClear.addEventListener(MouseEvent.CLICK,resetAll);
			btnEdit.addEventListener(MouseEvent.CLICK,startEdit);
			addEventListener(MouseEvent.MOUSE_MOVE,dragMouse);
		}

		private function resetAll(e:MouseEvent=null):void
		{
			for each(var p in pixels)
			{
				if (!p.isDefaultColor)
				{
					p.reset();
				}
			}
			txtInfo.text = "0/" + Utility.addCommas(pixels.length);
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
			txtInfo.text = Utility.addCommas(count) + "/" + Utility.addCommas(pixels.length);
		}

		private function startEdit(e:MouseEvent):void
		{
			if (editMode)
			{
				btnEdit.label = "Edit";
				btnShuffle.enabled = true;
				btnOpen.label = "Open file...";
				removeEventListener(MouseEvent.MOUSE_DOWN,dragMouse);
				removeEventListener(MouseEvent.MOUSE_UP,countPixels);
			}
			else
			{
				btnEdit.label = "Done";
				btnShuffle.enabled = false;
				btnOpen.label = "Save...";
				txtTime.text = "";
				addEventListener(MouseEvent.MOUSE_DOWN,dragMouse);
				addEventListener(MouseEvent.MOUSE_UP,countPixels);
			}
			editMode = ! editMode;
		}

		private function dragMouse(e:MouseEvent):void
		{
			if (e.target is PixelObject)
			{
				if (!editMode)
				{
					if (e.target.isDefaultColor)
						txtTime.text = "";
					else
						txtTime.text = "#" + zeros(e.target.getColor);
				}
				else if (e.buttonDown)
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
			txtInfo.text = Utility.addCommas(count) + "/" + Utility.addCommas(pixels.length);
		}

		private function fromCoordinate(posX:int,posY:int):PixelObject
		{
			if (posX >= lineCount)
			{
				return null;
			}
			if (posY >= pixels.length / lineCount)
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
				var str:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><imgdesc><matrix>";
				for each(var p in pixels)
				{
					if (!p.isDefaultColor)
					{
						var pos:Point = getCoordinate(p);
						var it:String = "<pixel x=\"" + pos.x + "\" y=\"" + pos.y + "\" c=\"0x" + p.getColor.toString(16) + "\" a=\"" + p.getAlpha + "\" />";
						str += it;
					}
				}
				str += "</matrix></imgdesc>";
				var d:ByteArray = new ByteArray();
				d.writeMultiByte(str,"utf-8");
				var endr:GZIPBytesEncoder = new GZIPBytesEncoder();
				var output:ByteArray = endr.compressToByteArray(d);
				var fs:FileReference = new FileReference();
				fs.addEventListener(Event.COMPLETE,saved);
				fs.save(output,".xdi");
			}
			else
			{
				file.browse([new FileFilter("Image File","*.bmp;*.jpg;*png;*.gif"),new FileFilter("XML Description File","*.xml;*.xdi")]);
			}
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
			resetAll();
			var d:ByteArray = e.target.data;
			var orig:ByteArray;
			if (file.type == ".xdi"){
				try
				{
					var endr:GZIPBytesEncoder = new GZIPBytesEncoder();
					orig = endr.uncompressToByteArray(d);
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
			else
			{
				orig = d;
			}
			var xml:XML = XML(orig);
			if (xml.name() != "imgdesc")
			{
				txtTime.text = "Invaild file!";
				return;
			}
			var imgrect:Rectangle = new Rectangle(0,0,xml.info.dimension.@width,xml.info.dimension.@height);
			var offset:Point = new Point();
			if (!imgrect.isEmpty())
			{
				offset.x = Math.floor((dispRect.width - imgrect.width) / 2);
				offset.y = Math.floor((dispRect.height - imgrect.height) / 2);
			}
			for each(var item in xml.matrix.pixel)
			{
				var fx:int = Number(item.@x) + offset.x;
				var fy:int = Number(item.@y) + offset.y;
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
			txtInfo.text = Utility.addCommas(xml.pixel.length()) + "/" + Utility.addCommas(pixels.length);
		}
		
		private function showImage(e:Event):void
		{
			var loader:LoaderInfo = LoaderInfo(e.target);
			var bmp:Bitmap = loader.content as Bitmap;
			var fit:BitmapData;
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
				fit = new BitmapData(nw,nh,true,0);
				fit.draw(bmp.bitmapData, matrix, null, null, null, true);
			}
			else
			{
				fit = bmp.bitmapData;
			}
			
			var offset:Point = new Point();
			offset.x = Math.floor((dispRect.width - fit.width) / 2);
			offset.y = Math.floor((dispRect.height - fit.height) / 2);
			
			var count:int = 0;
			for (var i:int = 0;i<fit.height;i++)
			{
				for (var j:int = 0;j<fit.width;j++)
				{
					var p:PixelObject = fromCoordinate(j + offset.x,i + offset.y);
					var argb:uint = fit.getPixel32(j,i);
					var a:Number = Math.floor(argb / 0x1000000) / 0xff;
					var c:uint = argb % 0x1000000;
					p.setColor(c,a);
					count++;
				}
			}
			txtTime.text = (getTimer() - time) / 1000 + "sec";
			txtInfo.text = Utility.addCommas(count) + "/" + Utility.addCommas(pixels.length);
		}
		
		private function error(e:IOErrorEvent):void
		{
			txtTime.text = "Invaild image file!";
		}
		
		private function zeros(num:uint):String
		{
			var nt:String = num.toString(16);
			while (nt.length < 6)
			{
				nt = "0" + nt;
			}
			return nt;
		}

	}

}